public with sharing class AccountController {

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList() {
        try {
            return [
                SELECT Id, Name, Phone, Industry, AnnualRevenue
                FROM Account
                WITH USER_MODE
                LIMIT 10
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Returns contacts for the accountsCard component, including their title and role.
     * Each contact is mapped to a lightweight wrapper so the LWC can render without
     * further SOQL or JS object manipulation.
     *
     * @param recordId  Id of the Account record whose contacts to fetch
     * @return          List of ContactRow wrappers (empty list if none found)
     */
    @AuraEnabled(cacheable=true)
    public static List<ContactRow> getAccountContacts(Id recordId) {
        if (recordId == null) {
            return new List<ContactRow>();
        }
        try {
            List<Contact> contacts = [
                SELECT Id, Name, Title, AccountId,
                       (SELECT ContactId, Role FROM AccountContactRoles LIMIT 1)
                FROM Contact
                WHERE AccountId = :recordId
                WITH USER_MODE
                ORDER BY Name
                LIMIT 50
            ];

            List<ContactRow> rows = new List<ContactRow>();
            for (Contact c : contacts) {
                String role = '';
                if (c.AccountContactRoles != null && !c.AccountContactRoles.isEmpty()) {
                    role = c.AccountContactRoles[0].Role;
                }
                rows.add(new ContactRow(c.Id, c.Name, c.Title, role));
            }
            return rows;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** Lightweight DTO transferred to the LWC. */
    public class ContactRow {
        @AuraEnabled public Id contactId { get; private set; }
        @AuraEnabled public String name    { get; private set; }
        @AuraEnabled public String title   { get; private set; }
        @AuraEnabled public String role    { get; private set; }

        /**
         * @param contactId  Salesforce Contact Id
         * @param name       Full name of the contact
         * @param title      Job title from Contact.Title
         * @param role       Account-contact relationship role (or empty string)
         */
        public ContactRow(Id contactId, String name, String title, String role) {
            this.contactId = contactId;
            this.name      = String.isBlank(name)  ? ''   : name;
            this.title     = String.isBlank(title) ? '--' : title;
            this.role      = String.isBlank(role)  ? '--' : role;
        }
    }
}