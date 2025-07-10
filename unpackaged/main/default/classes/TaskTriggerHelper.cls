public with sharing class TaskTriggerHelper {
    public static void TaskCallCounter(List<Id> oppIdList) {
        if (oppIdList.isEmpty()) {
            return; 
        }
        
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        List<Opportunity> opportunities = [
            SELECT Id, CallRecaptureAttempts__c 
            FROM Opportunity 
            WHERE Id IN :oppIdList
        ];

        for (Opportunity opp : opportunities) {
            if (opp.CallRecaptureAttempts__c == null) {
                opp.CallRecaptureAttempts__c = 1; 
            } else {
                opp.CallRecaptureAttempts__c += 1; 
            }
            opportunitiesToUpdate.add(opp); 
        }

        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate; 
        }
    }
}