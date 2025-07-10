@IsTest
private class CaseOwnerEmailActionTest {
    private static final String TEST_EMAIL = 'test@example.com';

    @TestSetup
    static void makeData() {
        String uniqueUsername = 'testuser' + Datetime.now().getTime() + '@testorg.com';
        User testUser = TestUtility.createUser(
            uniqueUsername,
            'testuser' + Datetime.now().getTime(),
            uniqueUsername
        );
        insert testUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            EmailTemplate testTemplate = TestUtility.createEmailTemplate(
                'Test Template',
                'Test_Template_' + Datetime.now().getTime()
            );
            insert testTemplate;
        }

        Account testAccount = TestUtility.createAccount('Test Account', 'Banking');
        insert testAccount;

        Contact testContact = TestUtility.createContact(testAccount.Id, 'Contact');
        testContact.Email = TEST_EMAIL;
        insert testContact;

        Case testCase = TestUtility.createCase(testAccount.Id, testContact.Id, testUser.Id);
        insert testCase;
    }

    @IsTest
    static void caseOwnerEmailAction_sendEmailToCaseOwner_emailSentSuccessfully() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        EmailTemplate testTemplate = [SELECT Id FROM EmailTemplate LIMIT 1];

        CaseOwnerEmailAction.EmailRequest request = new CaseOwnerEmailAction.EmailRequest();
        request.caseId = testCase.Id;
        request.emailTemplateId = testTemplate.Id;
        request.recipientId = testContact.Id;

        Test.startTest();
        List<CaseOwnerEmailAction.EmailResponse> responses = CaseOwnerEmailAction.sendEmailToCaseOwner(new List<CaseOwnerEmailAction.EmailRequest>{request});
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(true, responses[0].isSuccess, 'Email should be sent successfully');
        System.assertEquals(null, responses[0].errorMessage, 'Error message should be null');
    }

    @IsTest
    static void caseOwnerEmailAction_sendEmailToCaseOwner_invalidCaseNotFound() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        EmailTemplate testTemplate = [SELECT Id FROM EmailTemplate LIMIT 1];

        CaseOwnerEmailAction.EmailRequest request = new CaseOwnerEmailAction.EmailRequest();
        request.caseId = '500000000000000000';
        request.emailTemplateId = testTemplate.Id;
        request.recipientId = testContact.Id;

        Test.startTest();
        List<CaseOwnerEmailAction.EmailResponse> responses = CaseOwnerEmailAction.sendEmailToCaseOwner(new List<CaseOwnerEmailAction.EmailRequest>{request});
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(false, responses[0].isSuccess, 'Email should not be sent successfully');
        System.assert(responses[0].errorMessage.contains('Record not found'), 'Should return record not found error');
    }

    @IsTest
    static void caseOwnerEmailAction_sendEmailToCaseOwner_invalidTemplateNotFound() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        CaseOwnerEmailAction.EmailRequest request = new CaseOwnerEmailAction.EmailRequest();
        request.caseId = testCase.Id;
        request.emailTemplateId = '000000000000000000';
        request.recipientId = testContact.Id;

        Test.startTest();
        List<CaseOwnerEmailAction.EmailResponse> responses = CaseOwnerEmailAction.sendEmailToCaseOwner(new List<CaseOwnerEmailAction.EmailRequest>{request});
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(false, responses[0].isSuccess, 'Email should not be sent successfully');
        System.assert(responses[0].errorMessage.contains('Record not found'), 'Should return record not found error');
    }

    @IsTest
    static void caseOwnerEmailAction_sendEmailToCaseOwner_bulkEmailsSentSuccessfully() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        EmailTemplate testTemplate = [SELECT Id FROM EmailTemplate LIMIT 1];

        List<CaseOwnerEmailAction.EmailRequest> requests = new List<CaseOwnerEmailAction.EmailRequest>();
        for(Integer i = 0; i < 10; i++) {
            CaseOwnerEmailAction.EmailRequest request = new CaseOwnerEmailAction.EmailRequest();
            request.caseId = testCase.Id;
            request.emailTemplateId = testTemplate.Id;
            request.recipientId = testContact.Id;
            requests.add(request);
        }

        Test.startTest();
        List<CaseOwnerEmailAction.EmailResponse> responses = CaseOwnerEmailAction.sendEmailToCaseOwner(requests);
        Test.stopTest();

        System.assertEquals(10, responses.size(), 'Should return ten responses');
        for(CaseOwnerEmailAction.EmailResponse response : responses) {
            System.assertEquals(true, response.isSuccess, 'Email should be sent successfully');
            System.assertEquals(null, response.errorMessage, 'Error message should be null');
        }
    }

    @IsTest
    static void caseOwnerEmailAction_sendEmailToCaseOwner_generalExceptionThrown() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        EmailTemplate testTemplate = [SELECT Id FROM EmailTemplate LIMIT 1];

        CaseOwnerEmailAction.EmailRequest request = new CaseOwnerEmailAction.EmailRequest();
        request.caseId = testCase.Id;
        request.emailTemplateId = testTemplate.Id;
        request.recipientId = null;

        Test.startTest();
        List<CaseOwnerEmailAction.EmailResponse> responses = CaseOwnerEmailAction.sendEmailToCaseOwner(new List<CaseOwnerEmailAction.EmailRequest>{request});
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(false, responses[0].isSuccess, 'Email should not be sent successfully');
        System.assert(responses[0].errorMessage.startsWith('Error sending email:'), 'Should return general error message');
    }

    @IsTest
    static void caseOwnerEmailAction_sendEmailToCaseOwner_fatalErrorOccurred() {
        Test.startTest();
        List<CaseOwnerEmailAction.EmailResponse> responses = CaseOwnerEmailAction.sendEmailToCaseOwner(null);
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(false, responses[0].isSuccess, 'Should not be successful');
        System.assert(responses[0].errorMessage.startsWith('Fatal error:'), 'Should return fatal error message');
    }
}