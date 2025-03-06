@IsTest
public with sharing class PaymentScheduleGenQueuable_Test {

    @TestSetup
    static void makeData() {
        Account testAccount = TestUtility.createAccount('Test Account', 'Mortgage');
        insert testAccount;
       
        Contact testContact = TestUtility.createContact(testAccount.Id, 'Contact');
        insert testContact;

        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity', 'Qualification', Date.today());
        insert testOpportunity;
    }
    
    @IsTest
    static void PaymentScheduleGenQueuable_createPaymentSchedule_AsyncJobCreated() {

        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        PaymentScheduleGenQueuable.InputParameters params = new PaymentScheduleGenQueuable.InputParameters();
        params.ezPreset = 'Monthly';
        params.scheduleStatus = 'Active';
        params.startDate = Date.today();
        params.endDate = Date.today().addMonths(12);
        params.count = 12;
        params.opportunityId = testOpportunity.Id;
        params.initialAmount = 1000;
        params.eachAmount = 100;
        params.totalAmount = 2200;
        params.currencyITR = 'USD';
        params.description = 'Test Payment Schedule';
        params.accountPs = testAccount.Id;
        params.contactPs = testContact.Id;
        params.recurrenceMethod = 'Automatic';
        params.paymentStatus = 'Pending';
        params.balancePaid = 0;
        params.balanceDue = 2200;
        params.nextPaymentDate = Date.today().addMonths(1);
        params.repeats = 'Monthly';
        params.frequency = 1;
        params.dayOfTheMonth = '1';
        params.captureFirst = true;
        params.autoCapture = true;
        
        Test.startTest();
            PaymentScheduleGenQueuable.createPaymentSchedule(new List<PaymentScheduleGenQueuable.InputParameters>{params});

            List<AsyncApexJob> jobs = [
                SELECT Id, Status, ApexClass.Name 
                FROM AsyncApexJob 
                WHERE ApexClass.Name = 'PaymentScheduleGenQueuable'
            ];
            assert.areEqual(1, jobs.size(), 'Expected one queueable job to be created');
        Test.stopTest();
    }
    
    @IsTest
    static void PaymentScheduleGenQueuable_createPaymentSchedule_EmptyParameters() {
        Test.startTest();
        PaymentScheduleGenQueuable.createPaymentSchedule(new List<PaymentScheduleGenQueuable.InputParameters>());
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'PaymentScheduleGenQueuable'];
        System.assertEquals(0, jobs.size(), 'No job should be created for empty parameters');
    }

}