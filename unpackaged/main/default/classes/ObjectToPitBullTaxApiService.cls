public without sharing class ObjectToPitBullTaxApiService {
    private static String generateClientJson(Account account, Boolean sendBusinesses){
        List<Map<String, Object>> businessDataList = new List<Map<String, Object>>();

        if (sendBusinesses){
            for (Business__c business : account.Businesses__r) {
                businessDataList.add(new Map<String, Object>{
                    'contact_name_1_phone' => formatPhoneNumber(business.Business_Owner_Phone__c),
                    'contact_name_1_email' => business.Business_Owner_Email__c,
                    'zip' => business.Business_Zip_Code__c,
                    'street' => business.Business_Street__c,
                    'city' => business.Business_City__c,
                    'state' => business.Business_State__c,
                    'ein' => business.FEIN__c,
                    'business_name' => business.Name,
                    'type_of_business' => business.Business_Type__c,
                    'profile_id' => business.Id,
                    'is_business' => 1
                });
            }
        }

        Map<String, Object> clientData = new Map<String, Object>{
            'businesses' => businessDataList,
            'spouse_email' => account.Spouse_Email__pc,
            'spouse_cell_phone' => formatPhoneNumber(account.Spouse_Mobile__pc),
            'spouse_date_of_birth' => formatDate(account.Spouse_Date_of_Birth__pc),
            'spouse_last_name' => account.Spouse_Last_Name__pc,
            'spouse_first_name' => account.Spouse_First_Name__pc,
            'email' => account.PersonEmail,
            'cell_phone' => formatPhoneNumber(account.PersonMobilePhone),
            'work_phone' => formatPhoneNumber(account.Work_Phone__pc),
            'home_phone' => formatPhoneNumber(account.PersonHomePhone),
            'zip' => account.BillingPostalCode,
            'street' => account.BillingStreet,
            'city' => account.BillingCity,
            'state' => account.BillingStateCode,
            'date_of_birth' => formatDate(account.Date_of_Birth__pc),
            'last_name' => account.LastName,
            'first_name' => account.FirstName,
            'profile_id' => account.Id,
            'is_business' => 0
        };

        if(!sendBusinesses) {
            clientData.remove('businesses');
        }
        
        Map<String, Object> payload = new Map<String, Object>{
            'client_data' => clientData
        };

        return JSON.serialize(payload);
    }

    private static String getEndpoint(Boolean isUpdate, String clientId) {
        APIConfiguration config = APIConfigurationHelper.getConfiguration('PitbullTaxAPI');
        
        String baseUrl = '?token=' + EncodingUtil.urlEncode(config.token, 'UTF-8') +
                         '&api_version=' + EncodingUtil.urlEncode(config.apiVersion, 'UTF-8');
        
        if (isUpdate) {
            return '/update' + baseUrl + '&update_by=profile_id' + '&profile_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8');
        } else {
            return '/create' + baseUrl;
        }
    }

    private static void sendJsonToPitbullTaxAPI(String jsonBody, Boolean isUpdate, String clientId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:PitbullTaxAPI' + getEndpoint(isUpdate, clientId));
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);

        try {
            HttpResponse response = http.send(request);
            debugJson(response.getBody());
            if (response.getStatusCode() != 200) {
                throw new CustomException('API call failed', 'API call failed');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error occurred while sending data to API: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void sendClientApi(List<String> ids, Boolean isUpdate, Boolean sendBusinesses) {
        if (ids.isEmpty()) {
            throw new AuraHandledException('No Id were found.');
        }

        List<Id> opportunityIds = new List<Id>();
        List<Id> caseIds = new List<Id>();

        for (String id : ids) {
            if(id.substring(0,3) == '006') {    //opportunity
                opportunityIds.add(id);
            }else if(id.substring(0,3) == '500') {  //case
                caseIds.add(id);
            }
        }

        for (Case oneCase : [SELECT Id, Opportunity__r.Id FROM Case WHERE Id = :caseIds]) {
            opportunityIds.add(oneCase.Opportunity__r.Id);
        }

        List<Opportunity> opportunities = [
            SELECT Id, AccountId 
            FROM Opportunity 
            WHERE Id IN :opportunityIds
        ];

        List<Id> accountIds = new List<Id>();
        for (Opportunity opportunity : opportunities) {
            if (opportunity.AccountId != null) {
                accountIds.add(opportunity.AccountId);
            }
        }

        if (accountIds.isEmpty()) {
            throw new AuraHandledException('No related Accounts found for the provided Opportunity IDs.');
        }

        List<Account> accounts = [
            SELECT Id, 
                FirstName, 
                LastName, 
                Date_of_Birth__pc,
                BillingStateCode,
                BillingCity,
                BillingStreet,
                BillingPostalCode,
                PersonHomePhone,
                Work_Phone__pc,
                PersonMobilePhone,
                PersonEmail,
                Spouse_First_Name__pc, 
                Spouse_Last_Name__pc, 
                Spouse_Date_of_Birth__pc,
                Spouse_Mobile__pc,
                Spouse_Email__pc,
                (SELECT Id,
                    Business_Type__c, 
                    Name, 
                    FEIN__c,
                    Business_State__c,
                    Business_City__c,
                    Business_Street__c,
                    Business_Zip_Code__c,
                    Business_Owner_Email__c,
                    Business_Owner_Phone__c
                FROM Businesses__r)
            FROM Account 
            WHERE Id IN :accountIds
        ];

        for (Account account : accounts) {
            String jsonBody = generateClientJson(account, sendBusinesses);
            sendJsonToPitbullTaxAPI(jsonBody, isUpdate, account.Id);
        }
    }

    private static String formatPhoneNumber(String input) {
        if (String.isBlank(input) || input.length() != 10 || !Pattern.matches('\\d{10}', input)) {
            return null;
        }
        
        String formattedNumber = '(' + input.substring(0, 3) + ')'
                               + input.substring(3, 6) + '-'
                               + input.substring(6, 10);
        
        return formattedNumber;
    }

    public static String formatDate(Date inputDate) {
        if (inputDate == null) {
            return null;
        }

        return Datetime.newInstance(inputDate.year(), inputDate.month(), inputDate.day()).format('MM/dd/yyyy');
    }

    private static void debugJson(Object jsonObject) {
        String jsonString = JSON.serializePretty(jsonObject);
        
        Integer chunkSize = 100;
        Integer totalLength = jsonString.length();
        
        for (Integer i = 0; i < totalLength; i += chunkSize) {
            Integer endIndex = Math.min(i + chunkSize, totalLength);
            System.debug('JSON Chunk ' + (i/chunkSize + 1) + ': ' + jsonString.substring(i, endIndex));
        }
    }
}