global with sharing class ftr_OrderManagementService implements vlocity_cmt.VlocityOpenInterface { 

    private static final String COMPLETE_ORDER_METHOD_NAME = 'completeOrder';
    private static final String FLAG_ORDER_FOR_ASSET_METHOD_NAME = 'flagOrderForAssetization';

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        ftr_Logger.writeInfo('Enter ftr_OrderManagementService.*****' + methodName);
        try {

            if (methodName == COMPLETE_ORDER_METHOD_NAME) {                                         
               completeOrder(methodName,inputMap,outputMap);
            } else if (methodName == FLAG_ORDER_FOR_ASSET_METHOD_NAME) {                                         
                flagOrderForAssetization(methodName,inputMap,outputMap);
            }

        } catch (Exception ex) { 
            outputMap.put('isSuccess', false);
            outputMap.put('errorMessage', ex.getMessage());

            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_OrderManagementService.' + methodName);
        }
        
        return true;
    }

    global Boolean flagOrderForAssetization(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap) {
        if(inputMap.get('contextId') == null) {
            outputMap.put('error', methodName+': '+'Null orderId');
            return false;
        }
        Id orderId = (Id)inputMap.get('contextId');
        Order o = [SELECT Id, Products__c FROM Order WHERE Id=:orderId];
        o.ftr_AssetizeOrder__c = 'True';

        // if the order does not contain EIA or EVPL (Products with OM Enabled) then we can set it to complete, 
        // else let the Orchestration Item update the Stage to complete 
        if (!o.Products__c.contains('EIA') && !o.Products__c.contains('EVPL')) {
            o.Order_Stage__c = 'Complete';
        }
        update o;

        //Query Ordet get Orchestration Plan and Update the Wait to Assetize=Complete.later we need to refine this rule
        Order orderInput = [SELECT Id, vlocity_cmt__OrchestrationPlanId__c, Order_Stage__c, vlocity_cmt__OrderStatus__c FROM Order WHERE Id=: orderId];
        System.debug('OrchestrationPlanID-->'+orderInput.vlocity_cmt__OrchestrationPlanId__c);
        vlocity_cmt__OrchestrationItem__c item = [SELECT Id, Name FROM vlocity_cmt__OrchestrationItem__c WHERE vlocity_cmt__OrchestrationPlanId__c =: orderInput.vlocity_cmt__OrchestrationPlanId__c AND Name='Wait To Assetize'
                                                         and vlocity_cmt__State__c = 'Running'];
        if (item != null) { 
        item.vlocity_cmt__State__c = 'Completed';
        update item;
    }
        return true;
    }


    global Boolean completeOrder(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap){
        System.debug('inputMap..'+ inputMap);
        
        if(inputMap.get('contextId') == null) {
            outputMap.put('error', methodName+': '+'Null orderId');
            return false;
        }
        
        Id orderId = (Id)inputMap.get('contextId');
        
        System.debug('orderId ..'+ orderId);
        
        // query Order to get Plan
        Order orderInput = [SELECT Id, vlocity_cmt__OrchestrationPlanId__c, Order_Stage__c, vlocity_cmt__OrderStatus__c FROM Order WHERE Id=: orderId];
        System.debug('orderInput..'+orderInput);
        //get all the Orchestration Item of the plan with FinalOrderCompletion in Running state
        List <vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__State__c, vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__OrchestrationPlanId__c
                                                          FROM vlocity_cmt__OrchestrationItem__c
                                                          WHERE vlocity_cmt__State__c = 'Running'                                                         
                                                          AND vlocity_cmt__OrchestrationPlanId__c =: orderInput.vlocity_cmt__OrchestrationPlanId__c
                                                          AND vlocity_cmt__OrchestrationItemDefinitionId__r.Name = 'FinalOrderCompletion'];
        System.debug('items..'+ items.size()+ items);
        
        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();

        if(items.size() > 0) {
            for(vlocity_cmt__OrchestrationItem__c item : items){
                System.debug('item in for loop of execute..'+item.Id);
                String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                System.debug('jsonAttribute inside for..'+ jsonAttribute);
                
                vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                      vlocity_cmt__JSONAttribute__c = jsonAttribute);
                
                frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttribute(frl.vlocity_cmt__JSONAttribute__c, '{}', 'ATTR_M6_IsOrderCompleted','True');
                frlsToUpdateMap.put(frl.Id,frl);
                System.debug('frlsToUpdateMap..'+ frlsToUpdateMap);
            }
        }
        
        if(frlsToUpdateMap.values().size()>0){
            try{
                List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                            System.debug('ftr_OrderManagementService: Error while updating ATTR_M6_IsOrderCompleted: '+ err.getStatusCode() + ' ' + err.getMessage());
                        }
                        outputMap.put('isSuccess', false);
                    }
                }
            } catch(Exception e) {
                System.debug('Exception in ftr_OrderManagementService..'+ e.getMessage());
                outputMap.put('isSuccess', false);
                return false;
            }
        }
        // below code needs to be removed after vlocity upgrade.
        // start
        orderInput.Order_Stage__c = 'Complete';
        orderInput.vlocity_cmt__OrderStatus__c = 'Complete';
        update orderInput;
        // end
        outputMap.put('isSuccess', true);
        return true;
    }


}