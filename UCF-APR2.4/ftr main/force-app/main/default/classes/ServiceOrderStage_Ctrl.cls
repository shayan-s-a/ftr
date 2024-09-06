global without sharing class ServiceOrderStage_Ctrl {
    
    webservice static void updateSOStage(Id soId,String orderNum){
        updateOrderStage(soId,orderNum,true);
    }
    @AuraEnabled
    public static Service_Order__c updateOrderStage(Id soId,String orderNum,Boolean isCalledFromQuickAction){
        system.debug('soId :: '+soId);
         system.debug('orderNum :: '+orderNum);
        HttpResponse response = ServiceOrderStageVlocityM6.retrieveM6SoStage(orderNum);//3369393
        system.debug('response :: '+response.getBody());
        
        ServiceOrderResponse sor = parseResponse(response);
        //if(String.isBlank(sor.items[0].order_stage)){
            //throw new ServiceOrderStage_Exception(JSON.serialize(new ErrorMessage('UNKNOWN ERROR','We did not get any Orger Stage For Order Number '+orderNum)));
        //}
        if(sor.items == null || sor.items.size() == 0){
            return null;
        }
        try{
            String dateInISOFormate = String.isNotBlank(sor.items[0].dd_task_date)?'"'+sor.items[0].dd_task_date+'"':null;
            Integer offset = UserInfo.getTimezone().getOffset(System.now()) * (-1);
            
            //String orderStage = String.isBlank(sor.items[0].order_stage) ? '':sor.items[0].order_stage;
            String orderStage = '';

            if(String.isBlank(sor.items[0].order_stage) && !String.isBlank(sor.items[0].order_status)) {
                if(sor.items[0].order_status == 'Complete') {
                    orderStage = 'Completed';
                } else {
                    orderStage = '';
                }
            } else if(String.isBlank(sor.items[0].order_stage) && String.isBlank(sor.items[0].order_status)) {
                orderStage = '';
            } else {
                orderStage = sor.items[0].order_stage;
            }

            Service_Order__c so = new Service_Order__c();
            so.Id = soId;
            so.Service_Order_Stage__c = orderStage;
            so.M6_Order_Notes__c = sor.items[0].last_cust_note;
            so.M6_dd_task_date__c = dateInISOFormate!=null?DateTime.valueOf(JSON.deserialize(dateInISOFormate, Datetime.class)).addSeconds(offset/1000):null;
            so.Priloc_Address__c=sor.items[0].priloc_address;
            so.Secloc_Address__c=sor.items[0].secloc_address;
			so.Item_Spec_Id__c = String.valueOf(sor.items[0].item_spec_id);
            if(so.Item_Spec_Id__c != null || so.Item_Spec_Id__c != 'null' || so.Item_Spec_Id__c != ''){
                	so.Is_Created_By_Velocity__c = false;
            }
            if(isCalledFromQuickAction){
                if(!String.isBlank(orderStage)) {
                    update so;
                } else {
                    return so;
                }
            }else{
                return so;
            }
        }catch(Exception ee){
            if(ee.getMessage().contains('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST'))
                throw new ServiceOrderStage_Exception(JSON.serialize(new ErrorMessage('DML ERROR','Please add '+'\''+sor.items[0].order_stage+'\''+' Stage value to Service Order Stage')));
            else
                throw new ServiceOrderStage_Exception(JSON.serialize(new ErrorMessage('DML ERROR',ee.getMessage())));
        }
        return null;
    }
    public static ServiceOrderResponse parseResponse(HttpResponse response){
        if (response.getStatusCode() == 200) return new ServiceOrderResponse().parse(response.getBody());
        
        else throw new ServiceOrderStage_Exception(JSON.serialize(new ErrorMessage('Bad Request','Something went wrong . Status code is '+response.getStatusCode())));
        
    }
    
    public class ServiceOrderStage_Exception extends Exception {}
    
    public class ErrorMessage{
        @AuraEnabled public String cause;
        @AuraEnabled public String errorMessage;
        public ErrorMessage(String cause,String errorMessage){
            this.cause = cause;
            this.errorMessage = errorMessage;
        }
    }
    
}