global class XOMAutoTask_FulFillLeadBulkOrder implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask{

     global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {
        
         Set<Id> frlIds = new Set<Id>();
         String OrderNumber ='';
         String serviceAccountId ='';
         String controlNumber ='';
         String env = '';
         Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
   
            for (vlocity_cmt__OrchestrationItem__c item : items) {
                
                frlIds.add(item.vlocity_cmt__fulfilmentRequestLineId__c);
            }
            List<vlocity_cmt__FulfilmentRequestLine__c> frls = [SELECT Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber, vlocity_cmt__Product2Id__r.Name 
                                                                FROM vlocity_cmt__FulfilmentRequestLine__c
                                                                WHERE Id=:frlIds WITH SECURITY_ENFORCED];
        
            for(vlocity_cmt__FulfilmentRequestLine__c frl:frls){
               
                //frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttribute(frl.vlocity_cmt__JSONAttribute__c, '{}', 'Attr_WaitBulk','True');
               // frlsToUpdateMap.put(frl.Id,frl);
               OrderNumber = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'Attr_ReservationNumber');
               serviceAccountId = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'ATTR_SERV_ACCT');
            }
         
             if(!String.isBlank(OrderNumber) && !String.isBlank(serviceAccountId)){List<System_Order_Info__c> systemOrder = [Select Id,Environment__c, Control_Number__c, City_Abbreviation__c from System_Order_Info__c where Order__r.OrderNumber =:OrderNumber AND Service_Address__c =:serviceAccountId];if(!systemOrder.isEmpty()){for(System_Order_Info__c syOrder:systemOrder){controlNumber = syOrder.Control_Number__c;env = syOrder.Environment__c;}}if(!String.isBlank(controlNumber) && !String.isBlank(env)){Map<String, Object> attrVals = new Map<String, Object>{'ControlNumber' => controlNumber,'Environment' => env  };for(vlocity_cmt__FulfilmentRequestLine__c frl:frls){frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);frlsToUpdateMap.put(frl.Id,frl);
                       
                    }
                 }
             }
           
           if(frlsToUpdateMap.values().size()>0){try{List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);for (Database.SaveResult result : results) {if (!result.isSuccess()){for (Database.Error err : result.getErrors()){
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