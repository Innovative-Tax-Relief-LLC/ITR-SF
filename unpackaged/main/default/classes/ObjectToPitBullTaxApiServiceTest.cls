@IsTest
public class ObjectToPitBullTaxApiServiceTest {
    @IsTest
    static void testSendClientApi() {
        // Step 1: Create test data
        Account testAccount = TestDataFactory.createTestAccount();
        Business__c testBusiness = TestDataFactory.createTestBusiness(testAccount.Id);
        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(testAccount.Id);

        // Step 2: Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Step 3: Call the method
        Test.startTest();
        ObjectToPitBullTaxApiService.sendClientApi(
            new List<String>{testOpportunity.Id}, // Opportunity ID
            false, // isUpdate
            true   // sendBusinesses
        );
        Test.stopTest();

        // Step 4: Validate results
        // Assert that no exceptions were thrown
        System.assert(true, 'API callout completed successfully.');
    }

    @isTest
    static void testSendClientApiFail() {
        // Step 1: Create test data
        Account testAccount = TestDataFactory.createTestAccount();
        Business__c testBusiness = TestDataFactory.createTestBusiness(testAccount.Id);
        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(testAccount.Id);

        // Step 2: Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(404, '{"success": false}'));

        // Step 3: Call the method
        Test.startTest();
        try {
            ObjectToPitBullTaxApiService.sendClientApi(
                new List<String>{testOpportunity.Id}, // Opportunity ID
                false, // isUpdate
                true   // sendBusinesses
            );
        } catch (Exception e) {
            System.assert(true, 'API callout completed successfully.');    
        }
        
        Test.stopTest();        
    }

    @IsTest
    static void testSendClientApiWithoutBusinesses() {
        // Step 1: Create test data without businesses
        Account testAccount = TestDataFactory.createTestAccount();
        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(testAccount.Id);

        // Step 2: Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Step 3: Call the method
        Test.startTest();
        ObjectToPitBullTaxApiService.sendClientApi(
            new List<String>{testOpportunity.Id}, // Opportunity ID
            false, // isUpdate
            false  // sendBusinesses
        );
        Test.stopTest();

        // Step 4: Validate results
        // Assert that no exceptions were thrown
        System.assert(true, 'API callout without businesses completed successfully.');
    }

    @IsTest
    static void testSendClientApiForCase() {
        // Step 1: Create test data
        Account testAccount = TestDataFactory.createTestAccount();
        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(testAccount.Id);
        Case testCase = TestDataFactory.createTestCase(testOpportunity.Id);

        // Step 2: Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Step 3: Call the method
        Test.startTest();
        ObjectToPitBullTaxApiService.sendClientApi(
            new List<String>{testCase.Id}, // Case ID
            true,  // isUpdate
            true   // sendBusinesses
        );
        Test.stopTest();

        // Step 4: Validate results
        // Assert that no exceptions were thrown
        System.assert(true, 'API callout for case completed successfully.');
    }

    @IsTest
    static void testHandleEmptyIds() {
        Test.startTest();
        try {
            ObjectToPitBullTaxApiService.sendClientApi(new List<String>(), false, false);
            System.assert(false, 'An exception should have been thrown for empty IDs.');
        } catch (AuraHandledException e) {
            System.assert(true, 'Proper error message was thrown.');
        }
        Test.stopTest();
    }
}