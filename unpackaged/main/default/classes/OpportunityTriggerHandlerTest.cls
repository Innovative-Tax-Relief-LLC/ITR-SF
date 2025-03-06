@IsTest
private class OpportunityTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        Account acc = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Teste Bussiness'
        );
        insert acc;
    }

    @IsTest
    static void shouldHandleFieldChangesOpportunities() {

        Account acc = [SELECT Id FROM Account];

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('First Trade').getRecordTypeId(),
            Name = 'Teste Opportunity Trade',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(2)
        );

        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new OpportunitiesWebhookCalloutMock());
			insert opp;

			opp.CloseDate = Date.today();
			update opp;
		Test.stopTest();
    }
    
    @IsTest
    static void testGoogleDriveFolderService() {
        // Set mock response
        Test.setMock(HttpCalloutMock.class, new GoogleDriveHttpMock());

        Account acc = [SELECT Id FROM Account];

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('First Trade').getRecordTypeId(),
            Name = 'Teste Opportunity Trade',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(2)
        );

        insert opp;
        // Test the folder retrieval method
        Test.startTest();
   		opp.StageName = 'Investigation';
        opp.Type ='1st Trade';
        opp.Received_Agreements__c = TRUE;
        opp.Received_POAs__c = TRUE;
        opp.Processed_Payment__c = TRUE;
        update opp;
        Test.stopTest();


    }
}