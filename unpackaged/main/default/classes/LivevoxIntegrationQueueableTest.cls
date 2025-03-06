@isTest
public class LivevoxIntegrationQueueableTest {
    @TestSetup
    static void makeData(){

        TestDataFactory.createLivevoxConfiguration();

    }
    @isTest
    static void testExecute_Insert() {
        List<Lead> leads = TestDataFactory.buildLeadRecords();
        insert leads;

        Test.startTest();
        RequestMock sessionMock = LivevoxSessionRequestMock.getSuccessSessionId();
        RequestMock livevoxContactMock = LivevoxIntegrationServiceMock.getContactCreateResponse();
        RequestMock sessionValidMock = LivevoxSessionRequestMock.getValidSession();
        RequestMock campaingMock = LivevoxCampaignRequestMock.appendContactToCampaign();

        Map<String,HttpCalloutMock> mockMap = new Map<String,HttpCalloutMock>();
        mockMap.put('callout/session/validate/1212', sessionValidMock);
        mockMap.put('callout/session/login', sessionMock);
        mockMap.put('callout/contact/contacts/', livevoxContactMock);
        mockMap.put('callout/campaign/campaigns/23455/transactions', campaingMock);
        
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(mockMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LivevoxIntegrationQueueable queueable = new LivevoxIntegrationQueueable(leads,'INSERT');
        System.enqueueJob(queueable);
        Test.stopTest();


        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable' and ApexClass.Name = 'LivevoxIntegrationQueueable'];
        Assert.areEqual(1, jobs.size(), 'A Queueable job should be enqueued.');
    }

    @isTest
    static void testExecute_Update() {
        List<Lead> leads = TestDataFactory.buildLeadRecords();
        insert leads;

        Lead updateLead = [SELECT Id, FirstName, LastName, Email, Phone, 
        LeadSource, Total_Tax_Debt__c, Status, MobilePhone FROM Lead WHERE Id = :leads[0].Id];
        updateLead.LeadSource = 'DT Form DS';
        update updateLead;

        Test.startTest();
        RequestMock sessionMock = LivevoxSessionRequestMock.getSuccessSessionId();
        RequestMock livevoxContactMock = LivevoxIntegrationServiceMock.getContactCreateResponse();
        RequestMock sessionValidMock = LivevoxSessionRequestMock.getValidSession();
        RequestMock campaingMock = LivevoxCampaignRequestMock.appendContactToCampaign();

        Map<String,HttpCalloutMock> mockMap = new Map<String,HttpCalloutMock>();
        mockMap.put('callout/session/validate/1212', sessionValidMock);
        mockMap.put('callout/session/login', sessionMock);
        mockMap.put('callout/contact/contacts/', livevoxContactMock);
        mockMap.put('callout/campaign/campaigns/23455/transactions', campaingMock);
        
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(mockMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LivevoxIntegrationQueueable queueable = new LivevoxIntegrationQueueable(leads,'INSERT');
        System.enqueueJob(queueable);
        Test.stopTest();


        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable' and ApexClass.Name = 'LivevoxIntegrationQueueable'];
        Assert.areEqual(1, jobs.size(), 'A Queueable job should be enqueued.');
    }

   
}