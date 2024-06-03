@isTest
public class SumAmountTest {
    @testSetup
    static void setup() {
        // Create test Accounts
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Account A'),
            new Account(Name = 'Account B')
        };
        insert accounts;
        
        // Create test Contacts with Is_Primary_Contact__c set to true
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'Primary', LastName = 'ContactA', Email = 'primaryA@example.com', AccountId = accounts[0].Id, Is_Primary_Contact__c = true),
            new Contact(FirstName = 'Primary', LastName = 'ContactB', Email = 'primaryB@example.com', AccountId = accounts[1].Id, Is_Primary_Contact__c = true)
        };
        insert contacts;
        
        // Create test Opportunities
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

    @isTest
    static void testBatchExecution() {
        // Start the test
        System.Test.startTest();
        // Execute the batch class
        SumAmount batch = new SumAmount();
        Database.executeBatch(batch);
        System.Test.stopTest();
        
        // Verify that the batch processed the records correctly
        // Use System.debug or Assertions to validate the results
        List<EmailMessage> sentEmails = [SELECT Id, Subject, HtmlBody FROM EmailMessage];

        System.assertEquals(2, sentEmails.size(), 'Two emails should have been sent.');
        
        // Check the content of the emails
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