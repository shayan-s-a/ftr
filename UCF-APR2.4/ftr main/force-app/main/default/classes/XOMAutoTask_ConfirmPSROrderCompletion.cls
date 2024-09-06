global with sharing class XOMAutoTask_ConfirmPSROrderCompletion implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask{
    public final static String ATTR_REF_ID = 'ATTR_FRLRefId';
    public final static String ATTR_GRP_ORD_TRANSACTION_COUNT = 'GroupOrderTransactionCount';
    public final static String ATTR_CORRELATIONID = 'CorrelationId';
    public final static String STATUS = 'Completed';
    global  void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items) {
        System.debug('Entering XOMAutoTask_ConfirmPSROrderCompletion executeBatch-->');
        List<PSR_OrderCompletion_Update__e> statusUpdateEventList = new List<PSR_OrderCompletion_Update__e>();
        Set<Id> itemIds = new Set<Id>();
        if(items.size() > 0) {
            System.debug('Orch Items List -->'+JSON.serialize(items));
            for(vlocity_cmt__OrchestrationItem__c item : items) {
                itemIds.add(item.Id);
                System.debug('Orch ItemId-->'+item.id);
            }
            items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
            FROM vlocity_cmt__OrchestrationItem__c where Id IN: itemIds];

            for (vlocity_cmt__OrchestrationItem__c item : items) {
                String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                String attrReferenceId = ATTR_REF_ID;//'Fulfilment Request Line Reference Id';
                PSR_OrderCompletion_Update__e event = new PSR_OrderCompletion_Update__e();
                event.FRL_Id__c = item.vlocity_cmt__FulfilmentRequestLineId__c;
                event.FRL_Reference_Id__c = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, attrReferenceId);
               // event.GroupOrderTransactionCount__c	= Integer.valueof(ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_GRP_ORD_TRANSACTION_COUNT));
                //event.CorrelationId__c=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_CORRELATIONID);
                event.JSONAttribute__c = jsonAttribute;
                event.Object_Type__c = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c;
                event.Orchestration_Item__c = item.Id;
                event.Plan_Id__c = item.vlocity_cmt__OrchestrationPlanId__c;
                event.Product_Code__c = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
                event.Status__c = STATUS; //default
                statusUpdateEventList.add(event);
            }
System.debug('listevents--'+statusUpdateEventList);
        }

        List<Database.SaveResult> results = EventBus.publish(statusUpdateEventList);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event..'+ sr.getId());
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
    }
}