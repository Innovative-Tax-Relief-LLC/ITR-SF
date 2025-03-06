@isTest
private class LivevoxCampaignRequestWrapperTest {

    @TestSetup
    static void makeData(){
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '(650) 555-1234',
            ///Velocify_Id__c = '123456',
            Company = 'Test Company',
            Status = 'Working'
        );
        insert testLead;
    }
    @isTest
    static void testCampaignRequestWrapper() {
        Lead testLead = [SELECT Id, FirstName,LastName,Street,
        City,State,PostalCode,Phone,Email,LeadSource,MobilePhone,
        Total_Tax_Debt__c,CreatedDate,Status,Sub_Status__c
        FROM Lead WHERE FirstName ='John' LIMIT 1]; 

        LivevoxCampaignRequestWrapper wrapper = new LivevoxCampaignRequestWrapper(testLead);
        
        Assert.areEqual(1, wrapper.records.size(), 'Wrapper should contain one record');

        LivevoxCampaignRequestWrapper.CampaignRecord record = wrapper.records[0];

        
        Assert.areEqual('6505551234', record.phone1, 'Phone number should be formatted correctly');
        //Assert.areEqual(testLead.Velocify_Id__c, record.account, 'Account field should match the lead Velocify_Id__c');
        
    }

  
}