public with sharing class ActiveCampaignCalloutMultiMock implements HTTPCalloutMock {

    Map<String, ActiveCampaignCalloutMock> calloutMocks;

    public ActiveCampaignCalloutMultiMock() {
        calloutMocks = new Map<String, ActiveCampaignCalloutMock>();
    }

    // Constructor initializing the class variables (from user input if available)
    public ActiveCampaignCalloutMultiMock(Map<String, ActiveCampaignCalloutMock> calloutMocks) {
        this.calloutMocks = calloutMocks;
        if(this.calloutMocks == null) {
            calloutMocks = new Map<String, ActiveCampaignCalloutMock>();
        }
    }

    //Adding a callout mock class instance to (URL - Mock) map
    public void addCalloutMock(String endpoint, ActiveCampaignCalloutMock calloutMock) {
        calloutMocks.put(endpoint, calloutMock);
    }

    //This method is used to generate and send a mock HTTP response for the incoming request
    //It also throws a custom exception in case the mock is not found for the input request URL
    public HTTPResponse respond(HTTPRequest request) {
        ActiveCampaignCalloutMock calloutMock = calloutMocks.get(request.getEndpoint());
        if(calloutMock != null) {
            return calloutMock.respond(request);
        } else {
            throw new ActiveCampaignCalloutMultiMockException('Response Mock not found for the current request URL');
        }
    }

    public class ActiveCampaignCalloutMultiMockException extends Exception{}
}