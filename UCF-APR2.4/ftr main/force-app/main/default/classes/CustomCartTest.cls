/**
* @author Nicole McGuire
* @date 14 Oct 2019
* @group Vlocity Custom Cart Implementation
* @description Test class for logic needed for roll-up/roll-down logic, pricing logic  
*/  
@isTest
public class CustomCartTest {
    @isTest
    static void testData() {
        CustomCart createCustomCart = new CustomCart();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 

        inputMap.put('cartId','0Q01k0000000l2sCAA');
        String methodName = 'putCartsItems.PreInvoke';

        Boolean bResult = createCustomCart.invokeMethod(methodName,inputMap,outputMap,options);
    }
    //     // Create Account
    //     Account testAccount = new Account();
    //     testAccount.Name = 'Test Account';
    //     testAccount.BillingStreet = '123 Main Street';
    //     testAccount.BillingCity = 'Anywhere';
    //     testAccount.BillingState = 'Ohio';
    //     testAccount.BillingPostalCode = '44088';
    //     testAccount.ShippingStreet = '123 Main Street';
    //     testAccount.ShippingCity = 'Anywhere';
    //     testAccount.ShippingState = 'Ohio';
    //     testAccount.ShippingPostalCode = '44088';
    //     insert testAccount;
        
    //     vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
    //     oPremise.vlocity_cmt__Address1__c = '123 Main Street';
    //     oPremise.vlocity_cmt__City__c = 'Anywhere';
    //     oPremise.vlocity_cmt__State__c = 'California';
    //     oPremise.vlocity_cmt__PostalCode__c = '44076';
    //     oPremise.vlocity_cmt__Status__c = 'Connected';
    //     oPremise.DSAT_Ticket__c = '211212';
    //     oPremise.Copper_Tier__c = 'Tier 1';
    //     oPremise.Fiber_Tier__c = 'Tier 1';
    //     oPremise.Last_DSAT_Check__c = system.today();
    //     oPremise.WC_QOS__c = 'Platinum';
    //     oPremise.WC_Speed__c = '1000MB';
    //     oPremise.Market__c = 'B';
    //     oPremise.Level__c = 'a';
	// 	insert oPremise;
        
    //     Account testSAccount = new Account();
    //     testSAccount.Name = 'Test Service Account';
    //     testSAccount.BillingStreet = '123 Main Street';
    //     testSAccount.BillingCity = 'Anywhere';
    //     testSAccount.BillingState = 'Ohio';
    //     testSAccount.BillingPostalCode = '44088';
    //     testSAccount.ShippingStreet = '123 Main Street';
    //     testSAccount.ShippingCity = 'Anywhere';
    //     testSAccount.ShippingState = 'Ohio';
    //     testSAccount.ShippingPostalCode = '44088';
    //     testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
    //     insert testSAccount;
        
    //     Opportunity opp = new Opportunity();
    //     opp.Name = 'RefreshTestOpp';
    //     opp.AccountId = testAccount.id;
    //     Date d1=Date.newInstance(2019, 05, 11);
    //     opp.CloseDate=d1;
    //     opp.StageName='Investigating';
    //     opp.CPE_Product__c='No';
    //     insert opp;
        
    //     id pricebookId = Test.getStandardPricebookId();
    //     List<Product2> lstProduct2 = new List<Product2>();
    //     Product2 product = new Product2();
    //     product.Name = 'EIA';
    //     product.ProductCode = 'ENT_ETH_EIA_0001';
    //     product.IsActive = true;
    //     lstProduct2.add(product);

    //     Product2 prodEVC = new Product2();
    //     prodEVC.Name = 'EVC';
    //     prodEVC.ProductCode = 'ENT_ETH_EVC_0001';
    //     prodEVC.IsActive = true;
    //     lstProduct2.add(prodEVC);
        
    //     Product2 prodAccess = new Product2();
    //     prodAccess.Name = 'Access';
    //     prodAccess.ProductCode = 'ENT_ETH_ACCESS_0001';
    //     prodAccess.IsActive = true;
    //     lstProduct2.add(prodAccess);
	// 	//Insert products
    //     insert lstProduct2;  
        
    //     PricebookEntry standardPrice = new PricebookEntry(
    //         Pricebook2Id = pricebookId, 
    //         Product2Id = lstProduct2[0].Id,
    //         UnitPrice = 100, IsActive = true);
    //     insert standardPrice;
        
    //     Quote oQuote = new Quote();
    //     oQuote.Name = 'Testing Quote';
    //     oQuote.OpportunityId = Opp.id;
    //     oQuote.Pricebook2Id = pricebookId;
    //     insert oQuote;
        
    //     QuoteLineItem oQLI = new QuoteLineItem();
    //     oQLI.QuoteId = oQuote.id;
    //     oQLI.PricebookEntryId = standardPrice.id;
    //     oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
    //     oQLI.Quantity = 1;
    //     oQLI.UnitPrice = 34.50;
    //     oQLI.Term__c = '36 Months';
    //     oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
    //     oQLI.Product2Id = lstProduct2[0].Id;
    //     insert oQLI;
        
    //     oQLI.vlocity_cmt__RootItemId__c = oQLI.id;
    //     update oQLI;
        
    //     QuoteLineItem oQLI2 = new QuoteLineItem();
    //     oQLI2.QuoteId = oQuote.id;
    //     oQLI2.PricebookEntryId = standardPrice.id;
    //     oQLI2.vlocity_cmt__RootItemId__c = oQLI.id;
    //     oQLI2.Speed__c = '20 Mbps';
    //     oQLI2.Quantity = 1;
    //     oQLI2.UnitPrice = 34.50;
    //     oQLI2.vlocity_cmt__ParentItemId__c = oQLI.id;
    //     oQLI2.vlocity_cmt__Product2Id__c = lstProduct2[1].Id;
    //     oQLI2.Product2Id = lstProduct2[1].Id;
    //     insert oQLI2;
        
    //     QuoteLineItem oQLI3 = new QuoteLineItem();
    //     oQLI3.QuoteId = oQuote.id;
    //     oQLI3.PricebookEntryId = standardPrice.id;
    //     oQLI3.Quantity = 1;
    //     oQLI3.UnitPrice = 34.50;
    //     oQLI3.vlocity_cmt__Product2Id__c = lstProduct2[2].Id;
    //     oQLI3.Product2Id = lstProduct2[2].Id;
    //     insert oQLI3;
    // }
    // @isTest
    // static void testPutCartsItems_PreInvoke(){
    //     Map<String, Object> inputMap = new Map<String, Object>();
    //     Map<String, Object> outputMap = new Map<String, Object>();
    //     Map<String, Object> options = new Map<String, Object>(); 

    //     Quote oQuote = [select id from Quote limit 1];
    //     inputMap.put('cartId',oQuote.Id);
    //     String methodName = 'putCartsItems.PreInvoke';
        
    //     CustomCart createCustomCart = new CustomCart();
    //     test.startTest();
    //     Boolean bResult = createCustomCart.invokeMethod(methodName,inputMap,outputMap,options);
    //     test.stopTest();
    //     system.assertEquals(true, bResult, 'Upon invoke expecting true on success.');
    // }
    
    // @isTest
    // static void testPutCartsItems_FalseInvoke(){
    //     Map<String, Object> inputMap = new Map<String, Object>();
    //     Map<String, Object> outputMap = new Map<String, Object>();
    //     Map<String, Object> options = new Map<String, Object>(); 

    //     Quote oQuote = [select id from Quote limit 1];
    //     inputMap.put('cartId',oQuote.Id);
    //     String methodName = 'putCartsItems.FalseInvoke';
        
    //     CustomCart createCustomCart = new CustomCart();
    //     test.startTest();
    //     Boolean bResult = createCustomCart.invokeMethod(methodName,inputMap,outputMap,options);
    //     test.stopTest();
    //     system.assertEquals(false, bResult, 'Upon invoke expecting false on success.');
    // }
    
    // @isTest
    // static void testPutCartsItems_BaseEIA(){
    //     Map<String, Object> inputMap = new Map<String, Object>();
    //     Map<String, Object> outputMap = new Map<String, Object>();
    //     Map<String, Object> options = new Map<String, Object>(); 

    //     Quote oQuote = [select id from Quote limit 1];
    //     inputMap.put('cartId',oQuote.Id);
    //     String methodName = 'putCartsItems.PostInvoke';
        
    //     CustomCart createCustomCart = new CustomCart();
    //     test.startTest();
    //     Boolean bResult = createCustomCart.invokeMethod(methodName,inputMap,outputMap,options);
    //     test.stopTest();
    //     system.assertEquals(true, bResult, 'Upon invoke expecting true on success.');
    // }
    
    // @isTest
    // static void testPutCartsItems_BaseEVPL(){
    //     Map<String, Object> inputMap = new Map<String, Object>();
    //     Map<String, Object> outputMap = new Map<String, Object>();
    //     Map<String, Object> options = new Map<String, Object>(); 

    //     Quote oQuote = [select id from Quote limit 1];
    //     Account testSAccount = [Select id from Account where Name = 'Test Service Account' limit 1];
    //     inputMap.put('cartId',oQuote.Id);
    //     String methodName = 'putCartsItems.PostInvoke';
        
    //     Product2 prodEVC = [Select id from Product2 where Name = 'EVC'];
    //     Product2 product = new Product2();
    //     product.Name = 'EVPL';
    //     product.ProductCode = 'ENT_ETH_EVPL_0001';
    //     product.IsActive = true;
    //     insert product;
        
    //     PricebookEntry standardPrice = [Select id from PricebookEntry];

    //     QuoteLineItem oQLI = new QuoteLineItem();
    //     oQLI.QuoteId = oQuote.id;
    //     oQLI.PricebookEntryId = standardPrice.id;
    //     oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
    //     oQLI.Quantity = 1;
    //     oQLI.UnitPrice = 34.50;
    //     oQLI.Term__c = '36 Months';
    //     oQLI.vlocity_cmt__Product2Id__c = product.Id;
    //     oQLI.Product2Id = product.Id;
    //     insert oQLI;
        
    //     oQLI.vlocity_cmt__RootItemId__c = oQLI.id;
    //     update oQLI;
        
    //     QuoteLineItem oQLI2 = new QuoteLineItem();
    //     oQLI2.QuoteId = oQuote.id;
    //     oQLI2.PricebookEntryId = standardPrice.id;
    //     oQLI2.vlocity_cmt__RootItemId__c = oQLI.id;
    //     oQLI2.Speed__c = '20 Mbps';
    //     oQLI2.Quantity = 1;
    //     oQLI2.UnitPrice = 34.50;
    //     oQLI2.vlocity_cmt__ParentItemId__c = oQLI.id;
    //     oQLI2.vlocity_cmt__Product2Id__c = prodEVC.Id;
    //     oQLI2.Product2Id = prodEVC.Id;
    //     insert oQLI2;
        
    //     CustomCart createCustomCart = new CustomCart();
    //     test.startTest();
    //     Boolean bResult = createCustomCart.invokeMethod(methodName,inputMap,outputMap,options);
    //     test.stopTest();
    //     system.assertEquals(true, bResult, 'Upon invoke expecting true on success.');
    // }

}