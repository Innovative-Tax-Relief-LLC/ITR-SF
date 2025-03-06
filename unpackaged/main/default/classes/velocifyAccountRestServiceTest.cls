@IsTest
private class velocifyAccountRestServiceTest {
    
    @IsTest
    static void testCreateAccount_withCardPaymentMethod_Success() {

        String jsonBody = '{' +
            '"api_version": "0.0.3",' +
            '"token": "1VtC_1pqQojIKJKJjsxNbmDYS4qp8BWk",' +
            '"client_data": {' +
                '"is_business": 1,' +
                '"has_income_tax": 1,' +
                '"has_employment_taxes": 0,' +
                '"has_civil_penalty": 0,' +
                '"first_name": "Carlos",' +
                '"middle_name": "M",' +
                '"last_name": "Rodriguez",' +
                '"date_of_birth": "07/15/1985",' +
                '"state": "CA",' +
                '"city": "Los Angeles",' +
                '"street": "123 Sunset Blvd",' +
                '"zip": "90001",' +
                '"home_phone": "3235559876",' +
                '"work_phone": "3235551234",' +
                '"cell_phone": "3235554321",' +
                '"email": "carlosrodriguez@example.com",' +
                '"spouse_first_name": "Ana",' +
                '"spouse_middle_name": "L",' +
                '"spouse_last_name": "Martinez",' +
                '"spouse_date_of_birth": "11/20/1987",' +
                '"spouse_cell_phone": "3235556789",' +
                '"spouse_email": "anamartinez@example.com",' +
                '"notes": "Client inquiring about tax services.",' +
                '"profile_id": 12345,' +
                '"priority": 2,' +
                '"client_source_text": "Referral",' +
                '"billing_info": [' +
                    '{' +
                        '"holder_name": "Carlos Rodriguez",' +
                        '"card_number": "4111111111111111",' +
                        '"type_id": "Visa",' +
                        '"cvv": "321",' +
                        '"expire_year": "2026",' +
                        '"expire_month": "10",' +
                        '"address": "123 Sunset Blvd",' +
                        '"city": "Los Angeles",' +
                        '"state": "CA",' +
                        '"zip": "90001"' +
                    '}' +
                ']' +
            '}' +
        '}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        VelocifyResponseWrapper response = velocifyAccountRestService.createAccount();
        Test.stopTest();

        List<Account> createdAccs = [SELECT Id, FirstName, LastName, PersonEmail, Payment_Method__c FROM Account WHERE Id = :response.data.values() LIMIT 1];
        List<bt_stripe__Payment_Method__c> paymentMethod = [SELECT Id, bt_stripe__Account__c FROM bt_stripe__Payment_Method__c WHERE bt_stripe__Account__c = :createdAccs[0].Id LIMIT 1];
        
        Assert.isTrue(response.success, 'It should be a success');
        Assert.areNotEqual(null, response.data, 'It should return a valid id.');
        Assert.areNotEqual(paymentMethod[0], null, 'It should return a Payment Method.');
        Assert.areEqual('Carlos', createdAccs[0].FirstName, 'Firstname should match');
        Assert.areEqual('Rodriguez', createdAccs[0].LastName, 'Lastname should match');
        Assert.areEqual('carlosrodriguez@example.com', createdAccs[0].PersonEmail, 'Email should match');
        Assert.areEqual(paymentMethod[0].Id, createdAccs[0].Payment_Method__c, 'Payment Method should match');
    }

    @IsTest
    static void testCreateAccount_withACHPaymentMethod_Success() {

        String jsonBody = '{' +
            '"api_version": "0.0.3",' +
            '"token": "1VtC_1pqQojIKJKJjsxNbmDYS4qp8BWk",' +
            '"client_data": {' +
                '"is_business": 1,' +
                '"has_income_tax": 1,' +
                '"has_employment_taxes": 1,' +
                '"has_civil_penalty": 1,' +
                '"first_name": "Laura",' +
                '"middle_name": "L",' +
                '"last_name": "Acosta Fermin",' +
                '"cell_phone": "0000000000",' +
                '"email": "000000@example.com",' +
                '"profile_id": "12345",' +
                '"SalesforceObjectId": "a1B2C3D4E5",' +
                '"ExploratoryServiceType": "Service Type A",' +
                '"Service1": "Consulting",' +
                '"Service2": "Audit",' +
                '"ServiceResolutionType1_1": "Resolution A",' +
                '"ServiceResolutionType2_1": "Resolution B",' +
                '"YearsToFile1": "5",' +
                '"ServiceResolutionType3_1": "Resolution C",' +
                '"YearsToFile2": "3",' +
                '"ServiceResolutionType4_1": "Resolution D",' +
                '"YearsToFile3": "2",' +
                '"ServiceResolutionType5_1": "Resolution E",' +
                '"YearsToFile4": "1",' +
                '"ServiceResolutionType6_1": "Resolution F",' +
                '"GrossResolutionCosts": "1000",' +
                '"NetResolutionCost": "900",' +
                '"payments": [' +
                    '{' +
                        '"down_payment_1_date": "2025-01-01",' +
                        '"down_payment_1": "250",' +
                        '"down_payment_2_date": "2025-02-01",' +
                        '"down_payment_2": "250",' +
                        '"down_payment_3_date": "2025-03-01",' +
                        '"down_payment_3": "250",' +
                        '"down_payment_4_date": "2025-04-01",' +
                        '"down_payment_4": "250"' +
                    '}' +
                '],' +
                '"standard_payments": [' +
                    '{' +
                        '"date_1": "2025-01-01",' +
                        '"amount_1": "100",' +
                        '"date_2": "2025-02-01",' +
                        '"amount_2": "100",' +
                        '"date_3": "2025-03-01",' +
                        '"amount_3": "100",' +
                        '"date_4": "2025-04-01",' +
                        '"amount_4": "100",' +
                        '"date_5": "2025-05-01",' +
                        '"amount_5": "100",' +
                        '"date_6": "2025-06-01",' +
                        '"amount_6": "100",' +
                        '"date_7": "2025-07-01",' +
                        '"amount_7": "100",' +
                        '"date_8": "2025-08-01",' +
                        '"amount_8": "100",' +
                        '"date_9": "2025-09-01",' +
                        '"amount_9": "100",' +
                        '"date_10": "2025-10-01",' +
                        '"amount_10": "100",' +
                        '"date_11": "2025-11-01",' +
                        '"amount_11": "100",' +
                        '"date_12": "2025-12-01",' +
                        '"amount_12": "100"' +
                    '}' +
                '],' +
                '"billing_info": [' +
                    '{' +
                        '"holder_name": "John Doe",' +
                        '"routing_number": "123456789",' +
                        '"account_number": "9876543210",' +
                        '"recurrent_payment": "true",' +
                        '"account_holder_type": "Individual",' +
                        '"credit_card": {' +
                            '"holder_name": "John Doe",' +
                            '"card_number": "4111111111111111",' +
                            '"type_id": "Visa",' +
                            '"cvv": "123",' +
                            '"expire_year": "2027",' +
                            '"expire_month": "12",' +
                            '"address": "123 Main St",' +
                            '"city": "Anytown",' +
                            '"state": "CA",' +
                            '"zip": "12345"' +
                        '}' +
                    '}' +
                '],' +
                '"SecondStandardPayment": "50"' +
            '}' +
        '}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        VelocifyResponseWrapper response = velocifyAccountRestService.createAccount();
        Test.stopTest();

        List<Account> createdAccs = [SELECT Id, FirstName, LastName, PersonEmail FROM Account WHERE Id = :response.data.values() LIMIT 1];
        List<bt_stripe__Payment_Method__c> paymentMethod = [SELECT Id, bt_stripe__Account__c FROM bt_stripe__Payment_Method__c LIMIT 1];

        Assert.areEqual(true, response.success ,'It should be a success');
        Assert.areNotEqual(null, response.data, 'It should return a valid id.');
        Assert.areNotEqual(paymentMethod[0], null, 'It should return a Payment Method.');
        Assert.areEqual('Laura', createdAccs[0].FirstName, 'Firstname should match');
        Assert.areEqual('Acosta Fermin', createdAccs[0].LastName, 'Lastname should match');
        Assert.areEqual('000000@example.com', createdAccs[0].PersonEmail, 'Email should match');
    }

    @IsTest
    static void testCreateAccount_InsertFailure() {

        Test.setMock(HttpCalloutMock.class, VelocifyAccountPaymentMethodMock.error());
        
        String jsonPayload = JSON.serialize(null);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        VelocifyResponseWrapper response = velocifyAccountRestService.createAccount();
        Test.stopTest();

        Assert.areEqual(false, response.success, 'It should not be successful');
    }
    
}