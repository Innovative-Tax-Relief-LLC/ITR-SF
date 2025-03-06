@isTest
public class LivevoxCampaignRequestMock {

    public static String getSuccessAppendCampaignResponse(){
        Lead testLead = new Lead(
            FirstName = 'James',
            LastName = 'Bond',
            Email = 'james.bond@example.com',
            MobilePhone = '5555555555',
            LeadSource = 'DT Form',
            Total_Tax_Debt__c = 50000,
            Status = 'Working'
        );

        LivevoxCampaignRequestWrapper campaingWrapperMock = new LivevoxCampaignRequestWrapper(testLead);
        return JSON.serialize(campaingWrapperMock);
    }

    public static RequestMock appendContactToCampaign(){
        return new RequestMock(ResponseHelper.NO_CONTENT_CODE,ResponseHelper.getStatusCode(ResponseHelper.NO_CONTENT_CODE),getSuccessAppendCampaignResponse());
    }
   
}