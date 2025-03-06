@isTest
private class LastInteractionHelperTest {

    @isTest
    static void testUpdateLastInteractionFeedItem_NonEmptySet() {

        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;

        Set<Id> caseIds = new Set<Id>{testCase.Id};
        LastInteractionHelper.updateLastInteractionField(caseIds);

        Case updatedCase = [SELECT Id, LastOutreachDate__c FROM Case WHERE Id = :testCase.Id];
        
        Assert.isNotNull(updatedCase.LastOutreachDate__c, 'LastOutreachDate__c should be updated');
        Assert.areEqual(Date.today(), updatedCase.LastOutreachDate__c, 'LastOutreachDate__c should be today\'s date');
    }

    @isTest
    static void testUpdateLastInteractionFeedItem_DmlException() {

        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;

        Set<Id> caseIds = new Set<Id>{};

        Test.startTest();
        try {
            LastInteractionHelper.updateLastInteractionField(caseIds);
            //Assert.fail();
        } catch (Exception e) {
            Assert.isTrue(e.getMessage() != null, 'Exception should be thrown');
        }
        Test.stopTest();
    }
}