/**
 * @description       :This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3
**/
@isTest
public class ftr_XOMSubmitOrderControllerTest {
    
    @TestSetup
    static void makeData(){
        User u = ftr_TestDataFactory.getUsers(new List<String> {'#Project Manager'})[0];
        insert u;
        try {
            insert new Group(
                Email='test@test.com',
                Type='Queue',
                Name='PM_Assignment'
            );
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
     static testMethod void XOMSCTest() {    
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
        //Test Account Insert*
        
            Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account a = new Account();
         a.RecordTypeId = masterRecId1;
        a.Name = 'Test Account';
       a.ParentId = globalAcc1.Id;
       a.RecordTypeId = masterRecId1;
        insert a;
        Account serviceAccount = new Account();
         serviceAccount.ParentId = a.id;
        serviceAccount.Name = 'Service Account';
        serviceAccount.ShippingStreet = '1480 North Valley Parkway';
        serviceAccount.ShippingCity = 'Lewisville';     
        serviceAccount.ShippingState = 'Texas';
        serviceAccount.ShippingPostalCode = '75077';
        serviceAccount.vlocity_cmt__PremisesId__c= Prms.Id;
       // insert serviceAccount;
       /*Test Account 2
        
            Id globalRecId2 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc2 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId2;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc2;
        
         Id masterRecId2 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account a1 = new Account();
        a1.RecordTypeId = masterRecId2;
        a1.ParentId = globalAcc1.Id;
        a1.Name = 'Test Account 1';
       a1.ParentId = globalAcc2.Id;
       a1.RecordTypeId = masterRecId2;
        insert a1;*/
        Account serviceAccount1 = new Account();
         serviceAccount1.ParentId = a.id;
        serviceAccount1.Name = 'Service Account 1';
        serviceAccount1.ShippingStreet = '1565 West Main Street';
        serviceAccount1.ShippingCity = 'Lewisville';        
        serviceAccount1.ShippingState = 'Texas';
        serviceAccount1.ShippingPostalCode = '75067';
        serviceAccount1.vlocity_cmt__PremisesId__c= Prms.Id;
       // insert serviceAccount1;
        //Product-1
        Product2 p = new Product2();
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode = 'ENT_ETH_EIA_0002';
        p.isActive = true;
        //insert p;
        //Product-2
        Product2 p2 = new Product2();
        p2.Name = ' Test EVPL EVC ';
        p2.Description='Test EVPL EVC';
        p2.productCode = 'ENT_ETH_EVPL_0010';
        p2.isActive = true;
        //insert p2;
        //Product-3
        Product2 p3 = new Product2();
        p3.Name = ' Test UNI ';
        p3.Description='Test UNI';
        p3.productCode = 'ENT_ETH_UNI_0001';
        p3.isActive = true;
        //insert p3;
        //PriceBooks
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice1 = new PricebookEntry();
        standardPrice1.Pricebook2Id = pricebookId;
        standardPrice1.Product2Id = p.Id;
        standardPrice1.UnitPrice = 1;
        standardPrice1.IsActive = true;
        standardPrice1.UseStandardPrice = false;
       // insert standardPrice1 ;
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
       // insert standardPb;
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = standardPb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
       // insert standardPrice ;
        //Test Order Insert
        Order o = new Order();
        o.Name = 'Test Order 04.10.2020 KE';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 10;
        o.AccountId = a.id;
        o.Pricebook2Id =  standardPb.Id ;
        o.Products__c = 'SIP;EIA';
        o.Order_Stage__c = 'MSA Review';
       // insert o;
        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.id;
        i.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i.vlocity_cmt__Product2Id__c = p.Id;
        //i.Total_Price__c = i.Quantity * i.UnitPrice;
        //insert i;
        //Test OrderItem on second insert
        OrderItem i2 = new OrderItem();
        i2.OrderId = o.id;
        i2.Quantity = 10;
        i2.UnitPrice = 20;
        i2.PricebookEntryId=standardPrice.id;
        i2.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i2.vlocity_cmt__Product2Id__c = p.Id;
        //i2.Total_Price__c = i.Quantity * i.UnitPrice;
        //insert i2;
        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        ftr_XOMSubmitOrderController XOMSC = new ftr_XOMSubmitOrderController(sc); 
        try {
            XOMSC.submitOrder(); 
           // XOMSC.codeCoverageNeedToFixLater();
        }catch(Exception e){
            
        }
        //XOMSC.submitAsyncOrder();
        inputMap.put('contextId', o.id);
        ftr_XOMSubmitOrderController XOMSubOrder = new ftr_XOMSubmitOrderController();
        
        o.put('Network_Project_Specialist__c', [SELECT Id FROM User WHERE Email='Cpt.Awesome0@awesomesauce.com' AND Profile.Name = '#Project Manager'].Id);
        //update o;
        XOMSubOrder.invokeMethod('submitOrder', inputMap, outputMap, optionsMap);
         XOMSubOrder.invokeMethod('', inputMap, outputMap, optionsMap);
        inputMap.put('orderId', o.id);
        inputMap.put('contextId', o.id);
        ftr_XOMSubmitOrderController XOMServ = new ftr_XOMSubmitOrderController();
        XOMServ.invokeMethod('requestSEReview', inputMap, outputMap, optionsMap);
        XOMServ.invokeMethod('rejectOrder', inputMap, outputMap, optionsMap);
        XOMServ.invokeMethod('submitToMSA', inputMap, outputMap, optionsMap);
        XOMServ.invokeMethod('confirmProgressUCFOrder', inputMap, outputMap, optionsMap);
        
        inputMap.put('contextId', i.id);
        ftr_XOMSubmitOrderController XOMServ1 = new ftr_XOMSubmitOrderController();
        XOMServ1.invokeMethod('requestSEReview', inputMap, outputMap, optionsMap); 
        
       // o.Order_Stage__c = 'Solutions Engineering';
     //   update o;
       // XOMServ.invokeMethod('rejectOrder', inputMap, outputMap, optionsMap);
        
    }
     
    static testMethod void testSubmitOrder() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        oList[0].Products__c = 'EIA';
        insert oList;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        
        obj.invokeMethod('submitOrder', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        Test.stopTest();
        
    }
    
    static testMethod void testRequestSEReview() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('requestSEReview', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        
        Test.stopTest();
        
    }
    
    static testMethod void testRejectMngdSvc() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('rejectMngdSvc', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        
        Test.stopTest();
        
    }
    
    static testMethod void testSubmitForSEApproval() {
        
        List<Quote> oList = ftr_TestDataFactory.getQuotes(1);
        insert oList;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('submitForSEApproval', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        
        Test.stopTest();
        
    }
    
    static testMethod void testRequestSEReview2() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        oList[0].vlocity_cmt__QuoteId__c = oList[0].QuoteId;
        insert oList;
        
        Quote q = [select id, vlocity_cmt__ValidationStatus__c from quote where id=:oList[0].QuoteId];
        q.vlocity_cmt__ValidationStatus__c = 'Failed';
        update q;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('requestSEReview', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        obj.invokeMethod('confirmSubmitOrder', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        
        Test.stopTest();
        
    }
    
    static testMethod void testRejectOrder() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('rejectOrder', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        Test.stopTest();
        
    }
 /*   static testMethod void testSubmitforapproval() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        List<Quote> Qst = ftr_TestDataFactory.getQuotes(1);
        insert Qst;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('submitForApproval', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        obj.accountHasFSA( new Map<string,object>{'contextId'=>Qst[0].Id}, new Map<string,object>(), new Map<string,object>());
        Test.stopTest();
        
    }*/
    
    static testMethod void testConfirmSubmitOrder() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('confirmSubmitOrder', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        Test.stopTest();
        
    }
    
    static testMethod void testConfirmCompleteOrder() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('confirmCompleteOrder', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        Test.stopTest();
        
    }
    
    static testMethod void testCancelOrder() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('cancelOrder', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        obj.invokeMethod('confirmCancelOrder', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        Test.stopTest();
        
    }
    
    static testMethod void testPSAssignment() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        oList[0].Products__c = 'EIA';
        insert oList;
        
        Test.startTest();
        try {
            ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
            obj.checkForProjectSpecialist(new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        } catch (EXception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
        
    }
    
    static testMethod void testSubmitOrderAsync() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        String orderId = oList[0].Id;
        Test.startTest();
        try {
            System.enqueueJob(new ftr_XOMSubmitOrderController.DecomposeOrderAsync(orderId));
            System.enqueueJob(new ftr_XOMSubmitOrderController.CreatePlanAsync(orderId));
            
        } catch (EXception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
        
    }
    
    static testMethod void testSubmitOrderSC() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        
        Test.startTest();
        try {
            ApexPages.StandardController sc = new ApexPages.StandardController(oList[0]);
            ftr_XOMSubmitOrderController XOMSC = new ftr_XOMSubmitOrderController(sc);
            XOMSC.submitOrder(); 
        } catch (EXception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
        
    }
    
    static testMethod void testSendOrderDetails() {
        
        List<Order> oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        
        Test.startTest();
        try {
            Order currentOrder = [SELECT Id, Network_Project_Specialist__c,Order_Stage__c,OwnerId, OrderNumber, vlocity_cmt__OrderStatus__c, AccountId FROM Order WHERE Id = :oList[0].Id];
            ftr_XOMSubmitOrderController serv = new ftr_XOMSubmitOrderController();
            serv.sendOrderDetails(currentOrder, new List<String>{'test@mail.com'}); 
        } catch (EXception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
        
    }

    static testMethod void testSubmitToDealDesk() {
        
        List<Quote> oList = ftr_TestDataFactory.getQuotes(1);
        insert oList;
        
        Test.startTest();
        
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('submitForDealDeskApproval', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        
        Test.stopTest();
        
    }
    
    static testMethod void testStageOrder() {
        Order o = ftr_TestDataFactory.getOrders(1)[0];
        o.Order_Stage__c = 'CNP Quality Assurance';
        o.Products__c = 'SIP;EIA';
        insert o;
        
        Test.startTest();
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('stageOrder', new Map<string,object>{'contextId'=>o.Id}, new Map<string,object>(), new Map<string,object>());
        o.put('Order_Stage__c', 'Solutions Engineering');
        update o;
        obj.invokeMethod('stageOrder', new Map<string,object>{'contextId'=>o.Id}, new Map<string,object>(), new Map<string,object>());
        Test.stopTest();
    }
    
    static testMethod void testFloorPriceValidation() {
        
        List<QuoteLineItem> oList = ftr_TestDataFactory.getQLI(1, 1);
        insert oList;
        Quote q = [SELECT Id FROM QUOTE LIMIT 1];
        Test.startTest();
        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        obj.invokeMethod('checkQLI', new Map<string,object>{'contextId'=>q.Id}, new Map<string,object>(), new Map<string,object>());
        QuoteLineItem qli = [SELECT vlocity_cmt__CpqCardinalityMessage__c FROM QuoteLineItem WHERE QuoteId = :q.Id];
        qli.vlocity_cmt__CpqCardinalityMessage__c = 'cannot be test';
        qli.vlocity_cmt__CpqCardinalityMessage__c = 'cannot be test';
        update qli;
        obj.invokeMethod('checkQLI', new Map<string,object>{'contextId'=>q.Id}, new Map<string,object>(), new Map<string,object>());
        obj.invokeMethod('checkQLIAndFSA', new Map<string,object>{'contextId'=>q.Id}, new Map<string,object>(), new Map<string,object>());
        obj.accountHasFSA(new Map<string,object>{'contextId'=>q.Id}, new Map<string,object>(), new Map<string,object>());
        Test.stopTest();
    }
    
    Static testMethod void teststageMFWOrder(){
            Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
       Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        //insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
       // insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'SIP;EIA';
        ObjOrder.Name = 'Test order';
        ObjOrder.Status = 'Draft';
        ObjOrder.order_stage__c ='In Progress';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        lstOrder.add(ObjOrder);
        
        Order ObjOrder2 = new Order();
        ObjOrder2.EffectiveDate = system.today();
        ObjOrder2.EndDate = system.today() + 40;
        ObjOrder2.Pricebook2Id =  standardPb.Id ;
        ObjOrder2.Products__c = 'SIP;EIA';
        ObjOrder2.Name = 'Test order';
        ObjOrder2.Status = 'Draft';
        ObjOrder2.order_stage__c ='Customer Network Provisioning';
        ObjOrder2.OwnerId = ObjGrp.Id;
        ObjOrder2.AccountId = Acc.Id;
        
        lstOrder.add(ObjOrder2);
        //Insert lstOrder;
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController();
        //objCont.stageMFWOrder(lstOrder[0].Id);
        //objCont.stageMFWOrder(lstOrder[1].Id);
        
    }
    Static testMethod void teststageUCFOrderCNF(){
            Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
       Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'UCF';
        ObjOrder.Name = 'Test UCF order';
        ObjOrder.Status = 'Draft';
        ObjOrder.order_stage__c ='Customer Network Provisioning';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        lstOrder.add(ObjOrder);
        Insert lstOrder;
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController();
        objCont.stageUCFOrder(lstOrder[0].Id);
        
    }
    
    Static testMethod void testCreateTask1(){
        Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
       Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'UCF';
        ObjOrder.Name = 'Test UCF order';
        ObjOrder.Status = 'Draft';
        ObjOrder.order_stage__c ='New';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        lstOrder.add(ObjOrder);
        
        /*
        Order ObjOrder2 = new Order();
        ObjOrder2.EffectiveDate = system.today();
        ObjOrder2.EndDate = system.today() + 40;
        ObjOrder2.Pricebook2Id =  standardPb.Id ;
        ObjOrder2.Products__c = 'UCF';
        ObjOrder2.Name = 'Test UCF order 2';
        ObjOrder2.Status = 'Draft';
        ObjOrder2.order_stage__c ='In Progress';
        ObjOrder2.Is_Due_Date_Set__c = true;
        ObjOrder2.OwnerId = ObjGrp.Id;
        ObjOrder2.AccountId = Acc.Id;
        lstOrder.add(ObjOrder2);
        */
        Order ObjOrder3 = new Order();
        ObjOrder3.EffectiveDate = system.today();
        ObjOrder3.EndDate = system.today() + 40;
        ObjOrder3.Pricebook2Id =  standardPb.Id ;
        ObjOrder3.Products__c = 'UCF';
        ObjOrder3.Name = 'Test UCF order 2';
        ObjOrder3.Status = 'Draft';
        ObjOrder3.order_stage__c ='Hot Cuts';
        ObjOrder3.OwnerId = ObjGrp.Id;
        ObjOrder3.AccountId = Acc.Id;
        lstOrder.add(ObjOrder3);
        Insert lstOrder;
        
        for(Order order: lstOrder){
            ftr_XOMSubmitOrderController.createTask(order);
        }
        //ftr_XOMSubmitOrderController.createTask(lstOrder[0]);
    }
    
    Static testMethod void teststageUCFOrderQA(){
        
            Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
       Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'SIP;EIA';
        ObjOrder.Name = 'Test UCF QA order';
        ObjOrder.Status = 'Draft';
        ObjOrder.order_stage__c ='QA Review';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        lstOrder.add(ObjOrder);
        Insert lstOrder;
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController();
        objCont.stageUCFOrder(lstOrder[0].Id);
        
    }
    
    Static testMethod void teststageUCFOrderInP(){
        
            Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
       Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        //insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
       // insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'SIP;EIA';
        ObjOrder.Name = 'Test UCF In Progress order';
        ObjOrder.Status = 'Draft';
        ObjOrder.order_stage__c ='In Progress';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        lstOrder.add(ObjOrder);
        //Insert lstOrder;
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController();
        //objCont.stageUCFOrder(lstOrder[0].Id);
        
    }
    Static TestMethod void TestQueueable(){
         Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc;
        
         Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.name='Test Account';
       Acc.ParentId = globalAcc.Id;
       Acc.RecordTypeId = masterRecId;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        //insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        //insert standardPb;
        
        
        vlocity_cmt__FulfilmentRequestLine__c vlocityFulfill = new vlocity_cmt__FulfilmentRequestLine__c();
        vlocityFulfill.CreatedDate = date.today();
        insert vlocityFulfill;
        vlocity_cmt__OrchestrationItem__c vlocityOrchest = new vlocity_cmt__OrchestrationItem__c();
        vlocityOrchest.name = 'Wait To Start';
        vlocityOrchest.vlocity_cmt__FulfilmentRequestLineId__c =vlocityFulfill.Id;
        vlocityOrchest.CreatedDate = date.today();
        
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'SIP;EIA';
        ObjOrder.Name = 'Test queueable order';
        ObjOrder.Status = 'Draft';
        ObjOrder.order_stage__c ='In Progress';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        //Insert lstOrder;

        //insert vlocityOrchest;
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController();
        System.enqueueJob(new ftr_XOMSubmitOrderController.StartPlanAsync(lstOrder[0].Id));
        
    }
    
    Static TestMethod void TestQueueableNew(){
        
         Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc;
        
       Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId;
        Acc.ParentId = globalAcc.Id;
        Acc.name='Test Account';
        Acc.ParentId = globalAcc.Id;
        Acc.RecordTypeId = masterRecId;
        insert Acc;
        
        vlocity_cmt__Premises__c Prms = new vlocity_cmt__Premises__c();
        Prms.WC_CLLI__c = 'MSTNWIXA';
        //insert Prms;
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        insert ObjGrp;
        
         Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account a = new Account();
        a.RecordTypeId = masterRecId1;
        a.ParentId = globalAcc1.Id;
        a.Name = 'Test Account';
        a.ParentId = globalAcc1.Id;
       a.RecordTypeId = masterRecId1;
        insert a;
        
        Account serviceAccount = new Account();
        serviceAccount.RecordTypeId = masterRecId1;
        serviceAccount.ParentId = globalAcc1.Id;
        serviceAccount.Name = 'Service Account';
        serviceAccount.ShippingStreet = '1480 North Valley Parkway';
        serviceAccount.ShippingCity = 'Lewisville';     
        serviceAccount.ShippingState = 'Texas';
        serviceAccount.ShippingPostalCode = '75077';
        serviceAccount.vlocity_cmt__PremisesId__c= Prms.Id;
        //insert serviceAccount;
        //Test Account 2
        
        
        Product2 p = new Product2();
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode ='ENT_ETH_UNI_PSR_001';
        p.isActive = true;
        //insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice1 = new PricebookEntry();
        standardPrice1.Pricebook2Id = pricebookId;
        standardPrice1.Product2Id = p.Id;
        standardPrice1.UnitPrice = 1;
        standardPrice1.IsActive = true;
        standardPrice1.UseStandardPrice = false;
        //insert standardPrice1 ;
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        //insert standardPb;
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = standardPb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
       // insert standardPrice ;
        
        Order o = new Order();
        o.Name = 'Test Order 04.10.2020 KE';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 10;
        o.AccountId = a.id;
        o.Pricebook2Id =  standardPb.Id ;
        o.Products__c = 'SIP;EIA';
        //insert o;
        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.id;
        //i.Total_Price__c = i.Quantity * i.UnitPrice;
        //insert i;
        //Test OrderItem on second insert
        OrderItem i2 = new OrderItem();
        i2.OrderId = o.id;
        i2.Quantity = 10;
        i2.UnitPrice = 20;
        i2.PricebookEntryId=standardPrice.id;
        i2.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i2.vlocity_cmt__Product2Id__c = p.Id;
        //i2.Total_Price__c = i.Quantity * i.UnitPrice;
        //insert i2;
        
        
        vlocity_cmt__OrchestrationPlan__c vlocityOrchidPlan = new vlocity_cmt__OrchestrationPlan__c();
        vlocityOrchidPlan.vlocity_cmt__OrderId__c = o.Id;
        insert vlocityOrchidPlan;
        vlocity_cmt__FulfilmentRequestLine__c vlocityFulfill = new vlocity_cmt__FulfilmentRequestLine__c();
        vlocityFulfill.vlocity_cmt__Product2Id__c =p.Id;
        vlocityFulfill.CreatedDate = date.today();
        insert vlocityFulfill;
        vlocity_cmt__OrchestrationPlanDefinition__c vlocityplanDefine = new vlocity_cmt__OrchestrationPlanDefinition__c();
        vlocityplanDefine.Name = 'Test';
        insert vlocityplanDefine;
        vlocity_cmt__OrchestrationItemDefinition__c vlocityOrchidItem = new vlocity_cmt__OrchestrationItemDefinition__c();
        vlocityOrchidItem.Name = 'Wait To Start';
        vlocityOrchidItem.vlocity_cmt__OrchestrationPlanDefinitionId__c = vlocityplanDefine.Id;
        insert vlocityOrchidItem;
        vlocity_cmt__OrchestrationItem__c vlocityOrchest = new vlocity_cmt__OrchestrationItem__c();
        vlocityOrchest.name = 'Wait To Start';
        vlocityOrchest.vlocity_cmt__FulfilmentRequestLineId__c =vlocityFulfill.Id;
        vlocityOrchest.vlocity_cmt__OrchestrationItemDefinitionId__c = vlocityOrchidItem.Id;
        vlocityOrchest.vlocity_cmt__State__c = 'Pending';
        vlocityOrchest.CreatedDate = date.today();
        vlocityOrchest.vlocity_cmt__OrchestrationPlanId__c = vlocityOrchidPlan.Id;
        //insert vlocityOrchest;
        
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'SIP;EIA';
        ObjOrder.Name = 'Test queueable order';
        ObjOrder.Status = 'Draft';
        ObjOrder.order_stage__c ='In Progress';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController();
        System.enqueueJob(new ftr_XOMSubmitOrderController.StartPlanAsync(o.Id));
        
    }
    static testMethod void testcreateMFWTaskOnMFWOrder(){
        Map<String, Object> outputMap =new Map<String, Object>();
        Map<String, Object> inputMap =new Map<String, Object>();
        Map<String, Object> options =new Map<String, Object>();
        
          Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
        Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        ObjGrp.Type = 'Queue';
        //ObjGrp.DeveloperName = 'Service_Delivery_PM';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        //insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'SIP;EIA';
        ObjOrder.Name = 'Test UCF In Progress order';
        ObjOrder.Status = 'Draft';
        ObjOrder.order_stage__c ='In Progress';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        ObjOrder.vlocity_cmt__OrderStatus__c= 'In Progress';
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        insert lstOrder;
        inputMap.put('orderId',lstOrder[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ObjOrder);
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController(sc);
        objCont.createMFWTaskOnMFWOrder(inputMap,outputMap,options);   
    }
    
    static testMethod void testperformEmployeInformationValidations(){
        Map<String, Object> outputMap =new Map<String, Object>();
        Map<String, Object> inputMap =new Map<String, Object>();
        Map<String, Object> options =new Map<String, Object>();
        
          Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
        Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        ObjGrp.Type = 'Queue';
        //ObjGrp.DeveloperName = 'Service_Delivery_PM';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        //insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'UCF Call Recording Basic';
        ObjOrder.Name = 'performEmployeInformationValidations';
        ObjOrder.Status = 'Draft';
        ObjOrder.Order_Stage__c ='In Progress';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        ObjOrder.vlocity_cmt__OrderStatus__c= 'In Progress';
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        insert lstOrder;
        inputMap.put('orderId',lstOrder[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ObjOrder);
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController(sc);
        objCont.stageUCFOrder(lstOrder[0].Id);   
    }
    
    static testMethod void testcheckForImplementationSpecialist(){
        Map<String, Object> outputMap =new Map<String, Object>();
        Map<String, Object> inputMap =new Map<String, Object>();
        Map<String, Object> options =new Map<String, Object>();
        
          Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
        Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        ObjGrp.Type = 'Queue';
        //ObjGrp.DeveloperName = 'Service_Delivery_PM';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        //insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'UCF Call Recording Basic';
        ObjOrder.Name = 'performEmployeInformationValidations';
        ObjOrder.Status = 'Draft';
        ObjOrder.Order_Stage__c ='In Progress';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        ObjOrder.vlocity_cmt__OrderStatus__c= 'In Progress';
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        insert lstOrder;
        inputMap.put('orderId',lstOrder[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ObjOrder);
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController(sc);
        objCont.checkForImplementationSpecialist(lstOrder[0].Id);   
    }
    
    static testMethod void testcheckForImplementationSpecialist2(){
        Map<String, Object> outputMap =new Map<String, Object>();
        Map<String, Object> inputMap =new Map<String, Object>();
        Map<String, Object> options =new Map<String, Object>();
        
        //Premises
        vlocity_cmt__Premises__c Prms = new vlocity_cmt__Premises__c();
        Prms.WC_CLLI__c = 'MSTNWIXA';
        insert Prms; 
        
          Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';	
        //Acc.ParentId = globalAcc1.Id;
      // Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        Account serviceAccount = new Account();
         serviceAccount.ParentId = Acc.id;
        serviceAccount.Name = 'Service Account';
        serviceAccount.ShippingStreet = '1480 North Valley Parkway';
        serviceAccount.ShippingCity = 'Lewisville';     
        serviceAccount.ShippingState = 'Texas';
        serviceAccount.ShippingPostalCode = '75077';
        serviceAccount.vlocity_cmt__PremisesId__c= Prms.Id;
      //  insert serviceAccount;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        ObjGrp.Type = 'Queue';
        //ObjGrp.DeveloperName = 'Service_Delivery_PM';
        insert ObjGrp;
        Product2 p = new Product2();
        p.Name = ' Test UCF ';
        p.Description='Test UCF';
        p.productCode = 'TEST_UCF_0001';
        p.isActive = true;
        insert p;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = p.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = standardPb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'UCF Call Recording Basic';
        ObjOrder.Name = 'performEmployeInformationValidations';
        ObjOrder.Status = 'Draft';
        ObjOrder.Order_Stage__c ='New';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        ObjOrder.vlocity_cmt__OrderStatus__c= 'In Progress';
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        
        Order ObjOrder3 = new Order();
        ObjOrder3.EffectiveDate = system.today();
        ObjOrder3.EndDate = system.today() + 40;
        ObjOrder3.Pricebook2Id =  standardPb.Id ;
        ObjOrder3.Products__c = 'UCF';
        ObjOrder3.Name = 'Test UCF order 2';
        ObjOrder3.Status = 'Draft';
        ObjOrder3.order_stage__c ='Hot Cuts';
        ObjOrder.Network_Project_Specialist__c = [SELECT Id FROM User WHERE Email='Cpt.Awesome0@awesomesauce.com' AND Profile.Name = '#Project Manager'].Id;
        ObjOrder3.OwnerId = ObjGrp.Id;
        ObjOrder3.AccountId = Acc.Id;
        lstOrder.add(ObjOrder3);
        
        insert lstOrder;
        inputMap.put('orderId',lstOrder[0].Id);
        
        OrderItem i = new OrderItem();
        i.OrderId = lstOrder[0].Id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.id;
        i.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i.vlocity_cmt__Product2Id__c = p.Id;
        insert i;
        
        OrderItem i2 = new OrderItem();
        i2.OrderId = lstOrder[1].Id;
        i2.Quantity = 24;
        i2.UnitPrice = 240;
        i2.Product2id = p.id;
        i2.PricebookEntryId=standardPrice.id;
        i2.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i2.vlocity_cmt__Product2Id__c = p.Id;
        insert i2;
        
        ftr_DID_Location_Details__c did = new ftr_DID_Location_Details__c(
            OrderId__c = lstOrder[0].Id,
            BTN__c='1234567890'
        );
        insert did;
        
        ftr_DID_Location_Details__c did2 = new ftr_DID_Location_Details__c(
            OrderId__c = lstOrder[1].Id,
            BTN__c='1234567890'
        );
        insert did2;

        ftr_DID_Number_Details__c num = new ftr_DID_Number_Details__c(
            DID_Number__c='1234567890',
            Ucf_License_Type__c = 'UCF Basic',
            Ucf_Collaboration__c='UCF- Collab 200',
            Ucf_Webinar__c='None',
            Ucf_Device_Type__c='UCF Poly Edge 350',
            Ucf_Audio_Mining__c='UCF Audio Mining',
            Ucf_Device_Accessories__c='None	',
            Ucf_Storage__c='UCF Call Recording Basic',
            Ucf_Call_Recording__c='Yes ',
            Ucf_Screen_Recording__c='No ',
            DIDLocationDetailsId__c=did.Id
        );
        insert num;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ObjOrder);
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController(sc);
        objCont.checkForImplementationSpecialist(lstOrder[0].Id);
        objCont.checkForImplementationSpecialist(lstOrder[1].Id);
    }
    
    static testMethod void testcheckImplementationSpecialistForPM(){
        Map<String, Object> outputMap =new Map<String, Object>();
        Map<String, Object> inputMap =new Map<String, Object>();
        Map<String, Object> options =new Map<String, Object>();
        
          Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
        Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        ObjGrp.Type = 'Queue';
        //ObjGrp.DeveloperName = 'Service_Delivery_PM';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        //insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'UCF Call Recording Basic';
        ObjOrder.Name = 'performEmployeInformationValidations';
        ObjOrder.Status = 'Draft';
        ObjOrder.Order_Stage__c ='PM Enrichment';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        ObjOrder.vlocity_cmt__OrderStatus__c= 'In Progress';
        ObjOrder.Network_Project_Specialist__c = [SELECT Id FROM User WHERE Email='Cpt.Awesome0@awesomesauce.com' AND Profile.Name = '#Project Manager'].Id;
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        insert lstOrder;
        inputMap.put('orderId',lstOrder[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ObjOrder);
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController(sc);
        objCont.checkImplementationSpecialistForPM(lstOrder[0].Id);   
    }
    
    static testMethod void testcheckImplementationSpecialistForNT(){
        Map<String, Object> outputMap =new Map<String, Object>();
        Map<String, Object> inputMap =new Map<String, Object>();
        Map<String, Object> options =new Map<String, Object>();
        
          Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
        Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        ObjGrp.Type = 'Queue';
        //ObjGrp.DeveloperName = 'Service_Delivery_PM';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        //insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'UCF Call Recording Basic';
        ObjOrder.Name = 'performEmployeInformationValidations';
        ObjOrder.Status = 'Draft';
        ObjOrder.Order_Stage__c ='In Progress';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        ObjOrder.vlocity_cmt__OrderStatus__c= 'In Progress';
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        insert lstOrder;
        inputMap.put('orderId',lstOrder[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ObjOrder);
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController(sc);
        objCont.checkImplementationSpecialistForNT(lstOrder[0].Id);   
    }
    
    static testMethod void testcheckImplementationSpecialistForNT2(){
        Map<String, Object> outputMap =new Map<String, Object>();
        Map<String, Object> inputMap =new Map<String, Object>();
        Map<String, Object> options =new Map<String, Object>();
        
          Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
        Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        ObjGrp.Type = 'Queue';
        //ObjGrp.DeveloperName = 'Service_Delivery_PM';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        //insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'UCF Call Recording Basic';
        ObjOrder.Name = 'performEmployeInformationValidations';
        ObjOrder.Status = 'Draft';
        ObjOrder.Order_Stage__c ='Network Translations';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        ObjOrder.vlocity_cmt__OrderStatus__c= 'In Progress';
        ObjOrder.Network_Project_Specialist__c = [SELECT Id FROM User WHERE Email='Cpt.Awesome0@awesomesauce.com' AND Profile.Name = '#Project Manager'].Id;
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        insert lstOrder;
        inputMap.put('orderId',lstOrder[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ObjOrder);
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController(sc);
        objCont.checkImplementationSpecialistForNT(lstOrder[0].Id);   
    }
    
    static testMethod void testrejectOrderNetworkTranslations(){
        Map<String, Object> outputMap =new Map<String, Object>();
        Map<String, Object> inputMap =new Map<String, Object>();
        Map<String, Object> options =new Map<String, Object>();
        
          Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
        Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        ObjGrp.Type = 'Queue';
        //ObjGrp.DeveloperName = 'Service_Delivery_PM';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        //insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'UCF Call Recording Basic';
        ObjOrder.Name = 'performEmployeInformationValidations';
        ObjOrder.Status = 'Draft';
        ObjOrder.Order_Stage__c ='Network Translations';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        ObjOrder.vlocity_cmt__OrderStatus__c= 'In Progress';
        ObjOrder.Network_Project_Specialist__c = [SELECT Id FROM User WHERE Email='Cpt.Awesome0@awesomesauce.com' AND Profile.Name = '#Project Manager'].Id;
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        insert lstOrder;
        inputMap.put('orderId',lstOrder[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ObjOrder);
        
        ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController(sc);
        objCont.rejectOrderNetworkTranslations(lstOrder[0].Id); 
    }
    
    static testMethod void testperformPMNetworkTranslationValidations(){
        Map<String, Object> outputMap =new Map<String, Object>();
        Map<String, Object> inputMap =new Map<String, Object>();
        Map<String, Object> options =new Map<String, Object>();
        
          Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
         Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
      
        Account Acc = new Account();
        Acc.RecordTypeId = masterRecId1;
        Acc.ParentId = globalAcc1.Id;
        Acc.name='Test Account';
        Acc.ParentId = globalAcc1.Id;
       Acc.RecordTypeId = masterRecId1;
        insert Acc;
        
        group ObjGrp = new group();
        ObjGrp.name = 'test group';
        ObjGrp.Type = 'Queue';
        //ObjGrp.DeveloperName = 'Service_Delivery_PM';
        insert ObjGrp;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        //insert standardPb;
        
        List<Order> lstOrder = new List<Order>();
        Order ObjOrder = new Order();
        ObjOrder.EffectiveDate = system.today();
        ObjOrder.EndDate = system.today() + 40;
        ObjOrder.Pricebook2Id =  standardPb.Id ;
        ObjOrder.Products__c = 'UCF Call Recording Basic';
        ObjOrder.Name = 'performEmployeInformationValidations';
        ObjOrder.Status = 'Draft';
        ObjOrder.Order_Stage__c ='Network Translations';
        ObjOrder.OwnerId = ObjGrp.Id;
        ObjOrder.AccountId = Acc.Id;
        ObjOrder.vlocity_cmt__OrderStatus__c= 'In Progress';
        ObjOrder.Network_Project_Specialist__c = [SELECT Id FROM User WHERE Email='Cpt.Awesome0@awesomesauce.com' AND Profile.Name = '#Project Manager'].Id;
        //ObjOrder.Network_Project_Specialist__c=UserInfo.getUserId();
        lstOrder.add(ObjOrder);
        insert lstOrder;
        inputMap.put('orderId',lstOrder[0].Id);
        
        Service_Location__c testServiceLocation = new Service_Location__c(
            Location_Name__c = 'Test Location',
            Contact_Email__c = 'test@example.com',
            Contact_Name__c = 'John Doe',
            Contact_Phone__c = '123-456-7890',
            Caller_ID_Name__c = 'Caller Name',
            Shipping_Address__c = 'Shipping Address',
            Shipping_Location__c = 'Different address',
            Street__c = 'Test Street',
            City__c = 'Test City',
            State__c = 'Test State',
            Zip__c = '12345',
            Location_Street__c = 'Location Street',
            Location_City__c = 'Location City',
            Location_State__c = 'Location State',
            Location_Zip__c = '54321',
            Construction_Details__c = 'Construction Details',
            New_Construction__c = 'No',
            Custom_music__c = 'No',
            Main_Phone_Number__c = '987-654-3210',
            Location_Address__c = 'Location Address',
            Time_Zone__c = 'Eastern',
            Business_Group_Name__c = 'Business Group',
            EAS_Pin__c = 123456,
            Order__c = lstOrder[0].Id
        );
        
        ftr_DID_Location_Details__c did = new ftr_DID_Location_Details__c(
            OrderId__c = lstOrder[0].Id,
            BTN__c='1234567890'
        );
        insert did;

        ftr_DID_Number_Details__c num = new ftr_DID_Number_Details__c(
            DID_Number__c='1234567890',
            Ucf_License_Type__c = 'UCF Basic',
            Ucf_Collaboration__c='UCF- Collab 200',
            Ucf_Webinar__c='None',
            Ucf_Device_Type__c='UCF Poly Edge 350',
            Ucf_Audio_Mining__c='UCF Audio Mining',
            Ucf_Device_Accessories__c='None	',
            Ucf_Storage__c='UCF Call Recording Basic',
            Ucf_Call_Recording__c='Yes ',
            Ucf_Screen_Recording__c='No ',
            DIDLocationDetailsId__c=did.Id
        );
        insert num;

        // Insert the test record into the database
        insert testServiceLocation;
        
         // Create a unique UserName
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@org.com';

        // Pick the Profile you want to test under here
        String profileName = '#Solution Engineer Supervisor';
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];

        // Create a User object that uses that Profile
        User u = new User(
            UserName = uniqueUserName,
            ProfileId = p.Id,
            Alias = 'standt',
            Email = 'user@org.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        
         System.runAs(u) {
             ApexPages.StandardController sc = new ApexPages.StandardController(ObjOrder);
        
        	ftr_XOMSubmitOrderController objCont = new ftr_XOMSubmitOrderController(sc);
            objCont.invokeMethod('checkImplementationSpecialistForNT', new Map<string,object>{'contextId'=>lstOrder[0].Id}, new Map<string,object>(), new Map<string,object>());
        }
    }

    static testMethod void testConfirmCompleteOrder2() {
        
        /* List<Group> liObjGrp = new List<Group>();
        Group ObjGrp = new Group();
        ObjGrp.Name = 'Customer Network Provisioning';
        ObjGrp.DeveloperName = 'Customer_Network_Provisioning';
        ObjGrp.Type = 'Queue';
        liObjGrp.add(ObjGrp);
        
        Group ObjGrp2 = new Group();
        ObjGrp2.Name = 'Service DeliveryPM';
        ObjGrp2.DeveloperName = 'Service_Delivery_PM';
        ObjGrp2.Type = 'Queue';
        
        liObjGrp.add(ObjGrp2);
        insert liObjGrp; */


        List<Order> oList = ftr_TestDataFactory.getOrders(11);
        // oList[0].Order_Stage__c = 'New';
        oList[1].Order_Stage__c = 'In Progress';
        oList[2].Order_Stage__c = 'Customer Network Provisioning';
        oList[3].Order_Stage__c = 'MSA Review';
        oList[4].Order_Stage__c = 'Solutions Engineering';
        oList[5].Order_Stage__c = 'Sales Engineering';
        oList[6].Order_Stage__c = 'CNP Quality Assurance';
        oList[7].Order_Stage__c = 'QA Review';
        oList[8].Order_Stage__c = 'Hot Cuts';
        oList[9].Order_Stage__c = 'PM Enrichment';
        oList[10].Order_Stage__c = 'Network Translations';
        
        insert oList;

        
        Test.startTest();
        
        List<ftr_DID_Location_Details__c> locList = new List<ftr_DID_Location_Details__c>();
        //List<Account> accountList = getAccounts(numOflocation);
        // List<Order> orderId = getOrders(numOflocation); 
        for (Integer i = 0; i < 1; i++) {
            locList.add(new ftr_DID_Location_Details__c(Name = 'Rock Island Road, Irving, TX 75060',
                                                        ServiceAccountId__c =oList[0].Account.id,
                                                        DigitsSentToCustomer__c = '05',
                                                        IncomingCallerID__c = 'Number Only',
                                                        InternationalDialing__c = 'No',
                                                        TestNumber__c ='TestNumber__c',
                                                        MDN__c ='3342544615',
                                                        NumberOfDIDs__c=10,
                                                        OrderId__c = oList[0].Id,
                                                        AddressId__c = '9100401',
                                                        LocationId__c = '4855016',
                                                        E911Type__c ='NOMADIC'
                                                       ));
        }
		insert locList;

        ftr_XOMSubmitOrderController obj = new ftr_XOMSubmitOrderController();
        oList[0].Order_Stage__c = 'PM Enrichment';
        update oList[0];
        obj.invokeMethod('checkForImplementationSpecialist', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        obj.invokeMethod('checkImplementationSpecialistForNT', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        obj.invokeMethod('rejectOrderNetworkTranslations', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        obj.invokeMethod('stageMFWOrder', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        obj.invokeMethod('checkForOrderDueDateChange', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        oList[0].Order_Stage__c = 'PM Enrichment';
        update oList[0];
        
        ftr_DID_Location_Details__c did = new ftr_DID_Location_Details__c(
            OrderId__c = oList[0].Id,
            BTN__c='1234567890'
        );
        insert did;

        ftr_DID_Number_Details__c num = new ftr_DID_Number_Details__c(
            DID_Number__c='1234567890',
            Ucf_License_Type__c = 'UCF Basic',
            Ucf_Collaboration__c='UCF- Collab 200',
            Ucf_Webinar__c='None',
            Ucf_Device_Type__c='UCF Poly Edge 350',
            Ucf_Audio_Mining__c='UCF Audio Mining',
            Ucf_Device_Accessories__c='None	',
            Ucf_Storage__c='UCF Call Recording Basic',
            Ucf_Call_Recording__c='Yes ',
            Ucf_Screen_Recording__c='No ',
            DIDLocationDetailsId__c=did.Id
        );
        insert num;
        
        obj.invokeMethod('checkImplementationSpecialistForPM', new Map<string,object>{'contextId'=>oList[0].Id}, new Map<string,object>(), new Map<string,object>());
        Test.stopTest();
        
    }

     static testmethod void testIncrement() {
        Test.startTest();
        ftr_XOMSubmitOrderController.justIncrement();
        Test.stopTest(); 
     }
 }