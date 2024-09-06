/** 
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3 
**/
@isTest
private class ftr_M6CreatePSRTest {

    @TestSetup
    static void makeData(){
           
        ftr_TestDataFactory.getAttributesWithCategory();

        // insert response DR
        vlocity_cmt__DRBundle__c  dtb= new vlocity_cmt__DRBundle__c ();
        dtb.Name = 'M6CreateShellPSRResponseDR';
        dtb.vlocity_cmt__DRMapName__c='M6CreateShellPSRResponseDR';
        dtb.vlocity_cmt__InterfaceObject__c='json';
        insert dtb;

        // create orch items
        Map<String,String> prodCodeMap = new Map<String,String>{
            'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
        };
        List<vlocity_cmt__OrchestrationItem__c> orchItems = ftr_TestDataFactory.getOrchestrationItems(1, prodCodeMap);
        
        prodCodeMap = new Map<String,String>{
            'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001'
        };
        orchItems.addAll(ftr_TestDataFactory.getOrchestrationItems(1, prodCodeMap));

        //link items to the same orch plans
        for(vlocity_cmt__OrchestrationItem__c item : orchItems) {
            item.vlocity_cmt__OrchestrationPlanId__c = orchItems[0].vlocity_cmt__OrchestrationPlanId__c;
        }

        // link items to DR
        for (vlocity_cmt__OrchestrationItem__c item : orchItems) {
            item.vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c =dtb.Id;
            item.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c=dtb.Id;
            item.vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c =dtb.Id;
        }
        insert orchItems;
        
    }

    @isTest
    static void createPSRTestUNI(){

        vlocity_cmt__OrchestrationItem__c UNIitem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c 
                                                  WHERE Name = 'CreateShellPSR' AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode = 'ENT_ETH_UNI_PSR_001' LIMIT 1];

        Test.startTest();

        Test.setMock(WebServiceMock.class, new ftr_M6CreatePSRMock());
        ftr_M6CreatePSRSystemInterface psr = new ftr_M6CreatePSRSystemInterface();
        psr.executeItem('','',UNIitem);
        psr.updateDatabase();

        Test.stopTest();
        
       
    }

    @isTest
    static void createPSRTestEIA(){

        vlocity_cmt__OrchestrationItem__c EIAitem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c 
                                                  WHERE Name = 'CreateShellPSR' AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode = 'ENT_ETH_EIA_EVC_PSR_001' LIMIT 1];        
       
        Test.startTest();  

        Test.setMock(WebServiceMock.class, new ftr_M6CreatePSRMock());
        ftr_M6CreatePSRSystemInterface psr = new ftr_M6CreatePSRSystemInterface();
        psr.executeItem('','',EIAitem);
        psr.updateDatabase();

        Test.stopTest();
        
       
    }
     @isTest
    static void testHolidayCheck(){

      
       
        Test.startTest();  

       // Test.setMock(WebServiceMock.class, new ftr_M6CreatePSRMock());
        ftr_M6CreatePSRSystemInterface psr = new ftr_M6CreatePSRSystemInterface();
        Date desiredDueDate = System.today();
        psr.getHolidayCheck(desiredDueDate);
       // psr.updateDatabase();

        Test.stopTest();
        
       
    }
}