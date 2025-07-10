@isTest
private class RestarCallRecaptureAttamptsScheduleTest {
    
    @testSetup
    static void setupTestData() {
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            testOpportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                CallRecaptureAttempts__c = i 
            ));
        }
        insert testOpportunities;
    }

    @isTest
    static void testScheduledExecution() {

        List<Opportunity> beforeUpdate = [SELECT Id, CallRecaptureAttempts__c FROM Opportunity WHERE CallRecaptureAttempts__c != NULL];
        System.assert(!beforeUpdate.isEmpty(), 'Test opportunities should exist before execution.');

        Test.startTest();
        new RestarCallRecaptureAttamptsSchedule().execute(null);
        Test.stopTest();

        List<Opportunity> afterUpdate = [SELECT Id, CallRecaptureAttempts__c FROM Opportunity WHERE CallRecaptureAttempts__c != NULL];

        for (Opportunity opp : afterUpdate) {
            System.assertEquals(0, opp.CallRecaptureAttempts__c, 'CallRecaptureAttempts__c should be 0 after execution.');
        }
    }

}