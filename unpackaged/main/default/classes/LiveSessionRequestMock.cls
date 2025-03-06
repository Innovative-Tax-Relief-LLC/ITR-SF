@isTest
public class LiveSessionRequestMock {
    public static String getSuccessResponseBodySession() {
        return '{"sessionId": "1234"}';
    }

    public static String isSessionRequestBodyResponse(){
        return '';

    }

    public static RequestMock getSuccessSessionId(){
        return new RequestMock(ResponseHelper.OK_CODE, ResponseHelper.getStatusCode(ResponseHelper.OK_CODE), getSuccessResponseBodySession());

    }

    public static RequestMock getFailedSessionId(){
        return new RequestMock(ResponseHelper.BAD_REQUEST_CODE,ResponseHelper.getStatusCode(ResponseHelper.BAD_REQUEST_CODE), isSessionRequestBodyResponse());

    }

    public static RequestMock getInvalidSession(){
        return new RequestMock(ResponseHelper.NOT_FOUND_CODE, ResponseHelper.getStatusCode(ResponseHelper.NOT_FOUND_CODE), isSessionRequestBodyResponse());

    }
    public static RequestMock getValidSession(){
        return new RequestMock(ResponseHelper.NO_CONTENT_CODE, ResponseHelper.getStatusCode(ResponseHelper.NO_CONTENT_CODE), isSessionRequestBodyResponse());

    }
}