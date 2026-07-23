/**
 * Tests for AccountController, covering getAccountList and getAccountContacts.
 */
@IsTest
private class AccountControllerTest {

    @TestSetup
    static void setupTestData() {
        List<Account> accounts = TestDataFactory.createAccounts(5, true);
        TestDataFactory.createContacts(accounts, true);
    }

    // ── getAccountList ────────────────────────────────────────────────────────

    @IsTest
    static void shouldReturnAccounts_WhenRecordsExist() {
        Test.startTest();
        List<Account> result = AccountController.getAccountList();
        Test.stopTest();

        Assert.isTrue(result.size() > 0, 'Should return at least one account');
        Assert.isNotNull(result[0].Id, 'Account Id should be populated');
        Assert.isNotNull(result[0].Name, 'Account Name should be populated');
    }

    @IsTest
    static void shouldReturnAtMostTen_WhenMoreAccountsExist() {
        // @TestSetup creates 5; adding 10 more = 15 total, limit is 10
        TestDataFactory.createAccounts(10, true);

        Test.startTest();
        List<Account> result = AccountController.getAccountList();
        Test.stopTest();

        Assert.isTrue(result.size() <= 10, 'Result should respect the LIMIT 10 clause');
    }

    // ── getAccountContacts ────────────────────────────────────────────────────

    @IsTest
    static void shouldReturnContacts_WhenAccountHasContacts() {
        Account account = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<AccountController.ContactRow> rows =
            AccountController.getAccountContacts(account.Id);
        Test.stopTest();

        Assert.areEqual(1, rows.size(), 'Should return one contact for this account');
        Assert.isFalse(String.isBlank(rows[0].name), 'Contact name should be populated');
        Assert.areEqual('VP of Sales', rows[0].title, 'Title should match inserted value');
    }

    @IsTest
    static void shouldReturnEmptyList_WhenAccountHasNoContacts() {
        Account emptyAccount = TestDataFactory.createAccounts(1, true)[0];

        Test.startTest();
        List<AccountController.ContactRow> rows =
            AccountController.getAccountContacts(emptyAccount.Id);
        Test.stopTest();

        Assert.areEqual(0, rows.size(), 'Should return empty list when no contacts exist');
    }

    @IsTest
    static void shouldReturnEmptyList_WhenRecordIdIsNull() {
        Test.startTest();
        List<AccountController.ContactRow> rows =
            AccountController.getAccountContacts(null);
        Test.stopTest();

        Assert.areEqual(0, rows.size(), 'Null recordId should return empty list');
    }

    @IsTest
    static void shouldDefaultBlankFields_WhenTitleOrRoleIsNull() {
        Account account = TestDataFactory.createAccounts(1, true)[0];
        // Contact with no Title and no AccountContactRole
        Contact c = new Contact(FirstName = 'No', LastName = 'Title', AccountId = account.Id);
        insert c;

        Test.startTest();
        List<AccountController.ContactRow> rows =
            AccountController.getAccountContacts(account.Id);
        Test.stopTest();

        Assert.areEqual(1, rows.size(), 'Should have one row');
        Assert.areEqual('--', rows[0].title, 'Blank title should default to --');
        Assert.areEqual('--', rows[0].role,  'Missing role should default to --');
    }
}