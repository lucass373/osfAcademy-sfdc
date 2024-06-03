/*
*********************************************************
Apex Test Class Name : ContactTriggerHandlerTest
Created Date         : May 20, 2024
@description         : This test class verifies the functionality of the 
                       ContactTriggerHandler class, including the primary 
                       contact update logic and the asynchronous update logic.
@author              : Lucas Silva de Oliveira
Modification Log:
Ver   Date         Author         Modification
1.0   05-20-2024   Lucas Silva    Initial Version
1.1   05-21-2024   Lucas Silva    Update the test Classes to pass the tests.
*********************************************************
*/
@isTest
public class ContactTriggerHandlerTest {
     /*
    *********************************************************
    @Method Name    : testUpdatePrimaryContact
    @description    : Test method to verify if can set two contacts as primary.
    @param          : None
    @return         : void
    *********************************************************
    */
    @isTest
    static void testUpdatePrimaryContact() {        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact primaryContact = new Contact(
            FirstName = 'Primary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Is_Primary_Contact__c = true,
            Primary_Contact_Phone__c = '1234567890'
        );
        insert primaryContact;

        Contact nonPrimaryContact = new Contact(
            FirstName = 'Non-primary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Is_Primary_Contact__c = false
        );
        insert nonPrimaryContact;

        System.Test.startTest();
        nonPrimaryContact.Is_Primary_Contact__c = true;
        nonPrimaryContact.Primary_Contact_Phone__c = '0987654321';
        try {
            update nonPrimaryContact;
        } catch (DmlException e) {
            System.assertEquals(e.getDmlMessage(0), 'There is primary contact that already exist.', 'Error message should match.');
        }
        System.Test.stopTest();
        
        primaryContact = [SELECT Is_Primary_Contact__c FROM Contact WHERE Id = :primaryContact.Id];
        nonPrimaryContact = [SELECT Is_Primary_Contact__c FROM Contact WHERE Id = :nonPrimaryContact.Id];

        System.assertEquals(true, primaryContact.Is_Primary_Contact__c, 'The old primary contact should remain primary.');
        System.assertEquals(false, nonPrimaryContact.Is_Primary_Contact__c, 'The new contact should not be the primary contact.');
    }
    
     /*
    *********************************************************
    @Method Name    : testUpdateAsyncContact
    @description    : Test method to verify that non-primary contacts have the updated primary contact phone
    @param          : None
    @return         : void
    *********************************************************
    */
    @isTest
    static void testUpdateAsyncContact() {   

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact primaryContact = new Contact(
            FirstName = 'Primary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Is_Primary_Contact__c = true,
            Primary_Contact_Phone__c = '1234567890'
        );
        insert primaryContact;

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

        System.Test.startTest();
        primaryContact.Primary_Contact_Phone__c = '0987654321';
        update primaryContact;
        System.Test.stopTest();
            
        nonPrimaryContact1 = [SELECT Primary_Contact_Phone__c FROM Contact WHERE Id = :nonPrimaryContact1.Id];
        nonPrimaryContact2 = [SELECT Primary_Contact_Phone__c FROM Contact WHERE Id = :nonPrimaryContact2.Id];
                
        System.assertEquals('0987654321', nonPrimaryContact1.Primary_Contact_Phone__c, 'The non-primary contact should have the updated primary contact phone.');
        System.assertEquals('0987654321', nonPrimaryContact2.Primary_Contact_Phone__c, 'The non-primary contact should have the updated primary contact phone.');
    }
}