/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
 * 
**/
@isTest
public class ftr_OrderManagementServiceTest {

    @TestSetup
    static void makeData(){
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
        //Premises
        vlocity_cmt__Premises__c Prms = new vlocity_cmt__Premises__c();
		Prms.WC_CLLI__c = 'MSTNWIXA';
        insert Prms;
        //Custom Object Details
        ftr_PSRExchangeDetail__c Ex = new ftr_PSRExchangeDetail__c();
        Ex.WC_CLLI__c = 'MSTNWIXA';
        Ex.Company_Indicator_Code__c = 203;
        Ex.NPANXX__c = '608297';
        insert Ex;   
        //Test Account Insert
         Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Master' LIMIT 1]?.Id;
       
        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = masterRecId;
        a.ParentId = globalAcc.Id;
        insert a;
        Id servRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Service' LIMIT 1]?.Id;
        Account serviceAccount = new Account();
        serviceAccount.RecordTypeId = servRecId;
        serviceAccount.Name = 'Service Account';
        serviceAccount.ShippingStreet = '1480 North Valley Parkway';
        serviceAccount.ShippingCity = 'Lewisville';    	
        serviceAccount.ShippingState = 'Texas';
        serviceAccount.ShippingPostalCode = '75077';
        serviceAccount.vlocity_cmt__PremisesId__c= Prms.Id;
        serviceAccount.ParentId = a.Id;
        insert serviceAccount;
        //Test Account 2
        Account a1 = new Account();
        a1.Name = 'Test Account 1';
        a1.RecordTypeId = masterRecId;
        a1.ParentId = globalAcc.Id;
        insert a1;
        Account serviceAccount1 = new Account();
        serviceAccount1.RecordTypeId = servRecId;
        serviceAccount1.Name = 'Service Account 1';
        serviceAccount1.ShippingStreet = '1565 West Main Street';
        serviceAccount1.ShippingCity = 'Lewisville';    	
        serviceAccount1.ShippingState = 'Texas';
        serviceAccount1.ShippingPostalCode = '75067';
        serviceAccount1.vlocity_cmt__PremisesId__c= Prms.Id;
        serviceAccount1.ParentId = a1.Id;
        insert serviceAccount1;
        Product2 p = new Product2();
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode = 'ENT_ETH_EIA_0002';
        p.isActive = true;
        insert p;
        Product2 p2 = new Product2();
        p2.Name = ' Test EVPL EVC ';
        p2.Description='Test EVPL EVC';
        p2.productCode = 'ENT_ETH_EVPL_0010';
        p2.isActive = true;
        insert p2;
        Product2 p3 = new Product2();
        p3.Name = ' Test UNI ';
        p3.Description='Test UNI';
        p3.productCode = 'ENT_ETH_UNI_0001';
        p3.isActive = true;
        insert p3;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice1 = new PricebookEntry();
        standardPrice1.Pricebook2Id = pricebookId;
        standardPrice1.Product2Id = p.Id;
        standardPrice1.UnitPrice = 1;
        standardPrice1.IsActive = true;
        standardPrice1.UseStandardPrice = false;
        insert standardPrice1 ;
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = standardPb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        //Orchestration Plan
        vlocity_cmt__OrchestrationPlan__c Orp = new vlocity_cmt__OrchestrationPlan__c();
        Orp.vlocity_cmt__State__c = 'Completed';
        insert Orp;
        //OrchestrationPlanDefinition
        vlocity_cmt__OrchestrationPlanDefinition__c OrPDF = new vlocity_cmt__OrchestrationPlanDefinition__c();
        OrPDF.Name = 'FinalOrderCompletion';
        insert OrPDF;
        //Orchestrations item definition
        vlocity_cmt__OrchestrationItemDefinition__c OrdDef = new vlocity_cmt__OrchestrationItemDefinition__c();
        OrdDef.vlocity_cmt__OrchestrationPlanDefinitionId__c = OrPDF.id;
        OrdDef.Name='FinalOrderCompletion';
        insert OrdDef;
        //Fullfillment Request Line
        vlocity_cmt__FulfilmentRequestLine__c Flr = new vlocity_cmt__FulfilmentRequestLine__c();	
        insert Flr;
        //Orchestration Item
        vlocity_cmt__OrchestrationItem__c OItm = new vlocity_cmt__OrchestrationItem__c();
        OItm.vlocity_cmt__State__c = 'Running';
        OItm.vlocity_cmt__FulfilmentRequestLineId__c = Flr.id;
        OItm.vlocity_cmt__OrchestrationItemDefinitionId__c = OrdDef.id;
        OItm.vlocity_cmt__OrchestrationPlanId__c = Orp.id;
        insert OItm;        
        //Test Order Insert
        Order o = new Order();
        o.Name = 'Test Order 04.10.2020 KE';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 10;
        o.AccountId = a.id;
        o.Pricebook2Id =  standardPb.Id ;
        o.vlocity_cmt__OrchestrationPlanId__c = Orp.id;
        insert o;
        //Test Order Item
        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.id;
        i.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i.vlocity_cmt__Product2Id__c = p.Id;
        //i.Total_Price__c = i.Quantity * i.UnitPrice;
        insert i;
        //Test OrderItem on second insert
        OrderItem i2 = new OrderItem();
        i2.OrderId = o.id;
        i2.Quantity = 10;
        i2.UnitPrice = 20;
        i2.PricebookEntryId=standardPrice.id;
        i2.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i2.vlocity_cmt__Product2Id__c = p.Id;
        insert i2;
    }
    
    static testMethod void OrderMgmtServcTest() {      	
        
        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        test.startTest();	
        ftr_OrderManagementService OMS = new ftr_OrderManagementService();
        OMS.invokeMethod('completeOrder', inputMap, outputMap, options);            	   
        inputMap.put('contextId', [SELECT Id FROM Order LIMIT 1].id);
        boolean blnResult = OMS.invokeMethod('completeOrder', inputMap, outputMap, options);
        system.assertEquals(blnResult,true);
        inputMap.put('contextId', [SELECT Id FROM vlocity_cmt__OrchestrationPlan__c LIMIT 1].id);
        blnResult= OMS.invokeMethod('completeOrder', inputMap, outputMap, options);
        system.assertEquals(blnResult,false);
        test.stopTest();
        
    }

    static testMethod void OrderMgmtServcTest2() {      	
        
        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        
        test.startTest();	
        Order o = [SELECT Id,Products__c FROM Order LIMIT 1];
        o.Products__c = 'SIP';
        update o;
        ftr_OrderManagementService OMS = new ftr_OrderManagementService();
        inputMap.put('contextId', o.id);
        OMS.invokeMethod('flagOrderForAssetization', inputMap, outputMap, options);
        o.Products__c = 'SIP;EIA';
        update o;
        OMS.invokeMethod('flagOrderForAssetization', inputMap, outputMap, options);
        test.stopTest();
        
    }
}