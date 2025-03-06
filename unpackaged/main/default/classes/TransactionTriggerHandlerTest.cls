@isTest
public class TransactionTriggerHandlerTest {
    @testSetup
    static void setupTestData() {

        Id secondTradeRecordTypeId = TestDataFactory.getOppRecordTypeId('Second Trade');
        Id otherRecordTypeId = TestDataFactory.getOppRecordTypeId('First Trade');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Opportunity secondTradeOpp = TestDataFactory.createOpportunity('Second Trade Opportunity', secondTradeRecordTypeId);
        Opportunity otherOpp = TestDataFactory.createOpportunity('Other Opportunity', otherRecordTypeId);

        bt_stripe__Payment_Schedule__c secondTradeSchedule = TestDataFactory.createPaymentSchedule(secondTradeOpp.Id);
        bt_stripe__Payment_Schedule__c otherSchedule = TestDataFactory.createPaymentSchedule(otherOpp.Id);

        TestDataFactory.createTransaction(secondTradeSchedule.Id, secondTradeOpp.Id, 'Open', 100.0);
        TestDataFactory.createTransaction(otherSchedule.Id, otherOpp.Id, 'Open', 50.0);
    }

    @isTest
    static void testTransactionTrigger() {
        bt_stripe__Payment_Schedule__c paymentSchedule = new bt_stripe__Payment_Schedule__c();
        insert paymentSchedule;

        bt_stripe__Transaction__c transactionV = new bt_stripe__Transaction__c(
            bt_stripe__Transaction_Status__c = 'Completed',
            bt_stripe__Payment_Schedule__c = paymentSchedule.Id,
            bt_stripe__Amount__c = 100.00
        );
        insert transactionV;
        
        bt_stripe__Payment_Schedule__c updatedSchedule = [
            SELECT Last_Payment_Date__c, Last_Payment_Amount__c
            FROM bt_stripe__Payment_Schedule__c
            WHERE Id = :paymentSchedule.Id
        ];

        Assert.areEqual(100.00, updatedSchedule.Last_Payment_Amount__c);
    }
    
    @isTest
    static void testHandleFailedTransactionsForSecondTrade() {
        List<bt_stripe__Transaction__c> transactions = [
            SELECT Id, bt_stripe__Transaction_Status__c, bt_stripe__Payment_Schedule__c, bt_stripe__Opportunity2__c, 
                bt_stripe__Opportunity2__r.RecordType.Name
            FROM bt_stripe__Transaction__c
        ];

        List<bt_stripe__Transaction__c> transactionsToUpdate = new List<bt_stripe__Transaction__c>();

        for (bt_stripe__Transaction__c trans : transactions) {
            if (trans.bt_stripe__Opportunity2__r.RecordType.Name == 'Second Trade') {
                trans.bt_stripe__Transaction_Status__c = 'Failed';
                transactionsToUpdate.add(trans);
            }
        }
        Test.startTest();
        update transactionsToUpdate;
        Test.stopTest();

        List<Task> createdTasks = [SELECT Id, Subject, OwnerId 
                            FROM Task 
                            WHERE Subject LIKE '1st Payment Declined%' 
                            LIMIT 1];
        Assert.isFalse(createdTasks.isEmpty(), 'A task should be created');
        
    }


    @isTest
    static void testHandleFailedTransactionsForOtherTypes() {
        List<bt_stripe__Transaction__c> transactions = [
            SELECT Id, bt_stripe__Transaction_Status__c, bt_stripe__Payment_Schedule__c, 
            bt_stripe__Opportunity2__c, bt_stripe__Opportunity2__r.RecordType.Name
            FROM bt_stripe__Transaction__c
        ];

        for (bt_stripe__Transaction__c trans : transactions) {
            if (trans.bt_stripe__Opportunity2__r.RecordType.Name == 'Other') {
                trans.bt_stripe__Transaction_Status__c = 'Failed';
            }
        }
        update transactions;

        List<Task> tasks = [SELECT Id FROM Task WHERE Subject LIKE '1st Payment Declined%'];
        Assert.areEqual(0, tasks.size());
    }
}