/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MetadataServiceWrapper {
    global MetadataServiceWrapper() {

    }
    global static void addNewGlobalPicklistValues(List<bt_stripe.MetadataServiceWrapper.GlobalValueSet> customValues) {

    }
    global static void addNewPicklistValues(List<bt_stripe.MetadataServiceWrapper.PicklistField> picklistFields) {

    }
    global static void addNewPicklistValues(List<bt_stripe.MetadataServiceWrapper.PicklistField> picklistFields, Boolean isRestrictedPicklist) {

    }
    global static void createRemoteEndpoint(String instanceBaseUrl, String sessionId) {

    }
    global static Map<String,String> getProfileNameMap() {
        return null;
    }
    global static void upsertRemoteEndpoint(String instanceBaseUrl, String sessionId, String fullName, String description, Boolean disableProtocolSecurity, Boolean isActive) {

    }
global class GlobalValueSet {
    global Set<String> customValue;
    global String description;
    global String fullName;
    global String masterLabel;
    global Boolean sorted;
    global GlobalValueSet() {

    }
}
global class PicklistField {
    global String description;
    global String inlineHelpText;
    global String label;
    global String name;
    global Set<String> picklistValues;
    global String type;
    global Integer visibleLines;
    global PicklistField() {

    }
}
}
