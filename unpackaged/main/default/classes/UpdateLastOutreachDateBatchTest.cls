@isTest
private class UpdateLastOutreachDateBatchTest {

    @testSetup
    static void setupData() {

        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 3; i++) {
            cases.add(new Case(Status = 'New'));
        }
        insert cases;

        Id caseId1 = cases[0].Id;
        Id caseId2 = cases[1].Id;
        Id caseId3 = cases[2].Id;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(
            Alias = 'testu',
            Email = 'testuseraa@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testsalesfforce@example.com'
        );
        insert u;

        Task task1 = new Task(WhatId = caseId1, Subject = 'Follow-up', CreatedDate = Date.today().addDays(-5), Status = 'Open', OwnerId = u.Id, priority = 'Normal');
        insert task1;

        Event event1 = new Event(WhatId = caseId1, Subject = 'Meeting', CreatedDate = Date.today().addDays(-2), StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addHours(1), OwnerId = u.Id);
        insert event1;

        FeedItem feed1 = new FeedItem(ParentId = caseId2, Body = 'Customer Comment', CreatedDate = Date.today().addDays(-1));
        insert feed1;
    }

    @isTest
    static void testBatchProcessing() {
        Test.startTest();
        UpdateLastOutreachDateBatch batchJob = new UpdateLastOutreachDateBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();

        List<Case> updatedCases = [SELECT Id, LastOutreachDate__c FROM Case];

        for (Case c : updatedCases) {
            if (c.Id == [SELECT Id FROM Task WHERE WhatId = :updatedCases[0].Id LIMIT 1].Id) {
                Assert.areEqual(Date.today().addDays(-2), c.LastOutreachDate__c, 'Debe coincidir con la fecha más reciente de Event');
            }
            if (c.Id == [SELECT Id FROM FeedItem WHERE ParentId = :updatedCases[1].Id LIMIT 1].Id) {
                Assert.areEqual(Date.today().addDays(-1), c.LastOutreachDate__c, 'Debe coincidir con la fecha de FeedItem');
            }
            if (c.LastOutreachDate__c == null) {
                Assert.areEqual(null, c.CreatedDate.date(), 'Si no tiene registros relacionados, debe tomar CreatedDate');
            }
        }
    }
}