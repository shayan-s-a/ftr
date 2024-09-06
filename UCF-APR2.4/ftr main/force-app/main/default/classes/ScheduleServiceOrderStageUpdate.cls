global class ScheduleServiceOrderStageUpdate implements Schedulable {
    global void execute(SchedulableContext SC) {
        BatchServiceOrderStageUpdate b = new BatchServiceOrderStageUpdate();
        Database.executeBatch(b, 100);
    }
 }