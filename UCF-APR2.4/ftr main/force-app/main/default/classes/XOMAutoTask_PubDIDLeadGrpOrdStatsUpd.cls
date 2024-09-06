global class XOMAutoTask_PubDIDLeadGrpOrdStatsUpd implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {

    global void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items) {


     //Constants
     String ATTR_REF_ID = 'ATTR_FRLRefId';
     String STATUS = 'Completed';
     System.debug('XOMAutoTask_SIPPublishFulfilmentStatus:Order Items-->'+JSON.serialize(items));  
     List<PublishDIDLeadGrpOrderStatusUpdate__e> statusUpdateEventList = new List<PublishDIDLeadGrpOrderStatusUpdate__e>();
     Set<Id> itemIds = new Set<Id>();

     if(items.size() > 0) {
         for(vlocity_cmt__OrchestrationItem__c item : items) {
             itemIds.add(item.Id);
         }
         items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                 FROM vlocity_cmt__OrchestrationItem__c where Id IN: itemIds];

         for (vlocity_cmt__OrchestrationItem__c item : items) {

             String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
             String attrReferenceId = ATTR_REF_ID;//'Fulfilment Request Line Reference Id'; 
             System.debug('XOMAutoTask_SIPPublishFulfilmentStatus:attrReferenceId-->'+attrReferenceId); 
             PublishDIDLeadGrpOrderStatusUpdate__e event = new PublishDIDLeadGrpOrderStatusUpdate__e();
             event.FRL_Id__c = item.vlocity_cmt__FulfilmentRequestLineId__c;
             event.FRL_Reference_Id__c = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, attrReferenceId);
             event.JSONAttribute__c = jsonAttribute;
             event.Object_Type__c = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c;
             event.Orchestration_Item_Id__c = item.Id;
             event.Plan_Id__c = item.vlocity_cmt__OrchestrationPlanId__c;
             event.Product_Code__c = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
             event.Status__c = STATUS; //default
             statusUpdateEventList.add(event);
             
             
         }
     }
     System.debug('XOMAutoTask_SIPPublishFulfilmentStatus:statusUpdateEventList-->'+JSON.serialize(statusUpdateEventList)); 
     List<Database.SaveResult> results = EventBus.publish(statusUpdateEventList);

     // Inspect publishing result for each event
     for (Database.SaveResult sr : results) {
         if (sr.isSuccess()) {
             System.debug('Successfully published event..'+ sr.getId());
         } else {
             for(Database.Error err : sr.getErrors()) {
                 System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
             }
         }       
     }
 }


}