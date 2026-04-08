@IsTest
private class OpportunitiesPdfReportServiceTest {
    @IsTest
    static void attachesFileToAccount() {
        Account a = new Account(Name = 'Acme Demo', Industry = 'Technology');
        insert a;

        Opportunity o1 = new Opportunity(
            Name = 'Opp A',
            AccountId = a.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Amount = 1000
        );
        Opportunity o2 = new Opportunity(
            Name = 'Opp B',
            AccountId = a.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(20),
            Amount = 2500
        );
        insert new List<Opportunity>{o1, o2};

        Test.startTest();
        Id contentDocId = OpportunitiesPdfReportService.generateAndAttachPdf(a.Id);
        Test.stopTest();

        System.assertNotEquals(null, contentDocId, 'Should return a ContentDocumentId');

        List<ContentDocumentLink> links = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :contentDocId
            AND LinkedEntityId = :a.Id
        ];
        System.assert(!links.isEmpty(), 'File should be linked to the Account');
    }
}