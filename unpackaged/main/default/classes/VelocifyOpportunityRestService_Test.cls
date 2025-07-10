@IsTest
private class VelocifyOpportunityRestService_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.insertAccount('John', 'Doe');
        Account account = [SELECT Id, PersonEmail, PersonMobilePhone FROM Account WHERE FirstName = 'John' LIMIT 1];
        account.PersonEmail = 'carlosrodriguez@example.com';
        account.PersonMobilePhone = '3235554321';
        update account;  
    }

    @IsTest
    static void createOpportunityWithExistingAccount_shouldSucceedWithACHPaymentMethod() {

        String jsonBody = '{' +
            '"api_version": "0.0.3",' +
            '"token": "1VtC_1pqQojIKJKJjsxNbmDYS4qp8BWk",' +
            '"client_data": {' +
                '"is_business": 1,' +
                '"has_income_tax": 1,' +
                '"has_employment_taxes": 1,' +
                '"has_civil_penalty": 1,' +
                '"SalesforceObjectId": "",' +
                '"profile_id": "6265722",' +
                '"first_name": "Carlos",' +
                '"middle_name": "M",' +
                '"last_name": "Rodriguez",' +
                '"cell_phone": "3235554321",' +
                '"email": "carlosrodriguez@example.com",' +
                '"opportunity_type": "2nd Trade",' +
                '"payment_threshold": "30%",' +
                '"second_trade_received_agreement_date": "10/22/2024",' +
                '"tax_type": "Personal",' +
                '"solution_type": "Tax Negotiation Only",' +
                '"first_trader": "James, Coy",' +
                '"second_trader": "Maryana Gomez",' +
                '"lender_info": {' +
                    '"financing_lender_used": "Afterpay",' +
                    '"offered_client_financing": "YES",' +
                    '"agreed_client_financing": "YES",' +
                    '"approved_for_financing": "YES",' +
                    '"resquest_amount_to_be_financed": "$40,000.00"' +
                '},' +
                '"third_party_info": {' +
                    '"third_party_name": "Enmanuel 3rd",' +
                    '"third_party_relationship": "Primo",' +
                    '"third_party_phone_number": "(800) 222-2222",' +
                    '"third_party_email": "thirdparty@party.itr.com",' +
                    '"third_party_billing_street": "third party alli",' +
                    '"third_party_city": "Doral",' +
                    '"third_party_state": "AL",' +
                    '"third_party_zip": "51000"' +
                '},' +
                '"services": {' +
                    '"service_details": {' +
                        '"ExploratoryServiceType": "A note about something this textbox is a long text area",' +
                        '"Service1": "IRS Resolution",' +
                        '"Service2": "IRS Resolution",' +
                        '"ServiceResolutionType1_1": "Revenue Officer Representation",' +
                        '"ServiceResolutionType2_1": "Audit Representation: Close Audit",' +
                        '"ServiceResolutionType3_1": "File 1120 tax return",' +
                        '"ServiceResolutionType4_1": "File 941 Payroll tax return",' +
                        '"ServiceResolutionType5_1": "Analyze and submit IRS financials",' +
                        '"ServiceResolutionType6_1": "Analyze and submit IRS financials",' +
                        '"YearsToFile1": "2019",' +
                        '"YearsToFile2": "2020",' +
                        '"YearsToFile4": "2022",' +
                        '"YearsToFile3": "2021",' +
                        '"GrossResolutionCosts": "400",' +
                        '"NetResolutionCost": "$400.00"' +
                    '}' +
                '},' +
                '"payments_details": {' +
                    '"down_payment": {' +
                        '"down_payment_1_date": "1/28/2025",' +
                        '"down_payment_1": "$300.00",' +
                        '"down_payment_2_date": "3/1/2025",' +
                        '"down_payment_2": "$100.00",' +
                        '"down_payment_3_date": "3/7/2025",' +
                        '"down_payment_3": "$100.00",' +
                        '"down_payment_4_date": "3/7/2025",' +
                        '"down_payment_4": "$150.00"' +
                    '},' +
                    '"standard_payments": [' +
                        '{' +
                            '"date_1": "1/27/2025",' +
                            '"amount_1": "$200.00",' +
                            '"date_2": "2/4/2025",' +
                            '"amount_2": "$200.00",' +
                            '"date_3": "2/5/2025",' +
                            '"amount_3": "$200.00",' +
                            '"date_4": "2/13/2025",' +
                            '"amount_4": "$200.00",' +
                            '"date_5": "2/14/2025",' +
                            '"amount_5": "$200.00",' +
                            '"date_6": "2/15/2025",' +
                            '"amount_6": "$200.00",' +
                            '"date_7": "2/12/2025",' +
                            '"amount_7": "$200.00",' +
                            '"date_8": "2/13/2025",' +
                            '"amount_8": "$200.00",' +
                            '"date_9": "2/14/2025",' +
                            '"amount_9": "$200.00",' +
                            '"date_10": "2/5/2025",' +
                            '"amount_10": "$200.00",' +
                            '"date_11": "2/21/2025",' +
                            '"amount_11": "$200.00",' +
                            '"date_12": "2/20/2025",' +
                            '"amount_12": "$200.00"' +
                        '}' +
                    ']' +
                '},' +
                '"billing_info": [' +
                    '{' +
                        '"holder_name": "Enmanuel jerez",' +
                        '"routing_number": "00000000000000000",' +
                        '"account_number": "111111111111111111",' +
                        '"recurrent_payment": "Yes",' +
                        '"account_holder_type": "Company",' +
                        '"card_number": "4111111111111111",' +
                        '"type_id": "1",' +
                        '"cvv": "111",' +
                        '"expire_year": "30",' +
                        '"expire_month": "7",' +
                        '"address": "Testing Address",' +
                        '"city": "Santiago",' +
                        '"state": "AL",' +
                        '"zip": "51000"' +
                    '}' +
                '],' +
                '"SecondStandardPayment": "$200.00"' +
            '}' +
        '}';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            VelocifyResponseWrapper response = VelocifyOpportunityRestService.createOpportunityWithExistingAccount();
        Test.stopTest();

        List<Account> createdAccs = [SELECT Id 
                                    FROM Account 
                                    WHERE PersonMobilePhone = '3235554321' 
                                    LIMIT 1];
        List<bt_stripe__Payment_Method__c> paymentMethod = [SELECT Id, bt_stripe__Account__c, bt_stripe__Account_Number__c 
                                                            FROM bt_stripe__Payment_Method__c 
                                                            WHERE bt_stripe__Account__c = :createdAccs[0].Id 
                                                            LIMIT 1];
        List<Opportunity> createdOpps = [SELECT Id, Account_Number__c, Name, Down_Payment_1__c, Down_Payment_1_Date__c, Payment_Treshold__c, Account_Holder_Type__c, Financining_Amount_Approved__c, OwnerId, X3rd_Party_City__c, X3rd_Party_Zip__c, X3rd_Party_State__c, X3rd_Party_Relationship__c
                                        FROM Opportunity 
                                        WHERE AccountId = :createdAccs[0].Id 
                                        LIMIT 1];

        Assert.areEqual(true, response.success ,'It should be a success');
        Assert.areNotEqual(null, response.data, 'It should return a valid id.');
        Assert.areNotEqual(paymentMethod.size(), 0, 'It should return a Payment Method.');
        Assert.areNotEqual(paymentMethod[0].bt_stripe__Account_Number__c, null, 'It should return an Account Number.');
        Assert.areNotEqual(createdOpps.size(), 0, 'It should return an Opportunity.');
        Assert.areNotEqual(createdOpps[0].Account_Number__c, null, 'It should return an Account Number from Opportunity.');
        Assert.areNotEqual(createdOpps[0].Name, null, 'It should return a Name from Opportunity.');
        Assert.areNotEqual(null, createdOpps[0].Account_Holder_Type__c, 'There should be an Account Holder Type.');
        Assert.areNotEqual(null, createdOpps[0].Financining_Amount_Approved__c, 'There should be a Financining Amount Approved.');
        Assert.areNotEqual(null, createdOpps[0].X3rd_Party_City__c, 'There should be an third party name.');
        Assert.areNotEqual(null, createdOpps[0].X3rd_Party_Relationship__c, 'There should be an third party name.');
        Assert.areNotEqual(null, createdOpps[0].X3rd_Party_State__c, 'There should be an third party name.');
        Assert.areNotEqual(null, createdOpps[0].X3rd_Party_Zip__c, 'There should be an third party name.');
    }

    @IsTest
    static void createOpportunityWithExistingAccount_shouldFailWithNullJSON() {

        String jsonBody = '';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            VelocifyResponseWrapper response = VelocifyOpportunityRestService.createOpportunityWithExistingAccount();
        Test.stopTest();

        Assert.areEqual(false, response.success ,'It should fail');
    }

    @IsTest
    static void createOpportunityWithExistingAccount_shouldFailWithMissingRequiredFields() {

        String jsonBody = '{' +
            '"api_version": "0.0.3",' +
            '"token": "1VtC_1pqQojIKJKJjsxNbmDYS4qp8BWk",' +
            '"client_data": {' +
                '"is_business": 1,' +
                '"has_income_tax": 1,' +
                '"has_employment_taxes": 1,' +
                '"has_civil_penalty": 1,' +
                '"SalesforceObjectId": "",' +
                '"profile_id": null,' +
                '"opportunity_type": "2nd Trade",' +
                '"services": {' +
                    '"service_details": {' +
                        '"ExploratoryServiceType": "A note about something this textbox is a long text area",' +
                        '"Service1": "IRS Resolution",' +
                        '"Service2": "IRS Resolution",' +
                        '"ServiceResolutionType1_1": "Revenue Officer Representation",' +
                        '"ServiceResolutionType2_1": "Audit Representation: Close Audit",' +
                        '"ServiceResolutionType3_1": "File 1120 tax return",' +
                        '"ServiceResolutionType4_1": "File 941 Payroll tax return",' +
                        '"ServiceResolutionType5_1": "Analyze and submit IRS financials",' +
                        '"ServiceResolutionType6_1": "Analyze and submit IRS financials",' +
                        '"YearsToFile1": "2019",' +
                        '"YearsToFile2": "2020",' +
                        '"YearsToFile4": "2022",' +
                        '"YearsToFile3": "2021",' +
                        '"GrossResolutionCosts": "400",' +
                        '"NetResolutionCost": "$400.00"' +
                    '}' +
                '},' +
                '"payments_details": {' +
                    '"down_payment": {' +
                        '"down_payment_1_date": "1/28/2025",' +
                        '"down_payment_1": "$300.00",' +
                        '"down_payment_2_date": "3/1/2025",' +
                        '"down_payment_2": "$100.00",' +
                        '"down_payment_3_date": "3/7/2025",' +
                        '"down_payment_3": "$100.00",' +
                        '"down_payment_4_date": "3/7/2025",' +
                        '"down_payment_4": "$150.00"' +
                    '},' +
                    '"standard_payments": [' +
                        '{' +
                            '"date_1": "1/27/2025",' +
                            '"amount_1": "$200.00",' +
                            '"date_2": "2/4/2025",' +
                            '"amount_2": "$200.00",' +
                            '"date_3": "2/5/2025",' +
                            '"amount_3": "$200.00",' +
                            '"date_4": "2/13/2025",' +
                            '"amount_4": "$200.00",' +
                            '"date_5": "2/14/2025",' +
                            '"amount_5": "$200.00",' +
                            '"date_6": "2/15/2025",' +
                            '"amount_6": "$200.00",' +
                            '"date_7": "2/12/2025",' +
                            '"amount_7": "$200.00",' +
                            '"date_8": "2/13/2025",' +
                            '"amount_8": "$200.00",' +
                            '"date_9": "2/14/2025",' +
                            '"amount_9": "$200.00",' +
                            '"date_10": "2/5/2025",' +
                            '"amount_10": "$200.00",' +
                            '"date_11": "2/21/2025",' +
                            '"amount_11": "$200.00",' +
                            '"date_12": "2/20/2025",' +
                            '"amount_12": "$200.00"' +
                        '}' +
                    ']' +
                '},' +
                '"billing_info": [' +
                    '{' +
                        '"holder_name": "Enmanuel jerez",' +
                        '"routing_number": "00000000000000000",' +
                        '"account_number": "111111111111111111",' +
                        '"recurrent_payment": "Yes",' +
                        '"account_holder_type": "Company",' +
                        '"card_number": "4111111111111111",' +
                        '"type_id": "1",' +
                        '"cvv": "111",' +
                        '"expire_year": "30",' +
                        '"expire_month": "7",' +
                        '"address": "Testing Address",' +
                        '"city": "Santiago",' +
                        '"state": "AL",' +
                        '"zip": "51000"' +
                    '}' +
                '],' +
                '"SecondStandardPayment": "$200.00"' +
            '}' +
        '}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            VelocifyResponseWrapper response = VelocifyOpportunityRestService.createOpportunityWithExistingAccount();
        Test.stopTest();

        Assert.areEqual(false, response.success ,'It should fail');
    }

    @IsTest
    static void createOpportunityWithExistingAccount_shouldSucceedWithCardPaymentMethod() {

        String jsonBody = '{' +
            '"api_version": "0.0.3",' +
            '"token": "1VtC_1pqQojIKJKJjsxNbmDYS4qp8BWk",' +
            '"client_data": {' +
                '"is_business": 1,' +
                '"has_income_tax": 1,' +
                '"has_employment_taxes": 1,' +
                '"has_civil_penalty": 1,' +
                '"SalesforceObjectId": "",' +
                '"payment_threshold": "Down Payment",' +
                '"profile_id": "6265722",' +
                '"first_name": "Carlos",' +
                '"middle_name": "M",' +
                '"last_name": "Rodriguez",' +
                '"cell_phone": "3235554321",' +
                '"email": "carlosrodriguez@example.com",' +
                '"opportunity_type": "2nd Trade",' +
                '"second_trade_received_agreement_date": "10/22/2024",' +
                '"tax_type": "Personal",' +
                '"solution_type": "Tax Negotiation Only",' +
                '"first_trader": "James, Coy",' +
                '"second_trader": "Maryana Gomez",' +
                '"lender_info": {' +
                    '"financing_lender_used": "AfterPay",' +
                    '"offered_client_financing": "YES",' +
                    '"agreed_client_financing": "YES",' +
                    '"approved_for_financing": "YES",' +
                    '"resquest_amount_to_be_financed": "$40,000.00"' +
                '},' +
                '"third_party_info": {' +
                    '"third_party_name": "Enmanuel 3rd",' +
                    '"third_party_relationship": "Primo",' +
                    '"third_party_phone_number": "(800) 222-2222",' +
                    '"third_party_email": "thirdparty@party.itr.com",' +
                    '"third_party_billing_street": "third party alli",' +
                    '"third_party_city": "Doral",' +
                    '"third_party_state": "FL",' +
                    '"third_party_zip": "51003"' +
                '},' +
                '"services": {' +
                    '"service_details": {' +
                        '"ExploratoryServiceType": "A note about something this textbox is a long text area",' +
                        '"Service1": "IRS Resolution",' +
                        '"Service2": "IRS Resolution",' +
                        '"ServiceResolutionType1_1": "Revenue Officer Representation",' +
                        '"ServiceResolutionType2_1": "Audit Representation: Close Audit",' +
                        '"ServiceResolutionType3_1": "File 1120 tax return",' +
                        '"ServiceResolutionType4_1": "File 941 Payroll tax return",' +
                        '"ServiceResolutionType5_1": "Analyze and submit IRS financials",' +
                        '"ServiceResolutionType6_1": "Analyze and submit IRS financials",' +
                        '"YearsToFile1": "2019",' +
                        '"YearsToFile2": "2020",' +
                        '"YearsToFile4": "2022",' +
                        '"YearsToFile3": "2021",' +
                        '"GrossResolutionCosts": "400",' +
                        '"NetResolutionCost": "$400.00"' +
                    '}' +
                '},' +
                '"payments_details": {' +
                    '"down_payment": {' +
                        '"down_payment_1_date": "1/28/2025",' +
                        '"down_payment_1": "$300.00",' +
                        '"down_payment_2_date": "3/1/2025",' +
                        '"down_payment_2": "$100.00",' +
                        '"down_payment_3_date": "3/7/2025",' +
                        '"down_payment_3": "$100.00",' +
                        '"down_payment_4_date": "2/13/2025",' +
                        '"down_payment_4": "$100.00"' +
                    '},' +
                    '"standard_payments": [' +
                        '{' +
                            '"date_1": "1/27/2025",' +
                            '"amount_1": "$200.00",' +
                            '"date_2": "2/4/2025",' +
                            '"amount_2": "$200.00",' +
                            '"date_3": "2/5/2025",' +
                            '"amount_3": "$200.00",' +
                            '"date_4": "2/13/2025",' +
                            '"amount_4": "$200.00",' +
                            '"date_5": "2/14/2025",' +
                            '"amount_5": "$200.00",' +
                            '"date_6": "2/15/2025",' +
                            '"amount_6": "$200.00",' +
                            '"date_7": "2/12/2025",' +
                            '"amount_7": "$200.00",' +
                            '"date_8": "2/13/2025",' +
                            '"amount_8": "$200.00",' +
                            '"date_9": "2/14/2025",' +
                            '"amount_9": "$200.00",' +
                            '"date_10": "2/5/2025",' +
                            '"amount_10": "$200.00",' +
                            '"date_11": "2/21/2025",' +
                            '"amount_11": "$200.00",' +
                            '"date_12": "2/20/2025",' +
                            '"amount_12": "$200.00"' +
                        '}' +
                    ']' +
                '},' +
                '"billing_info": [' +
                    '{' +
                        '"holder_name": "Enmanuel Jerez",' +
                        '"card_number": "4242424242424242",' +
                        '"type_id": "1",' +
                        '"cvv": "789",' +
                        '"expire_year": "28",' +
                        '"expire_month": "08",' +
                        '"account_holder_type": "Company",' +
                        '"address": "Testing Address",' +
                        '"city": "Santiago",' +
                        '"state": "AL",' +
                        '"zip": "51000"' +
                    '}' +
                '],' +
                '"SecondStandardPayment": "$200.00"' +
            '}' +
        '}';


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            VelocifyResponseWrapper response = VelocifyOpportunityRestService.createOpportunityWithExistingAccount();
        Test.stopTest();

        List<Account> createdAccs = [SELECT Id 
                                    FROM Account 
                                    WHERE PersonMobilePhone = '3235554321'  
                                    LIMIT 1];
        List<bt_stripe__Payment_Method__c> paymentMethod = [SELECT Id, bt_stripe__Card_Number__c, bt_stripe__Account_Number__c 
                                                            FROM bt_stripe__Payment_Method__c 
                                                            WHERE bt_stripe__Account__c = :createdAccs[0].Id 
                                                            LIMIT 1];
        List<Opportunity> createdOpps = [SELECT Id, Credit_Card_Number__c, Name, Down_Payment_1__c, Down_Payment_1_Date__c, Account_Holder_Type__c
                                        FROM Opportunity 
                                        WHERE AccountId = :createdAccs[0].Id 
                                        LIMIT 1];

        Assert.areEqual(true, response.success ,'It should be a success');
        Assert.areNotEqual(null, response.data, 'It should return a valid id.');
        Assert.areNotEqual(paymentMethod.size(), 0, 'It should return a Payment Method.');
        Assert.areNotEqual(paymentMethod[0].bt_stripe__Card_Number__c, null, 'It should return an Account Number.');
        Assert.areNotEqual(createdOpps[0].Account_Holder_Type__c, null, 'There should be an Account Holder Type.');
        Assert.areNotEqual(createdOpps.size(), 0, 'It should return an Opportunity.');
        Assert.areNotEqual(createdOpps[0].Credit_Card_Number__c, null, 'It should return a Credit Card Number from Opportunity.');
        Assert.areNotEqual(createdOpps[0].Name, null, 'It should return a Name from Opportunity.');
    }

    @IsTest
    static void createOpportunityWithExistingAccount_shouldFailWhenOpportunityExistsWithinLast90Days() {

        String jsonBody = '{' +
            '"api_version": "0.0.3",' +
            '"token": "1VtC_1pqQojIKJKJjsxNbmDYS4qp8BWk",' +
            '"client_data": {' +
                '"is_business": 1,' +
                '"has_income_tax": 1,' +
                '"has_employment_taxes": 1,' +
                '"has_civil_penalty": 1,' +
                '"SalesforceObjectId": "",' +
                '"payment_threshold": "Down Payment",' +
                '"profile_id": "6265722",' +
                '"first_name": "Carlos",' +
                '"middle_name": "M",' +
                '"last_name": "Rodriguez",' +
                '"cell_phone": "3235554321",' +
                '"email": "carlosrodriguez@example.com",' +
                '"opportunity_type": "2nd Trade",' +
                '"second_trade_received_agreement_date": "10/22/2024",' +
                '"tax_type": "Personal",' +
                '"solution_type": "Tax Negotiation Only",' +
                '"first_trader": "James, Coy",' +
                '"second_trader": "Maryana Gomez",' +
                '"lender_info": {' +
                    '"financing_lender_used": "AfterPay",' +
                    '"offered_client_financing": "YES",' +
                    '"agreed_client_financing": "YES",' +
                    '"approved_for_financing": "YES",' +
                    '"resquest_amount_to_be_financed": "$40,000.00"' +
                '},' +
                '"third_party_info": {' +
                    '"third_party_name": "Enmanuel 3rd",' +
                    '"third_party_relationship": "Primo",' +
                    '"third_party_phone_number": "(800) 222-2222",' +
                    '"third_party_email": "thirdparty@party.itr.com",' +
                    '"third_party_billing_street": "third party alli",' +
                    '"third_party_city": "Doral",' +
                    '"third_party_state": "FL",' +
                    '"third_party_zip": "51003"' +
                '},' +
                '"services": {' +
                    '"service_details": {' +
                        '"ExploratoryServiceType": "A note about something this textbox is a long text area",' +
                        '"Service1": "IRS Resolution",' +
                        '"Service2": "IRS Resolution",' +
                        '"ServiceResolutionType1_1": "Revenue Officer Representation",' +
                        '"ServiceResolutionType2_1": "Audit Representation: Close Audit",' +
                        '"ServiceResolutionType3_1": "File 1120 tax return",' +
                        '"ServiceResolutionType4_1": "File 941 Payroll tax return",' +
                        '"ServiceResolutionType5_1": "Analyze and submit IRS financials",' +
                        '"ServiceResolutionType6_1": "Analyze and submit IRS financials",' +
                        '"YearsToFile1": "2019",' +
                        '"YearsToFile2": "2020",' +
                        '"YearsToFile4": "2022",' +
                        '"YearsToFile3": "2021",' +
                        '"GrossResolutionCosts": "400",' +
                        '"NetResolutionCost": "$400.00"' +
                    '}' +
                '},' +
                '"payments_details": {' +
                    '"down_payment": {' +
                        '"down_payment_1_date": "1/28/2025",' +
                        '"down_payment_1": "$300.00",' +
                        '"down_payment_2_date": "3/1/2025",' +
                        '"down_payment_2": "$100.00",' +
                        '"down_payment_3_date": "3/7/2025",' +
                        '"down_payment_3": "$100.00",' +
                        '"down_payment_4_date": "2/13/2025",' +
                        '"down_payment_4": "$100.00"' +
                    '},' +
                    '"standard_payments": [' +
                        '{' +
                            '"date_1": "1/27/2025",' +
                            '"amount_1": "$200.00",' +
                            '"date_2": "2/4/2025",' +
                            '"amount_2": "$200.00",' +
                            '"date_3": "2/5/2025",' +
                            '"amount_3": "$200.00",' +
                            '"date_4": "2/13/2025",' +
                            '"amount_4": "$200.00",' +
                            '"date_5": "2/14/2025",' +
                            '"amount_5": "$200.00",' +
                            '"date_6": "2/15/2025",' +
                            '"amount_6": "$200.00",' +
                            '"date_7": "2/12/2025",' +
                            '"amount_7": "$200.00",' +
                            '"date_8": "2/13/2025",' +
                            '"amount_8": "$200.00",' +
                            '"date_9": "2/14/2025",' +
                            '"amount_9": "$200.00",' +
                            '"date_10": "2/5/2025",' +
                            '"amount_10": "$200.00",' +
                            '"date_11": "2/21/2025",' +
                            '"amount_11": "$200.00",' +
                            '"date_12": "2/20/2025",' +
                            '"amount_12": "$200.00"' +
                        '}' +
                    ']' +
                '},' +
                '"billing_info": [' +
                    '{' +
                        '"holder_name": "Enmanuel Jerez",' +
                        '"card_number": "4242424242424242",' +
                        '"type_id": "1",' +
                        '"cvv": "789",' +
                        '"expire_year": "28",' +
                        '"expire_month": "08",' +
                        '"address": "Testing Address",' +
                        '"city": "Santiago",' +
                        '"state": "AL",' +
                        '"zip": "51000"' +
                    '}' +
                '],' +
                '"SecondStandardPayment": "$200.00"' +
            '}' +
        '}';


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Account account = [SELECT Id, PersonEmail, PersonMobilePhone FROM Account WHERE FirstName = 'John' LIMIT 1];
        TestDataFactory.createTestOpportunityWithRecordType(account.Id, 'Second_Trade', 'Prospecting');
        Opportunity opp = [SELECT Id, CreatedDate FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];
        Test.setCreatedDate(opp.Id, DateTime.now().addDays(-60));
        Test.startTest();
            VelocifyResponseWrapper response = VelocifyOpportunityRestService.createOpportunityWithExistingAccount();
        Test.stopTest();

        Assert.areEqual(false, response.success ,'It should be a fail');
        Assert.areEqual('An Opportunity has been created in the last 3 months for this record type; cannot create a new one.', response.message, 'It should return a valid id.');
    }

    @IsTest
    static void createOpportunityWithExistingAccount_shouldSucceedWhenOpportunityExistsWithinLast90DaysButItsClosed() {

        String jsonBody = '{' +
            '"api_version": "0.0.3",' +
            '"token": "1VtC_1pqQojIKJKJjsxNbmDYS4qp8BWk",' +
            '"client_data": {' +
                '"is_business": 1,' +
                '"has_income_tax": 1,' +
                '"has_employment_taxes": 1,' +
                '"has_civil_penalty": 1,' +
                '"SalesforceObjectId": "",' +
                '"payment_threshold": "Down Payment",' +
                '"profile_id": "6265722",' +
                '"first_name": "Carlos",' +
                '"middle_name": "M",' +
                '"last_name": "Rodriguez",' +
                '"cell_phone": "3235554321",' +
                '"email": "carlosrodriguez@example.com",' +
                '"opportunity_type": "2nd Trade",' +
                '"second_trade_received_agreement_date": "10/22/2024",' +
                '"tax_type": "Personal",' +
                '"solution_type": "Tax Negotiation Only",' +
                '"first_trader": "James, Coy",' +
                '"second_trader": "Maryana Gomez",' +
                '"lender_info": {' +
                    '"financing_lender_used": "AfterPay",' +
                    '"offered_client_financing": "YES",' +
                    '"agreed_client_financing": "YES",' +
                    '"approved_for_financing": "YES",' +
                    '"resquest_amount_to_be_financed": "$40,000.00"' +
                '},' +
                '"third_party_info": {' +
                    '"third_party_name": "Enmanuel 3rd",' +
                    '"third_party_relationship": "Primo",' +
                    '"third_party_phone_number": "(800) 222-2222",' +
                    '"third_party_email": "thirdparty@party.itr.com",' +
                    '"third_party_billing_street": "third party alli",' +
                    '"third_party_city": "Doral",' +
                    '"third_party_state": "FL",' +
                    '"third_party_zip": "51003"' +
                '},' +
                '"services": {' +
                    '"service_details": {' +
                        '"ExploratoryServiceType": "A note about something this textbox is a long text area",' +
                        '"Service1": "IRS Resolution",' +
                        '"Service2": "IRS Resolution",' +
                        '"ServiceResolutionType1_1": "Revenue Officer Representation",' +
                        '"ServiceResolutionType2_1": "Audit Representation: Close Audit",' +
                        '"ServiceResolutionType3_1": "File 1120 tax return",' +
                        '"ServiceResolutionType4_1": "File 941 Payroll tax return",' +
                        '"ServiceResolutionType5_1": "Analyze and submit IRS financials",' +
                        '"ServiceResolutionType6_1": "Analyze and submit IRS financials",' +
                        '"YearsToFile1": "2019",' +
                        '"YearsToFile2": "2020",' +
                        '"YearsToFile4": "2022",' +
                        '"YearsToFile3": "2021",' +
                        '"GrossResolutionCosts": "400",' +
                        '"NetResolutionCost": "$400.00"' +
                    '}' +
                '},' +
                '"payments_details": {' +
                    '"down_payment": {' +
                        '"down_payment_1_date": "1/28/2025",' +
                        '"down_payment_1": "$300.00",' +
                        '"down_payment_2_date": "3/1/2025",' +
                        '"down_payment_2": "$100.00",' +
                        '"down_payment_3_date": "3/7/2025",' +
                        '"down_payment_3": "$100.00",' +
                        '"down_payment_4_date": "2/13/2025",' +
                        '"down_payment_4": "$100.00"' +
                    '},' +
                    '"standard_payments": [' +
                        '{' +
                            '"date_1": "1/27/2025",' +
                            '"amount_1": "$200.00",' +
                            '"date_2": "2/4/2025",' +
                            '"amount_2": "$200.00",' +
                            '"date_3": "2/5/2025",' +
                            '"amount_3": "$200.00",' +
                            '"date_4": "2/13/2025",' +
                            '"amount_4": "$200.00",' +
                            '"date_5": "2/14/2025",' +
                            '"amount_5": "$200.00",' +
                            '"date_6": "2/15/2025",' +
                            '"amount_6": "$200.00",' +
                            '"date_7": "2/12/2025",' +
                            '"amount_7": "$200.00",' +
                            '"date_8": "2/13/2025",' +
                            '"amount_8": "$200.00",' +
                            '"date_9": "2/14/2025",' +
                            '"amount_9": "$200.00",' +
                            '"date_10": "2/5/2025",' +
                            '"amount_10": "$200.00",' +
                            '"date_11": "2/21/2025",' +
                            '"amount_11": "$200.00",' +
                            '"date_12": "2/20/2025",' +
                            '"amount_12": "$200.00"' +
                        '}' +
                    ']' +
                '},' +
                '"billing_info": [' +
                    '{' +
                        '"holder_name": "Enmanuel Jerez",' +
                        '"card_number": "4242424242424242",' +
                        '"type_id": "1",' +
                        '"cvv": "789",' +
                        '"expire_year": "28",' +
                        '"expire_month": "08",' +
                        '"address": "Testing Address",' +
                        '"city": "Santiago",' +
                        '"state": "AL",' +
                        '"zip": "51000"' +
                    '}' +
                '],' +
                '"SecondStandardPayment": "$200.00"' +
            '}' +
        '}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Account account = [SELECT Id, PersonEmail, PersonMobilePhone FROM Account WHERE FirstName = 'John' LIMIT 1];
        TestDataFactory.createTestOpportunityWithRecordType(account.Id, 'Second_Trade', 'Closed Won');
        Opportunity opp = [SELECT Id, CreatedDate FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];
        Test.setCreatedDate(opp.Id, DateTime.now().addDays(-60));
        Test.startTest();
            VelocifyResponseWrapper response = VelocifyOpportunityRestService.createOpportunityWithExistingAccount();
        Test.stopTest();

        Assert.areEqual(true, response.success ,'It should be a fail');
    }
}