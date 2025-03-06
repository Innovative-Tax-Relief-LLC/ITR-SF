global class ScheduleDeleteErrorLogsBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        DeleteErrorLogsBatch batch = new DeleteErrorLogsBatch();
        Database.executeBatch(batch, 200);
    }
}