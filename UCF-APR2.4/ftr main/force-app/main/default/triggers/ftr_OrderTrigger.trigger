trigger ftr_OrderTrigger on Order (before insert, after insert, before update, after update,before delete) {
    
    new ftr_OrderTriggerHandler().run();

}