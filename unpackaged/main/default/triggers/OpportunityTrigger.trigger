trigger OpportunityTrigger on Opportunity (before update, after insert, after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
        // Start of El Funileiro Code
        OpportunityTriggerHandler.handleFieldChangesOpportunities(Trigger.oldMap, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate);
        // End of El Funileiro Code
    }
    
    if (Trigger.isAfter && Trigger.isInsert) {
        // Start of El Funileiro Code
        OpportunityTriggerHandler.handleFieldChangesOpportunities(Trigger.oldMap, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate);
        // End of El Funileiro Code
    }
}