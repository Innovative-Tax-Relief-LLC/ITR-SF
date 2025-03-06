@IsTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
    public Integer statusCode;
    public String responseBody;

    // Constructor with defaults
    public MockHttpResponseGenerator() {
        this.statusCode = 200;
        this.responseBody = '{"success": true}';
    }

    // Constructor for customization
    public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody(responseBody);
        return res;
    }
}