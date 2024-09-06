global with sharing class ftr_DIDOrderSubmission implements vlocity_cmt.VlocityOpenInterface {
 
    public static final string PRODUCTDPIDIDCODE  = 'DID_DPI_MDN_RFS_0010';
    public static final string PRODUCTDPIDIDLEADCODE  = 'DID_DPI_LEAD_ORDER_RFS_0010';

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
       
        Map<string,Object> resultMap= new Map<String,Object>();
        if (methodName == 'saveDIDForSubmission') {
          resultMap = saveDIDForSubmission(inputMap, outputMap);
        }

        outputMap.put('result', resultMap);
         
        return true;
            
    }
    
    
    public Map<String, Object> saveDIDForSubmission(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        ftr_Logger.writeInfo('Enter ftr_DIDOrderSubmission.saveDIDForSubmission-->');
        Map<string,Object> resultMap= new Map<String,Object>();
        String jsonAttribute =''; 
        String didLocationId ='';
        String dueDateAttr='';
        String warningCode='';
        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
        
        try { 

            String orderId =  (String) inputMap.get('ContextId');
            Order orderInput = [SELECT Id, vlocity_cmt__OrchestrationPlanId__c, Order_Stage__c, vlocity_cmt__OrderStatus__c FROM Order WHERE Id=: orderId];
            Set<Id> fulfilmentRequestIds = new Set<Id>();
           
            List<vlocity_cmt__FulfilmentRequest__c> fulfilmentRequest = [Select Id,Name from vlocity_cmt__FulfilmentRequest__c where vlocity_cmt__orchestrationPlanId__c=: orderInput.vlocity_cmt__OrchestrationPlanId__c];
            System.debug('fulfilmentRequest: '+ fulfilmentRequest);

            if(!fulfilmentRequest.isEmpty()){

                for(vlocity_cmt__FulfilmentRequest__c frl:fulfilmentRequest){
                    fulfilmentRequestIds.add(frl.Id);
                }
            }

            List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineS =[Select Id,Name,vlocity_cmt__JSONAttribute__c  from vlocity_cmt__FulfilmentRequestLine__c where vlocity_cmt__FulfilmentRequestID__c IN : fulfilmentRequestIds And (vlocity_cmt__Product2Id__r.productCode =: PRODUCTDPIDIDCODE or vlocity_cmt__Product2Id__r.productCode =: PRODUCTDPIDIDLEADCODE) ];

            System.debug('orderId: '+ orderId);
            System.debug('fulfilmentRequestLineS: '+ fulfilmentRequestLineS);

            list<Object> serviceAccounts =  (list<Object>) inputMap.get('ServiceAccounts');
            list<ftr_DID_Location_Details__c> ItemToUpdate = new list<ftr_DID_Location_Details__c>();
            list<vlocity_cmt__FulfilmentRequestLine__c> FLIToUpdate = new list<vlocity_cmt__FulfilmentRequestLine__c>();
            list<Object> lstUpdate = new list<Object>();
            Map<String,String> mappingDueDate = new Map<String,String>();       

        
            for(Object sAcc : serviceAccounts) {

               Map<String, Object> sAccMap = (Map<String, Object>)sAcc;
               list<Object> didLocations =  (list<Object>) sAccMap.get('DIDLocations');
               lstUpdate.addAll(didLocations);

            } 

            System.debug('lstUpdate: '+ lstUpdate);

            for(Object item : lstUpdate) {

                Map<String, Object> itemMap = (Map<String, Object>)item;
                Boolean isSubmitted = (Boolean) itemMap.get('isSubmitted__c');
                Boolean isValidated = (Boolean) itemMap.get('isDIDNumberValidated__c');
                
                if(itemMap.get('DueDate__c') != null && itemMap.get('DueDate__c')!= '' && isSubmitted != true)
                {
                    System.debug('itemMap: '+ itemMap);
                    String dueDateStr = (String) itemMap.get('DueDate__c');
                    mappingDueDate.put((String)itemMap.get('Id'), dueDateStr);
                }
            } 

            Map<String,Integer> locationDIDMap = new Map<String,Integer>();
            Integer i =0;
            for(vlocity_cmt__FulfilmentRequestLine__c frLine: fulfilmentRequestLineS){
                
                ftr_DID_Location_Details__c didLocation = new ftr_DID_Location_Details__c();
                vlocity_cmt__FulfilmentRequestLine__c fullLR = new vlocity_cmt__FulfilmentRequestLine__c();

                jsonAttribute = frLine.vlocity_cmt__JSONAttribute__c;
                if(jsonAttribute != null){
                    didLocationId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_DID_LOC');
                    dueDateAttr = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_DueDate');
                    warningCode = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_WarningCode');

                    System.debug('mappingDueDate: '+ mappingDueDate);
                    System.debug('didLocationId: '+ didLocationId);
                    System.debug('dueDateAttr: '+ dueDateAttr);
                    System.debug('warningCode: '+ warningCode);

                    
                    if(didLocationId != '' && mappingDueDate.get(didLocationId) != null  ){
                        
                        dueDateAttr = (String) mappingDueDate.get(didLocationId);
                        warningCode = dueDateAttr;

                        System.debug('frLine.Id: '+ frLine.Id);
                        System.debug('frLine: '+ frLine);
                        System.debug('dueDateAttr: '+ dueDateAttr);
                        
                        Map<String, Object> attrVals = new Map<String, Object>{
                            'ATTR_DueDate' => dueDateAttr
                        };

                        frLine.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frLine.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                        update frLine;
                        frlsToUpdateMap.put(frLine.Id,frLine);

                        if(locationDIDMap.get(didLocationId) == null){
                            Date dueDate = Date.valueOf(dueDateAttr);
                            didLocation.Id = (Id) didLocationId;
                            didLocation.DueDate__c = dueDate;
                            didLocation.isSubmitted__c = true;
                            didLocation.isDIDNumberValidated__c = true;
                            locationDIDMap.put(didLocation.Id, i++);
                            ItemToUpdate.add(didLocation);
                        }


                        // fullLR = frLine;
                        // fullLR.vlocity_cmt__JSONAttribute__c = '';
                        // FLIToUpdate.add(fullLR);

                    }
                }
            }
    
            System.debug('frlsToUpdateMap: '+ frlsToUpdateMap);
            System.debug('ItemToUpdate: '+ ItemToUpdate);
    
            if(frlsToUpdateMap.values().size()>0){
                try{
                    List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                    
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            for (Database.Error err : result.getErrors()){
                            System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                            }
                        } else {
                            Update ItemToUpdate;
                            resultMap.put('ItemToUpdate', ItemToUpdate );

                        }
                    }
                } catch(Exception e) {
                    System.debug('Exception in Subscriber..'+ e.getMessage());
                
                }
            }



        } catch (Exception ex) {
            ftr_Logger.write(ex);
            resultMap.put('isSuccess', false);
            resultMap.put('errorMessage', ex.getMessage());
        } finally {
            ftr_Logger.writeInfo('ExiT ftr_DIDOrderSubmission.saveDIDForSubmission');            
        }
        
         return  resultMap;   
        
        
    }
            
}