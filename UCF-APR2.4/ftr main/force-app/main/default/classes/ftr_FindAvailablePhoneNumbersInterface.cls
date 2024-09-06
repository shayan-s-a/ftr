global without sharing class ftr_FindAvailablePhoneNumbersInterface extends ftr_DPIBaseSystemInterface{

    global class ftr_FindAvailablePhoneNumbersInterfaceException extends Exception {}

    global override String getOrchestrationTaskName() {
        System.debug('Task Name returned-->'+TaskName_findAvailableTelephoneNumbers);
        return TaskName_findAvailableTelephoneNumbers;
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

        //FindAvailableTelephoneNumbers:findAvailableTelephoneNumbersInput:exchangeFilter:env
        //FindAvailableTelephoneNumbers:findAvailableTelephoneNumbersInput:exchangeFilter:stateAbbreviation
        Map < String, Object > output = new Map < String, Object >();
        Map < String, Object > findAvailablePhoneNumbers = (Map < String, Object > ) input.get('FindAvailableTelephoneNumbers');
        System.debug('findAvailablePhoneNumbers -->'+findAvailablePhoneNumbers);
        Map < String, Object > findAvailableTelephoneNumbersInput = (Map < String, Object > ) findAvailablePhoneNumbers.get('findAvailableTelephoneNumbersInput');      
        Map < String, Object > exchangeFilter = (Map < String, Object > )findAvailableTelephoneNumbersInput.get('exchangeFilter');
        String env = (String) exchangeFilter.get('env');
        String stateAbbreviation= (String) exchangeFilter.get('stateAbbreviation');
        String maxTnNumbers= (String) exchangeFilter.get('maxTnNumbers');
        String itemSequence= (String) exchangeFilter.get('itemSequence');
        String wc_cilli = (String) exchangeFilter.get('wc_clli');
        String orderId = (String) exchangeFilter.get('Order_Id');
        String order_no = (String) exchangeFilter.get('order_no');
        String npaNxx   = (String) exchangeFilter.get('npanxx');
        System.debug('findAvailablePhoneNumbers:env -->'+env);
        System.debug('findAvailablePhoneNumbers:stateAbbreviation -->'+stateAbbreviation);
        System.debug('findAvailablePhoneNumbers:itemSequence -->'+itemSequence);
        System.debug('findAvailablePhoneNumbers:maxTnNumbers -->'+maxTnNumbers);
        System.debug('findAvailablePhoneNumbers:wc_cilli -->'+wc_cilli);
         System.debug('findAvailablePhoneNumbers:orderId -->'+orderId);
         System.debug('findAvailablePhoneNumbers:order_no -->'+order_no);
        System.debug('findAvailablePhoneNumbers:npaNxx -->'+npaNxx);
        //List<String> npaNxxList = ftr_ResourceManagementService.getNpaNxxList(env, stateAbbreviation);        
        //System.debug('findAvailablePhoneNumbers:npaNxxList -->'+npaNxxList);
        //output.put('npaNxxList', npaNxxList);
        output.put('maxTnNumbers', maxTnNumbers);
        output.put('itemSequence', itemSequence);
        output.put('state', stateAbbreviation);
        output.put('env', env);
        output.put('wc_cilli', wc_cilli);
        output.put('orderId', orderId);
        output.put('order_no', order_no);
         output.put('npaNxx', npaNxx);
        System.debug('outputfromDPI'+output);
        //return npaNxxList;
        return output;

    }

    global override Map<String, Object> processDPIResponseType(String url, String path, Object respType) {
        Map<String,Object> outputMap = new Map<String,Object>();
        return outputMap;
    }
}