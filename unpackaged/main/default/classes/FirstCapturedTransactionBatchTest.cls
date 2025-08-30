@isTest(SeeAllData=false)
public class FirstCapturedTransactionBatchTest {

    @TestSetup
    static void setupTestData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 4; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
        
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 4; i++) {
            opportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                AccountId = accounts[i].Id
            ));
        }
        insert opportunities;
        
        List<bt_stripe__Payment_Schedule__c> paymentSchedules = new List<bt_stripe__Payment_Schedule__c>();
        for (Integer i = 0; i < 4; i++) {
            paymentSchedules.add(new bt_stripe__Payment_Schedule__c(
                Opportunity__c = opportunities[i].Id
            ));
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
            bt_stripe__Due_Date__c = null,
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

        System.assertEquals(3, firstPSTransactions.size());
        System.assertEquals(true, firstPSTransactions[0].First_Completed_Captured_Transaction__c);
        System.assertEquals(false, firstPSTransactions[1].First_Completed_Captured_Transaction__c);
        System.assertEquals(false, firstPSTransactions[2].First_Completed_Captured_Transaction__c);

        List<Opportunity> updatedOpportunities = [SELECT Id, First_Pay_Date__c FROM Opportunity ORDER BY CreatedDate];
        
        List<bt_stripe__Transaction__c> firstTransactionsWithOpp = [
            SELECT Id, bt_stripe__Opportunity2__c, CreatedDate
            FROM bt_stripe__Transaction__c 
            WHERE First_Completed_Captured_Transaction__c = true
            AND bt_stripe__Opportunity2__c != null
        ];
        
        System.assertEquals(true, firstTransactionsWithOpp.size() > 0);

        List<bt_stripe__Transaction__c> secondPSTransactions = [
            SELECT Id, First_Completed_Captured_Transaction__c
            FROM bt_stripe__Transaction__c
            WHERE bt_stripe__Payment_Schedule__c = :paymentSchedules[1].Id
            AND bt_stripe__Transaction_Status__c = 'Completed'
            AND bt_stripe__Payment_Status__c = 'Captured'
        ];

        System.assertEquals(1, secondPSTransactions.size());
        System.assertEquals(true, secondPSTransactions[0].First_Completed_Captured_Transaction__c);

        List<bt_stripe__Transaction__c> fourthPSTransactions = [
            SELECT Id, First_Completed_Captured_Transaction__c, bt_stripe__Due_Date__c
            FROM bt_stripe__Transaction__c
            WHERE bt_stripe__Payment_Schedule__c = :paymentSchedules[3].Id
            AND bt_stripe__Transaction_Status__c = 'Completed'
            AND bt_stripe__Payment_Status__c = 'Captured'
            AND bt_stripe__Due_Date__c != null
            ORDER BY bt_stripe__Due_Date__c ASC
        ];

        System.assertEquals(2, fourthPSTransactions.size());
        System.assertEquals(true, fourthPSTransactions[0].First_Completed_Captured_Transaction__c);
        System.assertEquals(false, fourthPSTransactions[1].First_Completed_Captured_Transaction__c);
    }

    @isTest
    static void testTransactionDateComparator() {
        bt_stripe__Transaction__c trans1 = new bt_stripe__Transaction__c(bt_stripe__Due_Date__c = Date.today().addDays(-10));
        bt_stripe__Transaction__c trans2 = new bt_stripe__Transaction__c(bt_stripe__Due_Date__c = Date.today().addDays(-5));
        bt_stripe__Transaction__c trans3 = new bt_stripe__Transaction__c(bt_stripe__Due_Date__c = null);

        FirstCompletedCapturedTransactionBatch.TransactionDateComparator comparator = new FirstCompletedCapturedTransactionBatch.TransactionDateComparator();

        Test.startTest();
        System.assertEquals(-1, comparator.compare(trans1, trans2));
        System.assertEquals(1, comparator.compare(trans2, trans1));
        System.assertEquals(-1, comparator.compare(trans1, trans3));
        System.assertEquals(1, comparator.compare(trans3, trans1));
        Test.stopTest();
    }

    @isTest
    static void testBatchWithNoValidTransactions() {
        delete [SELECT Id FROM bt_stripe__Transaction__c];

        List<bt_stripe__Payment_Schedule__c> paymentSchedules = [SELECT Id FROM bt_stripe__Payment_Schedule__c LIMIT 1];

        insert new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[0].Id,
            bt_stripe__Transaction_Status__c = 'Failed',
            bt_stripe__Payment_Status__c = 'Failed',
            bt_stripe__Due_Date__c = Date.today().addDays(-1),
            bt_stripe__Amount__c = 100.00,
            First_Completed_Captured_Transaction__c = false
        );

        Test.startTest();
        FirstCompletedCapturedTransactionBatch batch = new FirstCompletedCapturedTransactionBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<bt_stripe__Transaction__c> updatedTransactions = [
            SELECT Id FROM bt_stripe__Transaction__c WHERE First_Completed_Captured_Transaction__c = true
        ];

        System.assertEquals(0, updatedTransactions.size());
    }
}