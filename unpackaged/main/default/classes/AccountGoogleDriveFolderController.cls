public with sharing class AccountGoogleDriveFolderController {
    public static String personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    @AuraEnabled(cacheable = true)
    public static void processGoogleDriveFolderRequest(Id accountId) {

        try {
            List <Account> accountList = [
                SELECT Id, Name, SSN__pc, Google_Drive_Folder_ID__c, CreatedDate
                FROM Account
                WHERE Google_Drive_Folder_ID__c = NULL 
                AND Id =: accountId AND RecordTypeId =: personAccountId
                ];

            if (!accountList.isEmpty()) {
                String parentFolderId = Label.GoogleDriveParentFolderID;
                System.enqueueJob(new GoogleDriveFolderCreatorQueueableBulk(accountList, parentFolderId));

            } else if (accountList.isEmpty()) {
                throw new AuraHandledException('Error creating folder. Validate Record Type');
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error creating Google Drive Folder ' + e.getMessage());
        }
    }
}