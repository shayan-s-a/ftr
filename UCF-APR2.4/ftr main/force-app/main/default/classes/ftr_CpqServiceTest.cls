/**
 * @description        : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3 
**/
@isTest
private class ftr_CpqServiceTest {

    @testSetup static void setup() {
        Pricebook2 priceBook = new Pricebook2(Name = 'test');
        insert priceBook;

        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Test1', ProductCode = 'PR_SHIPPING_RATE'));
        products.add(new Product2(Name = 'Test2', ProductCode = 'PR_MOBILE_911'));
        products.add(new Product2(Name = 'Test3', ProductCode = 'PR_LICENSE_RC', vlocity_cmt__type__c = 'Licenses', vlocity_cmt__SubType__c = 'RingCentral'));
        products.add(new Product2(Name = 'Test4', ProductCode = 'PR_DEVICE_RC', vlocity_cmt__type__c = 'Phones', vlocity_cmt__SubType__c = 'RingCentral'));
        products.add(new Product2(Name = 'Test5', ProductCode = 'RC_IMPLEMENTATION_PER_ACCOUNT_PREMIUM'));
        products.add(new Product2(Name = 'Test6', ProductCode = 'RC_IMPLEMENTATION_PER_ACCOUNT_BASIC'));
        products.add(new Product2(Name = 'Test7', ProductCode = 'RC_IMPLEMENTATION_PER_ACCOUNT_STANDARD'));
        products.add(new Product2(Name = 'Test8', ProductCode = 'RC_IMPLEMENTATION_PER_ACCOUNT_ESSENTIAL'));
        for (Product2 p : products){
            p.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';    
        }
        insert products;

        Id RecordTypeIdAccountGlobal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id RecordTypeIdAccountCarrierService = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Carrier Service').getRecordTypeId();
        Account accountGlobal = new Account();
        accountGlobal.Name = 'Global';
        accountGlobal.RecordTypeId = RecordTypeIdAccountGlobal;
        insert accountGlobal;

        Account account = new Account();
        account.Name = 'Carrier Service';
        account.RecordTypeId = RecordTypeIdAccountCarrierService;
        account.ParentId = accountGlobal.id;
        insert account;

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test';
        opportunity.AccountId = account.id;
        opportunity.StageName = 'Prospecting';
        opportunity.CloseDate = Date.today();
        insert opportunity;

        Quote quote = new Quote();
        quote.name = 'Test';
        quote.OpportunityId = opportunity.id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        insert quote;

        List<PricebookEntry> entries = new List<PricebookEntry>();
        for(Product2 prod : products){
            entries.add(new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 0, IsActive = true));
        }
        insert entries;

        List<QuoteLineItem> qlis = new List<QuoteLineItem>();
        for(Product2 prod : products){
            qlis.add(new QuoteLineItem(Product2Id = prod.Id,vlocity_cmt__Product2Id__c =prod.Id, Quantity = 1,vlocity_cmt__EffectiveQuantity__c=1,vlocity_cmt__OneTimeCharge__c=1,vlocity_cmt__RecurringCharge__c=1, QuoteId = quote.id, PricebookEntryId = entries[0].id, UnitPrice = 0));
        }
        insert qlis;
    }

    @isTest  
    static void getAndUpdateXLIAttributes_Test() {
        ftr_CpqService service = new ftr_CpqService();
        List<QuoteLineItem> qLIs = ftr_TestDataFactory.getQLI(1, 1);

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_JSONAttribute_Access' LIMIT 1];
        qLIs[0].vlocity_cmt__JSONAttribute__c = sr.body.toString();
        insert qLIs;

        Map<String, Object> input = new Map<String, Object> {
            'itemId' => qLIs[0].Id,
            'codes' => 'ATTR_BANDWIDTH'
        };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        service.invokeMethod('getXLIAttributes', input, output, options);
        system.debug(output);
        System.assertNotEquals(null, output.get('attributes'));

        input = new Map<String, Object> {
            'items' => new List<Object> {
                new Map<String, Object> {
                    'Id' => qLIs[0].Id,
                    'Attributes' => new List<Object> {
                        new Map<String, Object> {
                        	'AttributeCode' => 'ATTR_BANDWIDTH',
                            'Value' => '50 Mbps'
                    	}    
                    } 
                }
            }
        };
        service.invokeMethod('updateXLIAttributes', input, output, options);

    }
    
    @isTest  
    static void PricingPlan_PreInvoke_Test() {
        ftr_CpqService service = new ftr_CpqService();
        List<Quote> quotes = ftr_TestDataFactory.getQuotes(1);
        Quote testQuote = quotes[0];
        
        service.PricingPlan_PreInvoke(null, testQuote, new List<SObject> {});
    }

    @isTest  
    static void PutCartsItems_PreInvoke_Test() {
        ftr_CpqService service = new ftr_CpqService();

        // JSON for updating EVPL EVC speed
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q1_API_putCartsItems_Req' LIMIT 1];
        String body = sr.Body.toString();

        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(body);
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        service.PutCartsItems_PreInvoke(input, output, options);
        
        System.debug(ftr_CpqCartCtx.peekMessage('prepareDSATAttrSync'));
        System.debug(ftr_CpqCartCtx.peekMessage('prepareSpeedRollup'));

        // JSON for updating EIA's speed
        sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q1_API_putCartsItems_Req2' LIMIT 1];
        body = sr.Body.toString();

        input = (Map<String, Object>)JSON.deserializeUntyped(body);
        output = new Map<String, Object>();
        options = new Map<String, Object>();

        service = new ftr_CpqService();
        
        service.PutCartsItems_PreInvoke(input, output, options);
        
        System.debug(ftr_CpqCartCtx.peekMessage('prepareDSATAttrSync'));
        System.debug(ftr_CpqCartCtx.peekMessage('prepareSpeedRollup'));

        System.assertNotEquals(null, ftr_CpqCartCtx.peekMessage('prepareDSATAttrSync'));
        System.assertNotEquals(null, ftr_CpqCartCtx.peekMessage('prepareSpeedRollup'));
    }

    @isTest  
    static void PutCartsItems_PostInvoke_Test() {//eh
        Quote quote = [SELECT id FROM Quote WHERE name = 'Test' LIMIT 1];
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        input.put('cartId', quote.id);

        ftr_CpqService service = new ftr_CpqService();
        Boolean serviceInvoked = service.PutCartsItems_PostInvoke(input, output, options);
        System.assertEquals(true, serviceInvoked);
    }
    
    @isTest
    static void DeleteCartsItems_PreInvoke_Test(){
        StaticResource sr1 = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q2_LineItems' LIMIT 1];
        StaticResource sr2 = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q2_API_deleteCartsItems_Req' LIMIT 1];
        StaticResource sr3 = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q2_API_deleteCartsItems_Req2' LIMIT 1];

        ftr_CpqService service = new ftr_CpqService();

        List<QuoteLineItem> qLIs = (List<QuoteLineItem>)JSON.deserialize(sr1.body.toString(), List<QuoteLineItem>.class);
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(sr2.body.toString());
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        service.DeleteCartsItems_PreInvoke(input, output, options, qLIs);
        
        input = (Map<String, Object>)JSON.deserializeUntyped(sr3.body.toString());
        output = new Map<String, Object>();
        options = new Map<String, Object>();
       // service.DeleteCartsItems_PreInvoke(input, output, options);
        service.DeleteCartsItems_PreInvoke(input, output, options, qLIs);

        // service.DeleteCartsItems_PreInvoke(input, output, options);
    }

    @isTest
    static void DeleteCartsItems_PostInvoke_Test(){//eh
        Quote quote = [SELECT id FROM Quote WHERE name = 'Test' LIMIT 1];
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        input.put('cartId', quote.id);

        ftr_CpqService service = new ftr_CpqService();
        Boolean serviceInvoked = service.DeleteCartsItems_PostInvoke(input, output, options);
        System.assertEquals(true, serviceInvoked);
    }

      @isTest
    static void CloneCartsItems_PreInvoke_Test(){
        StaticResource sr1 = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q2_LineItems' LIMIT 1];
        StaticResource sr2 = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q2_API_deleteCartsItems_Req' LIMIT 1];
        StaticResource sr3 = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q2_API_deleteCartsItems_Req2' LIMIT 1];

        ftr_CpqService service = new ftr_CpqService();
       
         Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(sr2.body.toString());

        Map<String, Object> output = new Map<String, Object>();
        
        Map<String, Object> options = new Map<String, Object>();

        service.CloneCartsItems_PreInvoke(input, output, options);
       
    }
    
    @isTest
    static void PostCartsItems_PreInvoke_Test(){
        ftr_CpqService service = new ftr_CpqService();

        QuoteLineItem[] qLIs = ftr_TestDataFactory.getQLI(3, 1);
        Map<String, Object> input = new Map<String, Object>{
            'cartId' => qLIs[0].QuoteId,
            'items' => new List<Map<String, Object>>{
                new Map<String,Object> { 
                    'attributesToUpdate' => new Map<String,Object> {
                        'ATTR_BANDWIDTH' => '100 Mbps'
                    }
                }
            }
        };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Boolean result = service.PostCartsItems_PreInvoke(input, output, options);
       	System.assertEquals(true, result);
        
    }

    @isTest
    static void PostCartsItems_PostInvoke_Test(){//eh

        Quote quote = [SELECT id FROM Quote WHERE name = 'Test' LIMIT 1];
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        input.put('cartId', quote.id);

        ftr_CpqService service = new ftr_CpqService();
        Boolean result = service.PostCartsItems_PostInvoke(input, output, options);
       	System.assertEquals(true, result);
        
    }
    /*	@isTest
    static void PostCartsItems_PreInvoke_Test1(){
    ftr_CpqService service = new ftr_CpqService();

    // JSON for updating EVPL EVC speed
    StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q1_API_putCartsItems_Req' LIMIT 1];
    String body = sr.Body.toString();

    Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(body);
    Map<String, Object> output = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    
    //service.PostCartsItems_PreInvoke(input, output, options);
    
    System.debug(ftr_CpqCartCtx.peekMessage('prepareDSATAttrSync'));
    System.debug(ftr_CpqCartCtx.peekMessage('prepareSpeedRollup'));

    // JSON for updating EIA's speed
    sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q1_API_putCartsItems_Req2' LIMIT 1];
    body = sr.Body.toString();

    input = (Map<String, Object>)JSON.deserializeUntyped(body);
    output = new Map<String, Object>();
    options = new Map<String, Object>();

    service = new ftr_CpqService();
    
    //service.PostCartsItems_PreInvoke(input, output, options);
    
    System.debug(ftr_CpqCartCtx.peekMessage('prepareDSATAttrSync'));
    System.debug(ftr_CpqCartCtx.peekMessage('prepareSpeedRollup'));

    System.assertEquals(null, ftr_CpqCartCtx.peekMessage('prepareDSATAttrSync'));
    System.assertEquals(null, ftr_CpqCartCtx.peekMessage('prepareSpeedRollup'));
} */
@isTest
    static void updateXLIAttributes_Test1(){
        ftr_CpqService service = new ftr_CpqService();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Boolean result = service.updateXLIAttributes(input, output, options);
        System.assertEquals(false, result);
        
    }
    @isTest
    static void getXLIAttributes_Test2(){
        ftr_CpqService service = new ftr_CpqService();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Boolean result = service.getXLIAttributes(input, output, options);
        System.assertEquals(false, result);
        
    } 
 /*   @isTest
    static void CloneCartsItems_PreInvoke_Test(){
        ftr_CpqService service = new ftr_CpqService();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Boolean result = service.CloneCartsItems_PreInvoke(input, output, options);
        System.assertEquals(true, result);
        
    }*/
    @isTest
    static void invokeCpqAppHandlerMethod_Test(){
//        ftr_CpqService service = new ftr_CpqService();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        ftr_CpqService.invokeCpqAppHandlerMethod('',input, output, options);  
       // System.assertEquals(false, result);
        
    } 
    @isTest
    
    static void GetCartsItems_PreInvoke_Test(){
      ftr_CpqService service = new ftr_CpqService();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Boolean result = service.GetCartsItems_PreInvoke(input, output, options);
        System.assertEquals(true, result);   
        
    }
   
}