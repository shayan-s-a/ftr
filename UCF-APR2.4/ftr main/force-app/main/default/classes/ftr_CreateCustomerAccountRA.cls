/**
* 
* @description Remote Action class for invoking CreateCustomerAccount webservice call
*/ 
global with sharing class ftr_CreateCustomerAccountRA implements vlocity_cmt.VlocityOpenInterface {
    
    //Error messages //TODO: to be put in Custom Label
    //private static final String ERR_NULL_INPUT = 'Null Input Parameters';
    private static final String ERR_NULL_INPUT = 'Incorrect Service Address on Account';
    
    /*
    * @description entry point of remoting method 
    */
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter ftr_CreateCustomerAccountRA.' + methodName);
        try {
            if (methodName == 'createCustomerAccount') {
                return createCustomerAccount(methodName, inputMap, outputMap);
            }
            return true;
        } catch (Exception ex) {
            System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            return false;
        } finally {
            System.debug('Exit ftr_CreateCustomerAccountRA.' + methodName);
        }
    }


     /*
    * @description callout to createCustomerAccount webservice 
    * @param methodname, inputmap, outputmap
    */
    public Boolean createCustomerAccount(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap) {
        System.debug('method name..'+ methodName+ inputMap);

        if((String.valueOf(inputMap.get('QuoteType'))) == 'Install')
        {
        if(String.isBlank(String.valueOf(inputMap.get('AccountId'))) || String.isBlank(String.valueOf(inputMap.get('AccountName'))) ||
            String.isBlank(String.valueOf(inputMap.get('ShippingStreet'))) || String.isBlank(String.valueOf(inputMap.get('ShippingCity'))) ||
            String.isBlank(String.valueOf(inputMap.get('ShippingStateCode'))) ||String.isBlank(String.valueOf(inputMap.get('ShippingPostalCode')))) {
            outputMap.put('error', methodName+': '+ERR_NULL_INPUT);
            return false;
        }

        String custAcctNbr = '';

        try {
            ftr_CreateCustomerAccountWS createCustAcc = new ftr_CreateCustomerAccountWS();
            custAcctNbr = createCustAcc.createCustomerAccount(inputMap);
            outputMap.put('custAcctNbr', custAcctNbr);
        } catch(Exception e) {
            System.debug('e.getMessage()..'+ e.getMessage());
            outputMap.put('error', methodName+': '+ e.getMessage());
            outputMap.put('CreateCustomerAccountResponse', 'Failure');
            return false;
        }
        } else {
            String custAcctNbr = '';
            custAcctNbr = (String.valueOf(inputMap.get('AccountId')));
            outputMap.put('custAcctNbr', custAcctNbr);
        }
        outputMap.put('CreateCustomerAccountResponse', 'Success');
        
        return true;
    }
 
}