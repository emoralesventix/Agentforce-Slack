@IsTest
private class TimeEntryAuditQueryServiceTest {
    @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'Audit Account');
        insert acc;

        Project__c proj = new Project__c(Name = 'Audit Project', Account__c = acc.Id);
        insert proj;

        Project_Assignment__c pa = new Project_Assignment__c(
            Project__c = proj.Id,
            Assigned_User__c = UserInfo.getUserId(),
            Billing_Rate_Per_Hour__c = 100,
            Max_Weekly_Hours__c = 40
        );
        insert pa;

        insert new Time_Entry__c(
            Project_Assignment__c = pa.Id,
            Entry_Date__c = Date.newInstance(2026, 4, 2),
            Hours__c = 4,
            Notes__c = 'Test audit entry',
            Period_Type__c = 'Weekly'
        );
    }

    @IsTest
    static void getAuditData_byTimeEntryIds_returnsJson() {
        Time_Entry__c te = [SELECT Id FROM Time_Entry__c LIMIT 1];

        TimeEntryAuditQueryService.Input in0 = new TimeEntryAuditQueryService.Input();
        in0.timeEntryIds = new List<String>{ te.Id };

        Test.startTest();
        List<TimeEntryAuditQueryService.Output> outs = TimeEntryAuditQueryService.getAuditData(
            new List<TimeEntryAuditQueryService.Input>{ in0 }
        );
        Test.stopTest();

        System.assertEquals(1, outs.size());
        System.assert(String.isBlank(outs[0].errorMessage), outs[0].errorMessage);
        System.assertEquals(1, outs[0].recordCount);
        System.assert(outs[0].auditJson.contains('Audit Project'), outs[0].auditJson);
        System.assert(outs[0].auditJson.contains('Test audit entry'), outs[0].auditJson);
    }

    @IsTest
    static void getAuditData_byDateRange_returnsRows() {
        TimeEntryAuditQueryService.Input in0 = new TimeEntryAuditQueryService.Input();
        in0.entryDateFrom = Date.newInstance(2026, 4, 1);
        in0.entryDateTo = Date.newInstance(2026, 4, 30);

        Test.startTest();
        List<TimeEntryAuditQueryService.Output> outs = TimeEntryAuditQueryService.getAuditData(
            new List<TimeEntryAuditQueryService.Input>{ in0 }
        );
        Test.stopTest();

        System.assertEquals(1, outs.size());
        System.assert(String.isBlank(outs[0].errorMessage), outs[0].errorMessage);
        System.assertEquals(1, outs[0].recordCount);
    }

    @IsTest
    static void getAuditData_noCriteria_returnsError() {
        TimeEntryAuditQueryService.Input in0 = new TimeEntryAuditQueryService.Input();

        List<TimeEntryAuditQueryService.Output> outs = TimeEntryAuditQueryService.getAuditData(
            new List<TimeEntryAuditQueryService.Input>{ in0 }
        );

        System.assertEquals(1, outs.size());
        System.assert(!String.isBlank(outs[0].errorMessage));
    }

    @IsTest
    static void getAuditData_commaSeparatedId_inList() {
        Time_Entry__c te = [SELECT Id FROM Time_Entry__c LIMIT 1];
        String id18 = String.valueOf(te.Id);

        TimeEntryAuditQueryService.Input in0 = new TimeEntryAuditQueryService.Input();
        in0.timeEntryIds = new List<String>{ id18 + ', ' + id18 };

        List<TimeEntryAuditQueryService.Output> outs = TimeEntryAuditQueryService.getAuditData(
            new List<TimeEntryAuditQueryService.Input>{ in0 }
        );

        System.assertEquals(1, outs.size());
        System.assertEquals(1, outs[0].recordCount);
    }
}