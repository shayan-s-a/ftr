global class ftr_SiteSurveyController implements vlocity_cmt.VlocityOpenInterface {
    
      private static final String REQUEST_METHOD_POST = 'POST';
      private static final String AUTHORIZATION = 'Authorization';
      private static final String CONTENT_TYPE = 'Content-Type';
      private static final String API_KEY = 'apikey';
      private static final String API_CONFIG_SETTINGS = 'DPIAuthentication';
      @TestVisible private static Map<String, String> apiConfigMap=new Map<String,String>();
      @TestVisible private static IntegrationAPIConfig__mdt apiconfig;
      private static String requestInput;
      private static String OrderIdForSystemOrder;
      private static final string  invalidWTNErrMsg = 'WTN/BTN reservation Not Successfull';
    
    static{
        
        try{
            List<IntegrationAPIConfig__mdt> apiConfigs = [SELECT Timeout__c, ApiKey__c,Authorization_Header__c, CustomerOrderMgmt_URI__c, OrderStaging_URI__c,BulkNumber_URI__c FROM IntegrationAPIConfig__mdt WHERE DeveloperName=: API_CONFIG_SETTINGS LIMIT 1];
            
            
            //if ( !Test.isRunningTest() && (apiConfigs.isEmpty() || String.isBlank(apiConfigs[0].ApiKey__c) || apiConfigs[0].Timeout__c == null)) { throw new ftr_DPIBaseBillingSystemInterfaceException(ERR_NULL_INPUT); }
            
            apiconfig=apiConfigs[0];
            apiConfigMap.put('Timeout', String.valueOf(apiConfig.Timeout__c));
            apiConfigMap.put('ApiKey', apiConfig.ApiKey__c);
            apiConfigMap.put('AuthHeader', apiConfig.Authorization_Header__c);
            apiConfigMap.put('CustMgmtURI', apiConfig.CustomerOrderMgmt_URI__c);
            apiConfigMap.put('DPIOrderStageURI', apiConfig.OrderStaging_URI__c);
            apiConfigMap.put('BulkNumber', apiConfig.BulkNumber_URI__c);
            
        } catch (Exception ex){ ftr_Logger.write(ex); System.debug(ex.getMessage());
                              }
    }

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
     
        if (methodName == 'RetrieveCustomerFacilities') {
             String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
             retrieveCustomerFacilities(contextId);
        }
        /*
        else if(methodName == 'FindAvailablePhoneNubmers'){
             String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
           //  findAvailablePhoneNubmers(contextId);
        }else if(methodName == 'ReserveTelephonenubmers'){
             String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
            // ReserveTelephonenubmers(contextId);
        }else if(methodName == 'submitGroupOrderDI711Order'){
             String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
            // submitGroupOrderD1711(contextId);
        }
        */
        return false;   
    }
    
    public Boolean retrieveCustomerFacilities(String OrderId){
       
        
        Set<Id> serviceAccountId = new Set<Id>();
        Map<String, Object> output = new  Map<String,Object>(); 
        Map<String, Object> outputMetadata = new  Map<String,Object>(); 
        Object requestType;
        OrderIdForSystemOrder = OrderId; 
        List<OrderItem> orderItemList = [Select Id,vlocity_cmt__ServiceAccountId__c,vlocity_cmt__ServiceAccountId__r.Name from OrderItem where OrderId =:OrderId];
        for(OrderItem orderItemData: orderItemList){serviceAccountId.add(orderItemData.vlocity_cmt__ServiceAccountId__c);
        }
        if(!serviceAccountId.isEmpty()){
            
            List<Account> serviceAccountPremises = [Select Id,vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                                                    vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c from Account
                                                    where Id IN:serviceAccountId];
            System.debug('serviceAccountPremises:::'+serviceAccountPremises.size());
            if(!serviceAccountPremises.isEmpty()){
               
                for(Account servPermises: serviceAccountPremises){
                    
                    output = retrieveCustomerfacilitiesrequest(servPermises.Id,servPermises.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,servPermises.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,servPermises.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,servPermises.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c);
                    outputMetadata.put(servPermises.Id,output);
                }
             System.debug('output:::'+output); 
              System.debug('outputMetadata:::'+outputMetadata); 
                if(!outputMetadata.isEmpty()){
                    
                    systemOrderInfo(outputMetadata);
                    
                }
            }
            
            
        }
        return true;
    }
    
    public Map<String,Object> retrieveCustomerfacilitiesrequest(Id serviceAccountId,String streetAddress,String city,String state,String postalCode){
        
        Map<String, Object> retrvCustInputMap = new Map<String,Object>();
        Map<String, Object> outputResponse = new Map<String,Object>();
        String addressDescription = streetAddress +','+city+','+state+','+postalCode;
        ftr_addressBean addressObj = new ftr_addressBean();
        addressObj.addressLine1 = streetAddress;
        addressObj.cityName = city;
        addressObj.state = state;
        addressObj.zipCode = postalCode; 
        
        retrvCustInputMap.put('addressBean',addressObj); 
        outputResponse = ftr_DPIResourceManagmentSystemInterface.invoke('retrieveCustomerFacilities', retrvCustInputMap); 
        outputResponse.put('ServiceAccountId',serviceAccountId);
        outputResponse.put('addressDescription',addressDescription);
        
        System.debug(':::: output :::: '+outputResponse);
        return outputResponse;
    }
    
    /*
    public Boolean findAvailablePhoneNubmers(String OrderId){
        
        Map<String,Object> output = new Map<String,Object>();
        Map<String, Object> outputMetadata = new  Map<String,Object>();
        List<System_Order_Info__c> serviceOrderInfo = [Select Id, City_Abbreviation__c,Control_Number__c,Environment__c,Service_Address__c,Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                                       Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,WTN__c,Order__c,Service_Address__r.vlocity_cmt__PremisesId__r.WC_CLLI__c,
                                                       Order__r.OrderNumber,Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c  from System_Order_Info__c where Order__c =:OrderId
                                                       AND Control_Number__c != null AND Environment__c != null];
        if(!serviceOrderInfo.isEmpty()){
            
            for(System_Order_Info__c serRetreiveData: serviceOrderInfo){
                output = findAvailablePhoneNumbersRequest(serRetreiveData);
                outputMetadata.put(serRetreiveData.Id,output);
            }
            if(!outputMetadata.isEmpty()){
                systemOrderInfoFindAvailable(outputMetadata);
            }
             
        }
        return true;
    } */
    /*
    public Boolean ReserveTelephonenubmers(String OrderId){
        
        String reserveConfirmationId;
        String dateReservedUntil;
         Map<String,Object> output = new Map<String,Object>();
         Map<String,Object> reserveOutputMetadata = new Map<String,Object>();
        List<System_Order_Info__c> serviceOrderInfo = [Select Id, City_Abbreviation__c,Control_Number__c,Environment__c,Service_Address__c,Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                                       Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,WTN__c,Order__c,Service_Address__r.vlocity_cmt__PremisesId__r.WC_CLLI__c,
                                                       Order__r.OrderNumber,Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,ReserveConfirmationId__c  from System_Order_Info__c where Order__c =:OrderId AND WTN__c !=null];
        if(!serviceOrderInfo.isEmpty()){
            
            for(System_Order_Info__c serRetreiveData: serviceOrderInfo){
                if(serRetreiveData.ReserveConfirmationId__c == null){
                    output = reserveTelephonenumbersRequest(serRetreiveData);
                    reserveOutputMetadata.put(serRetreiveData.Id,output);
                }
                
            }
            if(!reserveOutputMetadata.isEmpty()){
                 systemOrderInfoReserveTelephone(reserveOutputMetadata);
            }
         
        }
        return true;
    }

*/
    
    /*
    public Map<String,Object> findAvailablePhoneNumbersRequest(System_Order_Info__c serviceOrderDetail){
        
         Map<String, Object> findAvaInputMap = new Map<String,Object>();
         Map<String, Object> findAvailTelephoneNumMap = new Map<String,Object>();  
            
         System.debug('ftr_DPIBaseSystemInterface:findAvailableTelephoneNumberAndReserve:Calling-->');
            findAvailTelephoneNumMap.put('env', String.ValueOf(serviceOrderDetail.Environment__c));
            findAvailTelephoneNumMap.put('state', String.ValueOf(serviceOrderDetail.Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c));
            findAvailTelephoneNumMap.put('city', String.ValueOf(serviceOrderDetail.Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c));
            findAvailTelephoneNumMap.put('maxTnNumbers', '1');
            findAvailTelephoneNumMap.put('itemSequence', '0');
            findAvailTelephoneNumMap.put('wc_cilli', String.ValueOf(serviceOrderDetail.Service_Address__r.vlocity_cmt__PremisesId__r.WC_CLLI__c));
            findAvailTelephoneNumMap.put('orderId', String.ValueOf(serviceOrderDetail.Order__c));
            findAvailTelephoneNumMap.put('order_no', String.ValueOf(serviceOrderDetail.Order__r.OrderNumber));
            findAvailTelephoneNumMap.put('zipCode', String.ValueOf(serviceOrderDetail.Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c));
            findAvailTelephoneNumMap.put('DI_Order711', 'SiteSurvey');
                
            findAvaInputMap=ftr_ResourceManagementService.findAvailableTelephoneNumberAndReserve(findAvailTelephoneNumMap);
        
           findAvaInputMap.put('ServiceOrderInfoId',serviceOrderDetail.Id);
           findAvaInputMap.put('OrderId',serviceOrderDetail.Order__c);
        
           System.debug(':::: findAvaInputMap :::: '+findAvaInputMap);
           return findAvaInputMap;
    }
    /*
    /*
    public Map<String,Object> reserveTelephonenumbersRequest(System_Order_Info__c serviceOrderDetail){
        
           Map<String, Object> reserTeleInputMap = new Map<String,Object>();
           Map<String, Object> reserTelephoneNumMap = new Map<String,Object>();  
            
         System.debug('ftr_DPIBaseSystemInterface:findAvailableTelephoneNumberAndReserve:Calling-->');
            reserTelephoneNumMap.put('env', String.ValueOf(serviceOrderDetail.Environment__c));
            reserTelephoneNumMap.put('tn', String.ValueOf(serviceOrderDetail.WTN__c));     
            reserTelephoneNumMap.put('maxTnNumbers', '1');
            reserTelephoneNumMap.put('itemSequence', '0');
            reserTelephoneNumMap.put('state', String.ValueOf(serviceOrderDetail.Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c));

            reserTeleInputMap=ftr_DPIResourceManagmentSystemInterface.invoke('reserveTelephoneNumber', reserTelephoneNumMap);
            reserTeleInputMap.put('ServiceOrderInfo',serviceOrderDetail.Id);
           System.debug(':::: reserTeleInputMap :::: '+reserTeleInputMap);
           return reserTeleInputMap;
    }
*/
   // @future 
    public static void systemOrderInfo(Map<String,Object> outputResponseMetadata){
        
        List<System_Order_Info__c> systemOrderRecord = new List<System_Order_Info__c>();
        List<Task> dpiBillingExceptionTask = new List<Task>();
        Map<String, Object> output = new Map<String, Object>();
       
        for(String key : outputResponseMetadata.keySet()){
             
            System.debug('outputResponseMetadata :::'+outputResponseMetadata.get(key));
            Map<String, Object> systemOrderData = (Map<String, Object>) outputResponseMetadata.get(key);

            System.debug('outputResponseMetadata :::'+String.valueOf(systemOrderData.get('env')));
            System.debug('outputResponseMetadata :::'+String.valueOf(systemOrderData.get('addressDescription')));
            
            if(String.isBlank(String.valueOf(systemOrderData.get('env')))){
                       
                      output.put('errorMessage', invalidWTNErrMsg+':No Unique Address Match Was Found For '+String.valueOf(systemOrderData.get('addressDescription')));
                      output.put('OrderId',OrderIdForSystemOrder);
                     dpiBillingExceptionTask =  creatTaskForDI711Orders(output);
             }else if(String.isBlank(String.valueOf(systemOrderData.get('controlNumber'))) || String.isBlank(String.valueOf(systemOrderData.get('cityabbreviation')))){
                        
                        output.put('errorMessage', invalidWTNErrMsg+':No Unique Address Match Was Found For '+String.valueOf(systemOrderData.get('addressDescription')));
                        output.put('OrderId',OrderIdForSystemOrder);
                       dpiBillingExceptionTask =  creatTaskForDI711Orders(output);
                    }
            else{
                System_Order_Info__c dpiRetreiveInfo = new System_Order_Info__c();
                dpiRetreiveInfo.Control_Number__c = String.valueOf(systemOrderData.get('controlNumber'));
                dpiRetreiveInfo.City_Abbreviation__c = String.valueOf(systemOrderData.get('cityabbreviation'));
                dpiRetreiveInfo.Environment__c = String.valueOf(systemOrderData.get('env'));
                dpiRetreiveInfo.Service_Address__c = String.valueOf(systemOrderData.get('ServiceAccountId'));
                dpiRetreiveInfo.Order__c = OrderIdForSystemOrder;
                dpiRetreiveInfo.WireCentre__c = String.valueOf(systemOrderData.get('controlNumber'));
                
               systemOrderRecord.add(dpiRetreiveInfo);
           }
        }
            
        if(!systemOrderRecord.isEmpty()){
            insert systemOrderRecord;
        }
        
        if(!dpiBillingExceptionTask.isEmpty()){
            insert dpiBillingExceptionTask;
        }
               
              
      }
  /*  
  //  @future 
    public static void systemOrderInfoFindAvailable(Map<String,Object> findAvailableMetadata){
       
         List<Task> taskList = new List<Task>();
         Map<String,Object> output = new Map<String,Object>();
         List<System_Order_Info__c> serviceOrderInfo = [Select Id, City_Abbreviation__c,Control_Number__c,Environment__c,WTN__c,Order__c from System_Order_Info__c where Id IN: findAvailableMetadata.KeySet()];
         
        List<System_Order_Info__c> serviceOrderInfoUpdate = new List<System_Order_Info__c>();
        if(!serviceOrderInfo.isEmpty()){
            
            for(System_Order_Info__c serviceUpdate:serviceOrderInfo){
                
                Map<String, Object> systemOrderFindAvailable = (Map<String, Object>) findAvailableMetadata.get(serviceUpdate.Id);
                if (!ftr_OrderManagementHelper.validTelephoneNumber(String.valueOf(systemOrderFindAvailable.get('telePhoneNumber')))){
                        output.put('errorMessage', invalidWTNErrMsg+':Available TN Not Found');
                       taskList = creatTaskForDI711Orders(output);
               }else{
                   serviceUpdate.WTN__c = String.valueOf(systemOrderFindAvailable.get('telePhoneNumber'));
                   serviceOrderInfoUpdate.add(serviceUpdate);
               }
            }
            
            if(!serviceOrderInfoUpdate.isEmpty()){
                
                update serviceOrderInfoUpdate;
            }
            if(!taskList.isEmpty()){
               insert taskList;
            }
        } 
    }
    */
   // @future 
    /*
    public static void systemOrderInfoReserveTelephone(Map<String,Object> reserveOutputMetadata){
  
         Map<String,Object> output = new Map<String,Object>();
         List<Task> taskList = new List<Task>();
         List<System_Order_Info__c> serviceOrderInfo = [Select Id, City_Abbreviation__c,Control_Number__c,Environment__c,WTN__c,Order__c from System_Order_Info__c where Id IN:reserveOutputMetadata.keySet()];
         List<System_Order_Info__c> serviceOrderInfoUpdate = new List<System_Order_Info__c>();
        if(!serviceOrderInfo.isEmpty()){
            
            for(System_Order_Info__c serviceUpdate:serviceOrderInfo){

                Map<String, Object> systemOrderReserve = (Map<String, Object>) reserveOutputMetadata.get(serviceUpdate.Id);
                String statusCode =(String) systemOrderReserve.get('statusCode');
                if (statusCode != '200'){
                     String messageText = getErrorMessageText((String)systemOrderReserve.get('responsebody'));
                     output.put('errorMessage',  messageText);
                     output.put('OrderId',  serviceUpdate.Order__c);
                     taskList = creatTaskForDI711Orders(output);
                }else{ 
                    String responseObj =  (String)systemOrderReserve.get('responsebody');
                    if(responseObj != null){
                           
                          serviceUpdate.ReserveConfirmationId__c =  responseObj.substringBetween('"reserveConfirmationId" : "', '"');
                          serviceOrderInfoUpdate.add(serviceUpdate);
                    }
                  
            }
        }
            
            if(!serviceOrderInfoUpdate.isEmpty()){
                
                update serviceOrderInfoUpdate;
            }
            if(!taskList.isEmpty()){
            insert taskList;
            }
        }
    
    }
    
    */
    
    /*
    public static void systemOrderDIOrderLeadOrderUpdate(Map<String,Object> submitOrderMetadata){
        
        System.debug('groupOrderId:::'+submitOrderMetadata);
         
        
        Map<String,Object> output = new Map<String,Object>();
        List<Task> taskList = new List<Task>();
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName ='DI_Service_Order'];
        List<System_Order_Info__c> serviceOrderInfo = [Select Id,WTN__c, Group_Order_Id__c,Lead_Order_Id__c,DI_711_Order_Request__c,DI_711_Order_Response__c,Order__r.OrderNumber,Environment__c,Order__c from System_Order_Info__c where Id IN:submitOrderMetadata.keySet()];
        List<System_Order_Info__c> serviceOrderInfoUpdate = new List<System_Order_Info__c>();
        List<Service_Order__c> serviceOrderByOM = new List<Service_Order__c>();
        if(!serviceOrderInfo.isEmpty()){
            
            for(System_Order_Info__c serviceUpdate:serviceOrderInfo){
               Map<String, Object> systemSubmitOrder = (Map<String, Object>) submitOrderMetadata.get(serviceUpdate.Id);
                if(systemSubmitOrder.get('errorMessage')!=null && systemSubmitOrder.get('errorMessage')!=''){
                    output.put('OrderId',serviceUpdate.Order__c);
                    taskList = creatTaskForDI711Orders(output);
              }else{
                Service_Order__c so = new Service_Order__c();
                serviceUpdate.Group_Order_Id__c = String.valueOf(systemSubmitOrder.get('GroupMemberOrderId'));
                serviceUpdate.Lead_Order_Id__c = String.ValueOf(systemSubmitOrder.get('LeadOrderId'));
                serviceUpdate.DI_711_Order_Request__c = String.ValueOf(systemSubmitOrder.get('Request'));
                serviceUpdate.DI_711_Order_Response__c = String.ValueOf(systemSubmitOrder.get('Response'));
                so.Name = String.ValueOf(systemSubmitOrder.get('LeadOrderId'));
                so.Working_Number__c = serviceUpdate.WTN__c;
                so.Order__c = serviceUpdate.Order__c;
                so.Order_Number__c = serviceUpdate.Order__r.OrderNumber;
                so.RecordTypeId = rt.Id;
                so.DPI_Env__c = serviceUpdate.Environment__c;
                so.Schedule_Due_Date__c = Date.Today() + 2;
                so.Description__c = 'Auto generated DI 711 Order by Vlocity OM';
                serviceOrderInfoUpdate.add(serviceUpdate);
                serviceOrderByOM.add(so);
            }
         }
            
            if(!serviceOrderInfoUpdate.isEmpty()){
                System.debug('serviceOrderInfoUpdate ::::'+serviceOrderInfoUpdate);
                update serviceOrderInfoUpdate;
                insert serviceOrderByOM;
            }
            if(!taskList.isEmpty()){
              insert taskList;
            }
        }
            
    }

   @future(callout=true)
   public static void submitGroupOrderD1711(String OrderId){
        
        System.debug('I am going to OrderId'+OrderId);
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> outputMetadataSubmitOrder = new Map<String,Object>();
        List<System_Order_Info__c> serviceOrderInfo = [Select Id,ContractTerm__c,Order__r.OrganizationType__c,Service_Address__r.BTN__c,Order__r.BillToContact.Phone,Order__r.Technical_Contact__r.Phone,Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c, City_Abbreviation__c,Control_Number__c,Environment__c,Service_Address__c,Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,WTN__c,Order__c,Service_Address__r.vlocity_cmt__PremisesId__r.WC_CLLI__c,
                                                       Order__r.OrderNumber,Order__r.Contract_Schedule__r.StartDate,Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,Order__r.BillingStreet, Order__r.BillingPostalCode,Order__r.BillingStateCode,Order__r.BillingCity,Order__r.BillToContact.Name,Order__r.Technical_Contact__r.Name,
                                                       Order__r.Order_Contact__r.Name,Order__r.Sales_Channel__c,Order__r.Partner_ID__c,Order__r.Selling_Representative_CRIS__c,Order__r.Vlocity_Schedule_ID__c,Order__r.Contract_Schedule__c,
                                                       Order__r.Account.Name,Order__r.Order_Contact__r.Phone,Lead_Order_Id__c,Group_Order_Id__c,Service_Address__r.Name,
                                                       Order__r.Selling_Representative_Name__c,Order__r.Hot_Cut__r.Name,Order__r.Federal_Tax_Exempt__c,Order__r.Federal_Tax_ID__c  from System_Order_Info__c
                                                       where Order__c =:OrderId];
       System.debug('serviceOrderInfo Data'+serviceOrderInfo);
        if(!serviceOrderInfo.isEmpty()){
            
            List<Location_Contact__c> locCon = [Select Id,Contact_Phone__c, Name from Location_Contact__c where Order__c =:OrderId limit 1];
            
            for(System_Order_Info__c serRetreiveData: serviceOrderInfo){
                if(String.isBlank(serRetreiveData.Lead_Order_Id__c)){
                    System.debug('serRetreiveData.Lead_Order_Id__c'+serRetreiveData.Lead_Order_Id__c);
                    output = submitGroupOrderD1711Request(serRetreiveData,locCon);
                    outputMetadataSubmitOrder.put(serRetreiveData.Id,output);
                }
                
            }
            if(!outputMetadataSubmitOrder.isEmpty()){
                systemOrderDIOrderLeadOrderUpdate(outputMetadataSubmitOrder);
            }
           
        }
        
    } 
    
    public static Map<String,Object> submitGroupOrderD1711Request(System_Order_Info__c serRetreiveData,List<Location_Contact__c> locCon){
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Map<String,Object> submitGroupOrderMember = new Map<String,Object>();
        Map<String,Object> requestBody = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        Map<String, Object> headerInfo = new Map<String, Object>();
        String endpoint = apiConfigMap.get('CustMgmtURI');
        headerInfo.put('endpoint',endpoint);
        headerInfo.put('contentType', 'text/xml;charset=UTF-8');
        //Highlighted Part
        requestBody = createDPI711Request(serRetreiveData,locCon);
        system.debug('DPI Request map: '+requestBody);
        String requestXml =(String) requestBody.get('DpiRequestXML');
        String orderCount = (String) requestBody.get('transactionCount');
        requestInput = requestXml;
           
        system.debug('DPI Request xml:'+JSON.serialize(requestXml) );
        request = setRequestHeaders(request, requestXml, headerInfo);
            HttpResponse response = http.send(request);
            System.debug('HttpResponse : '+ response);
            
            if (response!=null){
                //if (response.getStatusCode() == 200) {
                String responseType = response.getBody();
                System.debug('RespHttpResponse Body : '+ response.getBody());        
                //Highlighted Part
                output = createDPI711Response(response.getBody());
                output.put('transactionCount', orderCount);
                output.put('ServiceOrderInfo', serRetreiveData.Id);
                output.put('Request',requestXml);
                output.put('Response',output);
            }
        System.debug('Response Output::: '+output);
        return output; 
    }


    public static Map<String,Object> createDPI711Request(System_Order_Info__c serRetreiveData, List<Location_Contact__c> locCon){
        Map<String,Object> submitGroupOrderMemberRequest = new Map<String,Object>();
           String requesttotal;
           String streetAddress = String.ValueOf(serRetreiveData.Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c);
           String  streetNumber = streetAddress.substringBefore(' ');
           String streetName    = streetAddress.substringAfter(' ');
           Date nextTwoDays = Date.Today() + 2;
           String dueDate   = String.ValueOf(nextTwoDays)+'T00:00:00';
           String memoText = 'SF Order # '+serRetreiveData.Order__r.OrderNumber+'/ AE: '+serRetreiveData.Order__r.Selling_Representative_Name__c+'/ SC: '+serRetreiveData.Order__r.Hot_Cut__r.Name+'/ Contract Length '+serRetreiveData.ContractTerm__c;
           String request1 =  '<soapenv:Envelope '+'xmlns:'+'soapenv="http://schemas.xmlsoap.org/soap/envelope/" '+'xmlns:cus="http://esb.frontier.com/CustomerOrderManagement" '+'xmlns:'+'shar="'+ 'http://esb.frontier.com/sharedType" '+'xmlns:'+'xsi="xsi">'+
           '<soapenv:Header/>'+
           '<soapenv:Body>'+
           '<cus:SubmitGroupOrderMember>'+
           '<submitGroupOrderMemberInput>'+
           '<header>'+ //correlationId
           '<shar:correlationId>'+serRetreiveData.Order__r.OrderNumber+'.'+serRetreiveData.WTN__c+'</shar:correlationId>'+
           '<shar:requestingApplication>VlocityOM</shar:requestingApplication>'+
           '<securityInfo>'+
           '<userId>ftrqacomm</userId>'+
           '<employeeId>825280</employeeId>'+
           '</securityInfo>'+
           '</header>'+
           '<groupOrderTransactionCount>'+'1'+'</groupOrderTransactionCount>'+
           '<customerOrder>'+
           '<customerOrderType>'+'INSTALL'+'</customerOrderType>'+
           '<installationType>'+'FULL_INSTALL'+'</installationType>'+
           '<orderRemark>'+'Site Survey for new UCF location'+'</orderRemark>'+
           '<orderRemark>'+serRetreiveData.Service_Address__r.Name+'</orderRemark>'+
           '<orderRemark>'+''+'</orderRemark>'+
           '<memo>'+ '<templateName>*FREE</templateName>'+
           '<section>'+'<sectionName>*NONE</sectionName>'+
           '<text>'+memoText+'</text>'+
            '</section>'+'</memo>'+
           '<salesChannelPartnerId>'+serRetreiveData.Order__r.Partner_ID__c+'</salesChannelPartnerId>'+
           '<actionReason>'+'01'+'</actionReason>'+
           '<customerWillAdviseFlag>'+'false'+'</customerWillAdviseFlag>';
            String dueDateBlock =  '<dueDate>'+dueDate+'</dueDate>';
            String cridIdBlock =  '<soldBy>'+
            '<id>'+serRetreiveData.Order__r.Selling_Representative_CRIS__c+'</id>'+
            '</soldBy>';
            String salesChannelBlock =  '<saleschannelType>'+
            '<code>' + '217' + '</code>'+
            '</saleschannelType>';
        String newConstructionBlock = '<isNewConstruction>true</isNewConstruction>';
  
             String afterSalesChannelBlock = '<provisioningDetails>'+
            '<commercialCircuitProvisioning>'+
            '<orderStageCode>DIS</orderStageCode>'+
            '</commercialCircuitProvisioning>'+
            '</provisioningDetails>'+
            '<marketingProgram>BUSINESS</marketingProgram>';
        
         String appointment = '<appointment>'+'<businessTimePeriod>'+'<shar:startDate>'+dueDate+'</shar:startDate>'+
                '</businessTimePeriod>'+'<calendarEntry>'+'<status>'+'Open'+'</status>'+'</calendarEntry>'+
                '<contact>'+'<name>'+locCon[0].Name+'</name>'+'<telephoneNumber>'+
                '<telephoneNumber>'+locCon[0].Contact_Phone__c+'</telephoneNumber>'+'<type>'+'PrimaryTelephoneNumber'+
                '</type>'+'</telephoneNumber>'+
                '</contact>'+'<remark>'+'Please call 1st'+'</remark>'+
                '</appointment>';
        
            String contractTermBlock =   '<contract>'+
            '<term>'+
            '<termInMonths>'+serRetreiveData.ContractTerm__c+'</termInMonths>'+
            '</term>'+
            '<offer>'+
            '<soldOn>'+serRetreiveData.Order__r.Contract_Schedule__r.StartDate+'</soldOn>'+
            '<standardMarketingPackageId>1</standardMarketingPackageId>'+
            '</offer>'+
            '<Id>'+ serRetreiveData.Order__r.Contract_Schedule__c+'</Id>'+
            '<type>CIR</type>'+
            '<scheduleId>'+serRetreiveData.Order__r.Vlocity_Schedule_ID__c+'</scheduleId>'+
            '<marketingPackage>BUSINESS</marketingPackage>'+
             '</contract>';
            String afterContractBlock = '</customerOrder>'+
            '<customerAccount>'+
            '<accountId>'+
            '<telephoneNumber>'+
            '<telephoneNumber>'+serRetreiveData.WTN__c+'</telephoneNumber>'+
            '</telephoneNumber>'+
            '<environment>'+serRetreiveData.Environment__c+'</environment>'+
            '</accountId>'+
            '<billingAccountId>'+
            '<telephoneNumber>'+
            '<telephoneNumber>'+serRetreiveData.WTN__c+'</telephoneNumber>'+
            '</telephoneNumber>'+
            '</billingAccountId>'+
            '<accountServiceType>'+
           '<code>'+'71'+'</code>'+
             '</accountServiceType>'+
             '<accountPreferences>'+
                '<billHandlingCode>M</billHandlingCode>'+
             '<tollLimitCode/>'+
             '</accountPreferences>'+
             '<customerBill>'+
                  '<cus:billDetailLevel>'+'PARTIAL'+'</cus:billDetailLevel>';
          
  
            String afterCustomerBillBlock = '</customerBill>'+
             '<taxProfile>'+
             '<isFederalTaxExempt>'+serRetreiveData.Order__r.Federal_Tax_Exempt__c+'</isFederalTaxExempt>'+
              '<federalTaxId>'+serRetreiveData.Order__r.Federal_Tax_ID__c+'</federalTaxId>'+
             '</taxProfile>'+
             '<location>'+
             '<serviceAddress>'+
             '<serviceAddressMaterId>'+
             '<controlNumber>'+serRetreiveData.Control_Number__c+'</controlNumber>'+
             '<sequenceNumber>1</sequenceNumber>'+
             '</serviceAddressMaterId>'+
            // '<cityAbbreviation>'+cityAbbr+'</cityAbbreviation>'+
             '<address>'+
             '<streetNumber>'+streetNumber+'</streetNumber>'+
             '<streetName>'+streetName+'</streetName>'+
             '<streetSuffix>'+''+'</streetSuffix>'+
             '<cityName>'+serRetreiveData.Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c+'</cityName>'+
             '<stateAbbreviation>'+serRetreiveData.Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c+'</stateAbbreviation>'+
             '<zipCode>'+serRetreiveData.Service_Address__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c   +'</zipCode>'+
             '</address>'+
             '</serviceAddress>'+
             '</location>'+
            '</customerAccount>'+
            '<customer>'+
            '<cus:organization>'+
            '<organizationName>'+
            '<tradingName>'+serRetreiveData.Order__r.Account.Name+'</tradingName>'+
            '</organizationName>'+
            '<contactInformation>'+
            '<internationalAddress>'+
            '<addressLine1>'+serRetreiveData.Order__r.BillingStreet+'</addressLine1>';
          
            String intCityBlock =  '<cityName>'+serRetreiveData.Order__r.BillingCity+'</cityName>';
            String intStateOrProv = '<stateOrProvince>'+serRetreiveData.Order__r.BillingStateCode+'</stateOrProvince>';
            String intPostalCode =   '<postalCode>'+serRetreiveData.Order__r.BillingPostalCode+'</postalCode>';
            String beforeCreditProfileRefBlock = '</internationalAddress>'+
            '</contactInformation>'+
            '</cus:organization>'+
            '<cus:customerCreditProfile>'+
           
            '<creditProfileReference>';
            String customerOrderItemStr ='<customerOrderItem>'+
                      '<action>'+'Add'+'</action>'+
                      '<quantity>'+'1.00'+'</quantity>'+
                      '<chargeType>'+'Permanent'+'</chargeType>'+
                      '<processingDirection>'+'Forward'+'</processingDirection>'+
                      '<product>'+
                      '<id>'+'ANYWR'+'</id>'+
                      '<lineItemSequenceNumber>'+'0'+'</lineItemSequenceNumber>'+
                      '</product>'+
                      '</customerOrderItem>'+
                      '<customerOrderItem>'+
                      '<action>'+'Add'+'</action>'+
                      '<quantity>'+'1.00'+'</quantity>'+
                      '<chargeType>'+'Permanent'+'</chargeType>'+
                      '<processingDirection>'+'Forward'+'</processingDirection>'+
                      '<product>'+
                      '<id>'+'ACCSS'+'</id>'+
                      '<lineItemSequenceNumber>'+'0'+'</lineItemSequenceNumber>'+
                      '</product>'+
                      '</customerOrderItem>'+
                     '<customerOrderItem>'+
                      '<action>'+'Add'+'</action>'+
                      '<quantity>'+'1.00'+'</quantity>'+
                      '<chargeType>'+'Permanent'+'</chargeType>'+
                      '<processingDirection>'+'Forward'+'</processingDirection>'+
                      '<product>'+
                      '<id>'+'FIELD'+'</id>'+
                      '<lineItemSequenceNumber>'+'0'+'</lineItemSequenceNumber>'+
                      '</product>'+
                      '</customerOrderItem>';
            String creditProfileBusBlock =  '<business>'+
            '<organizationType>'+serRetreiveData.Order__r.OrganizationType__c + '</organizationType>'+
            '</business>';
            String busOwnerBlock =  '<businessOwner>'+
            '<name>'+serRetreiveData.Order__r.Order_Contact__r.Name+'</name>'+
                 '<telephoneNumber>'+serRetreiveData.Order__r.Order_Contact__r.Phone+'</telephoneNumber>'+
            '</businessOwner>';
            
            String creditProfileBillToContactBlock =  '<billingContact>'+
            '<name>'+serRetreiveData.Order__r.BillToContact.Name+'</name>'+
                 '<telephoneNumber>'+serRetreiveData.Order__r.BillToContact.Phone+'</telephoneNumber>'+
            '</billingContact>';
            String creditProfileTechContactBlock =  '<technicalContact>'+
            '<name>'+serRetreiveData.Order__r.Technical_Contact__r.Name+'</name>'+
            '<telephoneNumber>'+serRetreiveData.Order__r.Technical_Contact__r.Phone+'</telephoneNumber>'+
            '</technicalContact>';
            String afterCreditProfileRefBlock =   '</creditProfileReference>'+
                 '<creditScore>'+
                '<creditRating>7</creditRating>'+
            '</creditScore>'+
            '<customerRefusedToProvideSSN>false</customerRefusedToProvideSSN>'+
            '</cus:customerCreditProfile>'+
            '<cus:customerType>Business</cus:customerType>'+
            '</customer>'+
            '</submitGroupOrderMemberInput>'+
            '</cus:SubmitGroupOrderMember>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';

           requesttotal = request1 + customerOrderItemStr;
            if(dueDate!=null){
              requesttotal = requesttotal+dueDateBlock;
            }
            
              // requesttotal = requesttotal + cridIdBlock ;
            
            
               requesttotal = requesttotal +  salesChannelBlock ; 
             
               //  requesttotal = requesttotal + afterSalesChannelBlock;
             
             
        
            if(appointment !=null){
                requesttotal = requesttotal + appointment;
            }
        
             // requesttotal = requesttotal +    contractTermBlock;
              requesttotal = requesttotal + afterContractBlock;
              requesttotal = requesttotal + afterCustomerBillBlock;
              requesttotal = requesttotal + intCityBlock;    
           
           
              requesttotal = requesttotal + intStateOrProv;
            
            
              requesttotal = requesttotal + intPostalCode;   
            
            requesttotal = requesttotal + beforeCreditProfileRefBlock;
            
            requesttotal = requesttotal +  creditProfileBusBlock; 
            
            
            requesttotal = requesttotal + busOwnerBlock;    
            
           
            
              requesttotal = requesttotal +  creditProfileBillToContactBlock;
            
            
              requesttotal = requesttotal +  creditProfileTechContactBlock;
           
             requesttotal = requesttotal + afterCreditProfileRefBlock; 
           
            requesttotal = requesttotal.replaceAll('>null<', '><');
            System.debug('New design submit order request '+requesttotal );
            submitGroupOrderMemberRequest.put('DpiRequestXML', requesttotal);
            submitGroupOrderMemberRequest.put('transactionCount', '1');
        
        return submitGroupOrderMemberRequest;
    } 
    public static Map<String,Object> createDPI711Response(Object respType){
        Map<String,Object> submitGroupOrderResponseMap = new Map<String,Object>();
          String response = String.valueOf(respType);
  System.debug('Response:' + response);
 if (respType != null){
      String resp = JSON.serialize(respType);
     if(response.indexOf('<leadOrderId>') !=-1){
      String orderNum=response.substring(response.indexOf('<leadOrderId>'), response.indexOf('</leadOrderId>'));
      System.debug('ordernumber:' + ordernum);
      }
   
      System.debug('Index of operationstatus :'+ response.indexOf('<operationStatus>'));
     String OpStatus = response.substring(response.indexOf('<operationStatus>')+17, response.indexOf('</operationStatus>'));
      System.debug('Operation Status :'+ OpStatus.trim() );
      if((OpStatus.trim()).equals('TRUE')){
          String leadOrderBlock = response.substring(response.indexOf('<leadOrderId>'), response.indexOf('</leadOrderId>'));
          String leadOrderNum=leadOrderBlock.substring(leadOrderBlock.indexOf('<orderNumber>')+13, leadOrderBlock.indexOf('</orderNumber>'));
          String groupMemberOrderBlock = response.substring(response.indexOf('<groupMemberOrderId>'), response.indexOf('</groupMemberOrderId>'));
          String memberOrderNum=groupMemberOrderBlock.substring(groupMemberOrderBlock.indexOf('<orderNumber>')+13, groupMemberOrderBlock.indexOf('</orderNumber>'));
          System.debug('leadOrderNum :'+leadOrderNum);
          System.debug('memberOrderNum :'+memberOrderNum);
          submitGroupOrderResponseMap.put('LeadOrderId',leadOrderNum);
          submitGroupOrderResponseMap.put('GroupMemberOrderId', memberOrderNum);
          submitGroupOrderResponseMap.put('CreateTask', 'Yes');
      }
     else{
        System.debug('Operation status false, response is '+response);
          String severity,operationStatusCode,operationStatusDescription, errorcode ;
         //To Do - ExecutionStatusMessage is an array, need to be handled later. 
         String executionStatusParent = response.substring(response.indexOf('<executionStatusMessage>'),response.indexOf('</executionStatusMessage>'));
          severity =  executionStatusParent.substring(executionStatusParent.indexOf('<severity>')+('<severity>').length(),executionStatusParent.indexOf('</severity>'))    ;      
          operationStatusCode = executionStatusParent.substring(executionStatusParent.indexOf('<operationStatusCode>')+('<operationStatusCode>').length(),executionStatusParent.indexOf('</operationStatusCode>')) ;
           errorCode = severity + ' | '+ operationStatusCode;
           operationStatusDescription =  executionStatusParent.substring(executionStatusParent.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusParent.indexOf('</operationStatusDescription>')) ;
         System.debug('executionStatusParent: '+executionStatusParent);
         String executionStatusChild  = executionStatusParent.substring(executionStatusParent.indexOf('<executionStatusMessage>')+('<executionStatusMessage>').length()-1);
         System.debug('executionStatusChild: '+executionStatusChild);
       //  while(executionStatusChild.indexOf('<executionStatusMessage>') != -1){
         do{
              System.debug('executionStatusChild: inside while :'+executionStatusChild.indexOf('<executionStatusMessage>'));
             System.debug('errorCode inside while :'+errorCode);
             System.debug('Severity starting index :'+ executionStatusChild.indexOf('<severity>')+('<severity>').length());
             System.debug('Severity ending index :'+ executionStatusChild.indexOf('</severity>'));
             severity = errorCode +' | ' + executionStatusChild.substring(executionStatusChild.indexOf('<severity>')+('<severity>').length(),
                                                                          executionStatusChild.indexOf('</severity>') );
             System.debug('severity inside while :'+severity);
             operationStatusCode = severity + ' | '+executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusCode>')+('<operationStatusCode>').length(),executionStatusChild.indexOf('</operationStatusCode>') );
             operationStatusDescription = operationStatusDescription + ' | ' +executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusChild.indexOf('</operationStatusDescription>') );
             executionStatusChild=executionStatusChild.substring(executionStatusChild.indexOf('<executionStatusMessage>')+('<executionStatusMessage>').length() -1);
             System.debug('executionStatusChild inside while :'+executionStatusChild);
             errorCode = operationStatusCode;
             System.debug('Error code in while :'+errorCode);
             }while(executionStatusChild.indexOf('<executionStatusMessage>') != -1);
        System.debug('executionStatusChild after while: '+executionStatusChild);
          if(executionStatusChild.indexOf('<operationStatusCode>')!=-1){
             errorCode = errorCode + ' | '+executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusCode>')+('<operationStatusCode>').length(),executionStatusChild.indexOf('</operationStatusCode>') );
          }
         if(executionStatusChild.indexOf('<executionStatusChild>')!=-1){
         operationStatusDescription = operationStatusDescription+ executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusChild.indexOf('</operationStatusDescription>') );
          }
         executionStatusParent = response.substring(response.indexOf('</executionStatusMessage>')+('<executionStatusMessage>').length());
             System.debug('second executionStatusParent :'+executionStatusParent);
             executionStatusChild  = executionStatusParent.substring(executionStatusParent.indexOf('<executionStatusMessage>')+('<executionStatusMessage>').length());
             System.debug('second executionStatusChild :'+executionStatusChild);
             do{
                  if(executionStatusChild.indexOf('<severity>')!=-1){
                       severity = errorCode +' | ' + executionStatusChild.substring(executionStatusChild.indexOf('<severity>')+('<severity>').length(), executionStatusChild.indexOf('</severity>') );
                  }
                 System.debug('severity inside 2nd while :'+severity);
                   if(executionStatusChild.indexOf('<operationStatusCode>')!=-1){
                  operationStatusCode = severity + ' | '+executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusCode>')+('<operationStatusCode>').length(),executionStatusChild.indexOf('</operationStatusCode>') );
                   }
                   if(executionStatusChild.indexOf('<operationStatusDescription>')!=-1){
                       operationStatusDescription = operationStatusDescription + ' | ' +executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusChild.indexOf('</operationStatusDescription>') );
                   }
                       executionStatusChild=executionStatusChild.substring(executionStatusChild.indexOf('<executionStatusMessage>')+('<executionStatusMessage>').length() -1);
             }while(executionStatusChild.indexOf('<executionStatusMessage>') != -1);
             submitGroupOrderResponseMap.put('errorCode', errorCode); 
           if(operationStatusDescription.contains('Failure') ||operationStatusDescription.contains('RUN09034')  || operationStatusDescription.contains('clientGroupIdentifier') ){
             operationStatusDescription = 'The telephone numbers previously reserved for this order are either used by different account or the correlation id needs to be fixed. Please open a case for IT.';
           }    
             submitGroupOrderResponseMap.put('errorMessage', operationStatusDescription); 
           System.debug(' Error Map : '+ submitGroupOrderResponseMap);
     }
     }
 else{
        System.debug('Response is null');
  }
  return submitGroupOrderResponseMap;
  
    } 
    
    private static HttpRequest setRequestHeaders( HttpRequest request, Object requestType, Map<String, Object> headerInfo){
        
        System.debug('Customermanagement endpoint '+'callout:DPIApigeeCredentials');
        request.setEndpoint('callout:DPIApigeeCredentials'+(String)headerInfo.get('endpoint'));
      
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiConfigMap.get('AuthHeader')));
        request.setHeader(AUTHORIZATION, authorizationHeader);
        request.setHeader(API_KEY, apiConfigMap.get('ApiKey'));
       
        request.setHeader(CONTENT_TYPE ,(String)headerInfo.get('contentType'));
        request.setMethod(REQUEST_METHOD_POST);
        request.setTimeout(Integer.valueOf(apiConfigMap.get('Timeout')));
        if (headerInfo.get('ESB-requestingApplication')!=null){
            request.setHeader('ESB-requestingApplication',(String)headerInfo.get('ESB-requestingApplication'));
        }
        if (headerInfo.get('ESB-securityInfo.employeeId')!=null){
            request.setHeader('ESB-securityInfo.employeeId',(String)headerInfo.get('ESB-securityInfo.employeeId'));
        }
        if(!Test.isRunningTest()) {
            request.setBody((String)requestType);
        }
        System.debug('Request body 2:'+(String)request.getBody());
        return request;
        
    }
    
    private Static String getErrorMessageText(String  responseBody){
        String responseMessage;
        if(responseBody!=null){
            responseMessage = responseBody.substringBetween('message_text', ',');
            System.debug ('ReserveTn responseMessage :'+responseMessage);
        }
        
        return responseMessage;
    }    
    
 */
    public static List<Task> creatTaskForDI711Orders(Map<String,Object> outputMap){
        
          List<Task> taskList = new List<Task>();
          Group grp = [Select Id from Group where Type = 'Queue' AND DeveloperName ='Network_COE_UCaas'];
          Task task = new Task();
          task.Subject = 'DPI OM Billing Exception';
          task.Description = String.ValueOf(outputMap.get('errorMessage'));
          task.OwnerId = grp.Id;
          task.Priority = 'High';
          task.WhatId = String.ValueOf(outputMap.get('OrderId'));
          task.Status ='Not Started';
          task.ActivityDate = Date.Today() + 2;
          taskList.add(task);
          return taskList;
          
        
              
    }
}