trigger PremisesTrigger on vlocity_cmt__Premises__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerDispatcher.Run(new premisesTriggerHandler());
}