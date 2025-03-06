trigger LeadTriggerDNC on Lead (after insert, after update) {  
    
    // switch on Trigger.operationType {
    //     when AFTER_INSERT {
    //         new LeadTriggerHandler(Trigger.new).handleAfterInsert();
    //     }
    //     when AFTER_UPDATE {
    //         for (Lead lead : Trigger.new) {
    //             Lead oldLead = Trigger.oldMap.get(lead.Id);
                
    //             // Check if the DoNotCall field has changed
    //             if (lead.DoNotCall != oldLead.DoNotCall) {
    //                 StatusChangeHandler.sendDoNotCallChangeAsync(lead.Lead_Id__c, lead.Velocify_Id__c, lead.DoNotCall, lead.Phone, lead.MobilePhone);
    //             }
    //         }
    //     }
    // }
}