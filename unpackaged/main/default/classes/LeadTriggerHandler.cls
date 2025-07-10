public inherited sharing class LeadTriggerHandler extends TriggerHandler {
  List<Lead> newLeads;
  Map<Id, Lead> oldLeadsMap;

  public LeadTriggerHandler() {
    this.newLeads = (List<Lead>) Trigger.new;
    this.oldLeadsMap = (Map<Id, Lead>) Trigger.oldMap;
  }
  public override void afterUpdate() {
    new LeadDoNotCallHandler(this.newLeads, this.oldLeadsMap).handleAfterUpdate();
  }
}