/**
 * @description       : This test class covers the following Apex classes:
 *      WSProductCatalogController
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 5
**/
@isTest
public class WSProductCatalogControllerTest {
    
    @isTest
    public static void codeCoverage(){
       Id carrierSerRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;  
    
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierSerRecId;
        insert acc;

        RecordType recordtype = [SELECT Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'Carrier_Service' AND SobjectType = 'Product2' LIMIT 1]; 
        
        Product2 product = new Product2();
        product.Name = 'EIA 200M';
        product.evcspeed__c = '200M';
        product.Speed_BW_Whls__c = '200M';
        product.Family = 'EIA';
        product.Quantity__c = '1';
        product.mrcusoc__c = 'EIAUSOC';
        product.RecordTypeId = recordType.Id;
        product.isActive = TRUE;
        
        insert product;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry priceEntrylist = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product.Id,UnitPrice = 12000, IsActive = true);
        insert priceEntrylist;
        
       FTRWSAcna__c acna = new FTRWSAcna__c();
       acna.Name='ATX';
        acna.Company__c = acc.id;
        insert acna;
        
 		FTRWSPnum__c pnum = new FTRWSPnum__c();
 		pnum.Name='EIA001';
		pnum.Wholesale_ACNA__c = acna.id;
		insert pnum;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name='Test Opp2';
        opp2.StageName='Decision';
        opp2.AccountId=acc.id;
        opp2.CloseDate= System.today();
        opp2.ForecastCategoryName='Commit';
        opp2.Pricebook2Id = pricebookId;//customPB.Id;
       opp2.Wholesale_Pnum__c = pnum.id;
       opp2.Wholesale_ACNA__c=acna.id;
        insert opp2;
        
        
        String gAddressStr = '{"actionStr":"CREATE","streetNo":"2001","streetName":"Solar Drive","city":"Oxnard", '+ 
            '"state":"California","unitNo":"","zipcode":"93036","gLat":34.2203155,"gLng":-119.1458787}';
        
        FTRWSGoogleAddress gAddress = (FTRWSGoogleAddress)JSON.deserialize(gAddressStr, FTRWSGoogleAddress.class);
        FTRWSAddress__c  address = new FTRWSAddress__c();
        address.Street_Number__c = gAddress.streetNo;
        address.Street_Name__c = gAddress.streetName;
        address.Street_Number__c = gAddress.streetNo;
        address.City__c = gAddress.city;
        address.MRC_Discount_Type__c = 'Percentage';
        address.MRC_Discount__c = 200;
        address.NRC_Discount_Type__c = 'Percentage';
        address.NRC_Discount__c = 200;
        address.State__c = gAddress.state;
        address.Zip_Code__c = gAddress.zipcode;
        address.Opportunity_ID__c = opp2.id;
        address.G_Latitude__c = gAddress.gLat;
        address.G_Longitude__c = gAddress.gLng;
        
        insert address;
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'Carrier_Service' AND SobjectType = 'SterlingQuote__c'];        
        SterlingQuote__c quote = new SterlingQuote__c();
        quote.Name = 'Demo';
        quote.OpportunityId__c = opp2.Id;
        quote.QuoteType__c = 'New';
        quote.RecordTypeId = recordtypeid[0].Id;
        quote.ExpirationDate__c = System.today();        
        insert quote;
        
        System.debug('pricebookId:' + pricebookId);
        System.debug('opp.Pricebook2Id: ' + opp2.Pricebook2Id);
        
       SterlingQuoteItem__c quoteItem = new SterlingQuoteItem__c();
        quoteItem.Name = 'EIA 200M';
        quoteItem.Description__c = 'EIA 200M';
        quoteItem.SterlingQuote__c = quote.Id;
        quoteItem.Products__c = product.Id;
        quoteItem.Quantity__c = 1;
        quoteItem.StandardMRC__c = decimal.valueOf('1000.00');
        quoteItem.StandardNRC__c = decimal.valueOf('0.00');
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
        
        
        Test.startTest();
       Test.setMock(HttpCalloutMock.class, new FTRWSCVDRatesMock());
        WSProductCatalogController.getProductList(address.Id, quote.Id);
        WSProductCatalogController.addToQuote(quote.Id, address.Id, product.Name, 'EVC', '12', '0', '0', 'mrcUsoc', 'nrcUsoc', 'cvdSource', 'Silver', '3','EIA123',null);        						    
        WSProductCatalogController.getFormattedDsatSpeed('1000M');
        WSProductCatalogController.getFormattedDsatSpeed('5000m');
        WSProductCatalogController.getFormattedDsatSpeed('2G');
        WSProductCatalogController.getFormattedDsatSpeed('1g');
        
       WSProductCatalogController.isBDTRequired('200M', '1000M', address,'Silver');
       WSProductCatalogController.isBDTRequired('1000M', '500M', address,'Platinum');
        Test.stopTest();
       
    }
    
        @isTest
    public static void testGetTermlength() {
        
        Test.startTest();
       
        WSProductCatalogController.getTermLength('1');
        WSProductCatalogController.getTermLength('2');
        WSProductCatalogController.getTermLength('3');
        WSProductCatalogController.getTermLength('4');
        WSProductCatalogController.getTermLength('5');
        
        Test.stopTest();
    }
}