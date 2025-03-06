/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RelationshipService {
    global static String accountName;
    global static String CONTACT_ACCOUNT_RULE_BUCKET;
    global static String CONTACT_ACCOUNT_RULE_CREATE;
    global static String CREATE_RULE_ACCOUNT;
    global static String CREATE_RULE_CONTACT;
    global static String CREATE_RULE_LEAD;
    global static Map<String,SObject> cusKeyMap;
    global static Map<String,SObject> cusNewParentRecords;
    global static List<bt_stripe.LogData> errors;
    global static Map<Schema.SObjectType,List<Schema.SObjectField>> objEmailFieldMap;
    global static String REL_RULE_ALWAYS_NEW;
    global static String REL_RULE_MATCH_OR_NEW;
    global static String REL_RULE_NONE;
    global static String REL_RULE_ONLY_MATCH;
    global RelationshipService() {

    }
    global static void commitRecords(String location) {

    }
    global static SObject findBestMatch(SObject record) {
        return null;
    }
    global static String matchedRuleName() {
        return null;
    }
    global static SObject performMatchingBasedOnSetting(bt_stripe__Relationship_Settings__c setting, Contact matchContact, Account matchAccount, Lead matchLead) {
        return null;
    }
    global static void recordCreatedBasedOnSetting(bt_stripe__Relationship_Settings__c setting, SObject cus, Contact newContact, Account newAccount, Lead newLead) {

    }
}
