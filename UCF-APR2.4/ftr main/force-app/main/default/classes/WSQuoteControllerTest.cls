/**
* @description       : This test class covers the following Apex classes:
*       TBD_CLASS1
*       TBD_CLASS2
*       TBD_CLASS3
* @author            : TBD
* @version           : 7
**/
@isTest
public class WSQuoteControllerTest {
    
    
    @testSetup static void makeData() {
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
        Account acc = new Account();
        acc.Name='testAccount';
        acc.ParentId = globalAcc.Id;
        insert acc;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 customPB = new Pricebook2();
        customPB.IsActive = true;
        customPB.Id = Test.getStandardPricebookId();
        update customPB;
        
        
        RecordType recordtype = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name = 'Carrier Service' AND SobjectType = 'Product2' LIMIT 1]; 
        Product2 product = new Product2();
        product.Name = 'EIA 200M';
        product.evcspeed__c = '200M';
        product.Family = 'EIA';
        product.Quantity__c = '1';
        product.mrcusoc__c = 'EIAUSOC';
        product.RecordTypeId = recordType.Id;
        product.isActive = TRUE;
        
        insert product;
        
        PricebookEntry customPBEntry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product.Id,UnitPrice = 20000, IsActive = true);
        insert customPBEntry;
        
        System.debug('********customPB: ' + customPB.isStandard);
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        opp.Project_Id__c = 'TEST1234';
        opp.Pricebook2Id = customPB.Id;//pricebookId;
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
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE Name = 'Carrier Service' AND SobjectType = 'SterlingQuote__c'];        
        SterlingQuote__c quote = new SterlingQuote__c();
        quote.Name = 'Demo';
        quote.OpportunityId__c = opp.Id;
        quote.QuoteType__c = 'New';
        quote.RecordTypeId = recordtypeid[0].Id;
        quote.ExpirationDate__c = System.today();
        quote.Status__c = 'Needs Review';
        
        insert quote;
        
        System.debug('pricebookId:' + pricebookId);
        System.debug('opp.Pricebook2Id: ' + opp.Pricebook2Id);
        
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
        quoteItem.StateProvince__c = address.State__c;
        quoteItem.Postcode__c = address.Zip_Code__c;
        quoteItem.NumInstallments__c = 2;
        quoteItem.Pricebook_Entry_Id__c = customPBEntry.Id;
        INSERT quoteItem;
    }
    
    
    @isTest
    public static void codeCoverageForSubmitApproval(){
        SterlingQuote__c quote = [Select Id from SterlingQuote__c limit 1];
        WSQuoteController.submitWSQuoteForApproval(quote.Id);
    }
    
    @isTest
    public static void codeCoverage(){
        
        SterlingQuote__c quote = [Select Id from SterlingQuote__c limit 1];
        FTRWSAddress__c  address = [Select Id from FTRWSAddress__c limit 1];
        SterlingQuoteItem__c quoteItem = [Select Id from SterlingQuoteItem__c limit 1];
        Test.startTest();    
        WSQuoteController.getQuoteItemLines(quote.Id, address.Id);
        WSQuoteController.getOpportunityAddressList(quote.Id);
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void codeCoverageSyncQuote(){
        
        SterlingQuote__c quote = [Select Id from SterlingQuote__c limit 1];
        FTRWSAddress__c  address = [Select Id from FTRWSAddress__c limit 1];
        SterlingQuoteItem__c quoteItem = [Select Id from SterlingQuoteItem__c limit 1];
        Test.startTest();    
        WSQuoteController.getSyncQuoteWithOpportunity(quote.Id);
        WSQuoteController.getUnSyncQuoteWithOpportunity(quote.Id);
        Test.stopTest();
    }    
    
    @isTest
    public static void codeCoverageRemoveItem(){
        
        SterlingQuote__c quote = [Select Id from SterlingQuote__c limit 1];
        FTRWSAddress__c  address = [Select Id from FTRWSAddress__c limit 1];
        SterlingQuoteItem__c quoteItem = [Select Id from SterlingQuoteItem__c limit 1];
        Test.startTest();    
        WSQuoteController.removeItem(quoteItem.Id);
        Test.stopTest();
    }        
    
    
}