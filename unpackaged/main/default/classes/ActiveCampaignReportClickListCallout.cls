public with sharing class ActiveCampaignReportClickListCallout {
    public static Web_Service_Setting__mdt settings = Web_Service_Setting__mdt.getInstance('ActiveCampaign');

    public static Boolean getClickCampaign(String campaignId, String messageId, String email) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Endpoint__c + '/admin/api.php?api_action=campaign_report_link_list'+
                            '&campaignid='+ campaignId +'&messageid='+ messageId +'&api_output=json');
        request.setMethod('GET');
        request.setHeader('Api-Token', settings.Token__c);

        try {
            Boolean clicked = false;
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {

                // Verifica se o se o link foi clicado
                Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());

                if(rawObj.get('result_code') == 1) {
                    //Lista todos os links disponiveis
                    for(Object obj :rawObj.values()) {    
                        if (obj instanceof Map<String, Object>) {
                            Map<String, Object> mapObj = (Map<String, Object>) obj;
    
                            if (mapObj.get('info') instanceof List<Object>) {
                                //Lista todas as info
                                List<Object> infoList = (List<Object>) mapObj.get('info');
    
                                for(Object info :infoList) {   
                                    if (info instanceof Map<String, Object>) {
                                        Map<String, Object> infoMap = (Map<String, Object>) info;

                                        // Se o email for igual do usuário é porque foi clicado
                                        if(infoMap.get('email') == email) {
                                            clicked = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                return clicked;
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