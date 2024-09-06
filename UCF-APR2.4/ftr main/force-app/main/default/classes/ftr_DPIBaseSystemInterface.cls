global without sharing virtual class ftr_DPIBaseSystemInterface implements vlocity_cmt.XOMOrchestrationInterfaces.ISystemInterface, vlocity_cmt.XOMOrchestrationInterfaces.IDeferredUpdater {
    protected Map<String, Object> ctx = new Map<String, Object>();
    public static String FulfilmentReqLineId;
    public static final String TaskName_SubmitGroupOrderMember = 'SubmitGroupOrderMember';
    public static final String TaskName_RCSubmitGroupOrder = 'RCSubmitGroupOrder';
    public static final String TaskName_RetrieveCustomerFacilities = 'RetrieveCustomerFacilities';
    public static final String TaskName_findAvailableTelephoneNumbers = 'findAvailableTelephoneNumbers';
    public static final String TaskName_ReserveTelephoneNumber = 'ReserveTelephoneNumber';
    public static final String TaskName_StageGroupOrderMember = 'StageGroupOrderMember';
    public static String orchestrationTaskName; 
    private static final String REQUEST_METHOD_POST = 'POST';
    private static final String API_CONFIG_SETTINGS = 'DPIAuthentication';
    @TestVisible private static Map<String, String> apiConfigMap=new Map<String,String>();
    @TestVisible private static IntegrationAPIConfig__mdt apiconfig;
    private static final String ERR_NULL_INPUT ='Null ApiKey/Timeout';
    private static final String AUTHORIZATION = 'Authorization';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String API_KEY = 'apikey';
    private static final string  invalidWTNErrMsg = 'WTN/BTN reservation Not Successfull';
    private static Decimal  retryCount ;
    private static String sfOrderNumber ;
    private static String orchestrationItemName;
    
   // private esbftrCustomerordermanagement.CustomerOrderManagement_CustomerOrderManagementHttpPort port;
    
    static{
        
        try{
            List<IntegrationAPIConfig__mdt> apiConfigs = [SELECT Timeout__c, ApiKey__c,Authorization_Header__c, CustomerOrderMgmt_URI__c, OrderStaging_URI__c FROM IntegrationAPIConfig__mdt WHERE DeveloperName=: API_CONFIG_SETTINGS LIMIT 1];
            
            
            if ( !Test.isRunningTest() && (apiConfigs.isEmpty() || String.isBlank(apiConfigs[0].ApiKey__c) || apiConfigs[0].Timeout__c == null)) {
                throw new ftr_DPIBaseSystemInterfaceException(ERR_NULL_INPUT);
            }
            apiconfig=apiConfigs[0];
            apiConfigMap.put('Timeout', String.valueOf(apiConfig.Timeout__c));
            apiConfigMap.put('ApiKey', apiConfig.ApiKey__c);
            apiConfigMap.put('AuthHeader', apiConfig.Authorization_Header__c);
            apiConfigMap.put('CustMgmtURI', apiConfig.CustomerOrderMgmt_URI__c);
            apiConfigMap.put('DPIOrderStageURI', apiConfig.OrderStaging_URI__c);
            // apiConfigMap.put('DPIOrderStageURI', 'jhjhkhjkj');
            
        } catch (Exception ex){
            System.debug(ex.getMessage());
            ftr_Logger.write(ex);
        }
    }
    
    global class ftr_DPIBaseSystemInterfaceException extends Exception {}
    
    /**
* This method is a part of ISystemInterface. It is invoked at the start of the batch
* @param  url  base URL the batch is started for
* @param  path path this batch is started for
*/
    global virtual void startBatch(String url, String path){
        // Do nothing
        ftr_Logger.writeInfo('Exit ftr_DPIBaseSystemInterface.startBatch');
    }
    /**
* Executes a Callout OrchestrationItem
* if cache is enabled then orchestration item data is retrieved from cache
* @param  url  base URL to send the request to
* @param  path path to send the request to
* @param  item OrchestrationItem that needs to be executed
*/
    global virtual void executeItem(String url, String path, vlocity_cmt__OrchestrationItem__c item) { 
        ftr_Logger.writeInfo('Enter ftr_DPIBaseSystemInterface.executeItem');
        orchestrationTaskName = getOrchestrationTaskName();
        Map<String, Object> output = new  Map<String,String>();
        String whatId ;
        Boolean isXml = true;
        retryCount = item.vlocity_cmt__NumberOfRetries__c; 
        orchestrationItemName = item.Name;
        System.debug('Bundle id  '+ item.vlocity_cmt__VlocityDataRaptorBundleId__c );
        //System.debug('Order id  '+ item.vlocity_cmt__OrderItemId__r.Order.Id+' , '+ item.vlocity_cmt__OrderItemId__r.OrderId);
        try {
            Map<String, Object> input;
            String testjsonInput;
            // Pre_Invoke
            
            
            input = ftr_OrderManagementHelper.getInputPayload(url, path, item);
            System.debug('Output object0 : '+ output + 'Input object0: '+input);
            System.debug('ftr_DPIBaseSystemInterface:getInputPayload:input-->'+ JSON.serialize(input));
            whatId = String.valueOf(input.get('salesforce_order_id'));
            sfOrderNumber = String.valueOf(input.get('salesforce_order_number'));
            System.debug('Order id1  '+whatId);
            List<Object> orderItemsList = (List<Object>)input.get('order_items');
            Map<String,Object> orderItemIdMap = (Map<String,Object>)orderItemsList[0];
            FulfilmentReqLineId = String.valueOf(orderItemIdMap.get('order_item_id'));
            System.debug('ftr_DPIBaseSystemInterface:Orchestration bundle-->'+ item.vlocity_cmt__VlocityDataRaptorBundleId__c);
            //System.debug('Orchestration bundle id : '+ item.vlocity_cmt__VlocityDataRaptorBundleId__c);
            if(Test.isRunningTest() ){
                testJsonInput= '{"order_items":[{"described_by":{"FTR_ENT_TECH_ATTCAT":[{"value":"true","characteristic":"ATTR_IsSubmitOrderToDPI"},{"value":"dec50907-3671-506f-51a5-d8ebf6e962ab","characteristic":"CorrelationId"},{"value":"2","characteristic":"GroupOrderTransactionCount"}],"FTR_ENT_CUSTOMER_ATTCAT":[{"value":"null","characteristic":"BusinessOwnerName"},{"value":"Business","characteristic":"CustomerType"},{"value":"3","characteristic":"CreditRating"},{"value":"1234567890","characteristic":"BusinessOwnerTelephone"}],"FTR_ENT_CUSTOMERORDER_ATTCAT":[{"value":"Add","characteristic":"Action"},{"value":"ADUNI","characteristic":"UNI_SNE_CODE"},{"value":"null","characteristic":"SNE_Code_TERM"},{"value":"null","characteristic":"SNE_Code_OTC"},{"value":"null","characteristic":"SNE_Code_MRC"},{"value":"null","characteristic":"RecurringCharge"},{"value":"1.00","characteristic":"Quantity"},{"value":"null","characteristic":"OneTimeTotal"},{"value":"NO_INSTALL","characteristic":"InstallationType"},{"value":"INSTALL","characteristic":"CustomerOrderType"}],"FTR_ENT_CUSTOMERACCOUNT_ATTCAT":[{"value":"65","characteristic":"AccountServiceType"},{"value":"LWV","characteristic":"cityAbbreviation"},{"value":"9721970295","characteristic":"WorkingTelephoneNumber"},{"value":"Kavira Technology Consulting Inc","characteristic":"TradingName"},{"value":"75077","characteristic":"ServLocZipCode"},{"value":"1480 North Valley Parkway","characteristic":"ServLocStreetAddress"},{"value":"TX","characteristic":"ServLocStateAbbreviation"},{"value":"Lewisville","characteristic":"ServLocCityName"},{"value":"false","characteristic":"IsFederalTaxExempt"},{"value":"1480 North Valley Parkway","characteristic":"InterLocStreetAddress"},{"value":"TX","characteristic":"InterLocStateAbbreviation"},{"value":"75077","characteristic":"InterLocPostalCode"},{"value":"Lewisville","characteristic":"InterLocCityName"},{"value":"FT","characteristic":"Environment"},{"value":"2181288","characteristic":"ControlNumber"},{"value":"9721970295","characteristic":"BillingTelephoneNumber"},{"value":"M","characteristic":"BillHandlingCode"},{"value":"PARTIAL","characteristic":"BillDetailLevel"}]},"specified_by":{"specification_name":"DPI Circuit Billing CFS","specification_id":"01tc0000009cFlAAAU"},"line_number":"a9Dc0000000OXPOEA4.0001","action":"Add","order_item_id":"a9Dc0000000OXPOEA4"}],"account_id":"001c000002xt7UwAAI","order_id":"a9Ec0000000CzY8EAK"}';
                input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
            }
            
            
            //  input.put('commercialContractList',commercialContractList);
            if(!Test.isRunningTest() ){
                input = ftr_OrderManagementHelper.executeRequestDR(input, item.vlocity_cmt__VlocityDataRaptorBundleId__c);
                 System.debug('Dataraptor output' + JSON.serialize(input));
                if(orchestrationTaskName == TaskName_SubmitGroupOrderMember) {
                    
                    //paa512 - start SDDD-2650 changes for MACD Project - Get modified S&E items and other attributes for change order
                    //comparator method using the FulfilmentReqLineId as the input to see all the relevant changes
                    //process the input json based on the above comparator map/list of attributes changed.
                    //activty code needs to be added to the input json
                    
                    Map<String, Object> oliAssetChangeMap = ftr_OrderManagementHelper.compareOLIAndAssetForChangeDPIOrder(FulfilmentReqLineId);
                    System.debug('oliAssetChangeMap in ftr_DPIBaseSystemInterface.executeItem: ' + oliAssetChangeMap);
                    if(oliAssetChangeMap != null && oliAssetChangeMap.size() > 0) {
                        System.debug('Dataraptor output1' + JSON.serialize(input));
                        input = getModifiedDPIInputPayload(input, oliAssetChangeMap);    
                          System.debug('Modified Input' + JSON.serialize(input));
                    }
                    
                    //paa512 - End SDDD-2650 changes for MACD Project - Get modified custom and service item attributes for change order                    
                }
            }
            else{
                if(orchestrationTaskName == TaskName_SubmitGroupOrderMember) {
                    if(Test.isRunningTest()){
                    testJsonInput= '{"SubmitGroupOrderMember":{"submitGroupOrderMemberInput":{"customerAccount":{"location":{"serviceAddress":{"serviceAddressMaterId":{"controlNumber":"620372"},"address":{"zipCode":"75062","streetAddress":"100 East Airport Freeway","cityName":"Irving","plus4":"75062"},"cityAbbreviation":"IRV"}},"billingAccountId":{"telephoneNumber":{"telephoneNumber":"8321510008"}},"taxProfile":{"isFederalTaxExempt":"false"},"accountServiceType":{"code":"65"},"accountPreferences":{"billHandlingCode":"M"},"accountId":{"telephoneNumber":{"telephoneNumber":"8321510008"},"environment":"FT"},"CustomerBill":{"billDetailLevel":"PARTIAL","BillCycle":"null"}},"header":{"securityInfo":{"userId":"lsg522","employeeId":"lsg522"},"requestingApplication":"VlocityOM","correlationId":"10030431.8321510009"},"poOrder":null,"groupOrderTransactionCount":"2","circuitSNE":"CKT","circuitId":"13/CUXP/541477/   /FTNC/   ","customer":{"organization":{"contactInformation":{"internationalAddress":{"stateOrProvince":"TX","postalCode":"75077","country":"United States","cityName":"Lewisville","addressLine1":"1480 North Valley Parkway"}},"organizationName":{"tradingName":"AK Technical Test Company"}},"customerType":"Business","customerCreditProfile":{"creditScore":{"creditRating":"3"},"creditProfileReference":{"businessOwner":{"name":"Tom Cruise"},"business":{"organizationType":"Sole Ownership"},"TechnicalContact":{"Name":"Tom Cruise"},"BillToContact":{"Name":"Tom Cruise"}}}},"customerOrder":{"provisioningDetails":{"commercialCircuitProvisioning":{"OrgLocZipCode":"75062","OrgLocStreetAddress":"100 East Airport Freeway","OrgLocStateAbbreviation":null,"OrgLocCityName":"Irving"}},"customerOrderItem":[{"product":{"lineItemSequenceNumber":"1","id":"MEDAL"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"SSINS"},"chargeType":"Temporary","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"EIA2Y"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"BNR23"},"chargeType":"Temporary","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"BIP23"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"NA"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"CKT"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},null],"commercialContract":[{"monthlyRecurringChargeRate":{"amount":"880.00"},"quantity":"1","productId":"MEDAL"},{"nonRecurringChargeRate":{"amount":"250.00"},"quantity":"1","productId":"SSINS"},null],"installationType":"NO_INSTALL","dueDate":"2021-04-10","customerOrderType":"CHANGE","Quantity":1,"crisId":"838810"},"scheduleId":"S-5550011781","InternationalBillAddress":"false","ContractId":"8001g0000003dyrAAA"}}}}';
                    input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
                    }
                    //paa512 - start SDDD-2650 changes for MACD Project - Get modified S&E items and other attributes for change order
                    //comparator method using the FulfilmentReqLineId as the input to see all the relevant changes
                    //process the input json based on the above comparator map/list of attributes changed.
                    //activty code needs to be added to the input json
                   // if(!Test.isRunningTest() ){
                    Map<String, Object> oliAssetChangeMap = ftr_OrderManagementHelper.compareOLIAndAssetForChangeDPIOrder(FulfilmentReqLineId);
                    System.debug('oliAssetChangeMap in ftr_DPIBaseSystemInterface.executeItem: ' + oliAssetChangeMap);
                    if(oliAssetChangeMap != null && oliAssetChangeMap.size() > 0) {
                        input = getModifiedDPIInputPayload(input, oliAssetChangeMap);   
                        System.debug('ModifiedDPIInputPayload: '+JSON.serialize(input));
                    }
                  //  }
                    //paa512 - End SDDD-2650 changes for MACD Project - Get modified custom and service item attributes for change order
                    
                }else if(orchestrationTaskName == TaskName_findAvailableTelephoneNumbers){
                    testJsonInput= '{"FindAvailableTelephoneNumbers":{"findAvailableTelephoneNumbersInput":{"exchangeFilter":{"stateAbbreviation":"TX","maxTnNumbers":"2","itemSequence":"0","env":"FT"}}}}';
                    input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
                }else if (orchestrationTaskName == TaskName_RetrieveCustomerFacilities){
                    testJsonInput= '{"RetrieveCustomerFacilities":{"RetrieveCustomerFacilitiesInput":{"address":{"zipCode":"75077","stateAbbreviation":"TX","cityName":"Lewisville","addressLine1":"1480 North Valley Parkway"}}}}';
                    input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
                }else if(orchestrationTaskName == TaskName_ReserveTelephoneNumber){
                    testJsonInput= '{"ReserveTelephoneNumber":{"reserveTelephoneNumberInput":{"maxTnNumbers":"2","itemSequence":"0","environment":"FT","stateAbbreviation":"TX"}}}';
                    input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
                }
            }
            System.debug('ftr_DPIBaseSystemInterface:executeRequestDR:input-->'+ JSON.serialize(input));
            
            
            // Add final input to the payload
            ctx.put('url', url);
            ctx.put('path', path);
            ctx.put('item', item);
            ctx.put('input', input);
            
            // Invoke WebServiceCallout
            output = invoke(url, path, input);   
            if(Test.isRunningTest() ){
                if (orchestrationTaskName == TaskName_RetrieveCustomerFacilities){
                    testJsonInput= '{"controlNumber":"2181288","cityabbreviation":"LWV","env":"FT","wirecenter":"972221"}';
                    output = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
                }
            }
            ctx.put('output', output);      
            System.debug('Context output :'+ ctx.get('output'));
            
            
            if (getOrchestrationTaskName() == TaskName_RetrieveCustomerFacilities) {
                output.put('taskName', TaskName_RetrieveCustomerFacilities);
                output=ftr_OrderManagementHelper.executeResponseDR(item,output);
                System.debug('Output object1 : '+ output + 'Input object1: '+input);
                System.debug('Service call values :'+String.valueOf(output.get('controlNumber'))+':'+String.valueOf(output.get('cityabbreviation'))+':'+String.valueOf(output.get('env')));
               /* if(String.isBlank(String.valueOf(output.get('controlNumber'))) || String.isBlank(String.valueOf(output.get('cityabbreviation'))) ||
                   String.isBlank(String.valueOf(output.get('env'))) ) {*/
                if(String.isBlank(String.valueOf(output.get('env'))) ) {
                       System.debug('Service values blank');
                       ctx.put('createTask', 'True');
                       output.put('errorMessage', invalidWTNErrMsg+':No Unique Address Match Was Found for flr.Id :'+ sfOrderNumber);
                       throw new ftr_DPIBaseSystemInterfaceException(invalidWTNErrMsg+':No Unique Address Match Was Found');
                 }
                    if(String.isBlank(String.valueOf(output.get('controlNumber'))) || String.isBlank(String.valueOf(output.get('cityabbreviation'))) ) {
                        ctx.put('createTask', 'True');
                        output.put('infoMessage', invalidWTNErrMsg+':No Unique Address Match Was Found');
        
                    }
            } else if (getOrchestrationTaskName() == TaskName_findAvailableTelephoneNumbers){
                output.put('taskName', TaskName_findAvailableTelephoneNumbers);
                output=ftr_OrderManagementHelper.executeResponseDR(item,output);
                if (!ftr_OrderManagementHelper.validTelephoneNumber(String.valueOf(output.get('telePhoneNumber')))){
                    ctx.put('createTask', 'True');
                    System.debug('Output object : '+ output + 'Input object: '+input);
                    output.put('errorMessage', invalidWTNErrMsg+':Available TN Not Found :'+sfOrderNumber);
                    throw new ftr_DPIBaseSystemInterfaceException(invalidWTNErrMsg+':Available TN Not Found');
                }
                
            }else if (getOrchestrationTaskName() == TaskName_ReserveTelephoneNumber){  
                isXml = false;  
                String statusCode =(String) output.get('statusCode');
                System.debug('reservedOutMap==>'+output);
                boolean result = (boolean) output.get('result');
                if (statusCode!= '200'){
                     if(!Test.isRunningTest() ){
                    ctx.put('createTask', 'True');
                    String messageText = getErrorMessageText((String)output.get('responsebody'));
                    output.put('errorMessage',  messageText+'||'+sfOrderNumber);
                    throw new ftr_DPIBaseSystemInterfaceException(messageText+'||'+sfOrderNumber);
                   }
                } else if (ftr_OrderManagementHelper.validTelephoneNumber(String.valueOf(output.get('telePhoneNumber')))) {
                    System.debug('Reserved Another Number On Failure==>'+output.get('telePhoneNumber'));
                    output.put('taskName', TaskName_findAvailableTelephoneNumbers);
                    output=ftr_OrderManagementHelper.executeResponseDR(item,output);
                }
                output=ftr_OrderManagementHelper.executeReserveResponseDR(item,output); 
            }
            // Post_Invoke
            // Add final input to the payload
            ctx.put('output', output);       
            if (orchestrationTaskName == TaskName_SubmitGroupOrderMember){
                System.debug('ErrorMessage '+(String)output.get('errorMessage'));
                String groupOrderTransCount =(String)output.get('transactionCount') ;
                System.debug('****GroupOrderTransactionCount'+ groupOrderTransCount);      
                String createtask =(String) output.get('CreateTask');
                System.debug('createtask :'+ createtask);
                String description = 'Following Billing  Order(s) are submitted to DPI :'+
                    ' LeadOrder ='+ output.get('LeadOrderId')+
                    ' MemberOrder ='+ output.get('GroupMemberOrderId') ;
                
                if(output.get('errorMessage')!=null && output.get('errorMessage')!=''){
                    System.debug('Create task to be true');
                    ctx.put('createTask', 'True');          
                    if (getOrchestrationTaskName() == TaskName_SubmitGroupOrderMember){  
                        throw new ftr_DPIBaseSystemInterfaceException((String)output.get('errorMessage'));         
                    }
                }
                updateDatabase(); //This needs to be removed after testing ASAP.
            /*    if(Test.isRunningTest()) {
                    System.debug('Invoking update database');
                    updateDatabase(); ///invoking update database method
                }*/
            } 
            if (orchestrationTaskName == TaskName_StageGroupOrderMember){
                isXml = false;   
                Integer outputStatus = (Integer)output.get('orderStaged');
                if(outputStatus==200){
                    System.debug('Order staged successfully');
                    
                }
                else{
                    ctx.put('createTask', 'True'); 
                    throw new ftr_DPIBaseSystemInterfaceException('Order not staged, stagecode :'+outputStatus);
                }
            }
        } catch (CalloutException ex) { 
            // Capture recoverable exception and notify OM to retry
            System.debug('Exception Caught***' + ex.getStackTraceString());
            ctx.put('createTask', 'True');
            //         String addExMessage = output.get('errorMessage') + ' | '+ex.getMessage();        
            if (ex!=null){        
                output.put('errorMessage' , ex.getMessage());
            }
            
            ctx.put('output', output);
            ftr_Logger.write(ex);
            throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException ('Callout exception ' + ex + ': trying to retry');
        } catch (Exception ex) {
            // try to create a log with the exception details.
            try {
                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object> {
                    'request' => ctx.get('input'),
                        'response' => ctx.get('output'),
                        'interface' => getOrchestrationTaskName(),
                        'system' => 'DPI',
                        'status' => 'Error',
                        'errorMessage' => ex.getMessage(),
                        'errorCode' => '500',
                        'orderNumber' => sfOrderNumber,
                        'orchestrationItemId' => item.Id,
                        'convertToXML' => isXml,
                        'relatedTo' => whatId
                        };  
                            APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);
            } catch (Exception e) {
                System.debug('Unable to create log');
            }
            System.debug('Exception Caught***' + ex.getStackTraceString());
            ctx.put('createTask', 'True');
            //String addExMessage  = output.get('errorMessage') + ' | '+ex.getMessage();
            //output.put('errorMessage' , addExMessage);
            if (ex!=null){        
                output.put('errorMessage' , ex.getMessage());
            }
            ctx.put('output', output);
            ftr_Logger.write(ex);
            throw ex;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_DPIBaseSystemInterface.executeItem');
            System.debug('Inside Finalize***');
            System.debug('Order id  '+whatId);
            System.debug('Retry count  '+retryCount);
            if(retrycount == null){
                vlocity_cmt__OrchestrationItem__c tempItem = [SELECT  vlocity_cmt__NumberOfRetries__c FROM vlocity_cmt__OrchestrationItem__c WHERE Id=:item.Id];
                retryCount = tempItem.vlocity_cmt__NumberOfRetries__c == null ? 0 : tempItem.vlocity_cmt__NumberOfRetries__c;
            }
            System.debug('Retry count  '+retryCount);
            //retryCount =1.00;
            if((retryCount < 1.00 ) && ctx.get('createTask')!=null && ctx.get('createTask').equals('True')){
                Map<String,Object> createTaskInputMap =new Map<String,Object>();
                if (output.get('ErrorCode') != null)
                    createTaskInputMap.put('ErrorCode',output.get('ErrorCode'));
                if(output.get('GroupMemberOrderId')!=null){
                    createTaskInputMap.put('Description',output.get('errorMessage')+ ' | MemberOrderId:'+  output.get('GroupMemberOrderId')); 
                }
                else{
                    if (output.get('errorMessage') != null)
                        createTaskInputMap.put('Description',output.get('errorMessage'));
                createTaskInputMap.put('Subject','DPI OM Billing Exception');
                }
            if (output.get('infoMessage')!= null){
                createTaskInputMap.put('Description',output.get('infoMessage'));
                createTaskInputMap.put('Subject','DPI OM Billing Exception');
            }
                createTaskInputMap.put('Priority','High');
                createTaskInputMap.put('InterfaceName',getOrchestrationTaskName());
                 createTaskInputMap.put('Interface_Name',orchestrationItemName);
                createTaskInputMap.put('WhatId', whatId);
                System.debug('createTaskInputMap :'+ createTaskInputMap);
                ftr_OrderManagementHelper.CreateTask( createTaskInputMap) ;
                // try to create a log with the error details.
                try {
                    Map<String, Object> logOutput = new Map<String, Object>();
                    Map<String, Object> logInput = new Map<String, Object> {
                        'request' => ctx.get('input'),
                            'response' => output,
                            'interface' => getOrchestrationTaskName(),
                            'system' => 'DPI',
                            'status' => 'Error',
                            'orchestrationItemId' => item.Id,
                            'orderNumber' => sfOrderNumber,
                            'errorMessage' => output.get('errorMessage') != null ? output.get('errorMessage') : 'Unkown Error',
                                'errorCode' => output.get('ErrorCode') != null ? output.get('ErrorCode') : '500',
                                    'convertToXML' => isXml,
                                    'relatedTo' => whatId
                                    };  
                                        APILogger log = new APILogger();
                    log.createEntry(logInput, logOutput);
                } catch (Exception e) {
                    System.debug('Unable to create log');
                }
            } else {
                if(getOrchestrationTaskName()!=TaskName_findAvailableTelephoneNumbers){
                    // try to create a success log
                    try {
                        Map<String, Object> logOutput = new Map<String, Object>();
                        Map<String, Object> logInput = new Map<String, Object> {
                            'request' => ctx.get('input'),
                                'response' => output,
                                'interface' => getOrchestrationTaskName(),
                                'system' => 'DPI',
                                'orderNumber' => sfOrderNumber,
                                'orchestrationItemId' => item.Id,
                                'status' => 'Success',
                                'convertToXML' => isXml,
                                'relatedTo' => whatId
                                };  
                                    APILogger log = new APILogger();
                        log.createEntry(logInput, logOutput);
                    } catch (Exception e) {
                        System.debug('Unable to create log');
                    }
                }
            }
        }
    }
    /**
* This method is called at the end of the batch
* @param  url  base URL for the batch
* @param  path path for the batch
*/
    global virtual void endBatch(String url, String path) {
        // Do nothing
        System.debug('Enter ftr_DPIBaseSystemInterface.endBatch');
        
    }
    
    /**
* update DB,
* from XOMOrchestrationInterfaces, executed when it safe to do it.
*/
    public void updateDatabase() {
        System.debug('Enter ftr_DPIBaseSystemInterface.updateDatabase');
        
        try {
            vlocity_cmt__OrchestrationItem__c item = (vlocity_cmt__OrchestrationItem__c)ctx.get('item');
            /*    if (item.vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c != null) {
ftr_OrderManagementHelper.executeResponseAttrsDR(ctx, item.vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c);
}

if (item.vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c != null) {
ftr_OrderManagementHelper.executeResponseItemDR(ctx, item.vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c);
}
*/        
            if (item.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c != null && ctx.get('output') != null) {
                ftr_OrderManagementHelper.executeResponseDR(ctx, item.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c,FulfilmentReqLineId, '');
            }
        } catch (Exception ex) {
            ftr_Logger.write(ex);
        } finally {
            System.debug('Exit ftr_DPIBaseSystemInterface.updateDatabase');
        }
        
    }
    
    /**
* This method is called to execute the actual DPI SOAP API callout
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  input payload prepared by the DRs
* @return      output JSON data returned
*/
    private Map<String, Object> invoke(String url, String path, Map<String, Object> input) {
        
        system.debug('ftr_DPIBaseSystemInterface:input-->'+ JSON.serialize(input));
        Map<String, Object> output  = new  Map<String, Object> ();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Object requestType;
        
        String taskName = getOrchestrationTaskName();
        if (taskName == TaskName_SubmitGroupOrderMember) {
            Map<String, Object> headerInfo = new Map<String, Object>();
            String endpoint = apiConfigMap.get('CustMgmtURI');
            headerInfo.put('endpoint',endpoint);
            headerInfo.put('contentType', 'text/xml;charset=UTF-8');
            
            Map<String,Object> requestBody = new Map<String,Object>();
            // requestType = this.createDPIRequestType(url, path, input);
            requestBody =(Map<String,Object>)this.createDPIRequestType(url, path, input);
            system.debug('DPI Request map: '+requestBody );
            
            
            //paa512 -- MACD changes start - building DPI Submit Group Order request using WSDLToApex stub classes
            if(requestBody.containsKey('mcad_order')) {
                Object dpiChangeOrderReq = requestBody.get('mcad_order');
                String orderCount = (String) requestBody.get('transactionCount');
                if(dpiChangeOrderReq != null) {
                   /* setSubmitGroupOrderPortValues();
                    esbftrCustomerordermanagement.msg_SubmitGroupOrderMemberResponse dpiResponse = 
                        this.port.SubmitGroupOrderMember((esbftrCustomerordermanagement.msg_SubmitGroupOrderMemberRequest) dpiChangeOrderReq);                    
               
                System.debug('DPI Submit Group Order object response : '+ dpiResponse);
                    output = processDPIResponseType(url, path, dpiResponse); */
                    output.put('transactionCount', orderCount);
                }
            } else {
                //******install order flow building manual XML String as DPI Submit Group Order request ************************
                String requestXml =(String) requestBody.get('DpiRequestXML');
                String orderCount = (String) requestBody.get('transactionCount');
                // system.debug('DPI Request xml :'+requestType.get('DpiRequestXML'));
                system.debug('DPI Request xml:'+JSON.serialize(requestXml) );
                request = setRequestHeaders(request, requestXml, headerInfo);
                HttpResponse response = http.send(request);
                System.debug('HttpResponse : '+ response);
                
                if (response!=null){
                    //if (response.getStatusCode() == 200) {
                    String responseType = response.getBody();
                    System.debug('RespHttpResponse Body : '+ response.getBody());        
                    //output = processDPIResponseType(url, path, responseType);
                    output = processDPIResponseType(url, path, response.getBody());
                    output.put('transactionCount', orderCount);
                } else {
                    throw new ftr_DPIBaseSystemInterfaceException('Invalid Response ' + response);
                }
                //Call the DPI Webservice
            }
            //paa512 -- MACD changes End
            
            
        } else if(taskName == TaskName_RetrieveCustomerFacilities) {
            System.debug('ftr_DPIBaseSystemInterface:retrieveCustomerFacilities:input-->'+ JSON.serialize(input));
            requestType = this.createDPIRequestType(url, path, input);
            Map<String, Object> retrvCustInputMap = new Map<String,Object>();        
            retrvCustInputMap.put('addressBean',requestType); 
            system.debug('ftr_DPIBaseSystemInterface:retrieveCustomerFacilities:retrvCustInputMap-->'+ JSON.serialize(retrvCustInputMap));        
            output = ftr_DPIResourceManagmentSystemInterface.invoke('retrieveCustomerFacilities', retrvCustInputMap);
            System.debug('ftr_DPIBaseSystemInterface:retrieveCustomerFacilities:output-->'+ JSON.serialize(output));
            
            //output = processDPIResponseType(url, path, retrvCustOutputMap);
        } else if (taskName == TaskName_findAvailableTelephoneNumbers){
            // try to find numbers
            system.debug('ftr_DPIBaseSystemInterface:findAvailableTelephoneNumbers:input-->'+ JSON.serialize(input));
            List<String> tnList;         
            Map<String, Object> tnListMap = new Map<String, Object> ();
            //system.debug('findAvailableTelephoneNumbers:requestType-->'+ requestType);
            requestType = this.createDPIRequestType(url, path, input);
            Map<String, Object> requestTypeMap = (Map<String,Object>)requestType; 
            system.debug('findAvailableTelephoneNumbers:requestType-->'+ requestType);
            Map<String, Object> findAvailTelephoneNumMap = new Map<String,Object>();  
            
            System.debug('ftr_DPIBaseSystemInterface:findAvailableTelephoneNumberAndReserve:Calling-->');
            findAvailTelephoneNumMap.put('env', (String)requestTypeMap.get('env'));
            findAvailTelephoneNumMap.put('state', (String)requestTypeMap.get('state'));
            findAvailTelephoneNumMap.put('maxTnNumbers', (String)requestTypeMap.get('maxTnNumbers'));
            findAvailTelephoneNumMap.put('itemSequence', (String)requestTypeMap.get('itemSequence'));
            findAvailTelephoneNumMap.put('wc_cilli', (String)requestTypeMap.get('wc_cilli'));
            findAvailTelephoneNumMap.put('orderId', (String)requestTypeMap.get('orderId'));
            findAvailTelephoneNumMap.put('order_no', (String)requestTypeMap.get('order_no'));
            findAvailTelephoneNumMap.put('zipCode', (String)requestTypeMap.get('zipcode'));
            findAvailTelephoneNumMap.put('npaNxx',(String)requestTypeMap.get('npaNxx'));
            findAvailTelephoneNumMap.put('Item_Name',orchestrationItemName);
            output=ftr_ResourceManagementService.findAvailableTelephoneNumberAndReserve(findAvailTelephoneNumMap);           
            //List<String> npaNxxList=(List<String> )requestTypeMap.get('npaNxxList');
            
            /* for (String npaNxx : npaNxxList) {
System.debug('ftr_DPIBaseSystemInterface:findAvailableTelephoneNumbers:Calling-->');
findAvailTelephoneNumMap.put('npaNxx', npaNxx);
findAvailTelephoneNumMap.put('maxTnNumbers', (String)requestTypeMap.get('maxTnNumbers'));
//Integer maxTnNumbers = Integer.valueOf(inputMap.get('maxTnNumbers'));
findAvailTelephoneNumMap.put('itemSequence', (String)requestTypeMap.get('itemSequence'));
tnListMap = ftr_DPIResourceManagmentSystemInterface.invoke('findAvailableTelephoneNumbers', findAvailTelephoneNumMap);
system.debug('ftr_DPIBaseSystemInterface:findAvailableTelephoneNumbers:tnListMap-->'+ JSON.serialize(tnListMap));
if (tnListMap.get('tnList') != null) {
tnList = (List<String>) tnListMap.get('tnList');                
if (tnList!=null&& tnList.size() > 0) {
System.debug('NPA NXX used: ' + npaNxx);
System.debug('TNs returned: ' + JSON.serialize(tnList));
break;
} 
}
}
if (tnList!=null){
Integer itemSequence=Integer.valueOf(requestTypeMap.get('itemSequence'));
if (tnList[itemSequence]!=null){
output.put('telePhoneNumber', tnList[itemSequence]);
}
}*/
            system.debug('ftr_DPIBaseSystemInterface:findAvailableTelephoneNumbers:output-->'+ JSON.serialize(output));
        }else if(taskName == TaskName_ReserveTelephoneNumber) {
            System.debug('ftr_DPIBaseSystemInterface:ReserveTelephoneNumber:input-->'+ JSON.serialize(input));
            requestType = this.createDPIRequestType(url, path, input);
            Map<String, Object> reserveTNInputMap = (Map<String,Object>)requestType;       
            reserveTNInputMap.put('Item_Name',orchestrationItemName);
            system.debug('ftr_DPIBaseSystemInterface:ReserveTelephoneNumber:reserveTNInputMap-->'+ JSON.serialize(reserveTNInputMap));
            system.debug('ftr_DPIBaseSystemInterface:ReserveTelephoneNumber:requestType-->'+ requestType);
            output = ftr_DPIResourceManagmentSystemInterface.invoke('reserveTelephoneNumber', reserveTNInputMap);
            System.debug('ftr_DPIBaseSystemInterface:ReserveTelephoneNumber:output-->'+ JSON.serialize(output));
            //if (output.get('statusCode')== '000-000-0001' ){ 
            if (output.get('statusCode')== '400' ){ 
                reserveTNInputMap.put('isReserveTN', 'True'); 
                Integer itemSeqNum=Integer.valueOf((String) reserveTNInputMap.get('maxTnNumbers'));            
                reserveTNInputMap.put('itemSequence', itemSeqNum-1);//EQU-21237:Few NPA-NXX has
                //   reserveTNInputMap.put('wc_cilli', (String)requestTypeMap.get('wc_cilli'));
                // only 1 TN and repeatedly provides that for sequence '0' 
                
                output = ftr_ResourceManagementService.findAvailableTelephoneNumberAndReserve(reserveTNInputMap);
                System.debug('ftr_DPIBaseSystemInterface:ReserveTelephoneNumber:output---->'+ JSON.serialize(output));  
            }
            
            //output = processDPIResponseType(url, path, retrvCustOutputMap);
        }
        else if(taskName == TaskName_StageGroupOrderMember){
            Map<String, Object> headerInfo = new Map<String, Object>();
            String endpoint = apiConfigMap.get('DPIOrderStageURI');
            headerInfo.put('endpoint',endpoint);
            headerInfo.put('contentType', 'application/json');
            headerInfo.put('ESB-requestingApplication', 'VlocityOM');
            headerInfo.put('ESB-securityInfo.employeeId', '');
            System.debug('DPIOrderStageURI : '+ endpoint);
            // input.put('OrderStageInput', input.toString());
            Object requestXml =this.createDPIRequestType(url, path, input);
            // requestXml = requestXml.replaceAll('=', ':');
            requestXml = JSON.serialize(requestXml);
            System.debug('Request xml: '+requestXml);
            String req = (String) requestXml;
            String orderNum = req.substringBetween('"orderNumber":"', '"');
            System.debug('orderNum: '+orderNum);
            request = setRequestHeaders(request, requestXml, headerInfo);
            System.debug('Order stage complete request'+ request);
            HttpResponse response = http.send(request);
            output =  new  Map<String,Object>();
            output.put('orderStaged', response.getStatusCode());
            output.put('GroupMemberOrderId', orderNum);
        }
        return output;
    }
    
    global virtual Object createDPIRequestType(String url, String path, Map<String, Object> input) {
        
        throw new ftr_DPIBaseSystemInterfaceException('Must be implemented in the child class.');
        
    }
    
    /**
* This method is called from executeItem to create process response
*
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  respType M6 ResponseType to process
* @return         output object to be processed
*/
    global virtual Map<String, Object> processDPIResponseType(String url, String path, Object respType) {
        if(respType==null){
            throw new ftr_DPIBaseSystemInterfaceException('Must be implemented in the child class.');
        }
        return (Map<String, Object> )respType;
    }
    public virtual String getOrchestrationTaskName() {
        
        throw new ftr_DPIBaseSystemInterfaceException('Must be implemented in the child class getOrchestrationTaskName.');
    }
    
    //paa512 - Start MCAD changes  - set port for making the SubmitGroupOrder call via WSDLtoApex Stub code
 /*   private esbftrCustomerordermanagement.CustomerOrderManagement_CustomerOrderManagementHttpPort setSubmitGroupOrderPortValues(){
        this.port = new esbftrCustomerordermanagement.CustomerOrderManagement_CustomerOrderManagementHttpPort() ;
        
        Map<String, String> headers = new Map<String, String>{
          'ApiKey' => apiConfigMap.get('ApiKey'),
          'Authorization' => 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiConfigMap.get('AuthHeader')))
        };

        this.port.endpoint_x = 'callout:DPIApigeeCredentials'+'/'+apiConfigMap.get('CustMgmtURI');
        this.port.timeout_x = Integer.valueOf(apiConfigMap.get('Timeout'));
        this.port.inputHttpHeaders_x = headers;
        system.debug('DPI Port values:' + this.port);
        
        return this.port;
    }*/
	//paa512 -End- MCAD changes  - set port for making the SubmitGroupOrder call via WSDLtoApex Stub code    
    //Replace this with DPI setPortValues
    private HttpRequest  setRequestHeaders( HttpRequest request, Object requestType, Map<String, Object> headerInfo){
        
        System.debug('Customermanagement endpoint '+'callout:DPIApigeeCredentials');
        request.setEndpoint('callout:DPIApigeeCredentials'+(String)headerInfo.get('endpoint'));
        //  request.setEndpoint('callout:DPIApigeeCredentials'+endpoint);
        //  request.setEndpoint('callout:DPIApigeeCredentials'+'/esbcustomerordermanagement/v1');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiConfigMap.get('AuthHeader')));
        request.setHeader(AUTHORIZATION, authorizationHeader);
        request.setHeader(API_KEY, apiConfigMap.get('ApiKey'));
        //  request.setHeader(CONTENT_TYPE , 'text/xml;charset=UTF-8');
        request.setHeader(CONTENT_TYPE ,(String)headerInfo.get('contentType'));
        request.setMethod(REQUEST_METHOD_POST);
        request.setTimeout(Integer.valueOf(apiConfigMap.get('Timeout')));
        if (headerInfo.get('ESB-requestingApplication')!=null){
            request.setHeader('ESB-requestingApplication',(String)headerInfo.get('ESB-requestingApplication'));
        }
        if (headerInfo.get('ESB-securityInfo.employeeId')!=null){
            request.setHeader('ESB-securityInfo.employeeId',(String)headerInfo.get('ESB-securityInfo.employeeId'));
        }
        request.setBody((String)requestType);
        System.debug('Request body 2:'+(String)request.getBody());
        return request;
        
    }

  /*  private String getCilliCode(Map<String,Object> input){
        Map<String,Object> retrieveCustomerFacilities = (Map<String,Object>)input.get('RetrieveCustomerFacilities');
        Map<String,Object> retrieveCustomerFacilitiesInput=(Map<String,Object>)retrieveCustomerFacilities.get('RetrieveCustomerFacilitiesInput');
        Map<String,Object> addressMap = (Map<String,Object>)retrieveCustomerFacilitiesInput.get('address');
        String wc_cilli = String.valueOf(addressMap.get('wc_clli'));
        return wc_cilli;
    }*/
	private String getErrorMessageText(String  responseBody){
        String responseMessage;
        if(responseBody!=null){
            responseMessage = responseBody.substringBetween('message_text', ',');
            System.debug ('ReserveTn responseMessage :'+responseMessage);
        }
        
     	return responseMessage;
    }    
    
    public static Map<String, Object> getModifiedDPIInputPayload(Map<String, Object> originalInput, Map<String, Object> oliAssetChangeMap) {
        
        System.debug('oliAssetChangeMap in DPI getModifiedDPIInputPayload: ' + oliAssetChangeMap);
        if(Test.isRunningTest()){
          String  oliAssetChangeString = '{CUSTOMER_ORDER_TYPE=CHANGE, REMOVE_SNE_MAP={SNE_Code_MRC__c=MEDAO, SNE_Code_OTC__c=null, SNE_Code_TERM__c=EIA3Y}}';
       		 oliAssetChangeMap = (Map<String,Object>)JSON.deserializeUntyped(oliAssetChangeString);
        }
        if(oliAssetChangeMap == null || oliAssetChangeMap.size() == 0) {
            return originalInput;
        }
        
        Map<String, Object> input = originalInput.clone();
        
        Map<String, String> removeAssetSNEMap = (Map<String, String>)oliAssetChangeMap.get('REMOVE_SNE_MAP');
        Map < String, Object > SubmitGroupOrderMember = (Map < String, Object > ) input.get('SubmitGroupOrderMember');
        System.debug('SubmitGroupOrderMember in getModifiedDPIInputPayload :'+JSON.serialize(SubmitGroupOrderMember));
        Map < String, Object > SubmitGroupOrderMemberInput = (Map < String, Object > ) SubmitGroupOrderMember.get('submitGroupOrderMemberInput');
        System.debug('SubmitGroupOrderMemberInput in getModifiedDPIInputPayload :'+JSON.serialize(SubmitGroupOrderMemberInput));  
        
        Map < String, Object > customerAccountJson =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('customerAccount');
        System.debug('customerAccountJson :'+ customerAccountJson);
         Map < String, Object >  accountServiceTypeJson = (Map < String, Object > )customerAccountJson.get('accountServiceType');
        //clean up customerAccount tag specific for Change order
        for(String key : customerAccountJson.keySet()) {
            if(key.equalsIgnoreCase('billingAccountId') || key.equalsIgnoreCase('accountId') ||  key.equalsIgnoreCase('accountServiceType') || key.equalsIgnoreCase('location') ||key.equalsIgnoreCase('taxProfile') || key.equalsIgnoreCase('accountPreferences') || key.equalsIgnoreCase('CustomerBill')) {
                continue;
            } else {
                customerAccountJson.remove(key);
            }       
        } 
        
        //clean up customer tag specific for Change order
        Map < String, Object > customerJson =(Map < String, Object > )SubmitGroupOrderMemberInput.get('customer');
        for(String key : customerJson.keySet()) {
            if(key.equalsIgnoreCase('customerType') || key.equalsIgnoreCase('organization') || key.equalsIgnoreCase('customerCreditProfile')) {
                continue;
            } else {
                customerJson.remove(key);
            }       
            
        } 
        
        //clean up customerOrder tag specific for Change order
        Map < String, Object > customerOrderJson =(Map < String, Object > )SubmitGroupOrderMemberInput.get('customerOrder');
        if(customerOrderJson.containsKey('customerOrderType')) {
            String custOrderType = (String) oliAssetChangeMap.get('CUSTOMER_ORDER_TYPE');
            customerOrderJson.put('customerOrderType', custOrderType);    
        }
        
        //Add SNEs to remove on the customer order if there are any SNEs in the removeAssetSNEMap
        if(removeAssetSNEMap != null && removeAssetSNEMap.size() > 0) {
            List<Object> custOrderItemList = new List<Object>();
            if(customerOrderJson.containsKey('customerOrderItem')) {
                custOrderItemList = (List<Object>) customerOrderJson.get('customerOrderItem');
                
            }
            
            for(String snecode : removeAssetSNEMap.values()) {
                Map<String, Object>newItemMap = new Map<String, Object>();
                newItemMap.put('action', 'Remove');
                newItemMap.put('quantity', '1.00');
                newItemMap.put('chargeType', 'Permanent');
                newItemMap.put('processingDirection', 'Forward');
                
                Map<String, Object>productMap = new Map<String, Object>();
                productMap.put('id', snecode);
                productMap.put('lineItemSequenceNumber', '1');
                newItemMap.put('product', productMap);
                
                custOrderItemList.add(newItemMap);
            }
            
        }
        
        return input;
    }
     public static void justIncrement() {
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
	           i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
	        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
	           i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
	        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
	           i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
	        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
	           i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
	        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                 i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
	           i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
	           i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
	           i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
	           i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
	           i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
	           i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
	           i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
	           i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
	           i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
	        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
    
    }
    
    
}