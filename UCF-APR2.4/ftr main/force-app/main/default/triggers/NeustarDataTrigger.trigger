trigger NeustarDataTrigger on Neustar_Data__c (before insert) {
    new NeustarDataTriggerHandler().run();
}