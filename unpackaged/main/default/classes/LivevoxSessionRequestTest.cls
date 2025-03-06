@isTest
private class LivevoxSessionRequestTest {
    public Integer statusCode;
    public String responseBody;
    @TestSetup
    static void makeData(){
        TestDataFactory.createLivevoxConfiguration();

        
    }
    public LivevoxSessionRequestTest() {
        this.statusCode = 200;
        this.responseBody = '{"sessionId": "1234"}';
    }


    public LivevoxSessionRequestTest(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody(responseBody);
        return res;
    }
    
    @isTest
    static void testGetSessionId_noValidSessionId_expectOkayResponse() {
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator(200,'{"sessionId": "0a6ecafd"}');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        LivevoxSessionRequest.getSessionId();
        Test.stopTest();

        
        Assert.areEqual('{"sessionId": "0a6ecafd"}',mock.responseBody, 'Incorrect body response' );
        Assert.areEqual(200,mock.statusCode,'Incorrect status code');
    }

    @isTest
    static void testGetSessionId_ValidSessionId_expectOkayResponse() {
        Livevox_Integration_Configuration__c beforesession = Livevox_Integration_Configuration__c.getInstance('ITR Session');
        Test.startTest();
        RequestMock sessionMock = LivevoxSessionRequestMock.getSuccessSessionId();
        Test.setMock(HttpCalloutMock.class, sessionMock);
        LivevoxSessionRequest.getSessionId();
        Test.stopTest();

        Livevox_Integration_Configuration__c existingSession = Livevox_Integration_Configuration__c.getInstance('ITR Session');
        Assert.areEqual('1234', existingSession.sessionId__c,'Incorrect body response' );
        
    }

    @isTest
    static void testUpsertSessionId() {

        LivevoxSessionRequest.upsertSessionId('1234');
        Livevox_Integration_Configuration__c existingSession = Livevox_Integration_Configuration__c.getInstance('ITR Session');
        Assert.areEqual('1234', existingSession.sessionId__c, 'Session Id not updated');
    }

    // @isTest
    // static void testIsSessionValid() {
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new LivevoxSessionRequestTest(204,''));
    //     Boolean result = LivevoxSessionRequest.isSessionValid('1234');
    //     Test.stopTest();
    //     Assert.isTrue(result, 'Session is not valid');
    // }
    
}