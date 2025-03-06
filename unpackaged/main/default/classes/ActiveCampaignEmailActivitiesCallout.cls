public with sharing class ActiveCampaignEmailActivitiesCallout {
    
    public static Web_Service_Setting__mdt settings = Web_Service_Setting__mdt.getInstance('ActiveCampaign');

    public static List<ActiveCampaignEmailActivitiesResponse.EmailActivities> getEmailsActivities(ActiveCampaignContactResponse.Contacts contact) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Endpoint__c + '/api/3/emailActivities?filters[subscriberid]=' + contact.id);
        request.setMethod('GET');
        request.setHeader('Api-Token', settings.Token__c);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {

                // Retorna os dados de Email do Contato
                if((ActiveCampaignEmailActivitiesResponse.parse(response.getBody()).emailActivities).size() > 0) {
                    return ActiveCampaignEmailActivitiesResponse.parse(response.getBody()).emailActivities;
                } else {
                    return null;
                }
            } else {
                System.debug('Call failure ActiveCampaignEmailActivitiesCallout: ' + response.getStatusCode() + ' ' + response.getStatus());
                return null;
            }
        } catch(Exception e) {
            System.debug('Exception ActiveCampaignEmailActivitiesCallout: ' + e.getMessage());
            return null;
        }
    }
}