@isTest
public class LeadTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createLivevoxConfiguration(); 
    }
    @isTest
    static void testAfterInsert() {
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(LastName = 'Test1', Company = 'Company1', LeadSource = 'DT Form'));
        leads.add(new Lead(LastName = 'Test2', Company = 'Company2', LeadSource = 'DT Form DS'));
        leads.add(new Lead(LastName = 'Test3', Company = 'Company3', LeadSource = 'Other Source'));

        Test.startTest();
        insert leads;
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable'];
        Assert.isTrue(jobs.size() > 0, 'A Queueable job should be enqueued for valid leads.');
    }

    @isTest
    static void testAfterInsertWithNoValidLeads() {
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(LastName = 'Test1', Company = 'Company1', LeadSource = 'Other Source'));
        leads.add(new Lead(LastName = 'Test2', Company = 'Company2', LeadSource = 'Invalid Source'));

        Test.startTest();
        insert leads;
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable' and ApexClass.Name = 'LivevoxIntegrationQueueable'];
        Assert.areEqual(0, jobs.size(), 'No Queueable job should be enqueued for invalid leads.');
    }

   

}