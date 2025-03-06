@isTest
public class AccountTriggerDNCTest {

    @isTest
    static void testAccountTriggerWithoutChange() {
        // Mock the HTTP Callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create a mock account record without changing PersonDoNotCall
        Account accountNoChange = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Test',
            LastName = 'Account No Change',
            PersonDoNotCall = false,
            Phone = '1234567890',
            PersonMobilePhone = '0987654321',
            Velocify_Id__pc = '12345'
        );

        insert accountNoChange;

        Test.startTest();
        // Update the account but don't change PersonDoNotCall
        accountNoChange.Phone = '1111111111'; // Change an unrelated field
        update accountNoChange;
        Test.stopTest();

        // Assert that PersonDoNotCall did not change
        Account updatedAccountNoChange = [SELECT PersonDoNotCall FROM Account WHERE Id = :accountNoChange.Id];
        System.assertEquals(false, updatedAccountNoChange.PersonDoNotCall, 'PersonDoNotCall should remain unchanged.');
    }

    @isTest
    static void testAccountTriggerWithDoNotCallChange() {
        // Mock the HTTP Callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create a mock account record and change PersonDoNotCall
        Account accountWithChange = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Test',
            LastName = 'Account With Change',
            PersonDoNotCall = false,
            Phone = '1234567890',
            PersonMobilePhone = '0987654321',
            Velocify_Id__pc = '67890'
        );

        insert accountWithChange;

        Test.startTest();
        // Update the account and change PersonDoNotCall
        accountWithChange.PersonDoNotCall = true; // Change the PersonDoNotCall field
        update accountWithChange;
        Test.stopTest();

        // Assert that PersonDoNotCall was changed
        Account updatedAccountWithChange = [SELECT PersonDoNotCall FROM Account WHERE Id = :accountWithChange.Id];
        System.assertEquals(true, updatedAccountWithChange.PersonDoNotCall, 'PersonDoNotCall should have been updated.');
    }
}