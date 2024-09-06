public class AgentTools{
    public Boolean showBatchProcessMessage {get;set;}
    Public String SelectedCriteria {get;set;}
    public AgentTools_AddressValidation.LeadObject singleAddressLookup {get;set;}
    public List<AgentTools_AddressValidation.LeadObject> multipleAddressLookup {get;set;}
    public Blob multipleAddressFile {get;set;}
    List<List<String>> allFields {get;set;}
    public List<AgentTools_AddressValidation.HughesRequest> multipleHughesResponse {get;set;}
    public AgentTools_AddressValidation AddressValidation {get;set;}
    public AgentTools_DueDateCalculator DueDateCalculation {get;set;}
    public AgentTools_ProvisioningStatus ProvisioningStatus {get;set;}
    public String searchAddressText {get;set;}
    public FTRWSAddressSearchWrapper objAddressWrapper {get;set;}
    public Boolean showAddressSelection{get;set;}
    public String selectedAddress{get;set;}
	//comment for git pick v1

    public List<SelectOption> getSearchCriteria() {
        List<SelectOption> SearchCriteria = new List<SelectOption>();
        SearchCriteria.add(new selectOption('Address', 'Address')); 
        SearchCriteria.add(new selectOption('Telephone', 'Telephone'));
        return SearchCriteria;
    }

   
    public void ReadMultiFile(){
        showBatchProcessMessage = FALSE;
        String fileContent = '';
        
        try {
          fileContent = multipleAddressFile.toString();
        }catch (StringException ex) {
          HttpRequest tmp = new HttpRequest();
          tmp.setBodyAsBlob(multipleAddressFile);
          fileContent = tmp.getBody();
        }
        
        Boolean skipHeaders = true;
        
        allFields = new List<List<String>>();
        multipleHughesResponse = new List<AgentTools_AddressValidation.HughesRequest>();
        List<String> lines = new List<String>();
        try{
            lines = fileContent.split('\n');
        }catch (System.ListException e){
            System.debug('Limits exceeded?' + e.getMessage());
        }
        for(String line : lines) {
            if (line.replaceAll(',','').trim().length() == 0){
                break;
            }
            List<String> fields = line.split(',');
            System.debug('fields value '+line+' row values:'+fields);
            AgentTools_AddressValidation.HughesRequest hughesItem = new AgentTools_AddressValidation.HughesRequest();
            hughesItem.siteId = fields[0];
            hughesItem.customerId = fields[1];
            hughesItem.servicePhone = fields[2].replace('(','').replace(')','').replace('-','');
            hughesItem.serviceAddress1 = fields[3];
            hughesItem.serviceAddress2 = fields[4];
            hughesItem.city = fields[5];
            hughesItem.state = fields[6];
            hughesItem.zip = fields[7].trim();
            
            multipleHughesResponse.add(hughesItem);             
        }
        
        if(skipHeaders){
            multipleHughesResponse.remove(0);
        }
        database.executebatch(new WS_BATCH_HughesAddressValidation(multipleHughesResponse),5);
        showBatchProcessMessage = TRUE;
    }
    
    public AgentTools(){
        SelectedCriteria = 'Address';
        singleAddressLookup = new AgentTools_AddressValidation.LeadObject();
        DueDateCalculation = new AgentTools_DueDateCalculator();
        ProvisioningStatus = new AgentTools_ProvisioningStatus();
    }
    
    public void AddressValidation_Submit(){
        system.debug(logginglevel.info,singleAddressLookup);
        if(SelectedCriteria == 'Address'){
            if(
                (singleAddressLookup.Street == null || singleAddressLookup.Street == '') ||
                (singleAddressLookup.City == null || singleAddressLookup.City == '') ||
                //(singleAddressLookup.StateCode == null || singleAddressLookup.StateCode == '') ||
                (singleAddressLookup.State == null || singleAddressLookup.State == '') ||
                (singleAddressLookup.PostalCode == null || singleAddressLookup.PostalCode == '')
                ){
                    if(singleAddressLookup.Street == null || singleAddressLookup.Street == ''){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Street is required.'));         
                    }
                    if(singleAddressLookup.City == null || singleAddressLookup.City == ''){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'City is required.'));           
                    }
                    //if(singleAddressLookup.StateCode == null || singleAddressLookup.StateCode == ''){
                    if(singleAddressLookup.State == null || singleAddressLookup.State == ''){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'State/Province is required.'));         
                    }               
                    if(singleAddressLookup.PostalCode == null || singleAddressLookup.PostalCode == ''){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Zip/Postal Code is required.'));            
                    }
                }else{
                    AddressValidation = new AgentTools_AddressValidation(singleAddressLookup);
                    AddressValidation.SelectedCriteria = SelectedCriteria;
                    makeServiceAddressCallout();
                    //AddressValidation.RetrieveAddressRecords();
                }
        }else{
            AddressValidation = new AgentTools_AddressValidation(singleAddressLookup);
            AddressValidation.SelectedCriteria = SelectedCriteria;
            //AddressValidation.RetrieveAddressRecords();
            makeServiceAddressCallout();
        }
    }
    
    public void AddressValidation_Reset(){
        searchAddressText = '';
        objAddressWrapper = new FTRWSAddressSearchWrapper();
        singleAddressLookup = new AgentTools_AddressValidation.LeadObject();
        if(AddressValidation != null && AddressValidation.ServiceAddresses != null && !AddressValidation.ServiceAddresses.isEmpty()){
            AddressValidation.ServiceAddresses.clear();
        }
        if(AddressValidation != null && AddressValidation.objServiceAddress != null && !AddressValidation.objServiceAddress.isEmpty()){
            AddressValidation.objServiceAddress.clear();
        }
    }
    
    public Boolean getBusinessTechnologyRender(){
        if(AddressValidation != null && AddressValidation.objServiceAddress != null && !AddressValidation.objServiceAddress.isEmpty()){
            if(AddressValidation.objServiceAddress[0] != null && AddressValidation.objServiceAddress[0].technology != null && !AddressValidation.objServiceAddress[0].technology.isEmpty()){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    
    public Boolean getResidentialTechnologyRender(){
        if(AddressValidation != null && AddressValidation.SelectedRecord != null){
            if(AddressValidation.SelectedRecord.Residential_Technologies.size() > 0){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    
    public void doPredictiveSearch() {
        system.debug('searchText ==> ' + searchAddressText);
        //searchAddressText = 'asdas';
        if (String.isNotBlank(searchAddressText)) {
            String apiKey = getApigeeToken();
            Http http = new Http(); // SyncServiceOrderToM6 
            HttpRequest request = new HttpRequest();  
            //String address1 = addressBean.addressLine1 + validateString(addressBean.cityName) + validateString(addressBean.state) + validateString(addressBean.zipCode);
            String address1 = EncodingUtil.urlEncode(searchAddressText, 'UTF-8');
            request.setEndpoint('callout:DPIAddressCredentialsWholeSale'+ '/address-management/v1/AddressSearch/Predictive?applicationId=CommercialCRM&address='+address1);
            request.setMethod('GET');
            request.setHeader('apikey',apiKey);
            request.setHeader('requestingApplication', 'Salesforce');
            system.debug('req ' + request);
            system.debug('req ' + request.getEndpoint());
            HttpResponse response = http.send(request);
            system.debug('req ' + response.getBody());
            if(response.getStatusCode() == 200){
                system.debug('res. get doy ==> ' + response.getBody());
                String responseData = response.getBody();
                objAddressWrapper = (FTRWSAddressSearchWrapper)JSON.deserialize(responseData, FTRWSAddressSearchWrapper.class);
                showAddressSelection = objAddressWrapper != null && objAddressWrapper.addresses != null && !objAddressWrapper.addresses.isEmpty() ? true : false;
                system.debug('objAddressWrapper ' + objAddressWrapper);
                system.debug('showAddressSelection = ' + showAddressSelection);
            }
        } else {
            showAddressSelection = false;
        }
    }
    private static String getApigeeToken() {
        String apigeeToken = '';
        WS_ESB_Settings__c esbSettings = WS_ESB_Settings__c.getInstance();
        apigeeToken = esbSettings.Apigee_Token__c;
        return apigeeToken; //uncomment this before deployment
    }
    
    
    public void processAddressSelected() {
        system.debug('selectedAddress ==> ' + selectedAddress);
        if (String.isNotBlank(selectedAddress)) {
            FTRWSAddressSearchWrapper.ReadAddress objAddress = (FTRWSAddressSearchWrapper.ReadAddress)JSON.deserialize(selectedAddress, FTRWSAddressSearchWrapper.ReadAddress.class);
        	singleAddressLookup.Street = objAddress.addressLine1;
            singleAddressLookup.City = objAddress.city;
            singleAddressLookup.State = objAddress.stateProvince;
            singleAddressLookup.PostalCode = objAddress.zipCodeBase;
            singleAddressLookup.environment = objAddress.env;
            singleAddressLookup.controlNumber = objAddress.controlNumber;
            system.debug('singleAddressLookup ==> ' + singleAddressLookup);
        }
    }
    
    public void makeServiceAddressCallout() {
        String apiKey = getApigeeToken();
        String authorizationHeader = getAuthorizationHeader();
        HttpRequest req = new HttpRequest();
        //singleAddressLookup
        String endpointURL =  WS_ESB_Settings__c.getOrgDefaults().Serviceability_URI__c;
        if (SelectedCriteria == 'Address') {
        	req.setEndpoint(endpointURL + singleAddressLookup.controlNumber + '/' + singleAddressLookup.environment);
        } else {
            req.setEndpoint(endpointURL +'byphonenumber/' + singleAddressLookup.Telephone);
        }
        system.debug('end[pint ' + req.getEndpoint());
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
         req.setHeader('Authorization', authorizationHeader);
        system.debug('apiKey ' + apiKey);
        req.setHeader('apiKey', apiKey);
        req.setHeader('requestingApplication', 'D2DSterlingMobile');
        Http httpCls = new Http();
        HttpResponse response = httpCls.send(req);
        //String res = '{\r\n    \"offers\": [\r\n        \"fiberExpansion\",\r\n        \"incumbent\",\r\n        \"challenger1b\"\r\n    ],\r\n    \"address\": {\r\n        \"streetNumber\": \"9504\",\r\n        \"streetName\": \"AMY\",\r\n        \"streetSuffix\": \"DR\",\r\n        \"city\": \"QUINLAN\",\r\n        \"state\": \"TX\",\r\n        \"zipCode\": \"754740000\"\r\n    },\r\n    \"ServiceAddressMasterId\": {\r\n        \"controlNumber\": 6874643,\r\n        \"environment\": \"FT\"\r\n    },\r\n    \"telephoneNumber\": {\r\n        \"telephoneNumber\": \"0\"\r\n    },\r\n    \"timeZone\": {\r\n        \"timeZone\": \"America/Chicago\",\r\n        \"gmtOffset\": -5,\r\n        \"observesDST\": true\r\n    },\r\n    \"buildingType\": \"SINGLE_FAMILY\",\r\n    \"buildingUse\": \"RESIDENTIAL\",\r\n    \"plantArea\": \"CADDO MILLS\",\r\n    \"plantType\": \"OVERLAY\",\r\n    \"homingExchange\": 903447,\r\n    \"tariff\": \"TXC\",\r\n    \"rateCenter\": \"TAWAKONI\",\r\n    \"wireCenter\": 903447,\r\n    \"centralOfficeClliCode\": \"TAWKTXXADS0\",\r\n    \"remoteOfficeClliCode\": \"TAWKTXACRS0\",\r\n    \"isHoaRestrictedAddress\": false,\r\n    \"hasActiveServiceAtAddress\": true,\r\n    \"isPaClecAddress\": false,\r\n    \"hasLocalFranchiseAgreement\": true,\r\n    \"proximityToFootprint\": \"IN_FOOTPRINT\",\r\n    \"fiberBuildOutProjectId\": \"2022 FTTH\",\r\n    \"fiberBuildOutStatus\": \"IN_SERVICE\",\r\n    \"technology\": [\r\n        {\r\n            \"name\": \"XPON\",\r\n            \"medium\": \"FIBER\",\r\n            \"group\": \"FIBER\",\r\n            \"marketingSpeed\": \"5.0G/5.0G\",\r\n            \"features\": [\r\n                \"VOIP\",\r\n                \"POTS\"\r\n            ]\r\n        },\r\n        {\r\n            \"group\": \"Smartvoice\",\r\n            \"features\": [\r\n                \"VOIP\"\r\n            ]\r\n        }\r\n    ]\r\n}';
        ServiceAddressWrapper objResponse;
        system.debug('status code ' + response.getStatusCOde());
        system.debug('status response ' + response.getBody());
        if (response.getStatusCOde() == 200) {
            objResponse = (ServiceAddressWrapper)JSON.deserialize(response.getBody(), ServiceAddressWrapper.class);
            objResponse = ServiceAddressWrapper.parse(response.getBody());
            objResponse.FiberProductCapableFlag = false;
            objResponse.HSICapableFlag = false;
            objResponse.FBV_Available = false;
            objResponse.FiberVideoAvailableFlag = false;
            objResponse.UVerseCapable = false;
            objResponse.POTSCapable = false;
            if (objResponse.plantType == 'COPPER') {
                objResponse.HSICapableFlag = true;
            }
            if (objResponse.technology != null && !objResponse.technology.isEmpty()) {
                for (ServiceAddressWrapper.Technology objTech : objResponse.technology) {
                    List<String> featuresList = objTech.features != null ? objTech.features : new List<String>();
                    String strGroup = objTech.group_Z;
                    if (featuresList.contains('POTS')) {
                        objResponse.POTSCapable = true;
                    }
                    system.debug('strGroup ==> ' + strGroup);
                    system.debug('objTech ==> ' + objTech);
                    if (String.isNotBlank(strGroup) && strGroup == 'FIBER') {
                        objResponse.FiberProductCapableFlag = true;
                        objResponse.AccountSpeed = objTech.marketingSpeed;
                    }
                }
            }
            if (objResponse.ServiceAddressMasterId != null) {
            	objResponse.FBV_Available = AgentTools_GetTechnologyForAddress.getTechnologyForAddress(objResponse.ServiceAddressMasterId.environment, objResponse.ServiceAddressMasterId.controlNumber);               
            }
            AddressValidation.objServiceAddress = new List<ServiceAddressWrapper>{objResponse};
        } else {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your request has encountered an error, your administrator has been notified'));
        }
        system.debug('objResponse ==> ' + objResponse);
        
    }  
    private static String getAuthorizationHeader() {
      
        
        Blob headerValue = Blob.valueOf(WS_ESB_Settings__c.getOrgDefaults().HDR_Authorization__c);
            System.debug('Apigee authorizationHeader for Apigee resource management service:' + WS_ESB_Settings__c.getOrgDefaults().HDR_Authorization__c);
            String authorizationHeader ='Basic ' + EncodingUtil.base64Encode(headerValue);
        
        
      	return authorizationHeader;
    }
}