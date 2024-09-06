trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update, before delete, after insert, after update, after delete) {
    QuoteLineItemHandler handler = new QuoteLineItemHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    handler.triggerHandler(Trigger.isBefore, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
}