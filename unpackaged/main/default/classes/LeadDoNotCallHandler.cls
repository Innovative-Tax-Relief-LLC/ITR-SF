public without sharing class LeadDoNotCallHandler {
    private List<Lead> newLeads;
    private Map<Id, Lead> oldLeadsMap;
    
    public LeadDoNotCallHandler(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        this.newLeads = newLeads;
        this.oldLeadsMap = oldLeadsMap;
    }
    
    public void handleAfterUpdate() {
        for (Lead lead : newLeads) {
            Lead oldLead = oldLeadsMap.get(lead.Id);
            if (lead.DoNotCall != oldLead.DoNotCall) {
                StatusChangeHandler.sendDoNotCallChangeAsync(
                    lead.Id,
                    //lead.Velocify_ID__c,
                    lead.DoNotCall,
                    lead.Phone,
                    lead.MobilePhone
                );
            }
        }
    }
}