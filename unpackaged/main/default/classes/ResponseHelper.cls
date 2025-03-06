public with sharing class ResponseHelper {
    public static final Integer OK_CODE = 200;
    public static final Integer CREATED_CODE = 201;
    public static final Integer ACCEPTED_CODE = 202;
    public static final Integer NON_AUTHORITATIVE_INFORMATION_CODE = 203;
    public static final Integer NO_CONTENT_CODE = 204;
    public static final Integer OPERATION_WAS_CANCELED_CODE = 209;
    public static final Integer MULTIPLE_CHOICES_CODE = 300;
    public static final Integer MOVED_PERMANENTLY_CODE = 301;
    public static final Integer NOT_MODIFIED_CODE = 304;
    public static final Integer TEMPORARY_REDIRECT_CODE = 307;
    public static final Integer PERMANENT_REDIRECT_CODE = 308;
    public static final Integer BAD_REQUEST_CODE = 400;
    public static final Integer UNAUTHORIZED_CODE = 401;
    public static final Integer FORBIDDEN_CODE = 403;
    public static final Integer NOT_FOUND_CODE = 404;
    public static final Integer METHOD_NOT_ALLOWED_CODE = 405;
    public static final Integer REQUEST_TIMEOUT_CODE = 408;
    public static final Integer CONFLICT_CODE = 409;
    public static final Integer LENGTH_REQUIRED_CODE = 411;
    public static final Integer REQUEST_ENTITY_TOO_LARGE_CODE = 413;
    public static final Integer REQUEST_URI_TOO_LONG_CODE = 414;
    public static final Integer TOO_MANY_REQUESTS_CODE = 429;
    public static final Integer INTERNAL_SERVER_ERROR_CODE = 500;
    public static final Integer NOT_IMPLEMENTED_CODE = 501;
    public static final Integer BAD_GATEWAY_CODE = 502;
    public static final Integer SERVICE_UNAVAILABLE_CODE = 503;
    public static final Integer GATEWAY_TIMEOUT_CODE = 504;
    public static final Integer NETWORK_TIMEOUT_CODE = 599;
    private static final Map<Integer, String> STATUS_CODE_MAP = new Map<Integer, String>{
      OK_CODE => 'OK',
      CREATED_CODE => 'Created',
      ACCEPTED_CODE => 'Accepted',
      NON_AUTHORITATIVE_INFORMATION_CODE => 'Non-Authoritative Information',
      NO_CONTENT_CODE => 'No Content',
      OPERATION_WAS_CANCELED_CODE => 'Operation was Canceled',
      MULTIPLE_CHOICES_CODE => 'Multiple Choices',
      MOVED_PERMANENTLY_CODE => 'Moved Permanently',
      NOT_MODIFIED_CODE => 'Not Modified',
      TEMPORARY_REDIRECT_CODE => 'Temporary Redirect',
      PERMANENT_REDIRECT_CODE => 'Permanent Redirect',
      BAD_REQUEST_CODE => 'Bad Request',
      UNAUTHORIZED_CODE => 'Unauthorized',
      FORBIDDEN_CODE => 'Forbidden',
      NOT_FOUND_CODE => 'Not Found',
      METHOD_NOT_ALLOWED_CODE => 'Method Not Allowed',
      REQUEST_TIMEOUT_CODE => 'Request Timeout',
      CONFLICT_CODE => 'Conflict',
      LENGTH_REQUIRED_CODE => 'Length Required',
      REQUEST_ENTITY_TOO_LARGE_CODE => 'Request Entity Too Large',
      REQUEST_URI_TOO_LONG_CODE => 'Request URI Too Long',
      TOO_MANY_REQUESTS_CODE => 'Too Many Requests',
      INTERNAL_SERVER_ERROR_CODE => 'Internal Server Error',
      NOT_IMPLEMENTED_CODE => 'Not Implemented',
      BAD_GATEWAY_CODE => 'Bad Gateway',
      SERVICE_UNAVAILABLE_CODE => 'Service Unavailable',
      GATEWAY_TIMEOUT_CODE => 'Gateway Timeout',
      NETWORK_TIMEOUT_CODE => 'Network Timeout'
    };
  
    private ResponseHelper() {
    }
  
    public static String getStatusCode(Integer code) {
      return STATUS_CODE_MAP.get(code);
    }
  
    public static Boolean isInformationResponseType(HttpResponse response) {
      return response.getStatusCode() >= 100 && response.getStatusCode() <= 199;
    }
  
    public static Boolean isSuccessResponseType(HttpResponse response) {
      return response.getStatusCode() >= 200 && response.getStatusCode() <= 299;
    }
  
    public static Boolean isRedirectionResponseType(HttpResponse response) {
      return response.getStatusCode() >= 300 && response.getStatusCode() <= 399;
    }
  
    public static Boolean isClientErrorResponseType(HttpResponse response) {
      return response.getStatusCode() >= 400 && response.getStatusCode() <= 499;
    }
  
    public static Boolean isServerErrorResponseType(HttpResponse response) {
      return response.getStatusCode() >= 500 && response.getStatusCode() <= 599;
    }
  
    //200 Response Codes - Successful responses
    public static Boolean isSuccess(HttpResponse response) {
      return response != null && response.getStatusCode() == 200;
    }
  
    public static Boolean isCreated(HttpResponse response) {
      return response.getStatusCode() == 201;
    }
  
    public static Boolean isAccepted(HttpResponse response) {
      return response.getStatusCode() == 202;
    }
  
    //300 Response Codes - Redirection messages
    public static Boolean isTemporaryRedirect(HttpResponse response) {
      return response.getStatusCode() == 307;
    }
  
    public static Boolean isPermanentRedirect(HttpResponse response) {
      return response.getStatusCode() == 308;
    }
  
    //400 Response Codes - Client error responses
    public static Boolean isBadRequest(HttpResponse response) {
      return response.getStatusCode() == 400;
    }
  
    public static Boolean isUnauthorizedRequest(HttpResponse response) {
      return response.getStatusCode() == 401;
    }
  
    public static Boolean isForbiddenRequest(HttpResponse response) {
      return response.getStatusCode() == 403;
    }
  
    //500 Response Codes - Server error responses
    public static Boolean isInternalServerError(HttpResponse response) {
      return response.getStatusCode() == 500;
    }
  
    public static Boolean isServiceUnavailable(HttpResponse response) {
      return response.getStatusCode() == 503;
    }
  
    public static Boolean isGatewayTimeout(HttpResponse response) {
      return response.getStatusCode() == 504;
    }
  }