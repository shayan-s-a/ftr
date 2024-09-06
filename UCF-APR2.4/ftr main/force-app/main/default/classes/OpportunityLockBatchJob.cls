global class OpportunityLockBatchJob implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //collect all  open Opportunities
        return Database.getQueryLocator([Select Id,OpportunityId, Order_Opportunity_Unlocked__c from Quote where vlocity_cmt__pricelistid__c <> null AND Order_Opportunity_Unlocked__c = true]);
    }
    global void execute(Database.BatchableContext bc, List<Quote> scope){
        // process each batch of records and lock the record 
        for(Quote quoteObj: scope){
            if (!Approval.isLocked(quoteObj.OpportunityId)){
                Approval.lock(quoteObj.OpportunityId);
            }
            quoteObj.Order_Opportunity_Unlocked__c = false;
        }
        
        if(scope.size() > 0){
            update scope;
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}