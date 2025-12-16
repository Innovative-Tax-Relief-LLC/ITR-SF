@isTest
private class FirstPaymentDeclinedServiceTest {
    
    @TestSetup
    static void setup() {
        RecordType secondTradeRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Second Trade' LIMIT 1];
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Second Trade Opp 1',
                AccountId = testAccount.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                RecordTypeId = secondTradeRT.Id
            ),
            new Opportunity(
                Name = 'Second Trade Opp 2',
                AccountId = testAccount.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                RecordTypeId = secondTradeRT.Id
            )
        };
        insert opportunities;
        
        List<bt_stripe__Payment_Schedule__c> paymentSchedules = new List<bt_stripe__Payment_Schedule__c>{
            new bt_stripe__Payment_Schedule__c(
                Opportunity__c = opportunities[0].Id
            ),
            new bt_stripe__Payment_Schedule__c(
                Opportunity__c = opportunities[1].Id
            )
        };
        insert paymentSchedules;
        
        List<bt_stripe__Transaction__c> transactions = new List<bt_stripe__Transaction__c>();
        
        for (Integer i = 0; i < 2; i++) {
            transactions.add(new bt_stripe__Transaction__c(
                bt_stripe__Payment_Schedule__c = paymentSchedules[0].Id,
                bt_stripe__Opportunity2__c = opportunities[0].Id,
                bt_stripe__Transaction_Status__c = 'Open',
                bt_stripe__Due_Date__c = Date.today().addDays(i),
                bt_stripe__Amount__c = 1000
            ));
        }
        
        transactions.add(new bt_stripe__Transaction__c(
            bt_stripe__Payment_Schedule__c = paymentSchedules[1].Id,
            bt_stripe__Opportunity2__c = opportunities[1].Id,
            bt_stripe__Transaction_Status__c = 'Open',
            bt_stripe__Due_Date__c = Date.today(),
            bt_stripe__Amount__c = 1000
        ));
        
        insert transactions;
    }
    
    @isTest
    static void testFirstFailedTransactionMarked() {
        bt_stripe__Transaction__c trans = [
            SELECT Id, bt_stripe__Transaction_Status__c
            FROM bt_stripe__Transaction__c
            WHERE Opportunity_Record_Type__c = 'Second Trade'
            LIMIT 1
        ];
        
        Test.startTest();
        trans.bt_stripe__Transaction_Status__c = 'Failed';
        update trans;
        Test.stopTest();
        
        bt_stripe__Transaction__c result = [
            SELECT First_Payment_Declined__c
            FROM bt_stripe__Transaction__c
            WHERE Id = :trans.Id
        ];
        
        System.assertEquals(true, result.First_Payment_Declined__c, 
                          'First failed transaction should be marked');
    }
    
    @isTest
    static void testSecondFailedTransactionNotMarked() {
        List<bt_stripe__Transaction__c> transList = [
            SELECT Id, bt_stripe__Transaction_Status__c, bt_stripe__Payment_Schedule__c
            FROM bt_stripe__Transaction__c
            WHERE Opportunity_Record_Type__c = 'Second Trade'
            ORDER BY bt_stripe__Due_Date__c
            LIMIT 2
        ];
        
        Test.startTest();
        transList[0].bt_stripe__Transaction_Status__c = 'Failed';
        update transList[0];
        Test.stopTest();
        
        transList[1].bt_stripe__Transaction_Status__c = 'Failed';
        update transList[1];
        
        bt_stripe__Transaction__c result = [
            SELECT First_Payment_Declined__c
            FROM bt_stripe__Transaction__c
            WHERE Id = :transList[1].Id
        ];
        
        System.assertEquals(false, result.First_Payment_Declined__c, 
                          'Second failed transaction should NOT be marked');
    }
    
    @isTest
    static void testBulkProcessing() {
        List<bt_stripe__Transaction__c> transList = [
            SELECT Id, bt_stripe__Transaction_Status__c
            FROM bt_stripe__Transaction__c
            WHERE Opportunity_Record_Type__c = 'Second Trade'
        ];
        
        for (bt_stripe__Transaction__c trans : transList) {
            trans.bt_stripe__Transaction_Status__c = 'Failed';
        }
        
        Test.startTest();
        update transList;
        Test.stopTest();
        
        Integer markedCount = [
            SELECT COUNT()
            FROM bt_stripe__Transaction__c
            WHERE Id IN :transList
            AND First_Payment_Declined__c = true
        ];
        
        System.assertEquals(2, markedCount, 
                          'Should mark one per Payment Schedule (2 schedules = 2 marked)');
    }
}