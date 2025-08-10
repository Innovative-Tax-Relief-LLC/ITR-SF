@isTest
public class CaseNotesHandlerTest {
  
  @testSetup
  static void setupTestData() {
      List<Case> testCases = new List<Case>();
      for(Integer i = 0; i < 3; i++) {
          testCases.add(new Case(
              Subject = 'Test Case ' + i,
              Status = 'New',
              Origin = 'Web'
          ));
      }
      insert testCases;
  }
  
  @isTest
  static void testCaseNotesChangeFromBlankToFilled() {
      List<Case> cases = [SELECT Id, Description, CaseNotesFilledDate__c FROM Case];
      
      Test.startTest();
      for(Case c : cases) {
          c.Description = 'Notes added';
      }
      update cases;
      Test.stopTest();
      
      List<Case> updatedCases = [SELECT Id, CaseNotesFilledDate__c FROM Case WHERE Id IN :cases];
      for(Case c : updatedCases) {
          System.assertNotEquals(null, c.CaseNotesFilledDate__c);
      }
  }
  
  @isTest
  static void testCaseNotesFilledOnInsert() {
      Test.startTest();
      List<Case> newCases = new List<Case>();
      for(Integer i = 0; i < 3; i++) {
          newCases.add(new Case(
              Subject = 'Insert Test ' + i,
              Status = 'New',
              Origin = 'Web',
              Description = 'Notes on insert'
          ));
      }
      insert newCases;
      Test.stopTest();
      
      List<Case> insertedCases = [SELECT Id, CaseNotesFilledDate__c FROM Case WHERE Id IN :newCases];
      for(Case c : insertedCases) {
          System.assertNotEquals(null, c.CaseNotesFilledDate__c);
      }
  }
}