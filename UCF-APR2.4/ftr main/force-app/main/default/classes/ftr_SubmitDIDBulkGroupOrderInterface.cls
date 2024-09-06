// Created By Aamir
global without sharing class ftr_SubmitDIDBulkGroupOrderInterface extends ftr_DPIBaseBillingSystemInterface {
  
    
    global override String getOrchestrationTaskName() {
        System.debug('Task Name returned-->'+TaskName_SubmitDIDBulkGroupOrder);
        return TaskName_SubmitDIDBulkGroupOrder;
    }

    global override Object createDPIRequestType(String url, String path, Map<String, Object> input) {

         System.debug(':::: input JSON'+JSON.serialize(input));
          
         Map<String,Object> requestMap = new  Map<String,Object>();
         List<String> telePhoneNumbers = new List<String>();
         String didLocation = (String)input.get('DIDLocation');
         String didNumberType = (String)input.get('DIDNumberType'); 
         String orderNumber = (String)input.get('OrderNumber');
         String LeadOrderId = (String)input.get('LeadOrderId');
         String action = (String)input.get('Action');
         String Environment = (String)input.get('Environment');
         String serviceType = (String)input.get('serviceType');
         String didNumber;
         String clientTransactionId;
         Map<String, Object> telephoneNumberUsage = (Map<String,Object>)input.get('telephoneNumberUsage');
         
         List<Map<String, Object>> telephoneNumberRangeList = new List<Map<String, Object>>();
         Map<String, Object> telephoneNumberRangeItem = new Map<String, Object>();

         System.debug(':::: telephoneNumberUsage 1'+telephoneNumberUsage);
         Integer quantity;
         
        

         if(didNumberType == 'New'){

            List<ftr_DID_Number_Details__c> didNumberBulkNewNumbers = [Select Id,Name,DIDNumberInfo__c,DID_Number__c,DIDLocationDetailsId__r.E911Type__c 
                                                                      from  ftr_DID_Number_Details__c where DIDNumberInfo__c ='New DID Range' 
                                                                      AND DIDLocationDetailsId__c =: DIDLocation AND MDN_Checkbox__c = false AND 
                                                                      isDIDLead__c = false ORDER BY DID_Number__c ASC];
           System.debug(' didNumberBulkNewNumbers.size() 1'+didNumberBulkNewNumbers.size());
            if(!didNumberBulkNewNumbers.isEmpty()){
                quantity = didNumberBulkNewNumbers.size();
                
                didNumber = didNumberBulkNewNumbers[0].DID_Number__c;
                telephoneNumberRangeItem.put('start', didNumber);
                telephoneNumberRangeItem.put('end', didNumberBulkNewNumbers[quantity - 1].DID_Number__c);
                telephoneNumberRangeList.add(telephoneNumberRangeItem);
                

                clientTransactionId = orderNumber+'.'+didNumber;
                for(ftr_DID_Number_Details__c didNumbers: didNumberBulkNewNumbers){
                    telePhoneNumbers.add(didNumbers.DID_Number__c);
                 }
                 if(!telePhoneNumbers.isEmpty()){
                    telephoneNumberUsage.put('telephoneNumbers',telePhoneNumbers);
                 }

                System.debug(':::: telephoneNumberUsage 2'+telephoneNumberUsage);
                telephoneNumberUsage.put('serviceType',serviceType);
               // telephoneNumberUsage.put('telephoneNumberRange', telephoneNumberRangeList);
                requestMap.put('telephoneNumberUsage',telephoneNumberUsage);
                requestMap.put('leadOrderNumber',LeadOrderId);
                requestMap.put('quantity',quantity);
                requestMap.put('action',action);
                requestMap.put('environmentCode',Environment);
                requestMap.put('clientTransactionId',clientTransactionId);
 
                

                System.debug(':::: requestMap'+requestMap);
                return requestMap;
            }
         }
         else if(didNumberType == 'PortIn'){
            List<ftr_DID_Number_Details__c> didNumberBulkPortInNumbers = [Select Id,Name,DIDNumberInfo__c,DID_Number__c,DIDLocationDetailsId__r.E911Type__c 
                                                                        from  ftr_DID_Number_Details__c where DIDNumberInfo__c ='Port-In' 
                                                                        AND DIDLocationDetailsId__c =: DIDLocation AND MDN_Checkbox__c = false AND 
                                                                        isDIDLead__c = false ORDER BY DID_Number__c ASC ];
            System.debug(' didNumberBulkNewNumbers.size() 1'+didNumberBulkPortInNumbers.size());
            if(!didNumberBulkPortInNumbers.isEmpty()){
            quantity = didNumberBulkPortInNumbers.size();
            
            didNumber = didNumberBulkPortInNumbers[0].DID_Number__c;
            telephoneNumberRangeItem.put('start', didNumber);
            telephoneNumberRangeItem.put('end', didNumberBulkPortInNumbers[quantity - 1].DID_Number__c);
            telephoneNumberRangeList.add(telephoneNumberRangeItem);
            clientTransactionId = orderNumber+'.'+didNumber;
            for(ftr_DID_Number_Details__c didNumbers: didNumberBulkPortInNumbers){
                telePhoneNumbers.add(didNumbers.DID_Number__c);
             }
             if(!telePhoneNumbers.isEmpty()){
                telephoneNumberUsage.put('telephoneNumbers',telePhoneNumbers);
             }
             System.debug(':::: telephoneNumberUsage 2'+telephoneNumberUsage);
             telephoneNumberUsage.put('serviceType',serviceType);
             //telephoneNumberUsage.put('telephoneNumberRange', telephoneNumberRangeList);
             requestMap.put('telephoneNumberUsage',telephoneNumberUsage);
             requestMap.put('leadOrderNumber',LeadOrderId);
             requestMap.put('quantity',quantity);
             requestMap.put('action',action);
             requestMap.put('environmentCode',Environment);
             requestMap.put('clientTransactionId',clientTransactionId);

             

             System.debug(':::: requestMap'+requestMap);
             return requestMap;
            }
         }

          
         return null;
  }

  global override Map<String, Object> processDPIResponseType(String url, String path, Object respType) {
         
        System.debug(':::: respType 1'+respType);
        String JsonBody = respType.toString();

        Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(JsonBody);
        Map<String,Object> bulkResponseMap = new Map<String,Object>();
        
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