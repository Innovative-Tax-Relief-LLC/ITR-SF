global with sharing class RestarCallRecaptureAttamptsSchedule implements Schedulable {
    global void execute(SchedulableContext context) {

        List<Opportunity> opportunitiesToUpdate = [ 
            SELECT Id, CallRecaptureAttempts__c 
            FROM Opportunity 
            WHERE CallRecaptureAttempts__c != NULL
            LIMIT 1000
        ];

        for (Opportunity opp : opportunitiesToUpdate) {
            opp.CallRecaptureAttempts__c = 0;
        }

        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }
}