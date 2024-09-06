global without sharing class ftr_UCFSubmitBulkGroupOrderInterface extends ftr_DPIUCFSystemInterface {

    
       global override String getOrchestrationTaskName() {
        System.debug('Task Name returned-->'+TaskName_UCFSubmitBulkGroupOrder); 
        return TaskName_UCFSubmitBulkGroupOrder; 
    }
     
    global override Object createDPIRequestType(String url, String path, Map<String, Object> input) {

         System.debug(':::: input JSON'+JSON.serialize(input));
         
         DIDTypeSettings__c DPISettings = DIDTypeSettings__c.getInstance();
         Map<String,Object> requestMap = new  Map<String,Object>();
         List<String> telePhoneNumbers = new List<String>();
         List<String> phones = new List<String>();
         String ItemId = (String)input.get('ItemId');
         String didNumberType = (String)input.get('DIDNumberType'); 
         String orderNumber = (String)input.get('OrderNumber');
         String LeadOrderId = (String)input.get('LeadOrderId');
         String action = (String)input.get('Action');
         String Environment = (String)input.get('Environment');
         String serviceType = (String)input.get('serviceType');
         String correlationId = (String)input.get('CorrelationId');
         String leadDIDNumber = correlationId.substringAfterLast('.');
         String didNumber;
         String clientTransactionId;
         Map<String, Object> telephoneNumberUsage = (Map<String,Object>)input.get('telephoneNumberUsage');
         
         List<Map<String, Object>> telephoneNumberRangeList = new List<Map<String, Object>>();
         Map<String, Object> telephoneNumberRangeItem = new Map<String, Object>();

         System.debug(':::: telephoneNumberUsage 1'+telephoneNumberUsage);
         Integer quantity;
       
          List<OrderItem> orderItem = [Select Id,UCF_DID_Order_Items__c,UCF_DID_Numbers__c from OrderItem where Id=:ItemId];
         
          if(!orderItem.isEmpty()){
                       
                   for(OrderItem items: orderItem){
                           phones = items.UCF_DID_Numbers__c.split(',');
                       }
                   if(!phones.isEmpty()){
                        
                        for(String didNumbers: phones){
                                
                               if(didNumbers != leadDIDNumber){
                                        telePhoneNumbers.add(didNumbers);                            
                                 }
                        }
                    }

                  quantity = phones.size() - 1;
                
                didNumber = telePhoneNumbers[0];
               
                telephoneNumberRangeList.add(telephoneNumberRangeItem);
                

                clientTransactionId = orderNumber+'.'+didNumber;
               
                 if(!telePhoneNumbers.isEmpty()){
                    telephoneNumberUsage.put('telephoneNumbers',telePhoneNumbers);
                 }

                System.debug(':::: telephoneNumberUsage 2'+telephoneNumberUsage);
                telephoneNumberUsage.put('serviceType',serviceType);
                requestMap.put('telephoneNumberUsage',telephoneNumberUsage);
                requestMap.put('leadOrderNumber',LeadOrderId);
                requestMap.put('quantity',quantity);
                requestMap.put('action',action);
                requestMap.put('environmentCode',Environment);
                requestMap.put('clientTransactionId',clientTransactionId);
 
                

                System.debug(':::: requestMap'+requestMap);
                return requestMap;
    
          }
         
        
  
         return null;
  }
    
    global override Map<String, Object> processDPIResponseType(String url, String path, Object respType) {
         
        System.debug(':::: respType 1'+respType);
        String JsonBody = respType.toString();

        Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(JsonBody);
        Map<String,Object> bulkResponseMap = new Map<String,Object>();
        
        System.debug(':::: responseMap'+responseMap);
        if(responseMap.get('success') == true){
           
             bulkResponseMap.put('Message',responseMap.get('messages'));
             bulkResponseMap.put('success',responseMap.get('success'));
        }
        else if(responseMap.get('success') == false) {
            
            bulkResponseMap.put('errorMessage', responseMap.get('messages'));
            bulkResponseMap.put('success',responseMap.get('success'));
            
        }
         return bulkResponseMap;

  }
        
}