@IsTest
public class GoogleDriveFolderTest {
    @IsTest
    static void testGoogleDriveFolderCreatorQueueable() {
        // Set mock response
        Test.setMock(HttpCalloutMock.class, new GoogleDriveHttpMock());

        // Create a mock account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Test the Queueable class
        String parentFolderId = 'mockParentFolderId';
        String newFolderName = 'Test Folder';
        GoogleDriveFolderCreatorQueueable queueable = 
            new GoogleDriveFolderCreatorQueueable(parentFolderId, newFolderName, acc.Id);
        
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        // Assert folder ID is updated on the Account
        Account updatedAcc = [SELECT Id, Google_Drive_Folder_ID__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('mockFolderId123', updatedAcc.Google_Drive_Folder_ID__c, 
            'The folder ID should be updated on the Account.');
    }

    @IsTest
    static void testGoogleDriveFolderService() {
        // Set mock response
        Test.setMock(HttpCalloutMock.class, new GoogleDriveHttpMock());

        // Test the folder retrieval method
        Test.startTest();
        String folderId = GoogleDriveFolderService.getGoogleDriveFolderId('Test Folder');
        Test.stopTest();

        // Assert the folder ID is retrieved correctly
        System.assertEquals('mockFolderId123', folderId, 
            'The folder ID should match the mocked response.');
    }
    
    
}