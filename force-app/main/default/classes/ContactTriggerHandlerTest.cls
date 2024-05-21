@isTest
public class ContactTriggerHandlerTest {
    
    // Test method to verify the primary contact update logic
    @isTest
    static void testUpdatePrimaryContact() {
        // Creating a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Creating the initial primary contact
        Contact primaryContact = new Contact(
            FirstName = 'Primary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Is_Primary_Contact__c = true,
            Primary_Contact_Phone__c = '1234567890'
        );
        insert primaryContact;

        // Creating a non-primary contact
        Contact nonPrimaryContact = new Contact(
            FirstName = 'Non-primary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Is_Primary_Contact__c = false
        );
        insert nonPrimaryContact;

        // Updating the non-primary contact to be primary
        System.Test.startTest();
        nonPrimaryContact.Is_Primary_Contact__c = true;
        nonPrimaryContact.Primary_Contact_Phone__c = '0987654321';
        try {
            update nonPrimaryContact;
        } catch (DmlException e) {
            System.assertEquals(e.getDmlMessage(0), 'There is primary contact that already exist.', 'Error message should match.');
        }
        System.Test.stopTest();

        // Reload the contacts to check the results
        primaryContact = [SELECT Is_Primary_Contact__c FROM Contact WHERE Id = :primaryContact.Id];
        nonPrimaryContact = [SELECT Is_Primary_Contact__c FROM Contact WHERE Id = :nonPrimaryContact.Id];

        // Assertions to verify the primary contact update logic
        System.assertEquals(true, primaryContact.Is_Primary_Contact__c, 'The old primary contact should remain primary.');
        System.assertEquals(false, nonPrimaryContact.Is_Primary_Contact__c, 'The new contact should not be the primary contact.');
    }

    // Test method to verify the asynchronous update logic
    @isTest
    static void testUpdateAsyncContact() {
        // Creating a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Creating the initial primary contact
        Contact primaryContact = new Contact(
            FirstName = 'Primary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Is_Primary_Contact__c = true,
            Primary_Contact_Phone__c = '1234567890'
        );
        insert primaryContact;

        // Creating non-primary contacts
        Contact nonPrimaryContact1 = new Contact(
            FirstName = 'Non-primary1',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Is_Primary_Contact__c = false
        );
        Contact nonPrimaryContact2 = new Contact(
            FirstName = 'Non-primary2',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Is_Primary_Contact__c = false
        );
        insert new List<Contact>{nonPrimaryContact1, nonPrimaryContact2};

        // Updating the primary contact phone number
        System.Test.startTest();
        primaryContact.Primary_Contact_Phone__c = '0987654321';
        update primaryContact;
        System.Test.stopTest();

        // Using Test methods to verify @future method execution
        System.Test.startTest();
        // As future methods are enqueued, we have to make sure they execute
        // Fetching non-primary contacts again to verify they got updated
        nonPrimaryContact1 = [SELECT Primary_Contact_Phone__c FROM Contact WHERE Id = :nonPrimaryContact1.Id];
        nonPrimaryContact2 = [SELECT Primary_Contact_Phone__c FROM Contact WHERE Id = :nonPrimaryContact2.Id];
        System.Test.stopTest();

        // Assertions to verify that non-primary contacts have the updated primary contact phone
        System.assertEquals('0987654321', nonPrimaryContact1.Primary_Contact_Phone__c, 'The non-primary contact should have the updated primary contact phone.');
        System.assertEquals('0987654321', nonPrimaryContact2.Primary_Contact_Phone__c, 'The non-primary contact should have the updated primary contact phone.');
    }
}