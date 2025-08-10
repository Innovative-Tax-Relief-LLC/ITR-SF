@isTest
public class CaseNotesHistoryBatchTest {
    
    @testSetup
    static void setupTestData() {
        List<Case> testCases = new List<Case>();
        for(Integer i = 0; i < 3; i++) {
            testCases.add(new Case(
                Subject = 'Batch Test Case ' + i,
                Status = 'New',
                Origin = 'Web',
                Description = 'Test notes for case ' + i
            ));
        }
        insert testCases;
        
        Case caseWithoutNotes = new Case(
            Subject = 'Case Without Notes',
            Status = 'New',
            Origin = 'Web'
        );
        insert caseWithoutNotes;
    }
    
    @isTest
    static void testBatchExecution() {
        List<Case> allCases = [SELECT Id, Description FROM Case];
        List<Case> casesWithNotes = new List<Case>();
        
        for(Case c : allCases) {
            if(String.isNotBlank(c.Description)) {
                casesWithNotes.add(c);
            }
        }
        
        Test.startTest();
        Database.executeBatch(new CaseNotesHistoryBatch(), 200);
        Test.stopTest();
        
        List<Case> updatedCases = [SELECT Id, CaseNotesFilledDate__c, CreatedDate FROM Case WHERE Id IN :casesWithNotes];
        for(Case c : updatedCases) {
            System.assertEquals(c.CreatedDate, c.CaseNotesFilledDate__c);
        }
    }
    
    @isTest
    static void testBatchSkipsCasesWithoutNotes() {
        List<Case> allCases = [SELECT Id, Description FROM Case];
        Case caseWithoutNotes;
        
        for(Case c : allCases) {
            if(String.isBlank(c.Description)) {
                caseWithoutNotes = c;
                break;
            }
        }
        
        Test.startTest();
        Database.executeBatch(new CaseNotesHistoryBatch(), 200);
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, CaseNotesFilledDate__c FROM Case WHERE Id = :caseWithoutNotes.Id];
        System.assertEquals(null, updatedCase.CaseNotesFilledDate__c);
    }
    
    @isTest
    static void testBatchQueryLocator() {
        CaseNotesHistoryBatch batch = new CaseNotesHistoryBatch();
        Test.startTest();
        Database.QueryLocator ql = batch.start(null);
        Test.stopTest();
        
        System.assertNotEquals(null, ql);
    }
}