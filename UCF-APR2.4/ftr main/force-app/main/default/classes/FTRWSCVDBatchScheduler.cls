global class FTRWSCVDBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      FTRWSCVDBatch b = new FTRWSCVDBatch(); 
      database.executebatch(b,100);
   }
}