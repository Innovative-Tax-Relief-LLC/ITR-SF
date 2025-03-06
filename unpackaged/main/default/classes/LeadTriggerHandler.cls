public inherited sharing class LeadTriggerHandler extends TriggerHandler {
    List<Lead> newLeads;
    Map<Id, Lead> oldLeadsMap;

    public LeadTriggerHandler() {
        this.newLeads = (List<Lead>) Trigger.new;
        this.oldLeadsMap = (Map<Id, Lead>) Trigger.oldMap;
    }
    public override void afterInsert() {
        System.debug('in trigger after insert');
        if(!Test.isRunningTest()){
            LivevoxIntegrationHelper.manageIntegration(this.newLeads, 'INSERT');
        }
    }
    public override void afterUpdate() {
        new LeadDoNotCallHandler(this.newLeads, this.oldLeadsMap).handleAfterUpdate();
        System.debug('in trigger after update');
        if(!Test.isRunningTest()){
        LivevoxIntegrationHelper.manageIntegration(this.newLeads, 'UPDATE');
        }
       
    }
}