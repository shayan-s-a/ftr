global class XOMAutotask_PushLeadOrder implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask{
   
     public static final String ITEM_NAME = 'UCF WaitForInitiateDIDLeadOrder';
       
    
    global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items){
        
        Set<Id> frlIds = new Set<Id>();
        Set<Id> frlLeadIds = new Set<Id>();
        Set<Id> planIds = new Set<Id>();
        String  serviceAccountId = '';
        String BillingTelephoneNumber='';
        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
        
         for (vlocity_cmt__OrchestrationItem__c item : items) {
                
                frlIds.add(item.vlocity_cmt__fulfilmentRequestLineId__c);
                planIds.add(item.vlocity_cmt__OrchestrationPlanId__c);
            }
        
        /* -------This is for Getting the service AccountId From MDNOrder Fulfillment------ */
        
            List<vlocity_cmt__FulfilmentRequestLine__c> frlsForMDN = [SELECT Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber, 
                                                                      vlocity_cmt__Product2Id__r.Name FROM vlocity_cmt__FulfilmentRequestLine__c
                                                                      WHERE Id=:frlIds WITH SECURITY_ENFORCED];
        
            for(vlocity_cmt__FulfilmentRequestLine__c frl:frlsForMDN){
              
               serviceAccountId = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'ATTR_SERV_ACCT');
               BillingTelephoneNumber = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'BillingTelephoneNumber');
            }
        
        /*-------This is for setting the Wait Sempahore Value By Comparing the Service AccountId From MDNOrder Fulfillment To LeadOrder ------*/
        
         Map<String, Object> attrVals = new Map<String, Object>{
                  'ATTR_WaitSemaphore' => 'True',
                   'BillingTelephoneNumber'=>BillingTelephoneNumber
           };
         
        List<vlocity_cmt__OrchestrationItem__c> itemForLead = [Select Id,vlocity_cmt__fulfilmentRequestLineId__c,vlocity_cmt__OrchestrationPlanId__c from vlocity_cmt__OrchestrationItem__c where vlocity_cmt__OrchestrationPlanId__c=:planIds And Name =:ITEM_NAME];
        
        for(vlocity_cmt__OrchestrationItem__c LeadItems: itemForLead){
            
            frlLeadIds.add(LeadItems.vlocity_cmt__fulfilmentRequestLineId__c);
        }
        
         List<vlocity_cmt__FulfilmentRequestLine__c> frlsForLead = [SELECT Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber, 
                                                                    vlocity_cmt__Product2Id__r.Name FROM vlocity_cmt__FulfilmentRequestLine__c
                                                                    WHERE vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__c=:planIds AND Id=:frlLeadIds WITH SECURITY_ENFORCED];
        
        for(vlocity_cmt__FulfilmentRequestLine__c leadfrls:frlsForLead){
            
            if(serviceAccountId == (String)ftr_CpqHelper.getJSONAttributeValue(leadfrls.vlocity_cmt__JSONAttribute__c, 'ATTR_SERV_ACCT')){
                
                  leadfrls.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(leadfrls.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                  frlsToUpdateMap.put(leadfrls.Id,leadfrls);
            }
        }
          if(frlsToUpdateMap.values().size()>0){
            try{
                List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                            System.debug('XOMAutoTask_InitiateBulkOrder: Error while updating Attr_WaitBulk: '+ err.getStatusCode() + ' ' + err.getMessage());
                        }
                      
                    }
                }
            } catch(Exception e) {
                System.debug('Exception in ftr_OrderManagementService..'+ e.getMessage());
               
            }
    }
    }
}