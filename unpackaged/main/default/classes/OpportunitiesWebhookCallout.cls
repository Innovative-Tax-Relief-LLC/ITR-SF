public with sharing class OpportunitiesWebhookCallout implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private static Web_Service_Setting__mdt settings = Web_Service_Setting__mdt.getInstance('WebhookOpportunities');
    private String jsonBody;
    private List<Opportunity> opportunitiesToProcess;

    public OpportunitiesWebhookCallout(String json, List<Opportunity> opportunities) {
        this.jsonBody = json;
        this.opportunitiesToProcess = opportunities;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Opportunity WHERE Id IN :opportunitiesToProcess');
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('Success: ' + response.getBody());
            } else {
                System.debug('Error WebhookOpportunities: ' 
                             + response.getStatusCode() 
                             + ' ' + response.getStatus());
            }
        } catch (Exception e) {
            System.debug('Exception WebhookOpportunities: ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context) {
        // Do something
    }
}