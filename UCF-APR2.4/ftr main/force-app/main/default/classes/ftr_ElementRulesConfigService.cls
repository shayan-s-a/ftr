global class ftr_ElementRulesConfigService implements vlocity_cmt.VlocityOpenInterface {

    /*
     * @description entry point of remoting method 
     */
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter ftr_ElementRulesConfigService.' + methodName);
        try {
            if (methodName == 'getCCSDataByHandoff') {                
                return getCCSDataByHandoff(inputMap, outputMap, options);
            }
            return true;
        } catch (Exception ex) { 
            outputMap.put('error', ex.getMessage());
            ftr_Logger.write(ex);
            throw ex;
        } finally {
            System.debug('Exit ftr_ElementRulesConfigService.' + methodName);
        }
    }

    public Boolean getCCSDataByHandoff(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        Map<String, Object> result;
        String handOff = (String)inputMap.get('PBXHandOff');
        Integer ccs = (Integer)inputMap.get('ccs');
        if (handOff == null) {
            outputMap.put('error', 'PBXHandOff not found.');
            return false;
        } else if (ccs == null) {
            outputMap.put('error', 'ccs not found.');
            return false;
        }
        for (ftr_SIP_ElementRulesConfig__c config : [SELECT CCS__c, DID_Number__c, HandOff__c, LD_Overage_Rate__c, LongDistance_BOT__c, Router_Model__c, Speed__c 
                                                      FROM ftr_SIP_ElementRulesConfig__c WHERE HandOff__c = : handOff]) {
            String[] ccsRange = config.CCS__c.split('-');
            Integer x = Integer.valueOf(ccsRange[0]);
            Integer y = Integer.valueOf(ccsRange[1]);
            if (ccs >= x && ccs <= y) {
                outputMap.put('result', config);
                break;
            }
        }
        
        return true;
    }
}
