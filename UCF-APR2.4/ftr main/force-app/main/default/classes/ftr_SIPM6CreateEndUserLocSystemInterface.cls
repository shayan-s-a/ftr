/**
* @description webservice callout to Create End User Location Request interface
* @version 1
*/ 


global without sharing class ftr_SIPM6CreateEndUserLocSystemInterface extends ftr_SIPM6BaseSystemInterface  {
    
    //public static final String TN_SWITCHCLLI = 'SSVLCAXFDS0';
    
    global class ftr_SIPM6CreateEndUserLocSystemInterfaceException extends Exception {}
    
    ftr_PSRService.PSRServicePort port;
    ftr_PSRService.createServiceLocationRequestType request;
    
    public Set<String> DIDLocationIds = new Set<String>();
    
    
    global override String getOrchestrationTaskName(){
        
        return TaskName_CreateEndUserLocation;
    }
    
    /**
     * This method is called from executeItem to create M6 RequestType 
     *
     * @param  url  base URL for the batch
     * @param  path path for the batch
     * @param  input payload to be used to construct 
     * @return         M6 RequestType object to be sent
     */
    
  /****  
  global override Object createM6RequestType(String url, String path, Map<String, Object> input) {
       
        
        Map<String, Object> createServiceLocationRequestMap = (Map<String, Object>)input.get('createServiceLocation');
         
        Map<String, Object> requestMap = (Map<String, Object>)createServiceLocationRequestMap.get('createServiceLocationRequest');
         
        Map<String, Object> priLocMap = (Map<String, Object>)requestMap.get('priloc');
         
        List<Map<String, Object>> endUserPriLocationMap = (List<Map<String, Object>>)priLocMap.get('endUserLocation');
       
          

         String documentNumber = String.valueOf(requestMap.get('documentNumber'));
         
         this.request = new ftr_PSRService.createServiceLocationRequestType();
         this.request.documentNumber = documentNumber;
        
         if(!endUserPriLocationMap.isEmpty()){
             
           for(Integer i = 0; i < endUserPriLocationMap.size(); i++){

               
                DIDLocationIds.add(String.valueOf(endUserPriLocationMap[i].get('DIDLocationId')));
                this.request.endUserLocationName =  String.valueOf(endUserPriLocationMap[i].get('LocationName')).toUpperCase(); 
            
                String streetName = String.valueOf(endUserPriLocationMap[i].get('StreetName'));
       
                this.request.address = new ftr_PSRService.addressType();
                this.request.address.houseNumber = streetName.substring(0,streetName.indexOf(' '));//'191002'; //vlocity_cmt__Premises__c.vlocity_cmt__StreetAddress__c
                this.request.address.streetName = streetName.substringAfter(' ').toUpperCase();          
                this.request.address.city = String.valueOf(endUserPriLocationMap[i].get('City')).toUpperCase();
                this.request.address.state = String.valueOf(endUserPriLocationMap[i].get('State')).toUpperCase();//'NY';
                this.request.address.postalCode =  String.valueOf(endUserPriLocationMap[i].get('postalCode'));//'14607';

           }
            
           return (Object)this.request;        
            
         }
        // for happy Path
       
        Map<String, Object> createServiceLocationRequestMap = (Map<String, Object>)input.get('createServiceLocation');
        Map<String, Object> requestMap = (Map<String, Object>)createServiceLocationRequestMap.get('createServiceLocationRequest');
        Map<String, Object> priLocMap = (Map<String, Object>)requestMap.get('priloc');
        Map<String, Object> endUserPriLocationMap = (Map<String, Object>)priLocMap.get('endUserLocation');
        String documentNumber = String.valueOf(requestMap.get('documentNumber'));
    
        this.request = new ftr_PSRService.createServiceLocationRequestType();
        this.request.documentNumber = documentNumber;  
        this.request.endUserLocationName = String.valueOf(endUserPriLocationMap.get('LocationName')).toUpperCase(); 
          
         String streetName = String.valueOf(endUserPriLocationMap.get('StreetName'));
       
        this.request.address = new ftr_PSRService.addressType();
        this.request.address.houseNumber = streetName.substring(0,streetName.indexOf(' '));//'191002'; //vlocity_cmt__Premises__c.vlocity_cmt__StreetAddress__c
        this.request.address.streetName = streetName.substringAfter(' ').toUpperCase();          
        this.request.address.city = String.valueOf(endUserPriLocationMap.get('City')).toUpperCase();
        this.request.address.state = String.valueOf(endUserPriLocationMap.get('State')).toUpperCase();//'NY';
        this.request.address.postalCode = String.valueOf(endUserPriLocationMap.get('postalCode'));//'14607';
   
        
       
     return null;
    }

    */
    global Object createM6RequestTypeNew(String url, String path, String LocationName, String documentNumber, String StreetName, String City,  String State, String postalCode,String TN_SWITCHCLLI){

         
        this.request = new ftr_PSRService.createServiceLocationRequestType();
        this.request.documentNumber = documentNumber;
        this.request.tnSwitchCLLI =TN_SWITCHCLLI; 
        this.request.endUserLocationName =  LocationName.toUpperCase(); 
            
        //String streetName = StreetName;
        System.debug('### StreetName' + StreetName);
        this.request.address = new ftr_PSRService.addressType();
        this.request.address.houseNumber = StreetName.substring(0,StreetName.indexOf(' '));//'191002'; //vlocity_cmt__Premises__c.vlocity_cmt__StreetAddress__c
        this.request.address.streetName = StreetName.substringAfter(' ').toUpperCase();          
        this.request.address.city = City.toUpperCase();
        this.request.address.state = State.toUpperCase();
        this.request.address.postalCode =  postalCode;

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

     /* 
    global override Map<String, Object> processM6ResponseType(String url, String path, Object respType) {
        ftr_PSRService.createServiceLocationResponseValueType response = (ftr_PSRService.createServiceLocationResponseValueType)respType;
        Map<String,Object> respMap = new Map<String,Object>();
        
        if(response.statusMessage.get(0).code != '0'){
            throw new ftr_SIPM6CreateEndUserLocSystemInterfaceException(response.statusMessage.get(0).message);
        }
         
        respMap.put('locationId',String.valueOf(response.createServiceLocationResult.locationId));
        respMap.put('addressId',String.valueOf(response.createServiceLocationResult.addressId));
        
        
 
        return respMap;
        
    } */

    global  Map<String, Object> processM6ResponseTypeNew(String url, String path, Object respType,String DIDLocationId) {
        
        
        ftr_PSRService.createServiceLocationResponseValueType response = (ftr_PSRService.createServiceLocationResponseValueType)respType;
        Map<String,Object> respMap = new Map<String,Object>();
        
         
        if(response.statusMessage.get(0).code != '0'){
            throw new ftr_SIPM6CreateEndUserLocSystemInterfaceException(response.statusMessage.get(0).message);
        }
         
        respMap.put('locationId',String.valueOf(response.createServiceLocationResult.locationId));
        respMap.put('addressId',String.valueOf(response.createServiceLocationResult.addressId));
        respMap.put('DIDLocationId',DIDLocationId);
 
        return respMap;
        
    }
   
     
}