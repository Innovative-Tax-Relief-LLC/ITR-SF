@isTest
public class TransactionScheduledAmountBatchTest {
   
   @TestSetup
   static void setup() {
       bt_stripe__Payment_Schedule__c ps = new bt_stripe__Payment_Schedule__c(
           Scheduled_Transactions_Amount__c = 0
       );
       insert ps;
       
       List<bt_stripe__Transaction__c> transactions = new List<bt_stripe__Transaction__c>();
       for(Integer i = 0; i < 5; i++) {
           transactions.add(new bt_stripe__Transaction__c(
               bt_stripe__Payment_Schedule__c = ps.Id,
               bt_stripe__Transaction_Status__c = 'Open',
               bt_stripe__Amount__c = 100
           ));
       }
       
       for(Integer i = 0; i < 3; i++) {
           transactions.add(new bt_stripe__Transaction__c(
               bt_stripe__Payment_Schedule__c = ps.Id,
               bt_stripe__Transaction_Status__c = 'Closed',
               bt_stripe__Amount__c = 50
           ));
       }
       
       insert transactions;
   }
   
   @isTest
   static void testBatchExecution() {
       Test.startTest();
       Database.executeBatch(new TransactionScheduledAmountBatch(), 200);
       Test.stopTest();
       
       bt_stripe__Payment_Schedule__c ps = [
           SELECT Scheduled_Transactions_Amount__c 
           FROM bt_stripe__Payment_Schedule__c 
           LIMIT 1
       ];
       
       Assert.areEqual(500, ps.Scheduled_Transactions_Amount__c, 
           'El monto calculado debe ser 500 (5 transacciones x 100)');
   }
   
   @isTest
   static void testBatchWithMixedAmounts() {
       bt_stripe__Payment_Schedule__c ps = new bt_stripe__Payment_Schedule__c();
       insert ps;
       
       List<bt_stripe__Transaction__c> transactions = new List<bt_stripe__Transaction__c>{
           new bt_stripe__Transaction__c(
               bt_stripe__Payment_Schedule__c = ps.Id,
               bt_stripe__Transaction_Status__c = 'Open',
               bt_stripe__Amount__c = 150.50
           ),
           new bt_stripe__Transaction__c(
               bt_stripe__Payment_Schedule__c = ps.Id,
               bt_stripe__Transaction_Status__c = 'Open',
               bt_stripe__Amount__c = 75.25
           )
       };
       insert transactions;
       
       Test.startTest();
       Database.executeBatch(new TransactionScheduledAmountBatch(), 200);
       Test.stopTest();
       
       ps = [SELECT Scheduled_Transactions_Amount__c FROM bt_stripe__Payment_Schedule__c WHERE Id = :ps.Id];
       
       Assert.areEqual(225.75, ps.Scheduled_Transactions_Amount__c, 
           'El monto debe ser 225.75 (150.50 + 75.25)');
   }
}