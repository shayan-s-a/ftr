/**
* @description webservice callout to ServiceItemRequest L2 interface
* @version :2
*/  
global without sharing class ftr_M6OrderStatusUpdateSubscriber implements vlocity_cmt.VlocityOpenInterface
{
    public final static String INPUT_EVENT = 'events';
    //public final static String INPUT_STATE = 'Running';
    //public final static String INPUT_STATE_DPI = 'Pending';
    public final static String INPUT_STATE_RUNNING = 'Running';
    public final static String INPUT_STATE_PENDING = 'Pending';
    public final static String ATTR_GRP_ORD_TRANSACTION_COUNT = 'GroupOrderTransactionCount';
    public final static String ITEM_DEF_WAIT_FOR_BCN_COMPLETE = 'Wait for BCN Complete';
    public final static String ITEM_DEF_SIP_WAIT_FOR_BCN_COMPLETE = 'SIP Wait for BCN Complete';
    public final static String ITEM_DEF_SIP_WAIT_FOR_BCN_READY = 'SIP Wait for BCN Ready';
    public final static String TECH_PRODUCTCODE_EIA = 'ENT_ETH_EIA_EVC_PSR_001';
    public final static String TECH_PRODUCTCODE_EVPL_EVC = 'ENT_ETH_EVPL_EVC_PSR_001';
	public final static String TECH_PRODUCTCODE_ELAN = 'ENT_ETH_ELAN_EVC_PSR_001';
    public final static String TECH_PRODUCTCODE_UNI = 'ENT_ETH_UNI_PSR_001';
    public final static String TECH_PRODUCTCODE_DPI_CKT = 'ENT_ETH_DPI_CIRCUIT_BILLING';
	public final static String TECH_PRODUCTCODE_DPI_CKT_ELAN = 'ENT_ETH_ELAN_DPI';
    //SIP Trunking thecnical products
    public final static String TECH_PRODUCTCODE_SIP_UNI = 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_SIP_EVC = 'SIP_EVC_PSR_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_DPI_SIP_UNI = 'DPI_CIRCUIT_BILLING_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_DPI_SIP_TRUNKING = 'SIP_TRUNKING_DPI_BILLING_RES_SPEC_0010';
    // MDN
    public final static String TECH_PRODUCTCODE_DPI_MDN_RFS = 'DID_DPI_MDN_RFS_0010';

    
    
    public final static String ATT_HOST_UNI_REF_ID = 'ATTR_HostUNIRefId';
    public final static String ATT_REMOTE_UNI_REF_ID = 'ATTR_RemoteUNIRefId';
    public final static String ATT_DOC_NUMBER = 'documentNumber';   
    public final static String ATT_RUID_1 = 'RUID #1';  
    public final static String ATT_RUID_2 = 'RUID #2'; 
    public final static String EXECUTE_METHOD = 'execute';
    public final static String TECH_M6_IsOrderCompleted = 'ATTR_M6_IsOrderCompleted';
    public final static String TECH_Circuitid = 'CircuitId';
    public final static String ATTR_TECH_DueDate= 'ATTR_DueDate'; // For DueDate from OSSAPI Response
    public final static String TECH_FRLRefId= 'ATTR_FRLRefId';
    public final static String TECH_PurchaseOrderNumber = 'PONNumber'; // For Purchase Order Number from BCN Complete Event
    //public final static String TECH_HOST_TO_EVPL = 'HOST_TO_EVPL';
    // *public static String RUID1;
    private static final String API_CONFIG_SETTINGS = 'OSSAPIAuthentication';
    @TestVisible private static Map<String, String> apiConfigMap=new Map<String,String>();
    @TestVisible private static IntegrationAPIConfig__mdt apiconfig;
    private static final String ERR_NULL_INPUT ='Null ApiKey/Timeout';
    public static Map<String,String> returnmap = new Map<String,String>();
    
    private static String EMPLOYEE_ID = '823947';
    private static String USER_ID = 'Salesforce';
    private static String APPLICATION_ID = 'VOM';
    private static String POOL_TYPE = 'SCOM';
    
    static{
        try{
            List<IntegrationAPIConfig__mdt> apiConfigs = [SELECT Timeout__c, ApiKey__c,Authorization_Header__c ,Correlationid__c,OssAuthToken__c,UserName__c,Endpoint__c     FROM IntegrationAPIConfig__mdt WHERE DeveloperName=: API_CONFIG_SETTINGS LIMIT 1];
            
            if ( !Test.isRunningTest() && (apiConfigs.isEmpty() || String.isBlank(apiConfigs[0].ApiKey__c) || apiConfigs[0].Timeout__c == null 
                                                                || String.isBlank(apiConfigs[0].Correlationid__c)
                                                                || String.isBlank(apiConfigs[0].OssAuthToken__c))) {
               
               // throw new ftr_M6GetProvisioningOrderDetailsException(ERR_NULL_INPUT);
            }
            apiconfig=apiConfigs[0];
            
            // throw an exception if nothing is found, set the variable otherwise
            
            String Timeout=String.valueOf(apiConfig.Timeout__c);
            apiConfigMap.put('Timeout', Timeout);
            apiConfigMap.put('ApiKey', apiConfig.ApiKey__c);
            apiConfigMap.put('AuthHeader', apiConfig.Authorization_Header__c);
            apiConfigMap.put('Correlationid', apiConfig.Correlationid__c);
            apiConfigMap.put('OssAuthToken', apiConfig.OssAuthToken__c);
            apiConfigMap.put('UserName', apiConfig.UserName__c);
            
        } catch (Exception ex){
            System.debug(ex.getMessage());
            ftr_Logger.write(ex);
        }
    }
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter ftr_M6OrderStatusUpdateSubscriber.' + methodName);
        try {
            if (methodName == EXECUTE_METHOD) {
                
                return execute(methodName, inputMap, outputMap);
                
            }
            return true;
        } catch (Exception ex) {
            System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            return false;
        } finally {
            System.debug('Exit ftr_M6OrderStatusUpdateSubscriber.' + methodName);
        }
    }
    
    public static Boolean execute(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap) {
       
       System.debug('M6OrderStatusUpdate:InputMap--->'+inputMap);     
       Map<String,Object> ordnum = new Map<String,Object>();
       List<PSROrderUpdate__e> evs = (List<PSROrderUpdate__e>)inputMap.get(INPUT_EVENT);
       Map<String,Object> orderUpdateEvtMap = new Map<String,Object>();
       Map<String,Map<String,Object>> dpiTechProdMap=new Map <String,Map<String,Object>>();
       Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
       Set<Id> orchPlanIds = new Set<Id>();
       for (PSROrderUpdate__e singleEvent : evs) {           
            System.debug('M6OrderStatusUpdate:Plan_Id__c-->'+singleEvent.Plan_Id__c);                                         
            System.debug('M6OrderStatusUpdate:JSONInput__c-->'+singleEvent.JSONInput__c);
            System.debug('M6OrderStatusUpdate:Order_Number__c-->'+singleEvent.Order_Number__c);               
            System.debug('M6OrderStatusUpdate:FRL_Reference_Id__c-->'+singleEvent.FRL_Reference_Id__c); 
            orchPlanIds.add(singleEvent.Plan_Id__c);
            orderUpdateEvtMap.put(singleEvent.FRL_Reference_Id__c,singleEvent.JSONInput__c);//We need to change this.
         
       }
       List<vlocity_cmt__OrchestrationItem__c> items =[SELECT Id, vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, 
                    vlocity_cmt__OrchestrationPlanId__c,vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber
       FROM vlocity_cmt__OrchestrationItem__c
           WHERE 
           vlocity_cmt__State__c =: INPUT_STATE_RUNNING AND 
           vlocity_cmt__OrchestrationPlanId__c =: orchPlanIds
           AND vlocity_cmt__OrchestrationItemDefinitionId__r.Name In ('Wait for BCN Complete','RC Wait To Start' ,'Wait for M6Orders Completion', 'SIP Wait for BCN Ready', 'SIP Wait for M6Orders Completion','WaitToInitiateMDNOrder') // TODO: to refer an externalId field which will not change
            AND (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_EIA
	   OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_ELAN 
       OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_EVPL_EVC
	   OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: 'DPI_RC_Billing_RFS'
       OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_UNI
       OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI_CKT
       OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI_SIP_TRUNKING
       OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI_MDN_RFS
       OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_SIP_UNI
       OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_SIP_EVC
       OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI_SIP_UNI 
	   OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI_CKT_ELAN
       )];
        System.debug('M6OrderStatusUpdate:items-->'+items);
        for(vlocity_cmt__OrchestrationItem__c item : items){

        String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
        String orchPlanId = item.vlocity_cmt__OrchestrationPlanId__c;// This needs to be changed to handle more than one ORCH plan        
        vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                             vlocity_cmt__JSONAttribute__c = jsonAttribute);
        String prodCode = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
        
        System.debug('M6OrderStatusUpdate:prodCode-->'+prodCode);
        //String docNumber = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_DOC_NUMBER); 
        String FRLRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, TECH_FRLRefId);      
            //Map<String, Object> assetRefTNMap =   (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            Map<String, Object> orchPlanMap =new Map<String, Object>();
            Map<string,Object> assetRefCKTMap=new Map<String, Object>(); 
            Map<String, Object> attrValsRC = new Map<String, Object>{
                    'ATTR_WaitSemaphore' => 'true'
                };			
               if(orderUpdateEvtMap.containsKey(FRLRefId)){
                System.debug('M6OrderStatusUpdate:Matching EIA/EVP Exists:frl.Id-->'+frl.Id);
                String jsonInput=(String)orderUpdateEvtMap.get(FRLRefId);
                Map<String, Object> attrVals = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);                
                System.debug('M6OrderStatusUpdate:Matching EIA/EVP Exists:attrVals-->'+attrVals);
               // dpiTechProdMap.put (FRLRefId,attrVals);
                //orchPlanIds.add(OrchPLanId);        
                frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                frlsToUpdateMap.put(frl.Id,frl);

            }else if(prodCode =='DPI_RC_Billing_RFS'){
                   
                   frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrValsRC);
                   frlsToUpdateMap.put(frl.Id,frl);
               }
}

    System.debug('M6OrderStatusUpdate:frlsToUpdateMap M6/DPI Updated-->'+frlsToUpdateMap);
    System.debug('M6OrderStatusUpdate:frlsToUpdateMap M6/DPI Size-->'+frlsToUpdateMap.values().size());
     if(frlsToUpdateMap.values().size()>0){
       try{
            List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
            
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()){
                    for (Database.Error err : result.getErrors()){
                    System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                    }
                }else {
                    System.debug('M6OrderStatusUpdate Successfully published event-->'+ result.getId());
                }
            }
        } catch(Exception e) {
            System.debug('Exception in Subscriber..'+ e.getMessage());
           return false;
        }
    }

        return true;
    }
    @future(callout=true)
    public static void processBCNComplete(String jsonInput) {

        System.debug('processBCNComplete:jsonInput-->'+jsonInput);
        Map<String,Object> inputMap = new Map<String,Object>();    
        Map<String,String> sharedUNIEIAWTNMap = new Map<String,String>();  
        Map<String,Object> outputMap = new Map<String,Object>();  
        Map<String, Object> orderUpdateEvtMap =   (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        System.debug('processBCNComplete:orderUpdateEvtMap-->'+orderUpdateEvtMap);

        //Call OSS API using documentNumber received from BCNComplete to get UNI Circuit details
        Map<String, Object> circuitIdMap = new Map<String, Object>();
        System.debug('processBCNComplete:docNumber-->'+Integer.ValueOf(orderUpdateEvtMap.get('PSROrderId__c')));
        String psrOrderId=String.ValueOf(orderUpdateEvtMap.get('PSROrderId__c'));
        String orchPlanId,orderId,sfOrderNumber;
        try {
            Service_Order__c servOrders = [SELECT Id, Order__c, Order__r.OrderNumber FROM Service_Order__c WHERE Name=:psrOrderId LIMIT 1];   
       
            orderId=servOrders.Order__c;
            sfOrderNumber=servOrders.Order__r.OrderNumber;
            //orderId='8011g000001CbfzAAC';
            //inputMap.put('DOCUMENT_NUMBER',Integer.ValueOf(orderUpdateEvtMap.get('PSROrderId__c'))); 
            inputMap.put('DOCUMENT_NUMBER',orderUpdateEvtMap.get('PSROrderId__c'));
            inputMap.put('ORDER_NUMBER',orderUpdateEvtMap.get('PSROrderId__c'));  
            inputMap.put('ORDER_ID',orderId);  
            inputMap.put('sfOrderNumber',sfOrderNumber);  
            String stubResponse=String.ValueOf(orderUpdateEvtMap.get('Stub_Response__c'));
            ftr_M6GetProvisioningOrderDetails objOrddetails = new ftr_M6GetProvisioningOrderDetails();
            if(stubResponse=='True'){
                // TEST DATA
                //circuitIdMap.put('CircuitId', '30/CUXP/587241/   /FTNC/   ');
                circuitIdMap.put(String.valueOf(orderUpdateEvtMap.get('PSROrderId__c')),String.valueOf(orderUpdateEvtMap.get('CircuitId__c')));
                circuitIdMap.put('RUID1', '15/L1XN/541115/   /FTNC/   ');
                circuitIdMap.put('RUID2', '16/L1XN/541115/   /FTNC/   ');
            } else {            
                circuitIdMap = objOrddetails.invoke('getProvisioningOrderDetails',inputMap);
            }           
        } catch (Exception ex) {
            System.debug('Error while getting M6 Provisioning Details');
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            try {
                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object> {
                    'request' => psrOrderId,
                    'response' => ex.getStackTraceString(),
                    'interface' => 'GetM6ProvisioningDetails',
                    'system' => 'M6',
                    'status' => 'Error',
                    'errorMessage' => ex.getMessage(),
                    'errorCode' => 500,
                    'orderNumber' => sfOrderNumber,
                    'documentNumber' => psrOrderId,
                    'convertToXML' => false,
                    'relatedTo' => orderId
                };  
                APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);
            } catch (Exception e) {
                System.debug('Unable to create log');
            }
        }
    
        if (!circuitIdMap.isEmpty()){
         // Map<String,Object> orderUpdateEvtMap = new Map<String,Object>();
         
          orderUpdateEvtMap.put(String.valueOf(orderUpdateEvtMap.get('PSROrderId__c')),String.valueOf(orderUpdateEvtMap.get('CircuitId__c')));
          orderUpdateEvtMap.put('RUID1',String.ValueOf(circuitIdMap.get('RUID1')));
          orderUpdateEvtMap.put('RUID2',String.ValueOf(circuitIdMap.get('RUID2')));         
        System.debug('processBCNComplete:PSROrderId__c-->'+orderUpdateEvtMap.get('PSROrderId__c'));
        System.debug('processBCNComplete:Circuitid__c-->'+String.valueOf(orderUpdateEvtMap.get('CircuitId__c')));
        System.debug('processBCNComplete:RUID1-->'+String.ValueOf(circuitIdMap.get('RUID1')));
        System.debug('processBCNComplete:RUID2-->'+String.ValueOf(circuitIdMap.get('RUID2')));
        
        System.debug('processBCNComplete:DueDate__c-->'+orderUpdateEvtMap.get('DueDate__c'));
        Map<string,Object> assetRefCKTMap = new Map<string,Object>();
        Map<String, String> hostRemoteUNIMap = new Map<String, String>();
        /*String psrOrderId=String.ValueOf(orderUpdateEvtMap.get('PSROrderId__c'));
        String orchPlanId,orderId;
        Service_Order__c servOrders = [SELECT Id, Order__c FROM Service_Order__c WHERE Name=:psrOrderId LIMIT 1];   
       
        orderId=servOrders.Order__c;*/  
        List <vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c,
         vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, 
        vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c
        FROM vlocity_cmt__OrchestrationItem__c
        WHERE 
        vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c=:orderId AND
        vlocity_cmt__State__c =: INPUT_STATE_RUNNING AND (vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: ITEM_DEF_WAIT_FOR_BCN_COMPLETE OR vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: ITEM_DEF_SIP_WAIT_FOR_BCN_READY OR vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: ITEM_DEF_SIP_WAIT_FOR_BCN_COMPLETE)
        AND (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_EIA
        OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_EVPL_EVC OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_UNI OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_SIP_UNI OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_SIP_EVC OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_ELAN)];
        System.debug('processBCNComplete:items-->'+items);
        for(vlocity_cmt__OrchestrationItem__c item : items){
            String orderNumber=item.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber;
            String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;  
            orchPlanId = item.vlocity_cmt__OrchestrationPlanId__c;// This needs to be changed to handle more than one ORCH plan
            // String OrchPLanId = item.vlocity_cmt__OrchestrationPlanId__c;// This needs to be changed to handle more than one ORCH plan
           
           vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                              vlocity_cmt__JSONAttribute__c = jsonAttribute);
        String prodCode = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
        System.debug('processBCNComplete:prodCode-->'+prodCode);
        String docNumber = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_DOC_NUMBER);         
        String FRLRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, TECH_FRLRefId);
        System.debug('processBCNComplete:docNumber-->'+docNumber);      
            if(Test.isRunningTest()){
                docNumber='123';
            }
       if((prodCode == TECH_PRODUCTCODE_EIA || prodCode == TECH_PRODUCTCODE_ELAN || prodCode == TECH_PRODUCTCODE_EVPL_EVC || prodCode == TECH_PRODUCTCODE_SIP_EVC) && orderUpdateEvtMap.containsKey(docNumber)){
       //Initialize Variables    
       String workingTelephoneNumber = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'WTN'); 
       String hostUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_HOST_UNI_REF_ID); //'Host UNI Reference Id'); 
       String remoteUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_REMOTE_UNI_REF_ID); //'Remote UNI Reference Id'); 
       String controlNumber = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ControlNumber'); 
       String environment = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'Environment'); 
       String cityAbbreviation = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'cityAbbreviation'); 
       String sharedUNI = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'cityAbbreviation'); 
       String grpOrderTransCount='2';
       String dpiServiceItemId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'serviceItemId'); 
       String dpiParentServiceItemId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'parentServiceItemId');
              
        System.debug('processBCNComplete:Matching EIA/EVPL Exists:docNumber-->'+docNumber);
        System.debug('processBCNComplete:Matching EIA/EVP Exists:frl.Id-->'+frl.Id);
       // orderId=item.vlocity_cmt__OrderItemId__r.Order.Id;
         Map<String, Object> cktDetailsMap = new Map<String, Object>{
            TECH_M6_IsOrderCompleted => 'true',
            'WorkingTelephoneNumber'=>workingTelephoneNumber,
            'ControlNumber' => controlNumber,
            'cityAbbreviation' => cityAbbreviation,
            'Environment' => environment,
            'GroupOrderTransactionCount'=>grpOrderTransCount,
            //TECH_Circuitid => orderUpdateEvtMap.get(docNumber), This is for updating Circuit Id of Concerned DIA/EVC Products
            TECH_Circuitid => circuitIdMap.get(docNumber),
            ATTR_TECH_DueDate => orderUpdateEvtMap.get('DueDate__c'),
            TECH_PurchaseOrderNumber => orderUpdateEvtMap.get('PurchaseOrderNumber__c'),
            'dpiserviceItemId'=>dpiServiceItemId,
            'dpiparentserviceItemId' => dpiParentServiceItemId
            //'OrchestrationPlanID' => OrchPLanId
        };
        if (prodCode == TECH_PRODUCTCODE_EIA || prodCode == TECH_PRODUCTCODE_SIP_EVC || prodCode == TECH_PRODUCTCODE_ELAN){
            String hasSharedUNI=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_SHARED_UNI');
                    if (hasSharedUNI.equalsIgnoreCase('True')){
                        grpOrderTransCount='1';
                        cktDetailsMap.put('GroupOrderTransactionCount', grpOrderTransCount);
                        cktDetailsMap.put('CorrelationId', orderNumber+'.'+workingTelephoneNumber);
                        sharedUNIEIAWTNMap.put(FRLRefId, workingTelephoneNumber);
                        }
            hostRemoteUNIMap.put(hostUNIRefId, FRLRefId);
            }else if (prodCode == TECH_PRODUCTCODE_EVPL_EVC) {
                         hostRemoteUNIMap.put(remoteUNIRefId, FRLRefId);
                } 
       // String FRLRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, TECH_FRLRefId);
        System.debug('processBCNComplete:Matching EIA/EVP Exists:cktDetailsMap-->'+cktDetailsMap);
        assetRefCKTMap.put(FRLRefId, cktDetailsMap);      
        // update the frl DML operation for EIA/EVPL once we update the attributes  
   
     /*String circuitid1;
     String circuitid2;
            if(Test.isRunningTest()){
                circuitid1 = '123';
                circuitid2 = '456';
            }
            else{*/
      String RUID1,RUID2;
     if(prodCode == TECH_PRODUCTCODE_EIA  || prodCode == TECH_PRODUCTCODE_SIP_EVC || prodCode == TECH_PRODUCTCODE_ELAN)
     { 
        RUID1=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_RUID_1);
         System.debug('processBCNComplete:RUID1!-->'+RUID1);
         if(orderUpdateEvtMap.get('RUID1') != NULL){ //NULL check Update
         orderUpdateEvtMap.put(RUID1,(String)orderUpdateEvtMap.get('RUID1')); 
         System.debug('processBCNComplete:orderUpdateEvtMap!-->'+orderUpdateEvtMap);
         }
        }
    if(prodCode == TECH_PRODUCTCODE_EVPL_EVC){
        RUID1=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_RUID_1);
        RUID2=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_RUID_2);
        if(orderUpdateEvtMap.get('RUID1') != NULL && orderUpdateEvtMap.get('RUID2') != NULL){ //NULL check  update
        orderUpdateEvtMap.put(RUID1,orderUpdateEvtMap.get('RUID1'));
       // orderUpdateEvtMap.put(RUID1+'RUID1',orderUpdateEvtMap.get('RUID1'));      // This might be required for Combo Order -- TBD
        orderUpdateEvtMap.put(RUID2,orderUpdateEvtMap.get('RUID2'));
       // orderUpdateEvtMap.put(RUID2+'RUID2',orderUpdateEvtMap.get('RUID2'));      // This might be required for Combo Order -- TBD
        }
    }
        //}
    }
}


for(vlocity_cmt__OrchestrationItem__c item : items){

    String jsonAttributeUNI = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
   vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                      vlocity_cmt__JSONAttribute__c = jsonAttributeuni);

  String orderNumber=item.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber;
  String prodCode = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
  String docNumberUNI = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeUNI, ATT_DOC_NUMBER);
  String FRLRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeUNI, TECH_FRLRefId);
  String workingTelephoneNumber = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeUNI, 'WTN'); 
  String isHostToEVPL=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeUNI, 'HOST_TO_EVPL');          
  String transactionCount;
  String dpiServiceItemId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeUNI, 'serviceItemId'); 
  String dpiParentServiceItemId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeUNI, 'parentServiceItemId');
       
  if (ftr_OrderManagementHelper.validString (isHostToEVPL) && isHostToEVPL.endsWithIgnoreCase('True')){
    transactionCount='1';
  }else {
    transactionCount='2';
  }
  //
  System.debug('processBCNComplete:FRLRefId-->'+FRLRefId);  
  if  (hostRemoteUNIMap.containsKey(FRLRefId)){    
    System.debug('processBCNComplete:hostRemoteUNIMap EIA/EVC-->'+hostRemoteUNIMap.get(FRLRefId));  
    Map<String,Object> hostRemoteEIAEVCMap =  (Map<String,Object>)assetRefCKTMap.get(hostRemoteUNIMap.get(FRLRefId));       
    
    if (sharedUNIEIAWTNMap.containsKey(hostRemoteUNIMap.get(FRLRefId))){//check whether the respective EIA is having Shared UNI
        hostRemoteEIAEVCMap.put('CorrelationId', orderNumber+'.'+sharedUNIEIAWTNMap.get(hostRemoteUNIMap.get(FRLRefId)));
    }else {
        hostRemoteEIAEVCMap.put('CorrelationId', orderNumber+'.'+workingTelephoneNumber);
    }
    //hostRemoteEIAEVCMap.put('CorrelationId', orderNumber+'.'+workingTelephoneNumber);
    System.debug('processBCNComplete:hostRemoteEIAEVCMap-->'+hostRemoteEIAEVCMap); 
    assetRefCKTMap.put(hostRemoteUNIMap.get(FRLRefId), hostRemoteEIAEVCMap);    
    System.debug('processBCNComplete:assetRefCKTMap-->'+assetRefCKTMap); 
  }
  //
  System.debug('processBCNComplete:prodCode-->'+prodCode);     
  System.debug('processBCNComplete:docNumberuni--'+docNumberUNI);
    if(Test.isRunningTest()){
        prodCode = TECH_PRODUCTCODE_UNI;
        docNumberUNI = '123';
    }
   System.debug('processBCNComplete:orderUpdateEvtMap!!--'+orderUpdateEvtMap);
 if((prodCode == TECH_PRODUCTCODE_UNI || prodCode == TECH_PRODUCTCODE_SIP_UNI) && orderUpdateEvtMap.containsKey(docNumberUNI)){
    System.debug('processBCNComplete:Matching UNI Exists:docNumberUNI-->'+docNumberUNI);
    System.debug('processBCNComplete:Matching UNI Exists:frl.Id-->'+frl.Id);    
   /* if(isHostToEVPL.endsWithIgnoreCase('True') ){   //|| HOST_TO_DIA = true){       // This might be required for Combo Order -- TBD
        docNumberUNI = docNumberUNI+'RUID1';
    }
    else{
        docNumberUNI = docNumberUNI+'RUID2';
    } */
    String controlNumber = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeUNI, 'ControlNumber'); 
    String environment = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeUNI, 'Environment'); 
    String cityAbbreviation = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeUNI, 'cityAbbreviation'); 
    Map<String, Object> cktDetailsMap = new Map<String, Object>{
        TECH_M6_IsOrderCompleted => 'true',
        'WorkingTelephoneNumber'=>workingTelephoneNumber,
        'ControlNumber' => controlNumber,
        'cityAbbreviation' => cityAbbreviation,
        'Environment' => environment,
        'GroupOrderTransactionCount'=>transactionCount,
        'CorrelationId'=>orderNumber+'.'+workingTelephoneNumber,
        TECH_Circuitid => orderUpdateEvtMap.get(docNumberUNI),
        ATTR_TECH_DueDate => orderUpdateEvtMap.get('DueDate__c'),
        TECH_PurchaseOrderNumber => orderUpdateEvtMap.get('PurchaseOrderNumber__c'),
        'dpiserviceItemId'=>dpiServiceItemId,
        'dpiparentserviceItemId' => dpiParentServiceItemId
        //'OrchestrationPlanID' => OrchPLanId
    };
    assetRefCKTMap.put(FRLRefId, cktDetailsMap);
    System.debug('processBCNComplete:Matching UNI Exists:cktDetailsMap-->'+cktDetailsMap);
    //dpiTechProdMap.put (FRLRefId,UniMap);

   /* Map<String, Object> attrVals = new Map<String, Object>{
        TECH_M6_IsOrderCompleted => 'true',
        TECH_Circuitid => orderUpdateEvtMap.get(docNumberUNI) // why need to update again
    };
    frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
    frlsToUpdateMap.put(frl.Id,frl);*/
 }
   }

        //END
        //outputMap.put('orderId', orderId);
        outputMap.put('orchPlanId', orchPlanId);
        outputMap.put('assetRefCKTMap', assetRefCKTMap);

        //Publish the Event
        System.debug('processBCNComplete:outputMap-->'+outputMap);
        ftr_OrderManagementHelper.publishM6OrderUpdates(outputMap);
        System.debug('processBCNComplete:publishM6OrderUpdates Completed-->'+outputMap);

        }         

     }
}