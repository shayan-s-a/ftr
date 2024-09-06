/**
 * @description        : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2  
**/ 
@isTest
private class ftr_CPQEnrichmentServiceTest {

    @TestSetup
    static void makeData(){

        Integer numOfOrderItem = 1;
         List<Product2> prodList = new List<Product2>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
         List<OrderItem> orderItemList = new List<OrderItem>();
       
        //test data for Host UNI
        Map<String,String> prodUNIHostMap = new Map<String,String>{
            'User to Network Interface (UNI) Port' => 'ENT_ETH_UNI_0001'
        };
             List<Order> orderList = new List<Order>();
       // orderList = ftr_TestDataFactory.getOrders(1);
       // insert orderList;
                Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
       //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        
        Account accounts = new Account(Name = 'TestAccount'); 
        accounts.RecordTypeId = MasterRTId;
        accounts.ParentId = globalAcc1.Id;
        insert accounts;
        
       orderList.add(new Order(
            Name = 'Test Order',
            AccountId = accounts.Id,
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId(),
            Product__c = 'EIA',
            Product_Type__c = 'Ethernet',
            Router_s__c = 'No Router',
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
        ));
        
        List<OrderItem> ordItemHostUNIList = ftr_TestDataFactory.getOrderItems(numOfOrderItem, prodUNIHostMap);
        ordItemHostUNIList[0].OrderId =orderList[0].id;
      //  insert ordItemHostUNIList;        
        


        //test data for Remote UNI
        List<OrderItem> ordItemRemoteUNIList = ftr_TestDataFactory.getOrderItems(numOfOrderItem, prodUNIHostMap);
        ordItemRemoteUNIList[0].OrderId =orderList[0].id;
       // insert ordItemRemoteUNIList;
        
       

        //test data for EVPL
        Map<String,String> prodEVPLMap = new Map<String,String>{
            'EVPL (Ethernet Virtual Private Line)' => 'ENT_ETH_EVPL_0010'
        };
        List<OrderItem> ordItemEVPLList = ftr_TestDataFactory.getOrderItems(numOfOrderItem, prodEVPLMap);
        ordItemEVPLList[0].OrderId = orderList[0].id;
        ordItemEVPLList[0].UNI_Host__c = ordItemHostUNIList[0].Id;
        ordItemEVPLList[0].UNI_Remote__c = ordItemRemoteUNIList[0].Id;
        //insert ordItemEVPLList;

        // create another uni and link to EVPL as parent
   //     ordItemRemoteUNIList = ftr_TestDataFactory.getOrderItems(numOfOrderItem, prodUNIHostMap);
   
        Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001',
                    'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
    };
        
    prodList.add(new Product2(Name = 'M6 EIA EVC PSR CFS',
                                    ProductCode = 'ENT_ETH_EIA_EVC_PSR_001',
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true));
         pbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prodList[0].Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false));
        
     orderItemList.add(new OrderItem(Product2Id = prodList[0].Id, 
                                            PricebookEntryId = pbeList[0].Id,
                                            vlocity_cmt__Product2Id__c = prodList[0].Id,
                                          //  vlocity_cmt__JSONAttribute__c = jsonAttribute, 
                                            UNI_Host__c = null, 
                                            UNI_Remote__c = null,
                                            VLAN_Tag_Config__c = '',
                                            Quantity = 1,
                                            UnitPrice = 0.00)); 
        
        ordItemRemoteUNIList[0].OrderId =orderList[0].id;
        ordItemRemoteUNIList[0].ftr_ParentItemId__c =ordItemEVPLList[0].id;
       // insert ordItemRemoteUNIList;

        Map<String,String> prodDIAMap = new Map<String,String>{
            'DIA (Dedicated Internet Access)' => 'ENT_ETH_EIA_0002'
        };
        List<OrderItem> ordItemDIAList = ftr_TestDataFactory.getOrderItems(numOfOrderItem, prodDIAMap);
        ordItemDIAList[0].OrderId = orderList[0].id;
        ordItemDIAList[0].ftr_PromoCode__c = 'EIAPromo';
		//insert ordItemDIAList;
    }

    @isTest 
    static void updateVlanTagConfigTest() {
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

       // List<OrderItem> ordItem = [SELECT Id, OrderId, vlocity_cmt__JSONAttribute__c,VLAN_Tag_Config__c, vlocity_cmt__Product2Id__r.ProductCode
         //                           FROM OrderItem];
      List<OrderItem> ordItem = new List<OrderItem>();  
          List<Product2> prodList = new List<Product2>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
         List<OrderItem> orderItemList = new List<OrderItem>();
       
        
         Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001',
                    'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
    };
        
    prodList.add(new Product2(Name = 'M6 EIA EVC PSR CFS',
                                    ProductCode = 'ENT_ETH_EIA_EVC_PSR_001',
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true));
         pbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prodList[0].Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false));
        
     ordItem.add(new OrderItem(Product2Id = prodList[0].Id, 
                                            PricebookEntryId = pbeList[0].Id,
                                            vlocity_cmt__Product2Id__c = prodList[0].Id,
                                          //  vlocity_cmt__JSONAttribute__c = jsonAttribute, 
                                            UNI_Host__c = null, 
                                            UNI_Remote__c = null,
                                            VLAN_Tag_Config__c = '',
                                            Quantity = 1,
                                            UnitPrice = 0.00)); 
        
        inputMap.put('orderId', ordItem[0].OrderId);

        ftr_CPQEnrichmentService enrichServ = new ftr_CPQEnrichmentService();
        Test.startTest();
        enrichServ.invokeMethod('updateVlanTagConfig', inputMap, outputMap, options);
        Test.stopTest();
    }
@isTest 
    static void updateSECNCITest() {
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

      //  List<OrderItem> ordItem = [SELECT Id, OrderId, vlocity_cmt__JSONAttribute__c,VLAN_Tag_Config__c, vlocity_cmt__Product2Id__r.ProductCode
        //                            FROM OrderItem];
      List<OrderItem> ordItem = new List<OrderItem>();  
          List<Product2> prodList = new List<Product2>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
         List<OrderItem> orderItemList = new List<OrderItem>();
       
        
         Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001',
                    'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
    };
        
    prodList.add(new Product2(Name = 'M6 EIA EVC PSR CFS',
                                    ProductCode = 'ENT_ETH_EIA_EVC_PSR_001',
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true));
         pbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prodList[0].Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false));
        
     ordItem.add(new OrderItem(Product2Id = prodList[0].Id, 
                                            PricebookEntryId = pbeList[0].Id,
                                            vlocity_cmt__Product2Id__c = prodList[0].Id,
                                          //  vlocity_cmt__JSONAttribute__c = jsonAttribute, 
                                            UNI_Host__c = null, 
                                            UNI_Remote__c = null,
                                            VLAN_Tag_Config__c = '',
                                            Quantity = 1,
                                            UnitPrice = 0.00)); 
        inputMap.put('orderId', ordItem[0].OrderId);

        ftr_CPQEnrichmentService enrichServ = new ftr_CPQEnrichmentService();
        Test.startTest();
        enrichServ.invokeMethod('updateSECNCI', inputMap, outputMap, options);
        Test.stopTest();
    }
    @isTest 
    static void rollupUNIBitRateTest() {
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
		List<Object> DIAList = new List<Object>();
        Map<String,Object> DIAMap = new Map<String,Object>{
            'UNILocationId'=>''
        };
        DIAList.add(DIAMap);
        Map<String,Object> InputDIAMap = new Map<String,Object>{
            'DIA'=>DIAList
        };
       // List<OrderItem> ordItem = [SELECT Id, OrderId, vlocity_cmt__JSONAttribute__c,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.ProductCode, Product2.ProductCode, UNI_Host__c, UNI_Remote__c
         //                           FROM OrderItem];
       
         List<OrderItem> ordItem = new List<OrderItem>();  
          List<Product2> prodList = new List<Product2>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
         List<OrderItem> orderItemList = new List<OrderItem>();
       
        
         Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001',
                    'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
    };
        
    prodList.add(new Product2(Name = 'M6 EIA EVC PSR CFS',
                                    ProductCode = 'ENT_ETH_EIA_EVC_PSR_001',
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true));
         pbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prodList[0].Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false));
        
     ordItem.add(new OrderItem(Product2Id = prodList[0].Id, 
                                            PricebookEntryId = pbeList[0].Id,
                                            vlocity_cmt__Product2Id__c = prodList[0].Id,
                                          //  vlocity_cmt__JSONAttribute__c = jsonAttribute, 
                                            UNI_Host__c = null, 
                                            UNI_Remote__c = null,
                                            VLAN_Tag_Config__c = '',
                                            Quantity = 1,
                                            UnitPrice = 0.00)); 
        
        
       
        inputMap.put('orderId', ordItem[0].OrderId);
		inputMap.put('DIAUNIAssoc', InputDIAMap);
        ftr_CPQEnrichmentService enrichServ = new ftr_CPQEnrichmentService();
        Test.startTest();
        enrichServ.invokeMethod('rollupUNIBitRate', inputMap, outputMap, options);
        enrichServ.invokeMethod('updateEIAOverSDWAN', inputMap, outputMap, options);
        enrichServ.invokeMethod('updateUNIHBE', inputMap, outputMap, options);
        Test.stopTest();
    }
	
    @isTest 
    static void updateAttributesByServiceAccountTest() {

       // List<OrderItem> ordItem = [SELECT Id, OrderId, vlocity_cmt__JSONAttribute__c,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__ServiceAccountId__c, Product2.ProductCode, UNI_Host__c, UNI_Remote__c
         //                           FROM OrderItem];
             List<OrderItem> ordItem = new List<OrderItem>();  
          List<Product2> prodList = new List<Product2>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
         List<OrderItem> orderItemList = new List<OrderItem>();
       
        
         Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001',
                    'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
    };
        
    prodList.add(new Product2(Name = 'M6 EIA EVC PSR CFS',
                                    ProductCode = 'ENT_ETH_EIA_EVC_PSR_001',
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true));
         pbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prodList[0].Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false));
        
     ordItem.add(new OrderItem(Product2Id = prodList[0].Id, 
                                            PricebookEntryId = pbeList[0].Id,
                                            vlocity_cmt__Product2Id__c = prodList[0].Id,
                                          //  vlocity_cmt__JSONAttribute__c = jsonAttribute, 
                                            UNI_Host__c = null, 
                                            UNI_Remote__c = null,
                                            VLAN_Tag_Config__c = '',
                                            Quantity = 1,
                                            UnitPrice = 0.00)); 
        String orderId = ordItem[0].OrderId;
        String eiaProductCode = 'ENT_ETH_EIA_0002';
        String serviceAccountId = ordItem[0].vlocity_cmt__ServiceAccountId__c;
        Map<String, Object> attributesToUpdate = new Map<String, Object> {
            'ATTR_DSAT_ID' => 'VALUE1',
            'ATTR_TECH_CE_VLAN_ID' => 'VALUE2'
            //'ATTR_DIA_OVER_SDWAN'=>'true'
        };
        Map<String, Object> tempMap = new Map<String, Object> {
            'attributesToUpdate' => attributesToUpdate,
            'ServiceAccountId' => serviceAccountId
        };
        List<Map<String, Object>> reqList = new List<Map<String, Object>> { tempMap };
        ftr_CPQEnrichmentService service = new ftr_CPQEnrichmentService();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object> { 
            'input' => new Map<string, object> {
            	'OrderId' => orderId,
            	'ProductCode' => eiaProductCode,
            	'request' => reqList
            }
        };        

        Test.startTest();
        service.invokeMethod('updateAttributesByServiceAccount', inputMap, outputMap, options);
        Test.stopTest();
    }
    
    @isTest 
    static void updateAttributesByServiceAccountErrorTest() {

       // List<OrderItem> ordItem = [SELECT Id, OrderId, vlocity_cmt__JSONAttribute__c,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__ServiceAccountId__c, Product2.ProductCode, UNI_Host__c, UNI_Remote__c
         //                           FROM OrderItem];
               List<OrderItem> ordItem = new List<OrderItem>();  
          List<Product2> prodList = new List<Product2>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
         List<OrderItem> orderItemList = new List<OrderItem>();
       
        
         Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001',
                    'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
    };
        
    prodList.add(new Product2(Name = 'M6 EIA EVC PSR CFS',
                                    ProductCode = 'ENT_ETH_EIA_EVC_PSR_001',
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true));
         pbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prodList[0].Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false));
        
     ordItem.add(new OrderItem(Product2Id = prodList[0].Id, 
                                            PricebookEntryId = pbeList[0].Id,
                                            vlocity_cmt__Product2Id__c = prodList[0].Id,
                                          //  vlocity_cmt__JSONAttribute__c = jsonAttribute, 
                                            UNI_Host__c = null, 
                                            UNI_Remote__c = null,
                                            VLAN_Tag_Config__c = '',
                                            Quantity = 1,
                                            UnitPrice = 0.00)); 
       
        String orderId = ordItem[0].OrderId;
        String eiaProductCode = 'ENT_ETH_EIA_0002';
        String serviceAccountId = ordItem[0].vlocity_cmt__ServiceAccountId__c;
        Map<String, Object> attributesToUpdate = new Map<String, Object> {
            'ATTR_DSAT_ID' => 'VALUE1',
            'ATTR_TECH_CE_VLAN_ID' => 'VALUE2'
            //'ATTR_DIA_OVER_SDWAN'=>'true'
        };
        Map<String, Object> tempMap = new Map<String, Object> {
            'attributesToUpdate' => attributesToUpdate,
            'ServiceAccountId' => serviceAccountId
        };
        List<Map<String, Object>> reqList = new List<Map<String, Object>> { tempMap };
        ftr_CPQEnrichmentService service = new ftr_CPQEnrichmentService();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object> { 
            'input' => new Map<string, object> {
            	'OrderId' => orderId,
            	'orderId' => orderId,
            	'ProductCode' => eiaProductCode,
            	'request' => 'Error Scenarior'
            }
        };        

        Test.startTest();
        service.invokeMethod('updateAttributesByServiceAccount', inputMap, outputMap, options);
        service.invokeMethod('updateSIPUNIAttributes', inputMap, outputMap, options);
        Test.stopTest();
    }
    
    @isTest 
    static void rollupUNIBitRateErrorTest() {
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
         List<Product2> prodList = new List<Product2>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
         List<OrderItem> orderItemList = new List<OrderItem>();
       
		List<Object> DIAList = new List<Object>();
        Map<String,Object> DIAMap = new Map<String,Object>{
            'UNILocationId'=>null
        };
        DIAList.add(DIAMap);
        Map<String,Object> InputDIAMap = new Map<String,Object>{
            'DIA'=>'Error'
        };
            
       // List<OrderItem> ordItem = [SELECT Id, OrderId, vlocity_cmt__JSONAttribute__c,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.ProductCode, Product2.ProductCode, UNI_Host__c, UNI_Remote__c
                       //             FROM OrderItem];
       
       
        List<OrderItem> ordItem = new List<OrderItem>();  
         Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001',
                    'M6 EIA EVC PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
    };
        
    prodList.add(new Product2(Name = 'M6 EIA EVC PSR CFS',
                                    ProductCode = 'ENT_ETH_EIA_EVC_PSR_001',
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true));
         pbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prodList[0].Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false));
        
     ordItem.add(new OrderItem(Product2Id = prodList[0].Id, 
                                            PricebookEntryId = pbeList[0].Id,
                                            vlocity_cmt__Product2Id__c = prodList[0].Id,
                                          //  vlocity_cmt__JSONAttribute__c = jsonAttribute, 
                                            UNI_Host__c = null, 
                                            UNI_Remote__c = null,
                                            VLAN_Tag_Config__c = '',
                                            Quantity = 1,
                                            UnitPrice = 0.00)); 
        
       
        inputMap.put('orderId', ordItem[0].OrderId);
		inputMap.put('DIAUNIAssoc', InputDIAMap);
        ftr_CPQEnrichmentService enrichServ = new ftr_CPQEnrichmentService();
        Test.startTest();
        enrichServ.invokeMethod('rollupUNIBitRate', inputMap, outputMap, options);
        enrichServ.invokeMethod('updateEIAOverSDWAN', inputMap, outputMap, options);
        Test.stopTest();
    }
	    
}