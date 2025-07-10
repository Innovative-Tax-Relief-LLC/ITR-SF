public class OpportunityFieldHistoryProxy {
    public Id opportunityId;
    public String newValue;
    public DateTime createdDate;
    
    private static Map<Id, List<OpportunityFieldHistoryProxy>> testHistoryByOppId = new Map<Id, List<OpportunityFieldHistoryProxy>>();
    
    public OpportunityFieldHistoryProxy(Id oppId, String givenValue, DateTime givenDT) {
        this.opportunityId = oppId;
        this.newValue = givenValue;
        this.createdDate = givenDT;
    }
    
    public static void setTestHistory(Id oppId, List<OpportunityFieldHistoryProxy> histories) {
        testHistoryByOppId.put(oppId, histories);
    }
    
    public static void clearTestHistory() {
        testHistoryByOppId.clear();
    }
    
    public static List<OpportunityFieldHistoryProxy> getStageHistory(Set<Id> oppIds) {
        List<OpportunityFieldHistoryProxy> proxies = new List<OpportunityFieldHistoryProxy>();
        
        if (Test.isRunningTest() && !testHistoryByOppId.isEmpty()) {
            for (Id oppId : oppIds) {
                List<OpportunityFieldHistoryProxy> testHistories = testHistoryByOppId.get(oppId);
                if (testHistories != null) {
                    proxies.addAll(testHistories);
                }
            }
            return proxies;
        }
        
        List<OpportunityFieldHistory> fieldHistories = [
            SELECT OpportunityId, NewValue, OldValue, CreatedDate
            FROM OpportunityFieldHistory 
            WHERE OpportunityId IN :oppIds 
            AND Field = 'StageName'
            ORDER BY OpportunityId, CreatedDate ASC
        ];
        
        System.debug('Found ' + fieldHistories.size() + ' field history records for ' + oppIds.size() + ' opportunities');
        
        Set<String> closingStages = new Set<String>{
            'Intro Pending', 
            'TI PIF Completed', 
            'Closed Won'
        };
        
        for (OpportunityFieldHistory history : fieldHistories) {
            String newValueStr = String.valueOf(history.NewValue);
            System.debug('RAW History Record: OppId=' + history.OpportunityId + 
                        ', NewValue=[' + newValueStr + ']' + 
                        ', CreatedDate=' + history.CreatedDate);
            
            if (newValueStr != null && closingStages.contains(newValueStr)) {
                System.debug('✓ MATCHED History: OppId=' + history.OpportunityId + 
                            ', NewValue=' + newValueStr + 
                            ', CreatedDate=' + history.CreatedDate);
                
                proxies.add(new OpportunityFieldHistoryProxy(
                    history.OpportunityId, 
                    newValueStr, 
                    history.CreatedDate
                ));
            } else {
                System.debug('✗ SKIPPED History: OppId=' + history.OpportunityId + 
                            ', NewValue=[' + newValueStr + '] (not a closing stage)');
            }
        }
        
        System.debug('Returning ' + proxies.size() + ' proxy records');
        return proxies;
    }
    
    public static List<OpportunityFieldHistoryProxy> getStageHistory(Id oppId) {
        return getStageHistory(new Set<Id>{oppId});
    }
}