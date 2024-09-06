global class XOMAutoTask_UpdateVlocityOrderStatus implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask{
    global void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items) {
        System.debug('Enter XOMAutoTask_UpdateVlocityOrderStatus.executeBatch');
        try {
        System.debug('XOMAutoTask_UpdateVlocityOrderStatus:items.size()-->'+items.size());
        Set<Id> itemIds = new Set<Id>();
        if(items.size() > 0) {
           
            for(vlocity_cmt__OrchestrationItem__c item : items) {
                System.debug('XOMAutoTask:for loop-->'+JSON.serialize(item));
                itemIds.add(item.Id);              
            }
             vlocity_cmt__OrchestrationItem__c  orchItem = [SELECT Id,Name,vlocity_cmt__OrderItemId__r.Order.Id,  vlocity_cmt__OrchestrationPlanId__c,vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c
            FROM vlocity_cmt__OrchestrationItem__c where Id IN: itemIds LIMIT 1];
           
           // String OrderNumber=orchItem.vlocity_cmt__OrderItemId__r.Order.Id;
            String OrderNumber=orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c;
            System.debug('OrderNumber-->'+OrderNumber);
            
            Order OrderToUpdate;
            OrderToUpdate =[SELECT Order_Stage__c,ContractId, vlocity_cmt__OrderStatus__c FROM Order WHERE Id=:OrderNumber LIMIT 1];
            // Update the Order Stage.
            OrderToUpdate.Order_Stage__c = 'Complete';
            OrderToUpdate.vlocity_cmt__OrderStatus__c = 'Complete';
            // Make the update call.
            update OrderToUpdate;
            if(OrderToUpdate != null && OrderToUpdate.ContractId != null)
            {
               Contract  conObject = [SELECT id,StatusCode,vlocity_cmt__quoteid__c,agreement_type__c,product_type__c,products__c,scheduleid__c,
                                        shippingstreet,billingstreet,status,recordtypeid,vlocity_cmt__pricelistid__c,accountid,
                                        billingcity,billingcountry,billingpostalcode,billingstate,name,shippingcity,shippingcountry,
                                        shippingpostalcode,shippingstate,recordtype.developername FROM Contract WHERE id =: OrderToUpdate.ContractId limit 1];
                
            conObject.status = 'Activated';
              update conObject;
              System.debug('XOMAutoTask_UpdateVlocityOrderStatus:Order_Stage__c-->'+conObject.status);  
            }
            System.debug('XOMAutoTask_UpdateVlocityOrderStatus:Order_Stage__c-->'+OrderToUpdate.Order_Stage__c);
            System.debug('XOMAutoTask_UpdateVlocityOrderStatus:vlocity_cmt__OrderStatus__c-->'+OrderToUpdate.vlocity_cmt__OrderStatus__c);
        }
        }catch (Exception ex) { ftr_Logger.write(ex);
        } finally {
            ftr_Logger.writeInfo('Exit XOMAutoTask_UpdateVlocityOrderStatus.executeBatch');
        }
    }
}