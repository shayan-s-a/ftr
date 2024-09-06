global class MACDAccountIdCapsUpdateBatchScheduler implements Schedulable{
// MACD ***
    global void execute(SchedulableContext sc) {
        MACDAccountIdCapsUpdateBatch b = new MACDAccountIdCapsUpdateBatch(); 
        Database.executeBatch(b);
     }

}