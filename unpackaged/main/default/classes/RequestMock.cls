@IsTest
public class RequestMock implements HttpCalloutMock {
  protected final String HEADER_CONTENT_TYPE = 'Content-Type';
  protected final String HEADER_CONTENT_TYPE_VALUE = 'application/json';
  protected Integer code;
  protected String status;
  protected String bodyAsString;
  protected Blob bodyAsBlob;
  protected Map<String, String> responseHeaders = new Map<String, String>();

  public RequestMock() {
    //NOPMD
  }

  public RequestMock(
    Integer code,
    String status,
    Object body,
    Map<String, String> responseHeaders
  ) {
    this.code = code;
    this.status = status;
    this.bodyAsString = body != null && body instanceof String ? (String) body : null;
    this.bodyAsBlob = body != null && body instanceof Blob ? (Blob) body : null;
    if (responseHeaders != null) {
      this.responseHeaders.putAll(responseHeaders);
    }
    if (!this.responseHeaders.containsKey(HEADER_CONTENT_TYPE)) {
      this.responseHeaders.put(HEADER_CONTENT_TYPE, HEADER_CONTENT_TYPE_VALUE);
    }
  }

  public RequestMock(Integer code, Object body, Map<String, String> responseHeaders) {
    this(code, ResponseHelper.getStatusCode(code), body, responseHeaders);
  }

  public RequestMock(Integer code, String status, Object body) {
    this(code, status, body, null);
  }

  public RequestMock(Integer code, Object body) {
    this(code, ResponseHelper.getStatusCode(code), body);
  }

  public RequestMock(Integer code) {
    this(code, ResponseHelper.getStatusCode(code), '');
  }

  public HttpResponse respond(HttpRequest req) {
    HttpResponse resp = new HttpResponse();
    resp.setStatusCode(code);
    resp.setStatus(status);
    if (bodyAsBlob != null) {
      resp.setBodyAsBlob(bodyAsBlob);
    } else {
      resp.setBody(bodyAsString);
    }

    if (responseHeaders != null) {
      for (String key : responseHeaders.keySet()) {
        resp.setHeader(key, responseHeaders.get(key));
      }
    }
    return resp;
  }
}