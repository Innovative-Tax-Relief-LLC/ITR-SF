public class LastInteractionHelper {
    public static void updateLastInteractionField(Set<Id> relatedCaseIds) {

        List<Case> casesToUpdate = [SELECT Id, LastOutreachDate__c FROM Case WHERE Id IN :relatedCaseIds];

        for (Case cas : casesToUpdate) {
            cas.LastOutreachDate__c = date.today();
        }
        try {
            update casesToUpdate;
        } catch (DmlException e) {
            System.debug('Error DML error' + e.getMessage());
        }
    }
}