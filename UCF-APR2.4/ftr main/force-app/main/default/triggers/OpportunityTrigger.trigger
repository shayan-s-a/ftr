trigger OpportunityTrigger on Opportunity(after delete, after insert, after undelete,after update, before delete, before insert, before update) {
     //no need to run trigger if ProdRevenueOppUpdateBatch class is running.
     if(!ProdRevenueOppUpdateBatch.isProRevRunning){
    	     TriggerDispatcher.Run(new OpportunityTriggerHandler()); 
     }
}