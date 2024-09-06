public class APILogTriggerHandler extends ftr_TriggerHandler {

    public override void afterInsert() {
        TaskCreationService.createTasks((Map<Id, API_Log__c>) Trigger.newMap);
    } 

}