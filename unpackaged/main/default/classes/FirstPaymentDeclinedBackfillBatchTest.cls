@isTest
private class FirstPaymentDeclinedBackfillBatchTest {
    
    @TestSetup
    static void setup() {
        RecordType secondTradeRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Second Trade' LIMIT 1];
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            opportunities.add(new Opportunity(
                Name = 'Second Trade Opp ' + i,
                AccountId = testAccount.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                RecordTypeId = secondTradeRT.Id
            ));
        }
        insert opportunities;
        
        List<bt_stripe__Payment_Schedule__c> paymentSchedules = new List<bt_stripe__Payment_Schedule__c>();
        for (Opportunity opp : opportunities) {
            paymentSchedules.add(new bt_stripe__Payment_Schedule__c(
                Opportunity__c = opp.Id
            ));
        }
        insert paymentSchedules;
        
        List<bt_stripe__Transaction__c> transactions = new List<bt_stripe__Transaction__c>();
        
        for (Integer i = 0; i < 2; i++) {
            transactions.add(new bt_stripe__Transaction__c(
                bt_stripe__Payment_Schedule__c = paymentSchedules[0].Id,
                bt_stripe__Opportunity2__c = opportunities[0].Id,
                bt_stripe__Transaction_Status__c = 'Failed',
                bt_stripe__Due_Date__c = Date.today().addDays(i),
                bt_stripe__Amount__c = 1000,
                First_Payment_Declined__c = false
            ));
        }
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[1].Id,
            bt_stripe__Opportunity2__c = opportunities[1].Id,
            bt_stripe__Transaction_Status__c = 'Failed',
            bt_stripe__Due_Date__c = Date.today(),
            bt_stripe__Amount__c = 1000,
            First_Payment_Declined__c = false
        ));
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[2].Id,
            bt_stripe__Opportunity2__c = opportunities[2].Id,
            bt_stripe__Transaction_Status__c = 'Open',
            bt_stripe__Due_Date__c = Date.today(),
            bt_stripe__Amount__c = 1000
        ));
        
        insert transactions;
    }
    
    @isTest
    static void testBatchMarksFirstTransactionsOnly() {
        Test.startTest();
        Database.executeBatch(new FirstPaymentDeclinedBackfillBatch(), 200);
        Test.stopTest();
        
        List<bt_stripe__Transaction__c> markedTransactions = [
            SELECT Id, bt_stripe__Payment_Schedule__c, First_Payment_Declined__c,
                   bt_stripe__Due_Date__c
            FROM bt_stripe__Transaction__c
            WHERE First_Payment_Declined__c = true
            ORDER BY bt_stripe__Payment_Schedule__c, bt_stripe__Due_Date__c
        ];
        
        System.assertEquals(2, markedTransactions.size(), 
                          'Should mark 2 transactions (one per schedule with failed transactions)');
        
        Set<Id> markedSchedules = new Set<Id>();
        for (bt_stripe__Transaction__c trans : markedTransactions) {
            System.assert(!markedSchedules.contains(trans.bt_stripe__Payment_Schedule__c),
                        'Should only mark one transaction per payment schedule');
            markedSchedules.add(trans.bt_stripe__Payment_Schedule__c);
        }
    }
    
    @isTest
    static void testBatchDoesNotMarkNonFailedTransactions() {
        Test.startTest();
        Database.executeBatch(new FirstPaymentDeclinedBackfillBatch(), 200);
        Test.stopTest();
        
        List<bt_stripe__Transaction__c> openTransactions = [
            SELECT Id, First_Payment_Declined__c
            FROM bt_stripe__Transaction__c
            WHERE bt_stripe__Transaction_Status__c = 'Open'
        ];
        
        for (bt_stripe__Transaction__c trans : openTransactions) {
            System.assertEquals(false, trans.First_Payment_Declined__c,
                              'Open transactions should not be marked');
        }
    }
    
    @isTest
    static void testBatchHandlesAlreadyMarkedTransactions() {
        bt_stripe__Transaction__c trans = [
            SELECT Id
            FROM bt_stripe__Transaction__c
            WHERE bt_stripe__Transaction_Status__c = 'Failed'
            LIMIT 1
        ];
        
        trans.First_Payment_Declined__c = true;
        update trans;
        
        Test.startTest();
        Database.executeBatch(new FirstPaymentDeclinedBackfillBatch(), 200);
        Test.stopTest();
        
        bt_stripe__Transaction__c result = [
            SELECT First_Payment_Declined__c
            FROM bt_stripe__Transaction__c
            WHERE Id = :trans.Id
        ];
        
        System.assertEquals(true, result.First_Payment_Declined__c,
                          'Already marked transaction should remain marked');
    }
}