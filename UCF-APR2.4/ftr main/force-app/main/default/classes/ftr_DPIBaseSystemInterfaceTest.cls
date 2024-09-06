/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 4 
**/
@isTest(seeAllData = false) 
    private class ftr_DPIBaseSystemInterfaceTest {
   @TestSetup
    static void makeData(){
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account a = new Account(Name = 'TestAccount1');
        a.RecordTypeId = MasterRTId;
        a.ParentId = globalAcc1.Id;
       // insert a;
 //     Account a = ftr_TestDataFactory.getAccounts(1)[0];
        a.Customer_Number__c = '123';
        insert a;
        insert new ftr_DPIBillingDetails__c(
            BillingTelephoneNumber__c = '12345',
            Customer_Number__c = '123'
        );
    //    insert ftr_TestDataFactory.getAccounts(1);
         Integer numOfOrchItems = 1;
         Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'DPI Circuit Billing CFS' => 'ENT_ETH_DPI_CIRCUIT_BILLING'
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
      @isTest
    static void testDPIInt(){   
        Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock());
        
     //   vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
       //        vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  LIMIT 1];
             vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__NumberOfRetries__c,vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c where name like 'SubmitGroupOrderMember'  LIMIT 1];
        //   vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id FROM vlocity_cmt__OrchestrationItem__c where  vlocity_cmt__VlocityDataRaptorBundleId__c <> NULL  LIMIT 1];

        System.debug('Orchestration item '+ dpiOrcItem.Id);
     //   dpiOrcItem.vlocity_cmt__VlocityDataRaptorBundleId__c = 'a8b3C0000000FE6QAM';
        ftr_DPISubmitGroupOrderMemberInterface baseSystemInt = new ftr_DPISubmitGroupOrderMemberInterface();
    //  ftr_DPIBaseSystemInterface baseSystemInt = new ftr_DPIBaseSystemInterface();
        Test.startTest();
        //baseSystemInt.executeItem('test@test.com','',dpiOrcItem);
        ftr_DPISubmitGroupOrderMemberInterface.justIncrement();
        Test.stopTest();
    }
        @isTest
    public static void exceptionTest(){
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name,vlocity_cmt__NumberOfRetries__c, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c where name like 'SubmitGroupOrderMember' LIMIT 1];

      //  dpiOrcItem.vlocity_cmt__VlocityDataRaptorBundleId__c = 'a8b3C0000000FE6QAM';
        ftr_DPISubmitGroupOrderMemberInterface baseSystemInt = new ftr_DPISubmitGroupOrderMemberInterface();
        baseSystemInt.processDPIResponseType(' ',' ', null) ;
        baseSystemInt.startBatch(' ',' ');
        baseSystemInt.endBatch(' ',' ');
        //baseSystemInt.executeItem('test@test.com','',dpiOrcItem);
        Test.stopTest();
    }
    @isTest
    public static void handlegetOrchestrationItem(){
        Test.startTest();
              
        ftr_DPISubmitGroupOrderMemberInterface baseSystemInt = new ftr_DPISubmitGroupOrderMemberInterface();
        
        baseSystemInt.getOrchestrationTaskName()  ;
        Test.stopTest();
    }
          @isTest
    public static void findAvailableTn(){
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_ResourceManagementMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [select Name,vlocity_cmt__OrderItemId__r.OrderId,id,vlocity_cmt__NumberOfRetries__c,vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__VlocityDataRaptorBundleId__r.Name,vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c from vlocity_cmt__OrchestrationItem__c  where name like 'findAvailableTelephoneNumbers' LIMIT 1];

      //  dpiOrcItem.vlocity_cmt__VlocityDataRaptorBundleId__c = 'a8b3C0000000FE6QAM';
        
        ftr_FindAvailablePhoneNumbersInterface  findAvailableTn = new ftr_FindAvailablePhoneNumbersInterface ();
        findAvailableTn.executeItem('','',dpiOrcItem);
        Test.stopTest();
    }
    @isTest
    public static void retrieveCustomerFacilities(){
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_RetrieveCustFacilitiesMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [select Name,vlocity_cmt__OrderItemId__r.OrderId,id,vlocity_cmt__NumberOfRetries__c,vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__VlocityDataRaptorBundleId__r.Name,vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c from vlocity_cmt__OrchestrationItem__c  where name like 'findAvailableTelephoneNumbers' LIMIT 1];

      //  dpiOrcItem.vlocity_cmt__VlocityDataRaptorBundleId__c = 'a8b3C0000000FE6QAM';
        ftr_RetrieveCustomerFacilitiesInterface subGrpOrder= new ftr_RetrieveCustomerFacilitiesInterface();
        subGrpOrder.executeItem('','',dpiOrcItem);    
       
        Test.stopTest();
    }
         @isTest
    public static void reserveTelephoneNumber(){
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_reserveTelephoneNumberMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [select Name,vlocity_cmt__OrderItemId__r.OrderId,id,vlocity_cmt__NumberOfRetries__c,vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__VlocityDataRaptorBundleId__r.Name,vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c from vlocity_cmt__OrchestrationItem__c  where name like 'findAvailableTelephoneNumbers' LIMIT 1];

      //  dpiOrcItem.vlocity_cmt__VlocityDataRaptorBundleId__c = 'a8b3C0000000FE6QAM';
        ftr_ReserveTelephoneNumberInterface subGrpOrder= new ftr_ReserveTelephoneNumberInterface();
        subGrpOrder.executeItem('','',dpiOrcItem);  
        Test.stopTest();
    }
       @isTest
        public static void testStageGroupOrderMember(){
            Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_StageGroupOrderMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name,vlocity_cmt__NumberOfRetries__c, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c where name like 'StageGroupOrderMember' LIMIT 1];

        ftr_DPIStageGroupOrderMemberInterface stageOrder = new ftr_DPIStageGroupOrderMemberInterface();
        stageOrder.executeItem('','',dpiOrcItem);
        Test.stopTest();
        }
        @isTest
        public static void createTask_RetrieveCustFacilities(){
        Test.startTest();
             Test.setMock(HttpCalloutMock.class, new ftr_DPIBaseInterfaceFallOutMock());
         try{
        vlocity_cmt__OrchestrationItem__c dpiOrcItem = [select name, vlocity_cmt__OrderItemId__r.OrderId,id,vlocity_cmt__NumberOfRetries__c,vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__VlocityDataRaptorBundleId__r.Name,vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c from vlocity_cmt__OrchestrationItem__c  where name like 'findAvailableTelephoneNumbers' LIMIT 1];
        ftr_DPISubmitGroupOrderMemberInterface baseSystemInt= new ftr_DPISubmitGroupOrderMemberInterface();
        baseSystemInt.executeItem('','',dpiOrcItem);  
        }
        catch(Exception e){
                System.debug('Exception handled');
        }
        Test.stopTest();
        }
        
       @isTest
        public static void processDPIResponse(){
            Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_StageGroupOrderMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name,vlocity_cmt__NumberOfRetries__c, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c where name like 'StageGroupOrderMember' LIMIT 1];

        ftr_DPISubmitGroupOrderMemberInterface submitOrderResponse = new ftr_DPISubmitGroupOrderMemberInterface();
        submitOrderResponse.processDPIResponseType('test','',null);
        Test.stopTest();
        }    
        static testMethod void unitTest() {
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        insert globalAcc1;
       //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account accounts = new Account(name = 'TestAccount');
        accounts.RecordTypeId = MasterRTId;
        accounts.ParentId = globalAcc1.Id;
        insert accounts;
        List<Opportunity> oppList = new List<Opportunity>();
        // Order[] oList = ftr_TestDataFactory.getOrders(1);
       //  System.debug('Order list size '+ oList.size());
       //  insert oList[0];
      //   Order o = [select id from Order limit 1];
          Order o = new Order (
            Name = 'Test Order',
            AccountId = accounts.Id,
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId(),
            Product__c = 'EIA',
            Product_Type__c = 'Ethernet',
            Router_s__c = 'No Router',
            //Customer_Requested_Date__c = System.today(),
            EffectiveDate = System.today(),
            BillingStreet = '123 Main Street',
            BillingCity = 'Anywhere',
            BillingState = 'Texas',
            BillingStateCode = 'TX',
            BillingPostalCode = '44088',
            ShippingStreet = '123 Main Street',
            ShippingCity = 'Anywhere',
            ShippingState = 'Texas',
            ShippingStateCode = 'TX',
            ShippingPostalCode = '44088'
        );
          Map<String,Object> createTaskInputMap =new Map<String,Object>();
          Map<String,Object> inputMap =new Map<String,Object>();
          Map<String,String> assetRefCKTMap = new Map<String,String>();
          inputMap.put('orderId', o.Id);
          inputMap.put('assetRefCKTMap', assetRefCKTMap);
          String telnmbr =  '1234567891';
        
           createTaskInputMap.put('Subject','DPI OM Billing Exception'); 	
           createTaskInputMap.put('Priority','High');
           createTaskInputMap.put('WhatId', o.Id);
           createTaskInputMap.put('InterfaceName','reserveTelephoneNumber');
           System.debug('createTaskInputMap -->:'+ createTaskInputMap);
        
       
        Test.startTest();
            
        //    ftr_OrderManagementHelper.CreateTask(createTaskInputMap) ;
            
            Test.setMock(WebServiceMock.class, new ftr_WebServiceMockImpl());
            
          //  ftr_OrderManagementHelper.publishM6OrderUpdates( inputMap) ;
            //ftr_OrderManagementHelper.publishTOEnrichmentEvents( inputMap) ;
            ftr_OrderManagementHelper.validTelephoneNumber(telnmbr);
            
         Test.stopTest();

}
     /*   @isTest
        static void getOLIModifiedInputTest(){
              Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock());
      //  vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c  WHERE  Id='aA23C000000T6HxSAK'];
          vlocity_cmt__OrchestrationItem__c dpiOrcItem = [SELECT Id,Name,vlocity_cmt__NumberOfRetries__c, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c FROM vlocity_cmt__OrchestrationItem__c where name like 'StageGroupOrderMember' LIMIT 1];

        ftr_DPISubmitGroupOrderMemberInterface submitOrderResponse = new ftr_DPISubmitGroupOrderMemberInterface();
        submitOrderResponse.processDPIResponseType('','',null);
        Test.stopTest();
        }*/
    
     /*   @isTest
    static void getInputPayloadTest(){
        
        //Order[] oList = ftr_TestDataFactory.getOrders(1);
        // insert oList;
        // Order o = [select id from Order limit 1];
        
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

        // link items to the same orch plan
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
        Map<String,Object> ctx = new Map<String,Object>();
        Map<String, Object>  input = new Map<String, Object>();
        Map<String, Object>  output = new Map<String, Object>();
        Map<String,Object> ctxOutput = new Map<String,Object>();
        
        ctx.put('createTask', 'True');
        ctx.put('url', '');
        ctx.put('path', '');
       
        

        vlocity_cmt__OrchestrationItem__c UNIitem = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c,vlocity_cmt__OrderItemId__c,vlocity_cmt__OrderItemId__r.OrderId,vlocity_cmt__OrchestrationPlanId__c FROM vlocity_cmt__OrchestrationItem__c 
                                                  WHERE Name = 'CreateShellPSR' AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode = 'ENT_ETH_UNI_PSR_001' LIMIT 1];
        
        orchItems = [SELECT Id,Name, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c,vlocity_cmt__OrderItemId__c,vlocity_cmt__OrderItemId__r.OrderId FROM vlocity_cmt__OrchestrationItem__c 
                                                  WHERE Name = 'CreateShellPSR' AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.productCode = 'ENT_ETH_UNI_PSR_001' LIMIT 1];
         
        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> fulfilMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>([SELECT Id, Name, vlocity_cmt__LineNumber__c from vlocity_cmt__FulfilmentRequestLine__c LIMIT 1]); 
        
         ctx.put('item', UNIitem);
        ctx.put('input', input);
        
        ctxOutput.put('GroupMemberOrderId',UNIitem.vlocity_cmt__OrderItemId__r.OrderId);
        ctxOutput.put('LeadOrderId',UNIitem.vlocity_cmt__OrderItemId__r.OrderId);
        ctxOutput.put('ErrorCode', null);
        ctxOutput.put('ErrorMessage',null);
        ctx.put('output',ctxOutput);
        ctx.put('taskname','RetrieveCustomerFacilities');
        ctx.put('controlNumber','12345');
        ctx.put('cityabbreviation','DA');
        ctx.put('env','ABC');

        Test.startTest();
        Test.setMock(WebServiceMock.class, new ftr_WebServiceMockImpl());

        //Test.setMock(WebServiceMock.class, new ftr_M6CreatePSRMock());
        //ftr_M6CreatePSRSystemInterface psr = new ftr_M6CreatePSRSystemInterface();
        
        //ftr_OrderManagementHelper.executeResponseDR(ctx, UNIitem.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c,UNIitem.vlocity_cmt__fulfilmentRequestLineId__c, UNIitem.vlocity_cmt__OrderItemId__r.OrderId);
        input = ftr_OrderManagementHelper.getInputPayload('','',UNIitem);
        //ftr_OrderManagementHelper.setBTNOrder(orchItems, fulfilMap, ctx);
        ftr_OrderManagementHelper.executeResponseDR(ctx, '', fulfilMap.values()[0].Id, UNIitem.vlocity_cmt__OrderItemId__r.OrderId);
        ftr_OrderManagementHelper.executeResponseDR(UNIitem,ctx);
        ftr_OrderManagementHelper.getBTNbyEnvironment(UNIitem.vlocity_cmt__OrchestrationPlanId__c);
        

         //output = invoke('', '', input);
        //ctx.put('output', output);
             
//vlocity_cmt__OrchestrationItem__c.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c
        Test.stopTest();
        
       
    }*/
          @isTest 
     	static void testIncrement() {
            ftr_DPIBaseSystemInterface.justIncrement();
    
     }    
}