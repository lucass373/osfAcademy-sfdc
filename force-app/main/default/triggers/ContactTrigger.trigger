/*
*********************************************************
Trigger Name      : ContactTrigger
Created Date      : May 14, 2024
@description      : This trigger calls the updatePrimaryContact method 
                    in the ContactTriggerHandler class when a Contact 
                    record is inserted or updated.
@author           : Lucas Silva de Oliveira
Modification Log:
Ver   Date         Author         Modification
1.0   05-14-2024   Lucas Silva    Initial Version
*********************************************************
*/
trigger ContactTrigger on Contact (before insert, before update) {
    ContactTriggerHandler.UpdatePrimaryContact(Trigger.new[0]);
}
