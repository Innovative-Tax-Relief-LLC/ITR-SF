trigger OpportunityTrigger on Opportunity (before update, after insert, after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    
    if (Trigger.isAfter && Trigger.isInsert) {
        //
    }
}