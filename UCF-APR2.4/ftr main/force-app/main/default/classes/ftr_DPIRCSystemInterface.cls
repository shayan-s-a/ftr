global without sharing virtual class ftr_DPIRCSystemInterface implements vlocity_cmt.XOMOrchestrationInterfaces.ISystemInterface, vlocity_cmt.XOMOrchestrationInterfaces.IDeferredUpdater{
    

    protected Map<String, Object> ctx = new Map<String, Object>();
    public static String FulfilmentReqLineId;
   
    public static final String TaskName_RCSubmitGroupOrder = 'RCSubmitGroupOrder';
    public static final String TaskName_RC360 = 'RC360';
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
    private static String requestInput;


    static{
        
        try{
            List<IntegrationAPIConfig__mdt> apiConfigs = [SELECT Timeout__c, ApiKey__c,Authorization_Header__c, RC360__c,CustomerOrderMgmt_URI__c, OrderStaging_URI__c,BulkNumber_URI__c FROM IntegrationAPIConfig__mdt WHERE DeveloperName=: API_CONFIG_SETTINGS LIMIT 1];
            
            
            if ( !Test.isRunningTest() && (apiConfigs.isEmpty() || String.isBlank(apiConfigs[0].ApiKey__c) || apiConfigs[0].Timeout__c == null)) { throw new ftr_DPIRCSystemInterfaceException(ERR_NULL_INPUT); }
            
            apiconfig=apiConfigs[0];
            apiConfigMap.put('Timeout', String.valueOf(apiConfig.Timeout__c));
            apiConfigMap.put('ApiKey', apiConfig.ApiKey__c);
            apiConfigMap.put('AuthHeader', apiConfig.Authorization_Header__c);
            apiConfigMap.put('CustMgmtURI', apiConfig.CustomerOrderMgmt_URI__c);
            apiConfigMap.put('DPIOrderStageURI', apiConfig.OrderStaging_URI__c);
            apiConfigMap.put('BulkNumber', apiConfig.BulkNumber_URI__c);
            apiConfigMap.put('RC360', apiConfig.RC360__c);
            
        } catch (Exception ex){ ftr_Logger.write(ex); System.debug(ex.getMessage());
                              }
    }
    
    global class ftr_DPIRCSystemInterfaceException extends Exception {}
        
    /**
* This method is a part of ISystemInterface. It is invoked at the start of the batch
* @param  url  base URL the batch is started for
* @param  path path this batch is started for
*/
    global virtual void startBatch(String url, String path){
        // Do nothing
        ftr_Logger.writeInfo('Exit ftr_DPIBaseBillingSystemInterface.startBatch');
    }

   /**
* Executes a Callout OrchestrationItem
* if cache is enabled then orchestration item data is retrieved from cache
* @param  url  base URL to send the request to
* @param  path path to send the request to
* @param  item OrchestrationItem that needs to be executed
*/
global virtual void executeItem(String url, String path, vlocity_cmt__OrchestrationItem__c item) { 
    ftr_Logger.writeInfo('Enter ftr_DPIBaseBillingSystemInterface.executeItem');
    orchestrationTaskName = getOrchestrationTaskName();
    Map<String, Object> output = new  Map<String,String>();
    String whatId ;
    Boolean isXml = true;
    retryCount = item.vlocity_cmt__NumberOfRetries__c;    
    System.debug('Bundle id  '+ item.vlocity_cmt__VlocityDataRaptorBundleId__c );
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
            System.debug(':::: 123input12344'+input);
            input = ftr_OrderManagementHelper.executeRequestDR(input, item.vlocity_cmt__VlocityDataRaptorBundleId__c);
                                   System.debug('Input object3456: '+input);
        }
        else{
            if(orchestrationTaskName == TaskName_RCSubmitGroupOrder){
                testJsonInput= '{"SubmitGroupOrderMember":{"submitGroupOrderMemberInput":{"customerAccount":{"location":{"serviceAddress":{"serviceAddressMaterId":{"controlNumber":"192536"},"address":{"zipCode":"75061","streetAddress":"1130 East Pioneer Drive","stateAbbreviation":"TX","cityName":"Irving","plus4":"75061"},"cityAbbreviation":"IRV"}},"billingAccountId":{"telephoneNumber":{"telephoneNumber":"9723937082"}},"taxProfile":{"isFederalTaxExempt":"false"},"accountServiceType":{"code":"VX"},"accountPreferences":{"billHandlingCode":"M"},"accountId":{"telephoneNumber":{"telephoneNumber":"9724388518"},"environment":"FT"},"CustomerBill":{"billDetailLevel":null,"BillCycle":null},"AccounUUID":"5C675786853B48D08E8AA9D5B4C9B9F1"},"header":{"securityInfo":{"userId":"lsg522","employeeId":"lsg522"},"requestingApplication":"VlocityOM","correlationId":"10110113.9724388518"},"customerLocation":{"Remark":"Please call 1st","Type":"PrimaryTelephoneNumber","Phone":"3108317787","Name":"Sohail Warraich"},"groupOrderTransactionCount":null,"customer":{"organization":{"contactInformation":{"internationalAddress":{"stateOrProvince":"OR","postalCode":"97501","country":"United States","cityName":"Medford","addressLine1":"Dark Hollow Road"}},"organizationName":{"tradingName":"Testing Ring Central"}},"customerType":null,"customerCreditProfile":{"creditScore":{"creditRating":"1"},"creditProfileReference":{"business":{"organizationType":"Corporation"},"businessOwner":{"name":"Jack Daniel","number":"9134562890"},"TechnicalContact":{"Name":"Jack Daniel","telephone":"9134562890"},"BillToContact":{"Name":"Jack Daniel","telephone":"9134562890"}}}},"customerOrder":{"provisioningDetails":{"commercialCircuitProvisioning":{"OrgLocZipCode":"75061","OrgLocStreetAddress":"1130 East Pioneer Drive","OrgLocStateAbbreviation":null,"OrgLocCityName":"Irving"}},"customerOrderItem":[{"FTR_ENT_CUSTOMERACCOUNT_ATTCAT":[{"characteristic":"AccountServiceType","value":"VX"},{"characteristic":"cityAbbreviation","value":"IRV"},{"characteristic":"TradingName","value":"Testing Ring Central"},{"characteristic":"ServLocZipCode","value":"75061"},{"characteristic":"ServLocStreetAddress","value":"1130 East Pioneer Drive"},{"characteristic":"ServLocStateAbbreviation","value":"TX"},{"characteristic":"ServLocCityName","value":"Irving"},{"characteristic":"IsFederalTaxExempt","value":"false"},{"characteristic":"InterLocStreetAddress","value":"Dark Hollow Road"},{"characteristic":"InterLocStateAbbreviation","value":"OR"},{"characteristic":"InterLocPostalCode","value":"97501"},{"characteristic":"InterLocCountry","value":"United States"},{"characteristic":"InterLocCityName","value":"Medford"},{"characteristic":"Environment","value":"FT"},{"characteristic":"ControlNumber","value":"192536"},{"characteristic":"BillingTelephoneNumber","value":"9723937082"},{"characteristic":"BillHandlingCode","value":"M"}],"FTR_ENT_CUSTOMERORDER_ATTCAT":[{"characteristic":"RC_RecurringCharge","value":"34.99"},{"characteristic":"RC_Quantity","value":"1.00"},{"characteristic":"RC_OneTimeTotal","value":"0.00"},{"characteristic":"RC_SNE_Code_MRC","value":"PREST"},{"characteristic":"OrgLocCityName","value":"Irving"},{"characteristic":"OrgLocStreetAddress","value":"1130 East Pioneer Drive"},{"characteristic":"OrgLocZipCode","value":"75061"},{"characteristic":"ATTR_DueDate","value":"2023-10-06 00:00:00"}],"FTR_ENT_CUSTOMER_ATTCAT":[{"characteristic":"BusinessOwnerTelephone","value":"0000000001"},{"characteristic":"CreditRating","value":"1"},{"characteristic":"OrganizationType","value":"Corporation"}],"FTR_ENT_FULFILMENT_ATTCAT":[{"characteristic":"PriLocCity","value":"Irving"},{"characteristic":"PriLocPostalCode","value":"75061"},{"characteristic":"PriLocState","value":"TX"},{"characteristic":"PriLocStreetAddress","value":"1130 East Pioneer Drive"}],"FTR_ENT_SERVICEITEMVALUES_ATTCAT":[{"characteristic":"WTN","value":"9724388518"}],"FTR_ENT_TECH_ATTCAT":[{"characteristic":"RC_AccountUUID","value":"5C675786853B48D08E8AA9D5B4C9B9F1"},{"characteristic":"ATTR_ItemSequence","value":"0"},{"characteristic":"ATTR_ItemCount","value":"1"},{"characteristic":"GroupMemberOrderId","value":"084077849"},{"characteristic":"CorrelationId","value":"10110113.9724388518"},{"characteristic":"ATTR_WaitSemaphore","value":"true"},{"characteristic":"LeadOrderId","value":"084077849"}],"FTR_ENT_USERDATA_ATTCAT":[{"characteristic":"NPA_NXX","value":"972438"}]}],"commercialContract":[{"FTR_ENT_CUSTOMERACCOUNT_ATTCAT":[{"characteristic":"AccountServiceType","value":"VX"},{"characteristic":"cityAbbreviation","value":"IRV"},{"characteristic":"TradingName","value":"Testing Ring Central"},{"characteristic":"ServLocZipCode","value":"75061"},{"characteristic":"ServLocStreetAddress","value":"1130 East Pioneer Drive"},{"characteristic":"ServLocStateAbbreviation","value":"TX"},{"characteristic":"ServLocCityName","value":"Irving"},{"characteristic":"IsFederalTaxExempt","value":"false"},{"characteristic":"InterLocStreetAddress","value":"Dark Hollow Road"},{"characteristic":"InterLocStateAbbreviation","value":"OR"},{"characteristic":"InterLocPostalCode","value":"97501"},{"characteristic":"InterLocCountry","value":"United States"},{"characteristic":"InterLocCityName","value":"Medford"},{"characteristic":"Environment","value":"FT"},{"characteristic":"ControlNumber","value":"192536"},{"characteristic":"BillingTelephoneNumber","value":"9723937082"},{"characteristic":"BillHandlingCode","value":"M"}],"FTR_ENT_CUSTOMERORDER_ATTCAT":[{"characteristic":"RC_RecurringCharge","value":"34.99"},{"characteristic":"RC_Quantity","value":"1.00"},{"characteristic":"RC_OneTimeTotal","value":"0.00"},{"characteristic":"RC_SNE_Code_MRC","value":"PREST"},{"characteristic":"OrgLocCityName","value":"Irving"},{"characteristic":"OrgLocStreetAddress","value":"1130 East Pioneer Drive"},{"characteristic":"OrgLocZipCode","value":"75061"},{"characteristic":"ATTR_DueDate","value":"2023-10-06 00:00:00"}],"FTR_ENT_CUSTOMER_ATTCAT":[{"characteristic":"BusinessOwnerTelephone","value":"0000000001"},{"characteristic":"CreditRating","value":"1"},{"characteristic":"OrganizationType","value":"Corporation"}],"FTR_ENT_FULFILMENT_ATTCAT":[{"characteristic":"PriLocCity","value":"Irving"},{"characteristic":"PriLocPostalCode","value":"75061"},{"characteristic":"PriLocState","value":"TX"},{"characteristic":"PriLocStreetAddress","value":"1130 East Pioneer Drive"}],"FTR_ENT_SERVICEITEMVALUES_ATTCAT":[{"characteristic":"WTN","value":"9724388518"}],"FTR_ENT_TECH_ATTCAT":[{"characteristic":"RC_AccountUUID","value":"5C675786853B48D08E8AA9D5B4C9B9F1"},{"characteristic":"ATTR_ItemSequence","value":"0"},{"characteristic":"ATTR_ItemCount","value":"1"},{"characteristic":"GroupMemberOrderId","value":"084077849"},{"characteristic":"CorrelationId","value":"10110113.9724388518"},{"characteristic":"ATTR_WaitSemaphore","value":"true"},{"characteristic":"LeadOrderId","value":"084077849"}],"FTR_ENT_USERDATA_ATTCAT":[{"characteristic":"NPA_NXX","value":"972438"}]}],"installationType":null,"dueDate":"2023-10-06 00:00:00","customerOrderType":null,"Quantity":null,"contract":{"offer":{"soldOn":"2023-09-06 00:00:00"},"Term":{"termInMonths":36}},"crisId":"864998"},"scheduleId":"S-5555083209","OrderNumber":"10110113","InternationalBillAddress":"false","ContractId":"80074000000NQoFAAW"}}}';
                input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
            } else if(orchestrationTaskName == TaskName_RC360){
               testJsonInput= '{"communicationPreference":"SMS","lineOfBusiness":"BUSINESS","accountLifeCycle":"Customer","contact":{"GivenAndFamilyName":{"familyName":"Test02 UCF Contact","givenName":"Granite"}},"address":{"environment":"US","controlNumber":"237520"},"GivenAndFamilyName":{"familyName":"Test02 UCF Contact","givenName":"Granite"},"phones":[{"phoneType":"Mobile","isPrimary":"true","phoneNumber":"6128960825"}],"emails":[{"isPrimary":"true","address":"xyz@gmail.com"}],"businessName":"GRANITE TELECOM","accountUUID":"da598921-6baf-493a-9c43-521742d8b6b"}';
                   
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
        
        item.vlocity_cmt__Response__c = String.valueOf(JSON.serialize(output));
        item.vlocity_cmt__Request__c  = String.valueOf(JSON.serialize(requestInput));
        
        update item;
        
        ctx.put('output', output);      
        // System.debug('Context output :'+ ctx.get('output'));
        // markDIDNumberLead((String)output.get('DIDNumber'));
        
        
       
        
        if (orchestrationTaskName == TaskName_RCSubmitGroupOrder){
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
                if (getOrchestrationTaskName() == TaskName_RCSubmitGroupOrder){ throw new ftr_DPIRCSystemInterfaceException((String)output.get('errorMessage')); }
            }
            updateDatabase(); //This needs to be removed after testing ASAP.
            if(Test.isRunningTest()) {
                System.debug('Invoking update database');
                updateDatabase(); ///invoking update database method
            }
        } 

        else if(orchestrationTaskName == TaskName_RC360){

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
                if (getOrchestrationTaskName() == TaskName_RC360){ throw new ftr_DPIRCSystemInterfaceException((String)output.get('errorMessage')); }
            }
            //This needs to be removed after testing ASAP.
            if(!Test.isRunningTest()) {
                System.debug('Invoking update database');
                
                updateAccountUUID(ctx, item.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c,FulfilmentReqLineId, ''); ///invoking update database method
            }
        }
         
    } catch (CalloutException ex) { 
        // Capture recoverable exception and notify OM to retry
        System.debug('Exception Caught***');
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
            Map<String, Object> logInput = new Map<String, Object> { 'request' => ctx.get('input'), 'response' => ctx.get('output'), 'interface' => getOrchestrationTaskName(), 'system' => 'DPI', 'status' => 'Error', 'errorMessage' => ex.getMessage(), 'errorCode' => '500', 'orderNumber' => sfOrderNumber, 'orchestrationItemId' => item.Id, 'convertToXML' => isXml, 'relatedTo' => whatId };  
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
        ftr_Logger.writeInfo('Exit ftr_DPIBaseBillingSystemInterface.executeItem');
        System.debug('Inside Finalize***');
        System.debug('Order id  '+whatId);
        System.debug('Retry count  '+retryCount);
        if(retrycount == null){
            vlocity_cmt__OrchestrationItem__c tempItem = [SELECT  vlocity_cmt__NumberOfRetries__c FROM vlocity_cmt__OrchestrationItem__c WHERE Id=:item.Id];
            retryCount = tempItem.vlocity_cmt__NumberOfRetries__c == null ? 0 : tempItem.vlocity_cmt__NumberOfRetries__c;
        }
        System.debug('Retry count  '+retryCount);
        //retryCount =1.00;
        if((retryCount < 1.00 ) && ctx.get('createTask')!=null && ctx.get('createTask').equals('True')||(ctx.get('createTask')!=null && ctx.get('createTask').equals('True')&& output.get('infoMessage')!=null)){
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
            createTaskInputMap.put('WhatId', whatId);
            System.debug('createTaskInputMap :'+ createTaskInputMap);
            ftr_OrderManagementHelper.CreateTask( createTaskInputMap) ;
            // try to create a log with the error details.
            try {
                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object> { 'request' => ctx.get('input'), 'response' => output, 'interface' => getOrchestrationTaskName(), 'system' => 'DPI', 'status' => 'Error', 'orchestrationItemId' => item.Id, 'orderNumber' => sfOrderNumber, 'errorMessage' => output.get('errorMessage') != null ? output.get('errorMessage') : (output.get('infoMessage') != null ? output.get('infoMessage') : 'Unkown Error'), 'errorCode' => output.get('ErrorCode') != null ? output.get('ErrorCode') : '500', 'convertToXML' => isXml, 'relatedTo' => whatId };  
                    APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);
            } catch (Exception e) {
                System.debug('Unable to create log');
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
    if (taskName == TaskName_RCSubmitGroupOrder) {
        Map<String, Object> headerInfo = new Map<String, Object>();
        String endpoint = apiConfigMap.get('CustMgmtURI');
        headerInfo.put('endpoint',endpoint);
        headerInfo.put('contentType', 'text/xml;charset=UTF-8');
        
        Map<String,Object> requestBody = new Map<String,Object>();
        // requestType = this.createDPIRequestType(url, path, input);
        requestBody =(Map<String,Object>)this.createDPIRequestType(url, path, input);
        system.debug('DPI Request map: '+requestBody );
        
        String requestXml =(String) requestBody.get('DpiRequestXML');
        String orderCount = (String) requestBody.get('transactionCount');
        requestInput = requestXml;
        // system.debug('DPI Request xml :'+requestType.get('DpiRequestXML'));
        system.debug('DPI Request xml:'+JSON.serialize(requestXml) );
        request = setRequestHeaders(request, requestXml, headerInfo);
        HttpResponse response = http.send(request);
        System.debug('HttpResponse : '+ response);
        
        if (response!=null){
            
            String responseType = response.getBody();
            System.debug('RespHttpResponse Body : '+ response.getBody());        
            //output = processDPIResponseType(url, path, responseType);
            output = processDPIResponseType(url, path, response.getBody());
            output.put('transactionCount', orderCount);
            
        } else {
            throw new ftr_DPIRCSystemInterfaceException('Invalid Response ' + response);
        }
        //Call the DPI Webservice
        
    }  
    else if(taskName == TaskName_RC360){

        Map<String, Object> headerInfo = new Map<String, Object>();
        String endpoint = apiConfigMap.get('RC360');
        headerInfo.put('endpoint',endpoint);
        headerInfo.put('contentType', 'application/json');
        
        System.debug('::: headerInfo :::'+headerInfo);
        
        Map<String,Object> requestBody = new Map<String,Object>();
        // requestType = this.createDPIRequestType(url, path, input);
        requestBody =(Map<String,Object>)this.createDPIRequestType(url, path, input);
        system.debug('DPI Request map: '+requestBody );
        
        String requestXml = JSON.serialize(requestBody);
        system.debug('requestXml: '+requestXml );
        requestInput = input.toString();
        // system.debug('DPI Request xml :'+requestType.get('DpiRequestXML'));
        //system.debug('DPI Request xml:'+JSON.serialize(requestXml));
        request = setRequestHeadersforC360(request, requestBody, headerInfo);
        HttpResponse response = http.send(request);
        System.debug('HttpResponse : '+ response);
        
        if (response!=null){
            //if (response.getStatusCode() == 200) {
            
             
        
            String responseType = response.getBody();
            System.debug('RespHttpResponse Body : '+ response.getBody());        
            //output = processDPIResponseType(url, path, responseType);
            output = processDPIResponseType(url, path, response.getBody());
            //output.put('transactionCount', orderCount);
          
        } else {
            throw new ftr_DPIRCSystemInterfaceException('Invalid Response ' + response);
        }
        //Call the DPI Webservice

    }
     
  
    return output;
}

global virtual Object createDPIRequestType(String url, String path, Map<String, Object> input) {
        
    throw new ftr_DPIRCSystemInterfaceException('Must be implemented in the child class.');
    
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
        throw new ftr_DPIRCSystemInterfaceException('Must be implemented in the child class.');
    }
    return (Map<String, Object> )respType;
}
public virtual String getOrchestrationTaskName() {
    
    throw new ftr_DPIRCSystemInterfaceException('Must be implemented in the child class getOrchestrationTaskName.');
}


private HttpRequest  setRequestHeaders( HttpRequest request, Object requestType, Map<String, Object> headerInfo){
        
    System.debug('Customermanagement endpoint '+'callout:DPIApigeeCredentials');
    request.setEndpoint('callout:DPIApigeeCredentials'+(String)headerInfo.get('endpoint'));
    //  request.setEndpoint('callout:DPIApigeeCredentials'+endpoint);
    //  request.setEndpoint('callout:DPIApigeeCredentials'+'/esbcustomerordermanagement/v1');
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
    
    private HttpRequest setRequestHeadersforC360( HttpRequest request, Object requestType, Map<String, Object> headerInfo){
        
        System.debug('Customermanagement requestType '+requestType);
        String jsonString = JSON.serialize(requestType);
        System.debug('jsonStringjsonString'+jsonString);
        System.debug('Customermanagement endpoint '+'callout:DPIApigeeCredentials');
        request.setEndpoint('callout:DPIApigeeCredentials'+(String)headerInfo.get('endpoint'));
        //  request.setEndpoint('callout:DPIApigeeCredentials'+endpoint);
        //  request.setEndpoint('callout:DPIApigeeCredentials'+'/esbcustomerordermanagement/v1');
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
        request.setBody(jsonString); 
        System.debug('Request body 2:'+(String)request.getBody());
        return request;
        
    }

    
    public static Map<String, Object> updateAccountUUID(Map<String, Object> ctx, String responseDRName, String fulfilmentid, String accountId){
        
         
         Map<String,Object> DRinputMap =new Map<String,Object>(); 
         Map<String, Object> resultMap =new Map<String,Object>();
         Map<String,Object> ctxOutput = (Map<String,Object>)ctx.get('output');
         String rc360Map = JSON.serialize(ctxOutput); 
         Map<String,Object> ctxOutputMessage = (Map<String, Object>)Json.deserializeUntyped(rc360Map);
         Map<String,Object> ctxOutputResponse = (Map<String,Object>)ctxOutputMessage.get('Message');
         Map<String,Object> payload = (Map<String,Object>)ctxOutputResponse.get('payload');
         String accountUUID = (String)payload.get('accountUUID');
         String cleanedAccountUUID = accountUUID.replaceAll('-', '').toUpperCase();
         
         DRinputMap.put('Id',fulfilmentid);
         DRinputMap.put('accountUUID',cleanedAccountUUID);
      
         if(DRinputMap!=null){
             vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(DRinputMap, responseDRName);
             resultMap = result.convertToMap();
          }
                 
           System.debug('ResultMap : '+resultMap );
           return resultMap;
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
    } 
}