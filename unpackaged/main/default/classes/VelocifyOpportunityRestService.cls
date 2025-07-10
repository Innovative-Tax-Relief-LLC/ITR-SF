@RestResource(UrlMapping='/VelocifyCreateOpportunity')
global with sharing class VelocifyOpportunityRestService {
	private static final Id achRecordTypeId = Schema.SObjectType.bt_stripe__Payment_Method__c.getRecordTypeInfosByDeveloperName().get('ACH').getRecordTypeId();
    private static final Id creditCardRecordTypeId = Schema.SObjectType.bt_stripe__Payment_Method__c.getRecordTypeInfosByDeveloperName().get('Charge_Card').getRecordTypeId();
    private static final Id secondTradersOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Second_Trade').getRecordTypeId();
    private static final Id thirdTradersOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Third_Trade').getRecordTypeId();

    private static Account findAccountByCellphoneAndEmail(String cellphone, String email) {
        if (!Schema.SObjectType.Account.isAccessible()) {
            throw new SecurityException('Insufficient permissions to access Account');
        }
        if(String.isBlank(cellphone) && String.isBlank(email)) {
            return null;
        }
        List<Account> accounts = [
            SELECT Id, FirstName, LastName, PersonEmail, PersonHomePhone, Work_Phone__pc, PersonMobilePhone 
            FROM Account 
            WHERE PersonMobilePhone = :cellphone
            OR PersonEmail = :email
            LIMIT 1
        ];
        
        return accounts.isEmpty() ? null : accounts[0];
    }

    @HttpPost
    global static VelocifyResponseWrapper createOpportunityWithExistingAccount() {
        try {
            String requestBody = RestContext.request.requestBody.toString();            
            VelocifyClientPayload payload = (VelocifyClientPayload) JSON.deserialize(requestBody, VelocifyClientPayload.class);

            if (!validatePayload(payload)) {
                return new VelocifyResponseWrapper(400, false, 'Invalid payload', null);
            }

            Account account = findAccountByCellphoneAndEmail(payload.client_data.cell_phone, payload.client_data.email);
            if(account == null) {
                return new VelocifyResponseWrapper(400, false, 'We could not find an account associated with the provided cell phone and email.', null);
            } 

            Opportunity existingOpportunity = findExistingOpportunity(account.Id);
            if(existingOpportunity != null && existingOpportunity.CreatedDate > Date.today().addDays(-90)
            && (existingOpportunity.RecordTypeId == secondTradersOppRecordTypeId || existingOpportunity.RecordTypeId == thirdTradersOppRecordTypeId)) 
            {
                return new VelocifyResponseWrapper(400, false, 'An Opportunity has been created in the last 3 months for this record type; cannot create a new one.', null);
            }
            
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.Name = account.FirstName + ' ' + account.LastName;
            newOpportunity.AccountId = account.Id;
            newOpportunity.CloseDate = Date.today().addMonths(3);
            newOpportunity.StageName = 'Create CPII';
            setOpportunityRecordType(newOpportunity, payload.client_data.opportunity_type);
            newOpportunity.OwnerId = findOwnerId(payload);

            newOpportunity = mapOpportunityFields(newOpportunity, payload);
            if (newOpportunity.RecordTypeId == null) {
                return new VelocifyResponseWrapper(400, false, 'Invalid Opportunity Type', null);
            }

            insert newOpportunity;
            Map<String, String> dataMap = new Map<String, String>();
            dataMap.put('id', newOpportunity.Id);
            createPaymentMethod(account.Id, payload);
            return new VelocifyResponseWrapper(200, true, 'Opportunity inserted successfully', dataMap);                
        } catch (Exception e) {
            System.debug('Error in createOpportunityWithExistingAccount: ' + e.getMessage());
            return new VelocifyResponseWrapper(500, false, 'Opportunity was not inserted successfully: ' + e.getMessage(), null);
        }
    }

    private static void createPaymentMethod(Id accountId, VelocifyClientPayload payload) {
        try {
            bt_stripe__Payment_Method__c newPaymentMethod = new bt_stripe__Payment_Method__c();
            List<ITR_Payment_Method_Field_Mapping__mdt> paymentMethodFieldMappings = ITR_Payment_Method_Field_Mapping__mdt.getAll().values();
            Map<String, Object> billingInfoDataMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(payload.client_data.billing_info[0]));
            
            for(ITR_Payment_Method_Field_Mapping__mdt cmd: paymentMethodFieldMappings) {
                newPaymentMethod.put(cmd.SFDC_Field__c, billingInfoDataMap.get(cmd.ITR_XML_Field__c));
            }

            newPaymentMethod.bt_stripe__Account__c = accountId;
            
            if (newPaymentMethod.bt_stripe__Routing_Number__c != null) {
                newPaymentMethod.RecordTypeId = achRecordTypeId;
                newPaymentMethod.bt_stripe__Send_to_Gateway__c = false;
            } else if (newPaymentMethod.bt_stripe__Card_Number__c != null) {
                newPaymentMethod.RecordTypeId = creditCardRecordTypeId;
                newPaymentMethod.bt_stripe__Send_to_Gateway__c = !Test.isRunningTest();
            } 

            if (!Schema.SObjectType.bt_stripe__Payment_Method__c.isCreateable()) {
                throw new SecurityException('Insufficient permissions to create Payment Method');
            }
            
            insert newPaymentMethod;
            
        } catch (Exception e) {
            System.debug('Error creating payment method: ' + e.getMessage());
        }
    }

    private static Boolean validatePayload(VelocifyClientPayload payload) {
        if (payload == null || payload.client_data == null || payload.client_data.profile_id == null) {
            return false;
        }
        return true;
    }

    private static Opportunity mapOpportunityFields(Opportunity newOpportunity, VelocifyClientPayload payload) {
        List<ITR_Opportunity_Field_Mapping__mdt> opportunityFieldMappings = ITR_Opportunity_Field_Mapping__mdt.getAll().values();        
        Map<String, Object> clientDataInfoDataMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(payload.client_data));
        Map<String, Object> billingInfoDataMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(payload.client_data.billing_info[0]));
        Map<String, Object> serviceDetailsDataMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(payload.client_data.services.service_details));
        Map<String, Object> downPaymentDataMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(payload.client_data.payments_details.down_payment));
        Map<String, Object> lenderInfoDataMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(payload.client_data.lender_info));
        Map<String, Object> thirdPartyInfoDataMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(payload.client_data.third_party_info));
        
        Set<String> paymentFields = new Set<String>{'Down_Payment_1__c', 'Down_Payment_2__c', 'Down_Payment_3__c', 'Down_Payment_4__c', 'Financining_Amount_Approved__c', 'Amount'};
        Set<String> dateFields = new Set<String>{'Down_Payment_1_Date__c', 'Down_Payment_2_Date__c', 'Down_Payment_3_Date__c', 'Down_Payment_4_Date__c', 'Representation_Start_Date__c'};
        
        for(ITR_Opportunity_Field_Mapping__mdt cmd: opportunityFieldMappings) {
            String sfField = cmd.SFDC_Field__c;
            Object value = clientDataInfoDataMap.get(cmd.ITR_XML_Field__c);
            
            if (value == null) {
                value = billingInfoDataMap.get(cmd.ITR_XML_Field__c);
            }
            if (value == null) {
                value = serviceDetailsDataMap.get(cmd.ITR_XML_Field__c);
            }
            if (value == null) {
                value = downPaymentDataMap.get(cmd.ITR_XML_Field__c);
            }
            if (value == null) {
                value = lenderInfoDataMap.get(cmd.ITR_XML_Field__c);
            }
            if (value == null) {
                value = thirdPartyInfoDataMap.get(cmd.ITR_XML_Field__c);
            }
            
            if (!String.isBlank((String)value)) {
                if (dateFields.contains(sfField)) {
                    newOpportunity.put(sfField, Date.parse((String)value));
                } else if (paymentFields.contains(sfField)) {
                    String valueString = (String)value;
                    valueString = valueString.replaceAll('[$,\\s]', '');
                    newOpportunity.put(sfField, Decimal.valueOf(valueString));
                } else {
                    newOpportunity.put(sfField, value);
                }
            }
        }
        return newOpportunity;
    }

    private static Opportunity findExistingOpportunity(Id accountId) {
        List<Opportunity> existingOpportunityList = [
            SELECT Id, CreatedDate, RecordTypeId
            FROM Opportunity
            WHERE AccountId = :accountId
            AND IsClosed = FALSE
            ORDER BY CreatedDate DESC   
            LIMIT 1
        ];
        return existingOpportunityList.isEmpty() ? null : existingOpportunityList[0];
    }

    private static Opportunity setOpportunityRecordType(Opportunity newOpportunity, String opportunityType) {
        if (opportunityType == '2nd Trade') {
            newOpportunity.RecordTypeId = secondTradersOppRecordTypeId;
        } else if (opportunityType == '3rd Trade') {
            newOpportunity.RecordTypeId = thirdTradersOppRecordTypeId;
        } else {
            return null;
        }
        return newOpportunity;
    }

    private static Id findOwnerId(VelocifyClientPayload payload) {
        String secondTraderName = payload.client_data.second_trader != null ? payload.client_data.second_trader : '';
        if(String.isBlank(secondTraderName)) {
            return null;
        }
        List<User> users = [SELECT Id, IsActive 
                            FROM User 
                            WHERE Name = :secondTraderName AND IsActive = TRUE
                            LIMIT 1];
        if(users.isEmpty()) {
        users = [SELECT Id, IsActive, Name
                FROM User
                WHERE Profile.Name = 'ITR Second Trader' AND IsActive = TRUE
                LIMIT 1];
        }
        return users.isEmpty() ? null : users[0].Id;
    }
}