public class LivevoxIntegrationQueueable implements Queueable, Database.AllowsCallouts {

    private List<Lead> leadsToProcess;
    private Set<Id> leadsToProcessIds = new Set<Id>();
    private String triggerContext = '';

    public LivevoxIntegrationQueueable(List<Lead> leadsToProcess, String triggerContext) {
        this.leadsToProcess = leadsToProcess;
        this.triggerContext = triggerContext;
        for (Lead lead : leadsToProcess) {
            leadsToProcessIds.add(lead.Id);
        }

    }

    public void execute(QueueableContext context) {

        List<Lead> leads = [SELECT Id,FirstName,LastName,Street,
        City,State,PostalCode,Phone,Email,LeadSource,
        Total_Tax_Debt__c,CreatedDate,Status,Sub_Status__c, MobilePhone
        FROM Lead WHERE Id IN :leadsToProcessIds];

        //Validate this because we need to send the list of Leads instead of only one Lead at a time 
        for(Lead lead: leads){
            if(triggerContext == 'INSERT'){
                System.debug('queueable insert');
                LivevoxIntegrationService.createLivevoxContact(lead);
            } else if (triggerContext == 'UPDATE'){
                System.debug('queueable update');
                LivevoxIntegrationService.updateLivevoxContact(lead);
            }
            
        }
    }

}