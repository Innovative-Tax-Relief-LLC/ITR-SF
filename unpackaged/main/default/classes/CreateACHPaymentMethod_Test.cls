@IsTest
public with sharing class CreateACHPaymentMethod_Test {
    @TestSetup
    static void makeData() {
       
        Account testAccount = TestUtility.createAccount('Test Account', 'Mortgage');
        insert testAccount;
       
        Contact testContact = TestUtility.createContact(testAccount.Id, 'Contact');
        insert testContact;

        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity', 'Qualification', Date.today());
        testOpportunity.Account_Number__c = '“000123456789”';
        testOpportunity.Routing_Number__c = '“110000000”';
        insert testOpportunity;
    }

    @isTest
    static void createACHPaymentMethod_createPaymentMethod_recordCreated() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        List<Opportunity> testOpportunityList = [SELECT Id, AccountId, ContactId FROM Opportunity LIMIT 1];

        List<CreateACHPaymentMethod.InputParameters> inputList = new List<CreateACHPaymentMethod.InputParameters>();
        CreateACHPaymentMethod.InputParameters input = new CreateACHPaymentMethod.InputParameters();
        input.opportunityId = testOpportunityList[0].Id;
        input.paymentMethodRT = Schema.SObjectType.bt_stripe__Payment_Method__c.getRecordTypeInfosByDeveloperName().get('ACH').getRecordTypeId();
        input.cardholderName = 'John Doe';
        input.currencyIso = 'USD';
        input.countryIso = 'US';
        input.accountHolderType = 'Individual';
        input.accountOpp = account.Id;
        input.contactOpp = contact.Id;
        inputList.add(input);

        Test.startTest();
            List<Id> paymentMethodIds = CreateACHPaymentMethod.createPaymentMethod(inputList);
        Test.stopTest();

        assert.areNotEqual(0, paymentMethodIds.size(), 'Expected a payment method ID to be returned');
        
        bt_stripe__Payment_Method__c createdPaymentMethod = [
            SELECT Id, bt_stripe__Card_Holder_Name__c, bt_stripe__Account_Number__c,
                   bt_stripe__Card_Expiration_Month__c, bt_stripe__Card_Expiration_Year__c
            FROM bt_stripe__Payment_Method__c
            WHERE Id = :paymentMethodIds[0]
        ];
        
        assert.areEqual('John Doe', createdPaymentMethod.bt_stripe__Card_Holder_Name__c, 'Cardholder name mismatch');
    }

    @isTest
    static void createACHPaymentMethod_createPaymentMethod_NullOpportunityId() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        List<Opportunity> testOpportunityList = [SELECT Id, AccountId, ContactId FROM Opportunity LIMIT 1];
        Boolean hasError = false;

        List<CreateACHPaymentMethod.InputParameters> inputList = new List<CreateACHPaymentMethod.InputParameters>();
        CreateACHPaymentMethod.InputParameters input = new CreateACHPaymentMethod.InputParameters();
        input.opportunityId = null;
        input.paymentMethodRT = Schema.SObjectType.bt_stripe__Payment_Method__c.getRecordTypeInfosByDeveloperName().get('ACH').getRecordTypeId();
        input.cardholderName = 'John Doe';
        input.currencyIso = 'USD';
        input.countryIso = 'US';
        input.accountHolderType = 'Individual';
        input.accountOpp = account.Id;
        input.contactOpp = contact.Id;
        inputList.add(input);

        Test.startTest();
            try {
                List<Id> paymentMethodIds = CreateACHPaymentMethod.createPaymentMethod(inputList);
            } catch(Exception e) {
                hasError = true;
            }
        Test.stopTest();
        
        assert.isTrue(hasError, 'Expected an error due to invalid expiry data');
    }
}