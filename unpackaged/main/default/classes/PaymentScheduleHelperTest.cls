@isTest
private class PaymentScheduleHelperTest {
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

       // Assert.areEqual(transactionV.LastModifiedDate.date(), updatedSchedule.Last_Payment_Date__c);
        Assert.areEqual(100.00, updatedSchedule.Last_Payment_Amount__c);
    }
    
    @isTest
    static void testTransactionTriggerWithoutCompletedStatus() {

        bt_stripe__Payment_Schedule__c paymentSchedule = new bt_stripe__Payment_Schedule__c();
        insert paymentSchedule;
        

        bt_stripe__Transaction__c transactionV = new bt_stripe__Transaction__c(
            bt_stripe__Transaction_Status__c = 'Pending',
            bt_stripe__Payment_Schedule__c = paymentSchedule.Id,
            bt_stripe__Amount__c = 200.00
        );
        insert transactionV;
        

        bt_stripe__Payment_Schedule__c updatedSchedule = [
            SELECT Last_Payment_Date__c, Last_Payment_Amount__c
            FROM bt_stripe__Payment_Schedule__c
            WHERE Id = :paymentSchedule.Id
        ];
        
        Assert.areEqual(null, updatedSchedule.Last_Payment_Date__c);
        Assert.areEqual(null, updatedSchedule.Last_Payment_Amount__c);
    }
}