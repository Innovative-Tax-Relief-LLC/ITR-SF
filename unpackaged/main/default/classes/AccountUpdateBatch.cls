public class AccountUpdateBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Latest_Case_Created__c, Latest_Opp_Created__c, ' +
                       '(SELECT Id FROM Opportunities ORDER BY CreatedDate DESC LIMIT 1), ' +
                       '(SELECT Id FROM Cases ORDER BY CreatedDate DESC LIMIT 1) ' +
                       'FROM Account';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> accounts) {
        List<Account> accountsToUpdate = new List<Account>();
        
        for(Account acc : accounts) {
            Boolean needsUpdate = false;
            
            if(!acc.Opportunities.isEmpty()) {
                acc.Latest_Opp_Created__c = acc.Opportunities[0].Id;
                needsUpdate = true;
            }
            
            if(!acc.Cases.isEmpty()) {
                acc.Latest_Case_Created__c = acc.Cases[0].Id;
                needsUpdate = true;
            }
            
            if(needsUpdate) {
                accountsToUpdate.add(acc);
            }
        }
        
        if(!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch job completed');
    }
}