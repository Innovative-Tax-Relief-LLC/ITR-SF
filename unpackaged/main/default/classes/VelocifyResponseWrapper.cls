global with sharing class VelocifyResponseWrapper {
    global Integer statusCode;
    global Boolean success;
    global String message;
    global Map<String, String> data;
    
    global VelocifyResponseWrapper(Integer statusCode, Boolean success, String message, Map<String, String> data) {
        this.statusCode = statusCode;
        this.success = success;
        this.message = message;
        this.data = data;
    }
}