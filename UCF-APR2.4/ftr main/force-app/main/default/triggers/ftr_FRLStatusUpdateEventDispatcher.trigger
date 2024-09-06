trigger ftr_FRLStatusUpdateEventDispatcher on FRL_Status_Update__e (after insert) {
    System.debug('ftr_FRLStatusUpdateEventDispatcher .. ');
    // Load "FRL Status Update Event Subscription" 
    List<FRL_Status_Update__e> statusUpdateEventList = new List<FRL_Status_Update__e>();
    // Iterate through each notification.
    for (FRL_Status_Update__e event : Trigger.New) {
        System.debug('the event trigger loop.' + event);
        // Check if the given event has subscriber based off the subscription
        if(event.Product_Code__c == 'ENT_ETH_UNI_PSR_001' || event.Product_Code__c =='SIP_TRUNKING_UNI_PSR_RES_SPEC_0010' ){
            statusUpdateEventList.add(event);
        }
    }

    // call the subscriber
    Map<String, Object> inputMap = new Map<String, Object>{
        'events' => statusUpdateEventList
    };
    Map<String, Object> outputMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    ftr_UniStatusUpdateSubscriber subscriberUNI = new ftr_UniStatusUpdateSubscriber();
    Boolean result = subscriberUNI.invokeMethod('execute', inputMap, outputMap, options);
    System.debug('result in dispatcher..'+ result);
}