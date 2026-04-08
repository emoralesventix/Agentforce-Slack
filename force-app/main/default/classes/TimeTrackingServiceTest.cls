@IsTest
private class TimeTrackingServiceTest {
    @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'TT Account');
        insert acc;

        Project__c projectA = new Project__c(
            Name = 'Project Alpha',
            Account__c = acc.Id
        );
        Project__c projectB = new Project__c(
            Name = 'Project Beta',
            Account__c = acc.Id
        );
        insert new List<Project__c>{ projectA, projectB };

        Project_Assignment__c assignmentA = new Project_Assignment__c(
            Project__c = projectA.Id,
            Assigned_User__c = UserInfo.getUserId(),
            Billing_Rate_Per_Hour__c = 100,
            Max_Weekly_Hours__c = 40
        );
        Project_Assignment__c assignmentB = new Project_Assignment__c(
            Project__c = projectB.Id,
            Assigned_User__c = UserInfo.getUserId(),
            Billing_Rate_Per_Hour__c = 0,
            Max_Weekly_Hours__c = 40
        );
        insert new List<Project_Assignment__c>{ assignmentA, assignmentB };
    }

    @IsTest
    static void submitEntries_happyPath_multiLine_success() {
        TimeTrackingService.Request req = new TimeTrackingService.Request();
        req.actingUserId = UserInfo.getUserId();
        req.optionalProject = 'Project Alpha';
        req.messageText =
            '2026-03-04; Weekly planning; 1200\n' +
            '2026-03-05; Dev work; 800';

        Test.startTest();
        List<TimeTrackingService.Response> outList = TimeTrackingService.submitEntries(
            new List<TimeTrackingService.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, outList.size());
        TimeTrackingService.Response res = outList[0];
        System.assertEquals(2, res.createdEntries.size());
        System.assertEquals(0, res.errors.size());
        System.assertNotEquals(null, res.weeklyUtilization);

        List<Time_Entry__c> rows = [
            SELECT Id, Hours__c, Notes__c, Period_Type__c
            FROM Time_Entry__c
            WHERE Project_Assignment__r.Project__r.Name = 'Project Alpha'
        ];
        Map<String, Time_Entry__c> byNote = new Map<String, Time_Entry__c>();
        for (Time_Entry__c row : rows) {
            byNote.put(row.Notes__c, row);
        }
        System.assert(byNote.containsKey('Weekly planning'));
        System.assert(byNote.containsKey('Dev work'));
        System.assertEquals('Weekly', byNote.get('Weekly planning').Period_Type__c);
        System.assertEquals(12.00, byNote.get('Weekly planning').Hours__c);
        System.assertEquals(8.00, byNote.get('Dev work').Hours__c);
    }

    @IsTest
    static void submitEntries_mixedValidity_collectsErrorsAndSuccesses() {
        TimeTrackingService.Request req = new TimeTrackingService.Request();
        req.actingUserId = UserInfo.getUserId();
        req.optionalProject = 'Project Alpha';
        req.messageText =
            'bad line without separators\n' +
            '2026-03-06; Valid note; 500';

        Test.startTest();
        List<TimeTrackingService.Response> outList = TimeTrackingService.submitEntries(
            new List<TimeTrackingService.Request>{ req }
        );
        Test.stopTest();

        TimeTrackingService.Response res = outList[0];
        System.assertEquals(1, res.createdEntries.size());
        System.assert(res.errors.size() > 0, 'Expected parse error for invalid line');

        List<Time_Entry__c> createdRows = [
            SELECT Id, Notes__c
            FROM Time_Entry__c
            WHERE Project_Assignment__r.Project__r.Name = 'Project Alpha'
        ];
        Integer validCount = 0;
        for (Time_Entry__c row : createdRows) {
            if (row.Notes__c == 'Valid note') {
                validCount++;
            }
        }
        System.assertEquals(1, validCount);
    }

    @IsTest
    static void submitEntries_missingRate_returnsError() {
        TimeTrackingService.Request req = new TimeTrackingService.Request();
        req.actingUserId = UserInfo.getUserId();
        req.optionalProject = 'Project Beta';
        req.messageText = '2026-03-07; No rate assignment; 300';

        Test.startTest();
        List<TimeTrackingService.Response> outList = TimeTrackingService.submitEntries(
            new List<TimeTrackingService.Request>{ req }
        );
        Test.stopTest();

        TimeTrackingService.Response res = outList[0];
        System.assertEquals(0, res.createdEntries.size());
        System.assert(res.errors.size() > 0, 'Expected missing-rate error');
    }

    @IsTest
    static void submitEntries_withoutProjectAndMultipleAssignments_returnsProjectListError() {
        TimeTrackingService.Request req = new TimeTrackingService.Request();
        req.actingUserId = UserInfo.getUserId();
        req.optionalProject = null;
        req.messageText = '2026-03-07; Need project selection; 300';

        Test.startTest();
        List<TimeTrackingService.Response> outList = TimeTrackingService.submitEntries(
            new List<TimeTrackingService.Request>{ req }
        );
        Test.stopTest();

        TimeTrackingService.Response res = outList[0];
        System.assertEquals(0, res.createdEntries.size());
        System.assert(res.errors.size() > 0, 'Expected project disambiguation error');
        System.assert(
            res.errors[0].contains('Project Alpha') && res.errors[0].contains('Project Beta'),
            'Expected available project names in the error message'
        );
    }

    @IsTest
    static void submitEntries_noSeparatorFormat_supported() {
        TimeTrackingService.Request req = new TimeTrackingService.Request();
        req.actingUserId = UserInfo.getUserId();
        req.optionalProject = 'Project Alpha';
        req.messageText = '2026-03-08 Dev work no separator 500';

        Test.startTest();
        List<TimeTrackingService.Response> outList = TimeTrackingService.submitEntries(
            new List<TimeTrackingService.Request>{ req }
        );
        Test.stopTest();

        TimeTrackingService.Response res = outList[0];
        System.assertEquals(1, res.createdEntries.size(), 'Expected one created entry');
        System.assertEquals(0, res.errors.size(), 'Expected no parse errors');
    }

    @IsTest
    static void parseDateToken_slashAndKeywords_supported() {
        System.assertEquals(Date.today(), TimeTrackingService.parseDateToken('today'));
        System.assertEquals(Date.today(), TimeTrackingService.parseDateToken('hoy'));
        System.assertEquals(Date.today(), TimeTrackingService.parseDateToken('HOY'));
        System.assertEquals(Date.today().addDays(-1), TimeTrackingService.parseDateToken('yesterday'));
        System.assertEquals(Date.today().addDays(-1), TimeTrackingService.parseDateToken('ayer'));
        System.assertEquals(Date.today().addDays(-1), TimeTrackingService.parseDateToken('AYER'));
        System.assertEquals(Date.newInstance(2026, 3, 12), TimeTrackingService.parseDateToken('03/12/2026'));
        System.assertEquals(Date.newInstance(2026, 3, 13), TimeTrackingService.parseDateToken('13/03/2026'));
    }
}