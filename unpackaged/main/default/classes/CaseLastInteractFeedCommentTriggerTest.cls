@isTest
public class CaseLastInteractFeedCommentTriggerTest {
   @testSetup
    static void setup() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase;
    }
    
    @isTest
    static void testFeedCommentTriggerAsOwner() {
        Case testCase = [SELECT Id, OwnerId FROM Case LIMIT 1];
        
        Test.startTest();
        
        FeedItem feedItem = new FeedItem(
            ParentId = testCase.Id,
            Body = 'Test post'
        );
        insert feedItem;
        
        FeedComment feedComment = new FeedComment(
            FeedItemId = feedItem.Id,
            CommentBody = 'Test comment'
        );
        insert feedComment;
        
        Test.stopTest();
        
        Case updatedCase = [SELECT LastOutreachDate__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(Date.today(), updatedCase.LastOutreachDate__c, 'LastOutreachDate__c should be updated to today');
    }
    
    @isTest
    static void testFeedCommentTriggerAsNonOwner() {
        User anotherUser = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true LIMIT 1];
        
        Test.startTest();
        
        Case nonOwnerCase = new Case(
            Subject = 'Non Owner Test Case',
            Status = 'New',
            OwnerId = anotherUser.Id
        );
        insert nonOwnerCase;
        
        FeedItem feedItem = new FeedItem(
            ParentId = nonOwnerCase.Id,
            Body = 'Test post from non-owner'
        );
        insert feedItem;
        
        FeedComment feedComment = new FeedComment(
            FeedItemId = feedItem.Id,
            CommentBody = 'Test comment from non-owner'
        );
        insert feedComment;
        
        Test.stopTest();
        
        Case updatedCase = [SELECT LastOutreachDate__c FROM Case WHERE Id = :nonOwnerCase.Id];
        System.assertEquals(null, updatedCase.LastOutreachDate__c, 'LastOutreachDate__c should not be updated by non-owner');
    }
}