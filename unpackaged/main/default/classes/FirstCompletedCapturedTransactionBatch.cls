public class FirstCompletedCapturedTransactionBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM bt_stripe__Payment_Schedule__c WHERE Id IN ' +
                        '(SELECT bt_stripe__Payment_Schedule__c FROM bt_stripe__Transaction__c ' +
                        'WHERE bt_stripe__Payment_Schedule__c != null ' +
                        'AND bt_stripe__Transaction_Status__c = \'Completed\' ' +
                        'AND bt_stripe__Payment_Status__c = \'Captured\' ' +
                        'AND bt_stripe__Due_Date__c != null)';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<bt_stripe__Payment_Schedule__c> paymentSchedules) {
        List<bt_stripe__Transaction__c> transactionsToUpdate = new List<bt_stripe__Transaction__c>();
        Map<Id, Opportunity> opportunitiesToUpdateMap = new Map<Id, Opportunity>();
        
        Set<Id> paymentScheduleIds = new Set<Id>();
        for (bt_stripe__Payment_Schedule__c ps : paymentSchedules) {
            paymentScheduleIds.add(ps.Id);
        }
        
        Map<Id, List<bt_stripe__Transaction__c>> transactionsByPaymentSchedule = new Map<Id, List<bt_stripe__Transaction__c>>();
        
        List<bt_stripe__Transaction__c> allTransactions = [
            SELECT Id, bt_stripe__Payment_Schedule__c, bt_stripe__Transaction_Status__c, 
                    bt_stripe__Payment_Status__c, bt_stripe__Due_Date__c, bt_stripe__Amount__c,
                    First_Completed_Captured_Transaction__c, bt_stripe__Opportunity2__c, 
                    CreatedDate
            FROM bt_stripe__Transaction__c 
            WHERE bt_stripe__Payment_Schedule__c IN :paymentScheduleIds
            AND bt_stripe__Transaction_Status__c = 'Completed'
            AND bt_stripe__Payment_Status__c = 'Captured'
            AND bt_stripe__Due_Date__c != null
            ORDER BY bt_stripe__Payment_Schedule__c, bt_stripe__Due_Date__c ASC
        ];
        
        for (bt_stripe__Transaction__c trans : allTransactions) {
            if (!transactionsByPaymentSchedule.containsKey(trans.bt_stripe__Payment_Schedule__c)) {
                transactionsByPaymentSchedule.put(trans.bt_stripe__Payment_Schedule__c, new List<bt_stripe__Transaction__c>());
            }
            transactionsByPaymentSchedule.get(trans.bt_stripe__Payment_Schedule__c).add(trans);
        }
        
        for (Id paymentScheduleId : transactionsByPaymentSchedule.keySet()) {
            List<bt_stripe__Transaction__c> transactions = transactionsByPaymentSchedule.get(paymentScheduleId);
            
            if (!transactions.isEmpty()) {
                transactions.sort(new TransactionDateComparator());
                
                for (bt_stripe__Transaction__c trans : transactions) {
                    if (trans.First_Completed_Captured_Transaction__c == true) {
                        trans.First_Completed_Captured_Transaction__c = false;
                        transactionsToUpdate.add(trans);
                    }
                }
                
                if (transactions[0].First_Completed_Captured_Transaction__c == false) {
                    transactions[0].First_Completed_Captured_Transaction__c = true;
                    Boolean alreadyAdded = false;
                    for (bt_stripe__Transaction__c transToUpdate : transactionsToUpdate) {
                        if (transToUpdate.Id == transactions[0].Id) {
                            transToUpdate.First_Completed_Captured_Transaction__c = true;
                            alreadyAdded = true;
                            break;
                        }
                    }
                    if (!alreadyAdded) {
                        transactionsToUpdate.add(transactions[0]);
                    }
                    
                    // Update the related Opportunity's First_Pay_Date__c
                    if (transactions[0].bt_stripe__Opportunity2__c != null) {
                        opportunitiesToUpdateMap.put(transactions[0].bt_stripe__Opportunity2__c, new Opportunity(
                            Id = transactions[0].bt_stripe__Opportunity2__c,
                            First_Pay_Date__c = transactions[0].CreatedDate
                        ));
                        
                        System.debug('Adding Opportunity to update: ' + transactions[0].bt_stripe__Opportunity2__c + 
                                    ', First_Pay_Date__c: ' + transactions[0].CreatedDate);
                    }
                }
            }
        }
        
        // Update Transactions
        if (!transactionsToUpdate.isEmpty()) {
            try {
                update transactionsToUpdate;
                System.debug('Successfully updated ' + transactionsToUpdate.size() + ' transactions');
                
                for (bt_stripe__Transaction__c trans : transactionsToUpdate) {
                    System.debug('Updated Transaction: ' + trans.Id + 
                                ', Payment Schedule: ' + trans.bt_stripe__Payment_Schedule__c + 
                                ', First_Completed_Captured: ' + trans.First_Completed_Captured_Transaction__c);
                }
            } catch (Exception e) {
                System.debug('Error updating transactions: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
            }
        } else {
            System.debug('No transactions needed to be updated');
        }
        
        // Update Opportunities
        if (!opportunitiesToUpdateMap.isEmpty()) {
            List<Opportunity> opportunitiesToUpdate = opportunitiesToUpdateMap.values();
            System.debug('=== ABOUT TO UPDATE OPPORTUNITIES ===');
            System.debug('Number of opportunities to update: ' + opportunitiesToUpdate.size());
            
            for (Opportunity opp : opportunitiesToUpdate) {
                System.debug('Before Update - Opportunity: ' + opp.Id + ', First_Pay_Date__c: ' + opp.First_Pay_Date__c);
            }
            
            try {
                Database.SaveResult[] saveResults = Database.update(opportunitiesToUpdate, false);
                Integer successCount = 0;
                Integer errorCount = 0;
                
                for(Integer i = 0; i < saveResults.size(); i++) {
                    if(saveResults[i].isSuccess()) {
                        successCount++;
                    } else {
                        errorCount++;
                        System.debug('Error updating Opportunity ' + opportunitiesToUpdate[i].Id + ': ' + saveResults[i].getErrors());
                    }
                }
                
                System.debug('Successfully updated ' + successCount + ' opportunities, ' + errorCount + ' errors');
                
                // Query back to verify the update actually worked
                List<Opportunity> verifyOpps = [
                    SELECT Id, First_Pay_Date__c 
                    FROM Opportunity 
                    WHERE Id IN :opportunitiesToUpdateMap.keySet()
                ];
                
                System.debug('=== VERIFICATION AFTER UPDATE ===');
                for (Opportunity opp : verifyOpps) {
                    System.debug('After Update - Opportunity: ' + opp.Id + ', First_Pay_Date__c: ' + opp.First_Pay_Date__c);
                }
                
            } catch (Exception e) {
                System.debug('Error updating opportunities: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
            }
        } else {
            System.debug('No opportunities needed to be updated');
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('FirstCompletedCapturedTransactionBatch process completed.');
    }
    
    public class TransactionDateComparator implements Comparator<bt_stripe__Transaction__c> {
        public Integer compare(bt_stripe__Transaction__c t1, bt_stripe__Transaction__c t2) {
            if (t1.bt_stripe__Due_Date__c == null && t2.bt_stripe__Due_Date__c == null) {
                return 0;
            }
            if (t1.bt_stripe__Due_Date__c == null) {
                return 1;
            }
            if (t2.bt_stripe__Due_Date__c == null) {
                return -1;
            }
            
            if (t1.bt_stripe__Due_Date__c < t2.bt_stripe__Due_Date__c) {
                return -1;
            } else if (t1.bt_stripe__Due_Date__c > t2.bt_stripe__Due_Date__c) {
                return 1;
            } else {
                return 0;
            }
        }
    }
}