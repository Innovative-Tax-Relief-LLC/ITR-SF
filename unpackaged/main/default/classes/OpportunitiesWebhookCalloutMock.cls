@isTest
global class OpportunitiesWebhookCalloutMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message":"Workflow was started"}');
        res.setStatusCode(200);
        return res;
    }
}