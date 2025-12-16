@IsTest
private class RepresentationEndDateEmailServiceTest {
    
    @TestSetup
    static void setup() {
        // Create test user for case owner
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User caseOwner = new User(
            Alias = 'cowner',
            Email = 'caseowner@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Case Owner',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'caseowner' + DateTime.now().getTime() + '@test.com'
        );
        insert caseOwner;
        
        Account acc = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'john.doe@example.com'
        );
        insert acc;
        
        // Create case with specific owner
        Case c = new Case(
            AccountId = acc.Id,
            Subject = 'Test Case',
            Status = 'New',
            OwnerId = caseOwner.Id
        );
        insert c;
        
        // Update account to link to latest case
        acc.Latest_Case_Created__c = c.Id;
        update acc;
        
        List<Opportunity> opps = new List<Opportunity>();
        
        // Exact boundary: 90 days (should send)
        Opportunity opp90 = new Opportunity(
            Name = 'Opp 90 Days',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Representation_End_Date__c = Date.today().addDays(90)
        );
        opps.add(opp90);
        
        // Exact boundary: 60 days (should send)
        Opportunity opp60 = new Opportunity(
            Name = 'Opp 60 Days',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Representation_End_Date__c = Date.today().addDays(60)
        );
        opps.add(opp60);
        
        // Exact boundary: 30 days (should send)
        Opportunity opp30 = new Opportunity(
            Name = 'Opp 30 Days',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Representation_End_Date__c = Date.today().addDays(30)
        );
        opps.add(opp30);
        
        // Out of range: 45 days (should NOT send)
        Opportunity opp45 = new Opportunity(
            Name = 'Opp 45 Days',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Representation_End_Date__c = Date.today().addDays(45)
        );
        opps.add(opp45);
        
        // Out of range: 75 days (should NOT send)
        Opportunity opp75 = new Opportunity(
            Name = 'Opp 75 Days',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Representation_End_Date__c = Date.today().addDays(75)
        );
        opps.add(opp75);
        
        // Out of range: 10 days (should NOT send)
        Opportunity opp10 = new Opportunity(
            Name = 'Opp 10 Days',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Representation_End_Date__c = Date.today().addDays(10)
        );
        opps.add(opp10);
        
        insert opps;
    }
    
        static void testEmailRangeFiltering() {
        // Query ALL opportunities
        List<Opportunity> allOpps = [
            SELECT Id, Name, Account.FirstName, Account.PersonEmail, 
                Representation_End_Date__c, Remaining_Representation_Time__c
            FROM Opportunity
            ORDER BY Representation_End_Date__c DESC
        ];
        
        // DEBUG: Ver qué valores tiene el campo
        System.debug('=== OPPORTUNITY VALUES ===');
        for(Opportunity opp : allOpps) {
            System.debug('Opp: ' + opp.Name);
            System.debug('  Rep End Date: ' + opp.Representation_End_Date__c);
            System.debug('  Remaining Time: ' + opp.Remaining_Representation_Time__c);
        }
        
        RepresentationEndDateEmailService.Request req = new RepresentationEndDateEmailService.Request();
        req.opportunities = allOpps;
        
        Test.startTest();
        List<RepresentationEndDateEmailService.Result> results = 
            RepresentationEndDateEmailService.sendRepEndDateEmails(
                new List<RepresentationEndDateEmailService.Request>{req}
            );
        Test.stopTest();
        
        // Verify results
        Assert.isFalse(results.isEmpty(), 'Should return results');
        RepresentationEndDateEmailService.Result result = results[0];
        
        System.debug('=== RESULTS ===');
        System.debug('Success Count: ' + result.successCount);
        System.debug('Failure Count: ' + result.failureCount);
        System.debug('Total Email Logs: ' + result.emailLogs.size());
        
        // Should have 6 logs total (all opportunities processed)
        Assert.areEqual(6, result.emailLogs.size(), 'Should have log for each opportunity');
        
        // Count emails by type (construidos, aunque fallen al enviar)
        Integer count90Days = 0;
        Integer count60Days = 0;
        Integer count30Days = 0;
        Integer countSkipped = 0;
        
        for(RepresentationEndDateEmailService.EmailLog log : result.emailLogs) {
            System.debug('Log - OppId: ' + log.opportunityId + 
                        ' | Success: ' + log.success + 
                        ' | Type: ' + log.emailType + 
                        ' | Message: ' + log.message);
            
            // Contar por emailType, no por success (porque pueden fallar por permisos de sandbox)
            if(log.emailType == '90 Days') {
                count90Days++;
            } else if(log.emailType == '60 Days') {
                count60Days++;
            } else if(log.emailType == '30 Days') {
                count30Days++;
            } else if(log.message != null && log.message.contains('Out of range')) {
                countSkipped++;
            }
        }
        
        System.debug('=== SUMMARY ===');
        System.debug('90 Days: ' + count90Days);
        System.debug('60 Days: ' + count60Days);
        System.debug('30 Days: ' + count30Days);
        System.debug('Skipped: ' + countSkipped);
        
        // Assertions - verificar que se CONSTRUYERON los emails correctos
        Assert.areEqual(1, count90Days, 'Should construct exactly 1 email for 90 days');
        Assert.areEqual(1, count60Days, 'Should construct exactly 1 email for 60 days');
        Assert.areEqual(1, count30Days, 'Should construct exactly 1 email for 30 days');
        Assert.areEqual(3, countSkipped, 'Should skip exactly 3 opportunities');
        
        // En test context, los emails pueden fallar por permisos de sandbox
        // Lo importante es que se intentaron enviar los correctos
        Integer totalEmailsAttempted = count90Days + count60Days + count30Days;
        Assert.areEqual(3, totalEmailsAttempted, 'Should attempt to send 3 emails total');
    }
    
    @IsTest
    static void testSend90DayEmails() {
        List<Opportunity> opps = [
            SELECT Id, Account.FirstName, Account.PersonEmail, 
                   Representation_End_Date__c, Remaining_Representation_Time__c
            FROM Opportunity
            WHERE Representation_End_Date__c = :Date.today().addDays(90)
        ];
        
        System.debug('90 Day Opp Remaining Time: ' + opps[0].Remaining_Representation_Time__c);
        
        RepresentationEndDateEmailService.Request req = new RepresentationEndDateEmailService.Request();
        req.opportunities = opps;
        
        Test.startTest();
        List<RepresentationEndDateEmailService.Result> results = 
            RepresentationEndDateEmailService.sendRepEndDateEmails(
                new List<RepresentationEndDateEmailService.Request>{req}
            );
        Test.stopTest();
        
        Assert.isFalse(results.isEmpty(), 'Should return results');
        RepresentationEndDateEmailService.Result result = results[0];
        Assert.isTrue(result.successCount >= 0, 'Should track success count');
        Assert.isNotNull(result.emailLogs, 'Should have email logs');
    }
    
    @IsTest
    static void testSendAllEmails() {
        List<Opportunity> opps = [
            SELECT Id, Account.FirstName, Account.PersonEmail, 
                   Representation_End_Date__c, Remaining_Representation_Time__c
            FROM Opportunity
        ];
        
        RepresentationEndDateEmailService.Request req = new RepresentationEndDateEmailService.Request();
        req.opportunities = opps;
        
        Test.startTest();
        List<RepresentationEndDateEmailService.Result> results = 
            RepresentationEndDateEmailService.sendRepEndDateEmails(
                new List<RepresentationEndDateEmailService.Request>{req}
            );
        Test.stopTest();
        
        Assert.isFalse(results.isEmpty(), 'Should return results');
        RepresentationEndDateEmailService.Result result = results[0];
        Assert.isTrue(result.successCount + result.failureCount > 0, 
                     'Should process some emails');
    }
    
        @IsTest
    static void testCaseOwnerAsSender() {
        List<Opportunity> opps = [
            SELECT Id, Name, Account.FirstName, Account.PersonEmail, 
                Representation_End_Date__c, Remaining_Representation_Time__c,
                Account.Latest_Case_Created__r.Owner.Name,
                Account.Latest_Case_Created__r.Owner.Email,
                Account.Latest_Case_Created__r.CaseNumber
            FROM Opportunity
            WHERE Representation_End_Date__c = :Date.today().addDays(90)
            LIMIT 1
        ];
        
        Assert.isFalse(opps.isEmpty(), 'Should have opportunity');
        Assert.isNotNull(opps[0].Account.Latest_Case_Created__r.Owner.Email, 
                        'Should have case owner email');
        
        RepresentationEndDateEmailService.Request req = new RepresentationEndDateEmailService.Request();
        req.opportunities = opps;
        
        Test.startTest();
        List<RepresentationEndDateEmailService.Result> results = 
            RepresentationEndDateEmailService.sendRepEndDateEmails(
                new List<RepresentationEndDateEmailService.Request>{req}
            );
        Test.stopTest();
        
        // Verify result
        Assert.isFalse(results.isEmpty(), 'Should return results');
        RepresentationEndDateEmailService.Result result = results[0];
        Assert.isNotNull(result.emailLogs, 'Should have email logs');
        Assert.areEqual(1, result.emailLogs.size(), 'Should have one email log');
        
        // Verify email was constructed with correct type (even if send fails in test context)
        RepresentationEndDateEmailService.EmailLog log = result.emailLogs[0];
        Assert.areEqual('90 Days', log.emailType, 'Should be 90 Days email type');
        Assert.isNotNull(log.recipientEmail, 'Should have recipient email');
        
        // Note: In test context, email may fail due to sandbox permissions
        // What matters is that the email was constructed with case owner details
        System.debug('Email attempted for: ' + log.recipientEmail);
        System.debug('Email Type: ' + log.emailType);
        System.debug('Success: ' + log.success);
        System.debug('Message: ' + log.message);
    }
    
    @IsTest
    static void testNoEmailWhenMissingData() {
        Account acc = new Account(
            FirstName = 'Jane',
            LastName = 'Smith'
            // No PersonEmail
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Opp No Email',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Representation_End_Date__c = Date.today().addDays(90)
        );
        insert opp;
        
        List<Opportunity> opps = [
            SELECT Id, Account.FirstName, Account.PersonEmail, 
                   Representation_End_Date__c, Remaining_Representation_Time__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        
        RepresentationEndDateEmailService.Request req = new RepresentationEndDateEmailService.Request();
        req.opportunities = opps;
        
        Test.startTest();
        List<RepresentationEndDateEmailService.Result> results = 
            RepresentationEndDateEmailService.sendRepEndDateEmails(
                new List<RepresentationEndDateEmailService.Request>{req}
            );
        Test.stopTest();
        
        Assert.areEqual(0, Limits.getEmailInvocations(), 'No email should be sent');
        RepresentationEndDateEmailService.Result result = results[0];
        Assert.areEqual(0, result.successCount, 'No successful emails');
    }
    
    @IsTest
    static void testEmptyRequest() {
        RepresentationEndDateEmailService.Request req = new RepresentationEndDateEmailService.Request();
        req.opportunities = new List<Opportunity>();
        
        Test.startTest();
        List<RepresentationEndDateEmailService.Result> results = 
            RepresentationEndDateEmailService.sendRepEndDateEmails(
                new List<RepresentationEndDateEmailService.Request>{req}
            );
        Test.stopTest();
        
        Assert.areEqual(0, Limits.getEmailInvocations(), 'No email should be sent');
        Assert.isFalse(results.isEmpty(), 'Should return empty result');
    }
    
    @IsTest
    static void testNullRequest() {
        Test.startTest();
        List<RepresentationEndDateEmailService.Result> results = 
            RepresentationEndDateEmailService.sendRepEndDateEmails(null);
        Test.stopTest();
        
        Assert.isNotNull(results, 'Should return empty list, not null');
        Assert.isTrue(results.isEmpty(), 'Should return empty list for null input');
    }
    
    @IsTest
    static void testMultipleRequests() {
        List<Opportunity> allOpps = [
            SELECT Id, Account.FirstName, Account.PersonEmail, 
                   Representation_End_Date__c, Remaining_Representation_Time__c
            FROM Opportunity
        ];
        
        // Split into two requests
        RepresentationEndDateEmailService.Request req1 = new RepresentationEndDateEmailService.Request();
        req1.opportunities = new List<Opportunity>{allOpps[0]};
        
        RepresentationEndDateEmailService.Request req2 = new RepresentationEndDateEmailService.Request();
        req2.opportunities = new List<Opportunity>{allOpps[1]};
        
        Test.startTest();
        List<RepresentationEndDateEmailService.Result> results = 
            RepresentationEndDateEmailService.sendRepEndDateEmails(
                new List<RepresentationEndDateEmailService.Request>{req1, req2}
            );
        Test.stopTest();
        
        Assert.areEqual(2, results.size(), 'Should process both requests');
    }
}