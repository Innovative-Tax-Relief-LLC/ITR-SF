public class StatusChangeHandler {
    @future(callout=true)
    public static void sendDoNotCallChangeAsync(
        Id recordId, Boolean doNotCall, String Phone, String MobilePhone
    ) {
        System.debug('StatusChangeHandler: sendDoNotCallChangeAsync called');

        try {
            System.debug('Step 1: Preparing HTTP request');
            Http http = new Http();
            HttpRequest request = new HttpRequest();

            System.debug('Step 2: Setting endpoint');
            request.setEndpoint('https://www.docmost.itrapi.tech/api/salesforce/dnc');
            request.setMethod('POST');

            System.debug('Step 3: Setting headers');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-API-Key', 'c275f7b415c214b98c133ae9c719ad5e');
            request.setHeader('X-API-Secret', '$2a$14$kdIjAEj/7x8ROaK.XJiXA.qTc379ATYvp9AjpSglMYEhVvjZFJjKa');

            System.debug('Step 4: Constructing payload');
            Map<String, Object> payload = new Map<String, Object>{
                'id' => recordId
            };
            if (doNotCall != null) {
                payload.put('doNotCall', doNotCall);
            }
            if (String.isNotBlank(Phone)) {
                payload.put('phone', Phone);
            }
            if (String.isNotBlank(MobilePhone)) {
                payload.put('mobilePhone', MobilePhone);
            }
            // if (String.isNotBlank(VelocifyID)) {
            //     payload.put('velocifyId', VelocifyID);
            // }

            System.debug('Payload: ' + JSON.serialize(payload));
            request.setBody(JSON.serialize(payload));

            System.debug('Step 5: Sending HTTP request');
            HttpResponse response = http.send(request);

            System.debug('Response Status: ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());
        } catch (Exception e) {
            System.debug('Error in sendDoNotCallChangeAsync: ' + e.getMessage());
        }
    }
}