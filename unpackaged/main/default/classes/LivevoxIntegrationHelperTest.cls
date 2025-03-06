@isTest
public class LivevoxIntegrationHelperTest {
    @isTest
    static void testManageIntegration() {
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(LastName = 'Test1', Company = 'Company1', LeadSource = 'DT Form'));
        leads.add(new Lead(LastName = 'Test2', Company = 'Company2', LeadSource = 'DT Form DS'));

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
        LivevoxIntegrationHelper.manageIntegration(leads,'INSERT');
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.debug('jobs ' + jobs.size());
        System.assertEquals(1, jobs.size(), 'A job should be enqueued for processing leads with valid LeadSource.');
    }

    @isTest
    static void testManageIntegrationWithNoValidLeads() {

        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(LastName = 'Test1', Company = 'Company1', LeadSource = 'Other Source'));
        leads.add(new Lead(LastName = 'Test2', Company = 'Company2', LeadSource = 'Invalid Source'));

        Test.startTest();
        insert leads;
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable' and ApexClass.Name = 'LivevoxIntegrationQueueable'];
        System.assertEquals(0, jobs.size(), 'No job should be enqueued for invalid LeadSource.');
    }
}