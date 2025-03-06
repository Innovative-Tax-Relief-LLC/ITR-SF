@isTest
public class LeadDistributionControllerTest {
    
    @testSetup
    static void setupTestData() {
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
     
        insert criteria;
    }

    @IsTest
    static void testFetchRecordForDistribution() {
        
        insert new Lead(FirstName = 'Matching', LastName = 'Lead', Company = 'Test Company', IsConverted = false);
        insert new Account(FirstName = 'Matching', LastName = 'Account', AccountSource = 'Website', Site = 'Federal');

        sObject result;

        Test.startTest();
        result = LeadDistributionController.fetchRecordForDistribution();
        Test.stopTest();

        System.assertNotEquals(null, result, 'A lead should have been returned.');
        System.assert(result instanceof Account, 'The returned object should be an Account.');
    }
    

}