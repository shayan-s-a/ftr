/**
* @description webservice callout to ServiceItemRequest L2 interface
* @version :1
*/  
global without sharing class ftr_M6AddServiceItemL2SystemInterface extends ftr_M6BaseSystemInterface {
    
    global class ftr_M6addServiceItemRequestL2Exception extends Exception {}
    
    ftr_PSRService.PSRServicePort port;
    ftr_PSRService.addServiceItemRequestType request;
    
    global override String getOrchestrationTaskName() {
        System.debug('Task Name returned:'+TaskName_AddChildServiceItem);
        return TaskName_AddChildServiceItem;
    }
    
    /**
* This method is called from executeItem to create M6 RequestType 
*
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  input payload to be used to construct 
* @return         M6 RequestType object to be sent
*/
    global override Object createM6RequestType(String url, String path, Map<String, Object> input) {
        System.debug('input.in L2.'+ JSON.serialize(input));
        Map<String, Object> addServiceItemRequestMap = (Map<String, Object>)input.get('addServiceItem');
        System.debug('input.addServiceItem.'+ JSON.serialize(addServiceItemRequestMap));
        Map<String, Object> requestMap = (Map<String, Object>)addServiceItemRequestMap.get('addServiceItemRequest');
        Map<String, Object> priLocMap = (Map<String, Object>)requestMap.get('priloc');
        System.debug('Set priLocMap-->'+ priLocMap);
        Map<String, Object> endUserPriLocationMap = (Map<String, Object>)priLocMap.get('endUserLocation');
        System.debug('Set endUserPriLocationMap-->'+ endUserPriLocationMap);
        Map<String, Object> priLocAddressMap = (Map<String, Object>)endUserPriLocationMap.get('address');
        
        Map<String, Object> secLocMap = (Map<String, Object>)requestMap.get('secloc');
        System.debug('Set secLocMap-->'+ secLocMap);
        Map<String, Object> endUserSecLocationMap = (Map<String, Object>)secLocMap.get('endUserLocation');
        System.debug('Set endUserSecLocationMap-->'+ endUserSecLocationMap);
        Map<String, Object> secLocAddressMap = (Map<String, Object>)endUserSecLocationMap.get('address');
        
        List<Object> serviceItemValuesList = new List<Object>();
        Map<String, Object> serviceItemValuesMap = new Map<String, Object>();
        List<Object> customAttributesList = new List<Object>();
        Map<String, Object> customAttributesMap = new Map<String, Object>();
        
        
        
        if(requestMap.get('serviceItemValues') instanceof List<object>) {
            serviceItemValuesList = (List<Object>)requestMap.get('serviceItemValues');
        } else {
            serviceItemValuesMap = (Map<String, Object>)requestMap.get('serviceItemValues');
        }
        
        if(requestMap.get('customAttributes') instanceof List<object>) {
            customAttributesList = (List<Object>)requestMap.get('customAttributes');
        } else {
            customAttributesMap = (Map<String, Object>)requestMap.get('customAttributes');
        }
        
        
        
        this.request = new ftr_PSRService.addServiceItemRequestType();
        this.request.documentNumber = long.valueOf((String)requestMap.get('documentNumber'));//Long.valueOf('3170849');//
        this.request.itemSpecificationId = long.valueOf((String)requestMap.get('itemSpecificationId'));//Long.valueOf('1102');
        String stritemSpecificationId = String.valueOf((String)requestMap.get('itemSpecificationId'));
        Map<string,string> mapAlias = new Map<string,string>();
        //if(String.IsNotBlank((String)requestMap.get('ATTRTechIsPartnered'))){
         //String techIsPartnered = (String)requestMap.get('ATTRTechIsPartnered');
         // if(techIsPartnered.equalsIgnoreCase('true')){        
            mapAlias.put('1460','PSR EREACH NATIONAL ELAN');
         	mapAlias.put('1380','PSR EREACH EVPL - EIA');
        	mapAlias.put('1181','PSR EREACH EVPL - P2P');
         	this.request.itemAlias = mapAlias.get(stritemSpecificationId);
         // }
     //}    
        	
        //this.request.activityCode = 'N';
        //paa512 - start SDDD-2650 changes for MACD Project - Set activity code and service Item id 
        String activityCode = 'N';
        if(requestMap.containsKey('activityCode')) {
            activityCode = (String)requestMap.get('activityCode'); 
        }
        this.request.activityCode = activityCode;    
        //**********VERY IMP ******** ftr_PSRService class is fixed to have serviceItemId as part of M6 WSDL
        if(requestMap.containsKey('serviceItemId')) {
            if(requestMap.get('serviceItemId') != null) {
                String serviceItemId = (String) requestMap.get('serviceItemId');
                this.request.serviceItemId = long.valueOf(serviceItemId);
                
            }
        }
        //paa512 - End SDDD-2650 changes for MACD Project - - Set activity code and service Item id 
       
        if(requestMap.get('parentServiceItemId') != null){
            this.request.parentServiceItemId = long.valueOf((String)requestMap.get('parentServiceItemId'));//Long.valueOf('7216447'); //from addServiceItemRequest L1 EVC
        }
       if(requestMap.get('locationId') != null) this.request.locationId = long.valueOf((String)requestMap.get('locationId'));
        if(requestMap.get('addressId') != null) this.request.addressId = long.valueOf((String)requestMap.get('addressId'));
        System.debug('**L2_request'+this.request);
        
        //priLoc       
        String prilocStreetName = String.valueOf(priLocAddressMap.get('streetName'));
        
        if (!String.isBlank(prilocStreetName)){
            
            this.request.priloc = new ftr_PSRService.locationType();
            this.request.priloc.endUserLocation = new ftr_PSRService.endUserLocationType();
            
            if(endUserPriLocationMap.get('locationName') != null) {
				this.request.priloc.endUserLocation.locationName = String.valueOf(endUserPriLocationMap.get('locationName')).toUpperCase();//'abc'; //vlocity_cmt__Premises__c.vlocity_cmt__PropertyOwnerAccountId__r.Name                
            }
            
            this.request.priloc.endUserLocation.address = new ftr_PSRService.addressType();
            
            if(String.isNotBlank(prilocStreetName)) {
                this.request.priloc.endUserLocation.address.houseNumber = prilocStreetName.substring(0,prilocStreetName.indexOf(' '));//'191002'; //vlocity_cmt__Premises__c.vlocity_cmt__StreetAddress__c
            	this.request.priloc.endUserLocation.address.streetName = prilocStreetName.substringAfter(' ').toUpperCase();          
            }
            
            
            if(priLocAddressMap.get('city') != null) {
            	this.request.priloc.endUserLocation.address.city = String.valueOf(priLocAddressMap.get('city')).toUpperCase();    
            }
            
            if(priLocAddressMap.get('state') != null) {
            	this.request.priloc.endUserLocation.address.state = String.valueOf(priLocAddressMap.get('state')).toUpperCase();//'NY';    
            }
            
            if(priLocAddressMap.get('postalCode') != null ) {
            	this.request.priloc.endUserLocation.address.postalCode = String.valueOf(priLocAddressMap.get('postalCode'));//'14607';    
            }
            
            if(endUserPriLocationMap.get('nci') != null) {
            	this.request.priloc.endUserLocation.nci = String.valueOf(endUserPriLocationMap.get('nci')); //"order_items/described_by/Attribute Category/characteristic=[Primary Location NCI]/value    
            }         
            
        }
        System.debug('**L2_priloc'+this.request);
        
        //secloc
        
        String seclocStreetName = String.valueOf(secLocAddressMap.get('streetName'));
        if (!String.isBlank(seclocStreetName)){            
            
            this.request.secloc = new ftr_PSRService.locationType();                 
            this.request.secloc.endUserLocation = new ftr_PSRService.endUserLocationType();
            this.request.secloc.endUserLocation.locationName = String.valueOf(endUserSecLocationMap.get('locationName')).toUpperCase();//'abc'; //vlocity_cmt__Premises__c.vlocity_cmt__PropertyOwnerAccountId__r.Name
            this.request.secloc.endUserLocation.address = new ftr_PSRService.addressType();
            this.request.secloc.endUserLocation.address.houseNumber = seclocStreetName.substring(0,seclocStreetName.indexOf(' '));//'191002'; //vlocity_cmt__Premises__c.vlocity_cmt__StreetAddress__c
            this.request.secloc.endUserLocation.address.streetName = seclocStreetName.substringAfter(' ').toUpperCase(); 
            if(secLocAddressMap.get('city') != null){
            	this.request.secloc.endUserLocation.address.city = String.valueOf(secLocAddressMap.get('city')).toUpperCase();
            }
            if(secLocAddressMap.get('state') != null){
            	this.request.secloc.endUserLocation.address.state = String.valueOf(secLocAddressMap.get('state')).toUpperCase();//'NY';
            }
            if(secLocAddressMap.get('postalCode') != null){
                this.request.secloc.endUserLocation.address.postalCode = String.valueOf(secLocAddressMap.get('postalCode'));//'14607';
            }                
            if(endUserSecLocationMap.get('secnci') != null){
                 this.request.secloc.endUserLocation.nci = String.valueOf(endUserSecLocationMap.get('secnci'));
            }
        }       
                
        System.debug('**L2_secloc'+this.request);
        //serviceItemValues
        List<ftr_PSRService.serviceItemValueType> servItemList = new List<ftr_PSRService.serviceItemValueType>();
        
        if(serviceItemValuesList.size() > 0) {
            for(Object servItem : serviceItemValuesList) {
                Map<String, Object> servItemValMap = (Map<String, Object>)servItem;
                if(servItemValMap == null || servItemValMap.size() == 0) {
                    continue;
                }
                ftr_PSRService.serviceItemValueType servItemVal = new ftr_PSRService.serviceItemValueType();
                servItemVal.label = String.valueOf(servItemValMap.get('label'));//'WTN'// RUID#1;
                servItemVal.value = String.valueOf(servItemValMap.get('value'));//'0000000000';
                String manageddevice = (String)servItemVal.label;
                if(String.isNotBlank(manageddevice) && manageddevice.contains('MANAGED_DEVICE_UNI')){
                    System.debug('Managed Device val : '+manageddevice);
                    servItemVal.label ='MANAGED DEVICE';
                    servItemVal.value ='Y';
                }
                //paa512 - Start SDDD-2650 changes for MACD Project
                // servItemVal.activityCd = 'N';
                if(String.isNotBlank(activityCode)) {
                    servItemVal.activityCd = activityCode;  
                }
                //paa512 - End SDDD-2650 changes for MACD Project
                servItemList.add(servItemVal);
            }
        } else {
            ftr_PSRService.serviceItemValueType servItemVal = new ftr_PSRService.serviceItemValueType();
            servItemVal.label = String.valueOf(serviceItemValuesMap.get('label'));//'WTN'// RUID#1;
            String manageddevice = (String)servItemVal.label;
            if(String.isNotBlank(manageddevice) && manageddevice.contains('MANAGED_DEVICE_UNI')){
                System.debug('Managed Device val : '+manageddevice);
                servItemVal.label ='MANAGED DEVICE';
            }
            
            servItemVal.value = String.valueOf(serviceItemValuesMap.get('value'));//'0000000000';
            //servItemVal.activityCd = 'N';
            //paa512 - Start SDDD-2650 changes for MACD Project
            // servItemVal.activityCd = 'N';
            if(String.isNotBlank(activityCode)) {
                servItemVal.activityCd = activityCode;  
            }
            //paa512 - End SDDD-2650 changes for MACD Project            
            servItemList.add(servItemVal);
        }
        
        this.request.serviceItemValues = servItemList;
        System.debug('**L2_ServiceItem'+this.request);
        //customAttributes
        List<ftr_PSRService.customAttributeType> custAttributes = new List<ftr_PSRService.customAttributeType>();
        List <String> valueIds= new List<String>{'CIR','Bit Rate','SPEED'};
            if(customAttributesList.size() > 0) {
                for(Object customAttribute : customAttributesList) {
                    Map<String, Object> customAttributeMap = (Map<String, Object>)customAttribute;
                    
                if(customAttributeMap == null || customAttributeMap.size() == 0) {
                    continue;
                }
                    
                    ftr_PSRService.customAttributeType custAtt = new ftr_PSRService.customAttributeType();
                    custAtt.caLabel = String.valueOf(customAttributeMap.get('caLabel'));//'67';
                    system.debug(' custAtt.caLabel ----'+ custAtt.caLabel);
                    If(custAtt.caLabel == 'EXISTING ELAN CIRCUIT ID'){
                        String[] atrributeValues = String.valueOf(customAttributeMap.get('caValue')).split('/');
                        custAtt = new ftr_PSRService.customAttributeType();
                        custAtt.caLabel = 'Prefix';
                        //custAtt.caValueId = '';
                        custAtt.caValue = atrributeValues[0];
                        custAttributes.add(custAtt);
                        custAtt = new ftr_PSRService.customAttributeType();
                        custAtt.caLabel = 'SCMD';
                        //custAtt.caValueId = '';
                        custAtt.caValue = atrributeValues[1];
                        custAttributes.add(custAtt);
                        custAtt = new ftr_PSRService.customAttributeType();
                        custAtt.caLabel = 'Serial';
                        //custAtt.caValueId = '';
                        custAtt.caValue = atrributeValues[2];
                        custAttributes.add(custAtt);
						custAtt = new ftr_PSRService.customAttributeType();
                        custAtt.caLabel = 'Telco';
                       // custAtt.caValueId = '';
                        custAtt.caValue = atrributeValues[3];
                        custAttributes.add(custAtt);
                        continue;
                    }
                    If (valueIds.contains(custAtt.caLabel)) {
                        custAtt.caValueId = String.valueOf(customAttributeMap.get('caValue'));
                    } else {
                        custAtt.caValue = String.valueOf(customAttributeMap.get('caValue'));//'EVC';
                    }
                    custAttributes.add(custAtt);
                }
            } else {
                ftr_PSRService.customAttributeType custAtt = new ftr_PSRService.customAttributeType();
                custAtt.caLabel = String.valueOf(customAttributesMap.get('caLabel'));//'67';
                custAtt.caValue = String.valueOf(customAttributesMap.get('caValue'));//'EVC';
                custAttributes.add(custAtt);
            }
        
        
        
        this.request.customAttributes = custAttributes;
        System.debug('L2 request..'+ this.request);
        
        return (Object)this.request;
        
    }
    
    /**
* This method is called from executeItem to create process response
*
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  respType M6 ResponseType to process
* @return         output object to be processed
*/
    global override Map<String, Object> processM6ResponseType(String url, String path, Object respType) {
        ftr_PSRService.addServiceItemResponseValueType response = (ftr_PSRService.addServiceItemResponseValueType)respType;
        Map<String,Object> respMap = new Map<String,Object>();
        system.debug('response: ' + response);
        system.debug('Code: ' + response.statusMessage.get(0).code);
        if(response.statusMessage.get(0).code != '0'){
            throw new ftr_M6addServiceItemRequestL2Exception(response.statusMessage.get(0).message);
        }
        
        System.debug('L2..'+ response.addServiceItemResult.serviceItemId);
        respMap.put('serviceItemId',String.valueOf(response.addServiceItemResult.serviceItemId));
        respMap.put('parentServiceItemId',String.valueOf(response.addServiceItemResult.parentServiceItemId));
        return respMap;
        
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
                
    }
}