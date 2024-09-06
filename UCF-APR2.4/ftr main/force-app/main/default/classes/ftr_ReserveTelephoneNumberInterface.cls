global without sharing class ftr_ReserveTelephoneNumberInterface extends ftr_DPIBaseSystemInterface{

    global class ftr_ReserveTelephoneNumberInterfaceException extends Exception {}

    global override String getOrchestrationTaskName() {
        System.debug('Task Name returned-->'+TaskName_ReserveTelephoneNumber);
        return TaskName_ReserveTelephoneNumber;
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

        //ReserveTelephoneNumber:reserveTelephoneNumberInput:telephoneNumber
        Map < String, Object > ReserveTelephoneNumber = (Map < String, Object > ) input.get('ReserveTelephoneNumber');
        System.debug('ReserveTelephoneNumber -->'+ReserveTelephoneNumber);
        Map < String, Object > reserveTelephoneNumberInput = (Map < String, Object > ) ReserveTelephoneNumber.get('reserveTelephoneNumberInput');      
        String telephoneNumber = (String) reserveTelephoneNumberInput.get('telephoneNumber');
        String stateAbbreviation= (String) reserveTelephoneNumberInput.get('stateAbbreviation');
        String maxTnNumbers= (String) reserveTelephoneNumberInput.get('maxTnNumbers');
        String itemSequence= (String) reserveTelephoneNumberInput.get('itemSequence');
        String environment = (String) reserveTelephoneNumberInput.get('environment');


        System.debug('ReserveTelephoneNumber:telephoneNumber -->'+telephoneNumber);      
        Map<String,Object> reserveTnMap = new Map<String,Object>();
                reserveTnMap.put('env', environment);
                reserveTnMap.put('tn', telephoneNumber); 
                reserveTnMap.put('maxTnNumbers', maxTnNumbers);
                reserveTnMap.put('itemSequence', itemSequence);
                reserveTnMap.put('state', stateAbbreviation);
                        
        System.debug('ReserveTelephoneNumber:reserveTnMap -->'+reserveTnMap);
        return reserveTnMap;

    }

    global override Map<String, Object> processDPIResponseType(String url, String path, Object respType) {
        Map<String,Object> outputMap = new Map<String,Object>();
        return outputMap;
    }
}