@isTest
private class TaskTriggerHelperTest {
    
    @testSetup
    static void setupTestData() {
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp1;

        bt_stripe__Transaction__c tranxOne = new bt_stripe__Transaction__c(
            bt_stripe__Amount__c = 100,
            bt_stripe__Currency_ISO__c = 'USD',
            bt_stripe__Payment_Status__c = 'Uncaptured',
            bt_stripe__Due_Date__c = Date.today(),
            bt_stripe__Opportunity2__c = opp1.Id
        );
        insert tranxOne;
    }
    
    @isTest
    static void testTaskCallCounter() {

        Opportunity opp = [SELECT Id, CallRecaptureAttempts__c FROM Opportunity LIMIT 1];

        Task task = new Task(
            WhatId = opp.Id,
            Subject = 'Follow-up',
            taskSubtype = 'Call'
        );
        insert task;

        Opportunity updatedOpps = [SELECT Id, CallRecaptureAttempts__c FROM Opportunity LIMIT 1];

        Assert.areEqual(1, updatedOpps.CallRecaptureAttempts__c, 'The CallRecaptureAttempts should be 1.');

        Task task2 = new Task(
            WhatId = updatedOpps.Id,
            Subject = 'Follow-up next call',
            taskSubtype = 'Call'
        );
        insert task2;
        Opportunity updatedOpps2 = [SELECT Id, CallRecaptureAttempts__c FROM Opportunity LIMIT 1];

        Assert.areEqual(2, updatedOpps2.CallRecaptureAttempts__c, 'The CallRecaptureAttempts should be 2.');
    }
}