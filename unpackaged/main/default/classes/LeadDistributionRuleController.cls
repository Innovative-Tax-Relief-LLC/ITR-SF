public with sharing class LeadDistributionRuleController {

    @AuraEnabled(cacheable=true)
    public static List<LeadDistributionRule__c> getLeadDistributionRules() {
        return [SELECT Id, Name, Priority__c, From_Object__c, Return_Object__c, IsActive__c FROM LeadDistributionRule__c ORDER BY Priority__c];
    }

    @AuraEnabled
    public static void deleteRule(Id ruleId) {
        delete [SELECT Id FROM LeadDistributionRule__c WHERE Id = :ruleId];
    }

    @AuraEnabled
    public static void saveRule(Map<String, Object> ruleData) {
        System.debug('RuleData => '+ ruleData);
        LeadDistributionRule__c rule = new LeadDistributionRule__c();
        if((String)ruleData.get('ruleId') != null){
            rule.Id = (String)ruleData.get('ruleId');
        }
        rule.Name = (String)ruleData.get('ruleName');
        rule.Priority__c = (decimal)ruleData.get('priority');
        rule.IsActive__c = (Boolean)ruleData.get('isActive');
        rule.From_Object__c = (String)ruleData.get('fromObject');
        rule.Return_Object__c = (String)ruleData.get('returnObject');
        rule.Return_Field__c  = (String)ruleData.get('returnField');
        rule.Logic__c = (String)ruleData.get('logic');
        rule.Order_By__c = (String)ruleData.get('orderBy');
        rule.Sorting_Direction__c = (String)ruleData.get('sortingDirection');

        if(rule.Id == null){
            insert rule;
        }else{
            update rule;
            Delete [SELECT Id FROM Lead_Distribution_Rule_Criteria__c WHERE Lead_Distribution_Rule__c = :rule.Id];
        }
        

        List<Lead_Distribution_Rule_Criteria__c> criteria = new List<Lead_Distribution_Rule_Criteria__c>();
        List<object> criteriaObjectList = (List<object>)JSON.deserializeUntyped(JSON.serialize(ruleData.get('criteria')));
        List<Lead_Distribution_Rule_Criteria__c> criteriaList = new List<Lead_Distribution_Rule_Criteria__c>();
        for (Object criteriaObject : criteriaObjectList){
            Map<String, Object> criteriaData = (Map<String, Object>)criteriaObject;
            
            Lead_Distribution_Rule_Criteria__c ruleCriteria = new Lead_Distribution_Rule_Criteria__c();
            ruleCriteria.Lead_Distribution_Rule__c = rule.Id;
            string compundFieldName = (String)criteriaData.get('objectAndFieldApiName');
            ruleCriteria.FieldType__c = getFieldType(compundFieldName);

            if(compundFieldName.contains(rule.From_Object__c+'.')){
                ruleCriteria.Field__c = compundFieldName.substringAfter(rule.From_Object__c+'.');
            }else{
                ruleCriteria.Field__c = compundFieldName;
            }
            ruleCriteria.Operator__c = (String)criteriaData.get('operator');
            ruleCriteria.Value__c = (String)criteriaData.get('value');
            if(isSubQuery(ruleCriteria.Value__c)){
                ruleCriteria.IsSubQuery__c = true;
                ruleCriteria.SubQuery__c = ruleCriteria.Value__c.replace('(', '').replace(')', '');
                ruleCriteria.SubQuery_Field__c = getSubQueryFIeld(ruleCriteria.Value__c);
            }
            ruleCriteria.Order__c = (decimal)criteriaData.get('id');
            system.debug('ruleCriteria => '+ ruleCriteria);
            criteriaList.add(ruleCriteria);
        }
        insert criteriaList;
    }
    
    @AuraEnabled
    public static integer getLastPriority(){
        integer lastPriority = 1;
        List<LeadDistributionRule__c> rules = [SELECT Priority__c FROM LeadDistributionRule__c order by Priority__c desc limit 1];
        if(rules.size()>0){
            lastPriority = (integer)rules[0].Priority__c;
        }
        return lastPriority;
    }

    @AuraEnabled
    public static LeadDistributionRuleWrapper getRuleDetails(Id ruleId) {
        LeadDistributionRule__c rule = [
            SELECT Id, Name, Priority__c, IsActive__c, From_Object__c, Logic__c, Order_By__c, Sorting_Direction__c,
            Return_Object__c, Return_Field__c,
            (SELECT Field__c, Operator__c, Value__c, Order__c FROM Lead_Distribution_Rule_Criterias__r)
            FROM LeadDistributionRule__c
            WHERE Id = :ruleId
            LIMIT 1
        ];

        LeadDistributionRuleWrapper ruleWrapper = new LeadDistributionRuleWrapper();
        ruleWrapper.ruleId = rule.Id;
        ruleWrapper.ruleName = rule.Name;
        ruleWrapper.priority = (integer)rule.Priority__c;
        ruleWrapper.isActive = rule.IsActive__c;
        ruleWrapper.fromObject = rule.From_Object__c;
        ruleWrapper.returnObject = rule.Return_Object__c;
        ruleWrapper.returnField = rule.Return_Field__c;
        ruleWrapper.logic = rule.Logic__c;
        ruleWrapper.criteriaRows = new List<LeadDistributionRuleCriteriaWrapper>();

        for(Lead_Distribution_Rule_Criteria__c criteria : rule.Lead_Distribution_Rule_Criterias__r){
            LeadDistributionRuleCriteriaWrapper criteriaWrapper = new LeadDistributionRuleCriteriaWrapper();
            criteriaWrapper.id = (integer)criteria.Order__c;
            if(criteria.Field__c.contains(rule.Return_Object__c+'.')){
                criteriaWrapper.objectAndFieldApiName = criteria.Field__c;
            }else{
                criteriaWrapper.objectAndFieldApiName = rule.From_Object__c+'.'+criteria.Field__c;
            }
            if(criteria.Field__c.contains(rule.Return_Object__c+'.')){
                criteriaWrapper.fieldApiName = criteria.Field__c.substringAfter(rule.Return_Object__c+'.');
            }else{
                criteriaWrapper.fieldApiName = rule.From_Object__c+'.'+criteria.Field__c;
            }
            criteriaWrapper.operator = criteria.Operator__c;
            criteriaWrapper.value = criteria.Value__c;
            ruleWrapper.criteriaRows.add(criteriaWrapper);
        }

        return ruleWrapper;
    }

    private static string getFieldType(string compoundFieldApiName){
        string[] parts = compoundFieldApiName.split('\\.');
        integer lastIndex = parts.size() - 1;
        string objectName = parts[lastIndex-1];
        string fieldName = parts[lastIndex];
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldName).getDescribe();

        string dataType;
        if(fieldDescribe.getType().name() == 'STRING' || fieldDescribe.getType().name() == 'PICKLIST' 
        || fieldDescribe.getType().name() == 'TEXTAREA' || fieldDescribe.getType().name() == 'EMAIL' 
        || fieldDescribe.getType().name() == 'PHONE' || fieldDescribe.getType().name() == 'URL'
        || fieldDescribe.getType().name() == 'ID' || fieldDescribe.getType().name() == 'REFERENCE'){
            dataType = 'Text';
        }else if(fieldDescribe.getType().name() == 'BOOLEAN'){
            dataType = 'Boolean';
        }else if(fieldDescribe.getType().name() == 'DATE'){
            dataType = 'Date';
        }else  if(fieldDescribe.getType().name() == 'DATETIME'){
            dataType = 'DateTime';
        }else if(fieldDescribe.getType().name() == 'DOUBLE' || fieldDescribe.getType().name() == 'CURRENCY' || fieldDescribe.getType().name() == 'INTEGER'){
            dataType = 'Number';
        }
        return dataType;
    }

    private static boolean isSubQuery(string value){
        string upperValue = value.toUpperCase();
        if(upperValue.contains('SELECT') && upperValue.contains('FROM')){
            return true;
        }else {
            return false;
        }
    }

    private static string getSubQueryFIeld(string value){
        string upperValue = value.toUpperCase();
        return upperValue.substringAfter('SELECT').substringBefore('FROM').trim();
    }

    public class LeadDistributionRuleWrapper{

        @AuraEnabled
        public string ruleId {get;set;}
        @AuraEnabled
        public string ruleName {get;set;}
        @AuraEnabled
        public integer priority {get;set;}
        @AuraEnabled
        public boolean isActive {get;set;}
        @AuraEnabled
        public string fromObject {get;set;}
        @AuraEnabled
        public string returnObject {get;set;}
        @AuraEnabled
        public string returnField {get;set;}
        @AuraEnabled
        public string logic {get;set;}
        @AuraEnabled
        public List<LeadDistributionRuleCriteriaWrapper> criteriaRows {get;set;}
    }

    public class LeadDistributionRuleCriteriaWrapper{
       @AuraEnabled
        public integer id {get;set;}
        @AuraEnabled
        public string objectAndFieldApiName {get;set;}
        @AuraEnabled
        public string fieldApiName {get;set;}
        @AuraEnabled
        public string operator {get;set;}
        @AuraEnabled
        public string value {get;set;}
    }
}