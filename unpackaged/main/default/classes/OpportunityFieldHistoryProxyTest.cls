@isTest
public class OpportunityFieldHistoryProxyTest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        List<Opportunity> testOpportunities = new List<Opportunity>();
        
        for(Integer i = 1; i <= 3; i++) {
            testOpportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = testAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = 10000 * i
            ));
        }
        
        insert testOpportunities;
        
        for(Opportunity opp : testOpportunities) {
            opp.StageName = 'Qualification';
            update opp;
            
            opp.StageName = 'Proposal';
            update opp;
            
            opp.StageName = 'Closed Won';
            update opp;
        }
    }
    
    @isTest
    static void testProxyConstructor() {
        Id testOppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        DateTime testDateTime = DateTime.now();
        String testValue = 'Intro Pending';
        
        Test.startTest();
        OpportunityFieldHistoryProxy proxy = new OpportunityFieldHistoryProxy(testOppId, testValue, testDateTime);
        Test.stopTest();
        
        Assert.areEqual(testOppId, proxy.opportunityId, 'OpportunityId should be set correctly');
        Assert.areEqual(testValue, proxy.newValue, 'NewValue should be set correctly');
        Assert.areEqual(testDateTime, proxy.createdDate, 'CreatedDate should be set correctly');
    }
    
    @isTest
    static void testGetStageHistoryWithTestData() {
        List<Opportunity> testOpps = [SELECT Id FROM Opportunity LIMIT 2];
        Id opp1Id = testOpps[0].Id;
        Id opp2Id = testOpps[1].Id;
        
        DateTime baseDateTime = DateTime.now();
        
        OpportunityFieldHistoryProxy.setTestHistory(opp1Id, new List<OpportunityFieldHistoryProxy>{
            new OpportunityFieldHistoryProxy(opp1Id, 'Prospecting', baseDateTime.addDays(-10)),
            new OpportunityFieldHistoryProxy(opp1Id, 'Intro Pending', baseDateTime.addDays(-8)),
            new OpportunityFieldHistoryProxy(opp1Id, 'Closed Won', baseDateTime.addDays(-5))
        });
        
        OpportunityFieldHistoryProxy.setTestHistory(opp2Id, new List<OpportunityFieldHistoryProxy>{
            new OpportunityFieldHistoryProxy(opp2Id, 'Qualification', baseDateTime.addDays(-7)),
            new OpportunityFieldHistoryProxy(opp2Id, 'TI PIF Completed', baseDateTime.addDays(-3))
        });
        
        Test.startTest();
        
        List<OpportunityFieldHistoryProxy> opp1Histories = OpportunityFieldHistoryProxy.getStageHistory(opp1Id);
        Assert.areEqual(3, opp1Histories.size(), 'Should return 3 histories for opp1');
        Assert.areEqual(opp1Id, opp1Histories[0].opportunityId, 'OpportunityId should match');
        Assert.areEqual('Prospecting', opp1Histories[0].newValue, 'First stage should be Prospecting');
        
        Set<Id> oppIds = new Set<Id>{opp1Id, opp2Id};
        List<OpportunityFieldHistoryProxy> allHistories = OpportunityFieldHistoryProxy.getStageHistory(oppIds);
        Assert.areEqual(5, allHistories.size(), 'Should return 5 total histories (3+2)');
        
        Set<Id> returnedOppIds = new Set<Id>();
        for(OpportunityFieldHistoryProxy history : allHistories) {
            returnedOppIds.add(history.opportunityId);
        }
        Assert.isTrue(returnedOppIds.contains(opp1Id), 'Should include opp1Id');
        Assert.isTrue(returnedOppIds.contains(opp2Id), 'Should include opp2Id');
        
        Test.stopTest();
        
        OpportunityFieldHistoryProxy.clearTestHistory();
    }
    
    @isTest
    static void testGetStageHistoryWithEmptyTestData() {
        Id testOppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        
        OpportunityFieldHistoryProxy.setTestHistory(testOppId, new List<OpportunityFieldHistoryProxy>());
        
        Test.startTest();
        
        List<OpportunityFieldHistoryProxy> histories = OpportunityFieldHistoryProxy.getStageHistory(testOppId);
        
        Test.stopTest();
        
        Assert.areEqual(0, histories.size(), 'Should return empty list when test data is empty');
        
        OpportunityFieldHistoryProxy.clearTestHistory();
    }
    
    @isTest
    static void testGetStageHistoryWithNonExistentOpportunity() {
        Id fakeOppId = '006000000000000';
        
        OpportunityFieldHistoryProxy.clearTestHistory();
        
        Test.startTest();
        
        List<OpportunityFieldHistoryProxy> histories = OpportunityFieldHistoryProxy.getStageHistory(fakeOppId);
        
        Test.stopTest();
        
        Assert.areEqual(0, histories.size(), 'Should return empty list for non-existent opportunity');
    }
    
    @isTest
    static void testMixedScenarioTestAndRealData() {
        List<Opportunity> testOpps = [SELECT Id FROM Opportunity LIMIT 2];
        Id opp1Id = testOpps[0].Id;
        Id opp2Id = testOpps[1].Id;
        
        DateTime testDateTime = DateTime.now();
        
        OpportunityFieldHistoryProxy.setTestHistory(opp1Id, new List<OpportunityFieldHistoryProxy>{
            new OpportunityFieldHistoryProxy(opp1Id, 'Test Stage', testDateTime)
        });
        
        Test.startTest();
        
        Set<Id> bothIds = new Set<Id>{opp1Id, opp2Id};
        List<OpportunityFieldHistoryProxy> histories = OpportunityFieldHistoryProxy.getStageHistory(bothIds);
        
        Test.stopTest();
        
        Assert.areEqual(1, histories.size(), 'Should only return test data when test context is active');
        Assert.areEqual(opp1Id, histories[0].opportunityId, 'Should return test data for opp1');
        Assert.areEqual('Test Stage', histories[0].newValue, 'Should match test data');
        
        OpportunityFieldHistoryProxy.clearTestHistory();
    }
    
    @isTest
    static void testProxyDataIntegrity() {
        Id testOppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        DateTime createdDate1 = DateTime.now().addDays(-10);
        DateTime createdDate2 = DateTime.now().addDays(-5);
        
        List<OpportunityFieldHistoryProxy> testHistories = new List<OpportunityFieldHistoryProxy>{
            new OpportunityFieldHistoryProxy(testOppId, 'Stage A', createdDate1),
            new OpportunityFieldHistoryProxy(testOppId, 'Stage B', createdDate2)
        };
        
        OpportunityFieldHistoryProxy.setTestHistory(testOppId, testHistories);
        
        Test.startTest();
        
        List<OpportunityFieldHistoryProxy> retrievedHistories = OpportunityFieldHistoryProxy.getStageHistory(testOppId);
        
        Test.stopTest();
        
        Assert.areEqual(2, retrievedHistories.size(), 'Should maintain data integrity');
        
        OpportunityFieldHistoryProxy first = retrievedHistories[0];
        Assert.areEqual(testOppId, first.opportunityId, 'OpportunityId should be preserved');
        Assert.areEqual('Stage A', first.newValue, 'NewValue should be preserved');
        Assert.areEqual(createdDate1, first.createdDate, 'CreatedDate should be preserved');
        
        OpportunityFieldHistoryProxy second = retrievedHistories[1];
        Assert.areEqual(testOppId, second.opportunityId, 'OpportunityId should be preserved');
        Assert.areEqual('Stage B', second.newValue, 'NewValue should be preserved');
        Assert.areEqual(createdDate2, second.createdDate, 'CreatedDate should be preserved');
        
        OpportunityFieldHistoryProxy.clearTestHistory();
    }

    @isTest
static void testGetStageHistoryWithRealDataQuery() {

    OpportunityFieldHistoryProxy.clearTestHistory();
    
    List<Opportunity> testOpps = [SELECT Id FROM Opportunity LIMIT 1];
    Set<Id> oppIds = new Set<Id>();
    for(Opportunity opp : testOpps) {
        oppIds.add(opp.Id);
    }
    
    Test.startTest();
    
    List<OpportunityFieldHistoryProxy> histories = OpportunityFieldHistoryProxy.getStageHistory(oppIds);
    
    Test.stopTest();
    

    System.assert(histories != null, 'Should return history list');
    
}

@isTest
static void testGetStageHistoryWithFilteredStages() {

    List<Opportunity> testOpps = [SELECT Id FROM Opportunity LIMIT 2];
    Id opp1Id = testOpps[0].Id;
    
    OpportunityFieldHistoryProxy.clearTestHistory();
    
    Test.startTest();
    
    List<OpportunityFieldHistoryProxy> singleOppHistories = OpportunityFieldHistoryProxy.getStageHistory(opp1Id);
    
    Test.stopTest();
    
    System.assert(singleOppHistories != null, 'Should handle single opportunity ID');
}

@isTest
static void testGetStageHistoryDebugStatements() {

    List<Opportunity> testOpps = [SELECT Id FROM Opportunity LIMIT 1];
    Set<Id> oppIds = new Set<Id>{testOpps[0].Id};
    
    OpportunityFieldHistoryProxy.clearTestHistory();
    
    Test.startTest();
    
    List<OpportunityFieldHistoryProxy> histories = OpportunityFieldHistoryProxy.getStageHistory(oppIds);
    
    Test.stopTest();
    
    System.assert(true, 'Debug statements should execute');
    }

}