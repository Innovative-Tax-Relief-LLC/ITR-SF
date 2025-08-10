public class CaseNotesHandler {
    
    public static void handleCaseNotesInsert(List<Case> newCases) {
        for(Case newCase : newCases) {
            if(String.isNotBlank(newCase.Description)) {
                newCase.CaseNotesFilledDate__c = System.now();
            }
        }
    }
    
    public static void handleCaseNotesChange(List<Case> newCases, Map<Id, Case> oldCasesMap) {
        for(Case newCase : newCases) {
            Case oldCase = oldCasesMap.get(newCase.Id);
            
            if(String.isBlank(oldCase.Description) && 
               String.isNotBlank(newCase.Description)) {
                
                newCase.CaseNotesFilledDate__c = System.now();
            }
        }
    }
}