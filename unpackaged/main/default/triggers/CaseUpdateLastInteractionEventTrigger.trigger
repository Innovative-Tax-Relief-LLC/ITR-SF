trigger CaseUpdateLastInteractionEventTrigger on Event (after insert, after Update) {
    Set<Id> relatedCaseIds = new Set<Id>();
    Id currentUserId = UserInfo.getUserId();

    for (Event EventID : Trigger.new) {
        if (EventID.WhatId != null && String.valueOf(EventID.WhatId).startsWith('500')) { 
            relatedCaseIds.add(EventID.WhatId);
        }
    }
    
    if (!relatedCaseIds.isEmpty()) {
        Set<Id> ownerCaseIds = new Set<Id>();
        for (Case c : [SELECT Id FROM Case WHERE Id IN :relatedCaseIds AND OwnerId = :currentUserId]) {
            ownerCaseIds.add(c.Id);
        }
        
        if (!ownerCaseIds.isEmpty()) {
            LastInteractionHelper.updateLastInteractionField(ownerCaseIds);
        }
    }
}