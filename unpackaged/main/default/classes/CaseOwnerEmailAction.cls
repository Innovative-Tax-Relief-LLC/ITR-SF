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
            for (EmailRequest request : requests) {
                EmailResponse response = new EmailResponse();
                response.isSuccess = false;

                try {
                    Case caseRecord = getCaseRecord(request.caseId);
                    if (caseRecord == null) {
                        responses.add(response);
                        continue;
                    }

                    EmailTemplate template = getEmailTemplate(request.emailTemplateId);
                    if (template == null) {
                        responses.add(response);
                        continue;
                    }

                    Messaging.SingleEmailMessage email = buildEmailMessage(template, request, caseRecord);
                    List<Messaging.SendEmailResult> results = sendEmail(email);

                    updateResponseWithResults(response, results, caseRecord);
                } catch (QueryException e) {
                    response.errorMessage = 'Record not found: ' + e.getMessage();
                    System.debug('Query error: ' + e.getMessage());
                } catch (Exception e) {
                    response.errorMessage = 'Error sending email: ' + e.getMessage();
                    System.debug('Email error: ' + e.getMessage());
                }

                responses.add(response);
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

    private static Case getCaseRecord(Id caseId) {
        List<Case> cases = [
            SELECT Id, CaseNumber, Subject, Status,
                    ContactId, Contact.Email, Contact.Name,
                    AccountId, Account.Name,
                    OwnerId, Owner.Name, Owner.Email, Owner.IsActive,
                    Owner.FirstName, Owner.LastName
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        if (cases.isEmpty()) {
            throw new QueryException('Record not found: Case does not exist');
        }
        return cases[0];
    }

    private static EmailTemplate getEmailTemplate(Id templateId) {
        List<EmailTemplate> templates = [
            SELECT Id, Name, Subject, Body, HtmlValue, IsActive
            FROM EmailTemplate
            WHERE Id = :templateId
            AND IsActive = TRUE
            LIMIT 1
        ];

        if (templates.isEmpty()) {
            throw new QueryException('Record not found: EmailTemplate does not exist');
        }
        return templates[0];
    }

    private static Messaging.SingleEmailMessage buildEmailMessage(EmailTemplate template, EmailRequest request, Case caseRecord) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(template.Id);
        email.setTargetObjectId(request.recipientId);
        email.setWhatId(caseRecord.Id);
        email.setTreatTargetObjectAsRecipient(true);
        OrgWideEmailAddress owe = [SELECT Id, DisplayName, Address
                                    FROM OrgWideEmailAddress
                                    WHERE DisplayName = :ITR_CASE_MANAGEMENT_DISPLAY_NAME
                                    LIMIT 1];
        email.setOrgWideEmailAddressId(owe.Id);
        email.setCcAddresses(new String[]{owe.Address});

        if (String.isNotBlank(caseRecord.Owner.Email)) {
            email.setReplyTo(caseRecord.Owner.Email);
        }
        email.setSaveAsActivity(true);
        email.setUseSignature(false);
        return email;
    }

    private static List<Messaging.SendEmailResult> sendEmail(Messaging.SingleEmailMessage email) {
        return Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }

    private static void updateResponseWithResults(EmailResponse response, List<Messaging.SendEmailResult> results, Case caseRecord) {
        if (results[0].isSuccess()) {
            response.isSuccess = true;
            response.sentAsUser = caseRecord.Owner.Name;
            response.errorMessage = null;
        } else {
            response.isSuccess = false;
            String errorMsg = '';
            for (Messaging.SendEmailError error : results[0].getErrors()) {
                errorMsg += error.getMessage() + '; ';
            }
            response.errorMessage = 'Email send failed: ' + errorMsg;
        }
    }
}