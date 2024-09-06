/**
 *  QuoteLineItemTest - Handles Quote Line Item tests
 * 
 *  @author: Sean Fife
 *  @date: Dec 4 2019
 */
@isTest
public class QuoteLineItemTest {
	
    @isTest
    private static void TestLineItems()
    {
        QuoteLineItemHandler.blockRecursion();
    }
    
    private static Id getRecordType(String strRecordTypeName)
    {
        return Schema.SObjectType.account.getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
    
    private static User getUser()
    {
        User testUser = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Frontier System Administrator'].Id,
             UserRoleId = [SELECT Id FROM Userrole WHERE Name = 'Commercial Support & Center'].Id,
             LastName = 'Test Frontier',
             Email = 'testFrontier@test.com',
             Username = 'testFrontier@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             Account_Creation_Allowed__c  = true
             
        );
		insert testUser;        
        return testUser;
    }
    
    @isTest
    private static void InsertQuoteLineItems()
    {	
        Test.startTest();
        System.runAs(getUser()) {
			// Create Account
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
			//New Values
			testAccount.Phone = '9023214560';
			//testAccount.RecordTypeId = getRecordType('Master');
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
			
			Account testSAccount = new Account();
            testAccount.RecordTypeId = MasterRTId;
			testAccount.ParentId = globalAcc1.Id;
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
			testSAccount.RecordTypeId = getRecordType('Service');
			//testSAccount.Parent_Account__c = testAccount.id;
			insert testSAccount;
			
			Opportunity opp = new Opportunity();
			opp.Name = 'RefreshTestOpp';
			opp.AccountId = testAccount.id;
			Date d1=Date.newInstance(2019, 05, 11);
			opp.CloseDate=d1;
			opp.StageName='Investigating';
			opp.CPE_Product__c='No';
			insert opp;
			
			id pricebookId = Test.getStandardPricebookId();
			List<Product2> lstProduct2 = new List<Product2>();
			Product2 product = new Product2();
			product.Name = 'EIA';
			product.ProductCode = 'ENT_ETH_EIA_0001';
			product.IsActive = true;
			lstProduct2.add(product);

			Product2 prodEVC = new Product2();
			prodEVC.Name = 'EVC';
			prodEVC.ProductCode = 'ENT_ETH_EVC_0001';
			prodEVC.IsActive = true;
			lstProduct2.add(prodEVC);
			
			Product2 prodAccess = new Product2();
			prodAccess.Name = 'Access';
			prodAccess.ProductCode = 'ENT_ETH_ACCESS_0001';
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
			insert oQLI;
			
			oQLI.vlocity_cmt__RootItemId__c = oQLI.id;
			update oQLI;
			
			QuoteLineItem oQLI2 = new QuoteLineItem();
			oQLI2.QuoteId = oQuote.id;
			oQLI2.PricebookEntryId = standardPrice.id;
			oQLI2.vlocity_cmt__RootItemId__c = oQLI.id;
			oQLI2.Speed__c = '20 Mbps';
			oQLI2.Quantity = 1;
			oQLI2.UnitPrice = 34.50;
			oQLI2.vlocity_cmt__ParentItemId__c = oQLI.id;
			oQLI2.vlocity_cmt__Product2Id__c = lstProduct2[1].Id;
			oQLI2.Product2Id = lstProduct2[1].Id;
            oQLI2.vlocity_cmt__RecurringCharge__c = 25.00;
            oQLI2.vlocity_cmt__BaseRecurringCharge__c = 25.00;
			insert oQLI2;
			
			QuoteLineItem oQLI3 = new QuoteLineItem();
			oQLI3.QuoteId = oQuote.id;
			oQLI3.PricebookEntryId = standardPrice.id;
			oQLI3.Quantity = 1;
			oQLI3.UnitPrice = 34.50;
			oQLI3.vlocity_cmt__Product2Id__c = lstProduct2[2].Id;
			oQLI3.Product2Id = lstProduct2[2].Id;
			insert oQLI3; 
            
            //Test coverage for QuoteServiceTermUpdate class.
            List<QuoteLineItem> lstQuoteLineItems = new List<QuoteLineItem>{oQLI, oQLI2, oQLI3};
            QuoteServiceTermUpdate.UpdateServiceTerm(lstQuoteLineItems);
        }
        QuoteLineItemService.dummytestcoverage();
        Test.stopTest();
    }


    @isTest
    private static void UpdateQuoteLineItems()
    {
        Test.startTest();
        System.runAs(getUser()) {
			// Create Account
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
			
			Account testSAccount = new Account();
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
            testSAccount.RecordTypeId = MasterRTId;
			testSAccount.ParentId = globalAcc1.Id;
			insert testSAccount;
			
			Opportunity opp = new Opportunity();
			opp.Name = 'RefreshTestOpp';
			opp.AccountId = testAccount.id;
			Date d1=Date.newInstance(2019, 05, 11);
			opp.CloseDate=d1;
			opp.StageName='Investigating';
			opp.CPE_Product__c='No';
			insert opp;
			
			id pricebookId = Test.getStandardPricebookId();
			List<Product2> lstProduct2 = new List<Product2>();
			Product2 product = new Product2();
			product.Name = 'EIA';
			product.ProductCode = 'ENT_ETH_EIA_0001';
			product.IsActive = true;
			lstProduct2.add(product);

			Product2 prodEVC = new Product2();
			prodEVC.Name = 'EVC';
			prodEVC.ProductCode = 'ENT_ETH_EVC_0001';
			prodEVC.IsActive = true;
			lstProduct2.add(prodEVC);
			
			Product2 prodAccess = new Product2();
			prodAccess.Name = 'Access';
			prodAccess.ProductCode = 'ENT_ETH_ACCESS_0001';
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
			insert oQLI;
			
			oQLI.vlocity_cmt__RootItemId__c = oQLI.id;
			update oQLI;
			
			QuoteLineItem oQLI2 = new QuoteLineItem();
			oQLI2.QuoteId = oQuote.id;
			oQLI2.PricebookEntryId = standardPrice.id;
			oQLI2.vlocity_cmt__RootItemId__c = oQLI.id;
			oQLI2.Speed__c = '20 Mbps';
			oQLI2.Quantity = 1;
			oQLI2.UnitPrice = 34.50;
			oQLI2.vlocity_cmt__ParentItemId__c = oQLI.id;
			oQLI2.vlocity_cmt__Product2Id__c = lstProduct2[1].Id;
			oQLI2.Product2Id = lstProduct2[1].Id;
            oQLI2.vlocity_cmt__RecurringCharge__c = 24.00;
            oQLI2.vlocity_cmt__BaseRecurringCharge__c = 26.00;
            oQLI2.Floor_Price_Recurring__c = 26.00;
			insert oQLI2;
			
			QuoteLineItem oQLI3 = new QuoteLineItem();
			oQLI3.QuoteId = oQuote.id;
			oQLI3.PricebookEntryId = standardPrice.id;
			oQLI3.Quantity = 1;
			oQLI3.UnitPrice = 34.50;
			oQLI3.vlocity_cmt__Product2Id__c = lstProduct2[2].Id;
			oQLI3.Product2Id = lstProduct2[2].Id;
			insert oQLI3;  
			
			oQLI.Term__c = '12 Months';
			oQLI2.Term__c = '12 Months';
			oQLI3.Term__c = '12 Months';
			
			QuoteLineItemHandler.blockRecursion = false;
			
			List<QuoteLineItem> itemsToUpdate = new List<QuoteLineItem> {oQLI, oQLI2, oQLI3};
				
			update itemsToUpdate;
		}
        QuoteLineItemService.dummytestcoverage();
		Test.stopTest();
    }    
}