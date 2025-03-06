public with sharing class ActiveCampaignReportOpenListCallout {
    
    public static Web_Service_Setting__mdt settings = Web_Service_Setting__mdt.getInstance('ActiveCampaign');

    public static Boolean getOpenCampaign(String campaignId, String messageId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Endpoint__c + '/admin/api.php?api_action=campaign_report_open_list'+
                            '&campaignid='+ campaignId +'&messageid='+ messageId +'&api_output=json');
        request.setMethod('GET');
        request.setHeader('Api-Token', settings.Token__c);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                                
                // Verifica se o se foi Aberto
                Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());

                return rawObj.get('result_code') == 1 ? true : false;
            } else {
                System.debug('Call failure ActiveCampaignReportOpenListCallout: ' + response.getStatusCode() + ' ' + response.getStatus());
                return null;
            }
        } catch(Exception e) {
            System.debug('Exception ActiveCampaignReportOpenListCallout: ' + e.getMessage());
            return null;
        }
    }
}