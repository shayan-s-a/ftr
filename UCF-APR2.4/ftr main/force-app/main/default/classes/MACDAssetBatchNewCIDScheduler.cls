global class MACDAssetBatchNewCIDScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
      MACDAssetBatchNewCID b = new MACDAssetBatchNewCID(); 
      database.executebatch(b,100);
}
}