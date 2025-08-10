public class CaseTriggerHandler extends TriggerHandler {
    public List<Case> newCases;
    public Map<Id, Case> oldCasesMap;
    public Map<Id, Case> newCasesMap;
    
    public CaseTriggerHandler() {
        this.newCases = (List<Case>) Trigger.new;
        this.oldCasesMap = (Map<Id, Case>) Trigger.oldMap;
        this.newCasesMap = (Map<Id, Case>) Trigger.newMap;
    }
    
    public override void beforeInsert() {
         if (newCases != null && !newCases.isEmpty()) {
            CaseAssignmentService.assignOwnersBeforeInsert(newCases);
            CaseNotesHandler.handleCaseNotesInsert(newCases);
        }
    }
    
    public override void beforeUpdate() {
        if (oldCasesMap != null && newCasesMap != null) {
            CaseNotesHandler.handleCaseNotesChange(newCases, oldCasesMap);
        }
    }
    
    public override void afterInsert() {
        if (newCases != null && !newCases.isEmpty()) {
            CaseCounterService.updateCountersAfterAssignment(newCases);
        }
    }
    
    public override void afterUpdate() {
        if (oldCasesMap != null && newCasesMap != null) {
            List<Case> closedCases = new List<Case>();
            
            for (Id caseId : newCasesMap.keySet()) {
                Case oldCase = oldCasesMap.get(caseId);
                Case newCase = newCasesMap.get(caseId);
                
                if (!oldCase.IsClosed && newCase.IsClosed) {
                    closedCases.add(oldCase);
                }
            }
            
            if (!closedCases.isEmpty()) {
                CaseCounterService.decrementCountersForClosedCases(closedCases);
            }
        }
    }
}