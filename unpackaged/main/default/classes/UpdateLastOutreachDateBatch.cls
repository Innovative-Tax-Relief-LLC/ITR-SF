public class UpdateLastOutreachDateBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, CreatedDate, LastOutreachDate__c FROM Case');
    }

    public void execute(Database.BatchableContext BC, List<Case> caseRecords) {
        Map<Id, Date> caseDateMap = updateMostRecentDate(caseRecords);
        List<Case> casesToUpdate = new List<Case>();

        for (Case c : caseRecords) {
            Date lastOutreach = caseDateMap.get(c.Id);
            if (lastOutreach != null && (c.LastOutreachDate__c == null || lastOutreach >= c.LastOutreachDate__c)) {
                c.LastOutreachDate__c = lastOutreach;
                casesToUpdate.add(c);
            }
        }
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

    private Map<Id, Date> updateMostRecentDate(List<Case> cases) {
        Set<Id> caseIds = new Set<Id>();
        Map<Id, Date> caseDateMap = new Map<Id, Date>();

        for (Case c : cases) {
            caseIds.add(c.Id);
            caseDateMap.put(c.Id, c.LastOutreachDate__c != null ? c.LastOutreachDate__c : c.CreatedDate.date());
        }

        // Query all related records in one go
        List<Task> tasks = [SELECT ActivityDate, WhatId FROM Task WHERE WhatId IN :caseIds ORDER BY ActivityDate DESC];
        List<Event> events = [SELECT ActivityDate, WhatId FROM Event WHERE WhatId IN :caseIds ORDER BY ActivityDate DESC];
        List<FeedItem> feedItems = [SELECT CreatedDate, ParentId FROM FeedItem WHERE ParentId IN :caseIds ORDER BY CreatedDate DESC];

        for (Task t : tasks) {
            if (t.ActivityDate != null && (!caseDateMap.containsKey(t.WhatId) || t.ActivityDate >= caseDateMap.get(t.WhatId))) {
                caseDateMap.put(t.WhatId, t.ActivityDate);
            }
        }

        for (Event e : events) {
            if (e.ActivityDate != null && (!caseDateMap.containsKey(e.WhatId) || e.ActivityDate >= caseDateMap.get(e.WhatId))) {
                caseDateMap.put(e.WhatId, e.ActivityDate);
            }
        }

        for (FeedItem f : feedItems) {
            Date feedDate = f.CreatedDate.date();
            if (!caseDateMap.containsKey(f.ParentId) || feedDate >= caseDateMap.get(f.ParentId)) {
                caseDateMap.put(f.ParentId, feedDate);
            }
        }
        
        return caseDateMap;
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch process completed.');
    }
}