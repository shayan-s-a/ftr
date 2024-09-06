/**
* @description Service methods for Ring Central Quote related functionalities
* @version           : 1
*/  
global with sharing class ftr_RingCentralUtils implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        ftr_Logger.writeInfo('Enter ftr_RingCentralUtils.' + methodName);
        try {
            if (methodName == 'updateServiceAccountField') {                
                return updateServiceAccountField(inputMap, outputMap, options);
            }
            return true;
        } catch (Exception ex) { 
            // System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_RingCentralUtils.' + methodName);
        }
    }
    
    /*
* @description method to update the Service Account field on the Ring Central flow child products
*/
    public Boolean updateServiceAccountField(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        // Get the values from the Omniscript and update the child products of the licenses
        ID serviceAccountID;
        serviceAccountID  = (Id)inputMap.get('ServiceAccountId');
        String cartID;
        cartID= (String)inputMap.get('cartId');
        List<QuoteLineItem> qlisToCheck=new List<QuoteLineItem>();
        qlisToCheck = [select id, vlocity_cmt__ServiceAccountId__c from QuoteLineItem where quoteId =:cartID LIMIT 10000];
        List<QuoteLineItem> qlisToUpdate = new List<QuoteLineItem>();
        for (QuoteLineItem qi: qlisToCheck){
            if(qi.vlocity_cmt__ServiceAccountId__c != serviceAccountID){
                qi.vlocity_cmt__ServiceAccountId__c = serviceAccountID;
                qlisToUpdate.add(qi);
            }
        }        
        update qlisToUpdate;
        return true;
    }
}