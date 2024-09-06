trigger FieldAssignmentTrigger on FieldAssignment__c (after insert, after update, before insert, before update) {
    TriggerDispatcher.Run(new FieldAssignmentTriggerHandler());
}