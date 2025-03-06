global class DeleteErrorLogsBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date today = Date.today();
        Date threeDaysAgo = today.addDays(-3);
    
        DateTime threeDaysAgoStart = DateTime.newInstance(threeDaysAgo.year(), threeDaysAgo.month(), threeDaysAgo.day(), 0, 0, 0);
    
        return Database.getQueryLocator(
            'SELECT Id FROM ActiveCamp__Error_Log__c WHERE CreatedDate <= :threeDaysAgoStart'
        );
	}


    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        try {
            delete scope;
        } catch (Exception e) {
            System.debug('Error deleting records: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch job to delete ActiveCamp__Error_Log__c records completed.');
    }
}