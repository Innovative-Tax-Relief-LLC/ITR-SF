@isTest
public class ScheduleDeleteErrorLogsBatchTest {
    @isTest
    static void testScheduleBatch() {
        List<ActiveCamp__Error_Log__c> logs = new List<ActiveCamp__Error_Log__c>();
        for (Integer i = 0; i < 5; i++) {
            logs.add(new ActiveCamp__Error_Log__c(Name = 'Error Log ' + i, CreatedDate = DateTime.now().addDays(-5)));
        }
        insert logs;

        // Verify test data insertion
        Assert.areEqual(5, [SELECT COUNT() FROM ActiveCamp__Error_Log__c]);

        // Schedule the batch
        String jobName = 'Test Delete Error Logs Batch';
        String cronExpression = '0 0 0 * * ?'; // Daily at midnight
        ScheduleDeleteErrorLogsBatch scheduleClass = new ScheduleDeleteErrorLogsBatch();
        Id scheduledJobId = System.schedule(jobName, cronExpression, scheduleClass);

        // Verify the job is scheduled
        CronTrigger ct = [SELECT Id, CronExpression, State FROM CronTrigger WHERE Id = :scheduledJobId];
        System.assertEquals('WAITING', ct.State);

        // Run the batch
        Test.startTest();
        Database.executeBatch(new DeleteErrorLogsBatch(), 200);
        Test.stopTest();

        // Verify records are deleted
        Assert.areEqual(0, [SELECT COUNT() FROM ActiveCamp__Error_Log__c]);
    }
}