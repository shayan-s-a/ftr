global class OrchPlanUpdateEventSubscriber implements vlocity_cmt.VlocityOpenInterface  {
    
    private static Map<string, string> queueIds;
    private static Integer numerOfQueues;
    static {
        List<String> qNames  = new List<String> { 'Queue 1', 'Queue 2', 'Queue 3', 'Queue 4' };
        queueIds = new Map<String, String>();
        numerOfQueues = qNames.size();        
        for (vlocity_cmt__OrchestrationQueue__c q : [select id,name from vlocity_cmt__OrchestrationQueue__c where name IN :qNames ]) {
            queueIds.put(q.name, q.Id);
        }

    } 

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter OrchPlanUpdateEventSubscriber.' + methodName);
        try {
            if (methodName == 'AssignQueues') {
                assignQueues(inputMap, outputMap);
            } else if (methodName == 'DecomposeAndCreatePlan') {
                String orderId = (String) inputMap.get('orderId');
                OrchPlanUpdateEventSubscriber.createPlanAsync(orderId);
            }
            return true;
        } catch (Exception ex) {
            System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            return false;
        } finally {
            System.debug('Exit OrchPlanUpdateEventSubscriber.' + methodName);
        }
    }

    public void assignQueues(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        String orderId = (String) inputMap.get('orderId');
        String planId = [SELECT Id FROM vlocity_cmt__OrchestrationPlan__c WHERE vlocity_cmt__OrderId__c =:orderId LIMIT 1].Id;
        List<vlocity_cmt__OrchestrationItem__c> oList = [select id, name, vlocity_cmt__OrchestrationQueueId__c from vlocity_cmt__OrchestrationItem__c where vlocity_cmt__OrchestrationPlanId__c =:planId order by createddate];

        Integer count = 0;
        for (vlocity_cmt__OrchestrationItem__c oi : oList) {
            Integer qNumber = math.mod(count, numerOfQueues) + 1;
            oi.vlocity_cmt__OrchestrationQueueId__c = queueIds.get('Queue '+ qNumber);
            
            // kick start the orch plan
            if (oi.name == 'Start Order') 
                oi.vlocity_cmt__State__c = 'Completed';
            
            System.debug(oi.Name + ' assigned to Queue ' + qNumber);
            count++;
        }
        update oList;
    }

    @Future
    public static void createPlanAsync(String orderId) {
        try {
            vlocity_cmt.SimpleDecompositionController.decomposeAndCreatePlan(orderId);
        } catch (Exception e) {
            // if the exception is "System.AsyncException: Database.executeBatch cannot be called from a batch start, batch execute, or future method"
            System.debug(e.getMessage());
            OrchPlanEvent__e event = new OrchPlanEvent__e(
                OrderId__c = orderId,
                MethodName__c = 'AssignQueues'
            );
            Database.SaveResult sr = EventBus.publish(event);
            if (sr.isSuccess()) {
                System.debug('OrchPlanEvent published.');
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error publishing OrchPlanEvent : ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }
    }
    
}
