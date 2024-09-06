@isTest(seeAllData = true)
class FTRWSCalculateOppMRRTest {

    public static Opportunity opp;


    public static Product2 createTestProduct(String name, String decription, String prodCode) {
        
        /*
        Product2 product = new Product2();
        product.name = 'EPATH 200M';
        product.ProductCode = prodCode;
        insert Product;
        */
        Id prodRecId = [select id,name,developername from recordtype where sobjecttype='product2' and developername='Carrier_Service' LIMIT 1]?.Id;
        Product2 product = [SELECT Id, Name, Evcspeed__c, Family, MRCusoc__c, RecordTypeId FROM Product2 WHERE RecordTypeId =:prodRecId LIMIT 1];
		product.productCode = '%999%';
        //update product;
        return product;
    }


    public static void createTestOpportunity() {
        
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
       Account acc = new Account();
       acc.Name='testAccount';
       acc.RecordTypeId= globalRecId;
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

       opp = new Opportunity();
       opp.Name='Test Opp';
       opp.StageName='Decision';
       opp.AccountId=acc.id;
       opp.CloseDate= System.today();
       opp.ForecastCategoryName='Commit';
       opp.Wholesale_ACNA__c = acna.Id;
       opp.Wholesale_Pnum__c = pnum.Id;
       insert opp;
       
         Note note1 = new Note();
       note1.Title = 'Test Note1';
       note1.ParentId = opp.Id;
       insert note1;

       Note note2 = new Note();
       note2.Title = 'Test Note2';
       note2.ParentId = opp.Id;
       insert note2;        
       
   }

    @isTest
    static void test() {

        createTestOpportunity();
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
        address.Address_Lost_checkbox__c = true;
        
        insert address;
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'Carrier_Service' AND SobjectType = 'SterlingQuote__c'];        
         
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        SterlingQuote__c quote = new SterlingQuote__c(Name = 'Test Quote 1', 
                                                        RecordTypeId = recordtypeid[0].Id, 
                                                        OpportunityId__c = opp.Id, 
                                                        IsSyncing__c = true);
        
        quote.Status__c = 'Draft';
        
        insert quote;
        
        Product2 product = createTestProduct('EPATH 2000M', 'EPATH 2000 M Platinum', '%999%');
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = [SELECT ID from PriceBookEntry where product2Id=:product.Id];
        //new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id,UnitPrice = 10000, IsActive = true);
        //insert standardPrice;
        
        Pricebook2 customPB = [SELECT ID FROM PriceBook2 LIMIT 1];
        //new Pricebook2(Name='Custom Pricebook', isActive=true);
        //insert customPB;              
        
        
         SterlingQuoteItem__c quoteItem = new SterlingQuoteItem__c();
        quoteItem.Name = product.name;
        quoteItem.Description__c = product.name;
        quoteItem.circuitType__c = 'EVC';
        
        quoteItem.SterlingQuote__c = quote.Id;
        quoteItem.Products__c = product.Id;
        quoteItem.Quantity__c = 1;
        quoteItem.PNum__c = 'EPAV1234567';
        
        String mrc = '200.00';
        if(mrc != null && mrc != '') {
        	quoteItem.StandardMRC__c = decimal.valueOf(mrc);    
        	quoteItem.NetNewMRR__c = decimal.valueOf(mrc);
        	quoteItem.AdjustedMRC__c = decimal.valueOf(mrc);
            
        }
        
        String nrc = '100.00';
        if(nrc != null && nrc != '') {
        	quoteItem.StandardNRC__c = decimal.valueOf(nrc);
            quoteItem.AdjustedNRC__c = decimal.valueOf(nrc);
        }
        
        
        quoteItem.ItemCode__c = 'MRCEPATH';
        quoteItem.NRC_Item_Code__c = 'NRCEPATH';
        
        
        Integer termLength = 2;       
        if(termLength != null && termLength != 0) {
        	quoteItem.TermLength__c = termLength;    
        }
		
        
        quoteItem.SA_StreetNrFirst__c = address.Street_Number__c;
        quoteItem.SA_StreetName__c = address.Street_Name__c;
        quoteItem.SA_UnitNumber__c = address.Unit_Number__c;
        quoteItem.Zipcode__c = address.Zip_Code__c;
        quoteItem.Locality__c = address.City__c;
        quoteItem.DSAT_AddressID__c = address.Id__c;
        quoteItem.ST_AddressID__c = address.Id;
        quoteItem.NetNewMRR__c = 500.00;
        
        quoteItem.cvdratesource__c = 'Address';
        quoteItem.qos__c = 'Platinum';
        quoteItem.cvdPriceTier__c = '1';
        INSERT quoteItem;
        
        
		
        
        OpportunityLineItem oppLineItem = createTestOpportunityLineItem(opp.Id, product, pricebookId);

        FTRWSCVDRate__c cvdrates = new FTRWSCVDRate__c();
        Map<Id, List<ZAddress__c>> sterlingQuoteItemIdByZAddressList = new Map<Id, List<ZAddress__c>>();

        FTRWSOpportunityController.WrapperOpportunityProduct test = new FTRWSOpportunityController.WrapperOpportunityProduct(quote,quoteItem, oppLineItem, sterlingQuoteItemIdByZAddressList,address,cvdrates);

        //call calculateMRR
        //List<Id> addressList = new List<Id>();
        //addressList.add(address.Id);
        List<Id> oppList = new List<Id>();
        oppList.add(opp.Id);
        FTRWSCalculateOppMRR.calculateMRR(oppList);
        //Test for delete quote item trigger added for TotalAdjustMRC
        //DELETE quoteItem;
    }


    public static OpportunityLineItem createTestOpportunityLineItem(Id opportunityId, Product2 product, Id pricebookId) {
        //Product2 p = createTestProduct ('Test Product', 'Test Description', '%999%');

        PricebookEntry pe = createPricebookEntry(pricebookId, product.Id, 10000);
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.CPE_Gross_Margin__c = 0;
        oli.CPE_NRC_Price__c = 5.00;
        oli.NRC_Price__c = 12;
        oli.Product2 = product;
        oli.Service_Address__c = 'test';
        oli.Quantity = 1;
        oli.OpportunityId = opportunityId;
        oli.TotalPrice = 18.00;
        oli.PricebookEntryId = pe.Id;
        insert oli;
        return oli;
    }

    public static PricebookEntry createPricebookEntry(Id pricebookId, Id productId, Decimal price) {
		PricebookEntry pe =  [SELECT ID, UnitPrice, IsActive, Product2Id from PriceBookEntry where product2Id=:productId];
        //new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productId, UnitPrice = price, IsActive = true);
        //insert pe;
        return pe;
    }

}