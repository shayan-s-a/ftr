/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3 
**/
@isTest
public with sharing class ftr_GrpOrderStatusUpdateSubscriberTest {

    @isTest  
    static void executeTestEIA() {
        List<vlocity_cmt__OrchestrationItem__c> lst = ftr_TestDataFactory.getOrchestrationItems(1, new Map<String,String>{ 'M6 UNI PSR CFS' => 'ENT_ETH_DPI_CIRCUIT_BILLING' });
        insert lst;
        
        List<vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c 
                                                         WHERE Name = 'Wait for M6Orders Completion'];

        List<vlocity_cmt__OrchestrationItem__c> waitToStartItem = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c];

        List<PublishGrpOrderStatusUpdate__e> statusUpdateEventList = new List<PublishGrpOrderStatusUpdate__e>();
        String jsonAttribute = items[0].vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
        System.debug('jsonAttribute.in test.'+ jsonAttribute);
        String attrReferenceId = 'ATTR_FRLRefId';

        /*PublishGrpOrderStatusUpdate__e event = new PublishGrpOrderStatusUpdate__e();
        event.FRL_Id__c = items[0].vlocity_cmt__FulfilmentRequestLineId__c;
        event.FRL_Reference_Id__c = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, attrReferenceId);
        event.JSONAttribute__c = jsonAttribute;
        event.Object_Type__c = items[0].vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c;
        event.Orchestration_Item_Id__c = items[0].Id;
        event.Plan_Id__c = items[0].vlocity_cmt__OrchestrationPlanId__c;
        event.Product_Code__c = items[0].vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
        event.Status__c = 'Completed'; //default
        
        statusUpdateEventList.add(event);*/
        Map<String,Object> attrVals = new Map<String,Object>();
        attrVals.put('ATTR_IsSubmitOrderToDPI', 'False');
        attrVals.put('ATTR_HostUNIRefId', '1234');
        attrVals.put('ATTR_FRLRefId', '1234');
        attrVals.put('ATTR_RemoteUNIRefId', '1234');
        attrVals.put('BillingTelephoneNumber', '0000000000');
        attrVals.put('WorkingTelephoneNumber', '1234567891');
        
        vlocity_cmt__FulfilmentRequestLine__c flr = [SELECT Id, vlocity_cmt__JSONAttribute__c FROM vlocity_cmt__FulfilmentRequestLine__c WHERE Id=:items[0].vlocity_cmt__FulfilmentRequestLineId__c];
        flr.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(flr.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
        update flr;
        
        PublishGrpOrderStatusUpdate__e event = new PublishGrpOrderStatusUpdate__e();
        event.FRL_Id__c = items[0].vlocity_cmt__FulfilmentRequestLineId__c;
        event.FRL_Reference_Id__c = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, attrReferenceId);
        event.JSONAttribute__c =  flr.vlocity_cmt__JSONAttribute__c;
        event.Object_Type__c = items[0].vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c;
        event.Orchestration_Item_Id__c = items[0].Id;
        event.Plan_Id__c = items[0].vlocity_cmt__OrchestrationPlanId__c;
        event.Product_Code__c = items[0].vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
        event.Status__c = 'Completed'; //default
        
        statusUpdateEventList.add(event);



        // call the subscriber
        Map<String, Object> inputMap = new Map<String, Object>{
            'events' => statusUpdateEventList
        };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_GrpOrderStatusUpdateSubscriber subscriberUNI = new ftr_GrpOrderStatusUpdateSubscriber();
        
        test.startTest();
        //Boolean result = subscriberUNI.invokeMethod('execute', inputMap, outputMap, options);
        EventBus.publish(statusUpdateEventList);
        test.stopTest();
    }

   /* @isTest  
    static void executeTestEVPL() {
        List<vlocity_cmt__OrchestrationItem__c> lst = ftr_TestDataFactory.getOrchestrationItems(1, new Map<String,String>{ 'M6 UNI PSR CFS' => 'ENT_ETH_DPI_CIRCUIT_BILLING' });
        lst.addAll(ftr_TestDataFactory.getOrchestrationItems(1, new Map<String,String>{ 'M6 EVPL EVC PSR CFS' => 'ENT_ETH_DPI_CIRCUIT_BILLING' }));
        insert lst;

        List<vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c 
                                                         WHERE Name = 'Wait for M6Orders Completion'];

        List<vlocity_cmt__OrchestrationItem__c> waitToStartItem = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c];

        List<PublishGrpOrderStatusUpdate__e> statusUpdateEventList = new List<PublishGrpOrderStatusUpdate__e>();
        String jsonAttribute = items[0].vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
        System.debug('jsonAttribute.in test.'+ jsonAttribute);
        String attrReferenceId = 'ATTR_FRLRefId';

        PublishGrpOrderStatusUpdate__e event = new PublishGrpOrderStatusUpdate__e();
        event.FRL_Id__c = items[0].vlocity_cmt__FulfilmentRequestLineId__c;
        event.FRL_Reference_Id__c = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, attrReferenceId);
        event.JSONAttribute__c = jsonAttribute;
        event.Object_Type__c = items[0].vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c;
        event.Orchestration_Item_Id__c = items[0].Id;
        event.Plan_Id__c = items[0].vlocity_cmt__OrchestrationPlanId__c;
        event.Product_Code__c = items[0].vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
        event.Status__c = 'Completed'; //default
        statusUpdateEventList.add(event);



        // call the subscriber
        Map<String, Object> inputMap = new Map<String, Object>{
            'events' => statusUpdateEventList
        };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_GrpOrderStatusUpdateSubscriber subscriberUNI = new ftr_GrpOrderStatusUpdateSubscriber();
        
        test.startTest();
        Boolean result = subscriberUNI.invokeMethod('execute', inputMap, outputMap, options);
        test.stopTest();
    }*/
}