/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
private class ftr_M6SubmitOrderTest {

    @TestSetup
    static void makeData(){
        Integer numOfOrchItems = 1;
        Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001'
        };

        List<vlocity_cmt__OrchestrationItem__c> orchItemsList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
        insert orchItemsList;
        System.debug('orchItemsList'+orchItemsList);
        ftr_TestDataFactory.getAttributesWithCategory();    
    }
    @isTest
    static void submitOrderTest(){
        Test.setMock(WebServiceMock.class, new ftr_M6SubmitOrderMock());

        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, 
                                                  vlocity_cmt__VlocityDataRaptorBundleId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c       
                                                  FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'SubmitPSR' LIMIT 1];

        ftr_M6SubmitOrderSystemInterface fo = new ftr_M6SubmitOrderSystemInterface();
        System.debug('itemTest'+item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c);
        Test.startTest();
        fo.executeItem('','',item);
        Test.stopTest();
    }
}