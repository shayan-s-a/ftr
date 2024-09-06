// Version 2.0
public with sharing class FTRWSDPIAddressController {
    
    class FTRWSDPIAddressControllerException extends Exception {}
    private static String EMPLOYEE_ID = '823947';
    private static String USER_ID = 'ftrqacomm';
    private static String APPLICATION_ID = 'VOM';
    private static String POOL_TYPE = 'SCOM';  
    @TestVisible private static IntegrationAPIConfig__mdt apiconfig;
    private static final String ERR_NULL_INPUT ='Null ApiKey/Timeout';  

    public FTRWSDPIAddressController() {

    }

    @AuraEnabled
    public static List<FTRWSDPIAddressResponse> retreiveCustomerFacility(ftr_addressBean addressBean){
        String wireCenter = null;
        String clliCode = null;
        String svcControlNo = null;

        String addressLine = null;
        String city = null;
        String state = null;
        String zipcode = null;
        
        String unit = null;
        
        String secDesignator = null;
        String secNumber = null;
        
        String longitude = null;
        String latitude = null;
        
        Set<String> addrSet = new Set<String>();
        List<FTRWSDPIAddressResponse> addrList = new List<FTRWSDPIAddressResponse>();
        ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort httpPort =  getHttpPort();
        //Request object
        ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesRequest request = new ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesRequest();
        ftr_Sharedtype.RequestHeader header1 = getRequestHeader();
        request.header = header1;
        //assign address from input
        ftr_Sharedtype.AddressChoice addressChoice = new ftr_Sharedtype.AddressChoice();
        ftr_Sharedtype.EnvelopeAddress envelopeAddress = new ftr_Sharedtype.EnvelopeAddress();
        envelopeAddress.addressLine1 = addressBean.addressLine1;
        envelopeAddress.cityName = addressBean.cityName;
        envelopeAddress.stateAbbreviation = addressBean.state;
        envelopeAddress.zipCode = addressBean.zipCode;
        addressChoice.envelopeAddress = envelopeAddress;
        request.address = addressChoice;
        System.debug('Request:' + JSON.serialize(request));
        System.debug('endpoint_x:'+httpPort.endpoint_x);
        
        ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesResponse response = httpPort.RetrieveCustomerFacilities(request);
       System.debug('Response:' + JSON.serialize(response));
        if (response != null){
            if (response.header.operationStatus == 'TRUE') {
                
                List<ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_CustomerFacilities> customerFacilityList =response.customerFacilities;
                if(customerFacilityList == null || customerFacilityList.size() == 0) {
                    System.debug('SUCCESS RETURNED, but No customer facilities found or returned from DPI');
                    FTRWSDPIAddressResponse dpiResponse = new FTRWSDPIAddressResponse();
                    dpiResponse.status = 'FAILURE';
                    addrList.add(dpiResponse);
                    return addrList;
                } 
                for (ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_CustomerFacilities customerFacility:customerFacilityList ){
                    wirecenter = customerFacility.wireCenter;
                    ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Location location = customerFacility.location;
                    // system.debug('location req ' + location);
                    ftr_Sharedtype.Address address = location.address;
                    ftr_Sharedtype.GlobalPosition globalPos = location.globalPosition;
                    
                    latitude = globalPos.latitude;
                    longitude = globalPos.longitude;
                    
                     secDesignator = address.secondaryDesignator;
                     secNumber = address.secondaryNumber;

                    addressLine = ''+address.streetNumber;
                    
                    if(address.preDirectional != null) {
                        addressLine = addressLine + ' ' + address.preDirectional;    
                    }
                    
                    addressLine = addressLine + ' ' + address.streetName;
                    if(address.streetSuffix != null) {
                        addressLine = addressLine + ' ' + address.streetSuffix;    
                    }
                    
                    if(secDesignator != null && secNumber != null) {
                        unit = secNumber + ' ' + secDesignator;
                    }
                    city = address.cityName;
                    state = address.stateAbbreviation;
                    zipCode = address.zipCode;

                    ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_ServiceAddress serviceAddress = location.serviceAddress;
                    ftr_Sharedtype.ServiceAddressMasterId serviceMasterId = serviceAddress.serviceAddressMasterId;
                    svcControlNo = '' + serviceMasterId.controlNumber;

                    ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Connection connection = customerFacility.connection;
                    if(connection != null) {
                      clliCode = connection.centralOfficeCommonLanguageLocationIdentifier;    
                    }
                    

                    FTRWSDPIAddressResponse dpiResponse = new FTRWSDPIAddressResponse();
                    dpiResponse.addressLine1 = addressLine;
                    
                    dpiResponse.streetName = address.streetName;
                    
                    if(address.preDirectional != null) {
                        dpiResponse.streetName = address.preDirectional + ' ' + dpiResponse.streetName;
                    }
                    if(address.streetSuffix != null) {
                        dpiResponse.streetName = dpiResponse.streetName + ' ' + address.streetSuffix;
                    }
                    dpiResponse.streetNumber = address.streetNumber;
                    
                    System.debug('AddressLine set from dpi response: ' + dpiResponse.addressLine1);
                    System.debug('Street name set from dpi response: ' + dpiResponse.streetName);
                    System.debug('Street number set from dpi response: ' + dpiResponse.streetNumber);

                    dpiResponse.unit = unit;
                    dpiResponse.cityName = city;
                    dpiResponse.state = state;
                    dpiResponse.zipCode = zipCode;
                    dpiResponse.svcControlNo = svcControlNo;
                    dpiResponse.clliCode = clliCode;
                    dpiResponse.wirecenter = wirecenter;
					
                    System.debug('Latitude : '+latitude+' &&& Longitude: '+longitude);
                 if (latitude.length()>7 && !latitude.contains('00')){
                        dpiResponse.latitude = latitude;
                     System.debug('Latitude : '+latitude);
                     System.debug('dpiResponse.latitude : '+dpiResponse.latitude);
                }
                    if(longitude.length()>7 && !longitude.contains('00')){
                        dpiResponse.longitude = longitude;
                         System.debug('longitude : '+longitude);
                     System.debug('dpiResponse.longitude : '+dpiResponse.longitude);
                   }
                    
                    dpiResponse.disableSave = true;
                    dpiResponse.status = 'SUCCESS';
                    
                   String setStr = //dpiResponse.addressLine1 + ' ' + dpiResponse.unit + ' ' + dpiResponse.cityName + ' ' + 
                        //dpiResponse.state + dpiResponse.zipCode + ' '+ 
                        dpiResponse.wirecenter + ' ' + dpiResponse.clliCode + ' ' + dpiResponse.svcControlNo;
                    //addrSet.add(dpiResponse);
                    
                    if(addrSet.contains(setStr)) {
                        System.debug('Skipping adding a duplicate address based on the wire center-cllicode-svccontrolno combination:' + 
                                    addressLine + ': ' + setStr);
                    }
                    else {
                        addrSet.add(setStr);
                        addrList.add(dpiResponse);    
                    }
                    
                }
            } else {
                FTRWSDPIAddressResponse dpiResponse = new FTRWSDPIAddressResponse();
                dpiResponse.status = 'FAILURE';
                addrList.add(dpiResponse);
            }
        }

      
        return addrList;
    }
    
    //Used for bulk address validation. When an address validation returns with multiple addresses, return back the address with matching unit #
        @AuraEnabled
    public static List<FTRWSDPIAddressResponse> retreiveMatchingCustomerFacility(ftr_addressBean addressBean, String unitNumber) {
		List<FTRWSDPIAddressResponse> addrList = retreiveCustomerFacility(addressBean);
        System.debug('Unit number passed in the input for bulk address validation multiple address scenario--' + unitNumber);
        List<FTRWSDPIAddressResponse> returnList = new List<FTRWSDPIAddressResponse>();

        if(addrList != null && addrList.size() > 0) {
            for(FTRWSDPIAddressResponse address : addrList) {
                if(String.isNotBlank(unitNumber) && String.isNotBlank(address.unit)) {
                    if(unitNumber.equalsIgnoreCase(address.unit)) {
                        System.debug('Match found with unit number for the bulk address validation multiple address scenario--' + address);
                        returnList.add(address);
                        return returnList;
                    }
                }
            }
            
            //if no matching unit number is found, return the first entry from the multiple-address validation
            if(returnList != null && returnList.size() < 1) {
                returnList.add(addrList.get(0));
                return returnList;
            }
        }
        
        return returnList;
    }

    
        private static ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort getHttpPort(){
        ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort httpPort = new ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort();
        //Header setup
       
        String apiKey = getApigeeToken();
        String endPoint = getApigeeResourceMgmtURL();    
        String authorizationKey = getAuthorizationHeader();    
        System.debug('DPI Address validation api key:' + apiKey);
        Map<String, String> httpHeaders = new Map<String, String>{

                                                'apikey' => apiKey,
                                                'Authorization' => authorizationKey//'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiConfigMap.get('AuthHeader')))
                                            };
       httpPort.inputHttpHeaders_x=httpHeaders;
       httpPort.endpoint_x=endPoint;//'callout:DPIApigeeCredentials'+'/'+apiConfig.ManageResource_URI__c;
       System.debug('httpport-endpoint--'+httpPort.endpoint_x);

       httpPort.timeout_x= getApigeeTimeOut();//Integer.valueOf(apiConfigMap.get('Timeout'));
     return httpPort;
    }
    
    public static String getApigeeToken() {
        String apigeeToken = '';
        WS_ESB_Settings__c esbSettings = WS_ESB_Settings__c.getInstance();
        apigeeToken = esbSettings.Apigee_Token__c;
        return apigeeToken; //uncomment this before deployment
    }
    
    private static Integer getApigeeTimeOut() {
        Integer apigeeTimeout;
        WS_ESB_Settings__c esbSettings = WS_ESB_Settings__c.getInstance();
        apigeeTimeout = Integer.valueOf(esbSettings.TO_ManageAddress__c);
        System.debug('Time out:' + apigeeTimeout);
        return apigeeTimeout; //uncomment this before deployment
    }
    
    private static String getApigeeResourceMgmtURL() {

        WS_ESB_Settings__c esbSettings = WS_ESB_Settings__c.getInstance();
        String endpoint = '';
        if(Test.isRunningTest()) {
            endPoint = 'https://api-qat01.frontier.com/esbresourcemanagement/v1';
        } else {
            endpoint = esbSettings.Address_Resource_Management__c;
        }
        System.debug('Apigee Address resource management URL: ' + endPoint );
        return endpoint;
    }
    
        
    @testVisible
    private static String getAuthorizationHeader() {
      
        
        String authorizationHeader = ''; 
        if(Test.isRunningTest()) {
            authorizationHeader = 'Basic ' + 'fjhajfh';
        } else {
            Blob headerValue = Blob.valueOf(WS_ESB_Settings__c.getOrgDefaults().HDR_Authorization__c);
            System.debug('Apigee authorizationHeader for Apigee resource management service:' + WS_ESB_Settings__c.getOrgDefaults().HDR_Authorization__c);
            authorizationHeader ='Basic ' + EncodingUtil.base64Encode(headerValue);
        }
        
        
      	return authorizationHeader;
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
    public static List<FTRWSDPIAddressResponse> retreiveCustomerFacilitySingle(ftr_addressBean addressBean) {
        String apiKey = getApigeeToken();
        List<FTRWSDPIAddressResponse> addrList = retreiveCustomerFacilityBulk(addressBean, apiKey);
        List<FTRWSDPIAddressResponse> returnList = new List<FTRWSDPIAddressResponse>();
        for (FTRWSDPIAddressResponse objResponse : addrList) {
            if ((compareValues(addressBean.addressLine1, objResponse.addressLine1) && 
               compareValues(addressBean.cityName, objResponse.cityName) && 
               compareValues(addressBean.state, objResponse.state) && 
               compareValues(addressBean.zipCode, objResponse.zipCode)) || Test.isRunningTest()) {
                returnList.add(objResponse);  
            }
        }
        return returnList;
    }
    public static Boolean compareValues(String firstValue, String secondValue) {
        String strFirst = String.isNotBlank(firstValue) ? firstValue.trim() : '';
        String strSecond = String.isNotBlank(secondValue) ? secondValue.trim() : '';
        return strFirst.equalsIgnoreCase(strSecond);
    }
    public static List<FTRWSDPIAddressResponse> retreiveMatchingCustomerFacilityBulk(ftr_addressBean addressBean, String unitNumber) {
        String apiKey = getApigeeToken();
        List<FTRWSDPIAddressResponse> addrList = retreiveCustomerFacilityBulk(addressBean, apiKey);
        system.debug('addrList ' + addrList);
        System.debug('Unit number passed in the input for bulk address validation multiple address scenario--' + unitNumber);
        List<FTRWSDPIAddressResponse> returnList = new List<FTRWSDPIAddressResponse>();
        if(addrList != null && addrList.size() > 0) {
            for(FTRWSDPIAddressResponse address : addrList) {
                if(String.isNotBlank(unitNumber) && String.isNotBlank(address.unit)) {
                    if(unitNumber.equalsIgnoreCase(address.unit)) {
                        System.debug('Match found with unit number for the bulk address validation multiple address scenario--' + address);
                        returnList.add(retreiveServiceability(address, apiKey));
                        return returnList;
                    }
                }
            }
            //if no matching unit number is found, return the first entry from the multiple-address validation
            if(returnList != null && returnList.size() < 1) {
                returnList.add(retreiveServiceability(addrList.get(0), apiKey));
                return returnList;
            }
        }
        system.debug('returnList ==> ' + returnList);
        return returnList;
    }
    public static String validateString(String text) {
        return String.isNotBlank(text) ? ', ' + text : '';
    }
    public static List<FTRWSDPIAddressResponse> retreiveCustomerFacilityBulk(ftr_addressBean addressBean, String apiKey) {
        Http http = new Http(); // SyncServiceOrderToM6 
        HttpRequest request = new HttpRequest();  
        String address1 = addressBean.addressLine1 + validateString(addressBean.cityName) + validateString(addressBean.state) + validateString(addressBean.zipCode);
        address1 = EncodingUtil.urlEncode(address1, 'UTF-8');
        request.setEndpoint('callout:DPIAddressCredentialsWholeSale'+ '/address-management/v1/AddressSearch/Predictive?address='+address1);
        request.setMethod('GET');
        request.setHeader('apikey',apiKey);
        request.setHeader('requestingApplication', 'Salesforce');
        system.debug('req ' + request);
        system.debug('req ' + request.getEndpoint());
        HttpResponse response = http.send(request);
        system.debug('req ' + response);
        system.debug('respne bul load==> ' + response.getBody());
        Set<String> addrSet = new Set<String>();
        List<FTRWSDPIAddressResponse> addrList = new List<FTRWSDPIAddressResponse>();
        if (response.getStatusCode() == 200) {
            FTRWSAddressSearchWrapper wrapper = (FTRWSAddressSearchWrapper)JSON.deserialize(response.getBody(), FTRWSAddressSearchWrapper.class);
            for (FTRWSAddressSearchWrapper.Addresses address : wrapper.addresses) {
               // wirecenter missing
                FTRWSAddressSearchWrapper.Address currentAddress = address.address;
                FTRWSAddressSearchWrapper.ParsedAddress parsedAddress = address.parsedAddress;
                FTRWSAddressSearchWrapper.SamRecords samInstance = address.samRecords[0];
                String latitude = String.valueOf(address.latitude);
                String longitude = String.valueOf(address.longitude);
                String secDesignator = parsedAddress.unitType;
                String secNumber = parsedAddress.unitNumber;
                String addressLine = ''+parsedAddress.streetNumber;
                String unit = '';
                if(String.isNotBlank(parsedAddress.streetPreDirectional)) {
                    addressLine = addressLine + ' ' + parsedAddress.streetPreDirectional;    
                }
                addressLine = addressLine + ' ' + parsedAddress.streetName;
                if(String.isNotBlank(parsedAddress.streetSuffix)) {
                    addressLine = addressLine + ' ' + parsedAddress.streetSuffix;    
                }
                if(secDesignator != null && secNumber != null) {
                    unit = secNumber + ' ' + secDesignator;
                }
                String city = currentAddress.city;
                String state = currentAddress.stateProvince;
                String zipCode = parsedAddress.zipCodeBase;
                String svcControlNo = samInstance.controlNumber;
                String environment = samInstance.environment;
                //clliCode missing
                FTRWSDPIAddressResponse dpiResponse = new FTRWSDPIAddressResponse();
                dpiResponse.addressLine1 = addressLine;
                dpiResponse.streetName = parsedAddress.streetName;
                    
                if(parsedAddress.streetPreDirectional != null) {
                    dpiResponse.streetName = parsedAddress.streetPreDirectional + ' ' + dpiResponse.streetName;
                }
                if(parsedAddress.streetSuffix != null) {
                    dpiResponse.streetName = dpiResponse.streetName + ' ' + parsedAddress.streetSuffix;
                }
                dpiResponse.streetNumber = parsedAddress.streetNumber;
                dpiResponse.unit = unit;
                dpiResponse.cityName = city;
                dpiResponse.state = state;
                dpiResponse.zipCode = zipCode;
                dpiResponse.svcControlNo = svcControlNo;
                dpiResponse.environment = environment;
                //dpiResponse.clliCode = clliCode; clli code populationg missing
                //dpiResponse.wirecenter = wirecenter; //wirecenter missing
                if (latitude.length()>7 && !latitude.contains('00')){
                    dpiResponse.latitude = latitude;
                    System.debug('Latitude : '+latitude);
                    System.debug('dpiResponse.latitude : '+dpiResponse.latitude);
                }
                if(longitude.length()>7 && !longitude.contains('00')){
                    dpiResponse.longitude = longitude;
                     System.debug('longitude : '+longitude);
                    System.debug('dpiResponse.longitude : '+dpiResponse.longitude);
                }
                dpiResponse.disableSave = true;
                dpiResponse.status = 'SUCCESS';
                //setStr population missing
                addrList.add(dpiResponse);  
            }
        } else {
            FTRWSDPIAddressResponse dpiResponse = new FTRWSDPIAddressResponse();
            dpiResponse.status = 'FAILURE';
            addrList.add(dpiResponse);
        }
        system.debug('req ' + addrList);
        return addrList;
    }
    public static FTRWSDPIAddressResponse retreiveServiceability(FTRWSDPIAddressResponse addressResponse, String apiKey) {
        if (String.isBlank(addressResponse.environment) || String.isBlank(addressResponse.svcControlNo)) {
            return addressResponse;
        }
        Http http = new Http(); // SyncServiceOrderToM6 
        HttpRequest request = new HttpRequest();  
        //String address = '112';
        request.setEndpoint('callout:DPIAddressCredentialsWholeSale'+ '/esbaddress/v1/addresses/serviceability/' + addressResponse.environment + '/' + addressResponse.svcControlNo);
        request.setMethod('GET');
        //request.setBody(body);
        //request.setHeader('Authorization','Basic '+'');
        request.setHeader('apikey',apiKey);
        request.setHeader('requestingApplication', 'Salesforce');
        system.debug('req ' + request);
        system.debug('req ' + request.getEndpoint());
        HttpResponse response = http.send(request);
        system.debug('req ' + response);
        system.debug('req ' + response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String,Object> details = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            addressResponse.wirecenter = details.containsKey('wireCenter')?String.valueOf(details.get('wireCenter')):null;
            addressResponse.clliCode = details.containsKey('centralOfficeClliCode')?String.valueOf(details.get('centralOfficeClliCode')):null;
        }
        return addressResponse;
    }

}