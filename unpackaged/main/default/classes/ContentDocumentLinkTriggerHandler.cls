public inherited sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler {
    public List<ContentDocumentLink> newContentDocumentLinks;
    public Map<Id, ContentDocumentLink> oldContentDocumentLinksMap;

    public ContentDocumentLinkTriggerHandler() {
        this.newContentDocumentLinks = Trigger.new;
        this.oldContentDocumentLinksMap = (Map<Id, ContentDocumentLink>) Trigger.oldMap;
    }
    public override void afterInsert() {
        new TaskFileTriggerHandler(this.newContentDocumentLinks).handleAfterInsert();
    }
}