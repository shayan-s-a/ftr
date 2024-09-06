trigger ftr_M6OrderStatusUpdateEventDispatcher on PSROrderUpdate__e (after insert) {  
    List<PSROrderUpdate__e> statusUpdateEventList = new List<PSROrderUpdate__e>();
    
    for (PSROrderUpdate__e event : Trigger.New) {
        System.debug('ftr_M6OrderStatusUpdateEventDispatcher:the event trigger loop.' + event);        
        statusUpdateEventList.add(event);    
        
    }
    System.debug('EventStatusList==='+statusUpdateEventList);
    Map<String, Object> inputMap = new Map<String, Object>{
        'events' => statusUpdateEventList
    };
    Map<String, Object> outputMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    ftr_M6OrderStatusUpdateSubscriber subscriber = new ftr_M6OrderStatusUpdateSubscriber();
    Boolean result = subscriber.invokeMethod('execute', inputMap, outputMap, options);
    System.debug('ftr_M6OrderStatusUpdateEventDispatcher:DispatcherResult==='+ result);
}