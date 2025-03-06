public with sharing class ActiveCampaignContactCallout {

    public static Web_Service_Setting__mdt settings = Web_Service_Setting__mdt.getInstance('ActiveCampaign');

    public static ActiveCampaignContactResponse.Contacts getContacts(String email) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Endpoint__c + '/api/3/contacts?filters[email]=' +email);
        request.setMethod('GET');
        request.setHeader('Api-Token', settings.Token__c);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {

                // Retorna os dados do Contato
                if((ActiveCampaignContactResponse.parse(response.getBody()).contacts).size() > 0) {
                    return ActiveCampaignContactResponse.parse(response.getBody()).contacts[0];
                } else {
                    return null;
                }
            } else {
                System.debug('Call failure ActiveCampaignContactCallout: ' + response.getStatusCode() + ' ' + response.getStatus());
                return null;
            }
        } catch(Exception e) {
            System.debug('Exception ActiveCampaignContactCallout: ' + e.getMessage());
            return null;
        }
    }
}