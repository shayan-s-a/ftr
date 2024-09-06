/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3 
**/
@isTest
public with sharing class ftr_UniStatusUpdateSubscriberTest {
     @isTest      
     static void testIncrement() {
        Test.startTest();
        ftr_UniStatusUpdateSubscriber.justIncrement();
        Test.stopTest();
 }

    @isTest  
    static void executeTestEIA() {
 
        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001',
            'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
        };
        List<vlocity_cmt__OrchestrationItem__c> lst = ftr_TestDataFactory.getOrchestrationItems(1, prodNameCodeMap);
        insert lst;
        
        List<vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c 
                                                         WHERE Name = 'Publish Status Update'];

        List<vlocity_cmt__OrchestrationItem__c> waitToStartItem = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c];

        List<FRL_Status_Update__e> statusUpdateEventList = new List<FRL_Status_Update__e>();
        String jsonAttribute = items[0].vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
        System.debug('jsonAttribute.in test.'+ jsonAttribute);
        String attrReferenceId = 'ATTR_FRLRefId';

        FRL_Status_Update__e event = new FRL_Status_Update__e();
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
        ftr_UniStatusUpdateSubscriber subscriberUNI = new ftr_UniStatusUpdateSubscriber();
        
        test.startTest();
        Boolean result = subscriberUNI.invokeMethod('execute', inputMap, outputMap, options);
        test.stopTest();
    }

    @isTest  
    static void executeTestEVPL() {
        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001',
            'M6 EVPL EVC PSR CFS' => 'ENT_ETH_EVPL_EVC_PSR_001'
        };
        List<vlocity_cmt__OrchestrationItem__c> lst =  ftr_TestDataFactory.getOrchestrationItems(1, prodNameCodeMap);
        insert lst;

        List<vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c 
                                                         WHERE Name = 'Publish Status Update'];

        List<vlocity_cmt__OrchestrationItem__c> waitToStartItem = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c];

        List<FRL_Status_Update__e> statusUpdateEventList = new List<FRL_Status_Update__e>();
        String jsonAttribute = items[0].vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
        System.debug('jsonAttribute.in test.'+ jsonAttribute);
        String attrReferenceId = 'ATTR_FRLRefId';

        FRL_Status_Update__e event = new FRL_Status_Update__e();
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
        ftr_UniStatusUpdateSubscriber subscriberUNI = new ftr_UniStatusUpdateSubscriber();
        
        test.startTest();
        Boolean result = subscriberUNI.invokeMethod('execute', inputMap, outputMap, options);
        test.stopTest();
    }
 
 
}