public class GoogleDriveFolderCreatorQueueableBulk implements Queueable, Database.AllowsCallouts {
    private String parentFolderId;
    private  List<Account> accounts;
    public GoogleDriveFolderCreatorQueueableBulk(List<Account> accounts, String parentFolderId){
        this.accounts = accounts;
        this.parentFolderId = parentFolderId;
    }

    public void execute(QueueableContext context){
        for(Account acc : accounts){
            if (String.isBlank(acc.Google_Drive_Folder_ID__c)) {
                String parentFolderId = Label.GoogleDriveParentFolderID;
                
                String ssnLastFour = acc.SSN__pc != null && acc.SSN__pc.length() >= 4 ? acc.SSN__pc.substring(acc.SSN__pc.length() - 4) : 'XXXX';
                String newFolderName = acc.Name + ' - ' + ssnLastFour + ' - Tax Investigation';
                System.debug('DEBUG :: Drive Folder Name '+newFolderName);
                
                createGoogleDriveFolders(newFolderName,acc.Id,parentFolderId);
            }
            else{
                System.debug('DEBUG :: Account already has a Google Drive Folder created');
            }
          }
    }

    public static void createGoogleDriveFolders(String newFolderName, Id accountId, String parentFolderId) {
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