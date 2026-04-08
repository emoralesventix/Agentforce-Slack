public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList() {
        try {
            return [
                SELECT Id, Name, Phone, Industry, AnnualRevenue
                FROM Account 
                LIMIT 10
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}