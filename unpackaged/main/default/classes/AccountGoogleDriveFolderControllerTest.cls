@isTest
private class AccountGoogleDriveFolderControllerTest {
    @TestSetup
    static void makeData(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account account = new Account(
                FirstName = 'Test',
                LastName = ' Account GD ',
                Google_Drive_Folder_ID__c = null,
                RecordTypeId = recordTypeId
            );
        
        insert account;
    }

    @isTest
    static void testGoogleDriveFolderCreatorQuickAction(){
        Test.startTest();
        List<Account> accountList = [ SELECT Id, Name, SSN__pc, Google_Drive_Folder_ID__c, CreatedDate
                FROM Account
                WHERE Google_Drive_Folder_ID__c = NULL];
        Test.setMock(HttpCalloutMock.class, new GoogleDriveHttpMock());
        AccountGoogleDriveFolderController.processGoogleDriveFolderRequest(accountList[0].Id);

        Test.stopTest();
        Account updatedAcc = [ SELECT Id, Name, SSN__pc, Google_Drive_Folder_ID__c, CreatedDate
        FROM Account];

        Assert.areEqual('mockFolderId123', updatedAcc.Google_Drive_Folder_ID__c, 
        'The folder ID should be updated on the Account.');

    }

    @isTest
    static void testGoogleDriveFolderCreatorQuickAction_incorrectRecordType_expectException(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String message ='';
        Account account = new Account(
            Name = 'Test Account NOT PA ',
            Google_Drive_Folder_ID__c = null,
            RecordTypeId = recordTypeId
        );
    
        insert account;
        Test.startTest();
        List<Account> accountList = [ SELECT Id, Name, SSN__pc, Google_Drive_Folder_ID__c, CreatedDate
                FROM Account
                WHERE Google_Drive_Folder_ID__c = NULL AND RecordTypeId =: recordTypeId];
        Test.setMock(HttpCalloutMock.class, new GoogleDriveHttpMock());
        try {
            AccountGoogleDriveFolderController.processGoogleDriveFolderRequest(accountList[0].Id);
        } catch(Exception e) {
             message = e.getMessage();
        }
        Assert.isTrue(message.contains('Script-thrown exception'), 'The exception should be thrown.');
        Test.stopTest();
        Account updatedAcc = [ SELECT Id, Name, SSN__pc, Google_Drive_Folder_ID__c, CreatedDate
        FROM Account WHERE RecordTypeId =: recordTypeId LIMIT 1];

        System.debug('updatedAcc  ' + updatedAcc);

        Assert.areNotEqual('mockFolderId123', updatedAcc.Google_Drive_Folder_ID__c,  'The folder ID should not be on the Account.');

    }
}