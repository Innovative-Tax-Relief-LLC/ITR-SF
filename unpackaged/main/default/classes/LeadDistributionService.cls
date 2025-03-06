/**
 *  @description : The LeadDistributionService is a utility class designed to distribute leads among users based on specific criteria.
 *  The class provides a method, fetchRecordForDistribution, which takes a user ID as input and returns a lead record to be distributed to that user.
 *  The distribution is based on the LeadDistributionRule__c custom object, which defines the criteria for lead distribution.
 */
public with sharing class LeadDistributionService {

    /**
     *  @description : Fetches a lead record to be distributed to the specified user based on the LeadDistributionRule__c custom object.
     *  @param userId:  The ID of the user for whom a lead record is to be assigned to.
     *  @return sObject:  The fetched lead record or null if no lead record is found.
     */
    public static sObject fetchRecordForDistribution(Id userId) {
        try {

            List<LeadDistributionRule__c> rules = [
                SELECT Id, From_Object__c, Return_Object__c, Return_Field__c, 
                       Logic__c, Order_By__c, Sorting_Direction__c, Has_Not_Supported_SubQuery__c
                FROM LeadDistributionRule__c 
                WHERE IsActive__c = true 
                ORDER BY Priority__c ASC
            ];

            // Iterate through the rules and execute them.
            // If no record is found, it execute the next rule.
            // Return the first record that matches the rule criteria.
            for (LeadDistributionRule__c rule : rules) {
                List<sObject> records = executeRule(rule, userId);
                if (!records.isEmpty()) {
                    sObject record = records[0];
                    Id recordId = (Id)record.get(rule.Return_Field__c);
                    SObjectType t = recordId.getSObjectType();
                    if(t.getDescribe().getName() == 'Account'){
                        Account ac = new Account();
                        ac.Id = recordId;
                        ac.OwnerId = userId;
                        ac.Last_Assign_Date__c =  System.Now();
                        Update ac;
                        return ac; 
                    }else if(t.getDescribe().getName() == 'Lead'){
                        Lead lead = new Lead();
                        lead.Id = recordId;
                        lead.OwnerId = userId;
                        lead.Last_Assign_Date__c =  System.Now();
                        Update lead;
                        return lead; 
                    }else{
                        record.put('OwnerId', userId);
                        update record;
                        return record; 
                    }
                }
            }

            return null;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }

    private static List<sObject> executeRule(LeadDistributionRule__c rule, Id userId) {
        List<sObject> result = new List<sObject>();

        String query = buildQuery(rule, userId);
        system.debug('Query: '+ query);
        if (String.isNotBlank(query)) {
            result = Database.query(query);

            // Remove data according to not supported filter
            // This is a custom logic to remove data from the result set based on the not supported filter
            // Not supported filter is a filter that is not supported by SOQL as a Sub Query
            if(rule.Has_Not_Supported_SubQuery__c){
                result = removeDataAccordingToNotSupportedFilter(rule, result);
            }
        }

        return result;
    }

    private static String buildQuery(LeadDistributionRule__c rule, Id userId) {
        // Initialize the WHERE clause with the rule logic
        String whereClause = ' WHERE ' + rule.Logic__c;

        List<Lead_Distribution_Rule_Criteria__c> criteria = [
            SELECT Field__c, Operator__c, Value__c, IsSubQuery__c, SubQuery__c, Order__c, FieldType__c, Is_Not_Supported_SubQuery__c, SubQuery_Field__c 
            FROM Lead_Distribution_Rule_Criteria__c 
            WHERE Lead_Distribution_Rule__c = :rule.Id AND Is_Not_Supported_SubQuery__c = false
            ORDER BY Order__c ASC
        ];

        // Build the WHERE clause
        Set<string> fields = new Set<string>();
        for (integer i = 0; i < criteria.size(); i++) {
            Lead_Distribution_Rule_Criteria__c criterion = criteria[i]; 
            fields.add(criterion.Field__c);
            string condition = generateCondition(criterion);
            integer position = i+1;
            whereClause = whereClause.replace('{'+position+'}', condition);
        }

        // Construct the final SOQL query
        fields.add(rule.Return_Field__c);
        String query = 'SELECT ' +  string.join(fields,',') +
                       ' FROM ' + rule.From_Object__c + whereClause;

        if (String.isNotBlank(rule.Order_By__c)) {
            query += ' ORDER BY ' + rule.Order_By__c + ' ' + rule.Sorting_Direction__c;
        }

        return query;
    }

    private static string generateCondition(Lead_Distribution_Rule_Criteria__c criterion) {
        string condition =  criterion.Field__c + ' ' + criterion.Operator__c + ' ';

        if(criterion.IsSubQuery__c && (criterion.Operator__c == 'In' || criterion.Operator__c == 'Not In')){
            condition += ' (' + criterion.SubQuery__c + ') ';
        }else if(criterion.FieldType__c == 'Text'){
            if(criterion.Operator__c == 'LIKE'){
                condition += ' \'%' + criterion.Value__c + '%\'';
            } else {
                condition += ' \'' + criterion.Value__c + '\'';
            }
        } else { 
            condition += ' ' + criterion.Value__c;
        } 
        
        return condition;
    }

    private static List<sObject> removeDataAccordingToNotSupportedFilter(LeadDistributionRule__c rule, List<sObject> records){
        List<sObject> result = new List<sObject>();
        List<Lead_Distribution_Rule_Criteria__c> criteria = [
            SELECT Field__c, Operator__c, Value__c, IsSubQuery__c, SubQuery__c, Order__c, Is_Not_Supported_SubQuery__c, SubQuery_Field__c 
            FROM Lead_Distribution_Rule_Criteria__c 
            WHERE Lead_Distribution_Rule__c = :rule.Id and Is_Not_Supported_SubQuery__c = true
            ORDER BY Order__c ASC
        ];

        for (Lead_Distribution_Rule_Criteria__c criterion : criteria) {

            if(criterion.IsSubQuery__c && (criterion.Operator__c == 'In' || criterion.Operator__c == 'Not In')){
                String query = criterion.SubQuery__c;
                List<sObject> subQueryResult = Database.query(query);
                if(criterion.Operator__c == 'In'){
                    for (sObject record : records) {
                        Boolean isRecordValid = false;
                        for(sObject subQueryRecord : subQueryResult){
                            if(record.get(criterion.Field__c) ==  subQueryRecord.get(criterion.SubQuery_Field__c)){
                                isRecordValid = true;
                                break;
                            }
                        }
                        if(isRecordValid){
                            result.add(record);
                        }
                    }
                }else{
                    for (sObject record : records) {
                        Boolean isRecordValid = true;
                        for(sObject subQueryRecord : subQueryResult){
                            if(record.get(criterion.Field__c) == subQueryRecord.get(criterion.SubQuery_Field__c)){
                                isRecordValid = false;
                                break;
                            }
                        }
                        if(isRecordValid){
                            result.add(record);
                        }
                    }
                }
            }
        }

        return result;
    }   
}