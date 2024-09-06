/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 5
**/

/**
 * THIS CLASS NEEDS TO BE REFACTORED. WHY ARE WE COPY PASTING all the data into each method? 
 */
@isTest
private class ftr_QuoteServiceTest {

    @TestSetup
    static void makeData(){
        Integer numOfQLIforEachQuote = 2;
        Integer numOfQuote = 1;
        /*sravani changes start*/
        test.startTest();
        List<QuoteLineItem> qlis = ftr_TestDataFactory.getQLI(numOfQLIforEachQuote, numOfQuote);
        insert qlis;
        test.stopTest();
        /*sravani changes end*/
        Order[] orders = ftr_TestDataFactory.getOrders(1);
        //insert orders;
        OrderItem[] oLIs = ftr_TestDataFactory.getOrderItems(2, new Map<String, String> {'EVPL (Ethernet Virtual Private Line)' => 'ENT_ETH_EVPL_0010'});
        for (OrderItem oi : oLIs) {
            oi.OrderId = orders[0].Id;
        }   
    //  insert oLIs;
        // List<ProcessInstanceWorkItem> piWi = ftr_TestDataFactory.getProcessInstanceWorkItem();
        // insert piWi;

        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'Network Access' => 'ENT_ETH_ACCESS_0001'
        };
        Integer numOfProdForEachProdCode = 1;
        List<PricebookEntry> pbeList = ftr_TestDataFactory.getProductswithPbe(prodNameCodeMap, numOfProdForEachProdCode);
        insert pbeList;

    }

    @isTest  
    static void setProductFieldOnQuoteTest() {
        

        ftr_QuoteService service = new ftr_QuoteService();

        test.startTest();
        service.setProductsFieldOnQuote(new Map<Id,Quote>([
            SELECT Id FROM Quote
        ]), true);
        test.stopTest();

        // System.assertEquals(1, result.get('AccessIds').size());
        // System.assertEquals(1, result.get('EvplIds').size());
    }

    @isTest  
    static void setProductFieldOnOrderTest() {
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
        
        Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Master' LIMIT 1]?.Id;
        Account a1 = new Account();
        a1.Name = 'Test Account 1';
        a1.RecordTypeId = masterRecId;
        a1.ParentId = globalAcc.Id;
        insert a1;
        
        Product2 p = new Product2();
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode = 'ENT_ETH_EIA_0002';
        p.isActive = true;
        insert p;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
     

        Order o = new Order();
        o.Name = 'Test Order 04.10.2020 KE';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 10;
        o.AccountId = a1.id;
        o.Pricebook2Id =  standardPb.Id ;

        ftr_QuoteService service = new ftr_QuoteService();
         
        test.startTest();
        service.invokeMethod('setProductsFieldOnOrder', new Map<String,Object>{
            //'OrderId' => [SELECT Id FROM Order LIMIT 1].Id
            'OrderId' => o.id
        }, new Map<String,Object>(), new Map<String, Object>());
        test.stopTest();

        // System.assertEquals(1, result.get('AccessIds').size());
        // System.assertEquals(1, result.get('EvplIds').size());
    }

    @isTest  
    static void updateAttributeFromFieldTest() {
                Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
        
        Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Master' LIMIT 1]?.Id;
        Account a1 = new Account();
        a1.Name = 'Test Account 1';
        a1.RecordTypeId = masterRecId;
        a1.ParentId = globalAcc.Id;
        insert a1;
        
        Product2 p = new Product2();
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode = 'ENT_ETH_EIA_0002';
        p.isActive = true;
        insert p;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
     

        Order o = new Order();
        o.Name = 'Test Order 04.10.2020 KE';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 10;
        o.AccountId = a1.id;
        o.Pricebook2Id =  standardPb.Id ;

        ftr_QuoteService service = new ftr_QuoteService();

        test.startTest();
        service.invokeMethod('updateAttributeFromField', new Map<String,Object>{
            //'ContextId' => [SELECT Id FROM Order LIMIT 1].Id
            'ContextId' => o.id
        }, new Map<String,Object>(), new Map<String, Object>());
        test.stopTest();

        // System.assertEquals(1, result.get('AccessIds').size());
        // System.assertEquals(1, result.get('EvplIds').size());
    }

    @isTest  
    static void getSpeedRollupQLIsOnDeletePrevInvoke_Test() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q1_LineItems' LIMIT 1];
        String body = sr.Body.toString();
        QuoteLineItem[] qLIs = (List<QuoteLineItem>)JSON.deserialize(body, List<QuoteLineItem>.class);
    List<QuoteLineItem> qlieia = [select id,vlocity_cmt__LineNumber__c,vlocity_cmt__ServiceAccountId__c,PricebookEntry.Id,PricebookEntryId,PricebookEntry.Product2.ProductCode,QuoteId,Product2.ProductCode from QuoteLineItem where Product2.ProductCode =: 'ENT_ETH_EIA_0002' ];
        ftr_QuoteService service = new ftr_QuoteService();

        test.startTest();
        // Delete EVPL EVC
        Map<String, List<Id>> result = service.getSpeedRollupQLIsOnDeletePrevInvoke(qlieia[0].id, qlieia[0].id, qlieia);
        test.stopTest();

        // System.assertEquals(1, result.get('AccessIds').size());
        // System.assertEquals(1, result.get('EvplIds').size());
    }

 @isTest  
    static void getSpeedRollupQLIsOnDeletePrevInvoke_Test1() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q1_LineItems' LIMIT 1];
        String body = sr.Body.toString();
        QuoteLineItem[] qLIs = (List<QuoteLineItem>)JSON.deserialize(body, List<QuoteLineItem>.class);
    List<QuoteLineItem> qlieia = [select id,vlocity_cmt__LineNumber__c,vlocity_cmt__ServiceAccountId__c,PricebookEntry.Id,PricebookEntryId,PricebookEntry.Product2.ProductCode,QuoteId,Product2.ProductCode from QuoteLineItem where Product2.ProductCode =: 'ENT_ETH_EVPL_0010' ];
        ftr_QuoteService service = new ftr_QuoteService();

        test.startTest();
        // Delete EVPL EVC
        if(qlieia.size() > 0){
        Map<String, List<Id>> result = service.getSpeedRollupQLIsOnDeletePrevInvoke(qlieia[0].id, qlieia[0].id, qlieia);
            }
        test.stopTest();

        // System.assertEquals(1, result.get('AccessIds').size());
        // System.assertEquals(1, result.get('EvplIds').size());
    }
    @isTest  
    static void getSpeedRollupQLIsOnDeletePrevInvoke_Test2() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q1_LineItems' LIMIT 1];
        String body = sr.Body.toString();
        QuoteLineItem[] qLIs = (List<QuoteLineItem>)JSON.deserialize(body, List<QuoteLineItem>.class);
    List<QuoteLineItem> qlieia = [select id,vlocity_cmt__LineNumber__c,vlocity_cmt__ServiceAccountId__c,PricebookEntry.Id,PricebookEntryId,PricebookEntry.Product2.ProductCode,QuoteId,Product2.ProductCode from QuoteLineItem where Product2.ProductCode =: 'ENT_ETH_EVPL_0002' ];
        ftr_QuoteService service = new ftr_QuoteService();

        test.startTest();
         if(qlieia.size() > 0){
        Map<String, List<Id>> result = service.getSpeedRollupQLIsOnDeletePrevInvoke(qlieia[0].id, qlieia[0].id, qlieia);
            }
        test.stopTest();

        // System.assertEquals(1, result.get('AccessIds').size());
        // System.assertEquals(1, result.get('EvplIds').size());
    }
     @isTest  
    static void getSpeedRollupQLIsOnDeletePrevInvoke_Test3() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q1_LineItems' LIMIT 1];
        String body = sr.Body.toString();
        QuoteLineItem[] qLIs = (List<QuoteLineItem>)JSON.deserialize(body, List<QuoteLineItem>.class);
    List<QuoteLineItem> qlieia = [select id,vlocity_cmt__LineNumber__c,vlocity_cmt__ServiceAccountId__c,PricebookEntry.Id,PricebookEntryId,PricebookEntry.Product2.ProductCode,QuoteId,Product2.ProductCode from QuoteLineItem where Product2.ProductCode =: 'ENT_ETH_EVPL_0002' ];
        ftr_QuoteService service = new ftr_QuoteService();

        test.startTest();
        // Delete EVPL EVC
 if(qlieia.size() > 0){
        Map<String, List<Id>> result = service.getSpeedRollupQLIsOnDeletePrevInvoke(qlieia[0].id, qlieia[0].id, qlieia);
            }        test.stopTest();

        // System.assertEquals(1, result.get('AccessIds').size());
        // System.assertEquals(1, result.get('EvplIds').size());
    }
    @isTest  
    static void getSpeedRollupQLIsOnQLIBeforeUpdate_Test() {
        // List<StaticResource> srList = [SELECT Id, Body FROM StaticResource WHERE Name IN ('ftr_TD_Old_QuoteLineItems','ftr_TD_New_QuoteLineItems')];
        // String body1 = srList[0].Body.toString();
        // String body2 = srList[1].Body.toString();

        // QuoteLineItem oldQLI = (QuoteLineItem)JSON.deserialize(body1, QuoteLineItem.class);
        // QuoteLineItem newQLI = (QuoteLineItem)JSON.deserialize(body2, QuoteLineItem.class);
        // List<Account> servAcc = ftr_TestDataFactory.getServAccountsWithPremise(1);

        List<QuoteLineItem> qLIs = [SELECT Id, QuoteId, Product2Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__ServiceAccountId__c FROM QuoteLineItem];
        // qLIs[1]. vlocity_cmt__ServiceAccountId__c = servAcc[0].Id;
        qLIs[1].vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_ELIG_ATTCAT":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7be000000050xXAAQ","attributecategoryid__c":"a7ag00000008uyvAAA","categorycode__c":"FTR_ENT_ELIG_ATTCAT","categoryname__c":"Eligibility Attributes","attributeuniquecode__c":"ATTR_TIER1","attributeconfigurable__c":true,"attributedisplaysequence__c":"5","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Copper Tier","displaysequence__c":"null","categorydisplaysequence__c":50,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QE9EAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Tier 1","sequence":10,"id":"f6166d0b-d8f2-dce8-6c30-d1f0a68b5725","displayText":"Tier 1"},{"value":"Tier 2","sequence":20,"id":"270589b4-c7b0-0573-f048-23f44a2c6431","displayText":"Tier 2"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7bg0000000C9MYAA0","attributecategoryid__c":"a7ag00000008uyvAAA","categorycode__c":"FTR_ENT_ELIG_ATTCAT","categoryname__c":"Eligibility Attributes","attributeuniquecode__c":"ATTR_TIER2","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Fiber Tier","displaysequence__c":"null","categorydisplaysequence__c":50,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QE8EAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Tier 1","sequence":10,"id":"f6166d0b-d8f2-dce8-6c30-d1f0a68b5725","displayText":"Tier 1"},{"value":"Tier 2","sequence":20,"id":"270589b4-c7b0-0573-f048-23f44a2c6431","displayText":"Tier 2"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null}],"FTR_ENT_PRI_ATTCAT":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7be000000050xQAAQ","attributecategoryid__c":"a7ae0000000ElHKAA0","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_BANDWIDTH","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Speed","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QEAEA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"NA","sequence":1,"id":"b0966bd9-fd8a-64e8-c734-491d83f778f4","displayText":"NA"},{"value":"5 Mbps","sequence":5,"id":"4aba2306-23a9-9d57-df5e-6845e3943828","displayText":"5 Mbps"},{"value":"10 Mbps","sequence":10,"id":"1a208fd2-ccf1-e3ad-2f16-3009f90cb522","displayText":"10 Mbps"},{"value":"20 Mbps","sequence":20,"id":"8b45b7bf-7984-df2e-7378-108ef35bc8a5","displayText":"20 Mbps"},{"value":"30 Mbps","sequence":23,"id":"8e3195a8-38f9-7b18-d78b-87ef50d43f48","displayText":"30 Mbps"},{"value":"40 Mbps","sequence":26,"id":"8628d5bb-244e-41e2-db08-85d3cb246e8f","displayText":"40 Mbps"},{"value":"50 Mbps","sequence":30,"id":"f7bc4c42-ca8b-bd24-832f-a4a106b8173b","displayText":"50 Mbps"},{"value":"100 Mbps","sequence":40,"id":"ed22cdc9-eb1e-cd69-15a9-f5669740afb5","displayText":"100 Mbps"},{"value":"200 Mbps","sequence":50,"id":"3c2416ab-8c99-5331-c40b-ba36ca84bf72","displayText":"200 Mbps"},{"value":"300 Mbps","sequence":60,"id":"c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9","displayText":"300 Mbps"},{"value":"400 Mbps","sequence":70,"id":"fdebc972-b9ec-e456-1d6e-5d03c284ca67","displayText":"400 Mbps"},{"value":"500 Mbps","sequence":80,"id":"5b421e64-e57e-6aa5-fc1a-55c926e9e3dc","displayText":"500 Mbps"},{"value":"600 Mbps","sequence":90,"id":"f2af83f9-ab01-4700-0fe5-b02afe290f69","displayText":"600 Mbps"},{"value":"700 Mbps","sequence":100,"id":"0501fb70-8e20-540d-d4d5-2330d003a939","displayText":"700 Mbps"},{"value":"800 Mbps","sequence":110,"id":"e049798b-2162-1f86-1bdc-508c3e58a89d","displayText":"800 Mbps"},{"value":"900 Mbps","sequence":120,"id":"9e713b50-7ac2-2053-0aad-eeb42c9db47f","displayText":"900 Mbps"},{"value":"1 Gbps","sequence":130,"id":"3aa261dc-29ca-d36d-2a72-5e253b8937f3","displayText":"1 Gbps"},{"value":"2 Gbps","sequence":140,"id":"092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4","displayText":"2 Gbps"},{"value":"5 Gbps","sequence":170,"id":"ecd9008f-9dd8-2415-6574-a52930dc128f","displayText":"5 Gbps"},{"value":"10 Gbps","sequence":180,"id":"e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf","displayText":"10 Gbps"}],"default":[],"selectedItem":{"value":"200 Mbps","sequence":50,"id":"3c2416ab-8c99-5331-c40b-ba36ca84bf72","displayText":"200 Mbps"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7be000000050xSAAQ","attributecategoryid__c":"a7ae0000000ElHKAA0","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_CONTRACT_TERM","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Term","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QECEA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 Months","sequence":10,"id":"acf430f3-5767-4418-ae26-7ec4b80dbc8d","displayText":"12 Months"},{"value":"24 Months","sequence":20,"id":"7fca7a0e-1452-c879-31f2-baa9553ba1a9","displayText":"24 Months"},{"value":"36 Months","sequence":30,"id":"3ce165f6-d467-6a31-f2bf-edbbcad82725","displayText":"36 Months"},{"value":"60 Months","sequence":40,"id":"8782756f-f4d6-5b3a-951d-037e55539c20","displayText":"60 Months"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7bg0000000C9MZAA0","attributecategoryid__c":"a7ae0000000ElHKAA0","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_CoS","attributeconfigurable__c":true,"attributedisplaysequence__c":"30","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Class of Service","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QEEEA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Silver","sequence":10,"id":"4bd906e9-f059-2a1a-c588-ad08beb5d1e1","displayText":"Silver"},{"value":"Gold","sequence":20,"id":"da9c5b03-49f5-5d55-b41c-b068aa1f2031","displayText":"Gold"},{"value":"Platinum","sequence":30,"id":"f8d5b838-0867-537e-83a0-a7b710916357","displayText":"Platinum"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7bg0000000C9MaAAK","attributecategoryid__c":"a7ae0000000ElHKAA0","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_LEVEL","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Level","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QEDEA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"a","valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"a","sequence":10,"id":"2499efa7-499c-ac29-1e9e-3b6209f1e9a1","displayText":"a"}],"values":[{"value":"a","sequence":10,"id":"2499efa7-499c-ac29-1e9e-3b6209f1e9a1","displayText":"a"},{"value":"b","sequence":20,"id":"f739a60b-08ca-9502-a6a2-8756a69861ae","displayText":"b"},{"value":"c","sequence":30,"id":"32b86d23-7873-72d1-2c35-4bab2f73b914","displayText":"c"}],"selectedItem":{"value":"a","sequence":10,"id":"2499efa7-499c-ac29-1e9e-3b6209f1e9a1","displayText":"a"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7bg0000000C9MbAAK","attributecategoryid__c":"a7ae0000000ElHKAA0","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_MARKET","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Market","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QEBEA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"B","valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"B","value":"B"},"$$AttributeDefinitionEnd$$":null}]} }';
        
        ftr_QuoteService service = new ftr_QuoteService();
        test.startTest();
        update qLIs;
        Map<String, List<Id>> result = service.getSpeedRollupQLIsOnQLIBeforeUpdate(qLIs[0], qLIs[1],qLIs[0].Id, qLIs[0].vlocity_cmt__ServiceAccountId__c, 'ENT_ETH_EVPL_0010');
        test.stopTest();
    }

    @isTest  
    static void calculateEvplsSpeedRollup_Test() {
        StaticResource sr1 = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q2_LineItems' LIMIT 1];
        
        List<QuoteLineItem> qLIs = (List<QuoteLineItem>)JSON.deserialize(sr1.body.toString(), List<QuoteLineItem>.class);        
        List<Id> evplIds = new List<Id> { '0QLg00000017ARXGA2' };

        
        ftr_QuoteService service = new ftr_QuoteService();
        test.startTest();
        Boolean result = service.calculateEvplsSpeedRollup(evplIds, qLIs);
        test.stopTest();

    }
    @isTest  
    static void updateAttritbuteBasedSNE_Test1() {
        StaticResource sr1 = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q2_LineItems' LIMIT 1];
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'ENT_ETH_EVPL_0002';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
        attr.Term__c = '24 Months';
        attr.MinuteBlocks__c = '2500 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        insert attr;
        List<QuoteLineItem> qLIs = (List<QuoteLineItem>)JSON.deserialize(sr1.body.toString(), List<QuoteLineItem>.class); 
        ftr_QuoteService service = new ftr_QuoteService();
        test.startTest();
      //  Boolean result = service.updateAttritbuteBasedSNE('0QLg00000017ARXGA2', qLIs);
        test.stopTest();

    }
    @isTest
    static void updateChildServiceAccounts_Test(){
     List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
        Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'ENT_ETH_EIA_0002';
            prodAccess.IsActive = true;
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '36 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"ATTR_CONTRACT_TERM":"24 Months","ATTR_TECH_JURIS":"Interstate","ATTR_CoS":"Silver","ATTR_BANDWIDTH":"20 mbps","ATTR_IP_BLOCKS":"/22 = 1021 IPs","ATTR_MIN_BLOCKS":"2500 Minutes","ATTR_BUYING_OPTION":""}';
            insert oQLI;    
        
         ftr_QuoteService service = new ftr_QuoteService();
       // Boolean result = service.updateChildServiceAccounts(oQLI.id);
       service.setChildFieldOrAttributeFromParent(
            new Map<String, Object> {
                'cpqMethod' => 'postCartsItems.PreInvoke',
                'itemId' => oQLI.Id,
                'isAttribute' => false,
                'fieldOrAttribute' => 'vlocity_cmt__ServiceAccountId__c'
            },
            new List<QuoteLineItem>{ oQLI },oQuote
        );
        service.setChildFieldOrAttributeFromParent(
            new Map<String, Object> {
                'cpqMethod' => 'putCartsItems.PreInvoke',
                'itemId' => oQLI.Id,
                'isAttribute' => true,
                'fieldOrAttribute' => 'ATTR_CONTRACT_TERM'
            },
            new List<QuoteLineItem>{ oQLI },oQuote
        );
        service.setXLIAttributes(
            new Map<String, Object> {
                'cpqMethod' => 'postCartsItems.PreInvoke',
                'itemId' => oQLI.Id,
                'attributesToUpdate' => new Map<String, String> {
                    'ATTR_CONTRACT_TERM' => '12 Months'
                }
            },
            new List<QuoteLineItem>{ oQLI }
        );
        test.stopTest();
    }
     @isTest
    static void updateChildServiceAccounts_Test1(){
     List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'ENT_ETH_EIA_0002';
            prodAccess.IsActive = true;
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '36 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__LineNumber__c = '1.4';
        oQLI.vlocity_cmt__JSONAttribute__c = '{"ATTR_CONTRACT_TERM":"24 Months","ATTR_TECH_JURIS":"Interstate","ATTR_CoS":"Silver","ATTR_BANDWIDTH":"20 mbps","ATTR_IP_BLOCKS":"/22 = 1021 IPs","ATTR_MIN_BLOCKS":"2500 Minutes","ATTR_BUYING_OPTION":""}';
            insert oQLI;    
        
         ftr_QuoteService service = new ftr_QuoteService();
       // Boolean result = service.updateChildServiceAccounts(oQLI.id);
       service.setChildFieldOrAttributeFromParent(
            new Map<String, Object> {
                'cpqMethod' => 'postCartsItems.PreInvoke',
                'itemId' => oQLI.Id,
                    'rootItemId' => oQLI.Id,
                'isAttribute' => false,
                'fieldOrAttribute' => 'vlocity_cmt__ServiceAccountId__c'
            },
            new List<QuoteLineItem>{ oQLI },oQuote
        );
        service.setChildFieldOrAttributeFromParent(
            new Map<String, Object> {
                'cpqMethod' => 'putCartsItems.PreInvoke',
                'itemId' => oQLI.Id,
                    'rootItemId' => oQLI.Id,
                'isAttribute' => true,
                'fieldOrAttribute' => 'ATTR_CONTRACT_TERM'
            },
            new List<QuoteLineItem>{ oQLI },oQuote
        );
        service.setXLIAttributes(
            new Map<String, Object> {
                'cpqMethod' => 'postCartsItems.PreInvoke',
                'itemId' => oQLI.Id,
                'attributesToUpdate' => new Map<String, String> {
                    'ATTR_CONTRACT_TERM' => '12 Months'
                }
            },
            new List<QuoteLineItem>{ oQLI }
        );
        test.stopTest();
    }
        @isTest
    static void setProductsFieldOnQuote_Test(){
     List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_TF_ADDL_BLOCKS';
        prodAccess.Family = 'UCF';
            prodAccess.IsActive = true;
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '36 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"ATTR_CONTRACT_TERM":"24 Months","ATTR_TECH_JURIS":"Interstate","ATTR_CoS":"Silver","ATTR_BANDWIDTH":"20 mbps","ATTR_IP_BLOCKS":"/22 = 1021 IPs","ATTR_MIN_BLOCKS":"2500 Minutes","ATTR_BUYING_OPTION":""}';
            insert oQLI;    
        Map<Id,Quote> quotemap = new Map<Id,Quote>();
        quotemap.put(oQuote.id,oQuote);
         ftr_QuoteService service = new ftr_QuoteService();
         service.setProductsFieldOnQuote(quotemap,true);
        test.stopTest();
    }
          @isTest
    static void setProductsFieldOnQuote_Test2(){
     List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'ENT_ETH_EIA_0002';
       
            prodAccess.IsActive = true;
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '36 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"ATTR_CONTRACT_TERM":"24 Months","ATTR_TECH_JURIS":"Interstate","ATTR_CoS":"Silver","ATTR_BANDWIDTH":"20 mbps","ATTR_IP_BLOCKS":"/22 = 1021 IPs","ATTR_MIN_BLOCKS":"2500 Minutes","ATTR_BUYING_OPTION":""}';
            insert oQLI;    
        Map<Id,Quote> quotemap = new Map<Id,Quote>();
        quotemap.put(oQuote.id,oQuote);
         ftr_QuoteService service = new ftr_QuoteService();
         service.setProductsFieldOnQuote(quotemap,true);
        test.stopTest();
    }
      @isTest
    static void setProductsFieldOnQuote_Test3(){
     List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'ENT_ETH_EVPL_0002';
       
            prodAccess.IsActive = true;
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '36 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"ATTR_CONTRACT_TERM":"24 Months","ATTR_TECH_JURIS":"Interstate","ATTR_CoS":"Silver","ATTR_BANDWIDTH":"20 mbps","ATTR_IP_BLOCKS":"/22 = 1021 IPs","ATTR_MIN_BLOCKS":"2500 Minutes","ATTR_BUYING_OPTION":""}';
            insert oQLI;    
        Map<Id,Quote> quotemap = new Map<Id,Quote>();
        quotemap.put(oQuote.id,oQuote);
         ftr_QuoteService service = new ftr_QuoteService();
         service.setProductsFieldOnQuote(quotemap,true);
        test.stopTest();
    }
    @isTest
    static void setProductsTier_Test(){
     List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'ENT_ETH_EVPL_0002';
       
            prodAccess.IsActive = true;
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '36 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"ATTR_CONTRACT_TERM":"24 Months","ATTR_TECH_JURIS":"Interstate","ATTR_CoS":"Silver","ATTR_BANDWIDTH":"20 mbps","ATTR_IP_BLOCKS":"/22 = 1021 IPs","ATTR_MIN_BLOCKS":"2500 Minutes","ATTR_BUYING_OPTION":""}';
            insert oQLI;    
        List<QuoteLineItem> Qlilst = new List<QuoteLineItem>();
        Qlilst.add(oQLI);
        List<Id> qliid = new List<Id>();
        qliid.add(oQLI.id);
        Map<Id, vlocity_cmt__Premises__c> premisemap  = new Map<Id, vlocity_cmt__Premises__c>();
        premisemap.put(oPremise.id,oPremise);
        Map<Id,Quote> quotemap = new Map<Id,Quote>();
        quotemap.put(oQuote.id,oQuote);
         ftr_QuoteService service = new ftr_QuoteService();
       //  service.setProductsTier(qliid,Qlilst,quotemap);
        test.stopTest();
    }
      @isTest  
    static void updateAttritbuteBasedSNE_Test2() {
        StaticResource sr1 = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q2_LineItems' LIMIT 1];
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'ENT_ETH_EIA_0002';
            prodAccess.IsActive = true;
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '24 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"ATTR_CONTRACT_TERM":"24 Months","ATTR_TECH_JURIS":"Interstate","ATTR_CoS":"Silver","ATTR_BANDWIDTH":"20 mbps","ATTR_IP_BLOCKS":"/22 = 1021 IPs","ATTR_MIN_BLOCKS":"2500 Minutes","ATTR_BUYING_OPTION":""}';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'ENT_ETH_EIA_0002';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
        //attr.Term__c = '24 Months';
        attr.MinuteBlocks__c = '2500 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        insert attr;
        List<QuoteLineItem> qLIs = (List<QuoteLineItem>)JSON.deserialize(sr1.body.toString(), List<QuoteLineItem>.class); 
        ftr_QuoteService service = new ftr_QuoteService();
        String quoteId='0Q011000000TclPCAS';
        String ProductFamily='UCF';
        Map<string,Object> inputMap = new Map<string,Object>{
            'QuoteId'=> quoteId,
                'ProductFamily' => ProductFamily
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_QuoteService quoteService= new ftr_QuoteService();

        Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
       @isTest  
    static void UpdateSNEToQuoteLineItems_Test2() {
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_EXEC_LIC';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '24 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'UCF_EXEC_LIC';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
        //attr.Term__c = '24 Months';
        attr.MinuteBlocks__c = '2500 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        attr.NBD_Remote_Maint_Term__c = '1 Years';
        attr.NBD_Remote_Maint_Product__c = '1550-24P';
        insert attr;
        ftr_QuoteService quoteService= new ftr_QuoteService();
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
         Map<string,Object> inputMap = new Map<string,Object>{
            'QuoteId'=> oQuote.id,
                'ProductFamily' => productFamilyy,
                'IsSyncing' => true
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        quoteService.invokeMethod('UpdateSNEToQuoteLineItems', inputMap, outputMap, options);
        //ftr_QuoteService.UpdateSNEToQuoteLineItems(quoteIdd,productFamilyy);
        //quoteService.invokeMethod('UpdateSNEToQuote', inputMap, outputMap, options);
        //Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
    @isTest  
    static void UpdateSNEToQuoteLineItems_Test2If() {
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_EXEC_LIC';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '24 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'UCF_EXEC_LIC';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
        attr.Term__c = '24 Months';
        attr.MinuteBlocks__c = '2500 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        attr.NBD_Remote_Maint_Term__c = '1 Years';
        attr.NBD_Remote_Maint_Product__c = '1550-24P';
        insert attr;
        ftr_QuoteService quoteService= new ftr_QuoteService();
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
         Map<string,Object> inputMap = new Map<string,Object>{
            'QuoteId'=> oQuote.id,
                'ProductFamily' => productFamilyy
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        quoteService.invokeMethod('UpdateSNEToQuoteLineItems', inputMap, outputMap, options);
        //ftr_QuoteService.UpdateSNEToQuoteLineItems(quoteIdd,productFamilyy);
        //quoteService.invokeMethod('UpdateSNEToQuote', inputMap, outputMap, options);
        //Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
         @isTest  
    static void UpdateSNEToQuoteLineItems_Test1() {
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
       //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_TF_ADDL_BLOCKS';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '24 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ {"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1100000BLCAvAAP","attributeid__c":"a7b11000000DVbqAAG","attributecategoryid__c":"a7a3D00000090doQAA","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_MIN_BLOCKS","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Minute Blocks","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":5000,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Y110000004qSoEAI","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"5000","valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"5000 Minutes","id":"4c412f4b-7358-69ce-0ad1-1a3cba0d1a53","sequence":30,"value":"5000"}],"values":[{"displayText":"1000 Minutes","id":"3b00469e-65c3-fc05-77c7-e189d4267603","sequence":10,"value":"1000"},{"displayText":"2500 Minutes","id":"926343a8-51e5-7470-cca8-00bb85edd6b9","sequence":20,"value":"2500"},{"displayText":"5000 Minutes","id":"4c412f4b-7358-69ce-0ad1-1a3cba0d1a53","sequence":30,"value":"5000"},{"displayText":"7500 Minutes","id":"c182efde-06c6-d835-3777-536dca0950d2","sequence":40,"value":"7500"},{"displayText":"10000 Minutes","id":"1cf0a25d-ba79-2f1e-978a-273358f388ab","sequence":50,"value":"10000"}],"selectedItem":{"displayText":"1000 Minutes","id":"3b00469e-65c3-fc05-77c7-e189d4267603","sequence":10,"value":"1000"}},"$$AttributeDefinitionEnd$$":null},{ "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'UCF_TF_ADDL_BLOCKS';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
        //attr.Term__c = '24 Months';
        attr.MinuteBlocks__c = '1000 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        attr.NBD_Remote_Maint_Term__c = '1 Years';
        attr.NBD_Remote_Maint_Product__c = '1550-24P';
        insert attr;
        ftr_QuoteService quoteService= new ftr_QuoteService();
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
         Map<string,Object> inputMap = new Map<string,Object>{
            'QuoteId'=> oQuote.id,
                'ProductFamily' => productFamilyy
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        quoteService.invokeMethod('UpdateSNEToQuoteLineItems', inputMap, outputMap, options);
        //ftr_QuoteService.UpdateSNEToQuoteLineItems(quoteIdd,productFamilyy);
        //quoteService.invokeMethod('UpdateSNEToQuote', inputMap, outputMap, options);
        //Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
     @isTest  
    static void UpdateSNEToQuoteLineItems_Test1Else() {
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_TF_ADDL_BLOCKS';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '36 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ {"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1100000BLCAvAAP","attributeid__c":"a7b11000000DVbqAAG","attributecategoryid__c":"a7a3D00000090doQAA","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_MIN_BLOCKS","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Minute Blocks","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":5000,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Y110000004qSoEAI","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"5000","valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"5000 Minutes","id":"4c412f4b-7358-69ce-0ad1-1a3cba0d1a53","sequence":30,"value":"5000"}],"values":[{"displayText":"1000 Minutes","id":"3b00469e-65c3-fc05-77c7-e189d4267603","sequence":10,"value":"1000"},{"displayText":"2500 Minutes","id":"926343a8-51e5-7470-cca8-00bb85edd6b9","sequence":20,"value":"2500"},{"displayText":"5000 Minutes","id":"4c412f4b-7358-69ce-0ad1-1a3cba0d1a53","sequence":30,"value":"5000"},{"displayText":"7500 Minutes","id":"c182efde-06c6-d835-3777-536dca0950d2","sequence":40,"value":"7500"},{"displayText":"10000 Minutes","id":"1cf0a25d-ba79-2f1e-978a-273358f388ab","sequence":50,"value":"10000"}],"selectedItem":{"displayText":"1000 Minutes","id":"3b00469e-65c3-fc05-77c7-e189d4267603","sequence":10,"value":"1000"}},"$$AttributeDefinitionEnd$$":null},{ "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'UCF_TF_ADDL_BLOCKS';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
        attr.Term__c = '36 Months';
        attr.MinuteBlocks__c = '1000 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        attr.NBD_Remote_Maint_Term__c = '1 Years';
        attr.NBD_Remote_Maint_Product__c = '1550-24P';
        insert attr;
        ftr_QuoteService quoteService= new ftr_QuoteService();
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
         Map<string,Object> inputMap = new Map<string,Object>{
            'QuoteId'=> oQuote.id,
                'ProductFamily' => productFamilyy
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        quoteService.invokeMethod('UpdateSNEToQuoteLineItems', inputMap, outputMap, options);
        //ftr_QuoteService.UpdateSNEToQuoteLineItems(quoteIdd,productFamilyy);
        //quoteService.invokeMethod('UpdateSNEToQuote', inputMap, outputMap, options);
        //Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
        @isTest  
    static void UpdateSNEToQuoteLineItems_Test3() {
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_CCASS_AGENT_LIC';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '24 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'UCF_CCASS_AGENT_LIC';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
       // attr.Term__c = '24 Months';
        attr.MinuteBlocks__c = '2500 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        attr.NBD_Remote_Maint_Term__c = '1 Years';
        attr.NBD_Remote_Maint_Product__c = '1550-24P';
        insert attr;
        ftr_QuoteService quoteService= new ftr_QuoteService();
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
         Map<string,Object> inputMap = new Map<string,Object>{
            'QuoteId'=> oQuote.id,
                'ProductFamily' => productFamilyy
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        quoteService.invokeMethod('UpdateSNEToQuoteLineItems', inputMap, outputMap, options);
        //ftr_QuoteService.UpdateSNEToQuoteLineItems(quoteIdd,productFamilyy);
        //quoteService.invokeMethod('UpdateSNEToQuote', inputMap, outputMap, options);
        //Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
      @isTest  
    static void UpdateSNEToQuoteLineItems_Test3If() {
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_CCASS_AGENT_LIC';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '24 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'UCF_CCASS_AGENT_LIC';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
       attr.Term__c = '24 Months';
        attr.MinuteBlocks__c = '2500 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        attr.NBD_Remote_Maint_Term__c = '1 Years';
        attr.NBD_Remote_Maint_Product__c = '1550-24P';
        insert attr;
        ftr_QuoteService quoteService= new ftr_QuoteService();
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
         Map<string,Object> inputMap = new Map<string,Object>{
            'QuoteId'=> oQuote.id,
                'ProductFamily' => productFamilyy
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        quoteService.invokeMethod('UpdateSNEToQuoteLineItems', inputMap, outputMap, options);
        //ftr_QuoteService.UpdateSNEToQuoteLineItems(quoteIdd,productFamilyy);
        //quoteService.invokeMethod('UpdateSNEToQuote', inputMap, outputMap, options);
        //Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
     @isTest  
      static void UpdateSNEToQuoteLineItems_Test4If() {
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_POLY_EXPMICS';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '36 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ {"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1100000BLCAvAAP","attributeid__c":"a7b11000000DVbqAAG","attributecategoryid__c":"a7a3D00000090doQAA","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_MIN_BLOCKS","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Minute Blocks","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":5000,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Y110000004qSoEAI","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"5000","valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"5000 Minutes","id":"4c412f4b-7358-69ce-0ad1-1a3cba0d1a53","sequence":30,"value":"5000"}],"values":[{"displayText":"1000 Minutes","id":"3b00469e-65c3-fc05-77c7-e189d4267603","sequence":10,"value":"1000"},{"displayText":"2500 Minutes","id":"926343a8-51e5-7470-cca8-00bb85edd6b9","sequence":20,"value":"2500"},{"displayText":"5000 Minutes","id":"4c412f4b-7358-69ce-0ad1-1a3cba0d1a53","sequence":30,"value":"5000"},{"displayText":"7500 Minutes","id":"c182efde-06c6-d835-3777-536dca0950d2","sequence":40,"value":"7500"},{"displayText":"10000 Minutes","id":"1cf0a25d-ba79-2f1e-978a-273358f388ab","sequence":50,"value":"10000"}],"selectedItem":{"displayText":"1000 Minutes","id":"3b00469e-65c3-fc05-77c7-e189d4267603","sequence":10,"value":"1000"}},"$$AttributeDefinitionEnd$$":null},{ "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'UCF_POLY_EXPMICS';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
       attr.Term__c = '36 Months';
        attr.MinuteBlocks__c = '1000 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        attr.NBD_Remote_Maint_Term__c = '1 Years';
        attr.NBD_Remote_Maint_Product__c = '1550-24P';
        insert attr;
        ftr_QuoteService quoteService= new ftr_QuoteService();
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
         Map<string,Object> inputMap = new Map<string,Object>{
            'QuoteId'=> oQuote.id,
                'ProductFamily' => productFamilyy
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        quoteService.invokeMethod('UpdateSNEToQuoteLineItems', inputMap, outputMap, options);
        //ftr_QuoteService.UpdateSNEToQuoteLineItems(quoteIdd,productFamilyy);
        //quoteService.invokeMethod('UpdateSNEToQuote', inputMap, outputMap, options);
        //Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
      @isTest  
    static void UpdateSNEToQuoteLineItems_Test4() {
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_POLY_EXPMICS';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '24 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'UCF_POLY_EXPMICS';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
       // attr.Term__c = '24 Months';
        attr.MinuteBlocks__c = '2500 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        attr.NBD_Remote_Maint_Term__c = '1 Years';
        attr.NBD_Remote_Maint_Product__c = '1550-24P';
        insert attr;
        ftr_QuoteService quoteService= new ftr_QuoteService();
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
         Map<string,Object> inputMap = new Map<string,Object>{
            'QuoteId'=> oQuote.id,
                'ProductFamily' => productFamilyy
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        quoteService.invokeMethod('UpdateSNEToQuoteLineItems', inputMap, outputMap, options);
        //ftr_QuoteService.UpdateSNEToQuoteLineItems(quoteIdd,productFamilyy);
        //quoteService.invokeMethod('UpdateSNEToQuote', inputMap, outputMap, options);
        //Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
      @isTest  
    static void UpdateSNEToQuoteLineItems_Test5() {
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;

            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '24 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'UCF';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
        attr.Term__c = '24 Months';
        attr.MinuteBlocks__c = '2500 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        attr.NBD_Remote_Maint_Term__c = '1 Years';
        attr.NBD_Remote_Maint_Product__c = '1550-24P';
        insert attr;
        ftr_QuoteService quoteService= new ftr_QuoteService();
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
         Map<string,Object> inputMap = new Map<string,Object>();
           
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        quoteService.invokeMethod('UpdateSNEToQuoteLineItems', inputMap, outputMap, options);
        //ftr_QuoteService.UpdateSNEToQuoteLineItems(quoteIdd,productFamilyy);
        //quoteService.invokeMethod('UpdateSNEToQuote', inputMap, outputMap, options);
        //Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
      @isTest  
    static void UpdateSNEToQuoteLineItems_Test6() {
       List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_NBD_MAINT';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '24 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        QLIlist.add(oQLI);
        ftr_Attribute_Based_SNE__c attr = new ftr_Attribute_Based_SNE__c();
        attr.Product_Code__c = 'UCF_NBD_MAINT';
        attr.Speed__c = '200 Mbps';
        attr.CoS__c = 'Silver';
        attr.Jurisdiction__c = 'Interstate';
        attr.Term__c = '24 Months';
        attr.MinuteBlocks__c = '2500 Minutes';
        attr.IP_Blocks__c ='/22 = 1021 IPs';
        attr.Purchase_Type__c = 'P';
        attr.NBD_Remote_Maint_Term__c = '1 Years';
        attr.NBD_Remote_Maint_Product__c = '1550-24P';
        insert attr;
        ftr_QuoteService quoteService= new ftr_QuoteService();
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
         Map<string,Object> inputMap = new Map<string,Object>{
            'QuoteId'=> oQuote.id,
                'ProductFamily' => productFamilyy,
                'IsSyncing' => true
                };
           
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        quoteService.invokeMethod('UpdateSNEToQuoteLineItems', inputMap, outputMap, options);
        //ftr_QuoteService.UpdateSNEToQuoteLineItems(quoteIdd,productFamilyy);
        //quoteService.invokeMethod('UpdateSNEToQuote', inputMap, outputMap, options);
        //Boolean result = quoteService.updateAttritbuteBasedSNE(oQLI.id, QLIlist);
        //ftr_QuoteService.updateSNEfortheQuote(oQuote.id,'UCF');
        test.stopTest();

    }
    
    @isTest
    static void isQuoteHasUCFEquipmentTest(){
         List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
            testAccount.ParentId = globalAcc1.Id;
            testAccount.Name = 'Test Account';
            testAccount.BillingStreet = '123 Main Street';
            testAccount.BillingCity = 'Anywhere';
            testAccount.BillingState = 'Ohio';
            testAccount.BillingPostalCode = '44088';
            testAccount.ShippingStreet = '123 Main Street';
            testAccount.ShippingCity = 'Anywhere';
            testAccount.ShippingState = 'Ohio';
            testAccount.ShippingPostalCode = '44088';
            testAccount.Phone = '9023214560';
            insert testAccount;
            
            vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
            oPremise.vlocity_cmt__Address1__c = '123 Main Street';
            oPremise.vlocity_cmt__City__c = 'Anywhere';
            oPremise.vlocity_cmt__State__c = 'California';
            oPremise.vlocity_cmt__PostalCode__c = '44076';
            oPremise.vlocity_cmt__Status__c = 'Connected';
            oPremise.DSAT_Ticket__c = '211212';
            oPremise.Copper_Tier__c = 'Tier 1';
            oPremise.Fiber_Tier__c = 'Tier 1';
            oPremise.Last_DSAT_Check__c = system.today();
            oPremise.WC_QOS__c = 'Platinum';
            oPremise.WC_Speed__c = '1000MB';
            oPremise.Market__c = 'B';
            oPremise.Level__c = 'a';
            insert oPremise;
            
            Id ServiceRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Service' AND SobjectType = 'Account'].Id;
            Account testSAccount = new Account();
            testSAccount.RecordTypeId = ServiceRTId;
            testSAccount.ParentId = testAccount.Id;
            testSAccount.Name = 'Test Service Account';
            testSAccount.BillingStreet = '123 Main Street';
            testSAccount.BillingCity = 'Anywhere';
            testSAccount.BillingState = 'Ohio';
            testSAccount.BillingPostalCode = '44088';
            testSAccount.ShippingStreet = '123 Main Street';
            testSAccount.ShippingCity = 'Anywhere';
            testSAccount.ShippingState = 'Ohio';
            testSAccount.ShippingPostalCode = '44088';
            testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
            testSAccount.Phone = '9023214560';
            insert testSAccount;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'RefreshTestOpp';
            opp.AccountId = testAccount.id;
            Date d1=Date.newInstance(2019, 05, 11);
            opp.CloseDate=d1;
            opp.StageName='Investigating';
            opp.CPE_Product__c='No';
            insert opp;
        Product2 prodAccess = new Product2();
            prodAccess.Name = 'Access';
            prodAccess.ProductCode = 'UCF_POLY_DS230HS';
            prodAccess.IsActive = true;
        prodAccess.Family = 'UCF';
            lstProduct2.add(prodAccess);
            //Insert products
            insert lstProduct2; 
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = lstProduct2[0].Id,
                UnitPrice = 100, IsActive = true);
            insert standardPrice;
        Quote oQuote = new Quote();
            oQuote.Name = 'Testing Quote';
            oQuote.OpportunityId = Opp.id;
            oQuote.Pricebook2Id = pricebookId;
            oQuote.Status = 'Draft';
            oQuote.Approval_Status__c = 'N/A';
            insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
            oQLI.QuoteId = oQuote.id;
            oQLI.PricebookEntryId = standardPrice.id;
            oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
            oQLI.Quantity = 1;
            oQLI.UnitPrice = 34.50;
            oQLI.Term__c = '24 Months';
            oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
            oQLI.Product2Id = lstProduct2[0].Id;
            oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLI.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
            insert oQLI;
        
        ftr_QuoteService.isQuoteHasUCFEquipment(oQuote.id);
    }
  /*
    @isTest  
    static void calculateNetworkAccessesSpeedRollup_Test() {
        StaticResource sr1 = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_Q2_LineItems' LIMIT 1];
        
        List<QuoteLineItem> qLIs = (List<QuoteLineItem>)JSON.deserialize(sr1.body.toString(), List<QuoteLineItem>.class);        
        List<Id> accessIds = new List<Id> { '0QLg00000017ARSGA2' };

        ftr_QuoteService service = new ftr_QuoteService();
        test.startTest();
        Boolean result = service.calculateNetworkAccessesSpeedRollup(accessIds,qLIs);
        test.stopTest();

    }*/
    

    @isTest  
    static void syncPricingAttribsFromDSAT_Test() {
        List<QuoteLineItem> qLIs = [SELECT Id, Product2Id, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__JSONAttribute__c 
                                    FROM QuoteLineItem];
        List<Account> serviceAccount = [SELECT vlocity_cmt__PremisesId__c FROM Account];

        ftr_QuoteService service = new ftr_QuoteService();
        test.startTest();
        Boolean result = service.syncPricingAttribsFromDSAT(qLIs[0].Id, qLIs);
        test.stopTest();

    }

  /*
    @isTest  
    static void addAccessesBySelectedLocations_Test() {
        List<Quote> quoteList = [SELECT Id FROM Quote];
        List<QuoteLineItem> qLIs = [SELECT Id, Product2Id, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__LineNumber__c,vlocity_cmt__JSONAttribute__c FROM QuoteLineItem];
        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        String methodName = 'addAccessesBySelectedLocations';
        Map<String, Object> inputMap = new Map<String, Object>{'quoteId' => quoteList[0].Id};
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        test.startTest();
        ftr_QuoteService qsvs = new ftr_QuoteService();
        Boolean result = qsvs.invokeMethod(methodName, inputMap, outputMap, options);
        test.stopTest();
        //System.assertEquals(true, result);
    } */
       
    @isTest  
    static void invokeMethod_CancelApproval_Test() {
        List<Quote> quoteList = [SELECT Id FROM Quote];

        String methodName = 'cancelApproval';
        Map<String, Object> inputMap = new Map<String, Object>{'contextId' => quoteList[0].Id};
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        test.startTest();
        ftr_QuoteService qsvs = new ftr_QuoteService();
        Boolean result = qsvs.invokeMethod(methodName, inputMap, outputMap, options);
        test.stopTest();
        System.assertEquals(true, result);
    }


    @isTest
    static void testsetTermForQLIs(){
        Quote singleQuote = [SELECT Id FROM Quote LIMIT 1];
        List<QuoteLineItem> qliList = [SELECT Id, vlocity_cmt__JSONAttribute__c FROM QuoteLineItem WHERE QuoteId =: singleQuote.Id];
        String term = '12 months';
        System.debug('qliList..'+ qliList[0].vlocity_cmt__JSONAttribute__c);
        

        test.startTest();
        ftr_QuoteService quoServ = new ftr_QuoteService();
        quoServ.setTermForQLIs(term,qliList);
        test.stopTest();
        String updatedTerm;
        List<QuoteLineItem> updateQlis = [SELECT Id, vlocity_cmt__JSONAttribute__c FROM QuoteLineItem WHERE QuoteId =: singleQuote.Id];
        System.debug('updateQlis..'+ updateQlis);
    }

    @isTest  
    static void updateTermForAllQLIs_Test() {
        Quote singleQuote = [SELECT Id FROM Quote LIMIT 1];
        List<QuoteLineItem> qliList = [SELECT Id, vlocity_cmt__JSONAttribute__c FROM QuoteLineItem WHERE QuoteId =: singleQuote.Id];
        String newTerm = '36 months';

        test.startTest();
        ftr_QuoteService quoServ = new ftr_QuoteService();
        quoServ.updateTermForAllQLIs(singleQuote.Id, newTerm);
        test.stopTest();

    }
    
     @isTest  
    static void testToggleSync() {
        Quote singleQuote = [SELECT Id FROM Quote LIMIT 1];
        List<QuoteLineItem> qliList = [SELECT Id, vlocity_cmt__JSONAttribute__c FROM QuoteLineItem WHERE QuoteId =: singleQuote.Id];
        String newTerm = '36 months';

        test.startTest();
        ftr_QuoteService service = new ftr_QuoteService();
        service.invokeMethod('toggleQuoteSync', new Map<String, Object>{'contextId'=>singleQuote.Id}, new Map<String, Object>{}, new Map<String, Object>{});
        delete singleQuote;
        test.stopTest();

    }

@isTest  
    static void testSetQuoteTypeField() {
        Quote singleQuote = [SELECT Id, Status, ftr_QuoteType__c FROM Quote LIMIT 1];

        test.startTest();
        singleQuote.Status = 'Approved';
        singleQuote.ftr_QuoteType__c = 'Disconnect';
        update singleQuote;
        test.stopTest();

    }
    
    @isTest  
    static void testCheckForSyncedQuotes() {
        Quote singleQuote = [SELECT Id FROM Quote LIMIT 1];
        List<QuoteLineItem> qliList = [SELECT Id, vlocity_cmt__JSONAttribute__c FROM QuoteLineItem WHERE QuoteId =: singleQuote.Id];
        String newTerm = '36 months';
        singleQuote.IsSyncing__c = false;
        test.startTest();
        update singleQuote;
        ftr_QuoteService service = new ftr_QuoteService();
        service.invokeMethod('confirmStopSync', new Map<String, Object>{'contextId'=>singleQuote.Id}, new Map<String, Object>{}, new Map<String, Object>{});
        service.invokeMethod('checkForSyncedQuotes', new Map<String, Object>{'contextId'=>singleQuote.Id}, new Map<String, Object>{}, new Map<String, Object>{});
        test.stopTest();

        
    }
    
@isTest      
     static void testIncrement() {
        Test.startTest();
        ftr_QuoteService.justIncrement();
        Test.stopTest();
 }
}