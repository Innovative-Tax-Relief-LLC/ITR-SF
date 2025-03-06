global class UpdatePaymentScheduleBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id FROM bt_stripe__Payment_Schedule__c');
    }
    
    public void execute(Database.BatchableContext BC, List<bt_stripe__Payment_Schedule__c> schedules) {
        Set<Id> scheduleIds = new Set<Id>();
        for(bt_stripe__Payment_Schedule__c schedule : schedules) {
            scheduleIds.add(schedule.Id);
        }
        
        List<bt_stripe__Transaction__c> transactions = [
            SELECT Id, bt_stripe__Payment_Schedule__c, bt_stripe__Processed_Date__c, bt_stripe__Amount__c 
            FROM bt_stripe__Transaction__c 
            WHERE bt_stripe__Payment_Schedule__c IN :scheduleIds 
            AND bt_stripe__Transaction_Status__c = 'Completed'
            ORDER BY bt_stripe__Payment_Schedule__c, bt_stripe__Processed_Date__c DESC
        ];
        
        Map<Id, bt_stripe__Transaction__c> latestTransactions = new Map<Id, bt_stripe__Transaction__c>();
        for (bt_stripe__Transaction__c trans : transactions) {
            Id scheduleId = trans.bt_stripe__Payment_Schedule__c;
            if (!latestTransactions.containsKey(scheduleId)) {
                latestTransactions.put(scheduleId, trans);
            }
        }
        
        List<bt_stripe__Payment_Schedule__c> schedulesToUpdate = new List<bt_stripe__Payment_Schedule__c>();
        for (bt_stripe__Payment_Schedule__c schedule : schedules) {
            if (latestTransactions.containsKey(schedule.Id)) {
                bt_stripe__Transaction__c latestTransaction = latestTransactions.get(schedule.Id);
                if (latestTransaction.bt_stripe__Processed_Date__c != null) {
                    schedule.Last_Payment_Date__c = latestTransaction.bt_stripe__Processed_Date__c.date();
                }
                schedule.Last_Payment_Amount__c = latestTransaction.bt_stripe__Amount__c;
                schedulesToUpdate.add(schedule);
            }
        }
        
        if (!schedulesToUpdate.isEmpty()) {
            update schedulesToUpdate;
            System.debug('Schedules actualizados: ' + schedulesToUpdate);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch process completed.');
    }
}