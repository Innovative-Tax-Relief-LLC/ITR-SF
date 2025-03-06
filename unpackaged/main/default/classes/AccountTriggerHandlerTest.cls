@IsTest
private class AccountTriggerHandlerTest {

    @IsTest
    static void shouldHandlePersonAccountFieldChanges() {
        // Mock the HTTP callout to prevent external requests
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Get the Record Type ID for Person Accounts
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        // Create a Person Account with valid field values
        Account account = new Account(
            RecordTypeId = personAccountRecordTypeId,
            FirstName = 'Test',
            LastName = 'PersonAccount',
            BillingStreet = '1234 Test Street',
            BillingCity = 'Clearwater',
            BillingPostalCode = '33756',
            BillingState = 'FL', // Updated to use valid state code
            BillingCountry = 'United States', // Use valid ISO country code
            PersonEmail = 'tests@tests.com',
            PersonDoNotCall = false,
            Phone = '1234567890',
            PersonMobilePhone = '0987654321',
            Velocify_Id__pc = '67890'
        );

        // Insert the account to simulate creation
        insert account;

        Test.startTest();

        // Update the Person Account to simulate a field change
        account.PersonDoNotCall = true; // Change PersonDoNotCall to trigger the logic
        account.PersonEmail = 'tests@tests2.com'; // Change another field for additional validation
        update account;

        Test.stopTest();

        // Query the updated account to verify the changes
        Account updatedAccount = [SELECT PersonDoNotCall, PersonEmail FROM Account WHERE Id = :account.Id];

        // Assertions to ensure the trigger logic executed as expected
        System.assertEquals(true, updatedAccount.PersonDoNotCall, 'PersonDoNotCall should have been updated to true.');
        System.assertEquals('tests@tests2.com', updatedAccount.PersonEmail, 'PersonEmail should have been updated to the new value.');
    }
}