global with sharing class ftr_GuidedQuoteOSController implements vlocity_cmt.VlocityOpenInterface  {
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        ftr_Logger.writeInfo('Enter ValidatePremise.' + methodName);
        try {
            /*if (methodName == 'checkIfPremiseExists') {                
                checkIfPremiseExists(inputMap, outputMap, options);
            }*/
            if (methodName == 'getPremises') {                
                getPremises(inputMap, outputMap, options);
            } else if  (methodName == 'retrieveCustomerFacilities'){
                retrieveCustomerFacilities(inputMap, outputMap, options);
            }
            return true;
        } catch (Exception ex) { 
            // System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            outputMap.put('error', ex.getMessage());
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ValidatePremise.' + methodName);
        }
    }
    /*public void checkIfPremiseExists (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
        Map<String,object> qualifiedAddress = (Map<String,object>)inputMap.get('address');   
        String street = (String)qualifiedAddress.get('Address');
        String city = (String)qualifiedAddress.get('City');
        String state = (String)qualifiedAddress.get('State');   
        String zipCode = (String)qualifiedAddress.get('ZipCode');
        //String country = (String)QualifiedAddress.get('US');
     
        //Concatenate address as seen in utility and pass it into convert string to hash.
        String inputPremAddress;
        if(!String.isBlank(street)){
            inputPremAddress = street.toLowerCase();
        }
        if(!String.isBlank(city)){
            inputPremAddress += ', ' + city.toLowerCase();
        }
        if(!String.isBlank(state)){
            inputPremAddress += ', ' + state.toLowerCase();
        }
        if(!String.isBlank(zipCode)){
            inputPremAddress += ', ' + zipCode;
        }
        if(!String.isBlank(country)){
            inputPremAddress += ', ' + country.toLowerCase();
        }
        
        //String hashKey = PremisesUtility.convertStringToSha256Hash(inputPremAddress);
		vlocity_cmt__Premises__c Prem = premisesUtility.getPremise(street, city, state, zipCode, '', '');
        
        if (Prem != null)
        outputMap.put('premisesExists', True);          
        else
        outputMap.put('premisesExists', False);  

    }*/
    
    public void getPremises(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
        if (inputMap.get('address') == null) {
            return;
        }
        Map<String,object> qualifiedAddress = (Map<String,object>)inputMap.get('address');   
        String street = (String)qualifiedAddress.get('Address');
        String city = (String)qualifiedAddress.get('City');
        String state = (String)qualifiedAddress.get('State');   
        String zipCode = (String)qualifiedAddress.get('ZipCode');
		vlocity_cmt__Premises__c prem = new vlocity_cmt__Premises__c();
        prem = premisesUtility.getPremise(street, city, state, zipCode, '', '');
        outputMap.put('premises', prem);   
        outputMap.put('premisesId', prem.Id);       
         
    }

    @Future(callout=true)
    public static void retrieveCustomerFacilities(String premisesId) {
        vlocity_cmt__Premises__c premises = new vlocity_cmt__Premises__c(); 
        premises = [SELECT Id, vlocity_cmt__StreetAddress__c, vlocity_cmt__City__c, vlocity_cmt__State__c, 
                    vlocity_cmt__PostalCode__c, vlocity_cmt__Country__c, vlocity_cmt__UnitNumber__c, ftr_DPI_Environment__c,
                    ftr_DPI_Wirecenter__c, ftr_DPI_Exchange__c, ftr_DPI_ControlNumber__c
                    FROM vlocity_cmt__Premises__c 
                    WHERE Id =: premisesId];
        if (premises != null || Test.isRunningTest()) {
            ftr_addressBean addressBean = new ftr_addressBean();
            Map<String, String> customerFacilityResponseMap = new Map<String, String>();
            addressBean.addressLine1 = (String) premises.vlocity_cmt__StreetAddress__c;
            addressBean.cityName = (String) premises.vlocity_cmt__City__c;
            addressBean.state = (String) premises.vlocity_cmt__State__c;
            addressBean.zipCode = (String) premises.vlocity_cmt__PostalCode__c;
            
            if (Test.isRunningTest()) {
                customerFacilityResponseMap = new Map<String, String> {
                    'env' => 'ENV',
                    'wirecenter' => '123ABC',
                    'cityabbreviation' => 'CA',
                    'controlNumber' => '123'
                };
            } else {
                customerFacilityResponseMap = ftr_DPIResourceManagmentSystemInterface.retreiveCustomerFacility(addressBean);
            }
            
            if (customerFacilityResponseMap != null && !customerFacilityResponseMap.isEmpty()) {
                if (customerFacilityResponseMap.get('env') != null) {
                    premises.ftr_DPI_Environment__c = customerFacilityResponseMap.get('env');
                }
                if (customerFacilityResponseMap.get('wirecenter') != null) {
                    premises.ftr_DPI_Wirecenter__c = customerFacilityResponseMap.get('wirecenter');
                }
                if (customerFacilityResponseMap.get('cityabbreviation') != null) {
                    premises.ftr_DPI_Exchange__c = customerFacilityResponseMap.get('cityabbreviation');
                }
                if (customerFacilityResponseMap.get('controlNumber') != null) {
                    premises.ftr_DPI_ControlNumber__c = customerFacilityResponseMap.get('controlNumber');
                }
                update premises;
            }
        }
    }

    public void retrieveCustomerFacilities(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
        getPremises(inputMap, outputMap, options);
        Id premId = (Id) outputMap.get('premisesId');
        ftr_GuidedQuoteOSController.retrieveCustomerFacilities(premId);
        outputMap.put('message', 'Invoked RetrieveCustomerFacilities Callout');
    }
}