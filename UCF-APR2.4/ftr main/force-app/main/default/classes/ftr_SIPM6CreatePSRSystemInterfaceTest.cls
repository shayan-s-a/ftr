@isTest
private class ftr_SIPM6CreatePSRSystemInterfaceTest {
    @TestSetup
    static void makeData(){
           
        ftr_TestDataFactory.getAttributesWithCategory();

        // *insert response DR
        vlocity_cmt__DRBundle__c  dtb= new vlocity_cmt__DRBundle__c ();
        dtb.Name = 'SIPM6CreateShellPSRResponseDR';
        dtb.vlocity_cmt__DRMapName__c='SIPM6CreateShellPSRResponseDR';
        dtb.vlocity_cmt__InterfaceObject__c='json';
        insert dtb;

        // create orch items
        
        Map<String,String> prodCodeMap = new Map<String,String>{
            'M6 UNI SIP PSR RESOURCE SPEC' => 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010',
            'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001',
            'M6 EVPL EVC PSR CFS' => 'ENT_ETH_EVPL_EVC_PSR_001',
            'M6 SIP EVC  PSR RESOURCE SPEC' => 'SIP_EVC_PSR_RES_SPEC_0010'
        };
        List<vlocity_cmt__OrchestrationItem__c> orchItems = ftr_TestDataFactory.getOrchestrationItems(1, prodCodeMap);

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

        vlocity_cmt__OrchestrationItem__c UNIitem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c WHERE Name = 'SIPCreateShellPSR' AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode = 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010' LIMIT 1];

        Test.startTest();

        Test.setMock(WebServiceMock.class, new ftr_SIPM6CreatePSRMock());
        ftr_SIPM6CreatePSRSystemInterface psr = new ftr_SIPM6CreatePSRSystemInterface();
        psr.executeItem('','',UNIitem);
        psr.updateDatabase();

        Test.stopTest();
    }

     @isTest
    static void testHolidayCheck(){

      
       
        Test.startTest();  

       // Test.setMock(WebServiceMock.class, new ftr_SIPM6CreatePSRMock());
        ftr_SIPM6CreatePSRSystemInterface psr = new ftr_SIPM6CreatePSRSystemInterface();
        Date desiredDueDate = System.today();
        psr.getHolidayCheck(desiredDueDate);
       // psr.updateDatabase();

        Test.stopTest();
        
       
    }
}