/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3.1
**/
@isTest
public with sharing class ftr_QuoteLineItemTriggerHandlerTest {
     
    @isTest
    static void beforeInsertTest() {
        Integer numOfQLIforEachQuote = 2;
        Integer numOfQuote = 1;     

        test.startTest();
        List<QuoteLineItem> qlis = ftr_TestDataFactory.getQLI(numOfQLIforEachQuote, numOfQuote);
        
           ftr_CpqCartCtx.addMessage('prepareDSATAttrSync', new Map<String, Object> {
            'cpqMethod' => 'putCartsItems.PreInvoke',
            'quoteId' => qlis[0].QuoteId,
            'itemId' => qlis[0].Id,
            'itemProductCode' => 'test',
            'parentItemId' => null,
            'parentServiceAccountId' => null,
            'rootItemId' => null
        }); 
        
        insert qlis;
        
        test.stopTest();
        List<Quote> parentQuote  = [Select Id, Service_Term__c from Quote];
        System.assertEquals('36 Months',parentQuote[0].Service_Term__c);
    }

    @isTest
    static void beforeUpdateTest() {
        Integer numOfQLIforEachQuote = 2;
        Integer numOfQuote = 1;
        
        List<QuoteLineItem> qlis = ftr_TestDataFactory.getQLI(numOfQLIforEachQuote, numOfQuote);
        insert qlis;

        
        ftr_CpqCartCtx.addMessage('prepareDSATAttrSync', new Map<String, Object> {
            'cpqMethod' => 'putCartsItems.PreInvoke',
            'quoteId' => qlis[0].QuoteId,
            'itemId' => qlis[0].Id,
            'itemProductCode' => 'test',
            'parentItemId' => null,
            'parentServiceAccountId' => null,
            'rootItemId' => null
        });
        ftr_CpqCartCtx.addMessage('prepareSpeedRollup', new Map<String, Object> {
                    'cpqMethod' => 'putCartsItems.PreInvoke',
                    'quoteId' => qlis[0].QuoteId,
                    'itemId' => qlis[0].Id,
                    'itemProductCode' => null,
                    'parentItemId' => null,
                    'parentServiceAccountId' => null,
                    'rootItemId' => null
                });
        

       
        
        //qlis[0].vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgKAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QCEEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "displayText": "10 Mbps", "id": "6af9a9e5-dff5-0f51-223e-f149d256851c", "sequence": 10, "value": "10 Mbps" }, { "displayText": "20 Mbps", "id": "8d9a9bd8-a090-0531-c54b-be76521934dc", "sequence": 20, "value": "20 Mbps" }, { "displayText": "30 Mbps", "id": "14414b0c-98a4-9c39-1a98-ba04a2e7dcd9", "sequence": 23, "value": "30 Mbps" }, { "displayText": "40 Mbps", "id": "8178d30d-0ad0-b5af-f206-bc7c6ac80128", "sequence": 26, "value": "40 Mbps" }, { "displayText": "50 Mbps", "id": "71166878-186e-3b66-49ae-dcd659204939", "sequence": 30, "value": "50 Mbps" }, { "displayText": "100 Mbps", "id": "4c03d782-90e7-d359-0c4c-b847a4d13547", "sequence": 40, "value": "100 Mbps" }, { "displayText": "200 Mbps", "id": "250ff27d-186d-262e-6604-ccb548815ce5", "sequence": 50, "value": "200 Mbps" }, { "displayText": "500 Mbps", "id": "cbb255c2-9001-4471-a18b-8fadf853c33b", "sequence": 60, "value": "500 Mbps" }, { "displayText": "1 Gbps", "id": "bfd7e3ad-26a4-26d7-3c04-499855b76c53", "sequence": 70, "value": "1 Gbps" } ], "default": [ ], "selectedItem": { "displayText": "10 Mbps", "id": "6af9a9e5-dff5-0f51-223e-f149d256851c", "sequence": 10, "value": "10 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';
        qlis[0].vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgKAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QCEEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "displayText": "10 Mbps", "id": "6af9a9e5-dff5-0f51-223e-f149d256851c", "sequence": 10, "value": "10 Mbps" }, { "displayText": "20 Mbps", "id": "8d9a9bd8-a090-0531-c54b-be76521934dc", "sequence": 20, "value": "20 Mbps" }, { "displayText": "30 Mbps", "id": "14414b0c-98a4-9c39-1a98-ba04a2e7dcd9", "sequence": 23, "value": "30 Mbps" }, { "displayText": "40 Mbps", "id": "8178d30d-0ad0-b5af-f206-bc7c6ac80128", "sequence": 26, "value": "40 Mbps" }, { "displayText": "50 Mbps", "id": "71166878-186e-3b66-49ae-dcd659204939", "sequence": 30, "value": "50 Mbps" }, { "displayText": "100 Mbps", "id": "4c03d782-90e7-d359-0c4c-b847a4d13547", "sequence": 40, "value": "100 Mbps" }, { "displayText": "200 Mbps", "id": "250ff27d-186d-262e-6604-ccb548815ce5", "sequence": 50, "value": "200 Mbps" }, { "displayText": "500 Mbps", "id": "cbb255c2-9001-4471-a18b-8fadf853c33b", "sequence": 60, "value": "500 Mbps" }, { "displayText": "1 Gbps", "id": "bfd7e3ad-26a4-26d7-3c04-499855b76c53", "sequence": 70, "value": "1 Gbps" } ], "default": [ ], "selectedItem": { "displayText": "10 Mbps", "id": "6af9a9e5-dff5-0f51-223e-f149d256851c", "sequence": 10, "value": "10 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ],"FTR_ENT_ELIG_ATTCAT":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0h000002mZekAAE","attributeid__c":"a7b8D000000DV2fQAG","attributecategoryid__c":"a7a740000000xzIAAQ","categorycode__c":"FTR_ENT_ELIG_ATTCAT","categoryname__c":"Eligibility Attributes","attributeuniquecode__c":"ATTR_ELIGBL_PARTNRD","attributeconfigurable__c":true,"attributedisplaysequence__c":"1930","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Partnered","displaysequence__c":"null","categorydisplaysequence__c":50,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Y8D00000051QRUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"true","valuedatatype__c":"Checkbox","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"$$AttributeDefinitionEnd$$":null}] }';
        update qlis;
        Test.startTest();
        qlis[0].vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgKAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QCEEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "displayText": "10 Mbps", "id": "6af9a9e5-dff5-0f51-223e-f149d256851c", "sequence": 10, "value": "10 Mbps" }, { "displayText": "20 Mbps", "id": "8d9a9bd8-a090-0531-c54b-be76521934dc", "sequence": 20, "value": "20 Mbps" }, { "displayText": "30 Mbps", "id": "14414b0c-98a4-9c39-1a98-ba04a2e7dcd9", "sequence": 23, "value": "30 Mbps" }, { "displayText": "40 Mbps", "id": "8178d30d-0ad0-b5af-f206-bc7c6ac80128", "sequence": 26, "value": "40 Mbps" }, { "displayText": "50 Mbps", "id": "71166878-186e-3b66-49ae-dcd659204939", "sequence": 30, "value": "50 Mbps" }, { "displayText": "100 Mbps", "id": "4c03d782-90e7-d359-0c4c-b847a4d13547", "sequence": 40, "value": "100 Mbps" }, { "displayText": "200 Mbps", "id": "250ff27d-186d-262e-6604-ccb548815ce5", "sequence": 50, "value": "200 Mbps" }, { "displayText": "500 Mbps", "id": "cbb255c2-9001-4471-a18b-8fadf853c33b", "sequence": 60, "value": "500 Mbps" }, { "displayText": "1 Gbps", "id": "bfd7e3ad-26a4-26d7-3c04-499855b76c53", "sequence": 70, "value": "1 Gbps" } ], "default": [ ], "selectedItem": { "displayText": "10 Mbps", "id": "6af9a9e5-dff5-0f51-223e-f149d256851c", "sequence": 10, "value": "10 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ],"FTR_ENT_ELIG_ATTCAT":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0h000002mZekAAE","attributeid__c":"a7b8D000000DV2fQAG","attributecategoryid__c":"a7a740000000xzIAAQ","categorycode__c":"FTR_ENT_ELIG_ATTCAT","categoryname__c":"Eligibility Attributes","attributeuniquecode__c":"ATTR_ELIGBL_PARTNRD","attributeconfigurable__c":true,"attributedisplaysequence__c":"1930","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Partnered","displaysequence__c":"null","categorydisplaysequence__c":50,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Y8D00000051QRUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"true","valuedatatype__c":"Checkbox","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":true},"$$AttributeDefinitionEnd$$":null}] }';
        update qlis;
        Test.stopTest();
        

    }

    @isTest
    static void beforeDeleteTest() {

        Integer numOfQLIforEachQuote = 2;
        Integer numOfQuote = 1;
        
    //    test.startTest();
        List<QuoteLineItem> qlis = ftr_TestDataFactory.getQLI(numOfQLIforEachQuote, numOfQuote);
        insert qlis;

        delete qlis;
    //    test.stopTest();
    }
    
    @isTest
    static void beforeUpdateDsatTest() {
        Integer numOfQLIforEachQuote = 5;
        Integer numOfQuote = 1;
        // Account[] accList = ftr_TestDataFactory.getServAccountsWithPremise(2);
        // update accList;
        List<QuoteLineItem> qlis = ftr_TestDataFactory.getQLI(numOfQLIforEachQuote, numOfQuote);
        List<String> accIdList = new List<String>();
        for (QuoteLineItem qLI : qlis) {
            accIdList.add(qli.vlocity_cmt__ServiceAccountId__c);
        }
        Account[] accList = [SELECT vlocity_cmt__PremisesId__c FROM Account WHERE ID IN:accIdList ];
        
        List<vlocity_cmt__Premises__c> premiseList = new List<vlocity_cmt__Premises__c>();
        for(Account servAcc: accList){
            premiseList.add(new vlocity_cmt__Premises__c(
                Id=servAcc.vlocity_cmt__PremisesId__c,
                vlocity_cmt__State__c = 'CA',
                Lit__c = 'No',
                Fiber_Distance__c = 100
            ));
        }
        update premiseList;

        //DSAT_StandardInterval__c dsatRec = [select id,State__c,Lit__c,X1_1000FT__c,X1001_2000FT__c,X2001_to_4000FT__c from DSAT_StandardInterval__c where State__c =: premiseObj.vlocity_cmt__State__c];
        List<DSAT_StandardInterval__c> dsatList = new List<DSAT_StandardInterval__c>();
        DSAT_StandardInterval__c dsatRec = new DSAT_StandardInterval__c(State__c = 'CA',
                                                        Lit__c = 'No',
                                                        X1_1000FT__c = '35-45',
                                                        X1001_2000FT__c  = '45-55',    
                                                        X2001_to_4000FT__c = '55-65');
        
        dsatList.add(dsatRec);
        //dsatList.add(dsatRec1);
        insert dsatList;
        
        List<Product2> productList = new List<Product2>();
        for(QuoteLineItem eachItem :qlis){
            Product2 prodObj = new Product2();
            prodObj.ID = eachItem.Product2Id;
            prodObj.Family = 'Ethernet';
            productList.add( prodObj );
        }
        update productList;

        vlocity_cmt__ProductChildItem__c prodchilditem = new vlocity_cmt__ProductChildItem__c(
            vlocity_cmt__ParentProductId__c = qlis[0].Product2Id, 
            vlocity_cmt__ChildProductId__c = qlis[1].Product2Id,
            vlocity_cmt__ChildLineNumber__c = '1'
        );
        insert prodchilditem;


        Test.startTest();
    
            insert qlis;
       
            Integer i = 0;
            Id quoteId;
            for(QuoteLineItem eachItem :qlis){
                quoteId = eachItem.QuoteId;
                if(i == 0) {
                    eachItem.vlocity_cmt__OneTimeCharge__c = 50;
                    eachItem.vlocity_cmt__BaseOneTimeCharge__c = 100;
                    eachItem.Floor_Price_One_Time__c = 0.00;
                    eachItem.Floor_Price_Recurring__c = 50;
                    eachItem.vlocity_cmt__RecurringCharge__c = 40;
                }
                if(i == 1){
                    eachItem.vlocity_cmt__OneTimeCharge__c = 50;
                    eachItem.vlocity_cmt__BaseOneTimeCharge__c = 100;
                    eachItem.Floor_Price_One_Time__c = null;
                    eachItem.vlocity_cmt__RecurringCharge__c = 10;
                    eachItem.vlocity_cmt__BaseRecurringCharge__c = 100;
                    eachItem.Floor_Price_Recurring__c = null;
                }
                if(i == 2){
                    eachItem.vlocity_cmt__OneTimeCharge__c = 100;
                    eachItem.vlocity_cmt__BaseOneTimeCharge__c = 50;
                    eachItem.Floor_Price_One_Time__c = null;
                }
                if(i == 3) {
                    eachItem.vlocity_cmt__OneTimeCharge__c = 50;
                    eachItem.vlocity_cmt__BaseOneTimeCharge__c = 100;
                    eachItem.Floor_Price_One_Time__c = 0.00;
                    eachItem.Floor_Price_Recurring__c = 50;
                    eachItem.vlocity_cmt__RecurringCharge__c = 60;
                    eachItem.vlocity_cmt__OneTimeCharge__c = 50;
                    eachItem.Floor_Price_One_Time__c = 100;
                }
                if(i == 4) {
                    eachItem.vlocity_cmt__BaseOneTimeCharge__c = 100;
                    eachItem.Floor_Price_One_Time__c = 0.00;
                    eachItem.Floor_Price_Recurring__c = 50;
                    eachItem.vlocity_cmt__RecurringCharge__c = 1000000;
                    eachItem.vlocity_cmt__OneTimeCharge__c = 50;
                    eachItem.Floor_Price_One_Time__c = 100;
                }
                i++;
            }
            update qlis;
        QuoteLineItemService.quotesToUpdate.put(quoteId, new Quote(Id=quoteId));
        QuoteLineItemService.updateQuotesDelayed();
        Test.stopTest();
    }
	
    
}