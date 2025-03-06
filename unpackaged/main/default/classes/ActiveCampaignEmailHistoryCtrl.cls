public with sharing class ActiveCampaignEmailHistoryCtrl {
    
    @AuraEnabled
    public static List<Email_History__c> getHistories(String accountId) {
        try{
            return [SELECT Id, Name, Subject__c, Message__c, Date_Time_Shipping__c, Opened__c, Clicked__c 
                    FROM Email_History__c 
                    WHERE AccountId__c = :accountId 
                    ORDER BY Date_Time_Shipping__c DESC 
                    LIMIT 5000];
        } catch(Exception e){
            throw new AuraHandledException('Error searching email histories: '+ e.getMessage());
        }
    }

    @AuraEnabled
    public static ResponseMessage getEmailsHistories(String email, String accountId) {
        Map<String, ActiveCampaignEmailActivitiesResponse.EmailActivities> emailActivityById = new Map<String, ActiveCampaignEmailActivitiesResponse.EmailActivities>();
        ResponseMessage response = new ResponseMessage();
        response.title = 'Success';
        response.message = 'Success when searching email histories';
        response.typeMessage = 'success';

        //Busca o Contato
        ActiveCampaignContactResponse.Contacts contact = ActiveCampaignContactCallout.getContacts(email);

        if(contact != null) {
            // Retorna um lista de Logs onde temos o Id do email, campaignId e MessageId
            List<ActiveCampaignActivitiesResponse.Logs> logs = ActiveCampaignActivitiesCallout.getActivities(contact);

            // // Retorna os dados de Email do Contato
            List<ActiveCampaignEmailActivitiesResponse.EmailActivities> emailsActivities = ActiveCampaignEmailActivitiesCallout.getEmailsActivities(contact);

            if(emailsActivities != null) {
                for(ActiveCampaignEmailActivitiesResponse.EmailActivities emailActivity :emailsActivities) {
                    emailActivityById.put(emailActivity.relid, emailActivity);
                }
            }

            if(logs != null && emailsActivities != null) {
                List<Email_History__c> histories = new List<Email_History__c>();

                for(ActiveCampaignActivitiesResponse.Logs log :logs) {

                    // Verifica se foi encontrado o email
                    if(!emailActivityById.containsKey(log.id)) continue;

                    String campaignId = log.campaign;
                    String messageId = log.message;
                    String relid = log.id;
                    ActiveCampaignEmailActivitiesResponse.EmailActivities emailActivity = emailActivityById.get(relid);
                    Email_History__c history = new Email_History__c();

                    history.Subject__c = emailActivity.subject;
                    history.AccountId__c = accountId;
                    history.Date_Time_Shipping__c = (DateTime)Json.deserialize('"'+emailActivity.tstamp+'"', DateTime.class);
                    history.Message__c = emailActivity.message;
                    history.Id_Externo__c = email + '_' + campaignId + '_' + messageId;

                    // Contatos que abriram a Campanha
                    Boolean Opened = ActiveCampaignReportOpenListCallout.getOpenCampaign(campaignId, messageId);

                    if(Opened != null) {
                        history.Opened__c = Opened;

                        // Verifica se a Campanha foi aberta
                        if(Opened) {
                            //Contatos que clicaram na Link
                            Boolean clicked = ActiveCampaignReportClickListCallout.getClickCampaign(campaignId, messageId, email);

                            if(clicked != null) {
                                history.Clicked__c = clicked;
                            }
                        }
                    }

                    histories.add(history);
                }

                if(histories.size() > 0) {
                    upsert histories Id_Externo__c;
                }
            } else {
                response.title = 'Warning';
                response.message = 'Email activity not found';
                response.typeMessage = 'warning';
            }
        } else {
            response.title = 'Warning';
            response.message = 'Contact not found';
            response.typeMessage = 'warning';
        }

        return response;
    }

    public class ResponseMessage {
        @AuraEnabled public String message;
        @AuraEnabled public String typeMessage;
        @AuraEnabled public String title;
    }
}