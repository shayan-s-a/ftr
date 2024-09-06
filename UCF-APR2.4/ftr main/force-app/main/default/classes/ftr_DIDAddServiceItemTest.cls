@isTest
public with sharing class ftr_DIDAddServiceItemTest {
    
  @TestSetup
    static void makeData(){
         
         Integer numOfOrchItems = 1;
         Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI SIP PSR RESOURCE SPEC' => 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010',
                    'M6 SIP EVC  PSR RESOURCE SPEC' => 'SIP_EVC_PSR_RES_SPEC_0010'
    };
  
        List<vlocity_cmt__OrchestrationItem__c> orchItemsList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
        System.debug('**orchItemsList = ' + orchItemsList);
        insert orchItemsList;
        ftr_TestDataFactory.getAttributesWithCategory();
            
        
        
        // insert response DR
         vlocity_cmt__DRBundle__c  dtb= new vlocity_cmt__DRBundle__c ();
        dtb.Name = 'DRM6LoadAddServiceItemL1Response';
        dtb.vlocity_cmt__DRMapName__c='DRM6LoadAddServiceItemL1Response';
        dtb.vlocity_cmt__InterfaceObject__c='json';
        insert dtb;
    }

    @isTest
     static void addServiceItemTest(){
        System.debug('DIDAddServiceItem getting the orch item');

        Test.setMock(WebServiceMock.class, new ftr_M6AddServiceItemL1Mock());


        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c
                                                 WHERE Name = 'DIDAddServiceItem' LIMIT 1];
		System.Debug('orch item = ' + item);
		System.debug('DIDAddServiceItemTest Line 37');

        vlocity_cmt__DRBundle__c  dtb =[select Id from vlocity_cmt__DRBundle__c where Name='DRM6LoadAddServiceItemL1Response'];
		System.Debug('dtb = ' + dtb);
        item.vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c =dtb.Id;
        item.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c=dtb.Id;
        item.vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c =dtb.Id;
        update item;
        
        ftr_DIDM6AddServiceItemSystemInterface l1 = new ftr_DIDM6AddServiceItemSystemInterface();
        System.debug('Starting the test');
        Test.startTest();
        l1.executeItem('','',item);
        Test.stopTest();
    }

}