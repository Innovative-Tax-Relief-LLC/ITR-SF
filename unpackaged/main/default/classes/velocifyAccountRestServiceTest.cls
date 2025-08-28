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
                '"spouse_middle_initial": "L",' +
                '"spouse_last_name": "Martinez",' +
                '"spouse_date_of_birth": "11/20/1987",' +
                '"spouse_mobile_phone": "3235556789",' +
                '"spouse_email": "anamartinez@example.com",' +
                '"notes": "Client inquiring about tax services.",' +
                '"profile_id": 12345,' +
                '"priority": 2,' +
                '"client_source_text": "Referral",' +
                '"social_security_number": "123456789",' +
                '"marital_status": "Married",' +
                '"gender": "Single",' +
                '"occupation": "Software Engineer",' +
                '"date_of_marriage_to_current_spouse": "11/20/2021",' +
                '"spanish_speaking": "Yes",' +
                '"agency": "State",' +
                '"spouse_gender": "Female",' +
                '"spouse_social_security": "987654321",' +
                '"spouse_occupation": "Nurse",' +
                '"spouse_occupation_category": "Accounting",' +
                '"first_trader": "James, Coy",' +
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

        Assert.isTrue(response.success, 'It should be a success');
        Assert.isNotNull(response.data, 'Data should not be null');

        List<Account> createdAccs = [SELECT Id, FirstName, Velocify_First_Trader__c, LastName, PersonEmail, PersonContactId, Occupation__pc, Marital_Status__pc, Spanish_Speaking__c, Date_of_Marriage_to_Current_Spouse__pc, SSN__pc, Spouse_Social__pc, Spouse_Mobile__pc, Spouse_Middle_Initial__c
                                    FROM Account
                                    WHERE Id = :response.data.values() LIMIT 1];
        List<bt_stripe__Payment_Method__c> paymentMethod = [SELECT Id, bt_stripe__Account__c, bt_stripe__Contact__c
                                                            FROM bt_stripe__Payment_Method__c
                                                            WHERE bt_stripe__Account__c = :createdAccs[0].Id LIMIT 1];


        Assert.areNotEqual(paymentMethod[0], null, 'It should return a Payment Method.');
        Assert.areEqual('Carlos', createdAccs[0].FirstName, 'Firstname should match');
        Assert.areEqual('Rodriguez', createdAccs[0].LastName, 'Lastname should match');
        Assert.areEqual('carlosrodriguez@example.com', createdAccs[0].PersonEmail, 'Email should match');
        Assert.areEqual('Software Engineer', createdAccs[0].Occupation__pc, 'Occupation should match');
        Assert.areEqual('Married', createdAccs[0].Marital_Status__pc, 'Marital Status should match');
        Assert.areEqual('123456789', createdAccs[0].SSN__pc, 'SSN should match');
        Assert.areEqual('James, Coy', createdAccs[0].Velocify_First_Trader__c, 'First Trader should match');
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
    static void testCreateAccount_withACHPaymentMethodAndAnExistingAccount_Success() {

        String jsonBody = '{' +
            '"api_version": "0.0.3",' +
            '"token": "1VtC_1pqQojIKJKJjsxNbmDYS4qp8BWk",' +
            '"client_data": {' +
                '"is_business": 1,' +
                '"has_income_tax": 1,' +
                '"has_employment_taxes": 1,' +
                '"has_civil_penalty": 1,' +
                '"first_name": "John",' +
                '"middle_name": "L",' +
                '"last_name": "Doe",' +
                '"cell_phone": "0000000000",' +
                '"email": "000000@example.com",' +
                '"profile_id": "6265723",' +
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
        Account account = new Account();
        account.FirstName = 'John';
        account.LastName = 'Doe';
        account.ITR_ID__c = 6265722;
        upsert account;
        VelocifyResponseWrapper response = velocifyAccountRestService.createAccount();
        Test.stopTest();

        List<Account> createdAccs = [SELECT Id, FirstName, LastName, PersonEmail, ITR_ID__c FROM Account WHERE Id = :response.data.values() LIMIT 1];
        List<bt_stripe__Payment_Method__c> paymentMethod = [SELECT Id, bt_stripe__Account__c FROM bt_stripe__Payment_Method__c LIMIT 1];

        Assert.areEqual(true, response.success ,'It should be a success');
        Assert.areNotEqual(null, response.data, 'It should return a valid id.');
        Assert.areNotEqual(paymentMethod[0], null, 'It should return a Payment Method.');
        Assert.areEqual(6265723, createdAccs[0].ITR_ID__c, 'Id should match');

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

    @IsTest
    static void testCreateAccount_withFlippedClient_UpdateExistingAccount_Success() {

        Test.startTest();
        Account initialAccount = new Account();
        initialAccount.FirstName = 'Enmanuel';
        initialAccount.LastName = 'Jerez22';
        initialAccount.PersonEmail = 'docs@innovativetaxreliefllc.com';
        initialAccount.SSN__pc = '111-11-1111';
        initialAccount.Occupation__pc = 'Pirate King';
        initialAccount.Gender__pc = 'Male';
        initialAccount.Date_of_Birth__pc = Date.parse('5/1/2025');
        initialAccount.PersonMobilePhone = '(561) 247-0457';

        initialAccount.Spouse_First_Name__pc = 'Spouse Name test';
        initialAccount.Spouse_Last_Name__pc = 'Spouse Lastname test';
        initialAccount.Spouse_Email__pc = 'spouse@spouse.com';
        initialAccount.Spouse_Social__pc = '000-00-0000';
        initialAccount.Spouse_Occupation__c = 'teacher';
        initialAccount.Spouse_Gender__pc = 'Female';
        initialAccount.Spouse_Date_of_Birth__pc = Date.parse('5/15/2025');
        initialAccount.Spouse_Mobile__pc = '(561) 247-0457';

        initialAccount.ITR_Id__c = 6265722;
        insert initialAccount;

        String flippedJsonBody = '{' +
            '"api_version": "0.0.3",' +
            '"token": "1VtC_1pqQojIKJKJjsxNbmDYS4qp8BWk",' +
            '"client_data": {' +
                '"is_business": 0,' +
                '"has_income_tax": 0,' +
                '"has_employment_taxes": 0,' +
                '"has_civil_penalty": 0,' +
                '"first_name": "Spouse Name test",' +
                '"middle_name": "sp",' +
                '"last_name": "Spouse Lastname test",' +
                '"gender": "Female",' +
                '"date_of_birth": "5/15/2025",' +
                '"social_security_number": "000-00-0000",' +
                '"spanish_speaking": "No",' +
                '"agency": "State",' +
                '"marital_status": "Married Filing Separately",' +
                '"date_of_marriage_to_current_spouse": "",' +
                '"occupation": "teacher",' +
                '"occupation_category": "Other",' +
                '"state": "AL",' +
                '"city": "Santiago",' +
                '"street": "Testing Address",' +
                '"zip": "51000",' +
                '"Home_Phone": "(561) 247-0457",' +
                '"work_phone": "(561) 247-0457",' +
                '"cell_phone": "(561) 247-0457",' +
                '"email": "spouse@spouse.com",' +
                '"spouse_first_name": "Enmanuel",' +
                '"spouse_middle_initial": "P",' +
                '"spouse_last_name": "Jerez22",' +
                '"spouse_gender": "Male",' +
                '"spouse_email": "docs@innovativetaxreliefllc.com",' +
                '"spouse_date_of_birth": "5/1/2025",' +
                '"spouse_social_security": "111-11-1111",' +
                '"spouse_mobile_phone": "(561) 247-0457",' +
                '"spouse_occupation": "Pirate King",' +
                '"spouse_occupation_category": "Driving and Transportation",' +
                '"notes": "Test",' +
                '"profile_id": "6265722",' +
                '"priority": 3,' +
                '"lead_source": "Training",' +
                '"flipped_client": "Yes"' +
            '}' +
        '}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(flippedJsonBody);
        RestContext.request = req;
        RestContext.response = res;

        VelocifyResponseWrapper response = velocifyAccountRestService.createAccount();

        Test.stopTest();

        Assert.isTrue(response.success, 'Update with flipped_client should succeed. Error: ' + response.message);
        Assert.areEqual('Account updated successfully with flipped data', response.message, 'Should return flipped update message');
        Assert.isNotNull(response.data, 'Response data should not be null');

        String updatedAccountId = response.data.values()[0];
        Assert.areEqual(initialAccount.Id, updatedAccountId, 'Should be updating the same account');

        List<Account> updatedAccount = [SELECT Id, FirstName, LastName, PersonEmail,
                                            Occupation__pc, SSN__pc, PersonMobilePhone, Gender__pc,
                                            Date_of_Birth__pc,
                                            Spouse_First_Name__pc, Spouse_Last_Name__pc,
                                            Spouse_Email__pc, Spouse_Occupation__c,
                                            Spouse_Social__pc, Spouse_Mobile__pc, Spouse_Gender__pc,
                                            Spouse_Date_of_Birth__pc
                                    FROM Account
                                    WHERE Id = :updatedAccountId LIMIT 1];

        Assert.areEqual('Spouse Name test', updatedAccount[0].FirstName, 'Primary firstname should now be Spouse Name test');
        Assert.areEqual('Spouse Lastname test', updatedAccount[0].LastName, 'Primary lastname should now be Spouse Lastname test');
        Assert.areEqual('spouse@spouse.com', updatedAccount[0].PersonEmail, 'Primary email should now be spouse@spouse.com');
        Assert.areEqual('teacher', updatedAccount[0].Occupation__pc, 'Primary occupation should now be teacher');
        Assert.areEqual('000-00-0000', updatedAccount[0].SSN__pc, 'Primary SSN should now be spouse SSN');
        Assert.areEqual('Female', updatedAccount[0].Gender__pc, 'Primary gender should now be Female');
        Assert.areEqual(Date.parse('5/15/2025'), updatedAccount[0].Date_of_Birth__pc, 'Primary DOB should now be spouse DOB');

        Assert.areEqual('Enmanuel', updatedAccount[0].Spouse_First_Name__pc, 'Spouse firstname should now be Enmanuel');
        Assert.areEqual('Jerez22', updatedAccount[0].Spouse_Last_Name__pc, 'Spouse lastname should now be Jerez22');
        Assert.areEqual('docs@innovativetaxreliefllc.com', updatedAccount[0].Spouse_Email__pc, 'Spouse email should now be Enmanuel email');
        Assert.areEqual('Pirate King', updatedAccount[0].Spouse_Occupation__c, 'Spouse occupation should now be Pirate King');
        Assert.areEqual('111-11-1111', updatedAccount[0].Spouse_Social__pc, 'Spouse SSN should now be Enmanuel SSN');
        Assert.areEqual('Male', updatedAccount[0].Spouse_Gender__pc, 'Spouse gender should now be Male');
        Assert.areEqual(Date.parse('5/1/2025'), updatedAccount[0].Spouse_Date_of_Birth__pc, 'Spouse DOB should now be Enmanuel DOB');

        List<bt_stripe__Payment_Method__c> paymentMethods = [SELECT Id FROM bt_stripe__Payment_Method__c
                                                            WHERE bt_stripe__Account__c = :updatedAccountId];
        Assert.areEqual(0, paymentMethods.size(), 'Should not create payment method on flipped update');
    }

}