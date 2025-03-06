trigger CaseUpdateLastInteractionEventTrigger on Event (after insert, after Update) {
    Set<Id> relatedCaseIds = new Set<Id>();

    for (Event EventID : Trigger.new) {
        if (EventID.WhatId != null && String.valueOf(EventID.WhatId).startsWith('500')) { 
            relatedCaseIds.add(EventID.WhatId);
        }
    }
    LastInteractionHelper.updateLastInteractionField(relatedCaseIds);
}