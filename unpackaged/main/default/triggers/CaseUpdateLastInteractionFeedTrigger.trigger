trigger CaseUpdateLastInteractionFeedTrigger on FeedItem (after insert, after Update) {
   Set<Id> caseIds = new Set<Id>();
    for (FeedItem post : Trigger.new) {
        if (post.ParentId != null && String.valueOf(post.ParentId).startsWith('500')) {
            caseIds.add(post.ParentId);
        }
    }

    if (caseIds.isEmpty()) {
        return;
    }

    Map<Id, Case> casesMap = new Map<Id, Case>([
        SELECT Id, OwnerId
        FROM Case
        WHERE Id IN :caseIds
    ]);

    List<Case> casesToUpdate = new List<Case>();
    for (FeedItem post : Trigger.new) {
        if (casesMap.containsKey(post.ParentId)) {
            Case parentCase = casesMap.get(post.ParentId);
            
            if (post.CreatedById == parentCase.OwnerId) {
                casesToUpdate.add(new Case(
                    Id = parentCase.Id,
                    LastOutreachDate__c = Date.today()
                ));
            }
        }
    }

    if (!casesToUpdate.isEmpty()) {
        update casesToUpdate;
    }
}