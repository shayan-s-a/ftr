/*  test */

@isTest
public with sharing class ftr_SIPM6AddServiceItemL1Test {
  

    @TestSetup
    static void makeData(){
         
         Integer numOfOrchItems = 1;
         Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI SIP PSR RESOURCE SPEC' => 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010',
                    'M6 SIP EVC  PSR RESOURCE SPEC' => 'SIP_EVC_PSR_RES_SPEC_0010'
    };
  
        List<vlocity_cmt__OrchestrationItem__c> orchItemsList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
        insert orchItemsList;
        
        ftr_TestDataFactory.getAttributesWithCategory();
            
        
        
        // *insert response DR
         vlocity_cmt__DRBundle__c  dtb= new vlocity_cmt__DRBundle__c ();
        dtb.Name = 'DRM6LoadAddServiceItemL1Response';
        dtb.vlocity_cmt__DRMapName__c='DRM6LoadAddServiceItemL1Response';
        dtb.vlocity_cmt__InterfaceObject__c='json';
        insert dtb;
    }

   
  /*  
   @isTest
  static void createPSRTestUNI(){

        vlocity_cmt__OrchestrationItem__c UNIitem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c 
                                                  WHERE Name = 'SIPCreateShellPSR' AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode ='SIP_TRUNKING_UNI_PSR_RES_SPEC_0010' LIMIT 1];

        Test.startTest();

        Test.setMock(WebServiceMock.class, new ftr_M6CreatePSRMock());
        ftr_SIPM6CreatePSRSystemInterface psr = new ftr_SIPM6CreatePSRSystemInterface();
        
        psr.executeItem('','',UNIitem);
        psr.updateDatabase();

        Test.stopTest();
        */
       /*  static void createPSRTestUNI(){

        vlocity_cmt__OrchestrationItem__c UNIitem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c WHERE Name = 'SIPCreateShellPSR' AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode = 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010' LIMIT 1];

        Test.startTest();

        Test.setMock(WebServiceMock.class, new ftr_M6CreatePSRMock());
        ftr_SIPM6AddServiceItemL1SystemInterface psr = new ftr_SIPM6AddServiceItemL1SystemInterface();
        psr.executeItem('','',UNIitem);
        psr.updateDatabase();

        Test.stopTest();
        
       
   
       
    } */

    @isTest
     static void addServiceItemTest(){
        Test.setMock(WebServiceMock.class, new ftr_M6AddServiceItemL1Mock());


        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c
                                                 WHERE Name = 'SIPAddServiceItemL1' LIMIT 1];
        
        vlocity_cmt__DRBundle__c  dtb =[select Id from vlocity_cmt__DRBundle__c where Name='DRM6LoadAddServiceItemL1Response'];
        item.vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c =dtb.Id;
        item.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c=dtb.Id;
        item.vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c =dtb.Id;
        update item;
        
        ftr_SIPM6AddServiceItemL1SystemInterface l1 = new ftr_SIPM6AddServiceItemL1SystemInterface();
        
        Test.startTest();
        l1.executeItem('','',item);
        Test.stopTest();
    }

    @isTest
    static void addChildServiceItemTest(){
        Test.setMock(WebServiceMock.class, new ftr_M6AddServiceItemL2Mock());

        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, 
                                                  vlocity_cmt__VlocityDataRaptorBundleId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c       
                                                  FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'SIPAddServiceItemL2' LIMIT 1];

                                                 // ftr_SIPM6AddServiceItemL2SystemInterface l2 = new ftr_SIPM6AddServiceItemL2SystemInterface();
                                                  ftr_SIPM6AddServiceItemL1SystemInterface l2 = new ftr_SIPM6AddServiceItemL1SystemInterface();
        System.debug('itemTest'+item);
        Test.startTest();
        l2.executeItem('','',item);
        Test.stopTest();
    }

    @isTest
    static void exceptionTest(){
        Test.setMock(WebServiceMock.class, new ftr_M6SubmitOrderMock());

        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, 
                                                  vlocity_cmt__VlocityDataRaptorBundleId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c       
                                                  FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'SIPSubmitPSR' LIMIT 1];

                                                  ftr_SIPM6SubmitOrderSystemInterface fo = new ftr_SIPM6SubmitOrderSystemInterface();
        System.debug('itemTest'+item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c);
        Test.startTest();
        try{
             fo.executeItem('','',null);
        }catch(Exception e){
            
        }
       
        Test.stopTest();
    }

    @isTest
    static void submitOrderTest(){
        Test.setMock(WebServiceMock.class, new ftr_M6SubmitOrderMock());

        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, 
                                                  vlocity_cmt__VlocityDataRaptorBundleId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c       
                                                  FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'SIPSubmitPSR' LIMIT 1];

                                                  ftr_SIPM6SubmitOrderSystemInterface fo = new ftr_SIPM6SubmitOrderSystemInterface();
        System.debug('itemTest'+item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c);
        Test.startTest();
        fo.executeItem('','',item);
        Test.stopTest();
    }

}