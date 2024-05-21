@isTest
public class SumAmountTest {
    
    @isTest
    static void testSumAmountBatch() {
        // Setup test data
        Account testAccount1 = new Account(Name = 'Test Account 1');
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{testAccount1, testAccount2};
         
        //insert the contacts
        Contact primaryContact = new Contact(
            FirstName = 'Primary',
            LastName = 'Contact',
            AccountId = testAccount1.Id,
            Is_Primary_Contact__c = true,
            Primary_Contact_Phone__c = '1234567890'
        );
        insert primaryContact;
        
        Contact nonPrimaryContact = new Contact(
            FirstName = 'non-Primary',
            LastName = 'Contact',
            AccountId = testAccount2.Id,
            Is_Primary_Contact__c = false,
            Primary_Contact_Phone__c = '1234567890'
        );
        insert nonPrimaryContact;

        
        // Insert opportunities
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            AccountId = testAccount1.Id,
            StageName = 'Closed Won',
            Amount = 1000,
            CloseDate = Date.today()
        );
        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity 2',
            AccountId = testAccount1.Id,
            StageName = 'Open',
            Amount = 2000,
            CloseDate = Date.today()
        );
        Opportunity opp3 = new Opportunity(
            Name = 'Opportunity 3',
            AccountId = testAccount1.Id,
            StageName = 'Closed Lost',
            Amount = 500,
            CloseDate = Date.today()
        );
        Opportunity opp4 = new Opportunity(
            Name = 'Opportunity 4',
            AccountId = testAccount2.Id,
            StageName = 'Closed Won',
            Amount = 3000,
            CloseDate = Date.today()
        );
        insert new List<Opportunity>{opp1, opp2, opp3, opp4};
        
        // Execute batch
        System.Test.startTest();
        SumAmount batch = new SumAmount();
        Database.executeBatch(batch);
        System.Test.stopTest();
        
        // Verify the results
        // Check the batch summary map
        Map<Id, Map<String, Decimal>> expectedAccountSummaryMap = new Map<Id, Map<String, Decimal>>{
            testAccount1.Id => new Map<String, Decimal>{
                'Closed Won' => 1000,
                'Open' => 2000,
                'Closed Lost' => 500
            },
            testAccount2.Id => new Map<String, Decimal>{
                'Closed Won' => 3000,
                'Open' => 0,
                'Closed Lost' => 0
            }
        };
        
        System.assertEquals(expectedAccountSummaryMap, batch.accountSummaryMap, 'Account summaries should match expected values.');
    }
}