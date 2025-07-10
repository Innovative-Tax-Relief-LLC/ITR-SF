public class TransactionScheduledAmountBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Scheduled_Transactions_Amount__c,
                   (SELECT Id, bt_stripe__Amount__c 
                    FROM bt_stripe__Transactions__r 
                    WHERE bt_stripe__Transaction_Status__c = 'Open')
            FROM bt_stripe__Payment_Schedule__c 
            WHERE Id IN (
                SELECT bt_stripe__Payment_Schedule__c 
                FROM bt_stripe__Transaction__c 
                WHERE bt_stripe__Transaction_Status__c = 'Open'
                AND bt_stripe__Payment_Schedule__c != null
            )
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<bt_stripe__Payment_Schedule__c> scope) {
        List<bt_stripe__Payment_Schedule__c> psToUpdate = new List<bt_stripe__Payment_Schedule__c>();
        
        for(bt_stripe__Payment_Schedule__c ps : scope) {
            Decimal totalAmount = 0;
            
            for(bt_stripe__Transaction__c trans : ps.bt_stripe__Transactions__r) {
                totalAmount += trans.bt_stripe__Amount__c ?? 0;
            }
            
            ps.Scheduled_Transactions_Amount__c = totalAmount;
            psToUpdate.add(ps);
        }
        
        update psToUpdate;
    }
    
    public void finish(Database.BatchableContext BC) {}
}