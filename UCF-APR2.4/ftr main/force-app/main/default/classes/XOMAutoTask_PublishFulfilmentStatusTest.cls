/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public with sharing class XOMAutoTask_PublishFulfilmentStatusTest {

    @TestSetup
    static void makeData(){
        Integer numOfOrchItems = 1;
        Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001'
        };

        List<vlocity_cmt__OrchestrationItem__c> orchItemsList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
        insert orchItemsList;
    }

    @isTest  
    static void executeBatchTest() {
        
        List<vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c];

        XOMAutoTask_PublishFulfilmentStatus xom = new XOMAutoTask_PublishFulfilmentStatus();

        test.startTest();
        xom.executeBatch(items);
        test.stopTest();
        

    }
}