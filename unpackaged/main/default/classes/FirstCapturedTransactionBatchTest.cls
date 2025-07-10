@isTest
public class FirstCapturedTransactionBatchTest {
    
    @TestSetup
    static void setupTestData() {
        List<bt_stripe__Payment_Schedule__c> paymentSchedules = new List<bt_stripe__Payment_Schedule__c>();
        for (Integer i = 0; i < 4; i++) {
            paymentSchedules.add(new bt_stripe__Payment_Schedule__c());
        }
        insert paymentSchedules;
        
        List<bt_stripe__Transaction__c> transactions = new List<bt_stripe__Transaction__c>();
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[0].Id,
            bt_stripe__Transaction_Status__c = 'Completed',
            bt_stripe__Payment_Status__c = 'Captured',
            bt_stripe__Due_Date__c = Date.today().addDays(-10),
            bt_stripe__Amount__c = 100.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[0].Id,
            bt_stripe__Transaction_Status__c = 'Completed',
            bt_stripe__Payment_Status__c = 'Captured',
            bt_stripe__Due_Date__c = Date.today().addDays(-5),
            bt_stripe__Amount__c = 150.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[0].Id,
            bt_stripe__Transaction_Status__c = 'Completed',
            bt_stripe__Payment_Status__c = 'Captured',
            bt_stripe__Due_Date__c = Date.today().addDays(-8),
            bt_stripe__Amount__c = 200.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[1].Id,
            bt_stripe__Transaction_Status__c = 'Completed',
            bt_stripe__Payment_Status__c = 'Captured',
            bt_stripe__Due_Date__c = Date.today().addDays(-3),
            bt_stripe__Amount__c = 75.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[1].Id,
            bt_stripe__Transaction_Status__c = 'Pending',
            bt_stripe__Payment_Status__c = 'Captured',
            bt_stripe__Due_Date__c = Date.today().addDays(-1),
            bt_stripe__Amount__c = 50.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[1].Id,
            bt_stripe__Transaction_Status__c = 'Completed',
            bt_stripe__Payment_Status__c = 'Pending',
            bt_stripe__Due_Date__c = Date.today().addDays(-2),
            bt_stripe__Amount__c = 125.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[2].Id,
            bt_stripe__Transaction_Status__c = 'Failed',
            bt_stripe__Payment_Status__c = 'Failed',
            bt_stripe__Due_Date__c = Date.today().addDays(-1),
            bt_stripe__Amount__c = 300.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[3].Id,
            bt_stripe__Transaction_Status__c = 'Completed',
            bt_stripe__Payment_Status__c = 'Captured',
            bt_stripe__Due_Date__c = null, // Fecha null
            bt_stripe__Amount__c = 400.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[3].Id,
            bt_stripe__Transaction_Status__c = 'Completed',
            bt_stripe__Payment_Status__c = 'Captured',
            bt_stripe__Due_Date__c = Date.today().addDays(-1),
            bt_stripe__Amount__c = 500.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[3].Id,
            bt_stripe__Transaction_Status__c = 'Completed',
            bt_stripe__Payment_Status__c = 'Captured',
            bt_stripe__Due_Date__c = Date.today().addDays(-15),
            bt_stripe__Amount__c = 600.00,
            First_Completed_Captured_Transaction__c = true 
        ));
        
        insert transactions;
    }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        
        FirstCompletedCapturedTransactionBatch batch = new FirstCompletedCapturedTransactionBatch();
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        List<bt_stripe__Payment_Schedule__c> paymentSchedules = [SELECT Id FROM bt_stripe__Payment_Schedule__c ORDER BY CreatedDate];
        
        List<bt_stripe__Transaction__c> firstPSTransactions = [
            SELECT Id, First_Completed_Captured_Transaction__c, bt_stripe__Due_Date__c
            FROM bt_stripe__Transaction__c 
            WHERE bt_stripe__Payment_Schedule__c = :paymentSchedules[0].Id
            AND bt_stripe__Transaction_Status__c = 'Completed'
            AND bt_stripe__Payment_Status__c = 'Captured'
            ORDER BY bt_stripe__Due_Date__c ASC
        ];
        
        Assert.areEqual(3, firstPSTransactions.size(), 'Should have 3 valid transactions');
        Assert.areEqual(true, firstPSTransactions[0].First_Completed_Captured_Transaction__c, 
                           'First transaction (earliest due date) should be marked as first');
        Assert.areEqual(false, firstPSTransactions[1].First_Completed_Captured_Transaction__c, 
                           'Second transaction should not be marked as first');
        Assert.areEqual(false, firstPSTransactions[2].First_Completed_Captured_Transaction__c, 
                           'Third transaction should not be marked as first');
        
        List<bt_stripe__Transaction__c> secondPSTransactions = [
            SELECT Id, First_Completed_Captured_Transaction__c
            FROM bt_stripe__Transaction__c 
            WHERE bt_stripe__Payment_Schedule__c = :paymentSchedules[1].Id
            AND bt_stripe__Transaction_Status__c = 'Completed'
            AND bt_stripe__Payment_Status__c = 'Captured'
        ];
        
        Assert.areEqual(1, secondPSTransactions.size(), 'Should have 1 valid transaction');
        Assert.areEqual(true, secondPSTransactions[0].First_Completed_Captured_Transaction__c, 
                           'Only valid transaction should be marked as first');
        
        List<bt_stripe__Transaction__c> thirdPSTransactions = [
            SELECT Id, First_Completed_Captured_Transaction__c
            FROM bt_stripe__Transaction__c 
            WHERE bt_stripe__Payment_Schedule__c = :paymentSchedules[2].Id
            AND bt_stripe__Transaction_Status__c = 'Completed'
            AND bt_stripe__Payment_Status__c = 'Captured'
        ];
        
        Assert.areEqual(0, thirdPSTransactions.size(), 'Should have no valid transactions');
        
        List<bt_stripe__Transaction__c> fourthPSTransactions = [
            SELECT Id, First_Completed_Captured_Transaction__c, bt_stripe__Due_Date__c
            FROM bt_stripe__Transaction__c 
            WHERE bt_stripe__Payment_Schedule__c = :paymentSchedules[3].Id
            AND bt_stripe__Transaction_Status__c = 'Completed'
            AND bt_stripe__Payment_Status__c = 'Captured'
            AND bt_stripe__Due_Date__c != null
            ORDER BY bt_stripe__Due_Date__c ASC
        ];
        
        Assert.areEqual(2, fourthPSTransactions.size(), 'Should have 2 transactions with valid dates');
        Assert.areEqual(true, fourthPSTransactions[0].First_Completed_Captured_Transaction__c, 
                           'Earliest due date transaction should be marked as first');
        Assert.areEqual(false, fourthPSTransactions[1].First_Completed_Captured_Transaction__c, 
                           'Later due date transaction should not be marked as first');
    }
    
    @isTest
    static void testTransactionDateComparator() {

        bt_stripe__Transaction__c trans1 = new bt_stripe__Transaction__c(
            bt_stripe__Due_Date__c = Date.today().addDays(-10)
        );
        
        bt_stripe__Transaction__c trans2 = new bt_stripe__Transaction__c(
            bt_stripe__Due_Date__c = Date.today().addDays(-5)
        );
        
        bt_stripe__Transaction__c trans3 = new bt_stripe__Transaction__c(
            bt_stripe__Due_Date__c = null
        );
        
        bt_stripe__Transaction__c trans4 = new bt_stripe__Transaction__c(
            bt_stripe__Due_Date__c = null
        );
        
        bt_stripe__Transaction__c trans5 = new bt_stripe__Transaction__c(
            bt_stripe__Due_Date__c = Date.today().addDays(-10) 
        );
        
        FirstCompletedCapturedTransactionBatch.TransactionDateComparator comparator = 
            new FirstCompletedCapturedTransactionBatch.TransactionDateComparator();
        
        Test.startTest();
        
        Integer result1 = comparator.compare(trans1, trans2);
        Assert.areEqual(-1, result1, 'Earlier due date transaction should come first');
        
        Integer result2 = comparator.compare(trans2, trans1);
        Assert.areEqual(1, result2, 'Later due date transaction should come after');
        
        Integer result3 = comparator.compare(trans3, trans4);
        Assert.areEqual(0, result3, 'Both null dates should be equal');
        
        Integer result4 = comparator.compare(trans1, trans3);
        Assert.areEqual(-1, result4, 'Non-null date should come before null');
        
        Integer result5 = comparator.compare(trans3, trans1);
        Assert.areEqual(1, result5, 'Null date should come after non-null');
        
        Integer result6 = comparator.compare(trans1, trans5);
        Assert.areEqual(0, result6, 'Same dates should be equal');
        
        Test.stopTest();
    }
    
    @isTest
    static void testBatchWithNoValidTransactions() {
        delete [SELECT Id FROM bt_stripe__Transaction__c];
        
        List<bt_stripe__Payment_Schedule__c> paymentSchedules = [SELECT Id FROM bt_stripe__Payment_Schedule__c LIMIT 1];
        
        List<bt_stripe__Transaction__c> invalidTransactions = new List<bt_stripe__Transaction__c>();
        
        invalidTransactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[0].Id,
            bt_stripe__Transaction_Status__c = 'Failed',
            bt_stripe__Payment_Status__c = 'Failed',
            bt_stripe__Due_Date__c = Date.today().addDays(-1),
            bt_stripe__Amount__c = 100.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        invalidTransactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[0].Id,
            bt_stripe__Transaction_Status__c = 'Completed',
            bt_stripe__Payment_Status__c = 'Pending',
            bt_stripe__Due_Date__c = Date.today().addDays(-2),
            bt_stripe__Amount__c = 200.00,
            First_Completed_Captured_Transaction__c = false
        ));
        
        insert invalidTransactions;
        
        Test.startTest();
        
        FirstCompletedCapturedTransactionBatch batch = new FirstCompletedCapturedTransactionBatch();
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        List<bt_stripe__Transaction__c> updatedTransactions = [
            SELECT Id, First_Completed_Captured_Transaction__c
            FROM bt_stripe__Transaction__c
            WHERE First_Completed_Captured_Transaction__c = true
        ];
        
        Assert.areEqual(0, updatedTransactions.size(), 'No transactions should be marked when none are valid');
    }
    
    @isTest
    static void testBatchQueryLocator() {
        Test.startTest();
        
        FirstCompletedCapturedTransactionBatch batch = new FirstCompletedCapturedTransactionBatch();
        Database.QueryLocator ql = batch.start(null);
        
        Test.stopTest();
        
        Assert.areNotEqual(null, ql, 'Query locator should not be null');
        
        List<bt_stripe__Payment_Schedule__c> paymentSchedules = [SELECT Id FROM bt_stripe__Payment_Schedule__c];
        Assert.isTrue(paymentSchedules.size() > 0, 'Should find payment schedules with valid transactions');
    }
}