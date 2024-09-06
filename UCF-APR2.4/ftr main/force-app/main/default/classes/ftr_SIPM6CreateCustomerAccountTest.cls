@isTest
private with sharing class ftr_SIPM6CreateCustomerAccountTest {
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
    static void SIPM6CreateCustomerAccountTest(){
        Test.setMock(WebServiceMock.class, new ftr_SIPM6CreateCustomerAccountMock());
        //System.debug('Test');
        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, 
                                                  vlocity_cmt__VlocityDataRaptorBundleId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c       
                                                  FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'SIPCheckM6Account' LIMIT 1];

        ftr_SIPM6CreateCustomerAccountInterface l2 = new ftr_SIPM6CreateCustomerAccountInterface();
        System.debug('itemTest'+item);
        Test.startTest();
        l2.executeItem('','',item);
        Test.stopTest();
    }
}