public with sharing class CaseOwnerEmailAction {
    public final static String ITR_CASE_MANAGEMENT_DISPLAY_NAME = 'ITR Case Management';
    
    public class EmailRequest {
        @InvocableVariable(Label='Case Id' Description='ID of the case record' Required=true)
        public Id caseId;
        @InvocableVariable(Label='Email Template Id' Description='ID of the email template to use' Required=true)
        public Id emailTemplateId;
        @InvocableVariable(Label='Recipient Id' Description='ID of the recipient' Required=true)
        public Id recipientId;
    }
    
    public class EmailResponse {
        @InvocableVariable(Label='Success' Description='Indicates if the email was sent successfully')
        public Boolean isSuccess;
        @InvocableVariable(Label='Error Message' Description='Error message if the email failed to send')
        public String errorMessage;
        @InvocableVariable(Label='Sent as User' Description='The user who sent the email')
        public String sentAsUser;
    }
    
    @InvocableMethod(Label='Send Email to Case Owner'
                    Description='Sends an email to the owner of a case using a specified email template'
                    Category='Email')
    public static List<EmailResponse> sendEmailToCaseOwner(List<EmailRequest> requests) {
        List<EmailResponse> responses = new List<EmailResponse>();
        
        try {

            Set<Id> caseIds = new Set<Id>();
            Set<Id> templateIds = new Set<Id>();
            
            for (EmailRequest request : requests) {
                caseIds.add(request.caseId);
                templateIds.add(request.emailTemplateId);
            }
            

            Map<Id, Case> caseMap = new Map<Id, Case>([
                SELECT Id, CaseNumber, Subject, Status,
                        ContactId, Contact.Email, Contact.Name,
                        AccountId, Account.Name,
                        OwnerId, Owner.Name, Owner.Email, Owner.IsActive,
                        Owner.FirstName, Owner.LastName
                FROM Case
                WHERE Id IN :caseIds
            ]);
            

            Map<Id, EmailTemplate> templateMap = new Map<Id, EmailTemplate>([
                SELECT Id, Name, Subject, Body, HtmlValue, IsActive
                FROM EmailTemplate
                WHERE Id IN :templateIds
                AND IsActive = TRUE
            ]);
            

            List<OrgWideEmailAddress> oweList = [
                SELECT Id, DisplayName, Address
                FROM OrgWideEmailAddress
                WHERE DisplayName = :ITR_CASE_MANAGEMENT_DISPLAY_NAME
                LIMIT 1
            ];
            
            OrgWideEmailAddress owe = !oweList.isEmpty() ? oweList[0] : null;
            

            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            Map<Integer, EmailRequest> indexToRequestMap = new Map<Integer, EmailRequest>();
            
            for (Integer i = 0; i < requests.size(); i++) {
                EmailRequest request = requests[i];
                EmailResponse response = new EmailResponse();
                response.isSuccess = false;

                if (Limits.getEmailInvocations() >= Limits.getLimitEmailInvocations()) {
                    response.errorMessage = 'Email limit exceeded. Cannot send more emails.';
                    responses.add(response);
                    continue;
                }
                
                try {
                    Case caseRecord = caseMap.get(request.caseId);
                    if (caseRecord == null) {
                        response.errorMessage = 'Record not found: Case does not exist';
                        responses.add(response);
                        continue;
                    }
                    
                    EmailTemplate template = templateMap.get(request.emailTemplateId);
                    if (template == null) {
                        response.errorMessage = 'Record not found: EmailTemplate does not exist';
                        responses.add(response);
                        continue;
                    }
                    
                    if (owe == null) {
                        response.errorMessage = 'Org Wide Email Address not found: ' + ITR_CASE_MANAGEMENT_DISPLAY_NAME;
                        responses.add(response);
                        continue;
                    }
                    
                    Messaging.SingleEmailMessage email = buildEmailMessage(template, request, caseRecord, owe);
                    emailsToSend.add(email);
                    indexToRequestMap.put(emailsToSend.size() - 1, request);
                    
                    response.sentAsUser = caseRecord.Owner.Name;
                    responses.add(response);
                    
                } catch (Exception e) {
                    response.errorMessage = 'Error processing request: ' + e.getMessage();
                    System.debug('Error: ' + e.getMessage());
                    responses.add(response);
                }
            }

            if (!emailsToSend.isEmpty()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend);

                for (Integer i = 0; i < results.size(); i++) {
                    EmailRequest originalRequest = indexToRequestMap.get(i);
                    Integer responseIndex = requests.indexOf(originalRequest);
                    EmailResponse response = responses[responseIndex];
                    
                    if (results[i].isSuccess()) {
                        response.isSuccess = true;
                        response.errorMessage = null;
                    } else {
                        response.isSuccess = false;
                        String errorMsg = '';
                        for (Messaging.SendEmailError error : results[i].getErrors()) {
                            errorMsg += error.getMessage() + '; ';
                        }
                        response.errorMessage = 'Email send failed: ' + errorMsg;
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Fatal error in sendEmailAsCaseOwner: ' + e.getMessage());
            EmailResponse errorResponse = new EmailResponse();
            errorResponse.isSuccess = false;
            errorResponse.errorMessage = 'Fatal error: ' + e.getMessage();
            responses.add(errorResponse);
        }
        
        return responses;
    }
    
    private static Messaging.SingleEmailMessage buildEmailMessage(EmailTemplate template, EmailRequest request, Case caseRecord, OrgWideEmailAddress owe) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(template.Id);
        email.setTargetObjectId(request.recipientId);
        email.setWhatId(caseRecord.Id);
        email.setTreatTargetObjectAsRecipient(true);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setCcAddresses(new String[]{owe.Address});
        
        if (String.isNotBlank(caseRecord.Owner.Email)) {
            email.setReplyTo(caseRecord.Owner.Email);
        }
        email.setSaveAsActivity(true);
        email.setUseSignature(false);
        
        return email;
    }
}