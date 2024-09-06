/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
**/
@isTest //(seealldata=true)
private class GenerateProposalExtension_Test {

    static {
        update new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
    }
	static testMethod void myTest() {
		Test.startTest();
    //Id recortypeid=Schema.sObjectType.Case.getRecordTypeInfosByName().get('Global').getRecordTypeId();
	String globalstrRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Global'].Id;

	String masterstrRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Master'].Id;

		//Insrt the data
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
        
        
		Account objAcc = new Account();
		objAcc.Name = 'testaccount';
        objAcc.ParentId=objAcc1.id;
		objAcc.OwnerId = userinfo.getUserId();
		objAcc.Legal_Street__c = 'test';
		objAcc.Legal_City__c = 'test';
		objAcc.Legal_State__c = 'test';
		objAcc.ShippingStreet = 'test';
		objAcc.ShippingCity = 'NY';
		objAcc.ShippingState = 'New York';
		objAcc.BillingStreet = 'test';
		objAcc.BillingCity = 'NY';
		objAcc.BillingState = 'New York';
        objAcc.RecordTypeId=masterstrRecordTypeId;
		insert objAcc;
        
        

		Opportunity objOpp = new Opportunity();
		objOpp.Name = 'test';
		objOpp.AccountId = objAcc.id;
		objOpp.StageName = 'verbal commit';
		objOpp.CloseDate = date.today();
		objOpp.Expected_Billed_Date__c = date.today();
		objOpp.OwnerId = userinfo.getUserId();
		insert objOpp;

		SterlingQuote__c objSQ = new SterlingQuote__c();
		objSQ.name = 'test';
		objSQ.OpportunityId__c = objOpp.id;
        objSQ.ExpirationDate__c = date.today();
        objSQ.RecordTypeId= [SELECT Id FROM RecordType WHERE SobjectType='SterlingQuote__c' AND Name='SFA'].Id;
		objSQ.OwnerId = userinfo.getUserId();
		objSq.IsSyncing__c = true;
        insert objSQ;

		Product2 objProduct2_1 = new Product2(
			Name = '(Challenger)',
			IsActive = true,
			SKU__c = '',
			Item_Code__c = 'Code',
			Item_Rate__c = 10.00,
			MajorProduct__c = true,
			Item_Type__c = 'A',
			ProductCode = '1234',
			Grandfathered_Product__c = ''
		);
		insert objProduct2_1;

		PricebookEntry objPricebookEntry1 = new PricebookEntry(
			UnitPrice = 1000,
			pricebook2ID = [SELECT Id FROM Pricebook2 WHERE IsStandard = true limit 1].Id,
			IsActive = true,
			UseStandardPrice = false,
			Product2Id = objProduct2_1.Id
		);
		insert objPricebookEntry1;

		SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
		objst.name = '(Challenger)';
		objst.Products__c = objProduct2_1.Id;
		objst.SterlingQuote__c = objSQ.id;
		objst.IsInFrontierFootprint__c = false;
		objst.OverallStatus__c = 'pending';
        objst.DiscountType__c = 'ICB';
        objst.CPE_NRC_Price__c = 1;
        objst.Description__c = 'Running Test Class';
		objst.ApprovalTerritory__c = 'Indiana';
		objst.ApprovalRouting__c = 'Customer Build';
		objst.ApprovalRegion__c = 'IN';
		objst.StandardMRC__c = 10.00;
		objst.StandardNRC__c = 10.00;
		objst.AdjustedMRC__c = 10.00;
		objst.AdjustedNRC__c = 10.00;
		// MGG319 2/11/2019 Added net New MRR and Qty to clear error on Generate proposal Test class
		objst.NetNewMRR__c = 240.00;
		objst.Quantity__c = 2;
		objst.OwnerId = userinfo.getUserId();
		objst.ItemOwner__c = userinfo.getUserId();
		objst.ApprovalPriority__c = 'Normal';
		objst.Locality__c = 'Indiana';
		objst.StateProvince__c = 'IN';
		// objst.State__c='IN'; 10/16 raj
		objst.NXX__c = '10';
		objst.MinorLine__c = 0.0;
		objst.SetNextApprover__c = true;
		objst.OverallStatus__c = '';
		objst.SIFT_Required__c = true;
		objst.SIFT_InquiryId__c = '1234';
		objst.Quantity__c = 1;
         insert objst;
		ApexPages.currentPage().getParameters().put('oppId', objOpp.id);
		ApexPages.currentPage().getParameters().get('proposalFuture');
		ApexPages.currentPage().getParameters().get('proposalCompany');
		SterlingQuoteItem__c obj = new SterlingQuoteItem__c();
		obj.Id = objst.Id;
		obj.DiscountType__c = 'SVP';
		update objst;

		GenerateProposalExtension objgpe = new GenerateProposalExtension();
		GenerateProposalExtension.SteringQuoteItemExtension GPsqi = new GenerateProposalExtension.SteringQuoteItemExtension();
		GPsqi.Id = '12234';
		GPsqi.ProductId = '1234';
		GPsqi.Quantity = 10;
		GPsqi.TermLength = 12;
		GPsqi.CPE_NRC_Price = 123;
		GPsqi.StandardNRC = 123;
		GPsqi.ProductName = 'Test';
		GPsqi.standardMRC = 12;
        
        ApexPages.currentPage().getParameters().put('oppId', objOpp.id);
		ApexPages.currentPage().getParameters().get('proposalFuture');
		ApexPages.currentPage().getParameters().get('proposalCompany');
		objSQ.RecordTypeId= [SELECT Id FROM RecordType WHERE SobjectType='SterlingQuote__c' AND Name='Sterling'].Id;
		objSQ.IsSyncing__c = true;
        update objSQ;

		GenerateProposalExtension testGPE = new GenerateProposalExtension();
		Test.StopTest();
	}

	static testMethod void myTest2() {
		Test.startTest();
		String globalstrRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Global'].Id;

	String masterstrRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Master'].Id;

		//Insrt the data
		//Insrt the data
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
        
        
		Account objAcc = new Account();
		objAcc.Name = 'testaccount';
        objAcc.ParentId=objAcc1.id;
		objAcc.OwnerId = userinfo.getUserId();
		objAcc.Legal_Street__c = 'test';
		objAcc.Legal_City__c = 'test';
		objAcc.Legal_State__c = 'test';
		objAcc.ShippingStreet = 'test';
		objAcc.ShippingCity = 'NY';
		objAcc.ShippingState = 'New York';
		objAcc.BillingStreet = 'test';
		objAcc.BillingCity = 'NY';
		objAcc.BillingState = 'New York';
        objAcc.RecordTypeId=masterstrRecordTypeId;
		insert objAcc;

		Opportunity objOpp = new Opportunity();
		objOpp.Name = 'test';
		objOpp.AccountId = objAcc.id;
		objOpp.StageName = 'verbal commit';
		objOpp.CloseDate = date.today();
		objOpp.Expected_Billed_Date__c = date.today();
		objOpp.OwnerId = userinfo.getUserId();
		insert objOpp;

		SterlingQuote__c objSQ = new SterlingQuote__c();
		objSQ.name = 'test';
		objSQ.OpportunityId__c = objOpp.id;
		objSQ.ExpirationDate__c = date.today();
		objSQ.OwnerId = userinfo.getUserId();
		objSq.IsSyncing__c = true;
		insert objSQ;

		Product2 objProduct2_1 = new Product2(
			Name = 'Testing Name',
			IsActive = true,
			SKU__c = '',
			Item_Code__c = 'Code',
			Item_Rate__c = 10.00,
			MajorProduct__c = true,
			Item_Type__c = 'A',
			ProductCode = '1234',
			Grandfathered_Product__c = ''
		);
		insert objProduct2_1;

		PricebookEntry objPricebookEntry1 = new PricebookEntry(
			UnitPrice = 1000,
			pricebook2ID = [SELECT Id FROM Pricebook2 WHERE IsStandard = true limit 1].Id,
			IsActive = true,
			UseStandardPrice = false,
			Product2Id = objProduct2_1.Id
		);
        insert objPricebookEntry1;

		SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
		objst.name = 'test';
		objst.Products__c = objProduct2_1.Id;
		objst.SterlingQuote__c = objSQ.id;
		objst.IsInFrontierFootprint__c = false;
		objst.OverallStatus__c = 'pending';
		objst.DiscountType__c = 'ICB';
        objst.Description__c = 'Running Test Class';
		objst.ApprovalTerritory__c = 'Indiana';
		objst.ApprovalRouting__c = 'Customer Build';
		objst.ApprovalRegion__c = 'IN';
		objst.StandardMRC__c = 10.00;
		objst.StandardNRC__c = 10.00;
		objst.AdjustedMRC__c = 10.00;
		objst.AdjustedNRC__c = 10.00;
		// MGG319 2/11/2019 Added net New MRR and Qty to clear error on Generate proposal Test class
		objst.NetNewMRR__c = 240.00;
		objst.Quantity__c = 2;
		objst.OwnerId = userinfo.getUserId();
		objst.ItemOwner__c = userinfo.getUserId();
		objst.ApprovalPriority__c = 'Normal';
		objst.Locality__c = 'Indiana';
		objst.StateProvince__c = 'IN';
		// objst.State__c='IN'; 10/16 raj
		objst.NXX__c = '10';
		objst.MinorLine__c = 0.0;
		objst.SetNextApprover__c = true;
		objst.OverallStatus__c = 'Approved';
		objst.SIFT_Required__c = true;
		objst.SIFT_InquiryId__c = '1234';
		objst.Quantity__c = 1;
		insert objst;

		GenerateProposalExtension.SteringQuoteItemExtension oliWrapper = new GenerateProposalExtension.SteringQuoteItemExtension(
			new OpportunityLineItem(
				Quantity = 1,
				Term_Months__c = 12,
				DiscountType__c = 'BDT',
				Renewal_MRR__c = 1,
				CPQ_NetNewMRR__c = 1,
				CPE_Gross_Margin__c = 1,
				UnitPrice = 1,
				CPE_NRC_Price__c = 1,
				Speed__c = '200 Mbps',
				vlocity_cmt__OneTimeCharge__c = 1,
				vlocity_cmt__EffectiveQuantity__c = 1,
				Product2Id = objProduct2_1.Id,
				vlocity_cmt__RecurringCharge__c = 1,
				vlocity_cmt__ServiceAccountId__c = objAcc.Id,
				OpportunityId = objOpp.Id,
				Opportunity_Sync__c = 'Vlocity',
				vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }'
			)
		);

		//  PricebookEntry pbEntry = [SELECT Id, Product2Id, Product2.Id, Product2.MajorProduct__c, Product2.Name FROM PriceBookEntry WHERE PriceBook2.isStandard=true AND Product2Id =: objst.Products__c];
		ApexPages.currentPage().getParameters().put('oppId', objOpp.id);
		ApexPages.currentPage().getParameters().get('proposalFuture');
		ApexPages.currentPage().getParameters().get('proposalCompany');
		SterlingQuoteItem__c obj = new SterlingQuoteItem__c();
		obj.Id = objst.Id;
		obj.DiscountType__c = 'ISB';
		objst.OverallStatus__c = 'Approved';
		update objst;
		//GenerateProposalExtension.strQuoteItemsExtensions sterIE = new GenerateProposalExtension.strQuoteItemsExtensions();

		GenerateProposalExtension objgpe = new GenerateProposalExtension();
		GenerateProposalExtension.SteringQuoteItemExtension GPsqi = new GenerateProposalExtension.SteringQuoteItemExtension();
		GPsqi.Id = '12234';
		GPsqi.ProductId = '1234';
		GPsqi.Quantity = 10;
		GPsqi.TermLength = 12;
		GPsqi.CPE_NRC_Price = 123;
		GPsqi.StandardNRC = 123;
		GPsqi.ProductName = 'Test';
		GPsqi.standardMRC = 12;

		/*     objst.DiscountType__c ='';
        update objst;
        GenerateProposalExtension objgpe1 = new GenerateProposalExtension();        
        
  /*      objst.OverallStatus__c = 'Approved';
        objst.DiscountType__c ='ISB';
        update objst;
        GenerateProposalExtension objgpe2 = new GenerateProposalExtension(); 
        
        List<SterlingQuoteItem__c> majorItemList ;
        //SterlingQuoteItem__c var = majorItemList; */

		Test.StopTest();
	}
}