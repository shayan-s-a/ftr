@RestResource(urlMapping='/DIDBulkOrders/*')
global class DIDNumberBulkWebservice {
    
    @HttpPost
    global  static DIDNumberBulkWebserviceResponse didNumberBulkOrder(){
        List<String> lstFailedDidNumbers = new List<String>();
        List<String> lstSuccessDidNumbers = new List<String>();
        List<ftr_DID_Number_Details__c> lstToUpdateNumbers = new List<ftr_DID_Number_Details__c>(); 
        DIDNumberBulkWebserviceResponse objResponse = new DIDNumberBulkWebserviceResponse();
        Map<String, Object> customerAttributes = new Map<String, Object>();
        ftr_DID_Number_Details__c firstNumDetails;
        RestRequest req = RestContext.request;
        System.debug('req ::: '+req);
        String JsonBody = req.requestBody.toString();
        System.debug('JsonBody ::: '+JsonBody);
        if(!String.isBlank(JsonBody)){
            
            
            Map<String, Object> bulkRequest = (Map<String, Object>)Json.deserializeUntyped(JsonBody);
            if(!bulkRequest.isEmpty()){
                
                Map<String, Object> bulkRequestBody = (Map<String, Object>)bulkRequest.get('body');
                System.debug('bulkRequestBody ::: '+bulkRequestBody);

                String clientTransactionId = (String) bulkRequestBody.get('clientTransactionId');
				System.debug('clientTransactionId ::: '+ clientTransactionId);
				System.debug('clientTransactionId ::: '+ clientTransactionId.split('\\.'));
                List<String> splitedString = clientTransactionId.split('\\.');
                String OrderNumber = splitedString[0];
                
                if(!bulkRequestBody.isEmpty()){
                    List<Object> orderList = (List<Object>)bulkRequestBody.get('orders');
                    System.debug('orderList ::: '+orderList);
                    if(!orderList.isEmpty()){
                        for (Object obj : orderList) {
                            customerAttributes = (Map<String, Object>)obj;
                            //System.debug('========> '+customerAttributes.get('environmentCode'));     
                            if(customerAttributes.get('status') == 'SUCCESS')
                            {
                                lstSuccessDidNumbers.Add((String)customerAttributes.get('workingTelephoneNumber'));   
                            }
                            else if(customerAttributes.get('status') != 'SUCCESS')
                            {
                                lstFailedDidNumbers.Add((String)customerAttributes.get('workingTelephoneNumber'));   
                            }
                        } 
                        // Updating did numbers records that are processed 
                        // 
                        for(ftr_DID_Number_Details__c didnum : [Select Id, IsProcessed__c,DID_Number__c From ftr_DID_Number_Details__c Where DID_Number__c IN: lstSuccessDidNumbers])
                        {
                            didnum.IsProcessed__c = true;
                            didnum.DID_Status__c = 'Success';
                            lstToUpdateNumbers.Add(didnum);
                        }
                        
                        if(lstFailedDidNumbers.size() > 0) {
                            for(ftr_DID_Number_Details__c didnum : [Select Id, IsProcessed__c,DID_Number__c From ftr_DID_Number_Details__c Where DID_Number__c IN: lstFailedDidNumbers]) {
                                didnum.IsProcessed__c = true;
                                didnum.DID_Status__c = 'Failed';
                                lstToUpdateNumbers.Add(didnum);
                            }
                        }
                        
                        if(lstToUpdateNumbers.size() > 0 && lstToUpdateNumbers != null) {
                            update lstToUpdateNumbers;
                        }
                        
                        objResponse.Status  = 'Success';  
                        objResponse.StatusCode  = 'VOM-200';  
                        objResponse.Message ='DPI Order Events Processed Successfully';
                        
                        // Creating Task for the failed did numbers 
                        // Get SFOrderId by OrderNumber
                        if(!lstFailedDidNumbers.isEmpty()){

                            System.debug('OrderNumber' + OrderNumber);
                            Id orderId = [SELECT Id, OrderNumber FROM Order WHERE OrderNumber = :OrderNumber].Id;
                            System.debug('### orderId: ' + orderId);
                            Map<String,Object> createTaskInputMap =new Map<String,Object>();
                            
                            createTaskInputMap.put('Description','Failed Did numbers : ' + lstFailedDidNumbers);
                            createTaskInputMap.put('Subject','DID Numbers Processing Exception');
                            createTaskInputMap.put('Priority','High');
                            createTaskInputMap.put('WhatId', orderId);
                            System.debug('###createTaskInputMap: ' + createTaskInputMap);
                            ftr_OrderManagementHelper.CreateTask(createTaskInputMap);
                            System.debug('###task created');
                        }
                        

                        if(!lstSuccessDidNumbers.isEmpty()){
                             firstNumDetails = [SELECT Id, IsProcessed__c, DIDLocationDetailsId__c,Ucf_Install_Type__c , DIDNumberInfo__c,DID_Number__c FROM 
                                                ftr_DID_Number_Details__c WHERE DID_Number__c = :lstSuccessDidNumbers[0] LIMIT 1];
                            System.debug('### firstNumDetails: ' + firstNumDetails);
                        }else if(!lstFailedDidNumbers.isEmpty()){
                            firstNumDetails = [SELECT Id, IsProcessed__c, DIDLocationDetailsId__c, DIDNumberInfo__c,DID_Number__c FROM ftr_DID_Number_Details__c WHERE DID_Number__c = :lstFailedDidNumbers[0] LIMIT 1];
                            System.debug('### firstNumDetails: ' + firstNumDetails);
                        }else{
                            firstNumDetails = [SELECT Id, IsProcessed__c, DIDLocationDetailsId__c, DIDNumberInfo__c,DID_Number__c FROM ftr_DID_Number_Details__c WHERE DID_Number__c = :lstFailedDidNumbers[0] LIMIT 1];

                        }
                        
                        // Get all numbers of locations 
                        // 
                        if(firstNumDetails.Ucf_Install_Type__c !=null){
                            
                            List<ftr_DID_Number_Details__c> listDidNumberDetails = [SELECT Id, IsProcessed__c, DIDLocationDetailsId__c, 
                                                                                DIDNumberInfo__c, DID_Status__c,DID_Number__c 
                                                                                FROM ftr_DID_Number_Details__c 
                                                                                WHERE isDIDLead__c != true AND MDN_Checkbox__c != true 
                                                                                AND DID_Number__c =: firstNumDetails.DID_Number__c
                                                                                ];
                            
                            if(!listDidNumberDetails.isEmpty()) {
                             System.debug('### listDidNumberDetails Check IN');
                            processIsBillingStatus(JsonBody);
                        } else {
                            System.debug('### No pending records in this queue');
                        }
                            
                        }
                        else{
                            
                        
                        List<ftr_DID_Number_Details__c> listDidNumberDetails = [SELECT Id, IsProcessed__c, DIDLocationDetailsId__c, 
                                                                                DIDNumberInfo__c, DID_Status__c,DID_Number__c 
                                                                                FROM ftr_DID_Number_Details__c 
                                                                                WHERE isDIDLead__c != true AND MDN_Checkbox__c != true 
                                                                                AND DIDLocationDetailsId__c = :firstNumDetails.DIDLocationDetailsId__c 
                                                                                AND DIDNumberInfo__c = :firstNumDetails.DIDNumberInfo__c AND 
                                                                                DID_Status__c = null];

                        System.debug('### listDidNumberDetails: ' + listDidNumberDetails);

                        System.debug('### listDidNumberDetails.size(): ' + listDidNumberDetails.size());
                        if(!(listDidNumberDetails.size() > 0)) {
                             System.debug('### listDidNumberDetails Check IN');
                            processIsBillingStatus(JsonBody);
                        } else {
                            System.debug('### No pending records in this queue');
                        }
                       }
                    }
                    else {
                        objResponse.Status  = 'Failed';  
                        objResponse.Message = 'There Is No Order To Update';
                        objResponse.StatusCode  = '217';
                        
                    }
                }
                else{
                    objResponse.Status  = 'Failed';  
                    objResponse.Message = 'Error';
                    objResponse.StatusCode  = '500';
                }
            }
            else{
                objResponse.Status  = 'Failed';  
                objResponse.Message = 'Error';
                objResponse.StatusCode  = '500';
            }
            
        }
        return objResponse;
    }

    @future
    global static void processIsBillingStatus(String JsonBody) {
        Map<String, Object> bulkRequest = (Map<String, Object>)Json.deserializeUntyped(JsonBody);
        Map<String, Object> bulkRequestBody = (Map<String, Object>)bulkRequest.get('body');
        System.debug('### bulkRequestBody ::: '+bulkRequestBody);

        String clientTransactionId = (String) bulkRequestBody.get('clientTransactionId');
        List<String> splitedString = clientTransactionId.split('\\.');
        String OrderNumber = splitedString[0];

        System.debug('### OrderNumber: ' + OrderNumber);

        Map<String,Object> objectmap = new Map<String,Object>();

        objectmap.put('OrderNumber', OrderNumber);
        
        System.debug('### objectmap: ' + objectmap);
        // for(ftr_DPIOrderStatusEvent.orders childorder : obj.orders){
        //     if(childorder.orderNumber != ''){
        //         objectmap.put(childorder.orderNumber,childorder);
        //     }
        // }  
        
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_DPIStatusUpdateSubscriber stat = new ftr_DPIStatusUpdateSubscriber();
        System.debug('### objectmap: ' + objectmap);
        Boolean result = stat.invokeMethod('executeDIDBulkOrderStatusUpdate', objectmap, outputMap, options); 
        System.debug('### result:' + result);
    }
    
    global class DIDNumberBulkWebserviceResponse
    {
        global String Status;
        global String Message;
        global String StatusCode;
        
    }  
    
    global class RequestWrapper{
        
        Map<String,Object> header = new  Map<String,Object> ();
        
    }
}