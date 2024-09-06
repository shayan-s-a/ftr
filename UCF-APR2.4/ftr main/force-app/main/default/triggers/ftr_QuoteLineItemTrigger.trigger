trigger ftr_QuoteLineItemTrigger on QuoteLineItem (before insert, after insert, before update, after update, before delete, after delete) {
    new ftr_QuoteLineItemTriggerHandler().run();
}