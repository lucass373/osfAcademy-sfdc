public class ContactTriggerHandler {

    // This method verifies if the Account already has a primary contact and updates all contacts with the new primary contact.
    public static void UpdatePrimaryContact(Contact newRecord){

       // Query to retrieve the primary contact for the Account.
        Contact[] hasPrimary = [SELECT Id FROM Contact WHERE AccountId = :newRecord.AccountId AND Is_Primary_Contact__c = True];
     
        // If there is already a primary contact for the Account and the new contact is marked as primary and is not the same as the existing primary contact, it throws an error.
        if(!hasPrimary.isEmpty() && newRecord.Is_Primary_Contact__c && newRecord.Id != hasPrimary[0].Id){
            newRecord.addError('There is primary contact that already exist.');
        }

        // If the new contact is marked as primary, it triggers the asynchronous update of other contacts.
        if(newRecord.Is_Primary_Contact__c){
            UpdateAsyncContact(newRecord.AccountId, newRecord.Primary_Contact_Phone__c);
        }
    }

    // Asynchronous method to update non-primary contacts with the new primary contact information.
    @future
    public static void UpdateAsyncContact(String accId, String PrimaryPhone){

        // Query to fetch non-primary contacts related to the account.
        Contact[] cttNotPrimary = [SELECT Id, Primary_Contact_Phone__c FROM Contact WHERE AccountId = :accId AND Is_Primary_Contact__c = False];
        
        Contact[] cttToUp = new List<Contact>();

        // Iterating through non-primary contacts to update their primary contact phone.
        for(Contact ctt : cttNotPrimary){
            ctt.Primary_Contact_Phone__c = PrimaryPhone;
            cttToUp.add(ctt);
        }
        // Performing bulk update of non-primary contacts.
        Database.update(cttToUp, false);
    }
}