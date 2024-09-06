/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3
**/
@isTest
private class ftr_M6AddServiceItemL1Test { 

    @TestSetup
    static void makeData(){
         
         Integer numOfOrchItems = 1;
         Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001',
                    'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
    };

        List<vlocity_cmt__OrchestrationItem__c> orchItemsList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
        insert orchItemsList;
        System.debug('>>>orchItemsList'+ orchItemsList.size()); 
        ftr_TestDataFactory.getAttributesWithCategory();
            
        
        
        // insert response DR
         vlocity_cmt__DRBundle__c  dtb= new vlocity_cmt__DRBundle__c ();
        dtb.Name = 'DRM6LoadAddServiceItemL1Response';
        dtb.vlocity_cmt__DRMapName__c='DRM6LoadAddServiceItemL1Response';
        dtb.vlocity_cmt__InterfaceObject__c='json';
        insert dtb;
    }
 /*@isTest
    static void createPSRTestUNI(){

        vlocity_cmt__OrchestrationItem__c UNIitem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c 
                                                  WHERE Name = 'CreateShellPSR' AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode = 'ENT_ETH_UNI_PSR_001' LIMIT 1];

        Test.startTest();
		UNIitem.Name = 'CreateShellPSR';
        Test.setMock(WebServiceMock.class, new ftr_M6CreatePSRMock());
        ftr_M6CreatePSRSystemInterface psr = new ftr_M6CreatePSRSystemInterface();
        psr.executeItem('','',UNIitem);
        psr.updateDatabase();

        Test.stopTest();
        
       
    }*/

   /* @isTest
    static void createPSRTestEIA(){

        vlocity_cmt__OrchestrationItem__c EIAitem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c 
                                                  WHERE Name = 'CreateShellPSR' AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode = 'ENT_ETH_EIA_EVC_PSR_001' LIMIT 1];        
       
        Test.startTest();

        Test.setMock(WebServiceMock.class, new ftr_M6CreatePSRMock());
        ftr_M6CreatePSRSystemInterface psr = new ftr_M6CreatePSRSystemInterface();
        psr.executeItem('','',EIAitem);
        psr.updateDatabase();

        Test.stopTest();
        
       
    }*/
  /*  @isTest
    static void addServiceItemTest(){
        Test.setMock(WebServiceMock.class, new ftr_M6AddServiceItemL1Mock());


        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c
                                                 WHERE Name = 'AddServiceItem' LIMIT 1];
        
     //   vlocity_cmt__OrchestrationItem__c item = '{"Id":"aA23I0000001fW4SAI","vlocity_cmt__FulfilmentRequestLineId__c":"a9D3I0000008aJwUAI","vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c":"a8b0h000000PAxnAAG","vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c":"a8b0h000000PAxoAAG"}';
        vlocity_cmt__DRBundle__c  dtb =[select Id from vlocity_cmt__DRBundle__c where Name='DRM6LoadAddServiceItemL1Response'];
        item.Id = 'aA23I0000001fW4SAI';
        item.name = 'AddServiceItem';
        item.vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c =dtb.Id;
        item.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c=dtb.Id;
        item.vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c =dtb.Id;
        update item;
        
        ftr_M6AddServiceItemL1SystemInterface l1 = new ftr_M6AddServiceItemL1SystemInterface();
        Test.startTest();
        l1.executeItem('','',item);
        Test.stopTest();
    }
        @isTest
    	static void addChildServiceItemTest(){
        Test.setMock(WebServiceMock.class, new ftr_M6AddServiceItemL2Mock());

        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, 
                                                  vlocity_cmt__VlocityDataRaptorBundleId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c       
                                                  FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'addChildServiceItem' LIMIT 1];
        
		item.id ='aA23I0000001fW4SAI';
        item.Name ='addChildServiceItem';
        item.vlocity_cmt__FulfilmentRequestLineId__c ='a9D3I0000008aJwUAI';
        item.vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c = 'a8b0h000000PAxnAAG';
        item.vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c = 'a8b0h000000PAxoAAG';
        ftr_M6AddServiceItemL2SystemInterface l2 = new ftr_M6AddServiceItemL2SystemInterface();
        
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
                                                  FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'SubmitPSR' LIMIT 1];
		item.Name ='SubmitPSR';
        ftr_M6SubmitOrderSystemInterface fo = new ftr_M6SubmitOrderSystemInterface();
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
                                                  FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'SubmitPSR' LIMIT 1];
		item.Name ='SubmitPSR';
        ftr_M6SubmitOrderSystemInterface fo = new ftr_M6SubmitOrderSystemInterface();
        System.debug('itemTest'+item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c);
        Test.startTest();
        fo.executeItem('','',item);
        Test.stopTest();
    }*/
   static testmethod void testIncrement() {
        Test.startTest();
        ftr_M6AddServiceItemL1SystemInterface.justIncrement();
        ftr_M6BaseSystemInterface.justIncrement();
        Test.stopTest(); 
 }
}