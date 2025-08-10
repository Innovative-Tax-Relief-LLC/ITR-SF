public class CaseNotesHistoryBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, CreatedDate, CaseNotesFilledDate__c, Description
            FROM Case
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> cases) {
        // Filter cases with Description in Apex code
        List<Case> casesWithDescription = new List<Case>();
        for(Case c : cases) {
            if(String.isNotBlank(c.Description)) {
                casesWithDescription.add(c);
            }
        }
        
        if(casesWithDescription.isEmpty()) return;
        
        Set<Id> caseIds = new Map<Id, Case>(casesWithDescription).keySet();
        
        Map<Id, DateTime> caseFirstDescriptionDate = new Map<Id, DateTime>();
        
        List<CaseHistory> historyRecords = [
            SELECT CaseId, CreatedDate, NewValue, OldValue 
            FROM CaseHistory 
            WHERE CaseId IN :caseIds 
            AND Field = 'Description'
            ORDER BY CaseId, CreatedDate ASC
        ];
        
        for(CaseHistory history : historyRecords) {
            if(String.isBlank(String.valueOf(history.OldValue)) && 
               String.isNotBlank(String.valueOf(history.NewValue)) && 
               !caseFirstDescriptionDate.containsKey(history.CaseId)) {
                caseFirstDescriptionDate.put(history.CaseId, history.CreatedDate);
            }
        }
        
        List<Case> casesToUpdate = new List<Case>();
        for(Case c : casesWithDescription) {
            Case updateCase = new Case(Id = c.Id);
            if(caseFirstDescriptionDate.containsKey(c.Id)) {
                updateCase.CaseNotesFilledDate__c = caseFirstDescriptionDate.get(c.Id);
            } else {
                updateCase.CaseNotesFilledDate__c = c.CreatedDate;
            }
            casesToUpdate.add(updateCase);
        }
        
        update casesToUpdate;
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('CaseNotesHistoryBatch completed');
    }
}