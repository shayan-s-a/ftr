/**
 * @description       : This test class covers the following Apex classes:
 *      ftr_OrderManagementHelper
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest(seeAllData = false)

private class ftr_OrderManagementHelperTest {
    
    
    static testMethod void unitTest() {
        
      	 Order[] oList = ftr_TestDataFactory.getOrders(1);
         insert oList;
         Order o = [select id from Order limit 1];
        
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
        	
        	ftr_OrderManagementHelper.CreateTask(createTaskInputMap) ;
            
        	Test.setMock(WebServiceMock.class, new ftr_WebServiceMockImpl());
        	
            ftr_OrderManagementHelper.publishM6OrderUpdates( inputMap) ;
            //ftr_OrderManagementHelper.publishTOEnrichmentEvents( inputMap) ;
            ftr_OrderManagementHelper.validTelephoneNumber(telnmbr);
        	
         Test.stopTest();

}
    
        @isTest
    static void getInputPayloadTest(){
        
        /*Order[] oList = ftr_TestDataFactory.getOrders(1);
         insert oList;
         Order o = [select id from Order limit 1];*/
        
        ftr_TestDataFactory.getAttributesWithCategory();

        // insert response DR
        vlocity_cmt__DRBundle__c  dtb= new vlocity_cmt__DRBundle__c ();
        dtb.Name = 'M6CreateShellPSRResponseDR';
        dtb.vlocity_cmt__DRMapName__c='M6CreateShellPSRResponseDR';
        dtb.vlocity_cmt__InterfaceObject__c='json';
        insert dtb;

        // create orch items
        Map<String,String> prodCodeMap = new Map<String,String>{
            'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001',
            'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001'
        };
        List<vlocity_cmt__OrchestrationItem__c> orchItems = ftr_TestDataFactory.getOrchestrationItems(1, prodCodeMap);
        
        // orchItems.addAll(ftr_TestDataFactory.getOrchestrationItems(1, prodCodeMap));

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
                                                  WHERE Name = 'CreateShellPSR'  LIMIT 1];
        
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
        //   *ftr_M6CreatePSRSystemInterface psr = new ftr_M6CreatePSRSystemInterface();
        
        //ftr_OrderManagementHelper.executeResponseDR(ctx, UNIitem.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c,UNIitem.vlocity_cmt__fulfilmentRequestLineId__c, UNIitem.vlocity_cmt__OrderItemId__r.OrderId);
        input = ftr_OrderManagementHelper.getInputPayload('','',UNIitem);
        //ftr_OrderManagementHelper.setBTNOrder(orchItems, fulfilMap, ctx);
        ftr_OrderManagementHelper.executeResponseDR(ctx, '', fulfilMap.values()[0].Id, UNIitem.vlocity_cmt__OrderItemId__r.OrderId);
        ftr_OrderManagementHelper.executeResponseDR(UNIitem,ctx);
        ftr_OrderManagementHelper.getBTNbyEnvironment(UNIitem.vlocity_cmt__OrchestrationPlanId__c);

        input = ftr_OrderManagementHelper.getInputPayload('','',UNIitem);
        output = ftr_OrderManagementHelper.executeRequestDR(input, 'M6CreateShellPSRResponseDR');
        ftr_OrderManagementHelper.executeReserveResponseDR(UNIitem, output);
        ftr_OrderManagementHelper.getBillingTNByEnvironment(UNIitem.vlocity_cmt__OrderItemId__r.OrderId);
        

         //output = invoke('', '', input);
        //ctx.put('output', output);
             
//vlocity_cmt__OrchestrationItem__c.vlocity_cmt__ResponseVlocityDataRaptorBundleId__c
        Test.stopTest();
        
       
    }
    
    }