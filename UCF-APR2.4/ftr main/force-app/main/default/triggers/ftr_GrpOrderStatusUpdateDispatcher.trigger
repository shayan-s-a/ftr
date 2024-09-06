trigger ftr_GrpOrderStatusUpdateDispatcher on PublishGrpOrderStatusUpdate__e (after insert) {
    System.debug('PublishGrpOrderStatusUpdate__e .. ');
        List<PublishGrpOrderStatusUpdate__e > statusUpdateEventList = new List<PublishGrpOrderStatusUpdate__e >();
        // Iterate through each notification.
        for (PublishGrpOrderStatusUpdate__e event : Trigger.New) {
            System.debug('the event trigger loop.' + event);
            // Check if the given event has subscriber based off the subscription
            //if(event.Product_Code__c == 'ENT_ETH_UNI_PSR_001'){
                statusUpdateEventList.add(event);
            //}
        }
    
        // call the subscriber
        Map<String, Object> inputMap = new Map<String, Object>{
            'events' => statusUpdateEventList
        };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_GrpOrderStatusUpdateSubscriber grpOrderStatusUpdSub = new ftr_GrpOrderStatusUpdateSubscriber();
        Boolean result = grpOrderStatusUpdSub .invokeMethod('execute', inputMap, outputMap, options);
        System.debug('result in dispatcher..'+ result);
    
    }