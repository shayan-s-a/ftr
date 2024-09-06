global class ftr_DPIResourceManagmentSystemInterface {
     
    global class ftr_DPIResourceManagmentSystemInterfaceException extends Exception {}
    private static String EMPLOYEE_ID = '823947';
    private static String USER_ID = 'ftrqacomm';
    private static String APPLICATION_ID = 'VOM';
    private static String POOL_TYPE = 'FICT';
    private static String POOL_TYPE_RC = 'POTS';
    private static final String REQUEST_METHOD_PUT = 'PUT';
    private static final String API_CONFIG_SETTINGS = 'DPIAuthentication';
    @TestVisible private static Map<String, String> apiConfigMap=new Map<String,String>();
    @TestVisible private static IntegrationAPIConfig__mdt apiconfig;
    private static final String ERR_NULL_INPUT ='Null ApiKey/Timeout';
     private static final String AUTHORIZATION = 'Authorization';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String API_KEY = 'apikey';
    private static String ringCentralItemName;

    static{
        try{
            List<IntegrationAPIConfig__mdt> apiConfigs = [SELECT Timeout__c, ApiKey__c,Authorization_Header__c,ManageResource_URI__c, PutTelephoneNumber_URI__c, DaysToReserve__c  FROM IntegrationAPIConfig__mdt WHERE DeveloperName=: API_CONFIG_SETTINGS LIMIT 1];
            

            if ( !Test.isRunningTest() && (apiConfigs.isEmpty() || String.isBlank(apiConfigs[0].ApiKey__c) || apiConfigs[0].Timeout__c == null)) {
                throw new ftr_DPIResourceManagmentSystemInterfaceException(ERR_NULL_INPUT);
        }
            apiconfig=apiConfigs[0];

           
            apiConfigMap.put('Timeout', String.valueOf(apiConfig.Timeout__c));
            apiConfigMap.put('ApiKey', apiConfig.ApiKey__c);
            apiConfigMap.put('AuthHeader', apiConfig.Authorization_Header__c);
            apiConfigMap.put('ManageResource', apiConfig.ManageResource_URI__c);
            apiConfigMap.put('DPIPutTelephoneNumberURI', apiConfig.PutTelephoneNumber_URI__c);
            apiConfigMap.put('DPIDaysToReserve',  apiConfig.DaysToReserve__c);
            
        } catch (Exception ex){
            System.debug(ex.getMessage());
            ftr_Logger.write(ex);
        }
    }
    public static Map<String, Object> invoke(String methodName, Map<String, Object> inputMap) {
        Map<String, Object> resultMap = new Map<String, Object>();
        try {
            if (methodName == 'retrieveCustomerFacilities') {
                ftr_addressBean addressBean = (ftr_addressBean) inputMap.get('addressBean');
                return retreiveCustomerFacility(addressBean);
            } else if (methodName == 'findAvailableTelephoneNumbers'){
                String npaNxx = (String) inputMap.get('npaNxx');
                Integer itemSequence=Integer.valueOf(inputMap.get('itemSequence'));
                Integer maxTnNumbers = Integer.valueOf(inputMap.get('maxTnNumbers'));

                List<String> tnList = ftr_DPIResourceManagmentSystemInterface.findAvailableTn(inputMap);
                system.debug('findAvailableTelephoneNumbers:itemSequence-->'+ itemSequence);
                system.debug('findAvailableTelephoneNumbers:tnList-->'+ tnList);                
                try {
                    if (tnList!=null && tnList[itemSequence]!=null){
                        resultMap.put('tnList', tnList);
                    }else {
                        resultMap.put('tnList', null);
                    }
                } catch (ListException ex) {

                    resultMap.put('tnList', null);
                 }

                
            } else if (methodName == 'reserveTelephoneNumber'){
                String env =        (String) inputMap.get('env');
                String tn =         (String) inputMap.get('tn');
                ringCentralItemName = (String)inputMap.get('Item_Name');
                resultMap = ftr_DPIResourceManagmentSystemInterface.reserveTelephoneNumber(env,tn);
                System.debug('resultmap : '+ resultMap);
            }
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            System.debug('ftr_DPIResourceManagmentSystemInterface exception : '+ ex.getMessage());
            resultMap.put('Resource Management exception', ex.getMessage());
        }
        return resultMap;
    }


    public static Map<String,String> retreiveCustomerFacility(ftr_addressBean addressBean){
        String wireCenter = null;
        String exchange = null;
        String environment = null;
        String cityabbreviation = null;
        String controlnumber = null;
        Map<String, String> customerFacilityResponseMap = new Map<String, String> ();
        ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort httpPort =  getHttpPort();
        //Request object
        ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesRequest request = new ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesRequest();
        ftr_Sharedtype.RequestHeader header1 = getRequestHeader();
        request.header = header1;
        //assign address from input
        ftr_Sharedtype.AddressChoice addressChoice = new ftr_Sharedtype.AddressChoice();
        ftr_Sharedtype.EnvelopeAddress envelopeAddress = new ftr_Sharedtype.EnvelopeAddress();
     //   envelopeAddress.addressLine1 ='908789'+addressBean.addressLine1;
        envelopeAddress.addressLine1 = addressBean.addressLine1;
        envelopeAddress.cityName = addressBean.cityName;
      //  envelopeAddress.cityName = 'NA';
        envelopeAddress.stateAbbreviation = addressBean.state;
        envelopeAddress.zipCode = addressBean.zipCode;
        addressChoice.envelopeAddress = envelopeAddress;
        request.address = addressChoice;
        System.debug('Request:' + JSON.serialize(request));
        System.debug('endpoint_x:'+httpPort.endpoint_x);
        
        ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesResponse response = httpPort.RetrieveCustomerFacilities(request);
        System.debug('Response:' + JSON.serialize(response));
        if (response != null){
            System.debug('operationstatus--'+response.header.operationStatus);
            if (response.header.operationStatus == 'TRUE'){
                
                List<ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_CustomerFacilities> customerFacilityList =response.customerFacilities;
                System.debug('customerFacilityList--'+customerFacilityList);
                if(customerFacilityList!=null){
                for (ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_CustomerFacilities customerFacility:customerFacilityList ){
                    ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Location location;
                    ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_ServiceAddress serviceAddress;
                    ftr_Sharedtype.ServiceAddressMasterId serviceMasterId;
                    wirecenter = customerFacility.wireCenter;
                   
                    System.debug('exchange--'+customerFacility.exchange);
                    exchange = customerFacility.exchange;
                    System.debug('exchange--1'+exchange);
                    System.debug('wirecenter--'+wirecenter);
                    if(customerFacility.location != null){
                        location = customerFacility.location;
                    }
                    if(location != null){
                        serviceAddress = location.serviceAddress;
                    }
                    if(serviceAddress != null){
                        serviceMasterId = serviceAddress.serviceAddressMasterId;
                        cityabbreviation = serviceAddress.cityAbbreviation;
                    }
                    if(serviceMasterId != null){
                        environment = serviceMasterId.environment;
                        controlnumber = String.valueOf(serviceMasterId.controlNumber);
                    }
                   
                    System.debug('controlnumber--'+controlnumber);
                    System.debug('environment--'+environment);
                   
                    System.debug('cityabbreviation--'+cityabbreviation);
                    break;
                }
            }
            }
        }
        if (wirecenter !=null && environment != null && controlnumber != null && cityabbreviation != null){
            customerFacilityResponseMap = new Map<String,String>();
            customerFacilityResponseMap.put('wirecenter', wirecenter);
            customerFacilityResponseMap.put('env', environment);
            customerFacilityResponseMap.put('cityabbreviation',cityabbreviation);
            customerFacilityResponseMap.put('controlNumber',controlnumber);
            customerFacilityResponseMap.put('exchange',exchange);
        }
        else {
            Map<String,String> retPrefExchangeResponse = new  Map<String,String>();
            retPrefExchangeResponse = retrievePreferredExchange(addressBean.zipCode);
            customerFacilityResponseMap.put('env', (String)retPrefExchangeResponse.get('Env'));
            customerFacilityResponseMap.put('isRetCustFacSuccess', 'False');
            System.debug('Exchange from retrieve prefferred exchange : '+ customerFacilityResponseMap.get('exchange'));
        }
        return customerFacilityResponseMap;
    }
    public static List<String> findAvailableTn(Map<String, Object> inputMap){
        System.debug(':::: inputMap'+inputMap);
        List<String> tnList;
        String npaNxx = (String) inputMap.get('npaNxx');
        String orderId = (String) inputMap.get('orderId');
        String order_no = (String) inputMap.get('order_no');
        String Item_Name = (String) inputMap.get('Item_Name');
        Integer maxTns = Integer.valueOf(inputMap.get('maxTnNumbers'));
        ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort httpPort = getHttpPort();
        ftr_Sharedtype.RequestHeader header = getRequestHeader();
        ftr_Resourcemanagement.msg_FindAvailableTelephoneNumbersRequest findAvailableTelNumbInput
            =new ftr_Resourcemanagement.msg_FindAvailableTelephoneNumbersRequest();
        ftr_Resourcemanagement.FindAvailableTelephoneNumbersRequest_ExchangeFilter exchangeFilter
            =new ftr_Resourcemanagement.FindAvailableTelephoneNumbersRequest_ExchangeFilter ();
        exchangeFilter.npaNxx= npaNxx;
        if(Item_Name =='RCFindAvailablePhoneNumber'){
            exchangeFilter.poolType=POOL_TYPE_RC;
        }else{
            exchangeFilter.poolType=POOL_TYPE;
        }
        
        exchangeFilter.maximumNumberOfResults = maxTns;
        findAvailableTelNumbInput.header=header;
        findAvailableTelNumbInput.exchangeFilter=exchangeFilter;
        System.debug('FindAvailableTelephoneNumbersRequest: ' + JSON.serialize(findAvailableTelNumbInput));
        ftr_Resourcemanagement.msg_FindAvailableTelephoneNumbersResponse findAvailableTelephoneNumbersOutput=
            httpPort.FindAvailableTelephoneNumbers(findAvailableTelNumbInput);
        System.debug('FindAvailableTelephoneNumbersResponse: ' + JSON.serialize(findAvailableTelephoneNumbersOutput));
        if (findAvailableTelephoneNumbersOutput != null){
            if (findAvailableTelephoneNumbersOutput.header.operationStatus == 'TRUE'){

                if (findAvailableTelephoneNumbersOutput.header.executionStatusMessage!=null && findAvailableTelephoneNumbersOutput.header.executionStatusMessage.operationStatusCode == '0'){
                    tnList = findAvailableTelephoneNumbersOutput.telephoneNumber;   
                }                
            }
        }
        try {
            Map<String, Object> logOutput = new Map<String, Object>();
            Map<String, Object> logInput = new Map<String, Object> {
                'request' => findAvailableTelNumbInput,
                'response' => findAvailableTelephoneNumbersOutput,
                'interface' => 'findAvailableTelephoneNumbers',
                'system' => 'DPI',
                'status' => findAvailableTelephoneNumbersOutput.header.operationStatus   == 'TRUE'  ? 'Success' : 'Error',
                'errorMessage' =>findAvailableTelephoneNumbersOutput.header.operationStatus   == 'TRUE' ? null :findAvailableTelephoneNumbersOutput.header.executionStatusMessage,
                'errorCode' => findAvailableTelephoneNumbersOutput.header.operationStatus   == 'TRUE' ? null : findAvailableTelephoneNumbersOutput.header.executionStatusMessage.operationStatusCode,
                'orderNumber' => order_no,
             
                'convertToXML' => true,
                'relatedTo' => orderId
            };  
            APILogger log = new APILogger();
            log.createEntry(logInput, logOutput);
        } catch (Exception e) {
            System.debug('Unable to create log');
        }
        return tnList;
    }
    public static Map<String, String> retrievePreferredExchange(String zipcode){
        String exchange , wirecenter, miscInfo, env;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Map<String, String> responseMap = new Map<String, String> ();
        Map<String, Object> headerInfo = new Map<String, Object>();
        String endpoint = apiConfigMap.get('ManageResource');
        headerInfo.put('endpoint',endpoint);
        headerInfo.put('contentType', 'text/xml;charset=UTF-8');
        headerInfo.put('ESB-requestingApplication', 'VlocityOM');
        headerInfo.put('ESB-securityInfo.employeeId', '');
        request.setTimeout(Integer.valueOf(apiConfigMap.get('Timeout')));
        headerInfo.put('RequestMethod', 'POST');
        Map<String,Object> requestBody = new Map<String,Object>();
        String requestXml =(String)createESBRequest(zipcode);
        system.debug('DPI Request xml:'+JSON.serialize(requestXml) );
        request = setRequestHeaders(request, requestXml, headerInfo);
          if(Test.isRunningTest() ){
                 responseMap.put('Exchange', '4545454');
        responseMap.put('Env', 'FT');
          }else{
        HttpResponse response = http.send(request);
     
        String responseBody = (String)response.getBody();
        System.debug('HttpResponse : '+ responseBody);
        String operationStatus = responseBody.substringBetween('<operationStatus>','</operationStatus>');
        if(operationStatus.equalsIgnoreCase('TRUE')){
        miscInfo = responseBody.substringBetween('miscellaneousInformation');
        env = miscInfo.substringBetween('ENV=', ' ');
        exchange = responseBody.substringBetween('<exchange>','</exchange>');
        System.debug('Env :'+env);
        }
        
        responseMap.put('Exchange', exchange);
        responseMap.put('Env', env);
        }
        return responseMap;
    }
   /*  public static Map<String, String> retrievePreferredExchange_wsdl(String zipcode){
       List<String> tnList;
       String exchange , wirecenter, miscInfo;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Map<String, String> responseMap = new Map<String, String> ();
        ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort httpPort = getHttpPort();
        ftr_Sharedtype.RequestHeader header = getRequestHeader();
        ftr_Resourcemanagement.msg_RetrievePreferredExchangeRequest retrievePreferredExchangeRequestInput
            =new ftr_Resourcemanagement.msg_RetrievePreferredExchangeRequest();
        retrievePreferredExchangeRequestInput.header=header;
        retrievePreferredExchangeRequestInput.zipCode = zipcode;
        System.debug('RetrievePreferredExchangeRequest: ' + retrievePreferredExchangeRequestInput);
        ftr_Resourcemanagement.msg_RetrievePreferredExchangeResponse retrievePreferredExchangeOutput=
        httpPort.RetrievePreferredExchange(retrievePreferredExchangeRequestInput);
        System.debug('RetrievePreferredExchangeResponse: ' + JSON.serialize(retrievePreferredExchangeOutput));

        if (retrievePreferredExchangeOutput != null){
            if (retrievePreferredExchangeOutput.header.operationStatus == 'TRUE'){
            System.debug(retrievePreferredExchangeOutput.header.executionStatusMessage);
            
            if (retrievePreferredExchangeOutput.header.executionStatusMessage!=null && retrievePreferredExchangeOutput.header.executionStatusMessage.operationStatusCode == '0'){
                    miscInfo = retrievePreferredExchangeOutput.header.executionStatusMessage.miscellaneousInformation;
                    System.debug('Miscellaneous Info :'+miscInfo);
                    if(miscInfo.indexOf('ENV')!=-1){
                        miscInfo.substringBetween('ENV=', ' ');
                    }
                    exchange = retrievePreferredExchangeOutput.exchange   ;
                    wirecenter = retrievePreferredExchangeOutput.wireCenter     ;
                    responseMap.put('exchange', exchange);
                    responseMap.put('wirecenter', wirecenter);
                }                
            }
        }
        return responseMap;
    }*/
    /*public static Map<String, Object> reserveTelephoneNumber(String env, String tn){
        Map<String, Object> results = new Map<String, Object>();
        boolean tnReservered = false;
        ftr_Sharedtype.ResponseHeader responseHeader;
        ftr_Sharedtype.ExecutionStatusMessage executionStatusMessage;
        ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort httpPort = getHttpPort();
        ftr_Sharedtype.RequestHeader header = getRequestHeader();
        ftr_Resourcemanagement.msg_ReserveTelephoneNumberRequest reserveTelNumbInput
            =new ftr_Resourcemanagement.msg_ReserveTelephoneNumberRequest();
        reserveTelNumbInput.environment = env;
        reserveTelNumbInput.telephoneNumber = tn;
        reserveTelNumbInput.header=header;
        System.debug('reserveTelNumbInput:' + reserveTelNumbInput);
        ftr_Resourcemanagement.msg_ReserveTelephoneNumberResponse reserveTnResponse=
            httpPort.ReserveTelephoneNumber(reserveTelNumbInput);
        System.debug('reserveTnResponse-->:' + reserveTnResponse);
        if (reserveTnResponse != null){
            if (reserveTnResponse.header.operationStatus == 'TRUE'){
                responseHeader = reserveTnResponse.header;
                executionStatusMessage = responseHeader.executionStatusMessage;
                if (executionStatusMessage.operationStatusCode == '000-000-0000'){
                   tnReservered = true;
                }
            }
        }
        results.put('result', tnReservered);
        results.put('statusCode', executionStatusMessage.operationStatusCode);
        return results;
    }*/
    public static Map<String, Object> reserveTelephoneNumber(String env, String tn){
        Map<String, Object> results = new Map<String, Object>();
        String responsebody ;
        String status ;
        String statuscode ;
        String daysToReserve = apiConfigMap.get('DPIDaysToReserve');
         Map<String, Object> reservetelephoneinput = new Map<String, Object>();
         reservetelephoneinput.put('TelephoneNumber',tn);
         reservetelephoneinput.put('environmentCode',env);
         reservetelephoneinput.put('quoteNumber','vlocity order');
        if(ringCentralItemName == 'RCReserveTelephoneNumberInterface'){
            reservetelephoneinput.put('poolType','POTS');
        }else{
            reservetelephoneinput.put('poolType','FICT');
        }
         
         reservetelephoneinput.put('daysToReserve',daysToReserve);
         reservetelephoneinput.put('action','RESERVE');
         Map<String, Object> headerInfo = new Map<String, Object>();
         Map<String, Object> inputReserve = new Map<String, Object>();
         String endpoint = apiConfigMap.get('DPIPutTelephoneNumberURI');
         headerInfo.put('endpoint',endpoint);
         headerInfo.put('contentType', 'application/json');
         headerInfo.put('ESB-requestingApplication', 'VlocityOM');
         headerInfo.put('ESB-securityInfo.employeeId', '');
         headerInfo.put('RequestMethod', REQUEST_METHOD_PUT);
         System.debug('DPIPutTelephoneNumberURI : '+ endpoint);
       
         inputReserve.put('HeaderInfo',headerInfo);
         inputReserve.put('PutTelephoneNumReq', reservetelephoneinput);
         Map<String, String>  reserveTNResponse = reserveTnUsingRestAPI(inputReserve);
         //  Map<String, String> responseMap = (Map<String,String>)reserveTNResponse;
         //  System.debug('Response map :'+responseMap);
         if(reserveTNResponse!=null){
            responsebody =(String)  reserveTNResponse.get('ResponseBody');
            status =  (String)  reserveTNResponse.get('Status');
            statuscode =  (String) reserveTNResponse.get('StatusCode');
         }
        
        
            Boolean    tnReservered ;
            if (responsebody != null){
            if (statuscode.equals('200') ){
                
                tnReservered = true;
              
            }
        }
        results.put('result', tnReservered);
        results.put('statusCode', statuscode);
        results.put('responsebody', responsebody);
        return results;
     
        
    }
    private static ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort getHttpPort(){
        ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort httpPort = new ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort();
        //Header setup
       
         Map<String, String> httpHeaders = new Map<String, String>{
                                                'apikey' => apiConfigMap.get('ApiKey'),
        
                                                'Authorization' => 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiConfigMap.get('AuthHeader')))
                                            };
       httpPort.inputHttpHeaders_x=httpHeaders;
       httpPort.endpoint_x='callout:DPIApigeeCredentials'+'/'+apiConfig.ManageResource_URI__c;
     // httpPort.endpoint_x= 'https://th-apex-http-callout.herokuapp.com/animals';
       System.debug('httpport-endpoint--'+httpPort.endpoint_x);
       httpPort.timeout_x=Integer.valueOf(apiConfigMap.get('Timeout'));
         return httpPort;
    }
       private static ftr_Sharedtype.RequestHeader getRequestHeader(){
        ftr_Sharedtype.RequestHeader header = new ftr_Sharedtype.RequestHeader();
        ftr_Sharedtype.SecurityInfo securityInfo = new ftr_Sharedtype.SecurityInfo();
        securityInfo.employeeId = EMPLOYEE_ID;//'823947';
        securityInfo.userId =  USER_ID;  //'ftrqacomm';
        header.securityInfo = securityInfo;
        header.requestingApplication = APPLICATION_ID; //'VOM';
        return header;
    }
    public static void testCustomerFacility(){
        ftr_addressBean address = new ftr_addressBean();
        address.addressLine1 = '80 Timberline Rd';
        address.cityName = 'Crossville';
        address.state = 'TN';
        address.zipCode = '38571';
        //ftr_DPIResourceManagmentSystemInterface service = new ftr_DPIResourceManagmentSystemInterface();
        System.debug(ftr_DPIResourceManagmentSystemInterface.retreiveCustomerFacility(address));
    }
       public static void testRetrievePreferredExchange(){
        //ftr_DPIResourceManagmentSystemInterface service = new ftr_DPIResourceManagmentSystemInterface();
        System.debug(ftr_DPIResourceManagmentSystemInterface.retrievePreferredExchange('38571'));
    }
    public static void testFindAvailableTns(){
        //ftr_DPIResourceManagmentSystemInterface service = new ftr_DPIResourceManagmentSystemInterface();
      //  System.debug('tnList:' + ftr_DPIResourceManagmentSystemInterface.findAvailableTn(inputMap));
    }
    public static void testReserveTelephoneNumber(){
        //ftr_DPIResourceManagmentSystemInterface service = new ftr_DPIResourceManagmentSystemInterface();
        System.debug('tnList:' + ftr_DPIResourceManagmentSystemInterface.reserveTelephoneNumber('EA', '9311961057'));
    }
     public static  Map<String, String> reserveTnUsingRestAPI(Map<String, Object> input) {
            System.debug('Input for ReserveFirstAvailableTN -->'+input);
            
            Http http = new Http();
            HttpRequest restRequest = new HttpRequest();
            String environment, state;
            Map<String, Object> headerInfo =(Map<String, Object>) input.get('HeaderInfo');
            Map<String, Object> inputReserve =(Map<String, Object>) input.get('PutTelephoneNumReq');
            Map<String, String> output = new  Map<String,String>();
            System.debug('Input in reserve first telephone number : '+ inputReserve);
       
            if(inputReserve.get('environmentCode')!=null){
             environment= (String) inputReserve.get('environmentCode');
            }
           
          //  String environment = 'AZ';
            String requestXml = JSON.serialize(inputReserve);
                   System.debug('Request xml123: '+requestXml);
                    restRequest = setRequestHeaders(restRequest, requestXml, headerInfo);
            System.debug('Rest Request body: '+ restRequest.getBody());
            HttpResponse reserveTnResponse ;
         try {
           reserveTnResponse = http.send(restRequest);
         }
         catch (Exception e){
             System.debug('Exception caught: '+ e.getMessage());
             System.debug('Exception caught: '+ e.getStackTraceString());
         }
              
         if(reserveTnResponse!= null){
            output.put('Status', reserveTnResponse.getStatus());
            output.put('StatusCode', String.valueOf(reserveTnResponse.getStatusCode()));
            output.put('ResponseBody', reserveTnResponse.getBody());
         }
         
            return output;
        }
    public static HttpRequest setRequestHeaders( HttpRequest request, Object requestType, Map<String, Object> headerInfo){
 
        System.debug('ResourceManagement endpoint '+'callout:DPIApigeeCredentials');
         request.setEndpoint('callout:DPIApigeeCredentials'+'/'+(String)headerInfo.get('endpoint'));
      
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiConfigMap.get('AuthHeader')));
        request.setHeader(AUTHORIZATION, authorizationHeader);
        request.setHeader(API_KEY, apiConfigMap.get('ApiKey'));
        request.setHeader(CONTENT_TYPE ,(String)headerInfo.get('contentType'));
        request.setMethod((String)headerInfo.get('RequestMethod'));
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
  /*  public static String RetreivePreferredExchange1(String zipcode){
       List<String> tnList;
       String exchange , wirecenter, miscInfo;
         Http http = new Http();
         HttpRequest request = new HttpRequest();
          Map<String, Object> headerInfo = new Map<String, Object>();
         Map<String, Object> inputReserve = new Map<String, Object>();
         String endpoint = apiConfigMap.get('ManageResource');
        request.setEndpoint('https://api-qat02.frontier.com/esbresourcemanagement/v1');
       
        String authorizationHeader = 'Basic ' +'eGNvcnBcc2ZhY29tOmZyb250aWVyMTIz';
        request.setHeader(AUTHORIZATION, authorizationHeader);
        request.setHeader(API_KEY, 'ooAFxCEtyoqSRA1z2tEedU84RBEnsFot');
        //  request.setHeader(CONTENT_TYPE , 'text/xml;charset=UTF-8');
        request.setHeader(CONTENT_TYPE ,'text/xml;charset=UTF-8');
        request.setMethod('POST');
         request = setRequestHeaders(request, requestXml, headerInfo);
         String request1 = '<soapenv:Envelope '+'xmlns:'+'soapenv="http://schemas.xmlsoap.org/soap/envelope/" '+'xmlns:res="http://esb.frontier.com/ResourceManagement" '+'xmlns:'+'shar="'+ 'http://esb.frontier.com/sharedType" >'+
         '<soapenv:Header/>'+
         '<soapenv:Body>'+
      '<res:RetrievePreferredExchange>'+
  '<retrievePreferredExchangeInput>'+
    '<header>'+
      '<shar:requestingApplication>VlocityOM</shar:requestingApplication>'+
      '<securityInfo>'+
       ' <userId>t_crm004</userId>'+
        '<employeeId/>'+
      '</securityInfo>'+
    '</header>'+
    '<zipCode>95987</zipCode>'+
  '</retrievePreferredExchangeInput>'+
'</res:RetrievePreferredExchange>'+
  '</soapenv:Body>'+
'</soapenv:Envelope>';
         request.setBody((String)request1);
        System.debug('Request body 2:'+(String)request.getBody());
         HttpResponse response = http.send(request);
        
        String responseBody = (String)response.getBody();
        miscInfo = responseBody.substringBetween('miscellaneousInformation');
        String env = miscInfo.substringBetween('ENV=', ' ');
        System.debug('Env :'+env);
        return env;
    }*/
      public static String createESBRequest(String zipcode){
         String requestXML = '<soapenv:Envelope '+'xmlns:'+'soapenv="http://schemas.xmlsoap.org/soap/envelope/" '+'xmlns:res="http://esb.frontier.com/ResourceManagement" '+'xmlns:'+'shar="'+ 'http://esb.frontier.com/sharedType" >'+
         '<soapenv:Header/>'+
         '<soapenv:Body>'+
        '<res:RetrievePreferredExchange>'+
        '<retrievePreferredExchangeInput>'+
        '<header>'+
        '<shar:requestingApplication>VlocityOM</shar:requestingApplication>'+
        '<securityInfo>'+
        '<userId>ftrqacomm</userId>'+
        '<employeeId>823947</employeeId>'+
        '</securityInfo>'+
        '</header>'+
        '<zipCode>'+zipcode+'</zipCode>'+
        '</retrievePreferredExchangeInput>'+
        '</res:RetrievePreferredExchange>'+
        '</soapenv:Body>'+
        '</soapenv:Envelope>';
        return requestXML;
    }
}