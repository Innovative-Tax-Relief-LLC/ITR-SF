@isTest
public class LeadDistributionRuleControllerTest {

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

    @isTest
    static void testGetLeadDistributionRules() {
        Test.startTest();
        List<LeadDistributionRule__c> rules = LeadDistributionRuleController.getLeadDistributionRules();
        Test.stopTest();

        System.assertEquals(4, rules.size(), 'Expected 4 rules to be returned');
        System.assertEquals('Test Rule 1', rules[0].Name, 'Unexpected rule name for the first record');
    }

    @isTest
    static void testDeleteRule() {
        LeadDistributionRule__c ruleToDelete = [SELECT Id FROM LeadDistributionRule__c LIMIT 1];

        Test.startTest();
        LeadDistributionRuleController.deleteRule(ruleToDelete.Id);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM LeadDistributionRule__c WHERE Id = :ruleToDelete.Id], 'Rule was not deleted');
    }

    @isTest
    static void testSaveRule_Insert() {
        Map<String, Object> ruleData = new Map<String, Object>{
            'ruleName' => 'New Test Rule',
            'priority' => 5,
            'isActive' => true,
            'fromObject' => 'Opportunity',
            'returnObject' => 'Account',
            'returnField' => 'AccountId',
                'logic' => '{1}',
            'orderBy' => 'CreatedDate',
            'sortingDirection' => 'ASC',
            'criteria' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'objectAndFieldApiName' => 'Opportunity.Name',
                    'operator' => '=',
                    'value' => 'Test Value',
                    'id' => 1
                }
            }
        };

        Test.startTest();
        LeadDistributionRuleController.saveRule(ruleData);
        Test.stopTest();

        LeadDistributionRule__c insertedRule = [SELECT Name, Priority__c, IsActive__c FROM LeadDistributionRule__c WHERE Name = 'New Test Rule'];
        System.assertNotEquals(null, insertedRule, 'Rule was not inserted');
        System.assertEquals(5, insertedRule.Priority__c, 'Incorrect priority value');
    }

    @isTest
    static void testSaveRule_Update() {
        LeadDistributionRule__c existingRule = [SELECT Id, Name FROM LeadDistributionRule__c LIMIT 1];

        Map<String, Object> ruleData = new Map<String, Object>{
            'ruleId' => existingRule.Id,
            'ruleName' => 'Updated Rule',
            'priority' => 5,
            'isActive' => false,
            'fromObject' => 'Opportunity',
            'returnObject' => 'Account',
            'returnField' => 'AccountId',
                'logic' => '{1} AND {2}',
            'orderBy' => 'Name',
            'sortingDirection' => 'DESC',
            'criteria' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'objectAndFieldApiName' => 'Opportunity.Name',
                    'operator' => 'LIKE',
                    'value' => 'example.com',
                    'id' => 1
                },
                new Map<String, Object>{
                    'objectAndFieldApiName' => 'Opportunity.AccountId',
                    'operator' => 'IN',
                    'value' => 'SELECT AccountId FROM Case',
                    'id' => 2
                }  
            }
        };

        Test.startTest();
        LeadDistributionRuleController.saveRule(ruleData);
        Test.stopTest();

        LeadDistributionRule__c updatedRule = [SELECT Name, Priority__c, IsActive__c FROM LeadDistributionRule__c WHERE Id = :existingRule.Id];
        System.assertEquals('Updated Rule', updatedRule.Name, 'Rule was not updated');
        System.assertEquals(5, updatedRule.Priority__c, 'Incorrect priority value after update');
    }

    @isTest
    static void testGetLastPriority() {
        Test.startTest();
        Integer lastPriority = LeadDistributionRuleController.getLastPriority();
        Test.stopTest();

        System.assertEquals(4, lastPriority, 'Unexpected last priority value');
    }

    @isTest
    static void testGetRuleDetails() {
        LeadDistributionRule__c rule = [SELECT Id FROM LeadDistributionRule__c LIMIT 1];

        Test.startTest();
        LeadDistributionRuleController.LeadDistributionRuleWrapper ruleWrapper = LeadDistributionRuleController.getRuleDetails(rule.Id);
        Test.stopTest();

        System.assertNotEquals(null, ruleWrapper, 'Rule details were not returned');
        System.assertEquals(rule.Id, ruleWrapper.ruleId, 'Incorrect rule details returned');
    }
}