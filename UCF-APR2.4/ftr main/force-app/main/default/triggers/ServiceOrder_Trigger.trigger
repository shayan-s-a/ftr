trigger ServiceOrder_Trigger on Service_Order__c (after insert) {

    if(!System.isQueueable())
    	System.enqueueJob(new ServiceOrder_Queueable(trigger.new));
}