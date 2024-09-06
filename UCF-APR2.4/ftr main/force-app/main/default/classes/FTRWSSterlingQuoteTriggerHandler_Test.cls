/**
* @description       : This test class covers the following Apex Trigger:
*      FTRWSSterlingQuoteTrigger
* @author            : Paa512
* @version           : 4 
*
**/
@isTest(seealldata=true)
public class FTRWSSterlingQuoteTriggerHandler_Test {
    
    private static Opportunity opp2;
    private static SterlingQuote__c quote;
    
    @isTest
    private static void sterlingQuoteTriggerHandlerTest() {
        prepareTestData();
        
    }
    
    
    
    @isTest
    public static void prepareTestData(){
        
         Id carrierRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;      
       
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierRecId;
        insert acc;
        
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
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        opp.Wholesale_ACNA__c = acna.Id;
        opp.Wholesale_Pnum__c = pnum.Id;
      
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
        Product2 product = [SELECT Id, Name, Evcspeed__c, Family, MRCusoc__c, RecordTypeId FROM Product2 WHERE RecordTypeId =:prodRecId LIMIT 1];


        opp2 = new Opportunity();
        opp2.Name='Test Opp2';
        opp2.StageName='Decision';
        opp2.AccountId=acc.id;
        opp2.CloseDate= System.today();
        opp2.ForecastCategoryName='Commit';
        opp2.Wholesale_ACNA__c = acna.Id;
        opp2.Wholesale_Pnum__c = pnum.Id;
      
        insert opp2;
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'Carrier_Service' AND SobjectType = 'SterlingQuote__c'];        
        quote = new SterlingQuote__c();
        quote.Name = 'Demo';
        quote.OpportunityId__c = opp2.Id;
        quote.QuoteType__c = 'New';
        quote.RecordTypeId = recordtypeid[0].Id;
        quote.ExpirationDate__c = System.today();
        quote.Status__c = 'Draft';
        insert quote;        
        
        List<SterlingQuoteItem__c> quoteItems = new List<SterlingQuoteItem__c>();
        for(Integer i=0; i<4; i++) {

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
        quoteItem.OverallStatus__c = 'Pending';
            quoteItems.add(quoteItem);
        }
        
        INSERT quoteItems;
        
        quote.Status__c = 'Approved';
        update quote;
        
        quote.Status__c = 'Rejected';
        update quote;

       SterlingQuote__c tmpQuote =  [Select Id, status__c from SterlingQuote__c where Id =: quote.Id];
        System.debug('Quote status after inserting the quote item with adjusted price is: ' + tmpQuote.Id + '---' + tmpQuote.Status__c + ' tmpQuote.RecordType Id:' + quote.RecordTypeId);

    }
}