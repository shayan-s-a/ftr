global class WS_BATCH_HughesAddressValidation implements Database.Batchable<AgentTools_AddressValidation.HughesRequest>, Database.AllowsCallouts, Database.Stateful {
    
    global List<AgentTools_AddressValidation.HughesRequest> HUGHES_REQUESTS;
    global List<AgentTools_AddressValidation.HughesRequest> HUGHES_RESPONSES {get;set;}
    global WS_ESB_ManageAddress.Callout AddressCallout = new WS_ESB_ManageAddress.Callout();
    
    global WS_BATCH_HughesAddressValidation(List<AgentTools_AddressValidation.HughesRequest> lstHughesRequests){
        HUGHES_REQUESTS = lstHughesRequests;
        HUGHES_RESPONSES = new List<AgentTools_AddressValidation.HughesRequest>();
    }
    
    global List<AgentTools_AddressValidation.HughesRequest> start(Database.BatchableContext BC){
        return HUGHES_REQUESTS;
    }

    global void execute(Database.BatchableContext BC, List<AgentTools_AddressValidation.HughesRequest> scope){
        /*for(AgentTools_AddressValidation.HughesRequest HR : scope){
            HUGHES_RESPONSES.add(UpdateItem_Address(HR));
        }*/
        for(AgentTools_AddressValidation.HughesRequest HR : scope){
            ftr_addressBean addressBean = new ftr_addressBean();
            addressBean.addressLine1=HR.serviceAddress1 + ' ' + HR.serviceAddress2;
            addressBean.cityName=HR.city;
            addressBean.state=HR.state;
            addressBean.zipCode=HR.zip;
            List<FTRWSDPIAddressResponse> dpiResponseResults = FTRWSDPIAddressController.retreiveCustomerFacilitySingle(addressBean); 
            if(dpiResponseResults != null && dpiResponseResults.size() > 0) {
                FTRWSDPIAddressResponse dpiResp = dpiResponseResults.get(0);
                String apiKey = FTRWSDPIAddressController.getApigeeToken();
                HUGHES_RESPONSES.add(retrieveServiceabilityCustom(dpiResp, apiKey, HR));
            }
        }
    }
    private static String getAuthorizationHeader() {
      
        
        Blob headerValue = Blob.valueOf(WS_ESB_Settings__c.getOrgDefaults().HDR_Authorization__c);
            System.debug('Apigee authorizationHeader for Apigee resource management service:' + WS_ESB_Settings__c.getOrgDefaults().HDR_Authorization__c);
            String authorizationHeader ='Basic ' + EncodingUtil.base64Encode(headerValue);
        
        
      	return authorizationHeader;
    }
    
    public AgentTools_AddressValidation.HughesRequest retrieveServiceabilityCustom(FTRWSDPIAddressResponse dpiResp, String apiKey, AgentTools_AddressValidation.HughesRequest HR) {
        String authorizationHeader = getAuthorizationHeader();
        HttpRequest req = new HttpRequest();
        //singleAddressLookup
        String endpointURL =  WS_ESB_Settings__c.getOrgDefaults().Serviceability_URI__c;
        	req.setEndpoint(endpointURL + dpiResp.environment + '/' + dpiResp.svcControlNo);
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
            //objResponse.FBV_Available = AgentTools_GetTechnologyForAddress.getTechnologyForAddress(objResponse.ServiceAddressMasterId.environment, objResponse.ServiceAddressMasterId.controlNumber);               
        	HR.fiberUpDown = objResponse.AccountSpeed;
            //HR.hsiUpDown = objResponse.AccountSpeed;
            //HR.fiberVideo = objResponse.FBV_Available;
        } 
        system.debug('objResponse ==> ' + objResponse);
        system.debug('HR ==> ' + HR);
        return HR;
    }
    
    global void finish(Database.BatchableContext BC){
        String csvContent = 'Site Id,Customer Id,Service Phone,Service Address1,Service Address2,City,State,Zip,HSI Speed,Fiber Speed,Fiber Video\n';
        for(AgentTools_AddressValidation.HughesRequest HR : HUGHES_RESPONSES){
            csvContent += HR.siteId + ',';
            csvContent += HR.customerId + ',';
            csvContent += HR.servicePhone + ',';
            csvContent += HR.serviceAddress1 + ',';
            csvContent += HR.serviceAddress2 + ',';
            csvContent += HR.city + ',';
            csvContent += HR.state + ',';
            csvContent += HR.zip + ',';
            csvContent += HR.hsiUpDown + ',';
            csvContent += HR.fiberUpDown + ',';
            csvContent += HR.fiberVideo + '\n';
        }
        //Attachment attachment = new Attachment();
        //attachment.Body = Blob.valueOf(csvContent);
        //attachment.Name = 'results_' + system.now() + '.csv';

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();      
        msg.setToAddresses(new String[] {userinfo.getUserEmail()});
        msg.setReplyTo('randy.buhrt@ftr.com');
        msg.setSenderDisplayName('Frontier - Salesforce Automation');
        msg.setSubject('Address Batch Results');
        msg.setPlainTextBody('Please download the attached .csv file to access available service information.');

        Messaging.EmailFileAttachment msg_attachment = new Messaging.EmailFileAttachment();
        msg_attachment.setFileName('service_results_' + system.now() + '.csv');
        msg_attachment.setBody(Blob.valueOf(csvContent));
        msg.setFileAttachments(new Messaging.EmailFileAttachment[] {msg_attachment});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {msg});
    }

    /*private AgentTools_AddressValidation.HughesRequest UpdateItem(AgentTools_AddressValidation.HughesRequest HR){
        WS_ESB_ManageAddress.ManageAddressGetAddressRequest TN_Request = new WS_ESB_ManageAddress.ManageAddressGetAddressRequest();
        TN_Request.RequestCriteria.TelephoneNumber = new WS_ESB_BusinessObjects.TelephoneNumber();
        TN_Request.RequestCriteria.TelephoneNumber.Number_x = HR.servicePhone;
        TN_Request.RequestCriteria.Action = 'RetrieveServiceAddress';
        try{
            WS_ESB_ManageAddress.ManageAddressGetAddressResponse TN_Response = AddressCallout.GetAddress(TN_Request.RequestCriteria);
            WS_ESB_ManageAddress.ManageAddressGetAddressRequest SN_Request = new WS_ESB_ManageAddress.ManageAddressGetAddressRequest();
            SN_Request.RequestCriteria.Address = new WS_ESB_BusinessObjects.AddressType();
            SN_Request.RequestCriteria.Action = 'RetrieveServiceAddress';
            for(WS_ESB_BusinessObjects.AddressType this_address : TN_Response.Address){
                SN_Request.RequestCriteria.Address.ServiceAddress = this_address.ServiceAddress;
            }
            WS_ESB_ManageAddress.ManageAddressGetAddressResponse SN_Response = AddressCallout.GetAddress(SN_Request.RequestCriteria);
            for(WS_ESB_BusinessObjects.AddressType this_address : SN_Response.Address){
                if(this_address.ServiceAddress.FiberVideoAvailableFlag){
                    HR.fiberVideo = 'Available';
                }               
                for(WS_ESB_BusinessObjects.ConnectionType this_connectiontype : this_address.ServiceAddress.InternetInfo.Connections.Connection){
                    for(WS_ESB_BusinessObjects.TechnologyType this_technology : this_connectiontype.Technologies.Technology){
                        if(this_technology.CustomerType == 'Business'){
                            if(this_technology.Technology == 'FIBER' && this_technology.TechnologyGroup == 'FIBER'){
                                HR.fiberUpDown = this_technology.AvailableSpeed;
                            }
                            if(this_technology.Technology != 'FIBER' && this_technology.TechnologyGroup != 'FIBER'){
                                if(HR.hsiUpDown != null || HR.hsiUpDown != 'N/A'){
                                    //HR.hsiUpDown = this_technology.AvailableSpeed;
                                    HR.hsiUpDown = this_address.ServiceAddress.InternetInfo.AvailableMaxProductSpeed;
                                }
                            }                           
                        }
                    }
                }
            }           
        }catch(Exception e){

        }
        system.debug(HR);
        return HR;
    } */
    
    /*public AgentTools_AddressValidation.HughesRequest UpdateItem_Address(AgentTools_AddressValidation.HughesRequest HR){
        if(HR.ServicePhone != null && HR.ServicePhone.length() > 0) {
        	System.debug('1   '+HR.hsiUpDown);
            WS_ESB_ManageAddress.ManageAddressGetAddressRequest TN_Request = new WS_ESB_ManageAddress.ManageAddressGetAddressRequest();
            TN_Request.RequestCriteria.TelephoneNumber = new WS_ESB_BusinessObjects.TelephoneNumber();
            TN_Request.RequestCriteria.TelephoneNumber.Number_x = HR.servicePhone;
            TN_Request.RequestCriteria.Action = 'RetrieveServiceAddress';
            try{
            	System.debug('2    '+HR.hsiUpDown);
                WS_ESB_ManageAddress.ManageAddressGetAddressResponse TN_Response = AddressCallout.GetAddress(TN_Request.RequestCriteria);
                WS_ESB_ManageAddress.ManageAddressGetAddressRequest SN_Request = new WS_ESB_ManageAddress.ManageAddressGetAddressRequest();
                SN_Request.RequestCriteria.Address = new WS_ESB_BusinessObjects.AddressType();
                SN_Request.RequestCriteria.Action = 'RetrieveServiceAddress';
                for(WS_ESB_BusinessObjects.AddressType this_address : TN_Response.Address){
                    SN_Request.RequestCriteria.Address.ServiceAddress = this_address.ServiceAddress;
                }
                System.debug('3    '+HR.hsiUpDown);
                WS_ESB_ManageAddress.ManageAddressGetAddressResponse SN_Response = AddressCallout.GetAddress(SN_Request.RequestCriteria);
                System.debug('sunil response   '+SN_Response);
                for(WS_ESB_BusinessObjects.AddressType this_address : SN_Response.Address){
                	System.debug('4    '+HR.hsiUpDown);
                    if(this_address.ServiceAddress.FiberVideoAvailableFlag){
                        HR.fiberVideo = 'Available';
                    }               
                    for(WS_ESB_BusinessObjects.ConnectionType this_connectiontype : this_address.ServiceAddress.InternetInfo.Connections.Connection){
                    	System.debug('5    '+HR.hsiUpDown);
                        for(WS_ESB_BusinessObjects.TechnologyType this_technology : this_connectiontype.Technologies.Technology){
                        	System.debug('6    '+HR.hsiUpDown);
                            if(this_technology.CustomerType == 'Business'){
                            	System.debug('7    '+HR.hsiUpDown);
                                if(this_technology.Technology == 'FIBER' && this_technology.TechnologyGroup == 'FIBER'){
                                	System.debug('8    '+HR.hsiUpDown);
                                    HR.fiberUpDown = this_technology.AvailableSpeed;
                                }
                                if(this_technology.Technology != 'FIBER' && this_technology.TechnologyGroup != 'FIBER'){
                                	System.debug('9    '+HR.hsiUpDown);
                                    if(HR.hsiUpDown != null || HR.hsiUpDown != 'N/A'){
                                        //HR.hsiUpDown = this_technology.AvailableSpeed;
                                        System.debug('10    '+HR.hsiUpDown);
                                        HR.hsiUpDown = this_address.ServiceAddress.InternetInfo.AvailableMaxProductSpeed;
                                    }
                                }                           
                            }
                        }
                    }
                }           
            }catch(Exception e){

            }
        } else {
        	System.debug('Sunil  2nd  ');
            WS_ESB_ManageAddress.Callout AddressCallout = new WS_ESB_ManageAddress.Callout();
            //System.debug('Sunil  2nd  '+ Response);
            try {
                WS_ESB_ManageAddress.ManageAddressGetAddressResponse Response = AddressCallout.GetAddress(RPSA_Request(HR).RequestCriteria);
                System.debug('10    '+ Response);
                system.debug('Sunil 2nd'+Response);
                if(Response.ExecutionContext.ExecutionStatus.ExecutionStatusSuccessFlag){ 
                	  System.debug('Sunil    '+ Response.ExecutionContext.ExecutionStatus.ExecutionStatusSuccessFlag);                                                                            
                    if(Response.Address.size() == 1){//Example #1
                        Integer i = 1; 
                        for(WS_ESB_BusinessObjects.AddressType ThisAddress : Response.Address){
                            if(i<25){
                                if(ThisAddress.ServiceAddress.FiberVideoAvailableFlag){
                                        HR.fiberVideo = 'Available';
                                }
                                ServiceAddress NewServiceAddress = new ServiceAddress();
                                NewServiceAddress.RecordId = i;
                                NewServiceAddress.Address = ThisAddress.ServiceAddress;
                                for(WS_ESB_BusinessObjects.ConnectionType this_connectiontype : ThisAddress.ServiceAddress.InternetInfo.Connections.Connection){
                                    if(this_connectiontype.Technologies != null){
                                        if(this_connectiontype.Technologies.Technology != null){
                                            for(WS_ESB_BusinessObjects.TechnologyType this_technology : this_connectiontype.Technologies.Technology){
                                                if(this_technology.CustomerType == 'Business'){
                                                    if(this_technology.Technology == 'FIBER' && this_technology.TechnologyGroup == 'FIBER'){
                                                        HR.fiberUpDown = this_technology.AvailableSpeed;
                                                    }
                                                    if(this_technology.Technology != 'FIBER' && this_technology.TechnologyGroup != 'FIBER'){
                                                        if(HR.hsiUpDown != null || HR.hsiUpDown != 'N/A'){
                                                            //HR.hsiUpDown = this_technology.AvailableSpeed;
                                                            HR.hsiUpDown = ThisAddress.ServiceAddress.InternetInfo.AvailableMaxProductSpeed;
                                                        }
                                                    }
                                                    NewServiceAddress.Business_Technologies.add(this_technology);
                                                }else if(this_technology.CustomerType == 'Residential'){
                                                    NewServiceAddress.Residential_Technologies.add(this_technology);
                                                }
                                            }
                                        }
                                    }
                                }
                                //ServiceAddresses.add(NewServiceAddress);
                                i++;
                            }
                        }
                    }else if(Response.Address.size() > 1){//Example #5
                        Integer i = 1; 
                        for(WS_ESB_BusinessObjects.AddressType ThisAddress : Response.Address){
                            if(i<50){
                                if(ThisAddress.ServiceAddress.FiberVideoAvailableFlag){
                                        HR.fiberVideo = 'Available';
                                }
                                ServiceAddress NewServiceAddress = new ServiceAddress();
                                NewServiceAddress.RecordId = i;
                                NewServiceAddress.Address = ThisAddress.ServiceAddress;
                                for(WS_ESB_BusinessObjects.ConnectionType this_connectiontype : ThisAddress.ServiceAddress.InternetInfo.Connections.Connection){
                                    if(this_connectiontype.Technologies != null){
                                        if(this_connectiontype.Technologies.Technology != null){
                                            for(WS_ESB_BusinessObjects.TechnologyType this_technology : this_connectiontype.Technologies.Technology){
                                                if(this_technology.CustomerType == 'Business'){
                                                    NewServiceAddress.Business_Technologies.add(this_technology);
                                                    if(this_technology.Technology == 'FIBER' && this_technology.TechnologyGroup == 'FIBER'){
                                                        HR.fiberUpDown = this_technology.AvailableSpeed;
                                                    }
                                                    if(this_technology.Technology != 'FIBER' && this_technology.TechnologyGroup != 'FIBER'){
                                                        if(HR.hsiUpDown != null || HR.hsiUpDown != 'N/A'){
                                                            //HR.hsiUpDown = this_technology.AvailableSpeed;
                                                            HR.hsiUpDown = ThisAddress.ServiceAddress.InternetInfo.AvailableMaxProductSpeed;
                                                        }
                                                    }
                                                }else if(this_technology.CustomerType == 'Residential'){
                                                    NewServiceAddress.Residential_Technologies.add(this_technology);
                                                }
                                            }
                                        }
                                    }
                                }
                                //ServiceAddresses.add(NewServiceAddress);
                                i++;
                            }
                        }
                    }
                } else{
                    if(Response.ExecutionContext.ExecutionStatus.ExecutionStatusMessage.size() > 0){
                        for(WS_ESB_ExecutionContext.ExecutionStatusMessage Message : Response.ExecutionContext.ExecutionStatus.ExecutionStatusMessage){
                            Set<String> AllowedStatusCodes = new Set<String>{'-99','57','-1'};
                            if(AllowedStatusCodes.contains(Message.ExecutionStatusCode)){
                                Datetime RSA_DT = datetime.now();
                                try {
                                    //Example #2                                    
                                    WS_ESB_ManageAddress.ManageAddressGetAddressResponse Response2 = AddressCallout.GetAddress(RSA_Request(HR).RequestCriteria);
                                    //LIST_CALLOUTS.add(LOG_API(RSA_DT,AddressCallout.outputHttpHeaders_x));
                                    if(Response2.ExecutionContext.ExecutionStatus.ExecutionStatusSuccessFlag){                  
                                        if(Response2.Address.size() > 0){
                                            Integer i = 1; 
                                            for(WS_ESB_BusinessObjects.AddressType ThisAddress : Response2.Address){
                                                if(i<25){
                                                    if(ThisAddress.ServiceAddress.FiberVideoAvailableFlag){
                                                            HR.fiberVideo = 'Available';
                                                    }
                                                    ServiceAddress NewServiceAddress = new ServiceAddress();
                                                    NewServiceAddress.RecordId = i;
                                                    NewServiceAddress.Address = ThisAddress.ServiceAddress;
                                                    for(WS_ESB_BusinessObjects.ConnectionType this_connectiontype : ThisAddress.ServiceAddress.InternetInfo.Connections.Connection){
                                                        if(this_connectiontype.Technologies != null){
                                                            if(this_connectiontype.Technologies.Technology != null){
                                                                for(WS_ESB_BusinessObjects.TechnologyType this_technology : this_connectiontype.Technologies.Technology){
                                                                    if(this_technology.CustomerType == 'Business'){
                                                                        NewServiceAddress.Business_Technologies.add(this_technology);
                                                                        if(this_technology.Technology == 'FIBER' && this_technology.TechnologyGroup == 'FIBER'){
                                                                            HR.fiberUpDown = this_technology.AvailableSpeed;
                                                                        }
                                                                        if(this_technology.Technology != 'FIBER' && this_technology.TechnologyGroup != 'FIBER'){
                                                                            if(HR.hsiUpDown != null || HR.hsiUpDown != 'N/A'){
                                                                                //HR.hsiUpDown = this_technology.AvailableSpeed;
                                                                                HR.hsiUpDown = ThisAddress.ServiceAddress.InternetInfo.AvailableMaxProductSpeed;
                                                                            }
                                                                        }
                                                                    }else if(this_technology.CustomerType == 'Residential'){
                                                                        NewServiceAddress.Residential_Technologies.add(this_technology);
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    //ServiceAddresses.add(NewServiceAddress);
                                                    i++;
                                                }
                                            }
                                        }
                                    }else{
                                        if(Response2.ExecutionContext.ExecutionStatus.ExecutionStatusMessage.size() > 0){
                                            for(WS_ESB_ExecutionContext.ExecutionStatusMessage Message2 : Response2.ExecutionContext.ExecutionStatus.ExecutionStatusMessage){
                                                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Message2.ExecutionStatusDescription));
                                            }
                                        }
                                    }
                                }catch(Exception e){
                                    //EmailError(e);
                                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your request has encountered an error, your administrator has been notified'));
                                    //LOG_API(RSA_DT,e);
                                }
                            }
                        }
                    }
                }
            } catch(Exception e) {
            
            }
        }
        system.debug(HR);
        return HR;
    }
    
    public class ServiceAddress{
        public Integer RecordId {get;set;}      
        public WS_ESB_BusinessObjects.CitizensServiceAddress Address {get;set;}
        public List<WS_ESB_BusinessObjects.TechnologyType> Business_Technologies {get;set;}
        public List<WS_ESB_BusinessObjects.TechnologyType> Residential_Technologies {get;set;}
        
        public ServiceAddress(){
            Business_Technologies = new List<WS_ESB_BusinessObjects.TechnologyType>();
            Residential_Technologies = new List<WS_ESB_BusinessObjects.TechnologyType>();
        }
    }*/
    
    public WS_ESB_ManageAddress.ManageAddressGetAddressRequest RPSA_Request(AgentTools_AddressValidation.HughesRequest HR){
        WS_ESB_ManageAddress.ManageAddressGetAddressRequest AddressRequest = new WS_ESB_ManageAddress.ManageAddressGetAddressRequest();
        WS_ESB_BusinessObjects.AddressType AddressType = new WS_ESB_BusinessObjects.AddressType();                      
        WS_ESB_BusinessObjects.AddressText AddressText = new WS_ESB_BusinessObjects.AddressText();
        AddressText.AddressText = HR.ServiceAddress1 + ' ' + HR.ServiceAddress2;
        AddressText.SequenceNumber = 1;     
        AddressType.PostalAddress.AddressText.add(AddressText);     
        AddressType.PostalAddress.Locality = HR.City;
        AddressType.PostalAddress.StateOrProvince = HR.State;
        AddressType.PostalAddress.Postcode = HR.Zip;
        AddressRequest.RequestCriteria.Action = 'RetrievePostalAndServiceAddress';
        AddressRequest.RequestCriteria.Address = AddressType;
        return AddressRequest;
    }
    
    public WS_ESB_ManageAddress.ManageAddressGetAddressRequest RSA_Request(AgentTools_AddressValidation.HughesRequest HR){
        WS_ESB_ManageAddress.ManageAddressGetAddressRequest AddressRequest = new WS_ESB_ManageAddress.ManageAddressGetAddressRequest();
        WS_ESB_BusinessObjects.AddressType AddressType = new WS_ESB_BusinessObjects.AddressType();                      
        WS_ESB_BusinessObjects.AddressText AddressText = new WS_ESB_BusinessObjects.AddressText();
        AddressText.AddressText = HR.ServiceAddress1 + ' ' + HR.ServiceAddress2;
        AddressText.SequenceNumber = 1;     
        AddressType.PostalAddress.AddressText.add(AddressText);     
        AddressType.PostalAddress.Locality = HR.City;
        AddressType.PostalAddress.StateOrProvince = HR.State;
        AddressType.PostalAddress.PostCode = HR.Zip;
        AddressRequest.RequestCriteria.Action = 'RetrieveServiceAddress';
        AddressRequest.RequestCriteria.Address = AddressType;
        system.debug('Address Request:\n\n' + AddressRequest);
        return AddressRequest;
    }
}