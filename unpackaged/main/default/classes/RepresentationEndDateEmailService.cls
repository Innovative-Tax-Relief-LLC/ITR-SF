public class RepresentationEndDateEmailService {
    
    @InvocableMethod(label='Send Rep End Date Emails' 
                     description='Sends personalized reminder emails based on Remaining_Representation_Time__c')
    public static List<Result> sendRepEndDateEmails(List<Request> requests) {
        List<Result> results = new List<Result>();
        
        // Add null check
        if(requests == null || requests.isEmpty()) {
            return results;
        }
        
        for(Request req : requests) {
            Result result = processRequest(req);
            results.add(result);
        }
        
        return results;
    }
    
    private static Result processRequest(Request req) {
        Result result = new Result();
        result.successCount = 0;
        result.failureCount = 0;
        result.emailLogs = new List<EmailLog>();
        
        if(req == null || req.opportunities == null || req.opportunities.isEmpty()) {
            return result;
        }
        
        try {
            // Query complete Opportunity data
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opp : req.opportunities) {
                oppIds.add(opp.Id);
            }
            
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
                SELECT Id, Name, Account.PersonEmail, Account.FirstName, 
                       Representation_End_Date__c, Remaining_Representation_Time__c,
                       Account.Latest_Case_Created__r.Owner.Name,
                       Account.Latest_Case_Created__r.Owner.Email,
                       Account.Latest_Case_Created__r.CaseNumber
                FROM Opportunity 
                WHERE Id IN :oppIds
            ]);
            
            // Build emails
            List<Messaging.SingleEmailMessage> emails = buildEmails(oppMap.values(), result);
            
            // Send emails
            if(!emails.isEmpty()) {
                sendEmails(emails, result);
            }
            
            // Post summary to Chatter if there were failures
            if(result.failureCount > 0) {
                postToChatter(result);
            }
            
        } catch(Exception e) {
            result.failureCount = req.opportunities.size();
            EmailLog errorLog = new EmailLog();
            errorLog.success = false;
            errorLog.message = 'System Error: ' + e.getMessage();
            result.emailLogs.add(errorLog);
        }
        
        return result;
    }
    
    private static List<Messaging.SingleEmailMessage> buildEmails(
        List<Opportunity> opps, Result result) {
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for(Opportunity opp : opps) {
            EmailLog log = new EmailLog();
            log.opportunityId = opp.Id;
            log.recipientEmail = opp.Account.PersonEmail;
            
            // Validate required fields
            if(String.isBlank(opp.Account.PersonEmail)) {
                log.success = false;
                log.message = 'Skipped: Missing email address';
                result.emailLogs.add(log);
                continue;
            }
            
            if(opp.Representation_End_Date__c == null ||
               String.isBlank(opp.Account.FirstName) ||
               opp.Remaining_Representation_Time__c == null) {
                log.success = false;
                log.message = 'Skipped: Missing required fields';
                result.emailLogs.add(log);
                continue;
            }
            
            Decimal remainingTime = opp.Remaining_Representation_Time__c;
            Messaging.SingleEmailMessage mail = null;
            
            if(remainingTime >= 85 && remainingTime <= 95) {
                mail = createEmail90Days(opp);
                log.emailType = '90 Days';
            } else if(remainingTime >= 55 && remainingTime <= 65) {
                mail = createEmail60Days(opp);
                log.emailType = '60 Days';
            } else if(remainingTime >= 25 && remainingTime <= 35) {
                mail = createEmail30Days(opp);
                log.emailType = '30 Days';
            } else {
                log.success = false;
                log.message = 'Skipped: Out of range (' + remainingTime + ' days)';
                result.emailLogs.add(log);
                continue;
            }
            
            if(mail != null) {
                emails.add(mail);
            }
        }
        
        return emails;
    }
    
    private static void sendEmails(List<Messaging.SingleEmailMessage> emails, Result result) {
        try {
            List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emails, false);
            
            for(Integer i = 0; i < sendResults.size(); i++) {
                Messaging.SendEmailResult ser = sendResults[i];
                Messaging.SingleEmailMessage mail = emails[i];
                
                EmailLog log = new EmailLog();
                log.opportunityId = mail.getWhatId();
                log.recipientEmail = mail.getToAddresses()[0];
                log.success = ser.isSuccess();
                log.emailType = getEmailType(mail.getSubject());
                
                if(ser.isSuccess()) {
                    result.successCount++;
                    log.message = 'Email sent successfully';
                } else {
                    result.failureCount++;
                    List<String> errors = new List<String>();
                    for(Messaging.SendEmailError err : ser.getErrors()) {
                        errors.add(err.getMessage());
                    }
                    log.message = String.join(errors, '; ');
                }
                result.emailLogs.add(log);
            }
        } catch(Exception e) {
            result.failureCount = emails.size();
            EmailLog errorLog = new EmailLog();
            errorLog.success = false;
            errorLog.message = 'Send Error: ' + e.getMessage();
            result.emailLogs.add(errorLog);
        }
    }
    
    private static void postToChatter(Result result) {
        try {
            FeedItem post = new FeedItem();
            post.ParentId = UserInfo.getUserId();
            post.Body = 'Rep End Date Emails: ' + result.successCount + 
                        ' sent, ' + result.failureCount + ' failed';
            insert post;
        } catch(Exception e) {
            // Silently fail if Chatter is disabled or no permission
            System.debug('Failed to post to Chatter: ' + e.getMessage());
        }
    }
    
    private static Messaging.SingleEmailMessage createEmail90Days(Opportunity opp) {
        String caseManagerName = opp.Account.Latest_Case_Created__r?.Owner?.Name ?? 'your case manager';
        String caseManagerEmail = opp.Account.Latest_Case_Created__r?.Owner?.Email;
        String caseNumber = opp.Account.Latest_Case_Created__r?.CaseNumber ?? opp.Name;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{opp.Account.PersonEmail});
        mail.setSubject('Reminder: Your Representation Ends in 3 Months');
        mail.setHtmlBody(
            'Hi ' + opp.Account.FirstName + ',<br/><br/>' +
            'We wanted to remind you that your representation will end on ' + 
            formatDate(opp.Representation_End_Date__c) + '. ' +
            'You still have 3 months remaining to complete all necessary steps.<br/><br/>' +
            'If you have any questions or need assistance, feel free to reach out.<br/><br/>' +
            'Thank you,<br/>' +
            caseManagerName + '<br/>' +
            'Innovative Tax Relief'
        );
        mail.setWhatId(opp.Id);
        mail.setSaveAsActivity(true);
        
        // Set Case Owner as sender
        if(String.isNotBlank(caseManagerEmail)) {
            mail.setReplyTo(caseManagerEmail);
            mail.setSenderDisplayName(caseManagerName);
        }
        
        return mail;
    }
    
    private static Messaging.SingleEmailMessage createEmail60Days(Opportunity opp) {
        String caseManagerName = opp.Account.Latest_Case_Created__r?.Owner?.Name ?? 'your case manager';
        String caseManagerEmail = opp.Account.Latest_Case_Created__r?.Owner?.Email;
        String caseNumber = opp.Account.Latest_Case_Created__r?.CaseNumber ?? opp.Name;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{opp.Account.PersonEmail});
        mail.setSubject('2 Months Left: Complete Your Case Obligations');
        mail.setHtmlBody(
            'Hi ' + opp.Account.FirstName + ',<br/><br/>' +
            'Your representation for Case #' + caseNumber + ' will end on ' + 
            formatDate(opp.Representation_End_Date__c) + ', which is just 2 months away. ' +
            'Please ensure that all documents and required actions are completed to avoid delays or issues with your case.<br/><br/>' +
            'Contact us if you need assistance.<br/><br/>' +
            'Best regards,<br/>' +
            caseManagerName + '<br/>' +
            'Innovative Tax Relief'
        );
        mail.setWhatId(opp.Id);
        mail.setSaveAsActivity(true);
        
        // Set Case Owner as sender
        if(String.isNotBlank(caseManagerEmail)) {
            mail.setReplyTo(caseManagerEmail);
            mail.setSenderDisplayName(caseManagerName);
        }
        
        return mail;
    }
    
    private static Messaging.SingleEmailMessage createEmail30Days(Opportunity opp) {
        String caseManagerName = opp.Account.Latest_Case_Created__r?.Owner?.Name ?? 'your case manager';
        String caseManagerEmail = opp.Account.Latest_Case_Created__r?.Owner?.Email;
        String caseNumber = opp.Account.Latest_Case_Created__r?.CaseNumber ?? opp.Name;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{opp.Account.PersonEmail});
        mail.setSubject('Urgent: Representation Ending Soon – Action Required');
        mail.setHtmlBody(
            'Hi ' + opp.Account.FirstName + ',<br/><br/>' +
            'Your representation for Case #' + caseNumber + ' will end on ' + 
            formatDate(opp.Representation_End_Date__c) + ', which is just 1 month away.<br/><br/>' +
            'You have the option to extend your representation to avoid your case being closed due to non-compliance.<br/> ' +
            'If you wish to extend, please contact me immediately to make arrangements.<br/><br/>' +
            'Failure to take action may result in the automatic closure of your case.<br/><br/>' +
            'Thank you,<br/>' +
            caseManagerName + '<br/>' +
            'Innovative Tax Relief'
        );
        mail.setWhatId(opp.Id);
        mail.setSaveAsActivity(true);
        
        // Set Case Owner as sender
        if(String.isNotBlank(caseManagerEmail)) {
            mail.setReplyTo(caseManagerEmail);
            mail.setSenderDisplayName(caseManagerName);
        }
        
        return mail;
    }
    
    private static String formatDate(Date d) {
        return d.month() + '/' + d.day() + '/' + d.year();
    }
    
    private static String getEmailType(String subject) {
        if(subject.contains('3 Months')) return '90 Days';
        if(subject.contains('2 Months')) return '60 Days';
        if(subject.contains('Urgent')) return '30 Days';
        return 'Unknown';
    }
    
    public class Request {
        @InvocableVariable(required=true label='Opportunities')
        public List<Opportunity> opportunities;
    }
    
    public class Result {
        @InvocableVariable(label='Success Count')
        public Integer successCount;
        
        @InvocableVariable(label='Failure Count')
        public Integer failureCount;
        
        @InvocableVariable(label='Email Logs')
        public List<EmailLog> emailLogs;
    }
    
    public class EmailLog {
        @InvocableVariable public String opportunityId;
        @InvocableVariable public String recipientEmail;
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
        @InvocableVariable public String emailType;
    }
}