/*********************************************************************************************************************
*@Name        : OppQuickQuoteTest
*@Author      : Dileep Chinthala <dileep.chinthala@ftr.com>
*@Description : This test class is to cover OpportunityQuickQuoteController, CreateQuickQuote_Controller & QuoteServiceController 
				classes 
* UPDATES
* Version 		:1 Date       		Developer  				Description
*------------------------------------------------------------------------------------------------------------------
*1.0    		11/30/2021     Dileep Chinthala      Initial Creation      
*2.0    		06/30/2023     Dileep Chinthala      Initial Creation                                                 
*
**********************************************************************************************************************/
@isTest 
public class OppQuickQuoteTest {
    
    @isTest  
    static void UpdateSNEToQuoteLineItems_Test4() {
        List<Product2> lstProduct2 = new List<Product2>();
        id pricebookId = Test.getStandardPricebookId();
        test.startTest();
        
         String globalstrRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Global'].Id;

		String masterstrRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Master'].Id;

        Account objAcc1 = new Account();
		objAcc1.Name = 'testaccount';
		objAcc1.OwnerId = userinfo.getUserId();
		objAcc1.Legal_Street__c = 'test';
		objAcc1.Legal_City__c = 'test';
		objAcc1.Legal_State__c = 'test';
		objAcc1.ShippingStreet = 'test';
		objAcc1.ShippingCity = 'NY';
		objAcc1.ShippingState = 'New York';
		objAcc1.BillingStreet = 'test';
		objAcc1.BillingCity = 'NY';
		objAcc1.BillingState = 'New York';
        objAcc1.RecordTypeId=globalstrRecordTypeId;
		insert objAcc1;
        
        Account testAccount = new Account();
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
        testAccount.RecordTypeId=masterstrRecordTypeId;
        testAccount.ParentId=objAcc1.id;
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
        
     /*   Account testSAccount = new Account();
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
         testAccount.RecordTypeId=masterstrRecordTypeId;
        testAccount.ParentId=objAcc1.id;
        insert testSAccount;*/
        
        Opportunity opp = new Opportunity();
        opp.Name = 'RefreshTestOpp';
        opp.AccountId = testAccount.id;
        Date d1=Date.newInstance(2019, 05, 11);
        opp.CloseDate=d1;
        opp.StageName='Investigating';
        opp.CPE_Product__c='No';
        opp.ftr_NumberOfQuickQuotes__c = 1;
        opp.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Lightning').getRecordTypeId();
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
        oQuote.ftr_QuoteCreationStatus__c = 'Completed';
        oQuote.IsSyncing__c = true;
        insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
        oQLI.QuoteId = oQuote.id;
        oQLI.PricebookEntryId = standardPrice.id;
        oQLI.vlocity_cmt__ServiceAccountId__c = testAccount.id;
        oQLI.Quantity = 1;
        oQLI.UnitPrice = 34.50;
        oQLI.Term__c = '24 Months';
        oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
        oQLI.Product2Id = lstProduct2[0].Id;
        oQLI.vlocity_cmt__RecurringCharge__c = 25.00;
        oQLI.vlocity_cmt__BaseRecurringCharge__c = 30.00;
        oQLi.ftr_isApplyDiscount__c = true;
        oQLi.vlocity_cmt__OneTimeCharge__c = 123;
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
        
        OpportunityQuickQuoteController oqc = new OpportunityQuickQuoteController();
        CreateQuickQuote_Controller cqc = new CreateQuickQuote_Controller();
        
        String quoteIdd='0Q011000000TclPCAS';
        String productFamilyy='UCF';
        Map<string,Object> inputMap = new Map<string,Object>{
            'recordId'=> opp.id,
                'ProductFamily' => productFamilyy,
                'summaryQuote' => true
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        
        oqc.invokeMethod('CreateQuickQuote', inputMap, outputMap, options);
        cqc.init(opp.id);
        
        test.stopTest();
        
    }
    
  }