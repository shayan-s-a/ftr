/**
 * @description       : This test class covers the following Apex classes:
 *      FTRWSCVDController
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 14
 * **/
@isTest
public class FTRWSCVDControllerTest {
    
     @testSetup
    public static void dataSetup(){
  Id accountRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
        Account acc = new Account();
        acc.Name='testAccount';
        acc.recordtypeId = accountRecId;
        insert acc;
    
    
 Opportunity opp = new Opportunity();
    opp.Name='Test Opp';
    opp.StageName='Decision';
    opp.AccountId=acc.id;
    opp.CloseDate= System.today();
    opp.ForecastCategoryName='Commit';
    insert opp;
        
         String gAddressStr = '{"actionStr":"CREATE","streetNo":"1401","streetName":"S MacArthur Blvd","city":"Irving", '+ 
            '"state":"TX","unitNo":"","zipcode":"75060","gLat":32.7999746,"gLng":-96.9600006}';
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
        		address.CLLI_Code__c = 'IRNGTXXDDS0';
        		address.Service_Control_Number__c = '4178385';
        		address.Wire_Center__c = '972513';
        		address.Latitude__c = '32.7999746';
        		address.Longitude__c = '-96.9600006';
        		address.Id__c = '1695675';
        		address.WireCenter_CLLI__c = 'IRNGTXXD';
        		address.WireCenter_Speed__c = '1000MB';
        		address.Max_Qos__c = 'Platinum';
        		address.DSAT_Max_Speed__c = address.WireCenter_Speed__c;
        		address.Fiber_Qualification__c = 'Qualified (max WC speed)';
        		address.Fiber_Tier__c = '1';
        		address.Copper_Qualification__c = 'BDT';
        		address.DPI_Qualified__c = true;
        		address.DPI_Validated__c = true;
        		address.DSAT_Qualified__c = true;
        		address.DSAT_Validated__c = true;
        		address.DSAT_Services__c = '["EIA", "EVPL", "ELAN", "IPVPN", "EPL", "Connect Cloud", "EPath", "EReach"]';
                   
        insert address;
    }

    @isTest
    public static void testgetWSProductsAndRates() {
        FTRWSAddress__c address =[select id from FTRWSAddress__c limit 1];
        String pNUm = 'EIAV015ICB301402';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSCVDRatesMock());
        FTRWSCVDController.getWSProductsAndRates(address.Id, pNUM);
        Test.stopTest();
        
  /*      address.Max_Qos__c = 'SILVER';
        update address;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSCVDRatesMock());
        FTRWSCVDController.getWSProductsAndRates(address.Id, pNUM);
        Test.stopTest();
        
        address.Max_Qos__c = 'GOLD';
        update address;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSCVDRatesMock());
        FTRWSCVDController.getWSProductsAndRates(address.Id, pNUM);
        Test.stopTest();*/
    }
    
    @isTest
    public static void testgetPNUms() {
        String acna = 'GIM';
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new FTRWSCVDPnumsMock());
        FTRWSCVDController.getPNums(acna);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetNonCVDProductCatalogItems() {
        
        Product2 product = new Product2();
        product.Name = '10G Protected Channel Terminations 1YR';
        product.evcspeed__c = '10G';
        product.Family = 'FOTS';
        product.Quantity__c = '1';
        product.Recurring_Type__c = 'P';
        
        insert product;

        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry priceEntrylist = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product.Id,UnitPrice = 12000, IsActive = true);
        insert priceEntrylist;
        
        
        Product2 product2 = new Product2();
        product2.Name = 'Cloud Colocation CABINET-RACK';
        product2.evcspeed__c = '10G';
        product2.Family = 'EDGE';
        product2.Quantity__c = '1'; 
        
        insert product2;
        
        Id pricebookId2 = Test.getStandardPricebookId();
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId2, Product2Id = product2.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        Pricebook2 customPB2 = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB2;
        
        
  PricebookEntry priceEntrylist2 = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = product2.Id,UnitPrice = 1000, IsActive = true);
        insert priceEntrylist2;        

        Product2 product3 = new Product2();
        product3.Name = 'Dark Fiber';
        product3.evcspeed__c = '';
        product3.Family = 'DARKFIBER';
        product3.Quantity__c = '1';
        product3.Term__c = '3';
        
        insert product3;
        
     Id pricebookId3 = Test.getStandardPricebookId();
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = pricebookId3, Product2Id = product3.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice3;
        
        Pricebook2 customPB3 = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB3;
                
        
  PricebookEntry priceEntrylist3 = new PricebookEntry(Pricebook2Id = customPB3.Id, Product2Id = product3.Id,UnitPrice = 1000, IsActive = true);
        insert priceEntrylist3;    
        
        Test.startTest();
        FTRWSCVDController.getNonCVDProductCatalogItems();
        FTRWSCVDController.getNonCVDProductCatalogItems('FOT123');
        FTRWSCVDController.getNonCVDProductCatalogItems('EDG123');
        FTRWSCVDController.getNonCVDProductCatalogItems('DKF123');
        FTRWSCVDController.buildNonCVDTermProd(product3);
        FTRWSCVDController.getFormattedDsatSpeed('2G');
        FTRWSCVDController.getFormattedDsatSpeed('3g');
        FTRWSCVDController.getFormattedDsatSpeed('100m');
        Test.stopTest();

    }
    
    @isTest
    public static void testCloneRatesMethod() {
    FTRWSCVDRate rate = new FTRWSCVDRate();
        rate.pNUM = 'EIA001AKQSCM326';
        rate.region = 'A';
        rate.los = 'BASIC';
        rate.vta = '*';
        rate.product = 'EIA';
        rate.circuitType = 'EVC';
        rate.usocTier = '001';
        rate.evcSpeed = '5M';
        rate.nrcUsoc = 'EIANR';
        rate.nrc = '1500.00';
		rate.mrcUsoc = 'EIATA';
    	rate.mrc = '1000.00';
        Test.startTest();
		FTRWSCVDController.cloneRateObjectWithStarTerm(rate);  
        Test.stopTest();
    }
 
}