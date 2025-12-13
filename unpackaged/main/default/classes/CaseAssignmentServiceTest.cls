@IsTest
private class CaseAssignmentServiceTest {
    
    @TestSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String ts = String.valueOf(System.currentTimeMillis());
        
        User caseOwnerUser = new User(
            FirstName = 'User',
            LastName  = 'CaseOwner',
            Email = 'caseowner' + ts + '@test.com',
            Username = 'caseowner' + ts + '@test.com',
            Alias = 'cown',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        User taxProUser = new User(
            FirstName = 'User',
            LastName  = 'TaxPro',
            Email = 'taxpro' + ts + '@test.com',
            Username = 'taxpro' + ts + '@test.com',
            Alias = 'tpro',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        insert new List<User>{ caseOwnerUser, taxProUser };
        
        List<Case_User_Pool__c> pools = new List<Case_User_Pool__c>{
            new Case_User_Pool__c(
                Owner_Type__c = 'Case Owner',
                User__c = caseOwnerUser.Id,
                Stage__c = 'Stage 1',
                Number_Cases_Open__c = 0,
                Automate__c = true
            ),
            new Case_User_Pool__c(
                Owner_Type__c = 'Case Owner',
                User__c = caseOwnerUser.Id,
                Stage__c = 'Stage 3',
                Number_Cases_Open__c = 1,
                Automate__c = true
            ),
            new Case_User_Pool__c(
                Owner_Type__c = 'Tax Pro',
                User__c = taxProUser.Id,
                Stage__c = 'Stage 1',
                Number_Cases_Open__c = 0,
                Automate__c = true
            ),
            new Case_User_Pool__c(
                Owner_Type__c = 'Tax Pro',
                User__c = taxProUser.Id,
                Stage__c = 'Stage 3',
                Number_Cases_Open__c = 2,
                Automate__c = true
            )
        };
        insert pools;
        
        Product2 prod1 = new Product2(
            Name = 'Product Stage 1',
            Stage_Case_Owner__c = 'Stage 1',
            Stage_Tax_Pro__c = 'Stage 1',
            IsActive = true
        );
        Product2 prod3 = new Product2(
            Name = 'Product Stage 3',
            Stage_Case_Owner__c = 'Stage 3',
            Stage_Tax_Pro__c = 'Stage 3',
            IsActive = true
        );
        insert new List<Product2>{ prod1, prod3 };
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today()
        );
        insert opp;
        
        Id stdPbId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id = prod1.Id,
            UnitPrice = 100,
            IsActive = true
        );
        PricebookEntry pbe3 = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id = prod3.Id,
            UnitPrice = 200,
            IsActive = true
        );
        insert new List<PricebookEntry>{ pbe1, pbe3 };
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = prod1.Id,
            PricebookEntryId = pbe1.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        OpportunityLineItem oli3 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = prod3.Id,
            PricebookEntryId = pbe3.Id,
            Quantity = 1,
            UnitPrice = 200
        );
        insert new List<OpportunityLineItem>{ oli1, oli3 };
    }
    
    @IsTest
    static void testAssignOwnersBeforeInsert_SingleCase() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        User expectedOwner = [SELECT Id FROM User WHERE LastName = 'CaseOwner' LIMIT 1];
        User expectedTaxPro = [SELECT Id FROM User WHERE LastName = 'TaxPro' LIMIT 1];
        
        Case c = new Case(
            Subject = 'Test Case Assignment',
            Opportunity__c = opp.Id
        );
        List<Case> cases = new List<Case>{ c };
        
        Test.startTest();
        CaseAssignmentService.assignOwnersBeforeInsert(cases);
        Test.stopTest();
        
        System.assertNotEquals(null, c.OwnerId, 'Case Owner should be assigned');
        System.assertNotEquals(null, c.Enrolled_Agent__c, 'Enrolled Agent should be assigned');
        System.assertEquals(expectedOwner.Id, c.OwnerId, 'Owner should be the expected Case Owner user');
        System.assertEquals(expectedTaxPro.Id, c.Enrolled_Agent__c, 'Enrolled Agent should be the expected Tax Pro user');
    }
    
    @IsTest
    static void testAssignOwnersBeforeInsert_NoOpportunity() {
        Case c = new Case(Subject = 'Case Without Opportunity');
        List<Case> cases = new List<Case>{ c };
        
        Test.startTest();
        CaseAssignmentService.assignOwnersBeforeInsert(cases);
        Test.stopTest();
        
        System.assertEquals(null, c.OwnerId, 'Owner should not be assigned when there is no Opportunity');
        System.assertEquals(null, c.Enrolled_Agent__c, 'Enrolled Agent should not be assigned when there is no Opportunity');
    }
    
    @IsTest
    static void testAssignOwnersBeforeInsert_BulkCases() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            cases.add(new Case(
                Subject = 'Bulk Case ' + i,
                Opportunity__c = opp.Id
            ));
        }
        
        Test.startTest();
        CaseAssignmentService.assignOwnersBeforeInsert(cases);
        Test.stopTest();
        
        for (Case c : cases) {
            System.assertNotEquals(null, c.OwnerId, 'Bulk case should have an Owner assigned');
            System.assertNotEquals(null, c.Enrolled_Agent__c, 'Bulk case should have an Enrolled Agent assigned');
        }
    }

        @IsTest
    static void testAssignOwnersBeforeInsert_SyncsPoolCounters() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        User caseOwner = [SELECT Id FROM User WHERE LastName = 'CaseOwner' LIMIT 1];
    
        Case existing = new Case(
            Subject = 'Existing Open Case',
            OwnerId = caseOwner.Id
        );
        insert existing;
    
        Case_User_Pool__c pool = [
            SELECT Id, Number_Cases_Open__c
            FROM Case_User_Pool__c
            WHERE Owner_Type__c = 'Case Owner'
            AND User__c = :caseOwner.Id
            LIMIT 1
        ];
        pool.Number_Cases_Open__c = 0;
        update pool;
    
        Case toAssign = new Case(
            Subject = 'Sync Trigger Case',
            Opportunity__c = opp.Id
        );
        List<Case> cases = new List<Case>{ toAssign };
    
        Test.startTest();
        CaseAssignmentService.assignOwnersBeforeInsert(cases);
        Test.stopTest();
    
        Case_User_Pool__c updatedPool = [
            SELECT Number_Cases_Open__c
            FROM Case_User_Pool__c
            WHERE Id = :pool.Id
        ];
    
        System.assertEquals(
            1,
            updatedPool.Number_Cases_Open__c,
            'Pool counter should be synced to the actual number of open cases'
        );
    }
	
        @IsTest
    static void testIncrementCaseCounters_UpdatesPoolCounters() {
        Case_User_Pool__c ownerPool = [
            SELECT Id, User__c, Number_Cases_Open__c
            FROM Case_User_Pool__c
            WHERE Owner_Type__c = 'Case Owner'
            AND Automate__c = true
            LIMIT 1
        ];
        
        Case_User_Pool__c taxProPool = [
            SELECT Id, User__c, Number_Cases_Open__c
            FROM Case_User_Pool__c
            WHERE Owner_Type__c = 'Tax Pro'
            AND Automate__c = true
            LIMIT 1
        ];
        
        Decimal ownerBefore   = ownerPool.Number_Cases_Open__c == null ? 0 : ownerPool.Number_Cases_Open__c;
        Decimal taxProBefore  = taxProPool.Number_Cases_Open__c == null ? 0 : taxProPool.Number_Cases_Open__c;
        
        List<Case> assignedCases = new List<Case>{
            new Case(OwnerId = ownerPool.User__c),
            new Case(OwnerId = ownerPool.User__c, Enrolled_Agent__c = taxProPool.User__c)
        };
        
        Test.startTest();
        CaseCounterService.incrementCaseCounters(assignedCases);
        Test.stopTest();
        
        ownerPool = [
            SELECT Number_Cases_Open__c
            FROM Case_User_Pool__c
            WHERE Id = :ownerPool.Id
        ];
        taxProPool = [
            SELECT Number_Cases_Open__c
            FROM Case_User_Pool__c
            WHERE Id = :taxProPool.Id
        ];
        
        System.assertEquals(
            ownerBefore + 2,
            ownerPool.Number_Cases_Open__c,
            'Owner pool counter should be incremented by 2'
        );
        System.assertEquals(
            taxProBefore + 1,
            taxProPool.Number_Cases_Open__c,
            'Tax Pro pool counter should be incremented by 1'
        );
    }
}