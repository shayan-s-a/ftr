trigger FulfilmentRequestEventDispatcher on FulfilmentRequestEvent__e (after insert) {

    Map<String, FulfilmentRequestEvent__e[]> eventMap = new Map<String, FulfilmentRequestEvent__e[]>();
    for (FulfilmentRequestEvent__e e : Trigger.new) {
        if (eventMap.containsKey(e.MethodName__c)) {
            eventMap.get(e.MethodName__c).add(e);
        } else {
            eventMap.put(e.MethodName__c, new FulfilmentRequestEvent__e[]{ e });
        }
    }

    // updateFRLs
    if (eventMap.get('updateFRLs') != null) {
        Map<String, Object> inputMap = new Map<String, Object>{
            'events' => eventMap.get('updateFRLs')
        };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        FulfilmentRequestSubscriber subscriber = new FulfilmentRequestSubscriber();
        subscriber.invokeMethod('updateFRLs', inputMap, outputMap, options);
    }
}