public with sharing class OpportunityController {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunityList() {
        try {
            return [
                SELECT Id, Name, Amount, StageName, CloseDate, AccountId
                FROM Opportunity 
                LIMIT 10
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}