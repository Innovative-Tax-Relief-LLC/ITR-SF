@isTest
private class GoogleDriveFolderCreatorAccountBasedTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.insertAccountsWithOppsBulk(); 
    }

    @isTest
    static void testGoogleDriveFolderCreatorAccountBased(){
        String secondTradeRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Second Trade').getRecordTypeId();
        Test.startTest();
        List<Account> accountList = [SELECT Id, Name, SSN__pc, Google_Drive_Folder_ID__c, CreatedDate
        FROM Account 
        WHERE Google_Drive_Folder_ID__c = NULL
        AND Id IN (
            SELECT AccountId
            FROM Opportunity 
            WHERE RecordTypeId =:secondTradeRTId
        )];
        Test.setMock(HttpCalloutMock.class, new GoogleDriveHttpMock());
        GoogleDriveFolderCreatorAccountBased batchClassGD = new GoogleDriveFolderCreatorAccountBased();
        ID batchprocessid = Database.executeBatch(batchClassGD,100);
        Test.stopTest();
    }
}