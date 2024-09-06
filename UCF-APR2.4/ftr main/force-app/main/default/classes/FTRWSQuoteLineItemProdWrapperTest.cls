/**
* @description       : This test class covers the following Apex classes:
*      FTRWSQuoteLineItemProdWrapper
*      TBD_CLASS2
*      TBD_CLASS3
* @author            : TBD
* @version           : 4
*
**/
@IsTest
public class FTRWSQuoteLineItemProdWrapperTest {
    
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
        
        
        Product2 product2 = new Product2();
        product2.Name = 'FOTS Test';
        //product2.evcspeed__c = '200M';
        product2.Family = 'FOTS';
        product2.Quantity__c = '1';
        //product2.mrcusoc__c = 'EIAUSOC';
        product2.RecordTypeId = recordType.Id;
        product2.isActive = TRUE;
        insert product2;     
        
        PricebookEntry customPBEntry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product.Id,UnitPrice = 20000, IsActive = true);
        insert customPBEntry;
        
        
        PricebookEntry customPBEntry2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product2.Id,UnitPrice = 10000, IsActive = true);
        insert customPBEntry2;
        
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
        quote.CreatedDate = System.today();
        
        
        insert quote;
        
        System.debug('pricebookId:' + pricebookId);
        System.debug('opp.Pricebook2Id: ' + opp.Pricebook2Id);
        
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
        
        
        /////////////////////////////////////////////////
        
        SterlingQuoteItem__c quoteItem2 = new SterlingQuoteItem__c();
        quoteItem2.Name = product2.Name;
        quoteItem2.Description__c = product2.Name;
        quoteItem2.SterlingQuote__c = quote.Id;
        quoteItem2.Products__c = product2.Id;
        quoteItem2.Quantity__c = 1;
        quoteItem2.StandardMRC__c = decimal.valueOf('1000.00');
        quoteItem2.StandardNRC__c = decimal.valueOf('0.00');
        quoteItem2.ItemCode__c = product.mrcusoc__c;
        quoteItem2.TermLength__c = 36;        
        
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
        quoteItem2.Pricebook_Entry_Id__c = customPBEntry2.Id;
        INSERT quoteItem2;             
        
        /*  OpportunityLineItem oli = new OpportunityLineItem();
oli.CPE_Gross_Margin__c = 0;
oli.CPE_NRC_Price__c = 5.00;
oli.NRC_Price__c = 12;
oli.Product2 = product;
oli.Service_Address__c = 'test';
oli.Quantity = 1;
oli.OpportunityId = opp.Id;
oli.TotalPrice = 18.00;
// oli.P
oli.PricebookEntryId = customPBEntry.Id;
insert oli;*/
        
    }
    
    @isTest
    public static void codeCoverage(){
        Opportunity opp = [Select Id from Opportunity limit 1];
        SterlingQuote__c quote = [Select Id from SterlingQuote__c limit 1];
        FTRWSAddress__c  address = [Select Id from FTRWSAddress__c limit 1];
        List<SterlingQuoteItem__c> sqiList = getQuoteItem(quote.Id);//[Select Id from SterlingQuoteItem__c limit 1];
        WSQuoteController.getSyncQuoteWithOpportunity(quote.id);
        List<OpportunityLineItem> oliList = getOpportunityLineItems(opp.Id);//[Select Id from OpportunityLineItem limit 1];
        List<FTRWSQuoteLineItemProdWrapper> wrapperList = new List<FTRWSQuoteLineItemProdWrapper>();
        Test.startTest();   
        wrapperList = FTRWSQuoteLineItemProdWrapper.getQuickQuoteWrappers(opp.Id, quote.Id);
        FTRWSQuoteLineItemProdWrapper wrapper1 = wrapperList.get(0);
        FTRWSQuoteLineItemProdWrapper wrapper2 = wrapperList.get(1);
        
        //FTRWSQuoteLineItemProdWrapper.getTotalQuickQuoteValue(wrapperList);
        FTRWSQuoteLineItemProdWrapper.getQuoteDate(quote.Id);
        
        FTRWSQuoteLineItemProdWrapper.getMonthlyTotalQuickQuoteValue(wrapperList);
        FTRWSQuoteLineItemProdWrapper.getOneTimeTotalQuickQuoteValue(wrapperList);
        FTRWSQuoteLineItemProdWrapper.getOpportunityLineItemsMapFromOpportunity(opp.Id);
        FTRWSQuoteLineItemProdWrapper.getOppProductToAdd(wrapperList.get(0));
        
        wrapper1.compareTo(wrapper2);
        
        Test.stopTest();
    }
    
    @isTest
    public static void codeCoverageForGetters() {
        SterlingQuote__c quote = [Select Id from SterlingQuote__c limit 1];
        Set<Id> quoteIdSet = new Set<Id>();
        quoteidset.add(quote.Id);
        Test.startTest();
        FTRWSQuoteLineItemProdWrapper.getQuoteItemsFromQuotes(quoteIdSet);
        
        FTRWSQuoteLineItemProdWrapper.getTermLengthInYears(60, '60');
        FTRWSQuoteLineItemProdWrapper.getTermLengthInYears(24, '24');
        FTRWSQuoteLineItemProdWrapper.getTermLengthInYears(12, '12');
        FTRWSQuoteLineItemProdWrapper.getTermLengthInYears(36, '36');
        FTRWSQuoteLineItemProdWrapper.getTermLengthInYears(48, '48');
        FTRWSQuoteLineItemProdWrapper.getTermLengthInYears(0, '0');
        FTRWSQuoteLineItemProdWrapper.getTermLengthInYears(null, null);
        FTRWSQuoteLineItemProdWrapper.getTermLengthInYears(0, 'MTM');
        Test.stopTest();
    }
    
    private static List<SterlingQuoteItem__c> getQuoteItem(Id quoteId) {
        
        return [ SELECT Id,
                RecordType.Name,
                Products__r.name, 
                Renewal_MRR_Original__c, 
                NetNewMRR__c, 
                CurrentStatus__c, 
                StandardMRC__c, 
                AdjustedNRC__c, 
                AdjustedMRC__c, 
                OverallStatus__c, 
                Quantity__c, 
                IsPromoProduct__c, 
                TermLength__c, 
                Display_Term__c,
                NumInstallments__c, 
                DiscountType__c, 
                OpportunityLineItemId__c, 
                Products__c, 
                ApprovalRouting__c, 
                NoICB__c, 
                Part_Number__c, 
                Category__c,
                qos__c,
                circuitType__c,
                PNum__c,
                cvdPriceTier__c,
                StateProvince__c
                
                FROM SterlingQuoteItem__c 
                WHERE SterlingQuote__c =:quoteId limit 1];
    }
    
    
    private static  List<OpportunityLineItem> getOpportunityLineItems(String oppId) {
        return  [SELECT Id, 
                 Renewal_MRR__c, 
                 UnitPrice,
                 Speed__c,                      
                 CPE_Gross_Margin__c, 
                 CPE_NRC_Price__c, 
                 NRC_Price__c, 
                 Product2.name, 
                 AdjustedMRC__c, 
                 QuoteId__c, 
                 Service_Address__c, 
                 ZAddress__c 
                 FROM OpportunityLineItem 
                 WHERE Opportunityid = :oppId
                ];
    }
    
    
    
}