global without sharing class ftr_RetrieveCustomerFacilitiesInterface extends ftr_DPIBaseSystemInterface{

    global class ftr_RetrieveCustomerFacilitiesInterfaceException extends Exception {}

    global override String getOrchestrationTaskName() {
        System.debug('Task Name returned-->'+TaskName_RetrieveCustomerFacilities);
        return TaskName_RetrieveCustomerFacilities;
    }

    /**
     * This method is called from executeItem to create DPI RequestType 
     *
     * @param  url  base URL for the batch
     * @param  path path for the batch
     * @param  input payload to be used to construct 
     * @return DPI RequestType object to be sent
     */
    global override Object createDPIRequestType(String url, String path, Map<String, Object> input) {

      
        Map < String, Object > retrieveCustomerFacilities = (Map < String, Object > ) input.get('RetrieveCustomerFacilities');
        System.debug('retrieveCustomerFacilities -->'+retrieveCustomerFacilities);
        Map < String, Object > retrieveCustomerFacilitiesInput = (Map < String, Object > ) retrieveCustomerFacilities.get('RetrieveCustomerFacilitiesInput');      
        Map < String, Object > address = (Map < String, Object > )retrieveCustomerFacilitiesInput.get('address');
        ftr_addressBean addressObj = new ftr_addressBean();
        if(address!=null){
            addressObj.addressLine1 = (String) address.get('addressLine1');
            addressObj.cityName = (String) address.get('cityName');
            addressObj.state = (String) address.get('stateAbbreviation');
            addressObj.zipCode = (String) address.get('zipCode'); 
      //      addressObj.wcCilli = (String) address.get('wc_clli');
        }     
            
        return addressObj;

    }

    global override Map<String, Object> processDPIResponseType(String url, String path, Object respType) {
        Map<String,Object> outputMap = new Map<String,Object>();
        return outputMap;
    }
}