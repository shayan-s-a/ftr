public class PendingApprovalReminderSchedule implements Schedulable {
    public void execute(SchedulableContext SC) {
        PendingApprovalReminderBatch b = new PendingApprovalReminderBatch(); 
        Database.executeBatch(b);
    }
}