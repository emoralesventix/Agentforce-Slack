/**
 * Flow / integration helper: returns raw audit data for Time_Entry__c with related
 * Project_Assignment__c, Project__c, Account, and Assigned User — as one JSON string.
 * Use this when you want deterministic data (no LLM Query Records).
 */
public with sharing class TimeEntryAuditQueryService {
    private static final Integer MAX_ROWS = 2000;

    public class Input {
        @InvocableVariable(
            label='Time Entry Ids'
            description='List of Time_Entry__c Ids. Leave empty to filter by Entry Date range instead.'
        )
        public List<String> timeEntryIds;

        @InvocableVariable(
            label='Entry Date From'
            description='Inclusive start date (Time_Entry__c.Entry_Date__c). Used only when Time Entry Ids is empty.'
        )
        public Date entryDateFrom;

        @InvocableVariable(
            label='Entry Date To'
            description='Inclusive end date (Time_Entry__c.Entry_Date__c). Used only when Time Entry Ids is empty.'
        )
        public Date entryDateTo;
    }

    public class Output {
        @InvocableVariable(
            label='Audit JSON'
            description='JSON array: one object per time entry with nested timeEntry, projectAssignment, project, account, assignedUser.'
        )
        public String auditJson;

        @InvocableVariable(label='Record Count')
        public Integer recordCount;

        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    @InvocableMethod(
        label='Get Time Entry Audit Data'
        description='Loads Time_Entry__c rows with Project_Assignment__c, Project__c, Account, and User for Flow or APIs.'
    )
    public static List<Output> getAuditData(List<Input> inputs) {
        List<Output> outs = new List<Output>();
        if (inputs == null || inputs.isEmpty()) {
            Output o = new Output();
            o.errorMessage = 'No input provided.';
            outs.add(o);
            return outs;
        }

        Input in0 = inputs[0];
        Set<Id> idSet = new Set<Id>();
        if (in0.timeEntryIds != null) {
            for (String raw : in0.timeEntryIds) {
                if (String.isBlank(raw)) {
                    continue;
                }
                for (String part : raw.split(',')) {
                    String t = part != null ? part.trim() : '';
                    if (String.isBlank(t)) {
                        continue;
                    }
                    try {
                        idSet.add((Id) t);
                    } catch (Exception e) {
                        Output bad = new Output();
                        bad.errorMessage = 'Invalid Time Entry Id: ' + t;
                        outs.add(bad);
                        return outs;
                    }
                }
            }
        }

        List<Time_Entry__c> rows;
        try {
            if (!idSet.isEmpty()) {
                rows = [
                    SELECT
                        Id,
                        Name,
                        Entry_Date__c,
                        Hours__c,
                        Notes__c,
                        Period_Type__c,
                        Project_Assignment__c,
                        Project_Assignment__r.Id,
                        Project_Assignment__r.Name,
                        Project_Assignment__r.Assigned_User__c,
                        Project_Assignment__r.Assigned_User__r.Name,
                        Project_Assignment__r.Project__c,
                        Project_Assignment__r.Project__r.Name,
                        Project_Assignment__r.Project__r.Account__c,
                        Project_Assignment__r.Project__r.Account__r.Name,
                        Project_Assignment__r.Project__r.Opportunity__c,
                        Project_Assignment__r.Project__r.Opportunity__r.Name,
                        Project_Assignment__r.Max_Weekly_Hours__c,
                        Project_Assignment__r.Max_Hours__c,
                        Project_Assignment__r.Logged_Hours__c,
                        Project_Assignment__r.Billing_Rate_Per_Hour__c,
                        Project_Assignment__r.Allocated_Hours__c
                    FROM Time_Entry__c
                    WHERE Id IN :idSet
                    ORDER BY Entry_Date__c DESC, Id
                    LIMIT :MAX_ROWS
                ];
            } else if (in0.entryDateFrom != null && in0.entryDateTo != null) {
                rows = [
                    SELECT
                        Id,
                        Name,
                        Entry_Date__c,
                        Hours__c,
                        Notes__c,
                        Period_Type__c,
                        Project_Assignment__c,
                        Project_Assignment__r.Id,
                        Project_Assignment__r.Name,
                        Project_Assignment__r.Assigned_User__c,
                        Project_Assignment__r.Assigned_User__r.Name,
                        Project_Assignment__r.Project__c,
                        Project_Assignment__r.Project__r.Name,
                        Project_Assignment__r.Project__r.Account__c,
                        Project_Assignment__r.Project__r.Account__r.Name,
                        Project_Assignment__r.Project__r.Opportunity__c,
                        Project_Assignment__r.Project__r.Opportunity__r.Name,
                        Project_Assignment__r.Max_Weekly_Hours__c,
                        Project_Assignment__r.Max_Hours__c,
                        Project_Assignment__r.Logged_Hours__c,
                        Project_Assignment__r.Billing_Rate_Per_Hour__c,
                        Project_Assignment__r.Allocated_Hours__c
                    FROM Time_Entry__c
                    WHERE Entry_Date__c >= :in0.entryDateFrom AND Entry_Date__c <= :in0.entryDateTo
                    ORDER BY Entry_Date__c DESC, Id
                    LIMIT :MAX_ROWS
                ];
            } else {
                Output o = new Output();
                o.errorMessage =
                    'Provide either Time Entry Ids, or both Entry Date From and Entry Date To.';
                outs.add(o);
                return outs;
            }
        } catch (Exception e) {
            Output o = new Output();
            o.errorMessage = 'Query failed: ' + e.getMessage();
            outs.add(o);
            return outs;
        }

        List<AuditRow> payload = new List<AuditRow>();
        for (Time_Entry__c te : rows) {
            payload.add(buildRow(te));
        }

        Output ok = new Output();
        ok.recordCount = payload.size();
        ok.auditJson = JSON.serializePretty(payload);
        outs.add(ok);
        return outs;
    }

    private static AuditRow buildRow(Time_Entry__c te) {
        AuditRow r = new AuditRow();
        r.timeEntry = new TimeEntryDto();
        r.timeEntry.id = te.Id;
        r.timeEntry.name = te.Name;
        r.timeEntry.entryDate = te.Entry_Date__c;
        r.timeEntry.hours = te.Hours__c;
        r.timeEntry.notes = te.Notes__c;
        r.timeEntry.periodType = te.Period_Type__c;
        r.timeEntry.projectAssignmentId = te.Project_Assignment__c;

        Project_Assignment__c pa = te.Project_Assignment__r;
        if (pa != null) {
            r.projectAssignment = new ProjectAssignmentDto();
            r.projectAssignment.id = pa.Id;
            r.projectAssignment.name = pa.Name;
            r.projectAssignment.maxWeeklyHours = pa.Max_Weekly_Hours__c;
            r.projectAssignment.maxHours = pa.Max_Hours__c;
            r.projectAssignment.loggedHours = pa.Logged_Hours__c;
            r.projectAssignment.billingRatePerHour = pa.Billing_Rate_Per_Hour__c;
            r.projectAssignment.allocatedHours = pa.Allocated_Hours__c;
            r.projectAssignment.assignedUserId = pa.Assigned_User__c;
            r.projectAssignment.projectId = pa.Project__c;

            if (pa.Assigned_User__r != null) {
                r.assignedUser = new UserDto();
                r.assignedUser.id = pa.Assigned_User__r.Id;
                r.assignedUser.name = pa.Assigned_User__r.Name;
            }

            if (pa.Project__r != null) {
                r.project = new ProjectDto();
                r.project.id = pa.Project__r.Id;
                r.project.name = pa.Project__r.Name;
                if (pa.Project__r.Account__r != null) {
                    r.account = new AccountDto();
                    r.account.id = pa.Project__r.Account__c;
                    r.account.name = pa.Project__r.Account__r.Name;
                }
                if (pa.Project__r.Opportunity__r != null) {
                    r.opportunity = new OpportunityDto();
                    r.opportunity.id = pa.Project__r.Opportunity__c;
                    r.opportunity.name = pa.Project__r.Opportunity__r.Name;
                }
            }
        }
        return r;
    }

    public class AuditRow {
        public TimeEntryDto timeEntry;
        public ProjectAssignmentDto projectAssignment;
        public ProjectDto project;
        public AccountDto account;
        public OpportunityDto opportunity;
        public UserDto assignedUser;
    }

    public class TimeEntryDto {
        public Id id;
        public String name;
        public Date entryDate;
        public Decimal hours;
        public String notes;
        public String periodType;
        public Id projectAssignmentId;
    }

    public class ProjectAssignmentDto {
        public Id id;
        public String name;
        public Decimal maxWeeklyHours;
        public Decimal maxHours;
        public Decimal loggedHours;
        public Decimal billingRatePerHour;
        public Decimal allocatedHours;
        public Id assignedUserId;
        public Id projectId;
    }

    public class ProjectDto {
        public Id id;
        public String name;
    }

    public class AccountDto {
        public Id id;
        public String name;
    }

    public class OpportunityDto {
        public Id id;
        public String name;
    }

    public class UserDto {
        public Id id;
        public String name;
    }
}