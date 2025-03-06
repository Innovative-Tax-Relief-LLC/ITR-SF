@isTest
private class ResponseHelperTest {
  @isTest
  static void isInformationResponseType_receivesCodeInRange_expectTrueIsInformationResponseType() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(199);

    Assert.isTrue(ResponseHelper.isInformationResponseType(response));
  }

  @isTest
  static void isSuccessResponseType_receivesCodeInRange_expectTrueIsSuccessResponseType() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(299);

    Assert.isTrue(ResponseHelper.isSuccessResponseType(response));
  }

  @isTest
  static void isRedirectionResponseType_receivesCodeInRange_expectTrueIsRedirectionResponseType() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(399);

    Assert.isTrue(ResponseHelper.isRedirectionResponseType(response));
  }

  @isTest
  static void isClientErrorResponseType_receivesCodeInRange_expectTrueIsClientErrorResponseType() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(499);

    Assert.isTrue(ResponseHelper.isClientErrorResponseType(response));
  }

  @isTest
  static void isServerErrorResponseType_receivesCodeInRange_expectTrueIsServerErrorResponseType() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(599);

    Assert.isTrue(ResponseHelper.isServerErrorResponseType(response));
  }

  @isTest
  static void isSuccess_receivesSuccessCode_expectTrueIsSuccess() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(200);

    Assert.isTrue(ResponseHelper.isSuccess(response));
  }

  @isTest
  static void isCreated_receiveSuccessCode_expectTrueIsCreated() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(201);

    Assert.isTrue(ResponseHelper.isCreated(response));
  }

  @isTest
  static void isAccepted_receiveSuccessCode_expectTrueIsAccepted() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(202);

    Assert.isTrue(ResponseHelper.isAccepted(response));
  }

  @isTest
  static void isTemporaryRedirect_redirectionMessagesCode_expectTrueIsTemporaryRedirect() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(307);

    Assert.isTrue(ResponseHelper.isTemporaryRedirect(response));
  }

  @isTest
  static void isPermanentRedirect_redirectionMessagesCode_expectTrueIsPermanentRedirect() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(308);

    Assert.isTrue(ResponseHelper.isPermanentRedirect(response));
  }

  @isTest
  static void isBadRequest_clientErrorResponseCode_expectTrueIsBadRequest() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(400);

    Assert.isTrue(ResponseHelper.isBadRequest(response));
  }

  @isTest
  static void isUnauthorizedRequest_clientErrorResponseCode_expectTrueIsUnauthorizedRequest() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(401);

    Assert.isTrue(ResponseHelper.isUnauthorizedRequest(response));
  }

  @isTest
  static void isForbiddenRequest_clientErrorResponseCode_expectTrueIsForbiddenRequest() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(403);

    Assert.isTrue(ResponseHelper.isForbiddenRequest(response));
  }

  @isTest
  static void isInternalServerError_serverErrorResponseCode_expectTrueIsInternalServerError() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(500);

    Assert.isTrue(ResponseHelper.isInternalServerError(response));
  }

  @isTest
  static void isServiceUnavailable_serverErrorResponseCode_expectTrueIsServiceUnavailable() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(503);

    Assert.isTrue(ResponseHelper.isServiceUnavailable(response));
  }

  @isTest
  static void isServiceUnavailable_serverErrorResponseCode_expectTrueIsGatewayTimeout() {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(504);

    Assert.isTrue(ResponseHelper.isGatewayTimeout(response));
  }

  @IsTest
  static void testHttpCodes() {
    Assert.areEqual(200, ResponseHelper.OK_CODE);
    Assert.areEqual(201, ResponseHelper.CREATED_CODE);
    Assert.areEqual(202, ResponseHelper.ACCEPTED_CODE);
    Assert.areEqual(203, ResponseHelper.NON_AUTHORITATIVE_INFORMATION_CODE);
    Assert.areEqual(204, ResponseHelper.NO_CONTENT_CODE);
    Assert.areEqual(300, ResponseHelper.MULTIPLE_CHOICES_CODE);
    Assert.areEqual(301, ResponseHelper.MOVED_PERMANENTLY_CODE);
    Assert.areEqual(304, ResponseHelper.NOT_MODIFIED_CODE);
    Assert.areEqual(307, ResponseHelper.TEMPORARY_REDIRECT_CODE);
    Assert.areEqual(308, ResponseHelper.PERMANENT_REDIRECT_CODE);
    Assert.areEqual(400, ResponseHelper.BAD_REQUEST_CODE);
    Assert.areEqual(401, ResponseHelper.UNAUTHORIZED_CODE);
    Assert.areEqual(403, ResponseHelper.FORBIDDEN_CODE);
    Assert.areEqual(404, ResponseHelper.NOT_FOUND_CODE);
    Assert.areEqual(408, ResponseHelper.REQUEST_TIMEOUT_CODE);
    Assert.areEqual(409, ResponseHelper.CONFLICT_CODE);
    Assert.areEqual(411, ResponseHelper.LENGTH_REQUIRED_CODE);
    Assert.areEqual(429, ResponseHelper.TOO_MANY_REQUESTS_CODE);
    Assert.areEqual(500, ResponseHelper.INTERNAL_SERVER_ERROR_CODE);
    Assert.areEqual(501, ResponseHelper.NOT_IMPLEMENTED_CODE);
    Assert.areEqual(502, ResponseHelper.BAD_GATEWAY_CODE);
    Assert.areEqual(503, ResponseHelper.SERVICE_UNAVAILABLE_CODE);
    Assert.areEqual(504, ResponseHelper.GATEWAY_TIMEOUT_CODE);
    Assert.areEqual(599, ResponseHelper.NETWORK_TIMEOUT_CODE);
  }

  @IsTest
  static void testHttpStatusCodes() {
    Assert.areEqual('OK', ResponseHelper.getStatusCode(ResponseHelper.OK_CODE));
    Assert.areEqual('Created', ResponseHelper.getStatusCode(ResponseHelper.CREATED_CODE));
    Assert.areEqual('Accepted', ResponseHelper.getStatusCode(ResponseHelper.ACCEPTED_CODE));
    Assert.areEqual(
      'Non-Authoritative Information',
      ResponseHelper.getStatusCode(ResponseHelper.NON_AUTHORITATIVE_INFORMATION_CODE)
    );
    Assert.areEqual('No Content', ResponseHelper.getStatusCode(ResponseHelper.NO_CONTENT_CODE));
    Assert.areEqual(
      'Multiple Choices',
      ResponseHelper.getStatusCode(ResponseHelper.MULTIPLE_CHOICES_CODE)
    );
    Assert.areEqual(
      'Moved Permanently',
      ResponseHelper.getStatusCode(ResponseHelper.MOVED_PERMANENTLY_CODE)
    );
    Assert.areEqual('Not Modified', ResponseHelper.getStatusCode(ResponseHelper.NOT_MODIFIED_CODE));
    Assert.areEqual(
      'Temporary Redirect',
      ResponseHelper.getStatusCode(ResponseHelper.TEMPORARY_REDIRECT_CODE)
    );
    Assert.areEqual(
      'Permanent Redirect',
      ResponseHelper.getStatusCode(ResponseHelper.PERMANENT_REDIRECT_CODE)
    );
    Assert.areEqual('Bad Request', ResponseHelper.getStatusCode(ResponseHelper.BAD_REQUEST_CODE));
    Assert.areEqual('Unauthorized', ResponseHelper.getStatusCode(ResponseHelper.UNAUTHORIZED_CODE));
    Assert.areEqual('Forbidden', ResponseHelper.getStatusCode(ResponseHelper.FORBIDDEN_CODE));
    Assert.areEqual('Not Found', ResponseHelper.getStatusCode(ResponseHelper.NOT_FOUND_CODE));
    Assert.areEqual(
      'Request Timeout',
      ResponseHelper.getStatusCode(ResponseHelper.REQUEST_TIMEOUT_CODE)
    );
    Assert.areEqual('Conflict', ResponseHelper.getStatusCode(ResponseHelper.CONFLICT_CODE));
    Assert.areEqual(
      'Length Required',
      ResponseHelper.getStatusCode(ResponseHelper.LENGTH_REQUIRED_CODE)
    );
    Assert.areEqual(
      'Too Many Requests',
      ResponseHelper.getStatusCode(ResponseHelper.TOO_MANY_REQUESTS_CODE)
    );
    Assert.areEqual(
      'Internal Server Error',
      ResponseHelper.getStatusCode(ResponseHelper.INTERNAL_SERVER_ERROR_CODE)
    );
    Assert.areEqual(
      'Not Implemented',
      ResponseHelper.getStatusCode(ResponseHelper.NOT_IMPLEMENTED_CODE)
    );
    Assert.areEqual('Bad Gateway', ResponseHelper.getStatusCode(ResponseHelper.BAD_GATEWAY_CODE));
    Assert.areEqual(
      'Service Unavailable',
      ResponseHelper.getStatusCode(ResponseHelper.SERVICE_UNAVAILABLE_CODE)
    );
    Assert.areEqual(
      'Gateway Timeout',
      ResponseHelper.getStatusCode(ResponseHelper.GATEWAY_TIMEOUT_CODE)
    );
    Assert.areEqual(
      'Network Timeout',
      ResponseHelper.getStatusCode(ResponseHelper.NETWORK_TIMEOUT_CODE)
    );
  }
}