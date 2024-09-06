global class SchedulerforOpportunityLockBatchJob implements Schedulable{
    
    global void execute(SchedulableContext sc)  {
        
        Database.executeBatch(new OpportunityLockBatchJob(),120);
    }
    
}