@isTest
private class UpdatePaymentScheduleBatchTest {
    
    @testSetup
    static void setupData() {
        List<bt_stripe__Payment_Schedule__c> schedules = new List<bt_stripe__Payment_Schedule__c>();
        for (Integer i = 0; i < 5; i++) {
            bt_stripe__Payment_Schedule__c schedule = new bt_stripe__Payment_Schedule__c();
            schedules.add(schedule);
        }
        insert schedules;

        List<bt_stripe__Transaction__c> transactions = new List<bt_stripe__Transaction__c>();
        for (bt_stripe__Payment_Schedule__c schedule : schedules) {
            bt_stripe__Transaction__c trans = new bt_stripe__Transaction__c(
                bt_stripe__Payment_Schedule__c = schedule.Id,
                bt_stripe__Transaction_Status__c = 'Completed',
                bt_stripe__Amount__c = 150.00,
                bt_stripe__Processed_Date__c = System.now() 
            );
            transactions.add(trans);
        }
        insert transactions;
    }
    
    static testMethod void testBatchExecution() {
        // Inicia la prueba
        Test.startTest();
        UpdatePaymentScheduleBatch batchJob = new UpdatePaymentScheduleBatch();
        Database.executeBatch(batchJob, 200);
        Test.stopTest();
        
        List<bt_stripe__Payment_Schedule__c> updatedSchedules = [SELECT Id, Last_Payment_Date__c, Last_Payment_Amount__c FROM bt_stripe__Payment_Schedule__c];

        for (bt_stripe__Payment_Schedule__c schedule : updatedSchedules) {
            Assert.areNotEqual(null, schedule.Last_Payment_Date__c, 'El campo Last_Payment_Date__c debe tener valor');
            Assert.areEqual(150.00, schedule.Last_Payment_Amount__c, 'El campo Last_Payment_Amount__c debe ser 150.00');
        }
    }
}