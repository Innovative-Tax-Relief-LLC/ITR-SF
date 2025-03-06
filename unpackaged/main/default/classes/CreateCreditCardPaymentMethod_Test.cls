@IsTest
public class CreateCreditCardPaymentMethod_Test {
 	@TestSetup
    static void makeData() {
       
        Account testAccount = TestUtility.createAccount('Test Account', 'Mortgage');
        insert testAccount;
       
        Contact testContact = TestUtility.createContact(testAccount.Id, 'Contact');
        insert testContact;

        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity', 'Qualification', Date.today());
        testOpportunity.Credit_Card_Number__c = '4111111111111111';
        testOpportunity.CVV__c = '123';
        insert testOpportunity;
    }

    @isTest
    static void createCreditPaymentMethod_createPaymentMethod_recordCreated() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        List<Opportunity> testOpportunityList = [SELECT Id, AccountId, ContactId FROM Opportunity LIMIT 1];

        List<CreateCreditCardPaymentMethod.InputParameters> inputList = new List<CreateCreditCardPaymentMethod.InputParameters>();
        CreateCreditCardPaymentMethod.InputParameters input = new CreateCreditCardPaymentMethod.InputParameters();
        input.opportunityId = testOpportunityList[0].Id;
        input.paymentMethodRT = Schema.SObjectType.bt_stripe__Payment_Method__c.getRecordTypeInfosByDeveloperName().get('Charge_Card').getRecordTypeId();
        input.cardholderName = 'John Doe';
        input.expiryMonth = '02';
        input.expiryYear = '24';
        input.postalCode = '12345';
        input.accountOpp = account.Id;
        input.contactOpp = contact.Id;
        inputList.add(input);

        Test.startTest();
            List<Id> paymentMethodIds = CreateCreditCardPaymentMethod.createPaymentMethod(inputList);
        Test.stopTest();

        assert.areNotEqual(0, paymentMethodIds.size(), 'Expected a payment method ID to be returned');
        
        bt_stripe__Payment_Method__c createdPaymentMethod = [
            SELECT Id, bt_stripe__Card_Holder_Name__c, bt_stripe__Card_Number__c,
                   bt_stripe__Card_Expiration_Month__c, bt_stripe__Card_Expiration_Year__c
            FROM bt_stripe__Payment_Method__c
            WHERE Id = :paymentMethodIds[0]
        ];
        
        assert.areEqual('John Doe', createdPaymentMethod.bt_stripe__Card_Holder_Name__c, 'Cardholder name mismatch');
        assert.areEqual('02', createdPaymentMethod.bt_stripe__Card_Expiration_Month__c, 'Expiry month mismatch');
        assert.areEqual('24', createdPaymentMethod.bt_stripe__Card_Expiration_Year__c, 'Expiry year mismatch');
    }

    @isTest
    static void createCreditPaymentMethod_createPaymentMethod_NullOpportunityId() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        List<Opportunity> testOpportunityList = [SELECT Id, AccountId, ContactId FROM Opportunity LIMIT 1];
        Boolean hasError = false;

        List<CreateCreditCardPaymentMethod.InputParameters> inputList = new List<CreateCreditCardPaymentMethod.InputParameters>();
        CreateCreditCardPaymentMethod.InputParameters input = new CreateCreditCardPaymentMethod.InputParameters();
        input.opportunityId = null;
        input.paymentMethodRT = Schema.SObjectType.bt_stripe__Payment_Method__c.getRecordTypeInfosByDeveloperName().get('Charge_Card').getRecordTypeId();
        input.cardholderName = 'John Doe';
        input.expiryMonth = '13';
        input.expiryYear = '20'; 
        input.postalCode = '12345';
        input.accountOpp = account.Id;
        input.contactOpp = contact.Id;
        inputList.add(input);

        Test.startTest();
            try {
                List<Id> paymentMethodIds = CreateCreditCardPaymentMethod.createPaymentMethod(inputList);
            } catch(Exception e) {
                hasError = true;
            }
        Test.stopTest();
        
        assert.isTrue(hasError, 'Expected an error due to invalid expiry data');
    }
    
}