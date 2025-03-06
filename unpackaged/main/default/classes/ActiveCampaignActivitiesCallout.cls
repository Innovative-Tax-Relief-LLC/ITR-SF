public with sharing class ActiveCampaignActivitiesCallout {
    
    public static Web_Service_Setting__mdt settings = Web_Service_Setting__mdt.getInstance('ActiveCampaign');

    public static List<ActiveCampaignActivitiesResponse.Logs> getActivities(ActiveCampaignContactResponse.Contacts contact) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Endpoint__c + '/api/3/activities?contact=' + contact.id + '&include=reference.log.campaign');
        request.setMethod('GET');
        request.setHeader('Api-Token', settings.Token__c);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {

                // Retorna uma lista de Logs com dados do contato, campanha e mensagem
                if((ActiveCampaignActivitiesResponse.parse(response.getBody()).logs).size() > 0) {
                    return ActiveCampaignActivitiesResponse.parse(response.getBody()).logs;
                } else {
                    return null;
                }
            } else {
                System.debug('Call failure ActiveCampaignActivitiesCallout: ' + response.getStatusCode() + ' ' + response.getStatus());
                return null;
            }
        } catch(Exception e) {
            System.debug('Exception ActiveCampaignActivitiesCallout: ' + e.getMessage());
            return null;
        }
    }
}