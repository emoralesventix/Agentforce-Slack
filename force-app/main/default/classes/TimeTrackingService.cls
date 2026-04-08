/**
 * Same as TimeTrackingProjectService: assignment/time-entry queries must honor actingUserId from
 * Agent context, not only the running user's sharing visibility.
 */
public without sharing class TimeTrackingService {
    public class Request {
        @InvocableVariable(required=true)
        public String messageText;

        @InvocableVariable
        public String actingUserId;

        @InvocableVariable
        public String optionalProject;

        /** If true, the third token on each line is hours worked. If false (default), it is billing amount and Hours = amount / Billing_Rate_Per_Hour__c. */
        @InvocableVariable
        public Boolean amountRepresentsHours;
    }

    public class Response {
        @InvocableVariable
        public List<String> createdEntries;

        @InvocableVariable
        public String weeklyUtilization;

        @InvocableVariable
        public List<String> warnings;

        @InvocableVariable
        public List<String> errors;
    }

    private class AssignmentResolution {
        Project_Assignment__c assignment;
        String errorMessage;
    }

    private class ParsedLine {
        Date entryDate;
        String note;
        Decimal amount;
        Integer sourceLine;
    }

    @InvocableMethod(
        label='Submit Time Entries'
        description='Parse Date + Note + hours (or billing amount) lines and create Time_Entry__c records'
    )
    public static List<Response> submitEntries(List<Request> requests) {
        List<Response> responses = new List<Response>();
        if (requests == null || requests.isEmpty()) {
            return responses;
        }

        for (Request req : requests) {
            responses.add(processRequest(req));
        }
        return responses;
    }

    private static Response processRequest(Request req) {
        Response res = new Response();
        res.createdEntries = new List<String>();
        res.warnings = new List<String>();
        res.errors = new List<String>();

        if (req == null || String.isBlank(req.messageText)) {
            res.errors.add(
                ':information_source: Message is empty. Send one or more lines with how long you worked, e.g. "today ; What I did ; 2" (2 hours) or "2026-03-21 Project meeting 1.5".'
            );
            return res;
        }

        String actingUserId = resolveActingUserId(req.actingUserId);
        AssignmentResolution resolution = resolveAssignment(actingUserId, req.optionalProject);
        if (resolution == null || resolution.assignment == null) {
            res.errors.add(
                resolution == null || String.isBlank(resolution.errorMessage)
                    ? 'No project assignment found for the submitting user. Please provide a project to disambiguate.'
                    : resolution.errorMessage
            );
            return res;
        }
        Project_Assignment__c assignment = resolution.assignment;

        Boolean hoursMode = req.amountRepresentsHours == true;

        if (
            !hoursMode &&
            (assignment.Billing_Rate_Per_Hour__c == null || assignment.Billing_Rate_Per_Hour__c <= 0)
        ) {
            res.errors.add('Assignment has no valid Billing Rate Per Hour. Please update Billing_Rate_Per_Hour__c first.');
            return res;
        }

        List<ParsedLine> parsedLines = parseLines(req.messageText, res.errors);
        if (parsedLines.isEmpty()) {
            if (!res.errors.isEmpty()) {
                res.errors.add(
                    0,
                    ':information_source: I couldn\'t parse your entries. Use one line per task: date, what you did, then hours (e.g. "today ; Demo work ; 2" for 2 hours).'
                );
            }
            return res;
        }

        Decimal rate = assignment.Billing_Rate_Per_Hour__c == null ? 0 : assignment.Billing_Rate_Per_Hour__c;
        if (hoursMode) {
            for (ParsedLine parsed : parsedLines) {
                if (parsed.amount == null || parsed.amount <= 0 || parsed.amount > 24) {
                    res.errors.add(
                        ':x: Line ' + parsed.sourceLine +
                        ': enter how many hours you worked on that line (more than 0, up to 24 hours per line).'
                    );
                    return res;
                }
            }
        }

        List<Time_Entry__c> recordsToInsert = new List<Time_Entry__c>();
        for (ParsedLine parsed : parsedLines) {
            Decimal hours = hoursMode ? parsed.amount : (parsed.amount / rate);
            recordsToInsert.add(new Time_Entry__c(
                Project_Assignment__c = assignment.Id,
                Entry_Date__c = parsed.entryDate,
                Hours__c = hours.setScale(2),
                Notes__c = parsed.note,
                Period_Type__c = 'Weekly'
            ));
        }

        SObjectAccessDecision accessDecision = Security.stripInaccessible(
            AccessType.CREATABLE,
            recordsToInsert
        );
        List<Time_Entry__c> sanitizedRecords = (List<Time_Entry__c>) accessDecision.getRecords();
        Database.SaveResult[] saveResults = Database.insert(sanitizedRecords, false);

        Set<Date> weekStartDates = new Set<Date>();
        for (Integer i = 0; i < saveResults.size(); i++) {
            Database.SaveResult sr = saveResults[i];
            ParsedLine parsed = parsedLines[i];
            if (sr.isSuccess()) {
                Decimal hours = recordsToInsert[i].Hours__c;
                String amountOrHoursLabel = hoursMode
                    ? 'Time logged: ' + formatHoursHuman(hours)
                    : 'Billing amount: ' +
                      String.valueOf(parsed.amount.setScale(2)) +
                      ' → time logged: ' +
                      formatHoursHuman(hours);
                res.createdEntries.add(
                    ':white_check_mark: ' +
                    parsed.entryDate.format() +
                    ' · ' +
                    amountOrHoursLabel +
                    ' · ' +
                    parsed.note
                );
                weekStartDates.add(getWeekStart(parsed.entryDate));
            } else {
                String errMsg = 'Line ' + parsed.sourceLine + ' failed';
                for (Database.Error e : sr.getErrors()) {
                    errMsg += ': ' + e.getMessage();
                }
                res.errors.add(':x: ' + errMsg);
            }
        }

        if (!res.createdEntries.isEmpty()) {
            res.weeklyUtilization = buildWeeklySummary(assignment.Id, assignment.Max_Weekly_Hours__c, weekStartDates);
            if (assignment.Max_Weekly_Hours__c != null) {
                Decimal totalHours = getTotalHoursForWeeks(assignment.Id, weekStartDates);
                if (totalHours > assignment.Max_Weekly_Hours__c) {
                    res.warnings.add(
                        ':warning: This week you are over the weekly guideline: ' +
                        formatHoursHuman(totalHours) +
                        ' logged vs ' +
                        formatHoursHuman(assignment.Max_Weekly_Hours__c) +
                        ' hours planned.'
                    );
                } else if (totalHours >= (assignment.Max_Weekly_Hours__c * 0.9)) {
                    res.warnings.add(
                        ':warning: You are close to your weekly hours guideline: ' +
                        formatHoursHuman(totalHours) +
                        ' of ' +
                        formatHoursHuman(assignment.Max_Weekly_Hours__c) +
                        ' hours.'
                    );
                }
            }
        }

        return res;
    }

    private static AssignmentResolution resolveAssignment(String actingUserId, String optionalProject) {
        AssignmentResolution resolution = new AssignmentResolution();
        if (String.isBlank(actingUserId)) {
            resolution.errorMessage = 'Could not identify the submitting user.';
            return resolution;
        }

        List<Project_Assignment__c> assignments = [
            SELECT Id, Max_Weekly_Hours__c, Billing_Rate_Per_Hour__c, Project__c, Project__r.Name
            FROM Project_Assignment__c
            WHERE Assigned_User__c = :actingUserId
            ORDER BY LastModifiedDate DESC
        ];

        if (assignments.isEmpty()) {
            resolution.errorMessage = ':information_source: No project assignments found for your user. Please ask an admin to create one.';
            return resolution;
        }

        if (String.isBlank(optionalProject)) {
            if (assignments.size() == 1) {
                resolution.assignment = assignments[0];
                return resolution;
            }
            resolution.errorMessage =
                ':information_source: I found multiple projects for your user. Please specify one in the project field. Available projects: ' +
                String.join(buildProjectOptions(assignments), ', ');
            return resolution;
        }

        String projectFilter = optionalProject.trim();
        String normalizedFilter = projectFilter.toLowerCase();
        for (Project_Assignment__c assignment : assignments) {
            if (
                String.valueOf(assignment.Project__c) == projectFilter ||
                (assignment.Project__r != null && assignment.Project__r.Name != null &&
                 assignment.Project__r.Name.toLowerCase() == normalizedFilter)
            ) {
                resolution.assignment = assignment;
                return resolution;
            }
        }

        resolution.errorMessage =
            ':information_source: Project "' + projectFilter + '" was not found for your user. Available projects: ' +
            String.join(buildProjectOptions(assignments), ', ');
        return resolution;
    }

    private static String resolveActingUserId(String actingUserId) {
        if (!String.isBlank(actingUserId) && looksLikeUserId(actingUserId)) {
            return actingUserId;
        }

        return null;
    }

    private static Boolean looksLikeUserId(String value) {
        return !String.isBlank(value) &&
            (value.length() == 15 || value.length() == 18) &&
            value.startsWith('005');
    }

    private static List<String> buildProjectOptions(List<Project_Assignment__c> assignments) {
        Set<String> names = new Set<String>();
        for (Project_Assignment__c assignment : assignments) {
            if (assignment.Project__r != null && !String.isBlank(assignment.Project__r.Name)) {
                names.add(assignment.Project__r.Name);
            } else if (assignment.Project__c != null) {
                names.add(String.valueOf(assignment.Project__c));
            }
        }
        List<String> out = new List<String>();
        out.addAll(names);
        out.sort();
        return out;
    }

    private static List<ParsedLine> parseLines(String messageText, List<String> errors) {
        List<ParsedLine> result = new List<ParsedLine>();
        List<String> lines = messageText.split('\\n');
        Integer lineNumber = 0;
        for (String rawLine : lines) {
            lineNumber++;
            String line = rawLine == null ? '' : rawLine.trim();
            if (line == '') {
                continue;
            }
            ParsedLine parsed = parseSingleLine(line, lineNumber);
            if (parsed == null) {
                errors.add(
                    ':x: Line ' + lineNumber +
                    ' is invalid. Use: date, description, then hours (e.g. "today ; Work done ; 2") with ; or | between parts.'
                );
            } else {
                result.add(parsed);
            }
        }
        return result;
    }

    private static ParsedLine parseSingleLine(String line, Integer lineNumber) {
        List<String> parts;
        String separator = getSeparator(line);
        if (separator != null) {
            parts = line.split('\\' + separator);
            if (parts.size() < 3) {
                return null;
            }

            String dateToken = parts[0].trim();
            String amountToken = parts[parts.size() - 1].trim();
            String noteToken = joinMiddleParts(parts).trim();
            return buildParsedLine(dateToken, noteToken, amountToken, lineNumber);
        }

        // Flexible fallback without separators: Date + free-text note + Amount
        Integer firstSpace = line.indexOf(' ');
        Integer lastSpace = line.lastIndexOf(' ');
        if (firstSpace <= 0 || lastSpace <= firstSpace) {
            return null;
        }
        String dateToken = line.substring(0, firstSpace).trim();
        String amountToken = line.substring(lastSpace + 1).trim();
        String noteToken = line.substring(firstSpace + 1, lastSpace).trim();
        return buildParsedLine(dateToken, noteToken, amountToken, lineNumber);
    }

    private static ParsedLine buildParsedLine(String dateToken, String noteToken, String amountToken, Integer lineNumber) {
        Date parsedDate = parseDateToken(dateToken);
        Decimal parsedAmount = parseAmount(amountToken);

        if (parsedDate == null || parsedAmount == null || String.isBlank(noteToken)) {
            return null;
        }

        ParsedLine parsed = new ParsedLine();
        parsed.entryDate = parsedDate;
        parsed.amount = parsedAmount;
        parsed.note = noteToken;
        parsed.sourceLine = lineNumber;
        return parsed;
    }

    private static String getSeparator(String line) {
        if (line.contains(';')) {
            return ';';
        }
        if (line.contains('|')) {
            return '|';
        }
        if (line.contains(',')) {
            return ',';
        }
        return null;
    }

    private static String joinMiddleParts(List<String> parts) {
        if (parts.size() == 3) {
            return parts[1];
        }
        List<String> middle = new List<String>();
        for (Integer i = 1; i < parts.size() - 1; i++) {
            middle.add(parts[i]);
        }
        return String.join(middle, ' ');
    }

    private static Decimal parseAmount(String amountToken) {
        if (String.isBlank(amountToken)) {
            return null;
        }
        String cleaned = amountToken.toLowerCase().replace('$', '').replace('usd', '').trim();
        cleaned = cleaned.replace(',', '.');
        try {
            return Decimal.valueOf(cleaned);
        } catch (Exception ex) {
            return null;
        }
    }

    @TestVisible
    private static Date parseDateToken(String token) {
        if (String.isBlank(token)) {
            return null;
        }
        String normalized = token.trim().toLowerCase();
        if (normalized == 'today' || normalized == 'hoy') {
            return Date.today();
        }
        if (normalized == 'yesterday' || normalized == 'ayer') {
            return Date.today().addDays(-1);
        }

        try {
            return Date.valueOf(token.trim());
        } catch (Exception ex) {
            // no-op
        }

        if (token.contains('/')) {
            List<String> chunks = token.split('/');
            if (chunks.size() == 3) {
                try {
                    Integer a = Integer.valueOf(chunks[0]);
                    Integer b = Integer.valueOf(chunks[1]);
                    Integer y = Integer.valueOf(chunks[2]);
                    Integer month;
                    Integer day;
                    if (a > 12) {
                        day = a;
                        month = b;
                    } else {
                        month = a;
                        day = b;
                    }
                    return Date.newInstance(y, month, day);
                } catch (Exception ex2) {
                    return null;
                }
            }
        }
        return null;
    }

    private static String buildWeeklySummary(Id assignmentId, Decimal maxWeeklyHours, Set<Date> weekStartDates) {
        Decimal totalHours = getTotalHoursForWeeks(assignmentId, weekStartDates);
        String summary = 'This week you have logged ' + formatHoursHuman(totalHours) + ' on this assignment';
        if (maxWeeklyHours != null) {
            Decimal remaining = maxWeeklyHours - totalHours;
            summary +=
                ' (weekly guideline ' +
                formatHoursHuman(maxWeeklyHours) +
                '; ' +
                (remaining >= 0
                    ? formatHoursHuman(remaining) + ' still available'
                    : formatHoursHuman(-remaining) + ' over the guideline') +
                ')';
        }
        if (!weekStartDates.isEmpty()) {
            List<Date> ordered = new List<Date>();
            ordered.addAll(weekStartDates);
            ordered.sort();
            summary += '. Week starting ' + ordered[0].format();
        }
        return summary;
    }

    /** Plain language for Slack users (always "hours" / "minutes", never bare decimals that look like money). */
    @TestVisible
    private static String formatHoursHuman(Decimal hours) {
        if (hours == null || hours <= 0) {
            return '0 hours';
        }
        if (hours < 1) {
            Integer minutes = (Integer) Math.round(hours * 60);
            if (minutes < 1) {
                minutes = 1;
            }
            return String.valueOf(minutes) + ' minutes';
        }
        Decimal rounded = hours.setScale(2, System.RoundingMode.HALF_UP);
        Decimal whole = rounded.setScale(0, System.RoundingMode.DOWN);
        if (rounded == whole) {
            return String.valueOf(whole.intValue()) + ' hours';
        }
        String s = String.valueOf(rounded);
        while (s.contains('.') && s.endsWith('0')) {
            s = s.substring(0, s.length() - 1);
        }
        if (s.endsWith('.')) {
            s = s.substring(0, s.length() - 1);
        }
        return s + ' hours';
    }

    private static Decimal getTotalHoursForWeeks(Id assignmentId, Set<Date> weekStartDates) {
        if (weekStartDates.isEmpty()) {
            return 0;
        }
        Decimal total = 0;
        List<Time_Entry__c> rows = [
            SELECT Hours__c
            FROM Time_Entry__c
            WHERE Project_Assignment__c = :assignmentId
            AND Week_Start_Date__c IN :weekStartDates
        ];
        for (Time_Entry__c row : rows) {
            total += (row.Hours__c == null ? 0 : row.Hours__c);
        }
        return total;
    }

    @TestVisible
    private static Date getWeekStart(Date inputDate) {
        Date refMonday = Date.newInstance(1900, 1, 8);
        Integer offset = Math.mod(refMonday.daysBetween(inputDate), 7);
        return inputDate.addDays(-offset);
    }
}