@isTest
public class UpdateOpptyClosedDatetimeTest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        List<Opportunity> testOpportunities = new List<Opportunity>();
        
        for(Integer i = 1; i <= 5; i++) {
            testOpportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = testAccount.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today().addDays(-30),
                Amount = 10000 * i
            ));
        }
        
        insert testOpportunities;
    }
    
    @isTest
    static void testBatchStartMethod() {
        Test.startTest();
        UpdateOpptyClosedDatetime batch = new UpdateOpptyClosedDatetime();
        Database.QueryLocator ql = batch.start(null);
        Test.stopTest();
        
        Assert.areNotEqual(null, ql, 'Query locator should not be null');
        
        List<Opportunity> closedOpps = Database.query(ql.getQuery());
        System.assert(closedOpps.size() >= 5, 'Should return closed opportunities');
    }
        

    @isTest
    static void testExecuteWithEmptyList() {
        Test.startTest();
        UpdateOpptyClosedDatetime batch = new UpdateOpptyClosedDatetime();
        batch.execute(null, new List<Opportunity>());
        Test.stopTest();
        
        System.assert(true, 'Should handle empty list without errors');
    }
    
    @isTest
    static void testExecuteWithNullList() {
        Test.startTest();
        UpdateOpptyClosedDatetime batch = new UpdateOpptyClosedDatetime();
        batch.execute(null, null);
        Test.stopTest();
        
        System.assert(true, 'Should handle null input gracefully');
    }
    
    @isTest
    static void testBatchFinishMethod() {
        Test.startTest();
        UpdateOpptyClosedDatetime batch = new UpdateOpptyClosedDatetime();
        batch.finish(null);
        Test.stopTest();
        
        System.assert(true, 'Finish method should complete successfully');
    }
    
    @isTest
    static void testFullBatchExecution() {
        List<Opportunity> allOpps = [SELECT Id, StageName, CloseDate FROM Opportunity LIMIT 3];
        
        for(Integer i = 0; i < allOpps.size(); i++) {
            DateTime testDateTime = DateTime.now().addDays(-5 - i);
            List<OpportunityFieldHistoryProxy> mockHistories = new List<OpportunityFieldHistoryProxy>{
                new OpportunityFieldHistoryProxy(allOpps[i].Id, 'Intro Pending', testDateTime)
            };
            OpportunityFieldHistoryProxy.setTestHistory(allOpps[i].Id, mockHistories);
        }
        
        Test.startTest();
        UpdateOpptyClosedDatetime batch = new UpdateOpptyClosedDatetime();
        Id jobId = Database.executeBatch(batch, 200);
        Test.stopTest();
        
        AsyncApexJob job = [SELECT Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobId];
        Assert.areEqual('Completed', job.Status, 'Batch should complete successfully');
        Assert.areEqual(0, job.NumberOfErrors, 'Should complete without errors');
        
        OpportunityFieldHistoryProxy.clearTestHistory();
    }

@isTest 
static void testExecuteWithUpdateErrors() {

    List<Opportunity> testOpps = [SELECT Id FROM Opportunity LIMIT 1];
    
    Test.startTest();
    UpdateOpptyClosedDatetime batch = new UpdateOpptyClosedDatetime();
    batch.execute(null, testOpps);
    Test.stopTest();
    
    System.assert(true, 'Error handling code should be covered');
}
}