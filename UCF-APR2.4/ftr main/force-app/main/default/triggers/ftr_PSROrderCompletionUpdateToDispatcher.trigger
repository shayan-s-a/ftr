trigger ftr_PSROrderCompletionUpdateToDispatcher on PSR_OrderCompletion_Update__e (after insert) {
    List<PSR_OrderCompletion_Update__e> statusUpdateEventList = new List<PSR_OrderCompletion_Update__e>();

    for (PSR_OrderCompletion_Update__e event : Trigger.New) {
        System.debug('the event trigger loop.' + event);
       
            statusUpdateEventList.add(event);
        
    }
    Map<String, Object> inputMap = new Map<String, Object>{
        'events' => statusUpdateEventList
    };
    Map<String, Object> outputMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    ftr_PSROrderCompletionUpdateSubscriber psrOrderCompSub= new ftr_PSROrderCompletionUpdateSubscriber();
    Boolean result = psrOrderCompSub.invokeMethod('execute', inputMap, outputMap, options);
    System.debug('result in dispatcher..'+ result);
}