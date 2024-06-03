 /*
*********************************************************
Apex Class Name    : ContactTriggerHandler
Created Date       : May 14, 2024
@description       : This class handles the logic for updating the primary contact 
                    information for an Account in Salesforce.
@author            : Lucas Silva de Oliveira
Modification Log:
Ver   Date         Author         Modification
1.0   05-14-2024   Lucas Silva    Initial Version
*********************************************************
*/
public class ContactTriggerHandler {

    /*
    *********************************************************
    @Method Name    : UpdatePrimaryContact
    @description    : This method verifies if the Account already has a primary contact 
                      and updates all contacts with the new primary contact information.
    @param          : Contact newRecord - The contact record being processed.
    @return         : void
    *********************************************************
    */
    public static void UpdatePrimaryContact(Contact newRecord){

       
        Contact[] hasPrimary = [SELECT Id FROM Contact WHERE AccountId = :newRecord.AccountId AND Is_Primary_Contact__c = True];
     
        if(!hasPrimary.isEmpty() && newRecord.Is_Primary_Contact__c && newRecord.Id != hasPrimary[0].Id){
            newRecord.addError('There is primary contact that already exist.');
        }

        if(newRecord.Is_Primary_Contact__c){
            UpdateAsyncContact(newRecord.AccountId, newRecord.Primary_Contact_Phone__c);
        }
    }

    /*
    *********************************************************
    @Method Name    : UpdateAsyncContact
    @description    : Asynchronous method to update non-primary contacts with the new 
                      primary contact information.
    @param          : String accId - The Account ID related to the contacts.
                      String PrimaryPhone - The primary contact phone number to update.
    @return         : void
    *********************************************************
    */
    @future
    public static void UpdateAsyncContact(String accId, String PrimaryPhone){
        Contact[] cttNotPrimary = [SELECT Id, Primary_Contact_Phone__c FROM Contact WHERE AccountId = :accId AND Is_Primary_Contact__c = False];        
        Contact[] cttToUp = new List<Contact>();
        
        for(Contact ctt : cttNotPrimary){
            ctt.Primary_Contact_Phone__c = PrimaryPhone;
            cttToUp.add(ctt);
        }
        Database.update(cttToUp, false);
    }
}