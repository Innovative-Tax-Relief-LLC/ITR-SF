/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* GoogleDriveFolderCreatorQueueable
*
* Purpose: Queueable class used for API calls to Google Drive API and create Folders for Accounts
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cloudforia
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        2024-10-01
* @modified       
* @systemLayer    Service
* @see            
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.x        <user>
* <Date>      Explanation of the change
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class GoogleDriveFolderCreatorQueueable implements Queueable, Database.AllowsCallouts {
    private String parentFolderId;
    private String newFolderName;
    private Id accountId;

    public GoogleDriveFolderCreatorQueueable(String parentFolderId, String newFolderName,String accountId) {
        this.parentFolderId = parentFolderId;
        this.newFolderName = newFolderName;
        this.accountId = accountId; 
    }

    public void execute(QueueableContext context) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:GoogleDrive/files');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            Map<String, Object> folderMetadata = new Map<String, Object>();
            folderMetadata.put('title', newFolderName);
            folderMetadata.put('mimeType', 'application/vnd.google-apps.folder');
            
            if (parentFolderId != null) {
                folderMetadata.put('parents', new List<Map<String, String>>{new Map<String, String>{'id' => parentFolderId}});
            }

            req.setBody(JSON.serialize(folderMetadata));
            
            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String folderId = (String) response.get('id');
                System.debug('Folder created successfully. Folder ID: ' + folderId + ' with name: ' + newFolderName);

                Account acc = new Account(Id = accountId, Google_Drive_Folder_ID__c = folderId);
                update acc;
                
            } else {
                System.debug('Error creating folder: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception while creating folder: ' + e.getMessage());
        }
    }
}