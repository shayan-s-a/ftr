trigger ftr_UpdateFRLtoOLITrigger on vlocity_cmt__FulfilmentRequestLine__c (after insert, after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        ftr_UpdateFRLtoOLI.updateFRLtoOLI(Trigger.new);
    }
}