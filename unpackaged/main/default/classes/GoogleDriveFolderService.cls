public class GoogleDriveFolderService {
    public static String getGoogleDriveFolderId(String folderName) {
        HttpRequest req = new HttpRequest();
        
        String query = 'mimeType=%27application/vnd.google-apps.folder%27+and+title=%27' + EncodingUtil.urlEncode(folderName, 'UTF-8') + '%27';

        req.setEndpoint('callout:GoogleDrive/files?q=' + query);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> files = (List<Object>) response.get('items');
            if (!files.isEmpty()) {
                Map<String, Object> fileData = (Map<String, Object>) files[0];
                return (String) fileData.get('id'); 
            } else {
                System.debug('No folder found with the specified name.');
            }
        } else {
            System.debug('Error retrieving folder ID: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
        return null;
    }
}