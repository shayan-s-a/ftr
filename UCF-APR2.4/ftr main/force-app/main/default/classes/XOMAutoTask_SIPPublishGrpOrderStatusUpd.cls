global class  XOMAutoTask_SIPPublishGrpOrderStatusUpd implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask{
    
     

    global void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items) {
        System.debug('XOMAutoTask_SIPPublishGrpOrderStatusUpdate:Order Items-->'+JSON.serialize(items));
        
        //Constants
        String ATTR_REF_ID = 'ATTR_FRLRefId';
        String STATUS = 'Completed';
       

        List<PublishGrpOrderStatusUpdate__e> statusUpdateEventList = new List<PublishGrpOrderStatusUpdate__e>();
        Set<Id> itemIds = new Set<Id>(); 
        Set<Id> planIds = new Set<Id>();
        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
        System.debug('XOMAutoTask_SIPPublishGrpOrderStatusUpdate:Size-->'+items.size());       
        if(items.size() > 0) {
            
            for(vlocity_cmt__OrchestrationItem__c item : items) {
                itemIds.add(item.Id);
                planIds.add(item.vlocity_cmt__OrchestrationPlanId__c);
            }
            items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                    FROM vlocity_cmt__OrchestrationItem__c where Id IN: itemIds];

             
            for (vlocity_cmt__OrchestrationItem__c item : items) {

                String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                System.debug(':::: jsonAttribute and PLanIDs'+jsonAttribute+'::: planIds'+planIds);
                frlsToUpdateMap = btnOnLead(jsonAttribute,planIds);
                String attrReferenceId = ATTR_REF_ID;//'Fulfilment Request Line Reference Id'; 

                PublishGrpOrderStatusUpdate__e event = new PublishGrpOrderStatusUpdate__e();
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

        if(frlsToUpdateMap.values().size()>0){
            try{
                List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                for (Database.SaveResult result : results) { if (!result.isSuccess()){ for (Database.Error err : result.getErrors()){ System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                        }
                    }
                }
            } catch(Exception e) { System.debug('Exception in Subscriber..'+ e.getMessage()); }
        }

        List<Database.SaveResult> results = EventBus.publish(statusUpdateEventList);

        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('PublishGrpOrderStatusUpdate:Successfully published event..'+ sr.getId());
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
 
    public static Map<Id,vlocity_cmt__FulfilmentRequestLine__c> btnOnLead(String MDNJson,Set<Id> planIds){


       Set<Id> fulfilmentRequestLineId = new Set<Id>();
       String BTNNumber = 'BillingTelephoneNumber';
       Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
       String btnForLead = (String)ftr_CpqHelper.getJSONAttributeValue(MDNJson, 'MainDirectoryNumber');
       String didForLead = (String)ftr_CpqHelper.getJSONAttributeValue(MDNJson, 'ATTR_DID_LOC');

       System.debug('::::: btnForLead'+btnForLead);
       System.debug('::::: didForLead'+didForLead);
       Map<String, Object> attrValsLead = new Map<String, Object>{
        BTNNumber => btnForLead  
    };
       
      List<vlocity_cmt__OrchestrationItem__c> leadItems =[Select Id,vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c from vlocity_cmt__OrchestrationItem__c where Name ='WaitForInitiateDIDLeadOrder' AND vlocity_cmt__OrchestrationPlanId__c IN:planIds AND vlocity_cmt__State__c ='Running'  WITH SECURITY_ENFORCED];
            
     if(!leadItems.isEmpty()){

        for(vlocity_cmt__OrchestrationItem__c itemLead: leadItems){

            fulfilmentRequestLineId.add(itemLead.vlocity_cmt__FulfilmentRequestLineId__c);
           
        }
       
        if(!fulfilmentRequestLineId.isEmpty()){
            System.debug('I am in 2');
            List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineLeadResource =[Select Id,Name,vlocity_cmt__JSONAttribute__c  from vlocity_cmt__FulfilmentRequestLine__c where Id =:fulfilmentRequestLineId WITH SECURITY_ENFORCED];
            System.debug('fulfilmentRequestLineLeadResource'+fulfilmentRequestLineLeadResource);
            if(!fulfilmentRequestLineLeadResource.isEmpty()){

                for(vlocity_cmt__FulfilmentRequestLine__c frlLead: fulfilmentRequestLineLeadResource){

                    System.debug('I xyz '+(String)ftr_CpqHelper.getJSONAttributeValue(frlLead.vlocity_cmt__JSONAttribute__c, 'ATTR_DID_LOC'));
                     if(didForLead == (String)ftr_CpqHelper.getJSONAttributeValue(frlLead.vlocity_cmt__JSONAttribute__c, 'ATTR_DID_LOC')){
                       System.debug('I am in ');
                        frlLead.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frlLead.vlocity_cmt__JSONAttribute__c, '{}', attrValsLead);
                        frlsToUpdateMap.put(frlLead.Id,frlLead);
                    }
                }
            }
        }

     }
          return frlsToUpdateMap;
    }
}