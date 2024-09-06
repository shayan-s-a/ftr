/**
* @description       : This test class covers the following Apex classes:
*      CalculateMRC_NRC_On_Quote_Items
* @author            : Vara Prasad
* @version           : 1
**/
@IsTest(seealldata=true)
public class CalculateMRC_NRC_On_Quote_ItemsTest {
    @IsTest
    public static void makeAndTestData() {  
        Id accountRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
        Account acc = new Account();
        acc.Name='testAccount';
        acc.recordtypeId = accountRecId;
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
        quote.Status__c = 'Needs Review';
        quote.CreatedDate = System.today();
        quote.IsSyncing__c = true;
        
        
        insert quote;
        
        Id prodRecId = [select id,name,developername from recordtype where sobjecttype='product2' and developername='Carrier_Service' LIMIT 1]?.Id;
        System.debug('prodRecId:'+ prodRecId);
        Product2 product = [SELECT Id, Name, Evcspeed__c, Family, MRCusoc__c, RecordTypeId FROM Product2 WHERE RecordTypeId =:prodRecId LIMIT 1];
		System.debug('product:'+ product);

        SterlingQuoteItem__c quoteItem = new SterlingQuoteItem__c();
        quoteItem.Name = 'EIA 200M';
        quoteItem.Description__c = 'EIA 200M';
        quoteItem.SterlingQuote__c = quote.Id;
        quoteItem.Products__c = product.Id;
        quoteItem.circuitType__c = 'EVC';
        quoteItem.Quantity__c = 1;
        quoteItem.StandardMRC__c = decimal.valueOf('1000.00');
        quoteItem.StandardNRC__c = decimal.valueOf('0.00');
        quoteItem.ItemCode__c = product.mrcusoc__c;
        quoteItem.TermLength__c = 36;  
        
        quoteItem.AdjustedMRC__c = 1250;
        quoteItem.AdjustedNRC__c = 650;
        
        quoteItem.SA_StreetNrFirst__c = address.Street_Number__c;
        quoteItem.SA_StreetName__c = address.Street_Name__c;
        quoteItem.SA_UnitNumber__c = address.Unit_Number__c;
        quoteItem.Zipcode__c = address.Zip_Code__c;
        quoteItem.Locality__c = address.City__c;
        quoteItem.DSAT_AddressID__c = address.Id__c;
        quoteItem.ST_AddressID__c = address.Id;
        quoteItem.StateProvince__c = address.State__c;
        quoteItem.Postcode__c = address.Zip_Code__c;
        quoteItem.NumInstallments__c = 2;
        //quoteItem.Pricebook_Entry_Id__c = customPBEntry.Id;
        INSERT quoteItem;
        
        
        /////////////////////////////////////////////////
        
        SterlingQuoteItem__c quoteItem2 = new SterlingQuoteItem__c();
        quoteItem2.Name = product.Name;
        quoteItem2.Description__c = product.Name;
        quoteItem2.SterlingQuote__c = quote.Id;
        quoteItem2.Products__c = product.Id;
        quoteItem2.Quantity__c = 1;
        quoteItem2.StandardMRC__c = decimal.valueOf('1000.00');
        quoteItem2.StandardNRC__c = decimal.valueOf('0.00');
        quoteItem2.ItemCode__c = product.mrcusoc__c;
        quoteItem2.TermLength__c = 36;        

        quoteItem2.AdjustedMRC__c = 1250;
        quoteItem2.AdjustedNRC__c = 650;

        
        quoteItem2.SA_StreetNrFirst__c = address.Street_Number__c;
        quoteItem2.SA_StreetName__c = address.Street_Name__c;
        quoteItem2.SA_UnitNumber__c = address.Unit_Number__c;
        quoteItem2.Zipcode__c = address.Zip_Code__c;
        quoteItem2.Locality__c = address.City__c;
        quoteItem2.DSAT_AddressID__c = address.Id__c;
        quoteItem2.ST_AddressID__c = address.Id;
        quoteItem2.StateProvince__c = address.State__c;
        quoteItem2.Postcode__c = address.Zip_Code__c;
        quoteItem2.NumInstallments__c = 2;
        //quoteItem2.Pricebook_Entry_Id__c = customPBEntry2.Id;
        INSERT quoteItem2; 
        List<Id> listId = new List<Id>();
        listId.add(quote.Id);
        Test.startTest();
        CalculateMRC_NRC_On_Quote_Items.updateMRCandNRC(listId);
        Test.stopTest();
    }
}