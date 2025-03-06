@isTest
public class DeleteErrorLogsBatchTest {
    @isTest
    static void testDeleteErrorLogsBatch() {
        List<ActiveCamp__Error_Log__c> logs = new List<ActiveCamp__Error_Log__c>();
        for (Integer i = 0; i < 5; i++) {
            logs.add(new ActiveCamp__Error_Log__c(Name = 'Error Log ' + i, CreatedDate = DateTime.now().addDays(-5)));
        }
        insert logs;

        Assert.areEqual(5, [SELECT COUNT() FROM ActiveCamp__Error_Log__c], 'Test data was not inserted correctly.');

        Test.startTest();
        DeleteErrorLogsBatch batch = new DeleteErrorLogsBatch();
        Database.executeBatch(batch, 200); 
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM ActiveCamp__Error_Log__c], 'Records were not deleted by the batch.');
    }
}