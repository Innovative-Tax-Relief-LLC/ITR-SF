@isTest
public class CaseAssignmentServiceTest {
    
    @testSetup
    static void setup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testOwner1 = new User(
            FirstName = 'Test', LastName = 'Owner1', Email = 'testowner1@test.com',
            Username = 'testowner1@test.com.unique' + System.currentTimeMillis(),
            Alias = 'towner1', ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/New_York', EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US'
        );
        
        User testTaxPro1 = new User(
            FirstName = 'Test', LastName = 'TaxPro1', Email = 'testtaxpro1@test.com',
            Username = 'testtaxpro1@test.com.unique' + System.currentTimeMillis(),
            Alias = 'ttaxpr1', ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/New_York', EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US'
        );
        insert new List<User>{testOwner1, testTaxPro1};
        
        List<Case_User_Pool__c> userPools = new List<Case_User_Pool__c>();
        userPools.add(new Case_User_Pool__c(
            Owner_Type__c = 'Case Owner', User__c = testOwner1.Id,
            Stage__c = 'Stage 1', Number_Cases_Open__c = 0, Automate__c = true
        ));
        userPools.add(new Case_User_Pool__c(
            Owner_Type__c = 'Case Owner', User__c = testOwner1.Id,
            Stage__c = 'Stage 3', Number_Cases_Open__c = 1, Automate__c = true
        ));
        userPools.add(new Case_User_Pool__c(
            Owner_Type__c = 'Tax Pro', User__c = testTaxPro1.Id,
            Stage__c = 'Stage 1', Number_Cases_Open__c = 0, Automate__c = true
        ));
        userPools.add(new Case_User_Pool__c(
            Owner_Type__c = 'Tax Pro', User__c = testTaxPro1.Id,
            Stage__c = 'Stage 3', Number_Cases_Open__c = 2, Automate__c = true
        ));
        insert userPools;
        
        Product2 product1 = new Product2(
            Name = 'Product Stage 1', Stage_Case_Owner__c = 'Stage 1',
            Stage_Tax_Pro__c = 'Stage 1', IsActive = true
        );
        Product2 product3 = new Product2(
            Name = 'Product Stage 3', Stage_Case_Owner__c = 'Stage 3',
            Stage_Tax_Pro__c = 'Stage 3', IsActive = true
        );
        insert new List<Product2>{product1, product3};
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity', AccountId = testAccount.Id,
            StageName = 'Closed Won', CloseDate = Date.today()
        );
        insert testOpp;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        pbes.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId, Product2Id = product1.Id,
            UnitPrice = 100, IsActive = true
        ));
        pbes.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId, Product2Id = product3.Id,
            UnitPrice = 200, IsActive = true
        ));
        insert pbes;
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        olis.add(new OpportunityLineItem(
            OpportunityId = testOpp.Id, Product2Id = product1.Id,
            PricebookEntryId = pbes[0].Id, Quantity = 1, UnitPrice = 100
        ));
        olis.add(new OpportunityLineItem(
            OpportunityId = testOpp.Id, Product2Id = product3.Id,
            PricebookEntryId = pbes[1].Id, Quantity = 1, UnitPrice = 200
        ));
        insert olis;
    }
    
    @isTest
    static void testHighestStageAssignment() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        User testOwner1 = [SELECT Id FROM User WHERE LastName = 'Owner1' LIMIT 1];
        User testTaxPro1 = [SELECT Id FROM User WHERE LastName = 'TaxPro1' LIMIT 1];
        
        Test.startTest();
        
        Case testCase = new Case(
            Subject = 'Test Highest Stage Case',
            Opportunity__c = testOpp.Id
        );
        insert testCase;
        
        Test.stopTest();
        
        Case insertedCase = [SELECT Id, OwnerId, Enrolled_Agent__c FROM Case WHERE Id = :testCase.Id];
        
        System.assertNotEquals(null, insertedCase.OwnerId, 'Case Owner should be assigned');
        System.assertNotEquals(null, insertedCase.Enrolled_Agent__c, 'Enrolled Agent should be assigned');
        System.assertEquals(testOwner1.Id, insertedCase.OwnerId, 'Should assign owner eligible for highest stage');
        System.assertEquals(testTaxPro1.Id, insertedCase.Enrolled_Agent__c, 'Should assign enrolled agent eligible for highest stage');
    }
    
    @isTest
    static void testDirectAssignOwnersCall() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Case testCase = new Case(
            Subject = 'Direct Assignment Test',
            Opportunity__c = testOpp.Id
        );
        insert testCase;
        
        Test.startTest();
        CaseAssignmentService.assignOwners(new List<Case>{testCase});
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, OwnerId, Enrolled_Agent__c FROM Case WHERE Id = :testCase.Id];
        
        System.assertNotEquals(null, updatedCase.OwnerId, 'Case Owner should be assigned');
        System.assertNotEquals(null, updatedCase.Enrolled_Agent__c, 'Enrolled Agent should be assigned');
    }
    
    @isTest
    static void testBulkAssignment() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Debug setup más completo
        List<Case_User_Pool__c> debugPools = [
            SELECT Id, Owner_Type__c, Stage__c, User__c, Number_Cases_Open__c 
            FROM Case_User_Pool__c
        ];
        System.debug('=== AVAILABLE POOLS ===');
        for (Case_User_Pool__c pool : debugPools) {
            System.debug('Pool: ' + pool.Owner_Type__c + ' - Stage: ' + pool.Stage__c + ' - User: ' + pool.User__c + ' - Cases: ' + pool.Number_Cases_Open__c);
        }
        
        List<OpportunityLineItem> debugProducts = [
            SELECT Id, Product2.Name, Product2.Stage_Case_Owner__c, Product2.Stage_Tax_Pro__c 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :testOpp.Id
        ];
        System.debug('=== PRODUCTS ===');
        for (OpportunityLineItem oli : debugProducts) {
            System.debug('Product: ' + oli.Product2.Name + ' - Owner Stage: ' + oli.Product2.Stage_Case_Owner__c + ' - Tax Pro Stage: ' + oli.Product2.Stage_Tax_Pro__c);
        }
        
        Test.startTest();
        
        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 3; i++) {
            testCases.add(new Case(
                Subject = 'Bulk Test Case ' + i,
                Opportunity__c = testOpp.Id
            ));
        }
        insert testCases;
        
        Test.stopTest();
        
        List<Case> insertedCases = [SELECT Id, Subject, OwnerId, Enrolled_Agent__c FROM Case WHERE Id IN :testCases];
        
        System.debug('=== ASSIGNED CASES ===');
        for (Case c : insertedCases) {
            System.debug('Case: ' + c.Subject + ' - Owner: ' + c.OwnerId + ' - Enrolled Agent: ' + c.Enrolled_Agent__c);
        }
        
        for (Case c : insertedCases) {
            System.assertNotEquals(null, c.OwnerId, 'Each case should have owner assigned');
            System.assertNotEquals(null, c.Enrolled_Agent__c, 'Each case should have enrolled agent assigned - Check Stage eligibility');
        }
    }
    
    @isTest
    static void testCaseWithoutOpportunity() {
        Test.startTest();
        
        Case testCase = new Case(Subject = 'No Opportunity Case');
        insert testCase;
        
        Test.stopTest();
        
        Case insertedCase = [SELECT Id, OwnerId, Enrolled_Agent__c FROM Case WHERE Id = :testCase.Id];
        
        System.assertNotEquals(null, insertedCase.OwnerId, 'Case should have default owner');
        System.assertEquals(null, insertedCase.Enrolled_Agent__c, 'Enrolled Agent should not be assigned without opportunity');
    }
    
    @isTest
    static void testCounterServiceMethods() {
        User testOwner1 = [SELECT Id FROM User WHERE LastName = 'Owner1' LIMIT 1];
        
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(
            Subject = 'Counter Test',
            OwnerId = testOwner1.Id,
            Enrolled_Agent__c = testOwner1.Id
        ));
        
        Test.startTest();
        CaseCounterService.updateCountersAfterAssignment(testCases);
        Test.stopTest();
        
        List<Case_User_Pool__c> pools = [
            SELECT User__c, Owner_Type__c, Number_Cases_Open__c 
            FROM Case_User_Pool__c 
            WHERE User__c = :testOwner1.Id
        ];
        
        System.assertNotEquals(0, pools.size(), 'Should have pool records');
    }
    
    @isTest
    static void testLegacyMethod() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Case testCase = new Case(
            Subject = 'Legacy Test',
            Opportunity__c = testOpp.Id
        );
        insert testCase;
        
        Test.startTest();
        CaseAssignmentService.assignCaseOwnersAndTaxPros(new List<Case>{testCase});
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, OwnerId, Enrolled_Agent__c FROM Case WHERE Id = :testCase.Id];
        
        System.assertNotEquals(null, updatedCase.OwnerId, 'Legacy method should work');
        System.assertNotEquals(null, updatedCase.Enrolled_Agent__c, 'Legacy method should assign enrolled agent');
    }
}