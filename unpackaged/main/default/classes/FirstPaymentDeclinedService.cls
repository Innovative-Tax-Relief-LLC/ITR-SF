public class FirstPaymentDeclinedService {
    
    public static void markFirstDeclinedTransactions(
        List<bt_stripe__Transaction__c> newTransactions,
        Map<Id, bt_stripe__Transaction__c> oldTransactionsMap
    ) {

        List<Id> transactionIdsToUpdate = new List<Id>();
        Map<Id, bt_stripe__Transaction__c> newlyFailedTransactions = new Map<Id, bt_stripe__Transaction__c>();
        Set<Id> paymentScheduleIds = new Set<Id>();
        
        for (bt_stripe__Transaction__c trans : newTransactions) {
            bt_stripe__Transaction__c oldTrans = oldTransactionsMap.get(trans.Id);
            
            if (trans.bt_stripe__Transaction_Status__c == 'Failed' &&
                oldTrans.bt_stripe__Transaction_Status__c != 'Failed' &&
                trans.bt_stripe__Payment_Schedule__c != null &&
                trans.Opportunity_Record_Type__c == 'Second Trade') {
                
                newlyFailedTransactions.put(trans.Id, trans);
                paymentScheduleIds.add(trans.bt_stripe__Payment_Schedule__c);
            }
        }
                
        if (newlyFailedTransactions.isEmpty()) {
            return;
        }
        
        Set<Id> schedulesWithPreviousFailures = getSchedulesWithFailedTransactions(
            paymentScheduleIds,
            newlyFailedTransactions.keySet()
        );
        
        Map<Id, Id> firstTransactionBySchedule = getFirstTransactionIdsBySchedule(
            paymentScheduleIds, 
            newlyFailedTransactions.keySet()
        );
        
        for (bt_stripe__Transaction__c trans : newlyFailedTransactions.values()) {
           
            if (!schedulesWithPreviousFailures.contains(trans.bt_stripe__Payment_Schedule__c) &&
                firstTransactionBySchedule.get(trans.bt_stripe__Payment_Schedule__c) == trans.Id) {
                
                transactionIdsToUpdate.add(trans.Id);
            }
        }
                
        if (!transactionIdsToUpdate.isEmpty()) {
            updateTransactionsAsync(transactionIdsToUpdate);
        }
    }
    
    private static Set<Id> getSchedulesWithFailedTransactions(
        Set<Id> paymentScheduleIds,
        Set<Id> currentTransactionIds
    ) {
        Set<Id> schedulesWithFailures = new Set<Id>();
        
        List<bt_stripe__Transaction__c> failedTrans = [
            SELECT bt_stripe__Payment_Schedule__c
            FROM bt_stripe__Transaction__c
            WHERE bt_stripe__Payment_Schedule__c IN :paymentScheduleIds
            AND bt_stripe__Transaction_Status__c = 'Failed'
            AND Id NOT IN :currentTransactionIds
        ];
                
        for (bt_stripe__Transaction__c trans : failedTrans) {
            schedulesWithFailures.add(trans.bt_stripe__Payment_Schedule__c);
        }
        
        return schedulesWithFailures;
    }
    
    private static Map<Id, Id> getFirstTransactionIdsBySchedule(
        Set<Id> paymentScheduleIds,
        Set<Id> currentTransactionIds
    ) {
        Map<Id, Id> firstTransactionMap = new Map<Id, Id>();
        
        List<bt_stripe__Transaction__c> trans = [
            SELECT Id, bt_stripe__Payment_Schedule__c, bt_stripe__Due_Date__c
            FROM bt_stripe__Transaction__c
            WHERE bt_stripe__Payment_Schedule__c IN :paymentScheduleIds
            AND Id IN :currentTransactionIds
            ORDER BY bt_stripe__Payment_Schedule__c, bt_stripe__Due_Date__c ASC
        ];
        
        
        for (bt_stripe__Transaction__c t : trans) {
            if (!firstTransactionMap.containsKey(t.bt_stripe__Payment_Schedule__c)) {
                firstTransactionMap.put(t.bt_stripe__Payment_Schedule__c, t.Id);
            }
        }
        
        return firstTransactionMap;
    }
    
    @future
    private static void updateTransactionsAsync(List<Id> transactionIds) {
        
        List<bt_stripe__Transaction__c> transactionsToUpdate = new List<bt_stripe__Transaction__c>();
        
        for (Id transId : transactionIds) {
            transactionsToUpdate.add(new bt_stripe__Transaction__c(
                Id = transId,
                First_Payment_Declined__c = true
            ));
        }
        
        Database.SaveResult[] results = Database.update(transactionsToUpdate, false);
        
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                System.debug('✓ Updated: ' + transactionIds[i]);
            } else {
                System.debug('✗ Error: ' + transactionIds[i] + ' - ' + results[i].getErrors()[0].getMessage());
            }
        }
    }
}