public inherited sharing class TaskTriggerHandler extends TriggerHandler {
    public List<Task> newTasksList;
    public Map<Id, Task> oldTasksMap;
    
    public TaskTriggerHandler() {
        this.newTasksList = (List<Task>) Trigger.new;
        this.oldTasksMap = (Map<Id, Task>) Trigger.oldMap;
    }

    public override void afterInsert() {
        Set<Id> relatedCaseIds = new Set<Id>();
        Set<Id> relatedOppIds = new Set<Id>();
        Id currentUserId = UserInfo.getUserId();

        for (Task taskID : newTasksList) {
            if (taskID.WhatId != null && String.valueOf(taskID.WhatId).startsWith('500')) { 
                relatedCaseIds.add(taskID.WhatId);
            }
            if (taskID.WhatId != null && String.valueOf(taskID.WhatId).startsWith('006') && 
            (taskID.TaskSubtype == 'Call')) { 
                relatedOppIds.add(taskID.WhatId);
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
        
        if (!relatedOppIds.isEmpty()) {
            filterOpportunitiesWithUncapturedTransactions(new List<Id>(relatedOppIds));
        }
    }
    

    public override void afterUpdate() {
        Set<Id> relatedCaseIds = new Set<Id>();
        Id currentUserId = UserInfo.getUserId();

        for (Task taskID : newTasksList) {
            if (taskID.WhatId != null && String.valueOf(taskID.WhatId).startsWith('500')) { 
                relatedCaseIds.add(taskID.WhatId);
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

    private static void filterOpportunitiesWithUncapturedTransactions(List<Id> oppIdList) {
        if (oppIdList.isEmpty()) {
            return;
        }
    
        List<Id> filteredOpportunityIds = new List<Id>();
    
        List<bt_stripe__Transaction__c> transactions = [
            SELECT Id, bt_stripe__Payment_Status__c, LastModifiedDate, bt_stripe__Opportunity2__r.Id  
            FROM bt_stripe__Transaction__c 
            WHERE bt_stripe__Payment_Status__c = 'Uncaptured' 
            AND bt_stripe__Due_Date__c = TODAY
            AND bt_stripe__Opportunity2__r.Id IN :oppIdList
        ];
    
        for (bt_stripe__Transaction__c txn : transactions) {
            if (txn.bt_stripe__Opportunity2__r.Id != null) {
                filteredOpportunityIds.add(txn.bt_stripe__Opportunity2__r.Id);
            }
        }
        
        if (!filteredOpportunityIds.isEmpty()) {
            TaskTriggerHelper.TaskCallCounter(filteredOpportunityIds);
        }
    }
}