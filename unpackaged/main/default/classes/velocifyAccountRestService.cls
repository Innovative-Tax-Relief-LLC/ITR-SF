@RestResource(urlMapping='/velocifyCreateAccount')
global with sharing class velocifyAccountRestService {

    private static Id achRecordTypeId = Schema.SObjectType.bt_stripe__Payment_Method__c.getRecordTypeInfosByDeveloperName().get('ACH').getRecordTypeId();
    private static Id creditCardRecordTypeId = Schema.SObjectType.bt_stripe__Payment_Method__c.getRecordTypeInfosByDeveloperName().get('Charge_Card').getRecordTypeId();

    @HttpPost
    global static VelocifyResponseWrapper createAccount() {
        try {
            String requestBody = RestContext.request.requestBody.toString();
            VelocifyClientPayload payload = (VelocifyClientPayload) JSON.deserialize(requestBody, VelocifyClientPayload.class);

            if(payload == null) {
                return new VelocifyResponseWrapper(400, false, 'Invalid payload', null);
            }
            
            Account account = new Account();
            Map<String, Object> clientDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(payload.client_data));
            List<ITR_Account_Field_Mapping__mdt> accountFieldMappings = ITR_Account_Field_Mapping__mdt.getAll().values();

            for (ITR_Account_Field_Mapping__mdt cmd : accountFieldMappings) {
                Object value = clientDataMap.get(cmd.ITR_XML_Field__c);
                String sfField = cmd.SFDC_Field__c;

                if((sfField == 'Date_of_Birth__pc' || sfField == 'Spouse_Date_of_Birth__pc') && value != null){
                    account.put(sfField, Date.parse((String)value)); 
                } else if (sfField == 'ITR_Id__c' && value != null) {
                    account.put(sfField, Integer.valueOf((String)value));
                } else {
                    account.put(sfField, value);
                }
            }
            
            upsert account account.ITR_Id__c;

            createPaymentMethod(account.Id, payload);
            Map<String, String> dataMap = new Map<String, String>();
            dataMap.put('id', account.Id);
            return new VelocifyResponseWrapper(200, true, 'Account created successfully', dataMap);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return new VelocifyResponseWrapper(500, false, 'Error: ' + e.getMessage() , null);
        }
    }
    
    public static VelocifyResponseWrapper createPaymentMethod(Id accountId, VelocifyClientPayload payload) {
        
        try {
            bt_stripe__Payment_Method__c newPaymentMethod = new bt_stripe__Payment_Method__c();
            List<ITR_Payment_Method_Field_Mapping__mdt> paymentMethodFieldMappings = ITR_Payment_Method_Field_Mapping__mdt.getAll().values();
            Map<String, Object> billingInfoDataMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(payload.client_data.billing_info[0]));
            
            for(ITR_Payment_Method_Field_Mapping__mdt cmd: paymentMethodFieldMappings) {
                newPaymentMethod.put(cmd.SFDC_Field__c, billingInfoDataMap.get(cmd.ITR_XML_Field__c));
            }
            newPaymentMethod.bt_stripe__Account__c = accountId;
            if (newPaymentMethod.bt_stripe__Account_Number__c != null) {
                newPaymentMethod.RecordTypeId = achRecordTypeId;
                newPaymentMethod.bt_stripe__Send_to_Gateway__c = false;
            } else if (newPaymentMethod.bt_stripe__Card_Number__c != null) {
                newPaymentMethod.RecordTypeId = creditCardRecordTypeId;
                newPaymentMethod.bt_stripe__Send_to_Gateway__c = !Test.isRunningTest();
            } else {
                return new VelocifyResponseWrapper(500, false, 'Payment Method missing required Fields', null);           
            }

            Insert newPaymentMethod;
            Map<String, String> dataMap = new Map<String, String>();
            dataMap.put('id', newPaymentMethod.Id);
            linkAccountPaymentMethod(accountId, newPaymentMethod.Id);
            return new VelocifyResponseWrapper(200, true, 'Payment Method created successfully', dataMap);                
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return new VelocifyResponseWrapper(500, false, 'Payment Method was not created successfully', null);
        }
    }

    public static void linkAccountPaymentMethod(Id accountId, Id paymentMethodId) {
        Account account = [SELECT Id, Payment_Method__c FROM Account WHERE Id = :accountId LIMIT 1];
        account.Payment_Method__c = paymentMethodId;
        update account;
    }
}