@isTest
public class LivevoxIntegrationServiceMock {
   public static String getSuccessResponseContactCreate(){
   String responseBody = '{"id": "3456782"}';
   return responseBody;
            
   }

   public static RequestMock getContactCreateResponse(){
    return new RequestMock(ResponseHelper.CREATED_CODE,ResponseHelper.getStatusCode(ResponseHelper.CREATED_CODE),getSuccessResponseContactCreate());
   }
}