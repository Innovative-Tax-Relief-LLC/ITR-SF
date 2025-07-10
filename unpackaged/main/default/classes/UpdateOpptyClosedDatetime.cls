public class UpdateOpptyClosedDatetime implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator('SELECT Id, CloseDate__c FROM Opportunity WHERE IsClosed = true');
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> opportunities) {
        try {
            Map<Id, Date> opptyClosedDateMap = new Map<Id, Date>();
            Set<Id> opptyIds = new Set<Id>();
            
            for (Opportunity opp : opportunities) {
                opptyIds.add(opp.Id);
            }
            
            System.debug('Processing ' + opportunities.size() + ' closed opportunities');
            
            List<OpportunityFieldHistoryProxy> fieldHistories = OpportunityFieldHistoryProxy.getStageHistory(opptyIds);
            System.debug('Found ' + fieldHistories.size() + ' field history records');
            
            for (OpportunityFieldHistoryProxy history : fieldHistories) {
                String newValue = history.newValue;
                System.debug('Processing history proxy: OppId=' + history.opportunityId + 
                            ', NewValue=[' + newValue + ']' + 
                            ', CreatedDate=' + history.createdDate);
                
                if (isClosingStage(newValue)) {
                    Date existingDate = opptyClosedDateMap.get(history.opportunityId);
                    Date historyDate = history.createdDate.date();
                    
                    if (existingDate == null || historyDate < existingDate) {
                        opptyClosedDateMap.put(history.opportunityId, historyDate);
                        System.debug('✓ MAPPED OppId ' + history.opportunityId + ' to close date: ' + historyDate);
                    } else {
                        System.debug('- SKIPPED OppId ' + history.opportunityId + ' (earlier date already exists: ' + existingDate + ')');
                    }
                } else {
                    System.debug('✗ IGNORED OppId ' + history.opportunityId + ' NewValue=[' + newValue + '] (not a closing stage)');
                }
            }
            
            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            
            for (Opportunity opp : opportunities) {
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                boolean needsUpdate = false;
                
                if (opptyClosedDateMap.containsKey(opp.Id)) {
                    Date historicalCloseDate = opptyClosedDateMap.get(opp.Id);
                    oppToUpdate.CloseDate__c = historicalCloseDate;
                    needsUpdate = true;
                    System.debug('Setting OppId ' + opp.Id + ' CloseDate__c to historical date: ' + historicalCloseDate);
                    
                } else {
                    oppToUpdate.CloseDate__c = null;
                    needsUpdate = true;
                    System.debug('Setting OppId ' + opp.Id + ' CloseDate__c to null (no stage history found)');
                }
                
                if (needsUpdate) {
                    opportunitiesToUpdate.add(oppToUpdate);
                }
            }
            
            System.debug('Updating ' + opportunitiesToUpdate.size() + ' opportunities');
            
            if (!opportunitiesToUpdate.isEmpty()) {
                Database.SaveResult[] results = Database.update(opportunitiesToUpdate, false);
                Integer successCount = 0;
                Integer errorCount = 0;
                
                for (Integer i = 0; i < results.size(); i++) {
                    if (results[i].isSuccess()) {
                        successCount++;
                    } else {
                        errorCount++;
                        System.debug('Error updating Opportunity ' + opportunitiesToUpdate[i].Id + ': ' + 
                                   results[i].getErrors()[0].getMessage());
                    }
                }
                
                System.debug('Update Results - Success: ' + successCount + ', Errors: ' + errorCount);
            } else {
                System.debug('No opportunities needed to be updated');
            }
            
        } catch (Exception e) {
            System.debug('Error in batch: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('UpdateOpptyClosedDatetime batch completed');
    }
    
    private boolean isClosingStage(String stageName) {
        if (stageName == null) return false;
        
        Set<String> closingStages = new Set<String>{
            'Intro Pending', 
            'TI PIF Completed', 
            'Closed Won'
        };
        return closingStages.contains(stageName);
    }
}