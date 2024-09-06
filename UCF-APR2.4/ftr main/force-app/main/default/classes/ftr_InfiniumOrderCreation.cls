public with sharing class ftr_InfiniumOrderCreation {
    public class ftr_CreateInfiniumOrderException extends Exception {}
    private Map<String, Object> inputMap;
    @TestVisible private static IntegrationAPIConfig__mdt apiconfigs;
    @TestVisible private static NamedCredential apigeeCred;
    Boolean respError = false;

    //Constants
    private static final String AIP_CONFIG_SETTINGS = 'Infinium_API_Authentication';
    private static final String AIPGEE_CRED = 'InfiniumApigeeCredentials';

    //Error messages //TODO: to be put in Custom Label
    private static final String ERR_NULL_INPUT = 'Null ApiKey/Timeout';
    private static final String ERR_NAMEDCRED_MISSING = 'InfiniumApigeeCredentials Named Credential missing';
    private static final String PURCHASED_MAIN = '9311';
    private static final String RENTED_MAIN = '2362';

    private static final String PURCHASED_SUB = '000';
    private static final String RENTED_SUB = '001';

    private static final Integer VENDOR_ID = 0 ;
    private static final String VENDOR_NAME = '';

    private static final String PO_REQUIRED_Y = 'Y';
    private static final String PO_REQUIRED_N = 'N';

    private static final String IS_TAXABLE_Y = 'Y';
    private static final String IS_TAXABLE_N = 'N';

    private static final String SUFFIX = '';
    private static final String SUB_PROJECT = '';
    
    private static final String PURCHASED_ITEM_CODE = 'EXP50';
    private static final String RENTED_ITEM_CODE = 'EXP50';
    private static final String RENTED_ITEM_CODE_EXP = 'PRVSN-FTR-BUNDLE';
    
    private static final String PURCHASED_COST_CENTER = '032';
    private static final String RENTED_COST_CENTER = '000';

    private static final String PURCHASED_COST_CODE = '227';
    private static final String RENTED_COST_CODE = '502';

    // set static variables
    static {
        // query for the metadata record
        List<IntegrationAPIConfig__mdt> apiConfig = [SELECT ApiKey__c, Timeout__c,Authorization_Header__c, Endpoint__c FROM IntegrationAPIConfig__mdt WHERE DeveloperName =: AIP_CONFIG_SETTINGS LIMIT 1];


        
        // throw an exception if nothing is found, set the variable otherwise
        if (! Test.isRunningTest() && (apiConfig.isEmpty() || String.isBlank(apiConfig[0].ApiKey__c) || apiConfig[0].Timeout__c == null)) {
            throw new ftr_CreateInfiniumOrderException(ERR_NULL_INPUT);
        }
        
        apiconfigs = apiConfig[0];
       
        List<NamedCredential> apigeeCreds = [SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName =: AIPGEE_CRED];
        // throw an exception if nothing is found, set the variable otherwise
        if (! Test.isRunningTest() && apigeeCreds.isEmpty()) {
            throw new ftr_CreateInfiniumOrderException(ERR_NAMEDCRED_MISSING);
        }

        apigeeCred = apigeeCreds[0];

    }

    public static String calculateDueDate() {
        Integer numberOfWorkingDaysToAdd = 6;
        Datetime startDate = Date.today();
        
        while (numberOfWorkingDaysToAdd > 0) {
            startDate = startDate.addDays(1);
            
            // Check if the day is not a weekend (Saturday or Sunday)
            if (startDate.format('EEEE') != 'Saturday' && startDate.format('EEEE') != 'Sunday') {
                numberOfWorkingDaysToAdd--;
            }
        }
        
        String formattedDate = startDate.format('yyyy-MM-dd');
        
        return formattedDate;
    }

    public static void sendRequest(String orderId) {
        Order infiniumOrder = [SELECT Id, Name, OrderNumber, Managers_Name__c, Paid_Expedite__c, Technical_Contact_Name__c, Account_Name__c FROM Order WHERE Id =:orderId];
        List<String> typeOfPhones = new List<String>();
        typeOfPhones.add('Yealink Phones');
        typeOfPhones.add('Conference Models');
        typeOfPhones.add('Poly Phones');
        typeOfPhones.add('ATA');
        
        List<String> typeOfAccessories = new List<String>();
        typeOfPhones.add('Other');
        typeOfPhones.add('Power Cord');
        typeOfPhones.add('Headsets');
        typeOfPhones.add('Phones Accessories');
        
        try {
            // Construct the payload
            
            Map<String, Object> payload = new Map<String, Object>();
            List<OrderItem> lineItems = [SELECT Id, OrderId, OrderItemNumber, vlocity_cmt__LineNumber__c, SNE_Code_MRC__c, SNE_Code_OTC__c, Quantity, UnitPrice, vlocity_cmt__UsageMeasurementId__r.vlocity_cmt__UnitOfMeasureElement__c, vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,  vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__RequestDate__c, Premise_Detail__c, Product2.Family, Product2.IsActive, Product2.vlocity_cmt__SpecificationSubType__c, Product2.vlocity_cmt__SubType__c FROM OrderItem WHERE 
            /* Product_Type__c IN ('Phones', 'Accessories') AND  */
            OrderId = :orderId AND Product2.Family IN ('UCF') AND Product2.IsActive = TRUE AND (Product2.vlocity_cmt__SpecificationSubType__c IN :typeOfPhones 
            OR
            Product2.vlocity_cmt__SubType__c IN :typeOfAccessories)];

            // SELECT Id, Name, vlocity_cmt__Type__c, vlocity_cmt__SpecificationSubType__c, vlocity_cmt__SubType__c FROM Product2 WHERE Product2.Family IN ('UCF') AND IsActive = TRUE AND (vlocity_cmt__SpecificationSubType__c IN ('Yealink Phones', 'Conference Models', 'Poly Phones', 'ATA') OR vlocity_cmt__SubType__c IN ('Other', 'Power Cord', 'Headsets', 'Phones Accessories'))

            Map<String, String> mapServAccEmailList = new Map<String, String>();
            List<ftr_DID_Location_Details__c> liLocationDetails = [SELECT Id, ServiceAccountId__r.Id, Email_List__c FROM ftr_DID_Location_Details__c WHERE OrderId__c = :orderId];
            for(ftr_DID_Location_Details__c liLocationDetail: liLocationDetails) {
                if(liLocationDetail.Email_List__c != null) {
                    List<String> emailList = liLocationDetail.Email_List__c.split(',');
                    mapServAccEmailList.put(liLocationDetail.ServiceAccountId__r.Id, emailList[0]);
                }
            }

            if(lineItems.size() > 0) {
                Set<Id> setServiceAccount = new Set<Id>();
                for(OrderItem lineItem: lineItems) {
                    setServiceAccount.add(lineItem.vlocity_cmt__ServiceAccountId__c);
                }
                // SELECT Id, Name, State__c, City__c, Order__c  FROM Service_Location__c WHERE Order__c = '80174000001V9AlAAK'
                List<Service_Location__c> liServLocation = [SELECT Id, Name, State__c, City__c, Order__c, Location_Name__c, Location_Address__c, Contact_Name__c, Contact_Phone__c, Shipping_Location__c  FROM Service_Location__c WHERE Order__c = :orderId];
                if(liServLocation.size() > 0) {
                    Map<String, String> mapServAcc = new Map<String, String>();
                    for(Service_Location__c servLoc: liServLocation) {
                        if(servLoc.City__c != null && servLoc.State__c != null) {
                            String key = servLoc.City__c + '_' + servLoc.State__c;
                            String locAddress = servLoc.Location_Address__c.replace(' ', '_');
                            System.debug(locAddress);
                            mapServAcc.put(locAddress, key);
                        }
                    }
                    // Map for Part Numbers
                    List<UCF_S_E_Item_Code__c> liSNEItemCode = [SELECT Id, DPI_S_E__c, Vlocity_UCF_Equipment_name__c, Equipment_name_on_PDW__c, Part_number__c FROM UCF_S_E_Item_Code__c];
                    Map<String, Set<String>> mapSNEItemCode = new Map<String, Set<String>>();

                    for(UCF_S_E_Item_Code__c sneItemCode :liSNEItemCode) {
                        if(mapSNEItemCode.containsKey(sneItemCode.DPI_S_E__c)) {
                            Set<String> setPartNumbers = mapSNEItemCode.get(sneItemCode.DPI_S_E__c);
                            setPartNumbers.add(sneItemCode.Part_number__c);
                            mapSNEItemCode.put(sneItemCode.DPI_S_E__c, setPartNumbers);
                            
                        } else {
                            Set<String> setPartNumbers = new Set<String>();
                            setPartNumbers.add(sneItemCode.Part_number__c);
                            mapSNEItemCode.put(sneItemCode.DPI_S_E__c, setPartNumbers);
                        }
                    }
                    
                    if(mapSNEItemCode.size() > 0) {
                        List<ftr_UCFExchangeDetail__c> liUCFExchangeDetails = [SELECT Id, DPI_Env__c, WC_CLLI__c, NPANXX__c, FICT__c, Exchange_Number__c, Description__c, State__c, TARIFF__c, TARIFF_Description__c, W_C__c, Exchange_Name__c, City__c, DPI_Environment__c, DPI_NPA_NXX__c, DPI_Study_Code__c, DPI_Wire_Center__c, NPR_Ship_To__c, DPI_Office_Code__c, EM_2024_Project__c, Tariff_Name__c FROM ftr_UCFExchangeDetail__c];
                        
                        Map<String, ftr_UCFExchangeDetail__c> mapKeyProjectId = new Map<String, ftr_UCFExchangeDetail__c>();
                        
                        for(ftr_UCFExchangeDetail__c exchangeDetails : liUCFExchangeDetails ) {
                            if(exchangeDetails.City__c != null && exchangeDetails.State__c != null) {
                                String key = exchangeDetails.City__c + '_' + exchangeDetails.State__c;
                                mapKeyProjectId.put(key, exchangeDetails);
                            }
                        }

                        List<Map<String, Object>> lines = new List<Map<String, Object>>();
                        
                        List<String> strLineIds = new List<String>();
                        List<Map<String, Object>> limapPayloads = new List<Map<String, Object>>();
                        String projectId = '';
                        String serviceLocationKey = '';
                        for(Service_Location__c servLoc : liServLocation) {
                            payload = new Map<String, Object>();
                            System.debug(servLoc);
                            payload.put('lineItemKey', infiniumOrder.OrderNumber + '-' + servLoc.Id);
                            Decimal totalPhonesQuanity = 0;
                            serviceLocationKey = infiniumOrder.OrderNumber + '-' + servLoc.Id;
                            String lineItemKey = '';
                            for(OrderItem lineItem: lineItems) {
                                Map<String, Object> line = new Map<String, Object>();
                                
                                lineItemKey = lineItem.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c + '_' + lineItem.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c;
                                System.debug(lineItemKey);

                                if(mapKeyProjectId.get(lineItemKey) != null) {
                                    projectId = String.valueOf(mapKeyProjectId.get(lineItemKey).EM_2024_Project__c);
                                }
                                System.debug(mapSNEItemCode.get(lineItem.SNE_Code_MRC__c));
                                System.debug(mapSNEItemCode.get(lineItem.SNE_Code_OTC__c));
                                if(mapSNEItemCode.containsKey(lineItem.SNE_Code_MRC__c) || mapSNEItemCode.containsKey(lineItem.SNE_Code_OTC__c)) {
                                    Set<String> partNumbers = lineItem.SNE_Code_MRC__c != null ? mapSNEItemCode.get(lineItem.SNE_Code_MRC__c) : mapSNEItemCode.get(lineItem.SNE_Code_OTC__c);
                                    System.debug(partNumbers.size());
                                    if(partNumbers != null && partNumbers.size() > 0) {
                                        for(String partNumber: partNumbers) {
                                            line.put('externalId', lineItem.Id); // <----AC1.3, Salesforce Ojbect/Line ID
                                            line.put('referenceId', infiniumOrder.OrderNumber + '-' + servLoc.Id); // <----"OrderId-ServiceLocationID"'
                                            line.put('extOrderId', infiniumOrder.OrderNumber); // <----AC1.2, Salesforce Order ID
                                            
                                            if(lineItem.SNE_Code_MRC__c != null) {
                                                line.put('main', RENTED_MAIN); // <----AC1.10, always 9311 for Purchased equip
                                                line.put('sub', RENTED_SUB); // <----AC1.10, always 000 for Purchased equip
                                                line.put('costCode', RENTED_COST_CODE); // <----AC1.10, always 227 for Purchased equip
                                                line.put('itemCode', String.join(mapSNEItemCode.get(lineItem.SNE_Code_MRC__c),'')); // <----AC1.6, Infinium Item Code
                                                // line.put('itemCode', 'EXP50'); // <----AC1.6, Infinium Item Code
                                                line.put('isTaxable', IS_TAXABLE_Y); //  <----Always "N" for Purchased equip
                                                line.put('costCenter', RENTED_COST_CENTER); // <----AC1.10, always 032 for Purchased equip
                                            }
                                            
                                            if(lineItem.SNE_Code_OTC__c != null) {
                                                line.put('main', PURCHASED_MAIN); // <----AC1.10, always 9311 for Purchased equip
                                                line.put('sub', PURCHASED_SUB); // <----AC1.10, always 000 for Purchased equip
                                                line.put('costCode', PURCHASED_COST_CODE); // <----AC1.10, always 227 for Purchased equip
                                                line.put('itemCode', String.join(mapSNEItemCode.get(lineItem.SNE_Code_OTC__c), '')); // <----AC1.6, Infinium Item Code
                                                // line.put('itemCode', 'EXP50'); // <----AC1.6, Infinium Item Code
                                                line.put('isTaxable', IS_TAXABLE_N); //  <----Always "N" for Purchased equip
                                                line.put('costCenter', PURCHASED_COST_CENTER); // <----AC1.10, always 032 for Purchased equip
                                            }

                                            // line.put('itemDesc', lineItem.Description); //
                                            line.put('quantity', lineItem.Quantity); //
                                            line.put('PORequired', PO_REQUIRED_Y); // <----AC1.10, always "Y"
                                            if(servLoc.Shipping_Location__c != 'Same as Service Location') {
                                                // line.put('shipToId', 'XBLOOMNGTO'); // <----AC1.7, Infinium ShipTo Code
                                                if(mapKeyProjectId.containsKey(lineItemKey)) {
                                                    line.put('shipToId', String.valueOf(mapKeyProjectId.get(lineItemKey).NPR_Ship_To__c)); // <----AC1.7, Infinium ShipTo Code
                                                }
                                            }
                                            if(servLoc.Shipping_Location__c == 'Same as Service Location') {
                                                line.put('shipToId', 'SEEBELOW'); // <----AC1.7, Infinium ShipTo Code
                                                line.put('requisition_detail_notes', 
                                                'DROP SHIP TO CUSTOMER'+
                                                '\nCustomer First and Last Name: '+ infiniumOrder.Technical_Contact_Name__c+
                                                '\nBusiness Name: ' +infiniumOrder.Account_Name__c+ 
                                                '\nService Address: '+servLoc.Location_Name__c + '\n'+ servLoc.Location_Address__c + '\n' + servLoc.Contact_Name__c + '\n' + servLoc.Contact_Phone__c+ // <----AC1.8, Local Manager name
                                                '\nSF: '+infiniumOrder.OrderNumber); // <----AC1.8, Local Manager name
                                            } else {
                                                line.put('requisition_detail_notes', 
                                                'SF:'+infiniumOrder.OrderNumber+
                                                '\nCustomer Name: '+ infiniumOrder.Account_Name__c+
                                                '\nService Address: '+servLoc.Location_Name__c + '\n'+ servLoc.Location_Address__c + '\n' + servLoc.Contact_Name__c + '\n' + servLoc.Contact_Phone__c); // <----AC1.8, Local Manager name
                                            }
                                            // line.put('deliverTo', infiniumOrder.Managers_Name__c); // <----AC1.8, Local Manager name
                                            line.put('deliverTo', mapServAccEmailList.get(lineItem.vlocity_cmt__ServiceAccountId__c)); // <----AC1.8, Local Manager name
                                            line.put('requiredDate', String.valueOf(calculateDueDate())); //
                                            // line.put('requiredDate', System.now().format('dd-MM-yyyy')); //
                                            
                                            // line.put('isEmpty', ''); // <----AC1.10, always 032 for Purchased equip
                                            strLineIds.add(lineItem.Id);
                                            lines.add(line);

                                            if(typeOfPhones.contains(lineItem.Product2.vlocity_cmt__SpecificationSubType__c)) {
                                                totalPhonesQuanity+= lineItem.Quantity;
                                            }
                                        }

                                    } else {
                                        // Service Location is not present
                                        Map<String, Object> logOutput = new Map<String, Object>();
                                        Map<String, Object> logInput = new Map<String, Object>();
                                        
                                        logInput.put('interface', 'InfiniumOrderCreation');
                                        logInput.put('orderNumber', infiniumOrder.OrderNumber);
                                        logInput.put('convertToXML', false);
                                        logInput.put('errorStackTrace', 'Part Number size zero');
                                        logInput.put('responseCode', 'Error');
                                        logInput.put('responseMessage', 'Part Numbers not present for the Order');
                                        
                                        APILogger log = new APILogger();
                                        log.createEntry(logInput, logOutput);
                                    }
                                } else {
                                    // Service Location is not present
                                    Map<String, Object> logOutput = new Map<String, Object>();
                                    Map<String, Object> logInput = new Map<String, Object>();
                                    
                                    logInput.put('interface', 'InfiniumOrderCreation');
                                    logInput.put('orderNumber', infiniumOrder.OrderNumber);
                                    logInput.put('convertToXML', false);
                                    logInput.put('errorStackTrace', 'Part Number size zero');
                                    logInput.put('responseCode', 'Error');
                                    logInput.put('responseMessage', 'Part Numbers not present for the Order');
                                    
                                    APILogger log = new APILogger();
                                    log.createEntry(logInput, logOutput);
                                }
                            }
                            if(lines.size() > 0) {
                                Map<String, Object> newLine = new Map<String, Object>();
                                newLine.put('referenceId', infiniumOrder.OrderNumber + '-' + servLoc.Id); // <----"OrderId-ServiceLocationID"'
                                newLine.put('extOrderId', infiniumOrder.OrderNumber); // <----AC1.2, Salesforce Order ID
                                newLine.put('main', lines[0].get('main'));
                                newLine.put('sub', lines[0].get('sub'));
                                newLine.put('costCode', lines[0].get('costCode'));
                                newLine.put('quantity', totalPhonesQuanity);
                                newLine.put('PORequired', lines[0].get('PORequired'));
                                newLine.put('deliverTo', lines[0].get('deliverTo'));
                                newLine.put('shipToId', lines[0].get('shipToId'));
                                newLine.put('isTaxable', lines[0].get('isTaxable'));
                                newLine.put('requiredDate', String.valueOf(calculateDueDate())); // YYYY-MM-DD
                                newLine.put('costCenter', lines[0].get('costCenter'));
                            
                                if(infiniumOrder.Paid_Expedite__c == true) {
                                    newLine.put('itemCode', 'PRVSN-FTR-EXP'); // <----AC1.6, Infinium Item Code
                                } else {
                                    newLine.put('itemCode', 'PRVSN-FTR-BUNDLE'); // <----AC1.6, Infinium Item Code
                                }
                                lines.add(newLine);
                                payload.put('lines', lines);
                                
                                if(mapKeyProjectId.get(lineItemKey) != null) {
                                    payload.put('projectId', mapKeyProjectId.get(lineItemKey).EM_2024_Project__c); // <----Infinium Blanket Project ID, based on exchange, changes each year (AC1.1)
                                }
                                
                                // payload.put('projectId', '4195687'); // <----Infinium Blanket Project ID, based on exchange, changes each year (AC1.1)   
                                System.debug(String.valueOf(projectId));
                                System.debug(payload);
                                limapPayloads.add(payload);
                            }
                        }
                        System.debug(limapPayloads);
                        if(limapPayloads.size() > 0) {
                            for(Map<String, Object> payloadMap :limapPayloads) {
                                // Convert payload to JSON
                                String jsonPayload = JSON.serialize(payloadMap);
                                System.debug(jsonPayload);
                                String lineItemIds = String.join(strLineIds,',');
                                httpCalloutInfinium(jsonPayload, lineItemIds, infiniumOrder.Id ,infiniumOrder.OrderNumber, String.valueOf(payloadMap.get('lineItemKey')));
                            }
                        }
                    }
                    else {
                        // Service Location is not present
                        Map<String, Object> logOutput = new Map<String, Object>();
                        Map<String, Object> logInput = new Map<String, Object>();
                        
                        logInput.put('interface', 'InfiniumOrderCreation');
                        logInput.put('orderNumber', infiniumOrder.OrderNumber);
                        logInput.put('convertToXML', false);
                        logInput.put('errorStackTrace', 'SNE codes size zero');
                        logInput.put('responseCode', 'Error');
                        logInput.put('responseMessage', 'SNE codes not present for the Order');
                        
                        APILogger log = new APILogger();
                        log.createEntry(logInput, logOutput);
                    }
                } else {
                    // Service Location is not present
                    Map<String, Object> logOutput = new Map<String, Object>();
                    Map<String, Object> logInput = new Map<String, Object>();
                    
                    logInput.put('interface', 'InfiniumOrderCreation');
                    logInput.put('orderNumber', infiniumOrder.OrderNumber);
                    logInput.put('convertToXML', false);
                    logInput.put('errorStackTrace', 'Service Location size zero');
                    logInput.put('responseCode', 'Error');
                    logInput.put('responseMessage', 'Service Location not present for the Order');
                    
                    APILogger log = new APILogger();
                    log.createEntry(logInput, logOutput);
                }
            } else {
                //  Line Item not present
                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object>();
                
                logInput.put('interface', 'InfiniumOrderCreation');
                logInput.put('orderNumber', infiniumOrder.OrderNumber);
                logInput.put('convertToXML', false);
                logInput.put('errorStackTrace', 'Order Product size zero');
                logInput.put('responseCode', 'Error');
                logInput.put('responseMessage', 'Order Product not present for the Order');
                
                APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);
            }
        } catch (Exception exc) {
            System.debug('getStackTraceString===='+exc.getStackTraceString());
            System.debug('getMessage===='+exc.getMessage());

            Map<String, Object> logOutput = new Map<String, Object>();
            Map<String, Object> logInput = new Map<String, Object>();
            
            logInput.put('interface', 'InfiniumOrderCreation');
            logInput.put('orderNumber', infiniumOrder.OrderNumber);
            logInput.put('convertToXML', false);
            logInput.put('errorStackTrace', exc.getStackTraceString());
            logInput.put('responseCode', 'Exception');
            logInput.put('responseMessage', exc.getMessage());
            
            APILogger log = new APILogger();
            log.createEntry(logInput, logOutput);
        }
    }

    @future(callout = true)
    public static void httpCalloutInfinium(String jsonPayload, String lineItemIds, String OrderId, String orderNumber, String serviceLocationOrderKey) {

        System.debug(jsonPayload);
        // Make HTTP request
        HttpRequest request = new HttpRequest();

        // Creds approach
        request.setEndpoint(apiconfigs.Endpoint__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiconfigs.Authorization_Header__c));
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', '0' );
        request.setHeader('apikey', apiconfigs.ApiKey__c);  
        request.setHeader('ESB-requestingApplication', 'SFDC');
        request.setHeader('ESB-securityInfo.userId', 'ESB_REG');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonPayload); 

        Http http = new Http();
        HttpResponse response = http.send(request);

        // Handle the response
        if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
            System.debug('Request sent successfully. Response: ' + response.getBody());
            // You can handle the response here as needed
        } else {
            System.debug('Request failed with status code: ' + response.getStatusCode() + ', Body: ' + response.getBody());
            // Handle error cases here
            // Create a task to log the failure with response body
            createTaskOnFailure(OrderId, serviceLocationOrderKey, response.getBody());
        }
        

        Map<String, Object> logOutput = new Map<String, Object>();
        Map<String, Object> logInput = new Map<String, Object>();
        logInput.put('request', request.getBody());
        logInput.put('response', JSON.deserializeUntyped(response.getBody()));
        logInput.put('interface', 'InfiniumOrderCreation');
        logInput.put('orderNumber', orderNumber);
        logInput.put('convertToXML', false);
        
        Object ResObject = JSON.deserializeUntyped(response.getBody()); 
        Map<String, Object> ResMap;
        
        if(ResObject InstanceOf List<Object>){
            ResMap = (Map<String,Object>)((List<Object>)ResObject).get(0);
            
        }else if (ResObject InstanceOf Map<String,Object>){
            ResMap = (Map<String,Object>) ResObject;
        }
        logInput.put('status', 'SUCCESS');
        logInput.put('responseCode', ResMap.get('FaultCode'));
        logInput.put('responseMessage', ResMap.get('title'));
        logInput.put('responseDetail', ResMap.get('detail'));
        
        APILogger log = new APILogger();
        log.createEntry(logInput, logOutput);
        System.debug(logOutput);
    }

    public static void createTaskOnFailure(String orderId, String serviceLocationOrderKey, String response) {
        // Create a Task record to log the failure
        
        Group grp = [Select Id from Group where Type = 'Queue' AND Name ='Network COE - UCaas']; 
        //Order ord = [SELECT Id, OrderNumber FROM Order WHERE Id =:orderId];
        
        Task failureTask = new Task();
        failureTask.Subject = 'Equipment order - Infinium - Fallout task - Create manual order';
        failureTask.WhatId = orderId;
        failureTask.Description = 'BPO needs to create Infinium order. Please use SF order # ' + serviceLocationOrderKey + ' on the notes to create the order.\nError : Handle the Order Creation manually \n\n'+response;
        failureTask.OwnerId = grp.Id;
        failureTask.Priority = 'High';
        failureTask.Status = 'Pending';

        // Insert the Task record
        try {
            insert failureTask;
            System.debug('Task created successfully for the failed Infinium order.');
        } catch (Exception e) {
            System.debug('Failed to create a task. Error: ' + e.getMessage());
            // Handle the exception, log, or perform any necessary actions.
        }
    }
}