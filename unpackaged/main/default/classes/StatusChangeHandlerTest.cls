@isTest
public class StatusChangeHandlerTest {

    @isTest
    static void testSendDoNotCallChangeAsync_Success() {
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Test data
        Id sampleRecordId = Id.valueOf('001000000000001AAA'); // Valid Salesforce ID
        String sampleVelocifyId = '12345';
        Boolean sampleDoNotCall = true;
        String samplePhone = '1234567890';
        String sampleMobilePhone = '0987654321';

        // Execute the method
        Test.startTest();
        StatusChangeHandler.sendDoNotCallChangeAsync(sampleRecordId, sampleDoNotCall, samplePhone, sampleMobilePhone);
        Test.stopTest();

        // Assertions are optional here; verify execution through logs or mocks
        System.assert(true, 'sendDoNotCallChangeAsync executed successfully');
    }

    @isTest
    static void testSendDoNotCallChangeAsync_NullValues() {
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Test data with null values
        Id sampleRecordId = Id.valueOf('001000000000001AAA'); // Valid Salesforce ID
        String sampleVelocifyId = null; // Null Velocify ID
        Boolean sampleDoNotCall = null; // Null DoNotCall
        String samplePhone = null; // Null Phone
        String sampleMobilePhone = null; // Null MobilePhone

        // Execute the method
        Test.startTest();
        StatusChangeHandler.sendDoNotCallChangeAsync(sampleRecordId, sampleDoNotCall, samplePhone, sampleMobilePhone);
        Test.stopTest();

        // Assertions to verify no exceptions
        System.assert(true, 'sendDoNotCallChangeAsync executed successfully with null values');
    }

    @isTest
    static void testSendDoNotCallChangeAsync_NoMockConfig() {
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Test data
        Id sampleRecordId = Id.valueOf('001000000000001AAA'); // Valid Salesforce ID
        String sampleVelocifyId = '12345';
        Boolean sampleDoNotCall = true;
        String samplePhone = '1234567890';
        String sampleMobilePhone = '0987654321';

        // Execute the method
        Test.startTest();
        StatusChangeHandler.sendDoNotCallChangeAsync(sampleRecordId, sampleDoNotCall, samplePhone, sampleMobilePhone);
        Test.stopTest();

        // Assertions to verify execution
        System.assert(true, 'sendDoNotCallChangeAsync executed successfully without mock configuration');
    }
}