public class FirstPaymentDeclinedBackfillBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, bt_stripe__Payment_Schedule__c, ' +
                      'bt_stripe__Transaction_Status__c, bt_stripe__Due_Date__c, ' +
                      'First_Payment_Declined__c, Opportunity_Record_Type__c ' +
                      'FROM bt_stripe__Transaction__c ' +
                      'WHERE bt_stripe__Transaction_Status__c = \'Failed\' ' +
                      'AND Opportunity_Record_Type__c = \'Second Trade\' ' +
                      'AND bt_stripe__Payment_Schedule__c != null ' +
                      'ORDER BY bt_stripe__Payment_Schedule__c, bt_stripe__Due_Date__c';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<bt_stripe__Transaction__c> scope) {
        List<bt_stripe__Transaction__c> transactionsToUpdate = new List<bt_stripe__Transaction__c>();
        Map<Id, Id> firstTransactionBySchedule = new Map<Id, Id>();
        
        for (bt_stripe__Transaction__c trans : scope) {
            if (!firstTransactionBySchedule.containsKey(trans.bt_stripe__Payment_Schedule__c)) {
                firstTransactionBySchedule.put(trans.bt_stripe__Payment_Schedule__c, trans.Id);
            }
        }
        
        for (bt_stripe__Transaction__c trans : scope) {
            if (firstTransactionBySchedule.get(trans.bt_stripe__Payment_Schedule__c) == trans.Id &&
                !trans.First_Payment_Declined__c) {
                
                transactionsToUpdate.add(new bt_stripe__Transaction__c(
                    Id = trans.Id,
                    First_Payment_Declined__c = true
                ));
            }
        }
        
        if (!transactionsToUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(transactionsToUpdate, false);
            
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    System.debug('Error updating transaction ' + transactionsToUpdate[i].Id + ': ' + 
                               results[i].getErrors()[0].getMessage());
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                   TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob 
            WHERE Id = :bc.getJobId()
        ];
        
        System.debug('=== Batch Completed ===');
        System.debug('Status: ' + job.Status);
        System.debug('Items Processed: ' + job.JobItemsProcessed);
        System.debug('Errors: ' + job.NumberOfErrors);
    }
}