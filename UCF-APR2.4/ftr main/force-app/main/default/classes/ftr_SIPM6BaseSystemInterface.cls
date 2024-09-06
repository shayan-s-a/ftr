/**
* @description Utility class
* @version :1
*/
global without sharing abstract class ftr_SIPM6BaseSystemInterface implements vlocity_cmt.XOMOrchestrationInterfaces.ISystemInterface, vlocity_cmt.XOMOrchestrationInterfaces.IDeferredUpdater {
    //
    public static final String TaskName_SIPCreateShellPSR = 'SIPCreateShellPSR';
    public static final String TaskName_AddServiceItem = 'SIPAddServiceItemL1';
    public static final String TaskName_SIPAddServiceItemL2 = 'SIPAddServiceItemL2';
    public static final String TaskName_CreateEndUserLocation = 'CreateEndUserLocation';
    public static final String TaskName_SIPSubmitPSR = 'SIPSubmitPSR';
    public static final String TaskName_SIPCheckM6Account = 'SIPCheckM6Account';
    public static final String TaskName_DIDAddServiceItem = 'DIDAddServiceItem';
    public static final String DR_SIPAddServiceItemL1 = 'DRM6LoadAddServiceItemL1Response';
    public static final String DR_SIPAddServiceItemL2 = 'SIPM6AddServiceItemL2ResponseItemDR';
    public static final String DR_SIPDocumentNumber = 'SIPM6CreateShellPSRResponseDR';
    public static final String DR_DIDAddServiceItem = 'DIDM6AddServiceLineItemL1Response';
    private static final String API_CONFIG_SETTINGS = 'M6Authentication';
    @TestVisible private static Map<String, String> apiConfigMap=new Map<String,String>();
    @TestVisible private static IntegrationAPIConfig__mdt apiconfig;
    private static final String ERR_NULL_INPUT ='Null ApiKey/Timeout';
    String testjsonInput;
    String orderNumber;
    String orderId;
     String accountId;
    Object requestType;
    Object responseType;
    String documentNumber;
    String status;
    String taskName;
    ftr_PSRService.StatusMessageType[] responseStatus;




    static{
        try{
            List<IntegrationAPIConfig__mdt> apiConfigs = [SELECT Timeout__c, ApiKey__c,Authorization_Header__c  FROM IntegrationAPIConfig__mdt WHERE DeveloperName=: API_CONFIG_SETTINGS LIMIT 1];

            if ( !Test.isRunningTest() && (apiConfigs.isEmpty() || String.isBlank(apiConfigs[0].ApiKey__c) || apiConfigs[0].Timeout__c == null)) { throw new ftr_M6SystemInterfaceException(ERR_NULL_INPUT);
            }
            apiconfig=apiConfigs[0];

            // throw an exception if nothing is found, set the variable otherwise

            String Timeout=String.valueOf(apiConfig.Timeout__c);
            apiConfigMap.put('Timeout', Timeout);
            apiConfigMap.put('ApiKey', apiConfig.ApiKey__c);
            apiConfigMap.put('AuthHeader', apiConfig.Authorization_Header__c);
            //apiConfigMap.put('M6ApigeeCredentials',apigeeCred.Endpoint );
        } catch (Exception ex){ System.debug(ex.getMessage()); ftr_Logger.write(ex);
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
*/global virtual void startBatch(String url, String path){ ftr_Logger.writeInfo('Enter ftr_SIPM6BaseSystemInterface.startBatch'); ftr_Logger.writeInfo('Exit ftr_SIPM6BaseSystemInterface.startBatch');
    }

    /**
* Executes a Callout OrchestrationItem
* if cache is enabled then orchestration item data is retrieved from cache
* @param  url  base URL to send the request to
* @param  path path to send the request to
* @param  item OrchestrationItem that needs to be executed
*/
    global virtual void executeItem(String url, String path, vlocity_cmt__OrchestrationItem__c item) {
        ftr_Logger.writeInfo('Enter ftr_SIPM6BaseSystemInterface.executeItem');
        system.debug('I am in execute Method');
        system.debug('@Item'+item);
        system.debug('@Itemname'+item.Name);
        try {
            Map<String, Object> input;
            // Pre_Invoke

            input = getInputPayload(url, path, item);
            System.debug('execute method input..'+ JSON.serialize(input));
            List<Object> orderItemsList = (List<Object>)input.get('order_items');
            orderNumber = (String)input.get('order_number');
            orderId = (String)input.get('order_object_id');
            accountId = (String)input.get('account_id');
            system.debug('@@@@serviceAccount'+(String)input.get('service_account'));
            system.debug('checkaccount'+accountId);
              system.debug('checkaccount'+accountId);
            Map<String,Object> orderItemIdMap = (Map<String,Object>)orderItemsList[0];
            FulfilmentReqLineId = String.valueOf(orderItemIdMap.get('order_item_id'));
             


            if (!Test.isRunningTest() && item.vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c != null){ input = executeRequestItemDR(input, item.vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c);
            	System.debug('dataraptor bundle input =' + input);
            }

            if (!Test.isRunningTest() && item.vlocity_cmt__VlocityDataRaptorBundleId__c != null){ input = executeRequestDR(input, item.vlocity_cmt__VlocityDataRaptorBundleId__c);
                System.debug('dataraptor bundle input =' + input);
            } else if(Test.isRunningTest() && item.Name == 'SIPCreateShellPSR'){
				System.debug('Test.isRunningTest() SIPcheckM6Account');
                testJsonInput= '{"createShellPSR": {"createShellPsrRequest": {"orderNotes": "Order imported from Vlocity Order Management","custAcctNbr": "001e000001VyCcN","orderedByTelNbr": "818-555-1111","orderedByLastName": "Contact","orderedByFirstName": "EM Test","PRODUCTCODE": "SIP_TRUNKING_UNI_PSR_RES_SPEC_0010","FRLId": "a9De00000004llwEAA","userData": [{"fieldValue": "1723091","fieldName": "DSAT_ID"},{"fieldValue": "1","fieldName": "JURISDICTION_CODE"},{"fieldValue": "1G","fieldName": "RATE_CODE"},{"fieldValue": "374","fieldName": "COMPANY_INDICATOR"},{"fieldValue": "909975","fieldName": "NPA_NXX"}],"productName": "M6 UNI PSR CFS","orderContacts": {"ProjectSpecialist": {"contactType": "FTRPM","telNbr": "818-555-1111","lastName": "Contact","firstName": "EM Test","email": "testcontact@emtestcompany.com"},"ServiceContact": {"contactType": "LCON","telNbr": "818-555-1111","lastName": "Contact","firstName": "EM Test","email": "testcontact@emtestcompany.com"},"SolutionEngineer": {"contactType": "FTRSE","lastName": "Marcondes","firstName": "Eric","email": "eric.marcondes@ftr.com","telNbr": "999-999-9999"},"MaintainenceContact": {"contactType": "MAINT","telNbr": "818-555-1111","lastName": "Contact","firstName": "EM Test","email": "testcontact@emtestcompany.com"},"OrderContact": {"contactType": "IMPL","telNbr": "818-555-1111","lastName": "Contact","firstName": "EM Test","email": "testcontact@emtestcompany.com"},"AE": {"contactType": "FTRAE","telNbr": "+1 8183311326","Name": "Eric Marcondes"}},"OrderUsrData": {"StatOrder": "STATS_ORDER","ContDateVal": "2020-06-26","ContDate": "CONTRACT_DATE","StatsOrderVal": "10020781"},"desiredDueDate": "2020-04-16 00:00:00","expedite": false}},"OrderId": "801e0000001jbVpAAI"}';
                Input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);

            }else if(Test.isRunningTest() && item.Name == 'AddServiceItem'){ testJsonInput = '{"addServiceItem": {"addServiceItemRequest": {"activityCode": "N","itemSpecificationId": "1102","documentNumber": "3399085","lineNumber": "a1d6g000000RQpPAAW.0001","FRLId": "a1d6g000000RQpPAAW"}}}';
                Input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
                   System.debug('dataraptor bundle input =' + input);
            
            }else if(Test.isRunningTest() && item.Name == 'SIPAddServiceItemL1'){
                testJsonInput = '{"addServiceItem": {"addServiceItemRequest": {"activityCode": "N","itemSpecificationId": "1102","documentNumber": "3399085","lineNumber": "a1d6g000000RQpPAAW.0001","FRLId": "a1d6g000000RQpPAAW"}}}';
                Input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
                    System.debug('dataraptor bundle input =' + input);


            }else if(Test.isRunningTest() && item.Name == 'SIPAddServiceItemL2'){

                testJsonInput = '{"addServiceItem":{"addServiceItemRequest":{"secloc":{"endUserLocation":{"address":{"streetName":"1602 Glasson Street","state":"IL","postalCode":"61704","city":"Bloomington"},"secnci":"08LN9.1GE","locationName":"AJ Test Company 3"}},"priloc":{"endUserLocation":{"address":{"streetName":"1602 Glasson Street","state":"IL","postalCode":"61704","city":"Bloomington"},"nci":"08LN9.1GE","locationName":"AJ Test Company 3"}},"serviceItemValues":{"value":"3091980457","label":"WTN"},"customAttributes":[{"caValue":"UNI","caLabel":"NNI/UNI_Code"},{"caValue":"Copper RJ45","caLabel":"Physical Medium"},{"caValue":"Full Duplex","caLabel":"Mode"},{"caValue":"N or LAN (Ethernet)","caLabel":"Broadband Service Category"},{"caValue":"100586","caLabel":"Bit Rate"},{"caValue":"<=1600","caLabel":"Uni Maximum Transmission Unit (MTU)"},{"caValue":"NO","caLabel":"Service Multiplexing"},{"caValue":"Auto","caLabel":"Negotiation (Port Speed)"}],"itemSpecificationId":"1112","documentNumber":"3393658","parentServiceItemId":"7549054"}}}}';
                Input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);


            /******* Create End USer Location****////
            }else if(Test.isRunningTest() && item.Name == 'CreateEndUserLocation'){
                testJsonInput= '{"createServiceLocation":{"createServiceLocationRequest":{"priloc":{"endUserLocation":[{"LocationName":"two001","DIDLocationId":"aH67c0000008fuCCAQ","postalCode":"46804","StreetName":"8111 West Jefferson Boulevard","State":"IN","Country":"United States","City":"Fort Wayne","WCCLLISWITCH":"BCKLWVWDDS0","Address":"8111 West Jefferson Boulevard, Fort Wayne, IN 46804"},{"LocationName":"MDn Number","DIDLocationId":"aH67c0000008frNCAQ","postalCode":"46804","StreetName":"8111 West Jefferson Boulevard","State":"IN","Country":"United States","City":"Fort Wayne","Address":"8111 West Jefferson Boulevard, Fort Wayne, IN 46804","WCCLLISWITCH":"BCKLWVWDDS0"}]},"documentNumber":"3866166"}}}';
                Input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);}

            else if(Test.isRunningTest() && item.Name == 'SIPCheckM6Account'){
                System.debug('Test.isRunningTest() SIPcheckM6Account');
                testJsonInput= '{"createCustomerAccount": {"createCustomerAccountRequest": {"CompanyName": "1050 South Dupont Avenue","StreetName": "1050 South Dupont Avenue","State": "CA","PostalCode": null,"city": "Ontario","custAcctNbr": "0017c00000yevRgAAI"}}}';
                Input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);}

			/*******DID Add Service Line Item ****////
            else if(Test.isRunningTest() && item.Name == 'DIDAddServiceItem'){
                System.debug('Test.isRunningTest() DIDAddServiceItem');
                testJsonInput = '{"addServiceItem": {"addServiceItemRequest": [{"activityCode": "N","itemSpecificationId": "1284","documentNumber": "3399085", "serviceItemValues":[{"value":"3091980457","label":"WTN"}],"locationId": "2984564","addressId": "78978987","lineNumber": "a1d6g000000RQpPAAW.0001","FRLId": "a1d6g000000RQpPAAW"}]}}';
                Input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);}

            // Add final input to the payload
            ctx.put('url', url);
            ctx.put('path', path);
            ctx.put('item', item);
            ctx.put('input', input);

            system.debug('input::' + input);
            system.debug('url::' + url);
            system.debug('path::' + path);

            // Invoke WebServiceCallout
            Map<String, Object> output;
            output = invoke(url, path, input,item.Id);
                system.debug('input::dk' + input);
                  //Save request and response
                item.vlocity_cmt__Response__c = String.valueOf(JSON.serialize(output));
                item.vlocity_cmt__Request__c = String.valueOf(JSON.serialize(input));
                update item;

                List<vlocity_cmt__OrchestrationItem__c> itemList = new List<vlocity_cmt__OrchestrationItem__c>();
                itemList.add(item);

                if(item.Name == TaskName_SIPCreateShellPSR && !Test.isRunningTest()){ XOMAutoTask_AttributeFulFillment.updateAttribute(itemList);
                }

            try {



                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object> { 'request' => requestType, 'response' => responseType, 'interface' => taskName, 'system' => 'M6', 'status' => responseStatus[0].message, 'convertToXML' => true, 'orderNumber' => orderNumber, 'orchestrationItemId' => item.Id, 'errorMessage' => responseStatus[0].message, 'errorCode' => responseStatus[0].code, 'documentNumber' => documentNumber, 'relatedTo' => orderId };
                APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);

            } catch (Exception ex) {

            String addExMessage = ex.getMessage();
                Map<String,Object> createTaskInputMap =new Map<String,Object> {'Description'=>ex.getMessage(), 'Subject'=>'M6 OM Exception', 'Priority'=>'High', 'InterfaceName'=>'AddServiceItemL1', 'WhatId'=> orderId};
                ftr_Logger.write(ex);
                APILogger log = new APILogger();
                log.createEntry(new Map<String, Object>{'request' => requestType, 'response' => responseType, 'interface' => [SELECT Name FROM vlocity_cmt__OrchestrationItem__c WHERE Id =: item.Id].Name, 'system' => 'M6', 'status' => responseStatus != null ? responseStatus[0].message : 'Error', 'convertToXML' => true, 'orderNumber' => orderNumber, 'orchestrationItemId' => item.Id, 'errorMessage' => responseStatus != null ? responseStatus[0].message : ex.getMessage(), 'errorCode' => responseStatus != null ? responseStatus[0].code : '500', 'documentNumber' => documentNumber, 'relatedTo' => orderId }, new Map<String, Object>());
                ftr_OrderManagementHelper.CreateTask( createTaskInputMap) ;
                throw ex;
            }


            // Post_Invoke
            // Add final input to the payload
            ctx.put('output', output);
            System.debug('::::: ctx New'+ctx);
            System.debug('Executing updateDatanase below Line 232');
            updateDatabase();
            // if(!Test.isRunningTest()) {
            //     System.debug('::::: ctx New Update');
            //     updateDatabase(); ///invoking update database method
            // }

        } catch (CalloutException ex) { // Capture recoverable exception and notify OM to retry
            ftr_Logger.write(ex);
            throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException ('Callout exception ' + ex + ': trying to retry');
        } catch (Exception ex) { ftr_Logger.write(ex); throw ex;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_M6BaseSystemInterface.executeItem');
        }
    }

    /**
* This method is called at the end of the batch
* @param  url  base URL for the batch
* @param  path path for the batch
*/
    global virtual void endBatch(String url, String path) {
        // Do nothing
        ftr_Logger.writeInfo('Enter ftr_SIPM6BaseSystemInterface.endBatch');
        ftr_Logger.writeInfo('Exit ftr_SIPM6BaseSystemInterface.endBatch');
    }


    /**
* update DB,
* from XOMOrchestrationInterfaces, executed when it safe to do it.
*/
    public void updateDatabase() {
        ftr_Logger.writeInfo('Enter ftr_SIPM6BaseSystemInterface.updateDatabase');

        try {
            System.debug(' ::::: ctx.get(item)'+ctx.get('item'));
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
            // if(item.Name == TaskName_SIPCreateShellPSR){

            //     executeResponseDR(ctx,DR_SIPDocumentNumber);
            // }
            // else if(item.Name == DR_SIPAddServiceItemL1){

            //     executeResponseItemDR(ctx,DR_SIPAddServiceItemL1);
            // }
        } catch (Exception ex) {
            ftr_Logger.write(ex);
        } finally {
            ftr_Logger.writeInfo('Exit ftr_SIPM6BaseSystemInterface.updateDatabase');
        }
    }



    /**
* This method is called from executeItem to create M6 RequestType
*
* @return         return the M6 SOAP API method name
*/
    public virtual String getOrchestrationTaskName() { throw new ftr_M6SystemInterfaceException('Must be implemented in the child class.');
    }

    /**
* This method is called from executeItem to create M6 RequestType
*
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  input payload to be used to construct
* @return         M6 RequestType object to be sent
*/
    global virtual Object createM6RequestType(String url, String path, Map<String, Object> input) { throw new ftr_M6SystemInterfaceException('Must be implemented in the child class.');

    }

    /**
* This method is called from executeItem to create process response
*
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  respType M6 ResponseType to process
* @return         output object to be processed
*/
    global virtual Map<String, Object> processM6ResponseType(String url, String path, Object respType) { throw new ftr_M6SystemInterfaceException('Must be implemented in the child cleass.');
    }

    /**
* This method is called to execute the actual M6 SOAP API callout
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  input payload prepared by the DRs
* @return      output JSON data returned
*/
    private Map<String, Object> invoke(String url, String path, Map<String, Object> input,Id itemId) {
        String ItemState = [SELECT vlocity_cmt__State__c FROM vlocity_cmt__OrchestrationItem__c WHERE Id =: itemId].vlocity_cmt__State__c;
        try {
        system.debug('I am in invoke Method'+input);
        system.debug('I am in invoke Method'+ JSON.serialize(input));
        //requestType = createM6RequestType(url, path, input);
        
        //System.debug('request--> '+ JSON.serialize(requestType));


        // TODO...
        taskName = getOrchestrationTaskName();

         if(taskName == TaskName_CreateEndUserLocation){

            Map<String, Object> output = new  Map<String, Object>();
            Map<String, String> collectAddress = new  Map<String, String>();
            Map<String, String> collectLocation = new  Map<String, String>();
            
            
            Map<String, Object> createServiceLocationRequestMap = (Map<String, Object>)input.get('createServiceLocation');
            Map<String, Object> requestMap = (Map<String, Object>)createServiceLocationRequestMap.get('createServiceLocationRequest');
            Map<String, Object> priLocMap = (Map<String, Object>)requestMap.get('priloc');
            List<Map<String, Object>> endUserPriLocationListMap = new List<Map<String, Object>>();

            if(Test.isRunningTest()) {
                List<Object> pricLocList = (List<Object>)priLocMap.get('endUserLocation');
                Map<String, Object> mapStringObj = new Map<String, Object>();
                for(Object obj:pricLocList) {
                    mapStringObj = (Map<String,Object>)Json.deserializeUntyped(Json.serialize(obj));
                    endUserPriLocationListMap.add(mapStringObj);
                }
            } else { endUserPriLocationListMap = (List<Map<String,Object>>) priLocMap.get('endUserLocation');
            }

            

            System.debug('###' + endUserPriLocationListMap);
            
            String documentNumber = String.valueOf(requestMap.get('documentNumber'));

              if(!endUserPriLocationListMap.isEmpty()){

                for(Integer i = 0; i < endUserPriLocationListMap.size(); i++){
                    
                    
                    ftr_SIPM6CreateEndUserLocSystemInterface newInterface = new ftr_SIPM6CreateEndUserLocSystemInterface();
                    requestType = newInterface.createM6RequestTypeNew(url, path, String.valueOf(endUserPriLocationListMap[i].get('LocationName')), documentNumber ,String.valueOf(endUserPriLocationListMap[i].get('StreetName')),String.valueOf(endUserPriLocationListMap[i].get('City')), String.valueOf(endUserPriLocationListMap[i].get('State')), String.valueOf(endUserPriLocationListMap[i].get('postalCode')),String.valueOf(endUserPriLocationListMap[i].get('WCCLLISWITCH')));
                    
                    setPortValues();
                    responseType = (ftr_PSRService.createServiceLocationResponseValueType)this.port.createServiceLocation((ftr_PSRService.createServiceLocationRequestType)requestType);
                    
                    responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.createServiceLocationResponseValueType) responseType).statusMessage);
                    
                    if(responseStatus.get(0).code != '0' && responseStatus.get(0).message != 'External server did not return any content'){
                        System.debug('responseStatus.get(0).code= '+ responseStatus.get(0).code);
                        throw new ftr_M6SystemInterfaceException(responseStatus.get(0).message);
                        }
                    if ((ftr_PSRService.createServiceLocationResultType)((ftr_PSRService.createServiceLocationResponseValueType) responseType).createServiceLocationResult != null)
                    documentNumber = String.valueOf(((ftr_PSRService.createServiceLocationResultType)((ftr_PSRService.createServiceLocationResponseValueType) responseType).createServiceLocationResult).documentNumber);

                        output = newInterface.processM6ResponseTypeNew(url, path, responseType, String.valueOf(endUserPriLocationListMap[i].get('DIDLocationId')));
                        collectAddress.put(String.valueOf(endUserPriLocationListMap[i].get('DIDLocationId')),String.valueOf(output.get('addressId')));
                        collectLocation.put(String.valueOf(endUserPriLocationListMap[i].get('DIDLocationId')),String.valueOf(output.get('locationId')));
    
                }

                  
              }

  
            List<ftr_DID_Location_Details__c> didLocUpdate = new List<ftr_DID_Location_Details__c>();
            List<ftr_DID_Location_Details__c> didLoc = [Select Id, PremisesId__c,LocationId__c, AddressId__c,StreetAddress__c,OrderId__c from ftr_DID_Location_Details__c where Id=:collectAddress.keyset()];
           
            
            for(ftr_DID_Location_Details__c dLoc: didLoc){
                
               
                dLoc.LocationId__c = String.valueOf(collectLocation.get(dLoc.Id));
                dLoc.AddressId__c = String.valueOf(collectAddress.get(dLoc.Id));
                didLocUpdate.add(dLoc);
            }
            if(!didLocUpdate.isEmpty()){ update didLocUpdate;
            }

            return output;
           
         }
        else if (taskName == TaskName_DIDAddServiceItem) {
            System.debug('Updated TaskName_DIDAddServiceItem Executed');
            Map<String, Object> output = new  Map<String, Object>();
            Map<String,Object> serviceItemReq = (Map<String,Object>)input.get('addServiceItem');  // fetch root node from Map input
            ftr_DIDM6AddServiceItemSystemInterface newInterface = new ftr_DIDM6AddServiceItemSystemInterface();
        	system.debug(' this.serviceItemReq ='+serviceItemReq);
            
            List<Map<String,Object>> mapDidLocations = new List<Map<String,Object>>(); //fetch serviceItemRequest node from root node
            
            if(Test.isRunningTest()) {
                List<Object> liDiDLoc = (List<Object>)serviceItemReq.get('addServiceItemRequest');
                Map<String, Object> mapStringObj = new Map<String, Object>();
                for(Object obj:liDiDLoc) {
                    mapStringObj = (Map<String,Object>)Json.deserializeUntyped(Json.serialize(obj));
                    mapDidLocations.add(mapStringObj);
                }
            } else { mapDidLocations = (List<Map<String,Object>>)serviceItemReq.get('addServiceItemRequest'); //fetch serviceItemRequest node from root node
            }


            System.debug('mapDidLocations =' + mapDidLocations);
			System.debug('mapDidLocations.size() = ' + mapDidLocations.size()); 
             if(!mapDidLocations.isEmpty()){
                 for(Integer i = 0; i < mapDidLocations.size(); i++){
                     
					requestType = newInterface.createM6RequestTypeDID(url, path, mapDidLocations[i]);
					setPortValues();
					responseType= (ftr_PSRService.addServiceItemResponseValueType)this.port.addServiceItem((ftr_PSRService.addServiceItemRequestType)requestType);
            		responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.addServiceItemResponseValueType) responseType).statusMessage);
                     if(responseStatus.get(0).code != '0' && responseStatus.get(0).message != 'External server did not return any content'){
                        System.debug('responseStatus.get(0).code');
            			throw new ftr_M6SystemInterfaceException(responseStatus.get(0).message);
        				}
            		if ((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult != null)
					documentNumber = String.valueOf(((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult).documentNumber);

					output = newInterface.processM6ResponseType(url, path, responseType);
                     
                 }
					/*System.debug('Response Type Execution After the last location');
                	responseType= (ftr_PSRService.addServiceItemResponseValueType)this.port.addServiceItem((ftr_PSRService.addServiceItemRequestType)requestType);
            		responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.addServiceItemResponseValueType) responseType).statusMessage);
            		if(responseStatus.get(0).code != '0' && !(responseStatus.get(0).message.contains('trying to retry'))){
                        System.debug('responseStatus.get(0).code');
            			throw new ftr_M6SystemInterfaceException(responseStatus.get(0).message);
        				}
                    if ((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult != null)
					documentNumber = String.valueOf(((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult).documentNumber);
					
					output = newInterface.processM6ResponseType(url, path, responseType);*/
                 
             }
            return output;
         }  

         else
         {

            system.debug('I am in invoke Method'+input);
            system.debug('I am in invoke Method'+ JSON.serialize(input));
            requestType = createM6RequestType(url, path, input);

        System.debug('request--> '+ JSON.serialize(requestType));
        //system.debug('TaskName'+taskName);
        if (taskName == TaskName_SIPCreateShellPSR) {
            // PSR_ServicePort -> WebserviceCallout(...)
            setPortValues();
            responseType= (ftr_PSRService.createPsrResponseType)this.port.CreateShellPSR((ftr_PSRService.createShellPsrRequestType)requestType);
            responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.createPsrResponseType) responseType).statusMessage);
            if(responseStatus.get(0).code != '0' && responseStatus.get(0).message != 'External server did not return any content'){
                        System.debug('responseStatus.get(0).code= '+ responseStatus.get(0).code);
                        throw new ftr_M6SystemInterfaceException(responseStatus.get(0).message);
                        }
            if ((ftr_PSRService.createPsrResultType)((ftr_PSRService.createPsrResponseType) responseType).createPsrResult != null)
                documentNumber = String.valueOf(((ftr_PSRService.createPsrResultType)((ftr_PSRService.createPsrResponseType) responseType).createPsrResult).documentNumber);
            

        } else if (taskName == TaskName_AddServiceItem) {
            // PSR_ServicePort -> WebserviceCallout(...)
            setPortValues();
            responseType= (ftr_PSRService.addServiceItemResponseValueType)this.port.addServiceItem((ftr_PSRService.addServiceItemRequestType)requestType);
            responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.addServiceItemResponseValueType) responseType).statusMessage);
            if(responseStatus.get(0).code != '0'){
                        System.debug('responseStatus.get(0).code= '+ responseStatus.get(0).code);
            			throw new ftr_M6SystemInterfaceException(responseStatus.get(0).message);
        				}
            if ((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult != null)
                documentNumber = String.valueOf(((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult).documentNumber);

        } else if (taskName == TaskName_SIPAddServiceItemL2) {
            // PSR_ServicePort -> WebserviceCallout(...)
            setPortValues();
            responseType = (ftr_PSRService.addServiceItemResponseValueType)this.port.addServiceItem((ftr_PSRService.addServiceItemRequestType)requestType);
            responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.addServiceItemResponseValueType) responseType).statusMessage);
            if(responseStatus.get(0).code != '0' && responseStatus.get(0).message != 'External server did not return any content'){
                        System.debug('responseStatus.get(0).code= '+ responseStatus.get(0).code);
            			throw new ftr_M6SystemInterfaceException(responseStatus.get(0).message);
        				}
            if ((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult != null)
                documentNumber = String.valueOf(((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult).documentNumber);


             /***Create End User Location ***////

			}
            // else if (taskName == TaskName_CreateEndUserLocation)
            // {
            //    System.debug('requestenduser--> '+ taskName);
            // // PSR_ServicePort -> WebserviceCallout(...)
            // setPortValues();
            // responseType = (ftr_PSRService.createServiceLocationResponseValueType)this.port.createServiceLocation((ftr_PSRService.createServiceLocationRequestType)requestType);
            // System.debug('responseTypeenduser--> '+ responseType);
            //     responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.createServiceLocationResponseValueType) responseType).statusMessage);
            // if ((ftr_PSRService.createServiceLocationResultType)((ftr_PSRService.createServiceLocationResponseValueType) responseType).createServiceLocationResult != null)
            // documentNumber = String.valueOf(((ftr_PSRService.createServiceLocationResultType)((ftr_PSRService.createServiceLocationResponseValueType) responseType).createServiceLocationResult).documentNumber);

            // }
            else if (taskName == TaskName_SIPSubmitPSR) {
            // PSR_ServicePort -> WebserviceCallout(...)
            setPortValues();
            responseType = (ftr_PSRService.finishOrderResponseValueType)this.port.finishOrder((ftr_PSRService.finishOrderRequestType)requestType);
            responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.finishOrderResponseValueType) responseType).statusMessage);
            if(responseStatus.get(0).code != '0' && responseStatus.get(0).message != 'External server did not return any content'){
                        System.debug('responseStatus.get(0).code= '+ responseStatus.get(0).code);
            			throw new ftr_M6SystemInterfaceException(responseStatus.get(0).message);
        				}
            if ((ftr_PSRService.finishOrderResultType)((ftr_PSRService.finishOrderResponseValueType) responseType).finishOrderResult != null)
               documentNumber = String.valueOf(((ftr_PSRService.finishOrderResultType)((ftr_PSRService.finishOrderResponseValueType) responseType).finishOrderResult).documentNumber);

        }
        else if (taskName == TaskName_SIPCheckM6Account) {
            System.debug('TaskName_SIPCheckM6Account' + TaskName_SIPCheckM6Account);
            // PSR_ServicePort -> WebserviceCallout(...)
            setPortValues();
            responseType= (ftr_PSRService.createCustomerAccountResponseType)this.port.createCustomerAccount((ftr_PSRService.createCustomerAccountRequestType)requestType);
             System.debug('responseType --> ' + responseType);
            responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.createCustomerAccountResponseType) responseType).statusMessage);
            if(responseStatus.get(0).code != '0' && !(responseStatus.get(0).message.contains('Record Exists'))){
                System.debug('responseStatus.code = ' + responseStatus.get(0).code );
                throw new ftr_M6SystemInterfaceException(responseStatus.get(0).message);
                }
            if ((ftr_PSRService.CreateCustomerAccountResult)((ftr_PSRService.createCustomerAccountResponseType) responseType).CreateCustomerAccountResult != null)
                //documentNumber = String.valueOf(((ftr_PSRService.CreateCustomerAccountResult)((ftr_PSRService.createCustomerAccountResponseType) responseType).CreateCustomerAccountResult).documentNumber);
            System.debug('responseStatus--> ' + responseStatus);
        }
		/*else if (taskName == TaskName_DIDAddServiceItem) {
            // PSR_ServicePort -> WebserviceCallout(...)
            setPortValues();
            responseType= (ftr_PSRService.addServiceItemResponseValueType)this.port.addServiceItem((ftr_PSRService.addServiceItemRequestType)requestType);
            responseStatus = ((ftr_PSRService.StatusMessageType[])((ftr_PSRService.addServiceItemResponseValueType) responseType).statusMessage);
            if ((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult != null)
			documentNumber = String.valueOf(((ftr_PSRService.addServiceItemResultType)((ftr_PSRService.addServiceItemResponseValueType) responseType).addServiceItemResult).documentNumber);
        }*/
		else {
             System.debug('response-->123');
            throw new ftr_M6SystemInterfaceException('Invalid Orchestration Task: ' + taskName);
        }

        System.debug('response--> '+ JSON.serialize(responseType));

        Map<String, Object> output = processM6ResponseType(url, path, responseType);

        return output;
       }
     }
	 Catch(Exception ex)
     {
         System.debug('Exception Caught for Task***');
			String addExMessage = ex.getMessage();
         Map<String,Object> createTaskInputMap =new Map<String,Object>{ 'Description' => ex.getMessage(), 'Subject' => 'M6 OM Exception', 'Priority' => 'High', 'InterfaceName' => 'AddServiceItemL1', 'WhatId' => orderId};
            System.debug('createTaskInputMap :'+ createTaskInputMap);

                ftr_Logger.write(ex);

                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object> { 'request' => requestType, 'response' => responseType, 'interface' => [SELECT Name FROM vlocity_cmt__OrchestrationItem__c WHERE Id =: itemId].Name, 'system' => 'M6', 'status' => responseStatus != null ? responseStatus[0].message : 'Error', 'convertToXML' => true, 'orderNumber' => orderNumber, 'orchestrationItemId' => itemId, 'errorMessage' => responseStatus != null ? responseStatus[0].message : ex.getMessage(), 'errorCode' => responseStatus != null ? responseStatus[0].code : '500', 'documentNumber' => documentNumber, 'relatedTo' => orderId
                };
                APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);
                     ftr_OrderManagementHelper.CreateTask( createTaskInputMap) ;

                throw ex;
		//return new Map<String,Object>();
     }
    }

    /**
* This method returns the initial JSON payload from the given OrchestrationItem item
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  item Orchestration Item
* @return      initial payload
*/
    Private Map<String, Object> getInputPayload(String url, String path, vlocity_cmt__OrchestrationItem__c item) {
        
        String serviceAccount ='';
        system.debug('@@@@FRID'+item.vlocity_cmt__fulfilmentRequestLineId__c+' '+JSON.serialize(item));
        vlocity_cmt__FulfilmentRequestLine__c frl = [SELECT Id, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c,
                                                     vlocity_cmt__JSONAttribute__c, vlocity_cmt__Action__c, vlocity_cmt__LineNumber__c, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.Name,
                                                     vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber
                                                     FROM vlocity_cmt__FulfilmentRequestLine__c
                                                     WHERE Id=:item.vlocity_cmt__fulfilmentRequestLineId__c];
        system.debug('@@@@Tou'+frl);

        String jsonAttribute = frl.vlocity_cmt__JSONAttribute__c;
        serviceAccount = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_SERV_ACCT');
        system.debug('@@@@serviceAccount'+serviceAccount);
        Map<String, List<Object>> described_by = new Map<String, List<Object>>();
        Map<String, Object> payload = new Map<String, Object> {
            'service_account'=> serviceAccount,
            'order_id' => frl.vlocity_cmt__FulfilmentRequestID__r.Id,
            'order_object_id' => frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c,
            'order_number' => frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber,
                'account_id' => frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c,
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
               system.debug('@@@@payload'+payload);

            
        Map<String, Object> attrValMap = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
        vlocity_cmt__Attribute__c[] myAttribs = [SELECT Id, vlocity_cmt__Code__c, vlocity_cmt__AttributeCategoryCode__c FROM vlocity_cmt__Attribute__c WHERE vlocity_cmt__Code__c=:attrValMap.keySet()
                                                 ORDER BY vlocity_cmt__AttributeCategoryCode__c];


        Set<String> myCategoryCode = new Set<String>();
        for (vlocity_cmt__Attribute__c attr : myAttribs) {
            List<Object> categoryAttribs;
            if (!myCategoryCode.contains(attr.vlocity_cmt__AttributeCategoryCode__c)) {
                categoryAttribs = new List<Object>();
                described_by.put(attr.vlocity_cmt__AttributeCategoryCode__c, categoryAttribs);
                system.debug('described_by'+described_by);
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

        system.debug('@@@@afterpayload'+payload);
        return payload;
    }

    /**
* This method returns the JSON payload massaged by the RequestItem DataRaptor
* @param  input payload to be massaged
* @param  requestItemDRName Datarapotor name
* @return      payload massaged by RequestItem DR
*/
    private Map<String, Object> executeRequestItemDR(Map<String, Object> input, String requestItemDRName) {

        System.debug('::::: input maximize'+input);
        System.debug('::::: requestItemDRName'+requestItemDRName);
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
        system.debug('input'+input);

        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(input, requestDRName);

         system.debug('input'+input);


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
		System.Debug('Executing executeResponseAttrsDR below Line 635');
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
		System.Debug('Executing executeResponseItemDR below Line 658');
        Map<String,Object> DRinput =new Map<String,Object>();
        Map<String,Object> DRinputMap =new Map<String,Object>();

        System.debug('::: ctx.get(output)'+ctx.get('output'));
        Map<String,Object> ctxOutput = (Map<String,Object>)ctx.get('output');

        System.debug('::: ctxOutput'+ctxOutput);
        System.debug('::: FulfilmentReqLineId'+FulfilmentReqLineId);
        DRinputMap.put('Id',FulfilmentReqLineId);
        DRinputMap.putAll(ctxOutput);
        System.debug('::: DRinputMap'+DRinputMap);
        DRinput.put('output',DRinputMap);
        System.debug('::: DRinput'+DRinput);
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(DRinput, responseItemDRName);
        System.debug('::: result '+result);
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
		System.debug('Executing executeResponseDR below Line 685');
        Map<String,Object> DRinput =new Map<String,Object>();
        Map<String,Object> DRinputMap =new Map<String,Object>();
        Map<String, Object> resultMap =new Map<String,Object>();

       if(taskName == TaskName_DIDAddServiceItem){
				ftr_PSRService.addServiceItemResponseValueType didResponse = (ftr_PSRService.addServiceItemResponseValueType)responseType;
                Map<String,Object> ctxOutput = (Map<String,Object>)ctx.get('output');

                DRinputMap.put('Id',FulfilmentReqLineId);
           		System.debug('didResponse.statusMessage.get(0).code = ' + didResponse.statusMessage.get(0).code);
           		if(didResponse.statusMessage.get(0).code == '0')
                {
                    DRinputMap.put('isDidCompleted',true);
                }
                DRinput.put('output',DRinputMap);
                system.debug('DRinput-->'+json.serialize(DRinput));
                system.debug('responseDRName-->'+responseDRName);
                vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(DRinputMap, responseDRName);

                resultMap = result.convertToMap();
                System.Debug('executeResponseDR -> resultMap =  '+ resultMap);
           
       } else if(taskName == TaskName_SIPCreateShellPSR){

            Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
            Order orderInput = [SELECT Id, vlocity_cmt__OrchestrationPlanId__c, Order_Stage__c, vlocity_cmt__OrderStatus__c FROM Order WHERE Id=: orderId];
            Set<Id> fulfilmentRequestIds = new Set<Id>();
            String jsonAttribute =''; 
           
            List<vlocity_cmt__FulfilmentRequest__c> fulfilmentRequest = [Select Id,Name from vlocity_cmt__FulfilmentRequest__c where vlocity_cmt__orchestrationPlanId__c=: orderInput.vlocity_cmt__OrchestrationPlanId__c];
            
            if(!fulfilmentRequest.isEmpty()){
                for(vlocity_cmt__FulfilmentRequest__c frl:fulfilmentRequest){ fulfilmentRequestIds.add(frl.Id);
                }
            }

            List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineS =[Select Id,Name,vlocity_cmt__JSONAttribute__c  from vlocity_cmt__FulfilmentRequestLine__c where vlocity_cmt__FulfilmentRequestID__c IN : fulfilmentRequestIds And (vlocity_cmt__Product2Id__r.productCode =: 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010') ];

            String waitSemaphore = 'true';
            for(vlocity_cmt__FulfilmentRequestLine__c frLine: fulfilmentRequestLineS){

                if(frLine.Id == FulfilmentReqLineId && documentNumber != null ){
                    Map<String, Object> attrVals = new Map<String, Object>{ 'documentNumber' => documentNumber };
    
                    frLine.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frLine.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                    frlsToUpdateMap.put(frLine.Id,frLine);
                } else {
                    jsonAttribute = frLine.vlocity_cmt__JSONAttribute__c;
                    if(jsonAttribute != null){
                        String waitSemaphoreAttribute = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_WaitSemaphore');

                        if(waitSemaphoreAttribute != 'true'){

                            Map<String, Object> attrVals = new Map<String, Object>{ 'ATTR_WaitSemaphore' => waitSemaphore };
            
                            frLine.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frLine.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                            frlsToUpdateMap.put(frLine.Id,frLine);
                            waitSemaphore = 'false';

                        }
                    }
                    
                }
            }
           
            System.debug('frlsToUpdateMap: ATTR_WaitSemaphore: size(): '+ frlsToUpdateMap.values().size());
    
            if(frlsToUpdateMap.values().size()>0){
                try{
                    List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            for (Database.Error err : result.getErrors()){
                            System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                            }
                        } else {
                            resultMap.put('ItemToUpdate', frlsToUpdateMap );

                        }
                    }
                
                    
                } catch(Exception e) {
                    System.debug('Exception in Subscriber..'+ e.getMessage());
                
                }
            }


       } else {
           
                Map<String,Object> ctxOutput = (Map<String,Object>)ctx.get('output');

                DRinputMap.put('Id',FulfilmentReqLineId);
                DRinputMap.putAll(ctxOutput);

                DRinput.put('output',DRinputMap);
                system.debug('DRinput-->'+json.serialize(DRinput));
                system.debug('responseDRName-->'+responseDRName);
                vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(DRinput, responseDRName);

                resultMap = result.convertToMap();
                System.Debug('executeResponseDR -> resultMap =  '+ resultMap);
       }

        
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


}