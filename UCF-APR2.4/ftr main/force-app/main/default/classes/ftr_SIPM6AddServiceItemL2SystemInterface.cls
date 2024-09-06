/**
* @description webservice callout to ServiceItemRequest L2 interface
* @version : 1
*/  
global without sharing class ftr_SIPM6AddServiceItemL2SystemInterface extends ftr_SIPM6BaseSystemInterface {

    global class ftr_SIPM6AddServiceItemL2SystemInterfaceException extends Exception {}

    ftr_PSRService.PSRServicePort port;
    ftr_PSRService.addServiceItemRequestType request;
    
    global override String getOrchestrationTaskName() {
        System.debug('Task Name returned:'+TaskName_SIPAddServiceItemL2);
        return TaskName_SIPAddServiceItemL2;
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
        System.debug('@Anniemap-->'+ requestMap);
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
          system.debug('@dk1'+this.request);
        this.request.documentNumber = long.valueOf((String)requestMap.get('documentNumber'));//Long.valueOf('3170849');//
          system.debug('@dk2'+this.request);
        this.request.itemSpecificationId = long.valueOf((String)requestMap.get('itemSpecificationId'));//Long.valueOf('1102');
          system.debug('@dk3'+this.request);
        this.request.activityCode = 'N';
        this.request.parentServiceItemId = long.valueOf((String)requestMap.get('parentServiceItemId'));//Long.valueOf('7216447'); //from addServiceItemRequest L1 EVC
        system.debug('@dk4'+this.request.parentServiceItemId);

        if(requestMap.get('addressId') != null) this.request.addressId = long.valueOf((String)requestMap.get('addressId'));
        System.debug('**L2_request'+this.request);
        
        //priLoc       
        String prilocStreetName = String.valueOf(priLocAddressMap.get('streetName'));

        if (!String.isBlank(prilocStreetName)){

        this.request.priloc = new ftr_PSRService.locationType();
        this.request.priloc.endUserLocation = new ftr_PSRService.endUserLocationType();
        this.request.priloc.endUserLocation.locationName = String.valueOf(endUserPriLocationMap.get('locationName')).toUpperCase();//'abc'; //vlocity_cmt__Premises__c.vlocity_cmt__PropertyOwnerAccountId__r.Name
        this.request.priloc.endUserLocation.address = new ftr_PSRService.addressType();
        this.request.priloc.endUserLocation.address.houseNumber = prilocStreetName.substring(0,prilocStreetName.indexOf(' '));//'191002'; //vlocity_cmt__Premises__c.vlocity_cmt__StreetAddress__c
        this.request.priloc.endUserLocation.address.streetName = prilocStreetName.substringAfter(' ').toUpperCase();          
        this.request.priloc.endUserLocation.address.city = String.valueOf(priLocAddressMap.get('city')).toUpperCase();
        this.request.priloc.endUserLocation.address.state = String.valueOf(priLocAddressMap.get('state')).toUpperCase();//'NY';
        this.request.priloc.endUserLocation.address.postalCode = String.valueOf(priLocAddressMap.get('postalCode'));//'14607';
        this.request.priloc.endUserLocation.nci = String.valueOf(endUserPriLocationMap.get('nci')); //"order_items/described_by/Attribute Category/characteristic=[Primary Location NCI]/value
            
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
            this.request.secloc.endUserLocation.address.city = String.valueOf(secLocAddressMap.get('city')).toUpperCase();
            this.request.secloc.endUserLocation.address.state = String.valueOf(secLocAddressMap.get('state')).toUpperCase();//'NY';
            this.request.secloc.endUserLocation.address.postalCode = String.valueOf(secLocAddressMap.get('postalCode'));//'14607';
            this.request.secloc.endUserLocation.nci = String.valueOf(endUserSecLocationMap.get('secnci'));
            
                
            }
               
        System.debug('**L2_secloc'+this.request);
        //serviceItemValues
        List<ftr_PSRService.serviceItemValueType> servItemList = new List<ftr_PSRService.serviceItemValueType>();

        if(serviceItemValuesList.size() > 0) {
            for(Object servItem : serviceItemValuesList) {
                    System.debug('@ServItem'+servItem);
                Map<String, Object> servItemValMap = (Map<String, Object>)servItem;
                      System.debug('@SservItemValMap'+servItemValMap);
                ftr_PSRService.serviceItemValueType servItemVal = new ftr_PSRService.serviceItemValueType();
                  System.debug('@servItemVal'+servItemVal);
                servItemVal.label = String.valueOf(servItemValMap.get('label'));//'WTN'// RUID#1;
                 servItemVal.value = String.valueOf(servItemValMap.get('value'));//'0000000000';
                 System.debug('Managed Device val : '+(String)servItemVal.label);
                String manageddevice = (String)servItemVal.label;
                System.debug('Managed Device val : '+manageddevice);
            if(manageddevice.contains('MANAGED_DEVICE_UNI')){
                System.debug('Managed Device val : '+manageddevice);
                servItemVal.label ='MANAGED DEVICE';
                servItemVal.value ='Y';
            }
               
                servItemVal.activityCd = 'N';
                servItemList.add(servItemVal);
            }
        } else {
            ftr_PSRService.serviceItemValueType servItemVal = new ftr_PSRService.serviceItemValueType();
            servItemVal.label = String.valueOf(serviceItemValuesMap.get('label'));//'WTN'// RUID#1;
            String manageddevice = (String)servItemVal.label;
            if(manageddevice.contains('MANAGED_DEVICE_UNI')){
                System.debug('Managed Device val : '+manageddevice);
                servItemVal.label ='MANAGED DEVICE';
            }
            
            servItemVal.value = String.valueOf(serviceItemValuesMap.get('value'));//'0000000000';
            servItemVal.activityCd = 'N';
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
                ftr_PSRService.customAttributeType custAtt = new ftr_PSRService.customAttributeType();
                custAtt.caLabel = String.valueOf(customAttributeMap.get('caLabel'));//'67';
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
            throw new ftr_SIPM6AddServiceItemL2SystemInterfaceException(response.statusMessage.get(0).message);
        }
        
        System.debug('L2..'+ response.addServiceItemResult.serviceItemId);
        respMap.put('serviceItemId',String.valueOf(response.addServiceItemResult.serviceItemId));
        respMap.put('parentServiceItemId',String.valueOf(response.addServiceItemResult.parentServiceItemId));
        return respMap;
        
    }
}