trigger CaseUpdateLastInteractionTaskTrigger on Task (after insert, after Update) {
    Set<Id> relatedCaseIds = new Set<Id>();

    for (Task taskID : Trigger.new) {
        if (taskID.WhatId != null && String.valueOf(taskID.WhatId).startsWith('500')) { 
            relatedCaseIds.add(taskID.WhatId);
        }
    }
    LastInteractionHelper.updateLastInteractionField(relatedCaseIds);
}