@IsTest
public with sharing class VelocifyAccountPaymentMethodMock implements HttpCalloutMock {
    private final Integer statusCode;
    private final String responseBody;

    public VelocifyAccountPaymentMethodMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    public static VelocifyAccountPaymentMethodMock success() {
        return new VelocifyAccountPaymentMethodMock(200, '{"success": true}');
    }

    public static VelocifyAccountPaymentMethodMock error() {
        return new VelocifyAccountPaymentMethodMock(400, '{"success": false, "message": "Invalid data"}');
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseBody);
        res.setStatusCode(statusCode);
        return res;
    }
}