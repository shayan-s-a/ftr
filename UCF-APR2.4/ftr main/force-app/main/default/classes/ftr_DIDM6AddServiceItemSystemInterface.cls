/**
* @Author Hamza Shahid
* @Date 1-23-2023
 *@version           : 2
* @description webservice callout to AddServiceItemRequest DID L1 interface
*/ 
global without sharing class ftr_DIDM6AddServiceItemSystemInterface extends ftr_SIPM6BaseSystemInterface{
    global class ftr_DIDM6AddServiceItemSystemInterfaceException extends Exception {}
    
    ftr_PSRService.PSRServicePort port;
    ftr_PSRService.addServiceItemRequestType request;
    
    global override String getOrchestrationTaskName() {
        return TaskName_DIDAddServiceItem;
    }
    
    global Object createM6RequestTypeDID(String url, String path, Map<String, Object> mapDidLocations) {
        
        this.request = new ftr_PSRService.addServiceItemRequestType();
        ftr_PSRService.addServiceItemRequestType didLocation = new ftr_PSRService.addServiceItemRequestType();
		mapDIDLocations(mapDidLocations);
        this.request.documentNumber = Long.ValueOf((String)mapDidLocations.get('documentNumber'));
        this.request.itemSpecificationId = Long.ValueOf((String)mapDidLocations.get('itemSpecificationId'));
        this.request.locationId =Long.ValueOf((String)mapDidLocations.get('locationId'));
        this.request.addressId = Long.ValueOf((String)mapDidLocations.get('addressId'));
        this.request.activityCode = 'N';
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
       if(response.statusMessage.get(0).code != '0'){
            throw new ftr_DIDM6AddServiceItemSystemInterfaceException(response.statusMessage.get(0).message);
        }
        respMap.put('serviceItemId',String.valueOf(response.addServiceItemResult.serviceItemId));
        return respMap;
        
    }
    private void mapDIDLocations (Map<String, Object> reqAttrs) {
    	Long documentNumber = Long.ValueOf((String)reqAttrs.get('documentNumber')) ;
        Long itemSpecificationId = Long.ValueOf((String)reqAttrs.get('itemSpecificationId'));
        String locationId = (String)reqAttrs.get('locationId');
        String addressId = (String)reqAttrs.get('addressId');

        List<Map<String,Object>> serviceItemValuesReq = new List<Map<String,Object>>();
        if(Test.isRunningTest()) {
            List<Object> liDiDLoc = (List<Object>)reqAttrs.get('serviceItemValues');
            Map<String, Object> mapStringObj = new Map<String, Object>();
            for(Object obj:liDiDLoc) {
                mapStringObj = (Map<String,Object>)Json.deserializeUntyped(Json.serialize(obj));
                serviceItemValuesReq.add(mapStringObj);
            }
        } else {
            serviceItemValuesReq = (List<Map<String,Object>>)reqAttrs.get('serviceItemValues');
        }

       
        if(serviceItemValuesReq != Null && serviceItemValuesReq.size() > 0  ){
            System.debug('serviceItemValuesReq = ' + serviceItemValuesReq);
            System.debug('reqAttrs = ' + reqAttrs);
            List<ftr_PSRService.serviceItemValueType> lstDidNumbers = mapDIDNumbers(serviceItemValuesReq,reqAttrs);
            this.request.serviceItemValues = lstDidNumbers;
        }
        else{
            //System.debug('didNumbersList size = 0  ');
            //this.request.serviceItemValues = new List<Map<string,Object>>();
        }
        
		//}
    } 
    private List<ftr_PSRService.serviceItemValueType> mapDIDNumbers(List<Map<String, Object>> didreqAttrs,Map<String,Object> reqAttrs)
    {	
        Boolean isPsAli = false;
        Boolean isDidsNew = false;
        Boolean isDidsExisting = false;
        Boolean isPortIn = false;
        Boolean isWinback = false;
        Boolean isRegrade = false;
        String DidInfoM6; 

        List<Map<String,Object>> customAttributeMap = new  List<Map<String,Object>>();
        List<ftr_PSRService.serviceItemValueType> servItemList = new List<ftr_PSRService.serviceItemValueType>();
        for (Map<String,Object> didreq : didreqAttrs) {
            ftr_PSRService.serviceItemValueType servItem = new ftr_PSRService.serviceItemValueType();
            String didLabel = (String)didreq.get('label');
            String didValue = (String)didreq.get('value');
            
            if (didlabel == 'DIDS: New' )isDidsNew = true; if (didlabel == 'DIDS: Existing')isDidsExisting = true; if (didlabel == 'DIDS: Regrade')isDidsExisting = true;if (didlabel == 'DIDS: Winback')isWinback = true;if (didlabel == 'DIDS: Port In')isPortIn = true; if(isDidsNew == true )DidInfoM6 = 'New DIDs';
		
		    if(isDidsExisting == true )DidInfoM6 = 'Existing DIDs';if(isWinback == true )DidInfoM6 = 'Port-In (Winback)';if(isPortIn == true )DidInfoM6 = 'Port-In (Winback)';if(isDidsNew == true && isDidsExisting == true ) DidInfoM6 = 'Combo';if(isDidsNew == true && isWinback == true )DidInfoM6 = 'Combo New & Port-In';
            
            servItem.label = didLabel;
            servItem.value = didValue;
            servItem.activityCd = 'N';
            servItemList.Add(servItem);
        }
		List <String> valueIds= new List<String>{'*Main DN','*Cust Defined Loc Name','# Of Call Paths','DID Info','International Dialing','International Dialing = Y','Config: TG Failover TN','DID Test Number','CPE/PBX Manufacturer','CPE/PBX Model','CPE/PBX Model Software Re','Config: Incoming Call Id','Config: Digits Sent Cust','Config: Connect Line Id','TN Hunt Seq','911 Options','911: Main DN','911: Main DN Name','911: Type'};
        //,'Config: Digits Sent Cust'
		integer lblSize =  valueIds.size(); 
		 for(integer i = 1; i<=lblSize+1; i++)
        	{
            ftr_PSRService.serviceItemValueType custAttrItem = new ftr_PSRService.serviceItemValueType();
            System.debug('Map Error ' + reqAttrs.get('custAttr'+i.format()));
            Map<String,Object> attr = (Map<String,Object>)reqAttrs.get('custAttr'+i.format());
                System.debug('attrTesting ' + attr );
			if(attr != null){
                custAttrItem.label = String.valueOf(attr.get('label'));
                If (valueIds.contains(custAttrItem.label)) {
                        
						custAttrItem.label = String.valueOf(attr.get('label'));
                    	
                        if(custAttrItem.label == '911 Options')
                        {
                            if((String)attr.get('value') == 'PS/ALI')
                            {
                                isPsAli = true;
                            }
                        }
                    	if(isPsAli == true && (custAttrItem.label == '911: Main DN Name' || custAttrItem.label == '911: Type'))
                        {
                            custAttrItem.value = '';
                        }
                    	else if (custAttrItem.label == 'DID Info')
                        {
                            custAttrItem.value = DidInfoM6;
                        }
                        else
                        {
                            custAttrItem.value = (String)attr.get('value');  
                        }
                    		if(custAttrItem.value == 'Main Designated #')
                                custAttrItem.value = 'MAIN';
                    	if(String.IsNotBlank(custAttrItem.value)){
                            custAttrItem.activityCd ='N';
                        	servItemList.Add(custAttrItem);
                        }
					}
            	}
       		}
        return servItemList;
    }
}