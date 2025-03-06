@isTest
private class LivevoxIntegrationServiceTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createLivevoxConfiguration();

       
    }
    @isTest
    static void testCreateLivevoxContact() {
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
        LivevoxIntegrationService.createLivevoxContact(leads[0]);
        Test.stopTest();

        Assert.areEqual('DT Form' ,leads[0].LeadSource, 'LeadSource should be populated');
    }

    @isTest
    static void testUpdateLivevoxContact() {
        List<Lead> leads = TestDataFactory.buildLeadRecords();

        insert leads;

        Lead updateLead = [SELECT Id,FirstName,LastName,Street,
                            City,State,PostalCode,Phone,Email,LeadSource,
                            Total_Tax_Debt__c,CreatedDate,Status,Sub_Status__c, 
                            MobilePhone FROM Lead WHERE Id = :leads[0].Id];
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
        LivevoxIntegrationService.updateLivevoxContact(updateLead);
        Test.stopTest();

        
        Assert.areEqual('DT Form DS', updateLead.LeadSource, 'Field was not updated correctly');
    }

@isTest
static void appendContactToCampaignTest(){
    List<Lead> leads = TestDataFactory.buildLeadRecords();

    
    Test.startTest();
    RequestMock campaingMock = LivevoxCampaignRequestMock.appendContactToCampaign();
    Test.setMock(HttpCalloutMock.class, campaingMock);
    LivevoxIntegrationService.appendContactToCampaign('1234556', leads[0]);
    Test.stopTest();

   }
}