public inherited sharing class LivevoxIntegrationHelper {

    public static void manageIntegration(List<Lead> newLeads, String triggerContext){
        List<Lead> leadsToProcess = new List<Lead>();
        Set<String> validLeadSources = new Set<String>{'DT Form', 'DT Form DS'};

        for(Lead lead : newLeads){
            if(lead.LeadSource != null && validLeadSources.contains(lead.LeadSource)){
                leadsToProcess.add(lead);
            }
        }

        if(!leadsToProcess.isEmpty()){
            LivevoxIntegrationQueueable livevoxQueueable = new LivevoxIntegrationQueueable(leadsToProcess,triggerContext);
            System.enqueueJob(livevoxQueueable);
        }
    }

    
}