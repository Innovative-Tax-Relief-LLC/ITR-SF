@RestResource(urlMapping='/velocifyCreateAccount')
global with sharing class velocifyAccountRestService {
    private static Id achRecordTypeId = Schema.SObjectType.bt_stripe__Payment_Method__c.getRecordTypeInfosByDeveloperName().get('ACH').getRecordTypeId();
    private static Id creditCardRecordTypeId = Schema.SObjectType.bt_stripe__Payment_Method__c.getRecordTypeInfosByDeveloperName().get('Charge_Card').getRecordTypeId();
    private static final Set<String> SF_DATE_FIELDS = new Set<String>{'Date_of_Birth__pc', 'Spouse_Date_of_Birth__pc', 'Date_of_Marriage_to_Current_Spouse__pc', 'Spouse_Date_of_Birth__pc'};
 
    @HttpPost
    global static VelocifyResponseWrapper createAccount() {
        try {
            String requestBody = RestContext.request.requestBody.toString();
            VelocifyClientPayload payload = (VelocifyClientPayload) JSON.deserialize(requestBody, VelocifyClientPayload.class);

            if(payload == null) {
                return new VelocifyResponseWrapper(400, false, 'Invalid payload', null);
            }
            
            Boolean isFlippedClient = false;
            if(payload.client_data != null) {
                Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
                Map<String, Object> clientDataMap = (Map<String, Object>) payloadMap.get('client_data');
                Object flippedValue = clientDataMap != null ? clientDataMap.get('flipped_client') : null;
                
                System.debug('Flipped client value: ' + flippedValue);
                isFlippedClient = isFlippedClientTrue(flippedValue);
                
                if(isFlippedClient) {
                    System.debug('flipped_client detected - Velocify has already sent flipped data, processing as received');
                }
            }
            
            return processAccount(payload, isFlippedClient);
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return new VelocifyResponseWrapper(500, false, 'Error: ' + e.getMessage(), null);
        }
    }
    
    private static Boolean isFlippedClientTrue(Object flippedClientValue) {
        if (flippedClientValue == null) return false;
        String stringValue = String.valueOf(flippedClientValue).toLowerCase().trim();
        return (stringValue == 'yes' || stringValue == 'true' || stringValue == '1');
    }
    
    private static VelocifyResponseWrapper processAccount(VelocifyClientPayload payload, Boolean isFlippedClient) {
        try {
            Integer itrId = null;
            Map<String, Object> clientDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(payload.client_data));
            if (clientDataMap.get('profile_id') != null) {
                itrId = Integer.valueOf((String)clientDataMap.get('profile_id'));
            }
            
            Boolean isUpdate = false;
            if (itrId != null) {
                List<Account> existing = [SELECT Id FROM Account WHERE ITR_Id__c = :itrId LIMIT 1];
                isUpdate = !existing.isEmpty();
            }
            
            System.debug('Is update: ' + isUpdate + ', isFlippedClient: ' + isFlippedClient);
            
            if (isFlippedClient) {
                System.debug('Processing data already flipped by Velocify - applying directly');
            }
            
            Account account = new Account();
            List<ITR_Account_Field_Mapping__mdt> mappings = ITR_Account_Field_Mapping__mdt.getAll().values();
            
            for (ITR_Account_Field_Mapping__mdt cmd : mappings) {
                Object value = clientDataMap.get(cmd.ITR_XML_Field__c);
                String sfField = cmd.SFDC_Field__c;

                System.debug('Mapping: ' + cmd.ITR_XML_Field__c + ' (' + value + ') -> ' + sfField);

                if (SF_DATE_FIELDS.contains(sfField) && value instanceof String && !String.isBlank((String)value)) {
                    account.put(sfField, Date.parse((String)value)); 
                } else if (SF_DATE_FIELDS.contains(sfField) && value instanceof String && String.isBlank((String)value)) {
                    account.put(sfField, null);
                } else if (sfField == 'ITR_Id__c' && value != null) {
                    account.put(sfField, Integer.valueOf((String)value));
                } else if (sfField.equalsIgnoreCase('flipped_client__c') && value != null) {
                    account.put(sfField, value);
                } else {
                    account.put(sfField, value);
                }
            }
            
            upsert account Account.ITR_Id__c;
            System.debug('Account procesado con ID: ' + account.Id);
            
            if (isUpdate && isFlippedClient) {
                Map<String, String> dataMap = new Map<String, String>();
                dataMap.put('id', account.Id);
                return new VelocifyResponseWrapper(200, true, 'Account updated successfully with flipped data', dataMap);
            } else {
                createPaymentMethod(account.Id, payload);
                Map<String, String> dataMap = new Map<String, String>();
                dataMap.put('id', account.Id);
                String message = isFlippedClient ? 'Account created successfully with flipped data' : 'Account created successfully';
                return new VelocifyResponseWrapper(200, true, message, dataMap);
            }
            
        } catch (Exception e) {
            System.debug('Error in processAccount: ' + e.getMessage());
            return new VelocifyResponseWrapper(500, false, 'Error: ' + e.getMessage(), null);
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
            newPaymentMethod.bt_stripe__Contact__c = [SELECT Id, PersonContactId FROM Account WHERE Id = :accountId]?.PersonContactId;

            if (newPaymentMethod.bt_stripe__Account_Number__c != null) {
                newPaymentMethod.RecordTypeId = achRecordTypeId;
                newPaymentMethod.bt_stripe__Send_to_Gateway__c = false;
            } else if (newPaymentMethod.bt_stripe__Card_Number__c != null) {
                newPaymentMethod.RecordTypeId = creditCardRecordTypeId;
                newPaymentMethod.bt_stripe__Send_to_Gateway__c = !Test.isRunningTest();
            } else {
                return new VelocifyResponseWrapper(500, false, 'Payment Method missing required Fields', null);           
            }

            insert newPaymentMethod;
            Map<String, String> dataMap = new Map<String, String>();
            dataMap.put('id', newPaymentMethod.Id);
            return new VelocifyResponseWrapper(200, true, 'Payment Method created successfully', dataMap);                
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return new VelocifyResponseWrapper(500, false, 'Payment Method was not created successfully', null);
        }
    }
    
    private static String normalizePhone(String phone) {
        if (String.isBlank(phone)) return '';
        return phone.replaceAll('[^0-9]', '');
    }
}