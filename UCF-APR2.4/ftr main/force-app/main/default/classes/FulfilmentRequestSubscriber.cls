global class FulfilmentRequestSubscriber {

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter FulfilmentRequestSubscriber.' + methodName);
        try {
            if (methodName == 'updateFRLs') {
                return updateFRLs(inputMap);
            }
            return true;
        } catch (Exception ex) {
            System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            return false;
        } finally {
            System.debug('Exit FulfilmentRequestSubscriber.' + methodName);
        }
    }

    public Boolean updateFRLs(Map<String, Object> input) {
        vlocity_cmt__FulfilmentRequestLine__c[] frlList = new vlocity_cmt__FulfilmentRequestLine__c[]{};
        for (FulfilmentRequestEvent__e event : (List<FulfilmentRequestEvent__e>) input.get('events')) {
            frlList.add(new vlocity_cmt__FulfilmentRequestLine__c(
                Id=event.FRL_Id__c,
                vlocity_cmt__JSONAttribute__c=event.JSONAttribute__c
            ));
        }
        if (frlList.size() > 0) update frlList;
        return true;
    }
}
