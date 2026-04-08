public with sharing class AccountPDFController {
    @AuraEnabled(cacheable=true)
    public static AccountWrapper getAccountData(Id recordId) {
        Account acc = [SELECT Id, Name, Phone, Industry, AnnualRevenue, Website,
                              (SELECT Id, Name, StageName, Amount, CloseDate 
                               FROM Opportunities 
                               ORDER BY CloseDate DESC) 
                       FROM Account 
                       WHERE Id = :recordId 
                       LIMIT 1];
                       
        return new AccountWrapper(acc);
    }

    public class AccountWrapper {
        @AuraEnabled public Account account { get; set; }
        @AuraEnabled public List<Opportunity> opportunities { get; set; }

        public AccountWrapper(Account acc) {
            this.account = acc;
            this.opportunities = acc.Opportunities;
        }
    }
}