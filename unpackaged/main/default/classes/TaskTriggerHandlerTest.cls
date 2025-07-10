@isTest
private class TaskTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {

        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert testOpportunity;

        bt_stripe__Transaction__c tran = new bt_stripe__Transaction__c(
            bt_stripe__Amount__c = 100,
            bt_stripe__Currency_ISO__c = 'USD',
            bt_stripe__Payment_Status__c = 'Uncaptured',
            bt_stripe__Opportunity2__c = testOpportunity.Id,
            bt_stripe__Due_Date__c = Date.today()
        );
        insert tran;
    }
    
    @isTest
    static void taskAfterInsertWithCaseTest() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        Task task = new Task(
            WhatId = testCase.Id,
            Subject = 'Follow-up',
            Status = 'Not Started'
        );

        Test.startTest();
        insert task;
        Test.stopTest();

        Case updatedCase = [SELECT Id, DaysSinceLastOutreach__c, LastOutreachDate__c FROM Case LIMIT 1];
       Assert.areNotEqual(null, task.Id, 'The task should have been Insert.');
       Assert.areEqual(0, updatedCase.DaysSinceLastOutreach__c, 'The DaysSinceLastOutreach should be 0.');
    }
    
    @isTest
    static void taskAfterInsertWithOpportunityTest() {
        Opportunity testOpportunity = [SELECT Id, CallRecaptureAttempts__c FROM Opportunity LIMIT 1];

        Task task = new Task(
            WhatId = testOpportunity.Id,
            TaskSubtype = 'Call',
            Subject = 'Call with client',
            Status = 'Completed'
        );

        Test.startTest();
        insert task;
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, CallRecaptureAttempts__c FROM Opportunity WHERE Id = :testOpportunity.Id LIMIT 1];
        Assert.areNotEqual(null, task.Id, 'The task should have been updated.');
        Assert.isTrue(updatedOpp.CallRecaptureAttempts__c == 1, 'The CallRecaptureAttempts should be 1.');
    }

    @isTest
    static void taskAfterUpdateWithCaseTest() {
        Case testCase = [SELECT Id, LastOutreachDate__c FROM Case LIMIT 1];

        Task task = new Task(
            WhatId = testCase.Id,
            Subject = 'Initial Task',
            Status = 'Not Started'
        );
        insert task;

        task.Subject = 'Updated Task';

        Test.startTest();
        update task;
        Test.stopTest();

        Task updatedTask = [SELECT Id, Subject FROM Task WHERE Id = :task.Id LIMIT 1];
        case updateCase = [SELECT Id, LastOutreachDate__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        Assert.areEqual('Updated Task', updatedTask.Subject, 'The task should have been updated.');
        Assert.areEqual(date.today(), updateCase.LastOutreachDate__c, 'The LastOutreachDate should be match.');
    }
}