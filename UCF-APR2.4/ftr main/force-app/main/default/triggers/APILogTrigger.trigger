trigger APILogTrigger on API_Log__c (after insert) {
    new APILogTriggerHandler().run();
}