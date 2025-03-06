@isTest
public class LeadTriggerDNCTest {

    @isTest
    static void testLeadTriggerDoNotCallChange() {
        // Mock the HTTP Callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create a Lead with initial values
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead Change',
            Company = 'Test Company',
            DoNotCall = false,
            Phone = '1234567890',
            MobilePhone = '0987654321'
            //Velocify_Id__c = '12345'
        );
        insert testLead;

        Test.startTest();
        // Update the Lead to simulate a change in DoNotCall
        testLead.DoNotCall = true;
        update testLead;
        Test.stopTest();

        // Assert that DoNotCall was updated
        Lead updatedLead = [SELECT DoNotCall FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, updatedLead.DoNotCall, 'DoNotCall should have been updated to true.');
    }

    @isTest
    static void testLeadTriggerDoNotCallNoChange() {
        // Mock the HTTP Callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create a Lead with initial values
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead No Change',
            Company = 'Test Company',
            DoNotCall = false,
            Phone = '1234567890',
            MobilePhone = '0987654321'
            //Velocify_Id__c = '67890'
        );
        insert testLead;

        Test.startTest();
        // Update the Lead but do not change DoNotCall
        testLead.Phone = '1111111111'; // Change an unrelated field
        update testLead;
        Test.stopTest();

        // Assert that DoNotCall was not changed
        Lead updatedLead = [SELECT DoNotCall FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(false, updatedLead.DoNotCall, 'DoNotCall should remain unchanged.');
    }
}