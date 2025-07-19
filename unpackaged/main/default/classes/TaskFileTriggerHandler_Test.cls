@IsTest
private class TaskFileTriggerHandler_Test {

    @TestSetup
    static void makeData(){
        Task testTask = TestDataFactory.createTask('Test Task for File Upload');
        ContentVersion cv = TestDataFactory.createContentVersion('Test Document', 'TestDocument.pdf', Blob.valueOf('Test Content'));

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = testTask.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }

    @IsTest
    static void testTaskUpdateOnFileUpload() {
        Test.startTest();
        Task updatedTask = [SELECT Id, Is_File_Uploaded__c FROM Task WHERE Subject = 'Test Task for File Upload' LIMIT 1];
        Assert.areEqual(true, updatedTask.Is_File_Uploaded__c, 'The Task Is_File_Uploaded__c should be true after a file is attached.');
        Test.stopTest();
    }
}