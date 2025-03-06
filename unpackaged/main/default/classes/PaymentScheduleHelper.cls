public class PaymentScheduleHelper {
    public static void processTransactions(List<bt_stripe__Transaction__c> transactions) {
        Set<Id> paymentScheduleIds = new Set<Id>();
        Map<Id, bt_stripe__Transaction__c> transactionMap = new Map<Id, bt_stripe__Transaction__c>();
        
        for (bt_stripe__Transaction__c txn : transactions) {
            paymentScheduleIds.add(txn.bt_stripe__Payment_Schedule__c);
            transactionMap.put(txn.bt_stripe__Payment_Schedule__c, txn);
        }
        
        List<bt_stripe__Payment_Schedule__c> schedulesToUpdate = [
            SELECT Id, Last_Payment_Date__c, Last_Payment_Amount__c 
            FROM bt_stripe__Payment_Schedule__c
            WHERE Id IN :paymentScheduleIds
        ];
        
        for (bt_stripe__Payment_Schedule__c schedule : schedulesToUpdate) {
            bt_stripe__Transaction__c txn = transactionMap.get(schedule.Id);
            schedule.Last_Payment_Date__c = txn.LastModifiedDate.date(); 
            schedule.Last_Payment_Amount__c = txn.bt_stripe__Amount__c;
        }
        
        update schedulesToUpdate;
    }
}