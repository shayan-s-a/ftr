/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : Danyal lashari
 * @version           : 2 
**/
@isTest
private class ftr_SIPM6AddServiceItemL2Test {

    @TestSetup
     static void makeData(){
        Integer numOfOrchItems = 1;
        Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI SIP PSR RESOURCE SPEC' => 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010',
                    'M6 SIP EVC  PSR RESOURCE SPEC' => 'SIP_EVC_PSR_RES_SPEC_0010'
        };

        List<vlocity_cmt__OrchestrationItem__c> orchItemsList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
        insert orchItemsList;
        System.debug('orchItemsList'+orchItemsList);
        ftr_TestDataFactory.getAttributesWithCategory();
    }
    @isTest
    static void SIPAddServiceItemL2Test(){
        Test.setMock(WebServiceMock.class, new ftr_M6SIPAddServiceItemL2Mock());

        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, 
                                                  vlocity_cmt__VlocityDataRaptorBundleId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c       
                                                  FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'SIPAddServiceItemL2' LIMIT 1];

        ftr_SIPM6AddServiceItemL2SystemInterface l2 = new ftr_SIPM6AddServiceItemL2SystemInterface();
        System.debug('itemTest'+item);
        Test.startTest();
        l2.executeItem('','',item);
        Test.stopTest();
    }
}