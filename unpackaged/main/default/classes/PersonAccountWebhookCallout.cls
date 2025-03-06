public class PersonAccountWebhookCallout {
    
    private static Web_Service_Setting__mdt settings = Web_Service_Setting__mdt.getInstance('WebhookPersonAccounts');

    @future(callout=true)
    public static void sendPersonAccountData(String json) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(json);
            
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('Success: ' + response.getBody());
            } else {
                System.debug('Error WebhookPersonAccounts: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
        } catch(Exception e) {
            System.debug('Exception WebhookPersonAccounts: ' + e.getMessage());
        }
    }
}