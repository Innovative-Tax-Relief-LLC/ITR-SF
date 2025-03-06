public without sharing class LivevoxSessionRequest {

    private static Livevox_API_Settings__mdt liveVoxAuthentication = Livevox_API_Settings__mdt.getInstance('ITR_Livevox');
    
    public static void getSessionId() {
        String sessionId = '';
        Livevox_Integration_Configuration__c existingSession = Livevox_Integration_Configuration__c.getInstance('ITR Session');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Livevox/session/login');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('LV-Access', liveVoxAuthentication.Access_Token__c);
        SessionRequest sessionRequestBody = new SessionRequest();
        sessionRequestBody.clientName = liveVoxAuthentication.clientName__c;
        sessionRequestBody.userName = liveVoxAuthentication.userName__c;
        sessionRequestBody.password = liveVoxAuthentication.password__c;
        
        String requestBody = JSON.serialize(sessionRequestBody);
        request.setBody(requestBody);
        System.debug('Request Body: ' + requestBody + ' endpoint ' + request.getEndpoint());
        System.debug('sessionId ' + existingSession.sessionId__c);
        if (!isSessionValid(existingSession.sessionId__c) || Test.isRunningTest()) {
            try {
                HttpResponse response = http.send(request);
        
                if (response.getStatusCode() == 200) {
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    sessionId = (String) responseMap.get('sessionId');
                    System.debug('Session ID: ' + sessionId);
                    
                // Save the sessionId in a custom setting
                    upsertSessionId (sessionId);
                    
                } 
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
           
        }
        
    }

    public static void upsertSessionId(String sessionId) {
        Livevox_Integration_Configuration__c existingSession = Livevox_Integration_Configuration__c.getInstance('ITR Session');
        existingSession.sessionId__c = sessionId;
        try {
            upsert existingSession;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }   
    }

    public static Boolean isSessionValid(String liveVoxSessionId) {

        Boolean isSessionValid ;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Livevox/session/validate/'+liveVoxSessionId);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('LV-Access', liveVoxAuthentication.Access_Token__c);

        HttpResponse response = http.send(request);
        System.debug('response ' + response);

        if (response.getStatusCode() == 204) {
            isSessionValid = true;
        } else if(response.getStatusCode() == 404 || response.getStatusCode() != 204) {
            isSessionValid = false;
        }
        System.debug('isSessionValid ' + isSessionValid);
        return isSessionValid;
    }

    public class SessionRequest {
        public String clientName { get; set; }
        public String userName { get; set; }
        public String password { get; set; }
    }
    
}