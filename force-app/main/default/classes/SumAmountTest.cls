/*
*********************************************************
Apex Test Class Name : SumAmountTest
Created Date         : May 20, 2024
@description         : This test class verifies the functionality of the 
                       SumAmount batch class by setting up test data and 
                       validating the batch processing and email sending.
                       It includes a setup method to create test records 
                       and a test method to execute and validate the batch job.
@author              : Lucas Silva de Oliveira
Modification Log:
Ver   Date         Author         Modification
1.0   05-20-2024   Lucas Silva   Initial Version
1.1   05-21-2024   Lucas Silva   Updated the test to verify the email content.
*********************************************************
*/
@isTest
public class SumAmountTest {

    /*
    *********************************************************
    @Method Name    : setup
    @description    : Test setup method to create test data for Accounts, 
                      Contacts, and Opportunities.
    @param          : None
    @return         : void
    *********************************************************
    */
    @testSetup
    static void setup() {
        
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Account A'),
            new Account(Name = 'Account B')
        };
        insert accounts;
                
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'Primary', LastName = 'ContactA', Email = 'primaryA@example.com', AccountId = accounts[0].Id, Is_Primary_Contact__c = true),
            new Contact(FirstName = 'Primary', LastName = 'ContactB', Email = 'primaryB@example.com', AccountId = accounts[1].Id, Is_Primary_Contact__c = true)
        };
        insert contacts;
                
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(AccountId = accounts[0].Id, Name='op1', StageName = 'Closed Won', Amount = 1000, CloseDate = Date.today()),
            new Opportunity(AccountId = accounts[0].Id, Name='op2', StageName = 'Negotiation', Amount = 500, CloseDate = Date.today().addDays(-1)),
            new Opportunity(AccountId = accounts[0].Id, Name='op3', StageName = 'Closed Lost', Amount = 200, CloseDate = Date.today().addDays(-25)),
                
            new Opportunity(AccountId = accounts[1].Id, Name='op4', StageName = 'Closed Won', Amount = 1500, CloseDate = Date.today().addDays(-10)),
            new Opportunity(AccountId = accounts[1].Id, Name='op5', StageName = 'Negotiation', Amount = 700, CloseDate = Date.today().addDays(-25)),
            new Opportunity(AccountId = accounts[1].Id, Name='op6', StageName = 'Closed Lost', Amount = 300, CloseDate = Date.today())
        };
        insert opportunities;
    }

    /*
    *********************************************************
    @Method Name    : testBatchExecution
    @description    : Test method to verify the execution of the SumAmount 
                      batch class and validate the processing and email sending.
    @param          : None
    @return         : void
    *********************************************************
    */
    @isTest
    static void testBatchExecution() {
        
        System.Test.startTest();
        
        SumAmount batch = new SumAmount();
        Database.executeBatch(batch);
        System.Test.stopTest();
        
        
        List<EmailMessage> sentEmails = [SELECT Id, Subject, HtmlBody FROM EmailMessage];

        System.assertEquals(2, sentEmails.size(), 'Two emails should have been sent.');
        
          for (EmailMessage email : sentEmails) {
            if (email.Subject.contains('Account A')) {
                System.assert(email.HtmlBody.contains('Account A'), 'Email should contain Account A.');
                System.assert(email.HtmlBody.contains('Closed Won'), 'Email should contain Closed Won stage.');
                System.assert(email.HtmlBody.contains('R$ 1.000'), 'Email should contain Closed Won amount for Account A.');
                System.assert(email.HtmlBody.contains('Open'), 'Email should contain Open stage.');
                System.assert(email.HtmlBody.contains('R$ 500'), 'Email should contain Open amount for Account A.');
                System.assert(email.HtmlBody.contains('Closed Lost'), 'Email should contain Closed Lost stage.');
                System.assert(email.HtmlBody.contains('R$ 0'), 'Email should contain Closed Lost amount for Account A.');
                
            } else if (email.Subject.contains('Account B')) {
                System.assert(email.HtmlBody.contains('Account B'), 'Email should contain Account B.');
                System.assert(email.HtmlBody.contains('Closed Won'), 'Email should contain Closed Won stage.');
                System.assert(email.HtmlBody.contains('R$ 0'), 'Email should contain Closed Won amount for Account B.');
                System.assert(email.HtmlBody.contains('Open'), 'Email should contain Open stage.');
                System.assert(email.HtmlBody.contains('R$ 0'), 'Email should contain Open amount for Account B.');
                System.assert(email.HtmlBody.contains('Closed Lost'), 'Email should contain Closed Lost stage.');
                System.assert(email.HtmlBody.contains('R$ 300'), 'Email should contain Closed Lost amount for Account B.');
            }
        }
    }
}