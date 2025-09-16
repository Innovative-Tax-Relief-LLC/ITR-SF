@isTest
private class CaseUpdateLastInteractionFeedTriggerTest {

    @testSetup
    static void makeData(){
        User ownerUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'Owner',
            Email = 'testowner@testorg.com',
            Username = 'testowner.user@testorg.com' + System.currentTimeMillis(),
            Alias = 'owner',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert ownerUser;

        User nonOwnerUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'NonOwner',
            Email = 'nonowner@testorg.com',
            Username = 'nonowner.user@testorg.com' + System.currentTimeMillis(),
            Alias = 'nonown',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert nonOwnerUser;
    }

    @isTest
    static void testPostInsertByOwner_ShouldUpdateField() {
        User ownerUser = [SELECT Id FROM User WHERE LastName = 'Owner' LIMIT 1];
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Web',
            OwnerId = ownerUser.Id
        );
        insert testCase;

        System.runAs(ownerUser) {
            Test.startTest();
            FeedItem post = new FeedItem(
                ParentId = testCase.Id,
                Body = 'This is a test post from the owner.'
            );
            insert post;
            Test.stopTest();
        }

        Case resultCase = [SELECT LastOutreachDate__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(Date.today(), resultCase.LastOutreachDate__c);
    }

    @isTest
    static void testPostInsertByNonOwner_ShouldNotUpdateField() {
        User ownerUser = [SELECT Id FROM User WHERE LastName = 'Owner' LIMIT 1];
        User nonOwnerUser = [SELECT Id FROM User WHERE LastName = 'NonOwner' LIMIT 1];

        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Web',
            OwnerId = ownerUser.Id
        );
        insert testCase;

        // CORRECCIÓN AQUÍ: Otorgar acceso de lectura al usuario no propietario
        CaseShare nonOwnerAccess = new CaseShare();
        nonOwnerAccess.CaseId = testCase.Id;
        nonOwnerAccess.UserOrGroupId = nonOwnerUser.Id;
        nonOwnerAccess.CaseAccessLevel = 'Read';
        insert nonOwnerAccess;

        System.runAs(nonOwnerUser) {
            Test.startTest();
            FeedItem post = new FeedItem(
                ParentId = testCase.Id,
                Body = 'This is a test post from a non-owner.'
            );
            insert post;
            Test.stopTest();
        }

        Case resultCase = [SELECT LastOutreachDate__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(null, resultCase.LastOutreachDate__c);
    }
    
    @isTest
    static void testPostUpdateByOwner_ShouldUpdateField() {
        User ownerUser = [SELECT Id FROM User WHERE LastName = 'Owner' LIMIT 1];
        Case testCase = new Case(Subject = 'Test Case', Status = 'New', OwnerId = ownerUser.Id);
        insert testCase;

        FeedItem postToUpdate;
        System.runAs(ownerUser) {
            postToUpdate = new FeedItem(ParentId = testCase.Id, Body = 'Initial post.');
            insert postToUpdate;
        }

        testCase.LastOutreachDate__c = null;
        update testCase;

        System.runAs(ownerUser) {
            postToUpdate.Body = 'This is an updated post.';
            Test.startTest();
            update postToUpdate;
            Test.stopTest();
        }

        Case resultCase = [SELECT LastOutreachDate__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(Date.today(), resultCase.LastOutreachDate__c);
    }
}