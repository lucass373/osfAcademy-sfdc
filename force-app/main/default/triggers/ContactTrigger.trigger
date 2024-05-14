trigger ContactTrigger on Contact (before insert, before update) {
    //calls the updatePrimaryContact method in the ContactTriggerHandler.
    ContactTriggerHandler.UpdatePrimaryContact(Trigger.new[0]);
}