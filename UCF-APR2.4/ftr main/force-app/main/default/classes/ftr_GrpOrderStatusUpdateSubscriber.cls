/**
 * @description       : 
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
global with sharing class ftr_GrpOrderStatusUpdateSubscriber implements vlocity_cmt.VlocityOpenInterface{
    
    //Constants
    
    public final static String TECH_PRODUCTCODE_DPI = 'ENT_ETH_DPI_CIRCUIT_BILLING';
    public final static String TECH_PRODUCTCODE_ELAN_DPI = 'ENT_ETH_ELAN_DPI';
    // *SIP Trunking thecnical products
    public final static String TECH_PRODUCTCODE_DPI_SIP_UNI = 'DPI_CIRCUIT_BILLING_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_DPI_SIP_TRUNKING = 'SIP_TRUNKING_DPI_BILLING_RES_SPEC_0010';
    
    public final static String ATT_Correlation_Id='CorrelationId';
    public final static String ATTR_REF_ID = 'ATTR_FRLRefId';
    public final static String EXECUTE_METHOD = 'execute';    
    public final static String INPUT_EVENT = 'events';
    public final static String INPUT_STATE = 'Completed';
    public final static String INPUT_STATE_RUNNING = 'Running';    
    public final static String INPUT_ITEM_M6_ORD_COMPLETION = 'Wait for M6Orders Completion';
    public final static String INPUT_ITEM_SIP_M6_ORD_COMPLETION = 'SIP Wait for M6Orders Completion';
    public final static String ATTR_IsSubmitOrderToDPI = 'ATTR_IsSubmitOrderToDPI';    
    public final static String ATTR_IsBTNOrderComplete = 'ATTR_IsBTNOrderComplete';
    public final static String ATTR_WorkingTelephoneNumber = 'WorkingTelephoneNumber';
    public final static String ATTR_BillingTelephoneNumber = 'BillingTelephoneNumber';
    public final static String TECH_M6_IsOrderCompleted = 'ATTR_M6_IsOrderCompleted';

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter ftr_GrpOrderStatusUpdateSubscriber.' + methodName);
        try {
            if (methodName == EXECUTE_METHOD) {
                return execute(methodName, inputMap, outputMap);
            }
            return true;
        } catch (Exception ex) {
            System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            return false;
        } finally {
            System.debug('Exit ftr_GrpOrderStatusUpdateSubscriber.' + methodName);
        }
    }
        
    public Boolean execute(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap) {
        System.debug('GrpOrderStatusUpdate:InputMap-->'+ inputMap);
        List<PublishGrpOrderStatusUpdate__e> evs = (List<PublishGrpOrderStatusUpdate__e>)inputMap.get(INPUT_EVENT);

        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
        Set<Id> orchPlanIds = new Set<Id>();
        Map<String,String> eventMap = new Map<String,String>();
        for (PublishGrpOrderStatusUpdate__e singleEvent : evs) {
            orchPlanIds.add(singleEvent.Plan_Id__c); 
            Map<String, Object> myAttrValsevs = ftr_CpqHelper.getJSONAttributeValues(singleEvent.JSONAttribute__c);          
           // String hostUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(singleEvent.JSONAttribute__c, 'ATTR_HostUNIRefId'); 
           // String remoteUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(singleEvent.JSONAttribute__c, 'ATTR_RemoteUNIRefId'); 
           // String environment = (String)ftr_CpqHelper.getJSONAttributeValue(singleEvent.JSONAttribute__c, 'Environment'); 

            String hostUNIRefId = (String)myAttrValsevs.get('ATTR_HostUNIRefId');
            String remoteUNIRefId = (String)myAttrValsevs.get('ATTR_RemoteUNIRefId');
            String environment = (String)myAttrValsevs.get('Environment');
            System.debug('GrpOrderStatusUpdate:singleEvent:environment-->'+environment );
            System.debug('GrpOrderStatusUpdate:singleEvent:remoteUNIRefId: '+remoteUNIRefId);
            System.debug('GrpOrderStatusUpdate:singleEvent:hostUNIRefId: '+hostUNIRefId);
            eventMap.put(hostUNIRefId,environment);
            eventMap.put(remoteUNIRefId,environment);         
        }
        System.debug('GrpOrderStatusUpdate:orderCompletionEvent-->'+eventMap);
        System.debug('GrpOrderStatusUpdate:orchPlanIds-->'+orchPlanIds);
        //get all the Orchestration Item of the plan with Running state
        List <vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, 
        vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c,
      
                         vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c
                                                          FROM vlocity_cmt__OrchestrationItem__c
                                                          WHERE vlocity_cmt__State__c =: INPUT_STATE_RUNNING
                                                          AND vlocity_cmt__OrchestrationPlanId__c IN: orchPlanIds
                                                          AND (vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: INPUT_ITEM_M6_ORD_COMPLETION OR vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: INPUT_ITEM_SIP_M6_ORD_COMPLETION)// TODO: to refer an externalId field which will not change
                                                          AND (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI_SIP_UNI OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI_SIP_TRUNKING OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_ELAN_DPI
                                                          )];
        
        for(vlocity_cmt__OrchestrationItem__c item : items){



            String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
            Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
            vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                  vlocity_cmt__JSONAttribute__c = jsonAttribute);
            
            String attrFRLRefId = (String)myAttrVals.get(ATTR_REF_ID);
            String isSubmitOrderToDPI = (String)myAttrVals.get(ATTR_IsSubmitOrderToDPI);
            String isHostToEVPL=(String)myAttrVals.get('HOST_TO_EVPL'); 
            String orderNumber=item.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c;
            System.debug('GrpOrderStatusUpdate:attrFRLRefId-->'+attrFRLRefId );
            System.debug(' GrpOrderStatusUpdate:isSubmitOrderToDPI: '+isSubmitOrderToDPI);
            System.debug('GrpOrderStatusUpdate:isHostToEVPL: '+isHostToEVPL);
            //String attrFRLRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_REF_ID);
            //String isSubmitOrderToDPI = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_IsSubmitOrderToDPI);
            //String isHostToEVPL=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'HOST_TO_EVPL'); 
            //String orderNumber=item.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c; 
                                   
           
           if ((isSubmitOrderToDPI.containsIgnoreCase('False') && eventMap.containsKey(attrFRLRefId)) || isSubmitOrderToDPI=='True'){            
            System.debug('GrpOrderStatusUpdate:Matching Host/Remote UNI Exists:attrFRLRefId-->'+ attrFRLRefId);    
           // String environment = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'Environment'); 
            //String billingTelephoneNumber=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_BillingTelephoneNumber);
            String environment = (String)myAttrVals.get('Environment');
            String billingTelephoneNumber = (String)myAttrVals.get(ATTR_BillingTelephoneNumber);

            System.debug('GrpOrderStatusUpdate:environment-->'+environment );
            System.debug('GrpOrderStatusUpdate:billingTelephoneNumber: '+billingTelephoneNumber);

            Map<String, Object> attrVals = new Map<String, Object>();
            if (!ftr_OrderManagementHelper.validTelephoneNumber(billingTelephoneNumber)){
                String orchplanId = item.vlocity_cmt__OrchestrationPlanId__c;
                Map<String,String> btnByEnvmtMap=new  Map<String,String>();
                Map<String,Object> orchPlanByEnvmtMap=ftr_OrderManagementHelper.getBTNbyEnvironment (orchplanId); 
              // System.debug('ftr_GrpOrderStatusUpdateSubscriber:getBillingTNByEnvironment orderNumber-->'+ orderNumber);              
                //Map<String,Object> orchPlanByEnvmtMap=ftr_OrderManagementHelper.getBillingTNByEnvironment (orderNumber);               
                Map<String,String> btnByEnvmtCurrentMap=new Map<String,String>();
                if (orchPlanByEnvmtMap!=null && !orchPlanByEnvmtMap.isEmpty())
                 {           
                    System.debug('ftr_GrpOrderStatusUpdateSubscriber:orchPlanByEnvmtMap size-->'+ orchPlanByEnvmtMap.size());           
                     btnByEnvmtCurrentMap = (Map<String,String>)orchPlanByEnvmtMap.get(environment); 
                    
                     if (btnByEnvmtCurrentMap!=null && !btnByEnvmtCurrentMap.isEmpty()){
                        System.debug('ftr_GrpOrderStatusUpdateSubscriber:btnByEnvmtCurrentMap size-->'+ btnByEnvmtCurrentMap.size());
                        if (ftr_OrderManagementHelper.validString(btnByEnvmtCurrentMap.get('billingTelephoneNumber'))){
                            btnByEnvmtMap.put(environment, btnByEnvmtCurrentMap.get('billingTelephoneNumber'));
                            System.debug('ftr_GrpOrderStatusUpdateSubscriber:btnByEnvmtCurrentMap size-->'+ btnByEnvmtCurrentMap.size());
                            System.debug('ftr_GrpOrderStatusUpdateSubscriber:btnByEnvmtCurrentMap get Env-->'+ environment);
                           
                      }              
                      
                     }                   
                  }
                
                if (ftr_OrderManagementHelper.validTelephoneNumber(btnByEnvmtMap.get(environment))){                
                    System.debug('GrpOrderStatusUpdate:getBTNbyEnvironment-->'+btnByEnvmtMap.get(environment));  
                    attrVals = new Map<String, Object>{
                        ATTR_IsSubmitOrderToDPI => 'true',ATTR_IsBTNOrderComplete=>'True',ATTR_BillingTelephoneNumber=>btnByEnvmtMap.get(environment)
                    };
                    
                    }else {
                   // String workingTelephoneNumber=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_WorkingTelephoneNumber);
                    String workingTelephoneNumber = (String)myAttrVals.get(ATTR_WorkingTelephoneNumber);
                    System.debug('ftr_GrpOrderStatusUpdateSubscriber:validTelephoneNumber workingTelephoneNumber-->'+ workingTelephoneNumber);
                    attrVals = new Map<String, Object>{
                        ATTR_IsSubmitOrderToDPI => 'true',ATTR_BillingTelephoneNumber=>workingTelephoneNumber,ATTR_IsBTNOrderComplete=>'True'
                        };
                        System.debug('ftr_GrpOrderStatusUpdateSubscriber:validTelephoneNumber 2 ATTR_BillingTelephoneNumber-->'+ ATTR_BillingTelephoneNumber);
                    }

            }else{
                System.debug('GrpOrderStatusUpdate:Remaining Group Order Exists:attrFRLRefId-->'+ attrFRLRefId);    
                attrVals = new Map<String, Object>{ATTR_IsSubmitOrderToDPI => 'true',ATTR_IsBTNOrderComplete=>'True'};
                 }
            frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
            frlsToUpdateMap.put(frl.Id,frl);
          }        
        }

        if(frlsToUpdateMap.values().size()>0){
            try{
                List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                        System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                        }
                    }
                }
            } catch(Exception e) {
                System.debug('Exception in Subscriber..'+ e.getMessage());
                return false;
            }
        }

        return true;
    }
    
}