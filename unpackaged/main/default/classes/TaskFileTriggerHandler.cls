public with sharing class TaskFileTriggerHandler {
    private final List<ContentDocumentLink> newLinks;

    public TaskFileTriggerHandler(List<ContentDocumentLink> newLinks) {
        this.newLinks = newLinks;
    }

    public void handleAfterInsert() {
        Set<Id> taskIds = new Set<Id>();
        SObjectType taskObjectType = Task.SObjectType;

        for (ContentDocumentLink cdl : this.newLinks) {
            if (cdl.LinkedEntityId.getSobjectType() == taskObjectType) {
                taskIds.add(cdl.LinkedEntityId);
            }
        }

        if (!taskIds.isEmpty()) {
            List<Task> tasksToUpdate = new List<Task>();
            for (Task task : [SELECT Id, Status FROM Task WHERE Id IN :taskIds]) {
                task.Is_File_Uploaded__c = true;
                tasksToUpdate.add(task);
            }


            if (!tasksToUpdate.isEmpty()) {
                update tasksToUpdate;
            }
        }
    }
}