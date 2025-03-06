/**
 * This class contains unit tests for validating the behavior of LeadDistributionService Apex class.
 */
@isTest
private class LeadDistributionServiceTest {

    @testSetup
    static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + Math.random() + '@example.com',
            Alias = 'tuser',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert u;

        LeadDistributionRule__c rule1 = new LeadDistributionRule__c(
            Name = 'Test Rule 1',
            From_Object__c = 'Account',
            Return_Object__c = 'Account',
            Return_Field__c = 'Id',
            IsActive__c = true,
            Priority__c = 1,
            Logic__c = '{1} AND {2}',
            Order_By__c = 'CreatedDate',
            Sorting_Direction__c = 'DESC'
        );
        insert rule1;
        
        LeadDistributionRule__c rule2 = new LeadDistributionRule__c(
            Name = 'Test Rule 2',
            From_Object__c = 'Lead',
            Return_Object__c = 'Lead',
            Return_Field__c = 'Id',
            IsActive__c = true,
            Priority__c = 2,
            Logic__c = '{1} AND {2}',
            Order_By__c = 'CreatedDate',
            Sorting_Direction__c = 'ASC'
        );
        insert rule2;
        
        LeadDistributionRule__c rule3 = new LeadDistributionRule__c(
            Name = 'Test Rule 3',
            From_Object__c = 'Opportunity',
            Return_Object__c = 'Account',
            Return_Field__c = 'AccountId',
            IsActive__c = true,
            Priority__c = 3,
            Logic__c = '{1} AND {2} AND {3}',
            Order_By__c = 'CreatedDate',
            Sorting_Direction__c = 'ASC',
            Has_Not_Supported_SubQuery__c = true
        );
        insert rule3;
        
        LeadDistributionRule__c rule4 = new LeadDistributionRule__c(
            Name = 'Test Rule 4',
            From_Object__c = 'Opportunity',
            Return_Object__c = 'Account',
            Return_Field__c = 'AccountId',
            IsActive__c = true,
            Priority__c = 4,
            Logic__c = '{1}',
            Order_By__c = 'CreatedDate',
            Sorting_Direction__c = 'ASC',
            Has_Not_Supported_SubQuery__c = true
        );
        insert rule4;
        
        List<Lead_Distribution_Rule_Criteria__c> criteria =  new List<Lead_Distribution_Rule_Criteria__c>();

        Lead_Distribution_Rule_Criteria__c criterion1 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule1.Id,
            Field__c = 'AccountSource',
            Operator__c = '=',
            Value__c = 'Website',
            Order__c = 1,
            FieldType__c = 'Text'
        );
        criteria.add(criterion1);

        Lead_Distribution_Rule_Criteria__c criterion2 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule1.Id,
            Field__c = 'Site',
            Operator__c = '=',
            Value__c = 'Federal',
            Order__c = 2,
            FieldType__c = 'Text'
        );
        criteria.add(criterion2);
        
        Lead_Distribution_Rule_Criteria__c criterion3 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule2.Id,
            Field__c = 'IsConverted',
            Operator__c = '=',
            Value__c = 'false',
            Order__c = 1,
            FieldType__c = 'Boolean'
        );
        criteria.add(criterion3);

        Lead_Distribution_Rule_Criteria__c criterion4 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule2.Id,
            Field__c = 'Company',
            Operator__c = '!=',
            Value__c = '',
            Order__c = 2,
            FieldType__c = 'Text'
        );
        criteria.add(criterion4);
        
        Lead_Distribution_Rule_Criteria__c criterion5 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule2.Id,
            Field__c = 'LastName',
            Operator__c = 'LIKE',
            Value__c = 'Lead',
            Order__c = 2,
            FieldType__c = 'Text'
        );
        criteria.add(criterion5);
        
        Lead_Distribution_Rule_Criteria__c criterion6 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule3.Id,
            Field__c = 'Id',
            Operator__c = 'Not in',
            Value__c = '',
            Order__c = 1,
            FieldType__c = 'Text',
            IsSubQuery__c = true,
            SubQuery_Field__c = 'Opportunity__c',
            SubQuery__c = 'Select Opportunity__c from case where IsClosed = false'
        );
        criteria.add(criterion6);
        
        Lead_Distribution_Rule_Criteria__c criterion7 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule3.Id,
            Field__c = 'StageName',
            Operator__c = '=',
            Value__c = 'Pitch',
            Order__c = 2,
            FieldType__c = 'Text'
        );
        criteria.add(criterion7);
        
        Lead_Distribution_Rule_Criteria__c criterion8 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule3.Id,
            Field__c = 'AccountId',
            Operator__c = 'Not in',
            Value__c = '',
            Order__c = 0,
            FieldType__c = 'Text',
            IsSubQuery__c = true,
            SubQuery_Field__c = 'AccountId',
            SubQuery__c = 'SELECT AccountId  FROM Event WHERE ActivityDate > TODAY',
            Is_Not_Supported_SubQuery__c = true
        );
        criteria.add(criterion8);
        
        Lead_Distribution_Rule_Criteria__c criterion9 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule3.Id,
            Field__c = 'AccountId',
            Operator__c = 'In',
            Value__c = '',
            Order__c = 3,
            FieldType__c = 'Text',
            IsSubQuery__c = true,
            SubQuery_Field__c = 'Id',
            SubQuery__c = 'Select Id from Account'
        );
        criteria.add(criterion9);
        
        Lead_Distribution_Rule_Criteria__c criterion10 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule4.Id,
            Field__c = 'AccountId',
            Operator__c = 'In',
            Value__c = '',
            Order__c = 0,
            FieldType__c = 'Text',
            IsSubQuery__c = true,
            SubQuery_Field__c = 'Id',
            SubQuery__c = 'Select Id from Account',
            Is_Not_Supported_SubQuery__c = true
        );
        criteria.add(criterion10);
        
        Lead_Distribution_Rule_Criteria__c criterion11 = new Lead_Distribution_Rule_Criteria__c(
            Lead_Distribution_Rule__c = rule4.Id,
            Field__c = 'StageName',
            Operator__c = '=',
            Value__c = 'Qualification',
            Order__c = 1,
            FieldType__c = 'Text'
        );
        criteria.add(criterion11);
        
        insert criteria;
    }

    @IsTest
    static void testFetchRecordForDistributionFindOnFirstRule() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
        
        insert new Lead(FirstName = 'Matching', LastName = 'Lead', Company = 'Test Company', IsConverted = false);
        insert new Account(FirstName = 'Matching', LastName = 'Account', AccountSource = 'Website', Site = 'Federal');

        Test.startTest();
        sObject result = LeadDistributionService.fetchRecordForDistribution(testUser.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'A lead should have been returned.');
        System.assert(result instanceof Account, 'The returned object should be an Account.');
    }
    
    @IsTest
    static void testFetchRecordForDistributionFindOnSecondRule() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
        
        insert new Lead(FirstName = 'Matching', LastName = 'Lead Test', Company = 'Test Company', IsConverted = false);

        Test.startTest();
        sObject result = LeadDistributionService.fetchRecordForDistribution(testUser.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'A lead should have been returned.');
        System.assert(result instanceof Lead, 'The returned object should be an Lead.');
    }
    
    @IsTest
    static void testFetchRecordForDistributionFindOnThirdRule() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
        
        Account ac = new Account(FirstName = 'Matching', LastName = 'Account', AccountSource = 'Other', Site = 'State');
        insert ac;
        insert new Opportunity(Name = 'Matching Oppty', AccountId = ac.Id, StageName = 'Pitch', CloseDate = System.TODAY());

        Test.startTest();
        sObject result = LeadDistributionService.fetchRecordForDistribution(testUser.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'A lead should have been returned.');
        System.assert(result instanceof Account, 'The returned object should be an Account.');
    }
    
    @IsTest
    static void testFetchRecordForDistributionFindOnForthRule() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
        
        Account ac = new Account(FirstName = 'Matching', LastName = 'Account', AccountSource = 'Other', Site = 'State');
        insert ac;
        insert new Opportunity(Name = 'Matching Oppty', AccountId = ac.Id, StageName = 'Qualification', CloseDate = System.TODAY());

        Test.startTest();
        sObject result = LeadDistributionService.fetchRecordForDistribution(testUser.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'A lead should have been returned.');
        System.assert(result instanceof Account, 'The returned object should be an Account.');
    }
}