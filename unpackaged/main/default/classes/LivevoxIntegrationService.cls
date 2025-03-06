public without sharing class LivevoxIntegrationService {
    private static String livevoxContactId = '';
    private static List<Lead> notCreatedLeads = new List<Lead>();

   
    public static void createLivevoxContact(Lead lead){
        LivevoxSessionRequest.getSessionId();
        String endpoint ='callout:Livevox/contact/contacts/';
        String body = JSON.serialize(LivevoxContactWrapper.getLiveboxCreateContactDetailsWrapper(lead));
        System.debug('request body contact ' + body);
        sendRequestToLivevox(body, endpoint,'POST','', JSON.serialize(lead));
        System.debug('END!!' + livevoxContactId);
    }

    public static void updateLivevoxContact(Lead lead){
        LivevoxSessionRequest.getSessionId();
       // String velocifyId = lead.Velocify_Id__c;
        String endpoint = ('callout:Livevox/contact/contacts/'+'');
        String body = JSON.serialize(LivevoxContactWrapper.getLiveboxUpdateDetailsWrapper(lead));
        System.debug('request body contact ' + body);
        try {
            sendRequestToLivevox(body, endpoint,'PUT', '',JSON.serialize(lead));
            
            System.debug(livevoxContactId);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }


    @future(callout=true)
    public static void sendRequestToLivevox(String body,String endpoint, String method,String velocifyId, String leadRecord){
        String liveboxSessionId = Livevox_Integration_Configuration__c.getInstance('ITR Session').sessionId__c;
        System.debug('sendRequestToLivevox ' + liveboxSessionId + ' body ' + body + ' endpoint ' + endpoint);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('LV-Session', liveboxSessionId);  
        request.setBody(body); 
        try {
            HttpResponse response = http.send(request);
            System.debug('response ' + response + 'response body ' + response.getBody());
            if(response.getStatusCode() == 201){
                Map<String,Object> bodyMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                livevoxContactId = (String) bodyMap.get('id');
                appendContactToCampaign(livevoxContactId, (Lead)JSON.deserialize(leadRecord,Lead.class));
            }
            if(response.getStatusCode() == 404 && method == 'PUT' && response.getBody().contains('No Record Found')){
                notCreatedLeads.add((Lead)JSON.deserialize(leadRecord,Lead.class));
                LivevoxIntegrationQueueable livevoxQueueable = new LivevoxIntegrationQueueable(notCreatedLeads,'INSERT');
            }
            System.debug(livevoxContactId);
            
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }


    public static void appendContactToCampaign(String livevoxContactId, Lead lead){
        System.debug('appendContactToCampaign ' + livevoxContactId);
        String liveboxSessionId = Livevox_Integration_Configuration__c.getInstance('ITR Session').sessionId__c;
        String DTFormCampaignId = Livevox_Integration_Configuration__c.getInstance('ITR Session').DT_Form_campaingId__c;
        String DTFormDSCampaignId = Livevox_Integration_Configuration__c.getInstance('ITR Session').DT_Form_DS_campaing_Id__c;
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String livevoxCampaignId = (lead.LeadSource == 'DT Form') ? DTFormCampaignId : DTFormDSCampaignId;
            request.setEndpoint('callout:Livevox/campaign/campaigns/'+livevoxCampaignId+'/transactions');
            request.setMethod('PUT');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('LV-Session', liveboxSessionId);  
            String body = JSON.serialize(new LivevoxCampaignRequestWrapper(lead));
            System.debug('body lead ' + body + ' endpoint ' + request.getEndpoint());
            request.setBody(body);
            HttpResponse response = http.send(request);
            System.debug('response  append campaign ' + response + ' response body append campaign ' + response.getBody());
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
  
}