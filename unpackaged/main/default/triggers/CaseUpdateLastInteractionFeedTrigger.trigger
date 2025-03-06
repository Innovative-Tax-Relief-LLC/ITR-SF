trigger CaseUpdateLastInteractionFeedTrigger on FeedItem (after insert, after Update) {
    Set<Id> relatedCaseIds = new Set<Id>();

    for (FeedItem feedI : Trigger.new) {
        if (feedI.ParentId != null && String.valueOf(feedI.ParentId).startsWith('500')) { 
            relatedCaseIds.add(feedI.ParentId);
        }
    }
    LastInteractionHelper.updateLastInteractionField(relatedCaseIds);
}