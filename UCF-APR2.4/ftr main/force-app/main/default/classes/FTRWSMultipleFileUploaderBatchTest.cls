// version 1
@isTest
global class FTRWSMultipleFileUploaderBatchTest { 
    
    @testSetup static void methodName() { 
        
        Account acc = new Account();
        acc.Name='testAccount';
        insert acc;
        
        Product2 product = new Product2();
        product.Name = 'EPATH 1000M Silver';
        product.evcspeed__c = '1000M';
        product.Family = 'EPATH';
        product.Quantity__c = '1';
        product.mrcusoc__c = 'EPATHUSOC';
        
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
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.Wholesale_ACNA__c=acna.id;
        opp.Wholesale_Pnum__c=pnum.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        FTRWSAddress__c adr= new FTRWSAddress__c();
        adr.Address__c = '1 BROOKLYN RD' +' '+'FREEVILLE'+' '+'NY'+' '+'13068';
        adr.Name = '1 BROOKLYN RD' +' '+'FREEVILLE'+' '+'NY'+' '+'13068';
        adr.Street__c = '1 BROOKLYN RD';
        adr.Street_Name__c='1 BROOKLYN RD';            
        adr.City__c  = 'FREEVILLE';
        adr.State__c = 'NY';
        adr.Zip_Code__c = '13068';
        adr.Latitude__c = '';
        adr.Longitude__c =  '';
        adr.Unit_Number__c  = '';
        adr.Opportunity_ID__c = opp.Id;
        adr.DPI_Validated__c = False;
        adr.DSAT_Validated__c = False;
        adr.Comments__c='';
        insert adr;
        
    }
     
        
    
    public static TestMethod void execute(){
        Test.startTest();

        Test.setMock(WebServiceMock.class, new FTRWSDPIAddressValResultMock());
        Test.setMock(HttpCalloutMock.class, new FTRWSDSATAddressControllerPostMock());
        Test.stopTest();
        
    }
    

}