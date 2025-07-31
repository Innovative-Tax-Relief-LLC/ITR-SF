@isTest
public class CaseCounterServiceTest {
    
    @testSetup
    static void setup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser1 = new User(
            FirstName = 'Counter', LastName = 'User1', Email = 'counteruser1@test.com',
            Username = 'counteruser1@test.com.unique' + System.currentTimeMillis(),
            Alias = 'cuser1', ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/New_York', EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US'
        );
        
        User testUser2 = new User(
            FirstName = 'Counter', LastName = 'User2', Email = 'counteruser2@test.com',
            Username = 'counteruser2@test.com.unique' + System.currentTimeMillis(),
            Alias = 'cuser2', ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/New_York', EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US'
        );
        insert new List<User>{testUser1, testUser2};
        
        List<Case_User_Pool__c> userPools = new List<Case_User_Pool__c>();
        
        userPools.add(new Case_User_Pool__c(
            Owner_Type__c = 'Case Owner', User__c = testUser1.Id,
            Stage__c = 'Stage 1', Number_Cases_Open__c = 0, Automate__c = true
        ));
        
        userPools.add(new Case_User_Pool__c(
            Owner_Type__c = 'Tax Pro', User__c = testUser1.Id,
            Stage__c = 'Stage 1', Number_Cases_Open__c = 0, Automate__c = true
        ));
        
        userPools.add(new Case_User_Pool__c(
            Owner_Type__c = 'Case Owner', User__c = testUser2.Id,
            Stage__c = 'Stage 2', Number_Cases_Open__c = 5, Automate__c = true
        ));
        
        userPools.add(new Case_User_Pool__c(
            Owner_Type__c = 'Tax Pro', User__c = testUser2.Id,
            Stage__c = 'Stage 2', Number_Cases_Open__c = 3, Automate__c = true
        ));
        
        insert userPools;
    }
    
    @isTest
    static void testGetCurrentUserPools() {
        Test.startTest();
        Map<String, Case_User_Pool__c> userPoolMap = CaseCounterService.getCurrentUserPools();
        Test.stopTest();
        
        System.assertNotEquals(0, userPoolMap.size(), 'Should return user pools');
        
        for (String key : userPoolMap.keySet()) {
            System.assert(key.contains('_'), 'Key should contain underscores: ' + key);
            List<String> keyParts = key.split('_');
            System.assertEquals(3, keyParts.size(), 'Key should have 3 parts: Owner_Type + Stage + User_c. Found: ' + keyParts.size() + ' in key: ' + key);
        }
    }
    
    @isTest
    static void testUpdateCountersAfterAssignment() {
        User testUser1 = [SELECT Id FROM User WHERE LastName = 'User1' LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE LastName = 'User2' LIMIT 1];
        
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(
            Subject = 'Increment Test 1',
            OwnerId = testUser1.Id,
            Enrolled_Agent__c = testUser1.Id
        ));
        testCases.add(new Case(
            Subject = 'Increment Test 2',
            OwnerId = testUser2.Id,
            Enrolled_Agent__c = testUser2.Id
        ));
        testCases.add(new Case(
            Subject = 'Increment Test 3',
            OwnerId = testUser1.Id,
            Enrolled_Agent__c = testUser2.Id
        ));
        
        Test.startTest();
        CaseCounterService.updateCountersAfterAssignment(testCases);
        Test.stopTest();
        
        List<Case_User_Pool__c> pools = [
            SELECT User__c, Owner_Type__c, Number_Cases_Open__c, Stage__c
            FROM Case_User_Pool__c 
            WHERE User__c IN (:testUser1.Id, :testUser2.Id)
            ORDER BY User__c, Owner_Type__c
        ];
        
        Map<String, Decimal> expectedCounts = new Map<String, Decimal>();
        expectedCounts.put(testUser1.Id + '_Case Owner', 2);
        expectedCounts.put(testUser1.Id + '_Tax Pro', 1);
        expectedCounts.put(testUser2.Id + '_Case Owner', 6);
        expectedCounts.put(testUser2.Id + '_Tax Pro', 5);
        
        for (Case_User_Pool__c pool : pools) {
            String key = pool.User__c + '_' + pool.Owner_Type__c;
            Decimal expected = expectedCounts.get(key);
            if (expected != null) {
                System.assertEquals(expected, pool.Number_Cases_Open__c, 
                    'Counter should be correct for ' + key + ' in stage ' + pool.Stage__c);
            }
        }
    }
    
    @isTest
    static void testRecalculateAllCounters() {
        User testUser1 = [SELECT Id FROM User WHERE LastName = 'User1' LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE LastName = 'User2' LIMIT 1];
        
        List<Case> realCases = new List<Case>();
        for (Integer i = 0; i < 4; i++) {
            realCases.add(new Case(
                Subject = 'Real Case ' + i,
                OwnerId = testUser1.Id,
                Enrolled_Agent__c = testUser2.Id
            ));
        }
        insert realCases;
        
        Test.startTest();
        CaseCounterService.recalculateAllCounters();
        Test.stopTest();
        
        List<Case_User_Pool__c> pools = [
            SELECT User__c, Owner_Type__c, Number_Cases_Open__c 
            FROM Case_User_Pool__c 
            WHERE User__c IN (:testUser1.Id, :testUser2.Id)
        ];
        
        for (Case_User_Pool__c pool : pools) {
            if (pool.User__c == testUser1.Id && pool.Owner_Type__c == 'Case Owner') {
                System.assertEquals(4, pool.Number_Cases_Open__c, 'User1 should own 4 cases');
            } else if (pool.User__c == testUser2.Id && pool.Owner_Type__c == 'Tax Pro') {
                System.assertEquals(4, pool.Number_Cases_Open__c, 'User2 should be enrolled agent on 4 cases');
            }
        }
    }
    
    @isTest
    static void testDecrementCountersForClosedCases() {
        User testUser1 = [SELECT Id FROM User WHERE LastName = 'User1' LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE LastName = 'User2' LIMIT 1];
        
        List<Case> casesToClose = new List<Case>();
        casesToClose.add(new Case(
            Subject = 'Case to Close 1',
            OwnerId = testUser1.Id,
            Enrolled_Agent__c = testUser1.Id
        ));
        casesToClose.add(new Case(
            Subject = 'Case to Close 2',
            OwnerId = testUser2.Id,
            Enrolled_Agent__c = testUser2.Id
        ));
        
        Test.startTest();
        CaseCounterService.decrementCountersForClosedCases(casesToClose);
        Test.stopTest();
        
        List<Case_User_Pool__c> pools = [
            SELECT User__c, Owner_Type__c, Number_Cases_Open__c 
            FROM Case_User_Pool__c 
            WHERE User__c IN (:testUser1.Id, :testUser2.Id)
        ];
        
        for (Case_User_Pool__c pool : pools) {
            System.assert(pool.Number_Cases_Open__c >= 0, 'Counter should not be negative');
            
            if (pool.User__c == testUser1.Id && pool.Owner_Type__c == 'Case Owner') {
                System.assertEquals(0, pool.Number_Cases_Open__c, 'User1 case owner count should be 0');
            } else if (pool.User__c == testUser2.Id && pool.Owner_Type__c == 'Case Owner') {
                System.assertEquals(4, pool.Number_Cases_Open__c, 'User2 case owner count should be 4');
            }
        }
    }
    
    @isTest
    static void testEmptyListHandling() {
        Test.startTest();
        
        CaseCounterService.updateCountersAfterAssignment(new List<Case>());
        CaseCounterService.updateCountersAfterAssignment(null);
        CaseCounterService.decrementCountersForClosedCases(new List<Case>());
        CaseCounterService.decrementCountersForClosedCases(null);
        
        Test.stopTest();
        
        System.assert(true, 'Empty list handling should not throw exceptions');
    }
    
    @isTest
    static void testLegacyMethods() {
        User testUser1 = [SELECT Id FROM User WHERE LastName = 'User1' LIMIT 1];
        
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(
            Subject = 'Legacy Test',
            OwnerId = testUser1.Id,
            Enrolled_Agent__c = testUser1.Id
        ));
        
        Test.startTest();
        
        CaseCounterService.updateCaseCounters();
        CaseCounterService.incrementCaseCounters(testCases);
        
        Test.stopTest();
        
        System.assert(true, 'Legacy methods should work');
    }
}