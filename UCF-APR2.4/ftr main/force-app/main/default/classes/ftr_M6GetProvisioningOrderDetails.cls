global without sharing class ftr_M6GetProvisioningOrderDetails {
    
    @TestVisible private static final String API_CONFIG_SETTINGS = 'OSSAPIAuthentication';
    @TestVisible private static Map<String, String> apiConfigMap=new Map<String,String>();
    @TestVisible private static IntegrationAPIConfig__mdt apiconfig;
    private static final String ERR_NULL_INPUT ='Null ApiKey/Timeout';
   // public static Map<String,String> returnmap = new Map<String,String>();
   
    
    private static String EMPLOYEE_ID = '823947';
    private static String USER_ID = 'Salesforce';
    private static String APPLICATION_ID = 'VOM';
    private static String POOL_TYPE = 'SCOM';
    private static String orderId;
    private static String orderNumber;
    private static HttpRequest request;
    private static HttpResponse m6Response;
    
    static{
        try{
            System.debug('API_CONFIG_SETTINGS--'+API_CONFIG_SETTINGS);
            List<IntegrationAPIConfig__mdt> apiConfigs = [SELECT Timeout__c, ApiKey__c,Authorization_Header__c ,Correlationid__c,OssAuthToken__c,UserName__c,Endpoint__c FROM IntegrationAPIConfig__mdt WHERE DeveloperName=: API_CONFIG_SETTINGS LIMIT 1];
            
            if ( !Test.isRunningTest() && (apiConfigs.isEmpty() || String.isBlank(apiConfigs[0].ApiKey__c) || apiConfigs[0].Timeout__c == null 
                                                                || String.isBlank(apiConfigs[0].Correlationid__c)
                                                                || String.isBlank(apiConfigs[0].OssAuthToken__c))) {
               
                throw new ftr_M6GetProvisioningOrderDetailsException(ERR_NULL_INPUT);
            }
            System.debug('apiconfig--'+apiConfigs);
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
    global class ftr_M6GetProvisioningOrderDetailsException extends Exception {}
    
    public Map<String, Object> invoke(String methodName, Map<String, Object> inputMap) {
        System.debug('Method--'+methodName+'inputmap--'+inputMap);
        orderId = String.valueOf(inputMap.get('ORDER_ID'));
        orderNumber = String.valueOf(inputMap.get('sfOrderNumber'));
        System.debug('OrderId in M6getprovdetails:'+orderId);
        Map<String,Object> resultMap=new  Map<String,Object>();
        if (methodName == 'getProvisioningOrderDetails') {
            String documentNumber = String.valueOf(inputMap.get('DOCUMENT_NUMBER'));
            System.debug ('Testing document : ' + documentNumber);
            Map<String,Object> circuitdetails= (Map<String,Object>)inputMap.get('circuitDetails');
            String notes = (String)inputMap.get('clrNotes');
            resultMap=getProvisioningOrderDetails(documentNumber, orderId);
        }
       return resultMap;
    }
    public Map<String,Object> getProvisioningOrderDetails(String documentNumber, String orderId){
        Map<String,Object> provOrderDetailsMap=new  Map<String,Object>();
        try{
        // Construct Request and Call ossAPICallout
        provOrderDetailsMap=ossAPICallout(documentNumber);
            system.debug('provOrderDetailsMap-->'+provOrderDetailsMap);
            if(provOrderDetailsMap.get('CreateTask') != null){
                if(provOrderDetailsMap.get('CreateTask').equals('True')){
                    throw new ftr_M6GetProvisioningOrderDetailsException('GetM6ProvisioningDetails Exception. | Document No# : '+ documentNumber +' | '+provOrderDetailsMap.get('ErrorResp')); 
                }
            }
        }
        catch(Exception ex){
            System.debug('Exception Caught***');
            provOrderDetailsMap=new  Map<String,Object>(); 
        String addExMessage = ex.getMessage(); 
        Map<String,Object> createTaskInputMap =new Map<String,Object>();
           // createTaskInputMap.put('ErrorCode','7777');
            createTaskInputMap.put('Description',ex.getMessage()); 
        createTaskInputMap.put('Subject','DPI OM Billing Exception'); 
        createTaskInputMap.put('Priority','High');
            createTaskInputMap.put('InterfaceName','M6GetProvisioningDetails'); 
        createTaskInputMap.put('WhatId', orderId);
            System.debug('createTaskInputMap :'+ createTaskInputMap);
            ftr_OrderManagementHelper.CreateTask( createTaskInputMap) ;

            try {
                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object> {
                    'request' => documentNumber,
                    'response' => JSON.deserializeUntyped(m6Response.getBody()),
                    'interface' => 'GetM6ProvisioningDetails',
                    'system' => 'M6',
                    'status' => 'Error',
                    'errorMessage' => ex.getMessage(),
                    'errorCode' => m6Response.getStatusCode() != null ? m6Response.getStatusCode() : 500,
                    'orderNumber' => orderNumber,
                    'documentNumber' => documentNumber,
                    'convertToXML' => false,
                    'relatedTo' => orderId
                };  
                APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);
            } catch (Exception e) {
                System.debug('Unable to create log');
            }
        }
        System.debug('provOrderDetailsMap-->'+provOrderDetailsMap);
            // processOrderDetailsResponse
            return provOrderDetailsMap;
    }
    //use this method if required, else use url parameter
    //private HttpRequest request prepareOrderDetailsRequest(String documentNumber){


   //use this method if required, else use url parameter
     /* private Map<String,Object> processOrderDetailsResponse(HttpResponse httpResponse){
         
            Map<String,Object> orderDetailsResponse= new Map<String,Object>();
            return orderDetailsResponse;

      }*/

      public  static   Map<String,Object> ossAPICallout(String documentNumber){ //change the return accordingly
        Map<String,Object> ossAPICalloutMap =new  Map<String,Object>();
        Http http = new Http();
           String authorizationHeader ;
        String correlationId = apiConfigMap.get('Correlationid');
        String ossAuth = apiConfigMap.get('OssAuthToken');
          System.debug('authheader--'+apiConfigMap.get('AuthHeader'));
          if(apiConfigMap.get('AuthHeader') != null){  authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(Blob.valueOf(apiConfigMap.get('AuthHeader'))); 
          }
        
        String KeyAPI   = apiConfigMap.get('ApiKey');
        String username = apiConfigMap.get('UserName');
        String timeout  = apiConfigMap.get('Timeout');  
        
           request = new HttpRequest(); 
           request.setEndpoint('callout:OSSAPIApigeeCredentials'+'/'+documentNumber);
           request.setMethod('GET');
           request.setHeader('Content-Type', 'application/json');
           request.setHeader('Authorization', authorizationHeader);  
           request.setHeader('OssAuthToken',ossAuth);//from Custom Meta data types
           request.setHeader('UserName', username); 
           request.setHeader('Correlationid',correlationId);//from Custom Meta data types
           request.setHeader('ApiKey',keyAPI);
           request.setTimeout(120000);//THis should in Meta Data Configurable
           request.setHeader('Content-Length', '0' );
           //request.setHeader('Correlationid','');
           m6Response = http.send(request);

            try {
                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object> {
                    'request' => documentNumber,
                    'response' => JSON.deserializeUntyped(m6Response.getBody()),
                    'interface' => 'GetM6ProvisioningDetails',
                    'system' => 'M6',
                    'status' => m6Response.getStatus() == 'OK' ? 'Success' : 'Error',
                    'errorMessage' => m6Response.getStatusCode()  == 200 ? null : m6Response.getBody(),
                    'errorCode' => m6Response.getStatusCode()  == 200 ? null : m6Response.getStatusCode(),
                    'orderNumber' => orderNumber,
                    'documentNumber' => documentNumber,
                    'convertToXML' => false,
                    'relatedTo' => orderId
                };  
                APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);
            } catch (Exception e) {
                System.debug('Unable to create log');
            }

           System.debug(m6Response.getBody());
           System.debug ('User:' + USER_ID); 
           if (m6Response != null){
           System.debug ('M6 Callout:' + m6Response);  
           if(m6Response.getStatusCode() != 200){
                ossAPICalloutMap.put('CreateTask','True');
                ossAPICalloutMap.put('ErrorResp',m6Response.getBody());
           }
               else{
           System.debug ('testing Callout : ' + documentnumber);
           String resp = m6Response.getBody();
           System.debug('response body-- '+ resp);
           Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(resp);
            System.debug('rawobj--'+rawObj);
            Map<String,Object> orderdetails =(Map<String,Object>) rawObj.get('orderDetails');
                Map<String,Object> ruidmap = new Map<String,Object>();
                System.debug('orderdetails-'+orderdetails);
            List<Object> orderCircuitInfo = (List<Object>)orderdetails.get('orderCircuits');
            integer i = 1;
            for (Object circuit : orderCircuitInfo) {
                System.debug('circuit info: '+circuit);
                Map<String,Object> circuitmap =(Map<String,Object>) circuit;

            List<Object> orderruidlist = (List<Object>) circuitmap.get('orderRuids');
            for (Object ruid : orderruidlist) {
                    ruidmap =(Map<String,Object>) ruid;
                System.debug('RuidNbr: '+ruidmap.get('ruidNbr'));             
                //ossAPICalloutMap.put('RUID'+i,(String)ruidmap.get('ruidNbr'));
                //Add Due along with this If /esle
                String desiredDueDate= (String)orderdetails.get('desiredDueDate');
                ossAPICalloutMap.put('desiredDueDate', desiredDueDate);
               
                if (ruidmap.get('ruidNbr').equals('1')){
                    ossAPICalloutMap.put('RUID'+1,(String)ruidmap.get('ruidCircuitName')); 
                }
                else if(ruidmap.get('ruidNbr').equals('2')){
                    ossAPICalloutMap.put('RUID'+2,(String)ruidmap.get('ruidCircuitName')); 
                }
                ossAPICalloutMap.put(documentnumber,circuitmap.get('circuitName'));
                System.debug('returnmap112--'+ossAPICalloutMap);
                i++;
            }

            }
        }
        }
          System.debug('returnmap112--'+ossAPICalloutMap);
            return ossAPICalloutMap;
      }

}