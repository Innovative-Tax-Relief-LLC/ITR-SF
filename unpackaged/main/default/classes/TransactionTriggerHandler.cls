public with sharing class TransactionTriggerHandler extends TriggerHandler{

    public static Group queue = getQueueByName('2nd Trade – 1st Payment Declined');
    public static List<String> queueEmails = new List<String>{queue.Email};
    public List<bt_stripe__Transaction__c> newTransactions;
    public Map<Id, bt_stripe__Transaction__c> oldTransactionsMap;
    
    public TransactionTriggerHandler(){
        this.newTransactions = (List<bt_stripe__Transaction__c>) trigger.new;
        this.oldTransactionsMap = (Map<Id, bt_stripe__Transaction__c>) trigger.oldMap;
    }
    
    public override void afterInsert(){
        validateTransaction(this.newTransactions);
    
    }
	
    public override void afterUpdate(){
        List<bt_stripe__Transaction__c> transactions = this.newTransactions;
        Map<Id, bt_stripe__Transaction__c> transactionMap = this.oldTransactionsMap;
        List<Task> tasksToCreate = new List<Task>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        Map<Id, Opportunity> opportunityMap = fetchSecondTradeOpportunities(transactions);
        Map<Id, List<bt_stripe__Transaction__c>> scheduleTransactionsMap = fetchAllScheduleTransactions(transactions);

        for (bt_stripe__Transaction__c tr : transactions) {
            Opportunity relatedOpportunity = opportunityMap.get(tr.bt_stripe__Opportunity2__c);
            if (relatedOpportunity == null) {
                continue;
            }

            if (this.isTransactionFailed(tr, transactionMap)) {
                List<bt_stripe__Transaction__c> scheduleTransactions = scheduleTransactionsMap.get(tr.bt_stripe__Payment_Schedule__c);
                if (scheduleTransactions != null && !scheduleTransactions.isEmpty() && scheduleTransactions[0].Id == tr.Id) {
                    tasksToCreate.add(createTaskForTransaction(tr, relatedOpportunity, queue.Id));
                    emailsToSend.addAll(createEmails(tr, relatedOpportunity));
                }
            }
        }

        createTasks(tasksToCreate);
        sendEmails(emailsToSend);

        validateTransaction(this.newTransactions);
    
    }
    

    private Boolean isTransactionFailed(bt_stripe__Transaction__c trans, Map<Id, bt_stripe__Transaction__c> transactionMap) {
        return trans.bt_stripe__Transaction_Status__c == 'Failed' && 
               transactionMap.get(trans.Id).bt_stripe__Transaction_Status__c != 'Failed';
    }

    private static Map<Id, List<bt_stripe__Transaction__c>> fetchAllScheduleTransactions(List<bt_stripe__Transaction__c> transactions) {
        Set<Id> paymentScheduleIds = new Set<Id>();
        for (bt_stripe__Transaction__c tr : transactions) {
            if (tr.bt_stripe__Payment_Schedule__c != null) {
                paymentScheduleIds.add(tr.bt_stripe__Payment_Schedule__c);
            }
        }

        Map<Id, List<bt_stripe__Transaction__c>> scheduleTransactionsMap = new Map<Id, List<bt_stripe__Transaction__c>>();
        for (bt_stripe__Transaction__c tr : [SELECT Id, bt_stripe__Due_Date__c, bt_stripe__Payment_Schedule__c 
                                             FROM bt_stripe__Transaction__c 
                                             WHERE bt_stripe__Payment_Schedule__c IN :paymentScheduleIds 
                                             ORDER BY bt_stripe__Due_Date__c ASC]) {
            if (!scheduleTransactionsMap.containsKey(tr.bt_stripe__Payment_Schedule__c)) {
                scheduleTransactionsMap.put(tr.bt_stripe__Payment_Schedule__c, new List<bt_stripe__Transaction__c>());
            }
            scheduleTransactionsMap.get(tr.bt_stripe__Payment_Schedule__c).add(tr);
        }
        return scheduleTransactionsMap;
    }

    private static Group getQueueByName(String queueName) {
        return [SELECT Id, Email FROM Group WHERE Type = 'Queue' AND Name = :queueName LIMIT 1];
    }

    private static Map<Id, Opportunity> fetchSecondTradeOpportunities(List<bt_stripe__Transaction__c> transactions) {
        Set<Id> opportunityIds = new Set<Id>();
        for (bt_stripe__Transaction__c tr : transactions) {
            if (tr.bt_stripe__Opportunity2__c != null) {
                opportunityIds.add(tr.bt_stripe__Opportunity2__c);
            }
        }

        return new Map<Id, Opportunity>(
            [SELECT Id, Name, RecordType.Name 
             FROM Opportunity 
             WHERE Id IN :opportunityIds AND RecordType.Name = 'Second Trade']
        );
    }

    private static Task createTaskForTransaction(bt_stripe__Transaction__c trans, Opportunity opportunity, Id queueId) {
        return new Task(
            WhatId = opportunity.Id,
            OwnerId = queueId,
            Subject = '1st Payment Declined - ' + opportunity.Name + ' - US$' + trans.bt_stripe__Amount__c,
            Priority = 'Urgent',
            ActivityDate = System.today()
        );
    }

    private static List<Messaging.SingleEmailMessage> createEmails(bt_stripe__Transaction__c trans, Opportunity opportunity) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String opportunityUrl = baseUrl + '/' + opportunity.Id;
       
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(queueEmails);
        email.setSubject('1st Payment Declined - ' + opportunity.Name + ' - $US' + trans.bt_stripe__Amount__c);
        email.setPlainTextBody('Greetings,\n\nThe first payment for Second Trade Opportunity "' + opportunity.Name +
        '" has failed.\nLink to Opportunity: ' + opportunityUrl + '\n\nPlease review the related task and follow up '+
        'with your opportunity team. \n\nRegards,\nSalesforce System');
        email.setSaveAsActivity(false);
        emails.add(email);
        return emails;
    }

    private static void createTasks(List<Task> tasks) {
        if (!tasks.isEmpty()) {
            try {
                insert tasks;
            } catch (Exception e) {
                System.debug('Error inserting tasks: ' + e.getMessage());
            }
        }
    }

    private static void sendEmails(List<Messaging.SingleEmailMessage> emails) {
        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (Exception e) {
                System.debug('Error sending emails: ' + e.getMessage());
            }
        }
    }

    private static void validateTransaction(List<bt_stripe__Transaction__c> trans) {
        List<bt_stripe__Transaction__c> validTransactions = new List<bt_stripe__Transaction__c>();
        
        for (bt_stripe__Transaction__c txn : trans) {
            if (txn.bt_stripe__Transaction_Status__c == 'Completed' && txn.bt_stripe__Payment_Schedule__c != null) {
                validTransactions.add(txn);
            }
        }
        
        if (!validTransactions.isEmpty()) {
            PaymentScheduleHelper.processTransactions(validTransactions);
        }
    }
    
}