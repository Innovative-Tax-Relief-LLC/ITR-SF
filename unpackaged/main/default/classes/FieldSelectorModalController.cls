public with sharing class FieldSelectorModalController {
    @AuraEnabled(cacheable=true)
    public static List<String> getObjects(String baseObject, String secondObject) {
        List<String> objectOptions = new List<String>();

        objectOptions.add(baseObject);

        if (String.isBlank(secondObject) || baseObject == secondObject) {
            objectOptions.add('Opportunity');
            objectOptions.add('Case');
            objectOptions.add('Contact');
        } else {
            objectOptions.add(secondObject);
        }

        return objectOptions;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getFields(String baseObject) {
        List<String> result = new List<String>();

        Schema.DescribeSObjectResult selectedDescribe = Schema.getGlobalDescribe().get(baseObject).getDescribe();
        for (Schema.SObjectField field : selectedDescribe.fields.getMap().values()) {
            result.add(field.getDescribe().getName());
        }

        return result;
    }
}