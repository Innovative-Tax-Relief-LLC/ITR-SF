@isTest
public class AccountUpdateBatch_Test {
    
    @testSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        
        // Account with both Opportunities and Cases
        testAccounts.add(new Account(Name = 'Test Account 1'));
        
        // Account with only Opportunities
        testAccounts.add(new Account(Name = 'Test Account 2'));
        
        // Account with only Cases
        testAccounts.add(new Account(Name = 'Test Account 3'));
        
        // Account with no related records
        testAccounts.add(new Account(Name = 'Test Account 4'));
        
        insert testAccounts;
        
        // Create Opportunities for Account 1 and 2
        List<Opportunity> testOpportunities = new List<Opportunity>();
        testOpportunities.add(new Opportunity(
            Name = 'Test Opp 1 - Old',
            AccountId = testAccounts[0].Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            CreatedDate = DateTime.now().addDays(-10)
        ));
        testOpportunities.add(new Opportunity(
            Name = 'Test Opp 1 - New',
            AccountId = testAccounts[0].Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            CreatedDate = DateTime.now().addDays(-1)
        ));
        testOpportunities.add(new Opportunity(
            Name = 'Test Opp 2',
            AccountId = testAccounts[1].Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        ));
        insert testOpportunities;
        
        // Create Cases for Account 1 and 3
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(
            Subject = 'Test Case 1 - Old',
            AccountId = testAccounts[0].Id,
            Status = 'New',
            CreatedDate = DateTime.now().addDays(-5)
        ));
        testCases.add(new Case(
            Subject = 'Test Case 1 - New',
            AccountId = testAccounts[0].Id,
            Status = 'New',
            CreatedDate = DateTime.now()
        ));
        testCases.add(new Case(
            Subject = 'Test Case 3',
            AccountId = testAccounts[2].Id,
            Status = 'New'
        ));
        insert testCases;
    }
    
    @isTest
    static void testBatchExecution() {
        // Test the batch execution
        Test.startTest();
        
        AccountUpdateBatch batch = new AccountUpdateBatch();
        Id batchJobId = Database.executeBatch(batch, 100);
        
        Test.stopTest();
        
        // Verify the batch job completed
        AsyncApexJob batchJob = [SELECT Id, Status, NumberOfErrors 
                                FROM AsyncApexJob 
                                WHERE Id = :batchJobId];
        System.assertEquals('Completed', batchJob.Status, 'Batch should complete successfully');
        System.assertEquals(0, batchJob.NumberOfErrors, 'Batch should have no errors');
        
        // Verify account updates
        List<Account> updatedAccounts = [SELECT Id, Name, Latest_Case_Created__c, Latest_Opp_Created__c,
                                        (SELECT Id FROM Opportunities ORDER BY CreatedDate DESC LIMIT 1),
                                        (SELECT Id FROM Cases ORDER BY CreatedDate DESC LIMIT 1)
                                        FROM Account 
                                        ORDER BY Name];
        
        // Account 1 - should have both fields updated
        System.assertNotEquals(null, updatedAccounts[0].Latest_Opp_Created__c, 
                              'Account 1 should have Latest_Opp_Created__c populated');
        System.assertNotEquals(null, updatedAccounts[0].Latest_Case_Created__c, 
                              'Account 1 should have Latest_Case_Created__c populated');
        System.assertEquals(updatedAccounts[0].Opportunities[0].Id, updatedAccounts[0].Latest_Opp_Created__c,
                           'Latest_Opp_Created__c should match the most recent opportunity');
        System.assertEquals(updatedAccounts[0].Cases[0].Id, updatedAccounts[0].Latest_Case_Created__c,
                           'Latest_Case_Created__c should match the most recent case');
        
        // Account 2 - should have only Latest_Opp_Created__c updated
        System.assertNotEquals(null, updatedAccounts[1].Latest_Opp_Created__c, 
                              'Account 2 should have Latest_Opp_Created__c populated');
        System.assertEquals(null, updatedAccounts[1].Latest_Case_Created__c, 
                           'Account 2 should not have Latest_Case_Created__c populated');
        
        // Account 3 - should have only Latest_Case_Created__c updated
        System.assertEquals(null, updatedAccounts[2].Latest_Opp_Created__c, 
                           'Account 3 should not have Latest_Opp_Created__c populated');
        System.assertNotEquals(null, updatedAccounts[2].Latest_Case_Created__c, 
                              'Account 3 should have Latest_Case_Created__c populated');
        
        // Account 4 - should have neither field updated
        System.assertEquals(null, updatedAccounts[3].Latest_Opp_Created__c, 
                           'Account 4 should not have Latest_Opp_Created__c populated');
        System.assertEquals(null, updatedAccounts[3].Latest_Case_Created__c, 
                           'Account 4 should not have Latest_Case_Created__c populated');
    }
    
    @isTest
    static void testQueryLocator() {
        // Test the start method directly
        AccountUpdateBatch batch = new AccountUpdateBatch();
        Database.BatchableContext bc = new TestBatchableContext();
        
        Test.startTest();
        Database.QueryLocator ql = batch.start(bc);
        Test.stopTest();
        
        // Verify the query locator is not null
        System.assertNotEquals(null, ql, 'QueryLocator should not be null');
        
        // Verify we can iterate through the results
        Database.QueryLocatorIterator it = ql.iterator();
        Integer recordCount = 0;
        while(it.hasNext()) {
            it.next();
            recordCount++;
        }
        
        System.assertEquals(4, recordCount, 'Should return 4 account records');
    }
    
    @isTest
    static void testExecuteMethod() {
        // Test the execute method directly
        AccountUpdateBatch batch = new AccountUpdateBatch();
        Database.BatchableContext bc = new TestBatchableContext();
        
        // Get test accounts with related records
        List<Account> testAccounts = [SELECT Id, Name, Latest_Case_Created__c, Latest_Opp_Created__c,
                                     (SELECT Id FROM Opportunities ORDER BY CreatedDate DESC LIMIT 1),
                                     (SELECT Id FROM Cases ORDER BY CreatedDate DESC LIMIT 1)
                                     FROM Account 
                                     WHERE Name IN ('Test Account 1', 'Test Account 4')];
        
        Test.startTest();
        batch.execute(bc, testAccounts);
        Test.stopTest();
        
        // Verify updates were applied
        List<Account> updatedAccounts = [SELECT Id, Name, Latest_Case_Created__c, Latest_Opp_Created__c
                                        FROM Account 
                                        WHERE Id IN :testAccounts
                                        ORDER BY Name];
        
        // First account should be updated, second should remain null
        System.assertNotEquals(null, updatedAccounts[0].Latest_Opp_Created__c, 
                              'Test Account 1 should have Latest_Opp_Created__c populated');
        System.assertNotEquals(null, updatedAccounts[0].Latest_Case_Created__c, 
                              'Test Account 1 should have Latest_Case_Created__c populated');
        System.assertEquals(null, updatedAccounts[1].Latest_Opp_Created__c, 
                           'Test Account 4 should not have Latest_Opp_Created__c populated');
        System.assertEquals(null, updatedAccounts[1].Latest_Case_Created__c, 
                           'Test Account 4 should not have Latest_Case_Created__c populated');
    }
    
    @isTest
    static void testFinishMethod() {
        // Test the finish method
        AccountUpdateBatch batch = new AccountUpdateBatch();
        Database.BatchableContext bc = new TestBatchableContext();
        
        Test.startTest();
        batch.finish(bc);
        Test.stopTest();
        
        // Since finish only does System.debug, we just verify it runs without error
        // In a real scenario, you might want to test any additional logic in finish()
        System.assert(true, 'Finish method should execute without errors');
    }
    
    // Helper class for testing
    private class TestBatchableContext implements Database.BatchableContext {
        public Id getJobId() {
            return '01p000000000000';
        }
        
        public Id getChildJobId() {
            return '01p000000000001';
        }
    }
}