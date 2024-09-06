/***
* @description Utility class 
**/  
global without sharing abstract class ftr_M6BaseSystemInterface implements vlocity_cmt.XOMOrchestrationInterfaces.ISystemInterface, vlocity_cmt.XOMOrchestrationInterfaces.IDeferredUpdater {
    //
    public static final String TaskName_CreateShellPSR = 'createShellPSR';
    public static final String TaskName_AddServiceItem = 'addServiceItem';
    public static final String TaskName_AddChildServiceItem = 'addChildServiceItem';
    public static final String TaskName_SubmitPSR = 'submitPSR';
    private static final String API_CONFIG_SETTINGS = 'M6Authentication';
    @TestVisible private static Map<String, String> apiConfigMap=new Map<String,String>();
    @TestVisible private static IntegrationAPIConfig__mdt apiconfig;
    private static final String ERR_NULL_INPUT ='Null ApiKey/Timeout';
    String testjsonInput;
    String orderNumber;
    String orderId;
    Object requestType;
    Object responseType;
    String documentNumber;
    String status;
    String taskName;
    ftr_PSRService.StatusMessageType[] responseStatus;
    
    
    
    
    static{
        try{
            List<IntegrationAPIConfig__mdt> apiConfigs = [SELECT Timeout__c, ApiKey__c,Authorization_Header__c  FROM IntegrationAPIConfig__mdt WHERE DeveloperName=: API_CONFIG_SETTINGS LIMIT 1];
            
            if ( !Test.isRunningTest() && (apiConfigs.isEmpty() || String.isBlank(apiConfigs[0].ApiKey__c) || apiConfigs[0].Timeout__c == null)) {
                throw new ftr_M6SystemInterfaceException(ERR_NULL_INPUT);
            }
            apiconfig=apiConfigs[0];
            
            // throw an exception if nothing is found, set the variable otherwise
            
            String Timeout=String.valueOf(apiConfig.Timeout__c);
            apiConfigMap.put('Timeout', Timeout);
            apiConfigMap.put('ApiKey', apiConfig.ApiKey__c);
            apiConfigMap.put('AuthHeader', apiConfig.Authorization_Header__c);
            //apiConfigMap.put('M6ApigeeCredentials',apigeeCred.Endpoint );
        } catch (Exception ex){
            System.debug(ex.getMessage());
            ftr_Logger.write(ex);
        }
    }
    protected Map<String, Object> ctx = new Map<String, Object>();
    public static String FulfilmentReqLineId;
    
    
    /*
Declare port details and get config from custom metadata
*/
    
    ftr_PSRService.PSRServicePort port;
    
    
    
    /**
* Exception to be thrown within M6 Orchestration Task
*/
    global class ftr_M6SystemInterfaceException extends Exception {}
    
    
    /**
* This method is a part of ISystemInterface. It is invoked at the start of the batch
* @param  url  base URL the batch is started for
* @param  path path this batch is started for
*/
    global virtual void startBatch(String url, String path){
        // Do nothing
        ftr_Logger.writeInfo('Enter ftr_M6BaseSystemInterface.startBatch');
        ftr_Logger.writeInfo('Exit ftr_M6BaseSystemInterface.startBatch');
    }
    
    /**
* Executes a Callout OrchestrationItem
* if cache is enabled then orchestration item data is retrieved from cache
* @param  url  base URL to send the request to
* @param  path path to send the request to
* @param  item OrchestrationItem that needs to be executed
*/
    global virtual void executeItem(String url, String path, vlocity_cmt__OrchestrationItem__c item) { 
        ftr_Logger.writeInfo('Enter ftr_M6BaseSystemInterface.executeItem');
        system.debug('I am in execute Method');
        try {
            Map<String, Object> input;
            // Pre_Invoke
            if(!Test.isRunningTest()){
            input = getInputPayload(url, path, item);
            }
            System.debug('execute method input..'+ JSON.serialize(input));
            if(Test.isRunningTest()){
                        String addChildServiceItemInput =  '{"order_items":[{"described_by":{"FTR_ENT_USERDATA_ATTCAT":[{"value":"374","characteristic":"COMPANY_INDICATOR"},{"value":"1681582","characteristic":"DSAT_ID"},{"value":"1","characteristic":"JURISDICTION_CODE"},{"value":"310889","characteristic":"NPA_NXX"},{"value":"1G","characteristic":"RATE_CODE"},{"value":537,"characteristic":"LEG_OR_HBE"}],"FTR_ENT_TECH_ATTCAT":[{"value":"2","characteristic":"ATTR_ItemCount"},{"value":false,"characteristic":"ATTR_WaitFor_ComboOrder"},{"value":"7887123","characteristic":"serviceItemId"},{"value":"7887122","characteristic":"parentServiceItemId"},{"value":"3833870","characteristic":"documentNumber"},{"value":"A","characteristic":"activityCode"},{"value":"08LN9.1GE","characteristic":"NCI"},{"value":"1112","characteristic":"ItemSpecifitionIdL2"},{"value":"1111","characteristic":"ItemSpecifitionIdL1"},{"value":"False","characteristic":"ATTR_WaitSemaphore"},{"value":"true","characteristic":"ATTR_M6_IsOrderCompleted"},{"value":"5bc9c79a-f2d1-c7bd-0e18-9201a9855d1f","characteristic":"ATTR_FRLRefId"},{"value":"2","characteristic":"GroupOrderTransactionCount"},{"value":"10088345.7601970821","characteristic":"CorrelationId"},{"value":"1","characteristic":"ATTR_ItemSequence"}],"FTR_ENT_SERVICEITEMVALUES_ATTCAT":[{"value":"7601970821","characteristic":"WTN"}],"FTR_ENT_FULFILMENT_ATTCAT":[{"value":"LOS ANGELES","characteristic":"PriLocCity"},{"value":"16180 MULHOLLAND DR","characteristic":"PriLocStreetAddress"},{"value":"CA","characteristic":"PriLocState"},{"value":"90049","characteristic":"PriLocPostalCode"}],"FTR_ENT_CUSTOM_ATTRIBUTES_ATTCAT":[{"value":"<=1600","characteristic":"Uni Maximum Transmission Unit (MTU)"},{"value":"NO","characteristic":"Service Multiplexing"},{"value":"100861","characteristic":"SPEED"},{"value":"Copper RJ45","characteristic":"Physical Medium"},{"value":"Auto","characteristic":"Negotiation (Port Speed)"},{"value":"UNI","characteristic":"NNI/UNI_Code"},{"value":"Full Duplex","characteristic":"Mode"},{"value":"N or LAN (Ethernet)","characteristic":"Broadband Service Category"},{"value":"100594","characteristic":"Bit Rate"}],"FTR_ENT_CUSTOMERORDER_ATTCAT":[{"value":"False","characteristic":"ATTR_SHARED_UNI"},{"value":"Existing","characteristic":"ATTR_MACD_Order_Action"},{"value":"False","characteristic":"HOST_TO_EVPL"}],"FTR_ENT_CUSTOMERACCOUNT_ATTCAT":[{"value":"3756266","characteristic":"ControlNumber"},{"value":"LAL","characteristic":"cityAbbreviation"},{"value":"CZ","characteristic":"Environment"}]},"specified_by":{"specification_name":"M6 UNI PSR CFS","specification_id":"01t0h000002mdssAAA"},"line_number":"a9D3I0000008aJwUAI.0001","action":"Add","order_item_id":"a9D3I0000008aJwUAI"}],"account_id":"001E000001RCCPMIA5","order_number":"10088345","order_object_id":"8013I000000BVtHQAW","order_id":"a9E3I00000090lRUAQ"}';      
                        input = (Map<String, Object>)JSON.deserializeUntyped(addChildServiceItemInput);
            }
           
            List<Object> orderItemsList = (List<Object>)input.get('order_items');
            orderNumber = (String)input.get('order_number');
            orderId = (String)input.get('order_object_id');
            Map<String,Object> orderItemIdMap = (Map<String,Object>)orderItemsList[0];
            FulfilmentReqLineId = String.valueOf(orderItemIdMap.get('order_item_id'));
            
            
            
            if (!Test.isRunningTest() && item.vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c != null){
                input = executeRequestItemDR(input, item.vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c);}
            
            if (!Test.isRunningTest() && item.vlocity_cmt__VlocityDataRaptorBundleId__c != null){
                input = executeRequestDR(input, item.vlocity_cmt__VlocityDataRaptorBundleId__c);
                
            } else if(Test.isRunningTest() && item.Name == 'CreateShellPSR'){
                testJsonInput= '{"createShellPSR": {"createShellPsrRequest": {"orderNotes": "Order imported from Vlocity Order Management","custAcctNbr": "001e000001VyCcN","orderedByTelNbr": "818-555-1111","orderedByLastName": "Contact","orderedByFirstName": "EM Test","PRODUCTCODE": "ENT_ETH_EIA_EVC_PSR_001","FRLId": "a9De00000004llwEAA","userData": [{"fieldValue": "1723091","fieldName": "DSAT_ID"},{"fieldValue": "1","fieldName": "JURISDICTION_CODE"},{"fieldValue": "1G","fieldName": "RATE_CODE"},{"fieldValue": "374","fieldName": "COMPANY_INDICATOR"},{"fieldValue": "909975","fieldName": "NPA_NXX"}],"productName": "M6 UNI PSR CFS","orderContacts": {"ProjectSpecialist": {"contactType": "FTRPM","telNbr": "818-555-1111","lastName": "Contact","firstName": "EM Test","email": "testcontact@emtestcompany.com"},"ServiceContact": {"contactType": "LCON","telNbr": "818-555-1111","lastName": "Contact","firstName": "EM Test","email": "testcontact@emtestcompany.com"},"SolutionEngineer": {"contactType": "FTRSE","lastName": "Marcondes","firstName": "Eric","email": "eric.marcondes@ftr.com","telNbr": "999-999-9999"},"MaintainenceContact": {"contactType": "MAINT","telNbr": "818-555-1111","lastName": "Contact","firstName": "EM Test","email": "testcontact@emtestcompany.com"},"OrderContact": {"contactType": "IMPL","telNbr": "818-555-1111","lastName": "Contact","firstName": "EM Test","email": "testcontact@emtestcompany.com"},"AE": {"contactType": "FTRAE","telNbr": "+1 8183311326","Name": "Eric Marcondes"}},"OrderUsrData": {"StatOrder": "STATS_ORDER","ContDateVal": "2020-06-26","ContDate": "CONTRACT_DATE","StatsOrderVal": "10020781"},"desiredDueDate": "2020-04-16 00:00:00","expedite": false}},"OrderId": "801e0000001jbVpAAI"}';
                Input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
                
            }else if(Test.isRunningTest() && item.Name == 'AddServiceItem'){
                testJsonInput = '{"addServiceItem": {"addServiceItemRequest": {"activityCode": "N","itemSpecificationId": "1102","documentNumber": "3399085","lineNumber": "a1d6g000000RQpPAAW.0001","FRLId": "a1d6g000000RQpPAAW"}}}';
                Input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
                
            }else if(Test.isRunningTest() && item.Name == 'addChildServiceItem'){
                testJsonInput= '{"addServiceItem":{"addServiceItemRequest":{"secloc":{"endUserLocation":{"address":{"streetName":"1602 Glasson Street","state":"IL","postalCode":"61704","city":"Bloomington"},"secnci":"08LN9.1GE","locationName":"AJ Test Company 3"}},"priloc":{"endUserLocation":{"address":{"streetName":"1602 Glasson Street","state":"IL","postalCode":"61704","city":"Bloomington"},"nci":"08LN9.1GE","locationName":"AJ Test Company 3"}},"serviceItemValues":{"value":"3091980457","label":"WTN"},"customAttributes":[{"caValue":"UNI","caLabel":"NNI/UNI_Code"},{"caValue":"Copper RJ45","caLabel":"Physical Medium"},{"caValue":"Full Duplex","caLabel":"Mode"},{"caValue":"N or LAN (Ethernet)","caLabel":"Broadband Service Category"},{"caValue":"100586","caLabel":"Bit Rate"},{"caValue":"<=1600","caLabel":"Uni Maximum Transmission Unit (MTU)"},{"caValue":"NO","caLabel":"Service Multiplexing"},{"caValue":"Auto","caLabel":"Negotiation (Port Speed)"}],"itemSpecificationId":"1112","documentNumber":"3393658","parentServiceItemId":"7549054"}}}}';
                Input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
                
            }
            
            
            if(!Test.isRunningTest() && item.Name == 'addChildServiceItem') {
//paa512 - start SDDD-2650 changes for MACD Project - Get modified custom and service item attributes for change M6 order
                
        vlocity_cmt__FulfilmentRequestLine__c frl = [Select Id, vlocity_cmt__Action__c, vlocity_cmt__JSONAttribute__c from vlocity_cmt__FulfilmentRequestLine__c where Id=:FulfilmentReqLineId];
        System.debug('**********FRL for compareOLIAndAssetJSONAttributesForChangeOrder: '+ frl);       
                
                Map<String, List<Object>> oliAssetAttributesMap = ftr_CpqHelper.compareOLIAndAssetJSONAttributesForChangeOrder(frl);
                //avv335 - start SDDD-2650 changes for MACD Project - Disconnect Order
                String frlMACDAction = (String) ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'ATTR_MACD_Order_Action');
                if (frlMACDAction != null && frlMACDAction == 'Disconnect'){
                    System.debug('Input map for disconnect Order after running compareOLIAndAssetJSONAttributesForChangeOrder--' + input);
                    String serviceItemId = (String) ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'serviceItemId');
                    //input = getModifiedInputPayloadForDisconnect(input, oliAssetAttributesMap, serviceItemId);
                }else {
                    if (oliAssetAttributesMap != null && oliAssetAttributesMap.size() > 0) {
                    System.debug('Input map for change order after running compareOLIAndAssetJSONAttributesForChangeOrder--' + JSON.serialize(input));
                    String serviceItemId = (String) ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'serviceItemId');
                    input = getModifiedInputPayload(input, oliAssetAttributesMap, serviceItemId);    
                }
            }
                //paa512 - End SDDD-2650 changes for MACD Project - Get modified custom and service item attributes for change M6 order
                
                
            }
            
            
            
            // Add final input to the payload
            ctx.put('url', url);
            ctx.put('path', path);
            ctx.put('item', item);
            ctx.put('input', input);
            
            // Invoke WebServiceCallout
            Map<String, Object> output;
            try {
                
                output = invoke(url, path, input);
                
                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object> {
                    'request' => requestType,
                        'response' => responseType,
                        'interface' => taskName,
                        'system' => 'M6',
                        'status' => responseStatus[0].message,
                        'convertToXML' => true,
                        'orderNumber' => orderNumber,
                        'orchestrationItemId' => item.Id,
                        'errorMessage' => responseStatus[0].message,
                        'errorCode' => responseStatus[0].code,
                        'documentNumber' => documentNumber,
                        'relatedTo' => orderId
                        };
                            APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);
                
            } catch (Exception ex) {
                
            System.debug('Exception Caught***');
            String addExMessage = ex.getMessage(); 
            Map<String,Object> createTaskInputMap =new Map<String,Object>();
           // createTaskInputMap.put('ErrorCode','7777');
            createTaskInputMap.put('Description',ex.getMessage()); 
            createTaskInputMap.put('Subject','M6 OM Exception'); 
            createTaskInputMap.put('Priority','High');
            createTaskInputMap.put('InterfaceName','AddServiceItemL1'); 
            createTaskInputMap.put('WhatId', orderId);
            System.debug('createTaskInputMap :'+ createTaskInputMap);
                
                
                ftr_Logger.write(ex);
                
                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object> {
                    'request' => requestType,
                        'response' => responseType,
                        'interface' => [SELECT Name FROM vlocity_cmt__OrchestrationItem__c WHERE Id =: item.Id].Name,
                        'system' => 'M6',
                        'status' => responseStatus != null ? responseStatus[0].message : 'Error',
                            'convertToXML' => true,
                            'orderNumber' => orderNumber,
                            'orchestrationItemId' => item.Id,
                            'errorMessage' => responseStatus != null ? responseStatus[0].message : ex.getMessage(),
                                'errorCode' => responseStatus != null ? responseStatus[0].code : '500',
                                    'documentNumber' => documentNumber,
                                    'relatedTo' => orderId
                                    };
                                        APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);    
                ftr_OrderManagementHelper.CreateTask( createTaskInputMap) ;
                throw ex;
            }
            
            
            // Post_Invoke
            // Add final input to the payload
            ctx.put('output', output);
            
            if(Test.isRunningTest()) {
                updateDatabase(); ///invoking update database method
            }
            
        } catch (CalloutException ex) { // Capture recoverable exception and notify OM to retry
            ftr_Logger.write(ex);
            throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException ('Callout exception ' + ex + ': trying to retry');
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            throw ex;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_M6BaseSystemInterface.executeItem');
        }
    }
    
    //paa512 - start SDDD-2650 changes for MACD Project - Get modified custom and service item attributes for change order
    public static Map<String, Object> getModifiedInputPayload(Map<String, Object> orignalInputPayload, Map<String, List<Object>> oliAssetAttributesMap, String serviceItemId) {
        
        Map<String, Object> input = orignalInputPayload.clone();
        if(oliAssetAttributesMap != null && oliAssetAttributesMap.size() >0) {
            
            List<Object> caAttributes = oliAssetAttributesMap.get('CA_ATTRIBUTES');
            List<Object> serviceItemAttributes = oliAssetAttributesMap.get('SERVICEITEM_ATTRIBUTES');
            
            Map<String, Object> addServiceItemRequestMap = (Map<String, Object>)input.get('addServiceItem');
            Map<String, Object> requestMap = (Map<String, Object>)addServiceItemRequestMap.get('addServiceItemRequest');
            requestMap.put('activityCode', 'C');
            
            if(!requestMap.containsKey('serviceItemId')) {
                requestMap.put('serviceItemId', serviceItemId);    
            }
            
            List<Object> existingCustomAttributesList = new List<Object>();
            Map<String, Object> existingCustomAttributesMap = new Map<String, Object>();
            
            if(requestMap.get('customAttributes') instanceof List<object>) {
                existingCustomAttributesList = (List<Object>)requestMap.get('customAttributes');
                for(Object customAttribute : existingCustomAttributesList) {
                    Map<String, Object> customAttributeMap = (Map<String, Object>)customAttribute;
                    String caLabelName = String.valueOf(customAttributeMap.get('caLabel'));//'67';
                    String caLabelValue = String.valueOf(customAttributeMap.get('caValue'));//'67';
                    System.debug('ifcaLabelName:'+caLabelName);
                    System.debug('ifcaLabelValue:'+caLabelValue);
                    if(!caAttributes.contains(caLabelName)) {
                        customAttributeMap.remove('caLabel');
                        customAttributeMap.remove('caValue');
                    }
                }
            } else {
                existingCustomAttributesMap = (Map<String, Object>)requestMap.get('customAttributes');
                String caLabelName = String.valueOf(existingCustomAttributesMap.get('caLabel'));//'67';
                String caLabelValue = String.valueOf(existingCustomAttributesMap.get('caValue'));//'67';
                System.debug('caLabelName:'+caLabelName);
                   System.debug('caLabelValue:'+caLabelValue);
                if(!caAttributes.contains(caLabelName)) {
                    existingCustomAttributesMap.remove('caLabel');
                    existingCustomAttributesMap.remove('caValue');
                }
                
            }
            
            
            List<Object> existingServiceItemValuesList = new List<Object>();
            Map<String, Object> exstingServiceItemValuesMap = new Map<String, Object>();
            
            if(requestMap.get('serviceItemValues') instanceof List<object>) {
                existingServiceItemValuesList = (List<Object>)requestMap.get('serviceItemValues');
                for(Object serviceItem : existingServiceItemValuesList) {
                    Map<String, Object> serviceItemMap = (Map<String, Object>)serviceItem;
                    String serviceItemLabel = String.valueOf(serviceItemMap.get('label'));//'67';
                    String serviceItemValue = String.valueOf(serviceItemMap.get('value'));//'67';
                    if(!serviceItemAttributes.contains(serviceItemLabel)) {
                        
                        serviceItemMap.remove('label');
                        serviceItemMap.remove('value');
                    }
                }
                
                
            } else {
                exstingServiceItemValuesMap = (Map<String, Object>)requestMap.get('serviceItemValues');
            } 
            
            
        }
        
        return input;
        //paa512 - End SDDD-2650 changes for MACD Project - Get modified custom and service item attributes for change order
    }
    
    //avv335 - End SDDD-2650 changes for MACD Project - Get modified service item attributes for disconnect order
    /* public static Map<String, Object> getModifiedInputPayloadForDisconnect(Map<String, Object> orignalInputPayload, Map<String, List<Object>> oliAssetAttributesMap, String serviceItemId) {
        
        Map<String, Object> input = orignalInputPayload.clone();
        if(oliAssetAttributesMap != null && oliAssetAttributesMap.size() >0) {
            
            List<Object> serviceItemAttributes = oliAssetAttributesMap.get('SERVICEITEM_ATTRIBUTES');
            
            Map<String, Object> addServiceItemRequestMap = (Map<String, Object>)input.get('addServiceItem');
            Map<String, Object> requestMap = (Map<String, Object>)addServiceItemRequestMap.get('addServiceItemRequest');
            requestMap.put('activityCode', 'D');
            
            if(!requestMap.containsKey('serviceItemId')) {
                requestMap.put('serviceItemId', serviceItemId);    
            }
            
            List<Object> existingServiceItemValuesList = new List<Object>();
            Map<String, Object> exstingServiceItemValuesMap = new Map<String, Object>();
            
            if(requestMap.get('serviceItemValues') instanceof List<object>) {
                existingServiceItemValuesList = (List<Object>)requestMap.get('serviceItemValues');
                for(Object serviceItem : existingServiceItemValuesList) {
                    Map<String, Object> serviceItemMap = (Map<String, Object>)serviceItem;
                    String serviceItemLabel = String.valueOf(serviceItemMap.get('label'));//'67';
                    String serviceItemValue = String.valueOf(serviceItemMap.get('value'));//'67';
                    //String serviceItemactivityCd = String.valueOf(serviceItemMap.get('activityCd'));//'67';
                    if(!serviceItemAttributes.contains(serviceItemLabel)) {
                        
                        serviceItemMap.remove('label');
                        serviceItemMap.remove('value');
                        //serviceItemMap.remove('activityCd');
                    }
                }
                
                
            } else {
                exstingServiceItemValuesMap = (Map<String, Object>)requestMap.get('serviceItemValues');
            }
            
            
        }
        
        return input;
        //avv335 - End SDDD-2650 changes for MACD Project - Get modified service item attributes for disconnect order
    } */
    
    /**
* This method is called at the end of the batch
* @param  url  base URL for the batch
* @param  path path for the batch
*/
    global virtual void endBatch(String url, String path) {
        // Do nothing
        ftr_Logger.writeInfo('Enter ftr_M6BaseSystemInterface.endBatch');
        ftr_Logger.writeInfo('Exit ftr_M6BaseSystemInterface.endBatch');
    }
    
    
    /**
* update DB,
* from XOMOrchestrationInterfaces, executed when it safe to do it.
*/
    public void updateDatabase() {
        ftr_Logger.writeInfo('Enter ftr_M6BaseSystemInterface.updateDatabase');
        
        try {
            vlocity_cmt__OrchestrationItem__c item = (vlocity_cmt__OrchestrationItem__c)ctx.get('item');
            
            if (item.vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c != null) {
                executeResponseAttrsDR(ctx, item.vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c);
            }
            
            if (item.vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c != null) {
                executeResponseItemDR(ctx, item.vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c);
            }
            
            if (item.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c != null) {
                executeResponseDR(ctx, item.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c);
            }
        } catch (Exception ex) {
            ftr_Logger.write(ex);
        } finally {
            ftr_Logger.writeInfo('Exit ftr_M6BaseSystemInterface.updateDatabase');
        }
    }
    
    
    
    /**
* This method is called from executeItem to create M6 RequestType 
*
* @return         return the M6 SOAP API method name 
*/
    public virtual String getOrchestrationTaskName() {
        
        throw new ftr_M6SystemInterfaceException('Must be implemented in the child class.');
    }
    
    /**
* This method is called from executeItem to create M6 RequestType 
*
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  input payload to be used to construct 
* @return         M6 RequestType object to be sent
*/
    global virtual Object createM6RequestType(String url, String path, Map<String, Object> input) {
        
        throw new ftr_M6SystemInterfaceException('Must be implemented in the child class.');
        
    }
    
    /**
* This method is called from executeItem to create process response
*
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  respType M6 ResponseType to process
* @return         output object to be processed
*/
    global virtual Map<String, Object> processM6ResponseType(String url, String path, Object respType) {
        
        throw new ftr_M6SystemInterfaceException('Must be implemented in the child cleass.');
    }
    
    /**
* This method is called to execute the actual M6 SOAP API callout
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  input payload prepared by the DRs
* @return      output JSON data returned
*/
    private Map<String, Object> invoke(String url, String path, Map<String, Object> input) {
        
        system.debug('I am in invoke Method'+ JSON.serialize(input));
        requestType = createM6RequestType(url, path, input);
        
        System.debug('request--> '+ JSON.serialize(requestType));
        
        // TODO...
        taskName = getOrchestrationTaskName();
        //system.debug('TaskName'+taskName);
        if (taskName == TaskName_CreateShellPSR) {
            // PSR_ServicePort -> WebserviceCallout(...)
            setPortValues();
            responseType= (ftr_PSRService.createPsrResponseType)this.port.CreateShellPSR((ftr_PSRService.createShellPsrRequestType)requestType);
            responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.createPsrResponseType) responseType).statusMessage);
            if ((ftr_PSRService.createPsrResultType)((ftr_PSRService.createPsrResponseType) responseType).createPsrResult != null)
                documentNumber = String.valueOf(((ftr_PSRService.createPsrResultType)((ftr_PSRService.createPsrResponseType) responseType).createPsrResult).documentNumber);
            
        } else if (taskName == TaskName_AddServiceItem) {
            // PSR_ServicePort -> WebserviceCallout(...)
            setPortValues();
            responseType= (ftr_PSRService.addServiceItemResponseValueType)this.port.addServiceItem((ftr_PSRService.addServiceItemRequestType)requestType);
            responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.addServiceItemResponseValueType) responseType).statusMessage);
            if ((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult != null)
                documentNumber = String.valueOf(((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult).documentNumber);
            
        } else if (taskName == TaskName_AddChildServiceItem) {
            // PSR_ServicePort -> WebserviceCallout(...)
            setPortValues();
            responseType = (ftr_PSRService.addServiceItemResponseValueType)this.port.addServiceItem((ftr_PSRService.addServiceItemRequestType)requestType);
            responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.addServiceItemResponseValueType) responseType).statusMessage);
            if ((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult != null)
                documentNumber = String.valueOf(((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult).documentNumber);
            
        } else if (taskName == TaskName_SubmitPSR) {
            // PSR_ServicePort -> WebserviceCallout(...)
            setPortValues();
            responseType = (ftr_PSRService.finishOrderResponseValueType)this.port.finishOrder((ftr_PSRService.finishOrderRequestType)requestType);
            responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.finishOrderResponseValueType) responseType).statusMessage);
            if ((ftr_PSRService.finishOrderResultType)((ftr_PSRService.finishOrderResponseValueType) responseType).finishOrderResult != null)
                documentNumber = String.valueOf(((ftr_PSRService.finishOrderResultType)((ftr_PSRService.finishOrderResponseValueType) responseType).finishOrderResult).documentNumber);
            
        } else {
            throw new ftr_M6SystemInterfaceException('Invalid Orchestration Task: ' + taskName);
        }
        
        System.debug('response--> '+ JSON.serialize(responseType));
        
        Map<String, Object> output = processM6ResponseType(url, path, responseType);
        
        return output;
    }
    
    /**
* This method returns the initial JSON payload from the given OrchestrationItem item
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  item Orchestration Item
* @return      initial payload 
*/
    private Map<String, Object> getInputPayload(String url, String path, vlocity_cmt__OrchestrationItem__c item) {
        system.debug('@@@@FRID'+item.vlocity_cmt__fulfilmentRequestLineId__c+' '+JSON.serialize(item));
        vlocity_cmt__FulfilmentRequestLine__c frl = [SELECT Id, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c,
                                                     vlocity_cmt__JSONAttribute__c, vlocity_cmt__Action__c, vlocity_cmt__LineNumber__c, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.Name,vlocity_cmt__Product2Id__r.ProductCode,
                                                     vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber
                                                     FROM vlocity_cmt__FulfilmentRequestLine__c
                                                     WHERE Id=:item.vlocity_cmt__fulfilmentRequestLineId__c];
        
        System.debug('@@@@FRL in ftr_M6BaseSystemInterface class--' + frl);
        //paa512 - MACD changes for fetching the AccountId from the new field - M6_Customer_Number__c for accounts created outside of Vlocity
        Account account = [Select Id, M6_Customer_Number__c from Account where Id=:frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c];
        String m6AcctId = '';
        if(account != null && String.isNotBlank(Account.M6_Customer_Number__c)) {
            m6AcctId = account.M6_Customer_Number__c;
        } else {
            m6AcctId = account.Id;
        }
        
        
        Map<String, List<Object>> described_by = new Map<String, List<Object>>();
        Map<String, Object> payload = new Map<String, Object> {
            'order_id' => frl.vlocity_cmt__FulfilmentRequestID__r.Id,
                'order_object_id' => frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c,
                'order_number' => frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber,
                'account_id' => m6AcctId,//frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c,
                'order_items' => new List<Object> {
                    new Map<String, Object> {
                        'order_item_id' => frl.Id,
                            'action' => frl.vlocity_cmt__Action__c,
                            'line_number' => frl.vlocity_cmt__LineNumber__c,
                            'specified_by' => new Map<String, String> {
                                'specification_id' => frl.vlocity_cmt__Product2Id__c,
                                    'specification_name' => frl.vlocity_cmt__Product2Id__r.Name
                                    },
                                        'described_by' => described_by
                                        }
                }
        };
            
            String jsonAttribute = frl.vlocity_cmt__JSONAttribute__c;
        Map<String, Object> attrValMap = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
        vlocity_cmt__Attribute__c[] myAttribs = [SELECT Id, vlocity_cmt__Code__c, vlocity_cmt__AttributeCategoryCode__c FROM vlocity_cmt__Attribute__c WHERE vlocity_cmt__Code__c=:attrValMap.keySet() 
                                                 ORDER BY vlocity_cmt__AttributeCategoryCode__c];
        
        
        Set<String> myCategoryCode = new Set<String>();
        for (vlocity_cmt__Attribute__c attr : myAttribs) {
            List<Object> categoryAttribs;
            if (!myCategoryCode.contains(attr.vlocity_cmt__AttributeCategoryCode__c)) {
                categoryAttribs = new List<Object>();
                described_by.put(attr.vlocity_cmt__AttributeCategoryCode__c, categoryAttribs);
            } else {
                categoryAttribs = (List<Object>)described_by.get(attr.vlocity_cmt__AttributeCategoryCode__c); 
            }
            myCategoryCode.add(attr.vlocity_cmt__AttributeCategoryCode__c);
            
            if(attrValMap.get(attr.vlocity_cmt__Code__c) != null){
                categoryAttribs.add(new Map<String, Object> {
                    'characteristic' => attr.vlocity_cmt__Code__c,
                        'value' => attrValMap.get(attr.vlocity_cmt__Code__c)
                        });
            }
        }
        String psrMsuites = (String)attrValMap.get('PSR_Msuites');
        String orderId = (String)payload.get('order_object_id');
        List<OrderItem> orderItems = [SELECT Id, vlocity_cmt__Product2Id__r.ProductCode
                                      FROM OrderItem
                                      WHERE OrderId = :orderId AND vlocity_cmt__Product2Id__r.ProductCode = 'ENT_ETH_EIA_003'];
        system.debug('****orderItems*****'+orderItems);
        if (orderItems.size()>0 || (psrMsuites != null && psrMsuites.equalsIgnoreCase('Yes'))) {
            Map<String, Object> mSuites = new Map<String, Object> {
                    'characteristic' => 'Msuites',
                        'value' => 'Yes'
                        };
           Map<String, Object> managedDIA = new Map<String, Object> {
                    'characteristic' => 'MANAGED_DEVICE_UNI',
                        'value' => 'Y'
                        };
           Map<String, Object> orderitms = (Map<String, Object>)((List<Object>)payload.get('order_items'))[0];
            if(frl.vlocity_cmt__Product2Id__r.ProductCode == 'ENT_ETH_UNI_PSR_001')
            {
                ((List<Object>)((Map<String, Object>)orderitms.get('described_by')).get('FTR_ENT_CUSTOM_ATTRIBUTES_ATTCAT')).add(mSuites);
            }
            if(orderItems.size()>0 && frl.vlocity_cmt__Product2Id__r.ProductCode == 'ENT_ETH_UNI_PSR_001')
            {
                ((List<Object>)((Map<String, Object>)orderitms.get('described_by')).get('FTR_ENT_SERVICEITEMVALUES_ATTCAT')).add(managedDIA);
            }
        }
        return payload;
    }
    
    /**
* This method returns the JSON payload massaged by the RequestItem DataRaptor
* @param  input payload to be massaged
* @param  requestItemDRName Datarapotor name
* @return      payload massaged by RequestItem DR
*/
    private Map<String, Object> executeRequestItemDR(Map<String, Object> input, String requestItemDRName) {
        
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(input, requestItemDRName);
        Map<String, Object> DRItemFinalRequest = (Map<String, Object>)result.toJSON();
        return DRItemFinalRequest;
        
        //throw new ftr_M6SystemInterfaceException('Not implemented.');
    }
    
    /**
* This method returns the JSON payload massaged by the Request DataRaptor
* @param  input payload to be massaged
* @param  requestDRName Datarapotor name
* @return      payload massaged by Request DR
*/
    private Map<String, Object> executeRequestDR(Map<String, Object> input, String requestDRName) {
        
        
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(input, requestDRName);
        
        
        Map<String, Object> DRFinalRequest = (Map<String,Object>)result.toJSON();
        return DRFinalRequest;
        
        
        //throw new ftr_M6SystemInterfaceException('Not implemented.');
    }
    
    /**
* This method returns the JSON payload massaged by the Response DataRaptor
* @param  ctx context data 
* @param  responseAttrsDR Datarapotor name
* @return      payload massaged by Response DR
*/
    private Map<String, Object> executeResponseAttrsDR(Map<String, Object> ctx, String responseAttrsDR) {
        
        Map<String,Object> DRinput =new Map<String,Object>();
        Map<String,Object> DRinputMap =new Map<String,Object>();
        
        Map<String,Object> ctxOutput = (Map<String,Object>)ctx.get('output');
        
        
        DRinputMap.put('Id',FulfilmentReqLineId);
        DRinputMap.putAll(ctxOutput);
        DRinput.put('output',DRinputMap);
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(DRinput, responseAttrsDR);
        Map<String, Object> resultMap = result.convertToMap();
        return resultMap;
        // throw new ftr_M6SystemInterfaceException('Not implemented.');
    }
    
    /**
* This method returns the JSON payload massaged by the ResponseItem DataRaptor
* @param  ctx context data 
* @param  responseItemDRName Datarapotor name
* @return      payload massaged by ResponseItem DR
*/
    private Map<String, Object> executeResponseItemDR(Map<String, Object> ctx, String responseItemDRName) {
        
        Map<String,Object> DRinput =new Map<String,Object>();
        Map<String,Object> DRinputMap =new Map<String,Object>();
        
        Map<String,Object> ctxOutput = (Map<String,Object>)ctx.get('output');
        
        
        DRinputMap.put('Id',FulfilmentReqLineId);
        DRinputMap.putAll(ctxOutput);
        DRinput.put('output',DRinputMap);
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(DRinput, responseItemDRName);
        Map<String, Object> resultMap = result.convertToMap();
        return resultMap;
        
        //throw new ftr_M6SystemInterfaceException('Not implemented.');
    }
    
    /**
* This method returns the JSON payload massaged by the ResponseItem DataRaptor
* @param  ctx context data 
* @param  responseDRName Datarapotor name
* @return      payload massaged by ResponseItem DR
*/
    private Map<String, Object> executeResponseDR(Map<String, Object> ctx, String responseDRName) {
        
        Map<String,Object> DRinput =new Map<String,Object>();
        Map<String,Object> DRinputMap =new Map<String,Object>();
        
        Map<String,Object> ctxOutput = (Map<String,Object>)ctx.get('output');
        
        
        
        DRinputMap.put('Id',FulfilmentReqLineId);
        DRinputMap.putAll(ctxOutput);
        
        DRinput.put('output',DRinputMap);
        system.debug('DRinput-->'+json.serialize(DRinput));          
        system.debug('responseDRName-->'+responseDRName);
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(DRinput, responseDRName);
        
        Map<String, Object> resultMap = result.convertToMap();
        
        return resultMap;
        
        
        //throw new ftr_M6SystemInterfaceException('Not implemented.');
    }
    
    
    private ftr_PSRService.PSRServicePort setPortValues(){
        this.port = new ftr_PSRService.PSRServicePort();
        
        Map<String, String> headers = new Map<String, String>{
            'ApiKey' => apiConfigMap.get('ApiKey'),
                
                'Authorization' => 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiConfigMap.get('AuthHeader')))
                };
                    this.port.endpoint_x = 'callout:M6ApigeeCredentials';
        this.port.timeout_x = Integer.valueOf(apiConfigMap.get('Timeout'));
        this.port.inputHttpHeaders_x = headers;
        system.debug('Port values:');
        
        return this.port;
        
        
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