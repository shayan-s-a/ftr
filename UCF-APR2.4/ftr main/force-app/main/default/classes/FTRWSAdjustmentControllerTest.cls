@isTest
public class FTRWSAdjustmentControllerTest {
    
        @isTest(seealldata=true)
    public static void codeCoverage(){

        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId= globalRecId;
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        String gAddressStr = '{"actionStr":"CREATE","streetNo":"2001","streetName":"Solar Drive","city":"Oxnard", '+ 
            '"state":"California","unitNo":"","zipcode":"93036","gLat":34.2203155,"gLng":-119.1458787}';
        FTRWSGoogleAddress gAddress = (FTRWSGoogleAddress)JSON.deserialize(gAddressStr, FTRWSGoogleAddress.class);
        FTRWSAddress__c  address = new FTRWSAddress__c();
        address.Street_Number__c = gAddress.streetNo;
        address.Street_Name__c = gAddress.streetName;
        address.Street_Number__c = gAddress.streetNo;
        address.City__c = gAddress.city;
        address.State__c = gAddress.state;
        address.Zip_Code__c = gAddress.zipcode;
        address.Opportunity_ID__c = opp.id;
        address.G_Latitude__c = gAddress.gLat;
        address.G_Longitude__c = gAddress.gLng;
        
        insert address;
        
        Id prodRecId = [select id,name,developername from recordtype where sobjecttype='product2' and developername='Carrier_Service' LIMIT 1]?.Id;
        
        Product2 product = [SELECT Id, Name, evcspeed__c, Family, Quantity__c,mrcusoc__c , RecordTypeId from PRODUCT2 where RecordTypeId=:prodRecId LIMIT 1];
        /*
        Product2 product = new Product2();
        product.Name = 'EIA 200M';
        product.evcspeed__c = '200M';
        product.Family = 'FOTS';
        product.Quantity__c = '1';
        product.mrcusoc__c = 'EIAUSOC';
        product.RecordTypeId = prodRecId;
        insert product;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry priceEntrylist = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product.Id,UnitPrice = 12000, IsActive = true);
        insert priceEntrylist;
        */
        
        FTRWSAcna__c acna = new FTRWSAcna__c();
        acna.ACNA__c = 'GIM';
        acna.Company__c = acc.id;
        acna.Name = 'GIM';
        INSERT acna;
        
        FTRWSPnum__c pnum = new FTRWSPnum__c();
        pnum.PNum__c = 'EIAV001GIM300484';
        pnum.Name = 'EIAV001GIM300484';
        pnum.Wholesale_ACNA__c = acna.Id;
        INSERT pnum;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name='Test Opp2';
        opp2.StageName='Decision';
        opp2.AccountId=acc.id;
        opp2.CloseDate= System.today();
        opp2.ForecastCategoryName='Commit';
        opp2.Wholesale_ACNA__c = acna.Id;
        opp2.Wholesale_Pnum__c = pnum.Id;
        //opp2.Pricebook2Id = pricebookId;//customPB.Id;
        insert opp2;
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'Carrier_Service' AND SobjectType = 'SterlingQuote__c'];        
        SterlingQuote__c quote = new SterlingQuote__c();
        quote.Name = 'Demo';
        quote.OpportunityId__c = opp2.Id;
        quote.QuoteType__c = 'New';
        quote.RecordTypeId = recordtypeid[0].Id;
        quote.ExpirationDate__c = System.today();
        
        insert quote;        
        
        //System.debug('pricebookId:' + pricebookId);
        //System.debug('opp.Pricebook2Id: ' + opp2.Pricebook2Id);
        
        SterlingQuoteItem__c quoteItem = new SterlingQuoteItem__c();
        quoteItem.Name = 'EIA 200M';
        quoteItem.Description__c = 'EIA 200M';
        quoteItem.SterlingQuote__c = quote.Id;
        quoteItem.Products__c = product.Id;

        quoteItem.Quantity__c = 1;
        quoteItem.StandardMRC__c = decimal.valueOf('1000.00');
        quoteItem.AdjustedMRC__c = decimal.valueOf('9000.00');
        quoteItem.Adjusted_MRC_Notes__c = 'MRC Discount TEST';
        quoteItem.Adjusted_NRC_Notes__c = 'NRC Discount TEST';
        quoteItem.StandardNRC__c = decimal.valueOf('50.00');
        quoteItem.AdjustedNRC__c = decimal.valueOf('15.00');
        quoteItem.ItemCode__c = product.mrcusoc__c;
        quoteItem.TermLength__c = 36;        
        
        quoteItem.SA_StreetNrFirst__c = address.Street_Number__c;
        quoteItem.SA_StreetName__c = address.Street_Name__c;
        quoteItem.SA_UnitNumber__c = address.Unit_Number__c;
        quoteItem.Zipcode__c = address.Zip_Code__c;
        quoteItem.Locality__c = address.City__c;
        quoteItem.DSAT_AddressID__c = address.Id__c;
        quoteItem.ST_AddressID__c = address.Id;
        INSERT quoteItem;
        
        FTRWSDiscountRequest req = new FTRWSDiscountRequest();
        req.quoteItem = quoteItem;
        req.recurringType = 'MRC';
        req.discountType = 'AMOUNT';
        req.discountVal = 100.00;
        req.mrcDiscountNotes = quoteItem.Adjusted_MRC_Notes__c;
        String reqStr = Json.serialize(req);
        FTRWSAdjustmentController.getQuoteLineItemDiscountInfo(reqStr);
        FTRWSAdjustmentController.applyDiscount(reqStr);
        FTRWSAdjustmentController.removeDiscount(reqStr);
        
        req.discountType = 'OVERRIDE';
        req.discountVal = 800.00;
        reqStr = Json.serialize(req);
        FTRWSAdjustmentController.applyDiscount(reqStr);
        
        req.discountType = 'PERCENTAGE';
        req.discountVal = 10;
        reqStr = Json.serialize(req);
        FTRWSAdjustmentController.applyDiscount(reqStr);

        
        req = new FTRWSDiscountRequest();
        req.quoteItem = quoteItem;
        req.recurringType = 'NRC';
        req.discountType = 'AMOUNT';
        req.discountVal = 15.00;
        req.NrcDiscountNotes = quoteItem.Adjusted_nRC_Notes__c;
        reqStr = Json.serialize(req);
        FTRWSAdjustmentController.getQuoteLineItemDiscountInfo(reqStr);
        FTRWSAdjustmentController.applyDiscount(reqStr);
        FTRWSAdjustmentController.removeDiscount(reqStr); 
        
        req.discountType = 'OVERRIDE';
        req.discountVal = 800.00;
        reqStr = Json.serialize(req);
        FTRWSAdjustmentController.applyDiscount(reqStr);
        
        req.discountType = 'PERCENTAGE';
        req.discountVal = 10;
        reqStr = Json.serialize(req);
        FTRWSAdjustmentController.applyDiscount(reqStr);
        
    }

}