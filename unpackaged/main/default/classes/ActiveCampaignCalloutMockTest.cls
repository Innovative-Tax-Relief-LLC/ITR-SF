@isTest
private class ActiveCampaignCalloutMockTest {
    
    private static final String ENDPOINT = 'https://www.test.com';
    private static final String RESPONSE_BODY = '{"output":"Test Output"}';
    private static final Integer RESPONSE_SUCCESS = 200;
    private static final String KEY1 = 'key1';
    private static final String VALUE1 = 'value1';

    @isTest
    public static void shouldTestMock() {
        Test.startTest();
        ActiveCampaignCalloutMock instance = new ActiveCampaignCalloutMock();
        ActiveCampaignCalloutMock testMock = new ActiveCampaignCalloutMock(RESPONSE_SUCCESS, RESPONSE_BODY);
        Test.setMock(HTTPCalloutMock.class, testMock);

        testMock.setResponseCode(RESPONSE_SUCCESS);
        testMock.setResponseBody(RESPONSE_BODY);
        testMock.setResponseHeader(KEY1, VALUE1);
        testMock.setResponseStatus('Ok');
                
        ActiveCampaignCalloutMultiMock multimock = new ActiveCampaignCalloutMultiMock(new Map<String, ActiveCampaignCalloutMock>{ENDPOINT => testMock});

        System.assertEquals(RESPONSE_SUCCESS, testMock.getResponseCode());
        System.assertEquals(RESPONSE_BODY, testMock.getResponseBody());
        System.assertEquals(new Map<String,String>{KEY1 => VALUE1}, testMock.getResponseHeaders());
        System.assertEquals('Ok', testMock.getResponseStatus());
        Test.stopTest();
    }
}