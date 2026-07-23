/**
 * Central factory for test record creation. All @TestSetup methods must delegate here.
 * Never call DML directly inside test setup — always use these helpers.
 */
@IsTest
public class TestDataFactory {

    /**
     * Creates and inserts Account records.
     *
     * @param count   Number of accounts to create
     * @param doInsert  When true, inserts records before returning them
     * @return          List of Account records
     */
    public static List<Account> createAccounts(Integer count, Boolean doInsert) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        if (doInsert) {
            insert accounts;
        }
        return accounts;
    }

    /**
     * Creates and inserts Contact records linked to the supplied accounts.
     *
     * @param accounts  Parent accounts (must already be inserted)
     * @param doInsert  When true, inserts records before returning them
     * @return          List of Contact records (one per account)
     */
    public static List<Contact> createContacts(List<Account> accounts, Boolean doInsert) {
        List<Contact> contacts = new List<Contact>();
        Integer i = 0;
        for (Account a : accounts) {
            contacts.add(new Contact(
                FirstName = 'First' + i,
                LastName  = 'Last'  + i,
                Title     = 'VP of Sales',
                AccountId = a.Id
            ));
            i++;
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }
}