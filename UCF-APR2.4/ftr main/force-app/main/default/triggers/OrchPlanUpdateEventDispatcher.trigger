trigger OrchPlanUpdateEventDispatcher on OrchPlanEvent__e (after insert) {
    Map<String, String> orderIds = new Map<String, String>();
    OrchPlanUpdateEventSubscriber subscriber = new OrchPlanUpdateEventSubscriber();

    for (OrchPlanEvent__e event : Trigger.new) {
        Map<String, Object> inputMap = new Map<String, Object>{
            'orderId' => event.OrderId__c
        };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        subscriber.invokeMethod(event.MethodName__c, inputMap, outputMap, options);
    }
    
}