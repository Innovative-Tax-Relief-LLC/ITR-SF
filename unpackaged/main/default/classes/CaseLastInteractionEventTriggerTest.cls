@isTest
private class CaseLastInteractionEventTriggerTest {

    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User uS = new User( 
            Alias = 'testu',
            Email = 'testuseraa@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test09881@example.com'
        );
        insert uS;
    }
    
    @isTest
    static void testTriggerAfterInsert() {
        User u = [SELECT Id FROM User WHERE LastName = 'Test' LIMIT 1];

        Case testCase = new Case(Subject = 'Test Case', Status = 'In progress');
        insert testCase;

        Event testEvent = new Event(Subject = 'Test Event', WhatId = testCase.Id, OwnerId = u.Id, StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addHours(1));
        insert testEvent;

        Case updatedCase = [SELECT Id, LastOutreachDate__c FROM Case WHERE Id = :testCase.Id];

        Assert.isNotNull(updatedCase.LastOutreachDate__c, 'LastOutreachDate__c should be updated');
        Assert.areEqual(Date.today(), updatedCase.LastOutreachDate__c, 'LastOutreachDate__c should be today\'s date');
    }

    @isTest
    static void testTriggerAfterUpdate() {
        User u = [SELECT Id FROM User WHERE LastName = 'Test' LIMIT 1];

        Case testCase = new Case(Subject = 'Test Case', Status = 'In progress');
        insert testCase;

        Event testEvent = new Event(Subject = 'Test Event', WhatId = testCase.Id, OwnerId = u.Id, StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addHours(1));
        insert testEvent;

        testEvent.Subject = 'Updated Test Event';
        update testEvent;

        Case updatedCase = [SELECT Id, LastOutreachDate__c FROM Case WHERE Id = :testCase.Id];

        Assert.isNotNull(updatedCase.LastOutreachDate__c, 'LastOutreachDate__c should be updated');
        Assert.areEqual(Date.today(), updatedCase.LastOutreachDate__c, 'LastOutreachDate__c should be today\'s date');
    }
}