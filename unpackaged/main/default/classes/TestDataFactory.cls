@IsTest
public class TestDataFactory {
  public static Account createTestAccount() {
    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();

    Account account = new Account(
      FirstName = 'John',
      LastName = 'Doe',
      RecordTypeId = recordTypeId
    );
    insert account;
    return account;
  }

  public static Business__c createTestBusiness(Id accountId) {
    Business__c business = new Business__c(Name = 'Doe Enterprises', Related_Client__c = accountId);
    insert business;
    return business;
  }

  public static Opportunity createTestOpportunity(Id accountId) {
    Opportunity opportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today(),
      AccountId = accountId
    );
    insert opportunity;
    return opportunity;
  }

  public static Opportunity createTestOpportunityWithRecordType(
    Id accountId,
    String developerTypeName,
    String stageName
  ) {
    Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(developerTypeName)
      .getRecordTypeId();

    Opportunity opportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = stageName,
      CloseDate = Date.today(),
      AccountId = accountId,
      RecordTypeId = oppRecordTypeId
    );
    insert opportunity;
    return opportunity;
  }

  public static Case createTestCase(Id opportunityId) {
    Case testCase = new Case(
      Subject = 'Test Case',
      Status = 'Open',
      Opportunity__c = opportunityId
    );
    insert testCase;
    return testCase;
  }

  //Create Second Trade Opportunities with Account without Google Drive Folder
  public static void insertAccountsWithOppsBulk() {
    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    List<Account> accounts = new List<Account>();

    for (Integer i = 1; i < 100; i++) {
      accounts.add(
        new Account(
          FirstName = 'Test',
          LastName = ' Account GD ' + i,
          Google_Drive_Folder_ID__c = null,
          RecordTypeId = recordTypeId
        )
      );
    }
    insert accounts;

    Map<String, Id> accountIdMap = new Map<String, Id>();
    for (Account acc : [SELECT Id, Name FROM Account]) {
      accountIdMap.put(acc.Name, acc.Id);
    }

    Id secondTradeRecordTypeId = Schema.SObjectType.Opportunity
      .getRecordTypeInfosByName()
      .get('Second Trade')
      .getRecordTypeId();

    List<Opportunity> opportunities = new List<Opportunity>();
    for (Integer i = 1; i < 100; i++) {
      Id accountId = accountIdMap.get('Test Account GD ' + i);
      opportunities.add(
        new Opportunity(
          Name = 'Test Opportunity GD Second Trade ' + i,
          AccountId = accountId,
          StageName = 'Set Appointment',
          CloseDate = Date.today().addDays(30),
          RecordTypeId = secondTradeRecordTypeId
        )
      );
    }
    insert opportunities;
  }

  public static void insertAccountsBulk() {
    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    List<Account> accounts = new List<Account>();

    for (Integer i = 1; i < 100; i++) {
      accounts.add(
        new Account(
          FirstName = 'Test',
          LastName = ' Account GD ' + i,
          Google_Drive_Folder_ID__c = null,
          RecordTypeId = recordTypeId
        )
      );
    }
    insert accounts;
  }

  public static void insertAccount(String firstName, String lastName) {
    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    Account account = new Account(
      FirstName = firstName,
      LastName = lastName,
      Google_Drive_Folder_ID__c = null,
      RecordTypeId = recordTypeId
    );
    insert account;
  }

  public static Id getOppRecordTypeId(String recordTypeName) {
    return Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get(recordTypeName)
      .getRecordTypeId();
  }

  public static Opportunity createOpportunity(String name, Id recordTypeId) {
    Opportunity opp = new Opportunity(
      Name = name,
      StageName = 'Prospecting',
      CloseDate = System.today().addDays(30),
      RecordTypeId = recordTypeId
    );
    insert opp;
    return opp;
  }

  public static bt_stripe__Payment_Schedule__c createPaymentSchedule(Id opportunityId) {
    bt_stripe__Payment_Schedule__c schedule = new bt_stripe__Payment_Schedule__c(
      Opportunity__c = opportunityId
    );
    insert schedule;
    return schedule;
  }

  public static bt_stripe__Transaction__c createTransaction(
    Id scheduleId,
    Id opportunityId,
    String status,
    Decimal amount
  ) {
    bt_stripe__Transaction__c trans = new bt_stripe__Transaction__c(
      bt_stripe__Transaction_Status__c = status,
      bt_stripe__Amount__c = amount,
      bt_stripe__Payment_Schedule__c = scheduleId,
      bt_stripe__Opportunity2__c = opportunityId,
      bt_stripe__Due_Date__c = System.today()
    );
    insert trans;
    return trans;
  }

  public static List<Lead> buildLeadRecords() {
    List<Lead> leads = new List<Lead>();
    leads.add(
      new Lead(
        FirstName = 'James',
        LastName = 'Bond',
        Email = 'james.bond@example.com',
        LeadSource = 'DT Form',
        Total_Tax_Debt__c = 50000,
        Status = 'Working',
        MobilePhone = '5555555555'
      )
    );
    return leads;
  }

  public static void createLivevoxConfiguration() {
    Livevox_Integration_Configuration__c existingSession = new Livevox_Integration_Configuration__c();
    existingSession.Name = 'ITR Session';
    existingSession.sessionId__c = '1234';
    existingSession.DT_Form_campaingId__c = '23455';
    existingSession.DT_Form_DS_campaing_Id__c = '32142';
    insert existingSession;
  }

    public static Task createTask(String subject) {
        Task testTask = new Task(Subject = subject);
        insert testTask;
        return testTask;
    }

    public static ContentVersion createContentVersion(String title, String pathOnClient, Blob versionData) {
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = pathOnClient;
        cv.VersionData = versionData;
        insert cv;
        return cv;
    }
}