trigger AccountTrigger on Account (after insert, after update) {

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            AccountTriggerHandler.handleFieldChangesPersonAccount(Trigger.oldMap, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate);
        }

        if(Trigger.isUpdate) {
            AccountTriggerHandler.handleFieldChangesPersonAccount(Trigger.oldMap, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate);
        }
    }
}