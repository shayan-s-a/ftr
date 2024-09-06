@isTest
public class ftr_DPISIPBaseSystemInterfaceTest {
    @TestSetup
    static void makeData(){
        Account a = ftr_TestDataFactory.getAccounts(1)[0];
        a.Customer_Number__c = '123';
        insert a;
        insert new ftr_DPIBillingDetails__c( BillingTelephoneNumber__c = '12345', Customer_Number__c = '123');
        insert ftr_TestDataFactory.getAccounts(1);
         Integer numOfOrchItems = 1;
         Map<String,String> prodNameCodeMap = new Map<String,String>{
            'M6 UNI SIP PSR RESOURCE SPEC' => 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010',
            'M6 SIP EVC  PSR RESOURCE SPEC' => 'SIP_EVC_PSR_RES_SPEC_0010',
            'SIP TRUNKING DPI BILLING RESOURCE SPEC' => 'SIP_TRUNKING_DPI_BILLING_RES_SPEC_0010',
            'DPI CIRCUIT BILLING RESOURCE SPEC' => 'DPI_CIRCUIT_BILLING_RES_SPEC_0010'
        };

        List<vlocity_cmt__OrchestrationItem__c> orchItems = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
             
        ftr_TestDataFactory.getAttributesWithCategory();
        vlocity_cmt__FulfilmentRequestLine__c Flr = [select id,vlocity_cmt__FulfilmentRequestId__c from vlocity_cmt__FulfilmentRequestLine__c where Id = :orchItems[0].vlocity_cmt__FulfilmentRequestLineId__c];
        vlocity_cmt__FulfilmentRequest__c ftr_request =   [select id,vlocity_cmt__AccountId__c from vlocity_cmt__FulfilmentRequest__c where Id = :Flr.vlocity_cmt__FulfilmentRequestId__c];
        ftr_request.vlocity_cmt__AccountId__c = a.Id;
         
        update ftr_request;
        System.debug('ftr_request is :'+ ftr_request);
      /*  vlocity_cmt__FulfilmentRequestLine__c Flr = new vlocity_cmt__FulfilmentRequestLine__c();
        Flr.vlocity_cmt__FulfilmentRequestID__c =
            orchItems[0].vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c  ;
        insert Flr;*/
        
        // insert response DR
         vlocity_cmt__DRBundle__c  dtb= new vlocity_cmt__DRBundle__c ();
        dtb.Name = 'SubmitGroupOrderMemberRequestDR';
        dtb.vlocity_cmt__DRMapName__c='SubmitGroupOrderMemberRequestDR';
        dtb.vlocity_cmt__InterfaceObject__c='json';
        insert dtb;
         vlocity_cmt__DRBundle__c  dtb_staging= new vlocity_cmt__DRBundle__c ();
        dtb_staging.Name = 'StageGroupOrderMemberRequestDR';
        dtb_staging.vlocity_cmt__DRMapName__c='StageGroupOrderMemberRequestDR';
        dtb_staging.vlocity_cmt__InterfaceObject__c='json';
        insert dtb_staging;
         vlocity_cmt__DRBundle__c  dtb_retrieveCustFac= new vlocity_cmt__DRBundle__c ();
        dtb_retrieveCustFac.Name = 'RetrieveCustomerFacilitiesRequest';
        dtb_retrieveCustFac.vlocity_cmt__DRMapName__c = 'RetrieveCustomerFacilitiesRequest';
        dtb_retrieveCustFac.vlocity_cmt__InterfaceObject__c='json';
        insert dtb_retrieveCustFac;
         vlocity_cmt__DRBundle__c  dtb_findAvailableTel= new vlocity_cmt__DRBundle__c ();
        dtb_findAvailableTel.Name = 'FindAvailablePhoneNumbersRequest';
        dtb_findAvailableTel.vlocity_cmt__DRMapName__c = 'FindAvailablePhoneNumbersRequest';
        dtb_findAvailableTel.vlocity_cmt__InterfaceObject__c='json';
        insert dtb_findAvailableTel;
         vlocity_cmt__DRBundle__c  dtb_reserveTelNum= new vlocity_cmt__DRBundle__c ();
        dtb_reserveTelNum.Name = 'ReserveTelephoneNumberRequest';
        dtb_reserveTelNum.vlocity_cmt__DRMapName__c = 'ReserveTelephoneNumberRequest';
        dtb_reserveTelNum.vlocity_cmt__InterfaceObject__c='json';
        insert dtb_reserveTelNum;
        vlocity_cmt__DRBundle__c  dtbr= new vlocity_cmt__DRBundle__c ();
        dtbr.Name = 'SubmitGroupOrderMemberResponseDR';
        dtbr.vlocity_cmt__DRMapName__c='SubmitGroupOrderMemberResponseDR';
        dtbr.vlocity_cmt__InterfaceObject__c='json';
        insert dtbr;        
         for(vlocity_cmt__OrchestrationItem__c item : orchItems) {
            item.vlocity_cmt__OrchestrationPlanId__c = orchItems[0].vlocity_cmt__OrchestrationPlanId__c;
           
        }

        // link items to DR
        for (vlocity_cmt__OrchestrationItem__c item : orchItems) {
            item.vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c =dtbr.Id;
            item.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c=dtbr.Id;
            item.vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c =dtbr.Id;
            item.vlocity_cmt__VlocityDataRaptorBundleId__c = dtb.Id;
        }
        insert orchItems;
        System.debug('orchItems '+ orchItems);
    }
    /*
      @isTest
    static void testDPIInt(){   
        Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock());
        
     //   vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
       //        vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  LIMIT 1];
             vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__NumberOfRetries__c,vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c where name like 'SIPSubmitGroupOrderMember'  LIMIT 1];
        //   vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id FROM vlocity_cmt__OrchestrationItem__c where  vlocity_cmt__VlocityDataRaptorBundleId__c <> NULL  LIMIT 1];

        System.debug('Orchestration item '+ dpiOrcItem.Id);
     //   dpiOrcItem.vlocity_cmt__VlocityDataRaptorBundleId__c = 'a8b3C0000000FE6QAM';
     ftr_DPISIPSubmitGroupOrderMemberInterf baseSystemInt = new ftr_DPISIPSubmitGroupOrderMemberInterf();
    //  ftr_DPIBaseSystemInterface baseSystemInt = new ftr_DPIBaseSystemInterface();
        Test.startTest();
        baseSystemInt.executeItem('','',dpiOrcItem);
        Test.stopTest();
    }
    */
    /*
        @isTest
    public static void exceptionTest(){
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name,vlocity_cmt__NumberOfRetries__c, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c where name like 'SIPSubmitGroupOrderMember' LIMIT 1];

      //  dpiOrcItem.vlocity_cmt__VlocityDataRaptorBundleId__c = 'a8b3C0000000FE6QAM';
        ftr_DPISIPSubmitGroupOrderMemberInterf baseSystemInt = new ftr_DPISIPSubmitGroupOrderMemberInterf();
        baseSystemInt.processDPIResponseType(' ',' ', null) ;
        baseSystemInt.startBatch(' ',' ');
        baseSystemInt.endBatch(' ',' ');
        baseSystemInt.executeItem('','',dpiOrcItem);
        Test.stopTest();
    }
    */
    /*
    @isTest
    public static void handlegetOrchestrationItem(){
        Test.startTest();
              
        ftr_DPISIPSubmitGroupOrderMemberInterf baseSystemInt = new ftr_DPISIPSubmitGroupOrderMemberInterf();
        
        baseSystemInt.getOrchestrationTaskName()  ;
        Test.stopTest();
    }
          @isTest
    public static void findAvailableTn(){
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_ResourceManagementMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [select vlocity_cmt__OrderItemId__r.OrderId,id,vlocity_cmt__NumberOfRetries__c,vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__VlocityDataRaptorBundleId__r.Name,vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c from vlocity_cmt__OrchestrationItem__c  where name like 'SIPFindAvailableTelephoneNumbers' LIMIT 1];

      //  dpiOrcItem.vlocity_cmt__VlocityDataRaptorBundleId__c = 'a8b3C0000000FE6QAM';
        
      ftr_SIPFindAvailablePhoneNumbInterface  findAvailableTn = new ftr_SIPFindAvailablePhoneNumbInterface ();
        findAvailableTn.executeItem('','',dpiOrcItem);
        Test.stopTest();
    }
    */
    @isTest
    public static void retrieveCustomerFacilities(){
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_RetrieveCustFacilitiesMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [select vlocity_cmt__OrderItemId__r.OrderId,id,vlocity_cmt__NumberOfRetries__c,vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__VlocityDataRaptorBundleId__r.Name,vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c from vlocity_cmt__OrchestrationItem__c  where name like 'SIPFindAvailableTelephoneNumbers' LIMIT 1];

      //  dpiOrcItem.vlocity_cmt__VlocityDataRaptorBundleId__c = 'a8b3C0000000FE6QAM';
      ftr_SIPRetrieveCustomerFacilitiesInterf subGrpOrder= new ftr_SIPRetrieveCustomerFacilitiesInterf();
        subGrpOrder.executeItem('','',dpiOrcItem);    
       
        Test.stopTest();
    }
         @isTest
    public static void reserveTelephoneNumber(){
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_reserveTelephoneNumberMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [select vlocity_cmt__OrderItemId__r.OrderId,id,vlocity_cmt__NumberOfRetries__c,vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__VlocityDataRaptorBundleId__r.Name,vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c from vlocity_cmt__OrchestrationItem__c  where name like 'SIPFindAvailableTelephoneNumbers' LIMIT 1];

      //  dpiOrcItem.vlocity_cmt__VlocityDataRaptorBundleId__c = 'a8b3C0000000FE6QAM';
      ftr_SIPReserveTelephoneNumberInterface subGrpOrder= new ftr_SIPReserveTelephoneNumberInterface();
        subGrpOrder.executeItem('','',dpiOrcItem);    
       
        Test.stopTest();
    }
       @isTest
        public static void testStageGroupOrderMember(){
            Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_StageGroupOrderMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name,vlocity_cmt__NumberOfRetries__c, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c where name like 'SIPStageGroupOrderMember' LIMIT 1];

          ftr_DPISIPStageGroupOrderMemberInterf stageOrder = new ftr_DPISIPStageGroupOrderMemberInterf();
        stageOrder.executeItem('','',dpiOrcItem);
        Test.stopTest();
        }
        /*
        @isTest
        public static void createTask_RetrieveCustFacilities(){
        Test.startTest();
             Test.setMock(HttpCalloutMock.class, new ftr_DPIBaseInterfaceFallOutMock());
         try{
        vlocity_cmt__OrchestrationItem__c dpiOrcItem = [select vlocity_cmt__OrderItemId__r.OrderId,id,vlocity_cmt__NumberOfRetries__c,vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__VlocityDataRaptorBundleId__r.Name,vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c from vlocity_cmt__OrchestrationItem__c  where name like 'SIPFindAvailableTelephoneNumbers' LIMIT 1];
        ftr_DPISIPSubmitGroupOrderMemberInterf baseSystemInt= new ftr_DPISIPSubmitGroupOrderMemberInterf();
        baseSystemInt.executeItem('','',dpiOrcItem);  
                }
            catch(Exception e){
                System.debug('Exception handled');
            }
        Test.stopTest();
        }
        */
}