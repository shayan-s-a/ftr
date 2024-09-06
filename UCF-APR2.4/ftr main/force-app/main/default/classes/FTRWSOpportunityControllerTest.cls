/**
 * @description       : This test class covers the following Apex classes:
 *       TBD_CLASS1
 *       TBD_CLASS2
 *       TBD_CLASS3
 * @author            : TBD
 * @version           : 6
**/
@isTest(seeAllData = true)
public class FTRWSOpportunityControllerTest {
    
    public static Opportunity opp;
    public static SterlingQuoteItem__c quoteItem = new SterlingQuoteItem__c();
    public static Product2 product;
    
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
    
      public static PricebookEntry createPricebookEntry(Id pricebookId, Id productId, Decimal price) {
		//PricebookEntry pe =new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productId, UnitPrice = price, IsActive = true);
        PricebookEntry pe = [SELECT ID, UnitPrice, IsActive, Product2Id from PriceBookEntry where product2Id=:productId AND IsActive=true LIMIT 1]; //test lucas
        return pe;
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

    
    public static void prepareTestData() {
        
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
        
        product = createTestProduct('EPATH 2000M', 'EPATH 2000 M Platinum', '%999%');
        Id pricebookId = Test.getStandardPricebookId();
        List<PriceBookEntry> objEntry = [SELECT Id FROM PriceBookEntry WHERE product2ID=: product.Id AND PriceBook2ID =: pricebookId];
        if (objEntry.isEmpty()) {
            insert new PriceBookEntry(product2ID = product.Id, PriceBook2ID = pricebookId,UnitPrice = 10000, IsActive = true); 
        }
        
        

 
        
        Pricebook2 customPB = [SELECT ID FROM PriceBook2 LIMIT 1];
        //new Pricebook2(Name='Custom Pricebook', isActive=true);
        //insert customPB;              
        
        
         //SterlingQuoteItem__c quoteItem = new SterlingQuoteItem__c();
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
        //INSERT quoteItem;
                
        //OpportunityLineItem oppLineItem = createTestOpportunityLineItem(opp.Id, product, pricebookId);

    }

        
    @isTest
    public static void testAttachmentsAndWrappers () 
    {
        aps_VlocityQuoteHandler.stopTrigger = true;
        SterlingQuoteItemTriggerHandler.stopTrigger = true;
       prepareTestData();
        OpportunityLineItem oppLineItem = createTestOpportunityLineItem(opp.Id, product, Test.getStandardPricebookId());
        quoteItem.OpportunityLineItemId__c = oppLineItem.Id;
        INSERT quoteItem;
        Test.startTest();
        
        
        List<FTRWSOpportunityController.AttachmentWrapper> TT = new List<FTRWSOpportunityController.AttachmentWrapper>();
		FTRWSOpportunityController.AttachmentWrapper objattach = new FTRWSOpportunityController.AttachmentWrapper();

		objAttach.Name = 'Testing';
		objAttach.typeOf = 'test';
		objAttach.ID = '1234';
		objAttach.createdById = 'test';
		objAttach.createByName = 'test name';
		objAttach.urlRedirection = 'Testing Name';
        objattach.LastModifiedDate = System.now();
		TT.add(objAttach);        
        
        
        FTRWSOpportunityController.WrapperOpportunityProduct wrapperProd = new FTRWSOpportunityController.WrapperOpportunityProduct();
        wrapperProd.AdjustedNRC = 200.00;
        wrapperProd.category = 'Test';
            wrapperProd.circuitType = 'EVC';
        wrapperProd.Id = '123456';
        wrapperProd.Name = 'Test';
        wrapperProd.NetNewMRR = 300.00;
        wrapperProd.NRC = 100.00;
        wrapperProd.Quantity = 1;
        wrapperProd.quoteId = '12345c';
        wrapperProd.quoteitemid = '1234dfgh';
        wrapperProd.recurringTotal = 500.00;
        wrapperProd.quoteRecordType = 'SFA';
        wrapperProd.RenewalMRR = 500.00;
        wrapperProd.ServiceAddress = 'Test';
        wrapperProd.SnECode = 'SNE1234';
        wrapperProd.Speed = '2000M';
        wrapperProd.TermLength = 3;
        wrapperProd.TotalCharge = 500.00;
        wrapperProd.TotalMRC = 300.00;
        wrapperProd.TotalNRC = 200.00;
        wrapperProd.url = 'www.test.com';
        wrapperProd.ZAddress = 'Test Z Address';
        wrapperProd.isSubmitted = true;
        wrapperProd.isPending = true;
        wrapperProd.isstatus = true;
        wrapperProd.isshow  = true;
        wrapperProd.SnEMRC = 'TestMRC';
        wrapperProd.SnENRC = 'TestNRC';
        wrapperProd.noOfBusinessDays = '5';    
        wrapperProd.cvdratesource = 'Test';
        wrapperProd.Status ='Pending';
        wrapperProd.EVC_Bandwidth = '100M';
        wrapperProd.Term_Aggrement = '3Y';
        wrapperProd.Level_of_Service = 'Silver';
        wrapperProd.MRC = '200.00';
        wrapperProd.Product_Id = '1234';
        wrapperProd.Product_Name = 'tets';
        wrapperProd.CVD_Pnum = '123';
        wrapperProd.Quantity = 1;
        wrapperProd.IsPromoProduct = 'No';
        wrapperProd.ServiceAddress = '1234';
        wrapperProd.StateOrProvince = 'TX';
        wrapperProd.Address_Id = '1234';
        wrapperProd.DisplayTerm = '3Y';
        wrapperProd.NumInstallments = 3;
        wrapperProd.CPEGrossMargin = 32.22;
        wrapperProd.CPENRC = 0.00;
        wrapperProd.discountType = 'Percentage';
        wrapperProd.isOLI= TRUE;
        wrapperProd.OverallStatus = 'Approved';
        wrapperProd.isApproved = TRUE;
        wrapperProd.isDiscountTypeEmpty = TRUE;
        wrapperProd.isICB = FALSE;
        wrapperProd.isEmptyStatus = false;
        wrapperProd.isRecalled = false;
        wrapperProd.isfinance = false;
        wrapperProd.partnumber = '1234';
        wrapperProd.ftrwsAddressLine = '1234';
        wrapperProd.ftrwsUnit = '123';
        wrapperProd.ftrwsState = 'TX';
        wrapperProd.ftrwsCity = 'Dallas';
        wrapperProd.ftrwsZipcode = '12245';
        wrapperProd.ftrwsLat = '12.99';
        wrapperProd.ftrwsLong = '123.99';
        wrapperProd.ftrwsComments = 'test';
        wrapperProd.ftrwsDPIQualified = true;
        wrapperProd.ftrwsDSATQualified = true;
        wrapperProd.ftrwsInFootprint = true;
        wrapperProd.ftrwsWireCenterCLLI = 'test';
        wrapperProd.ftrwsMaxQos = 'Silver';
        wrapperProd.ftrwsDSATMaxSpeed = '100M';
        wrapperProd.ftrwsCopperTier = '100M';
        wrapperProd.ftrwsFiberQualification = '12';
        wrapperProd.ftrwsFiberTier = '2';
        wrapperProd.cvdratetier = '1';
        wrapperProd.ftrwsNotes = 'Test';
        wrapperProd.ftrwsAcna = 'GIM';
        wrapperProd.ftrwsLevelOfService = 'Silver';
        wrapperProd.ftrwsstreet ='test';
        wrapperProd.DSATID = '12345';
        wrapperProd.FiberDistance = '123';
        wrapperProd.AddressLost= false;

        wrapperProd.AddressLostReason  = '';
        wrapperProd.CSLATA  = 12.22;
        wrapperProd.SiteID  = '';
        wrapperProd.AltSiteName  = '';
        wrapperProd.InterconnectLata  = 12.22;
        wrapperProd.InterconnectCLLI  = '';
        wrapperProd.County  = '';
        wrapperProd.MTSOLATA  = 12.11;
        wrapperProd.UMTSMTSO  = '';
        wrapperProd.UNI_NNISpeed  = '';
        wrapperProd.UNI_NNIType  = '';
        wrapperProd.NeedbyDate = System.today();
        
        wrapperProd.NonAdjustedMRC  = '1';
        wrapperProd.NonAdjustedNRC  ='11';
        
        wrapperProd.CRT  = '12';
        wrapperProd.CIAC  = 12;
        wrapperProd.AllocatedTotalCapex  ='123';
        wrapperProd.ATTMRC  = 12;
        wrapperProd.ATTDate  = System.today();
        wrapperProd.ftrwsCopperQualification = '10M';
        wrapperProd.SQI_Id     = '123';


       PageReference pdfPage = Page.WSCarrierSvcQuickQuote;
        Blob pdfBlob = Blob.toPdf('Testing pdf');//pdfPage.getContent();
         //Attachment oAtt = new Attachment(parentId = opp.Id, name = 'QuickQuote.pdf', body = pdfBlob);
        Attachment oAtt2 = new Attachment(parentId = opp.Id, name = 'QuickQuote.pdf', body = pdfBlob);
            insert oAtt2;

                
		FTRWSOpportunityController.initAttachmentSection(opp.Id);
		FTRWSOpportunityController.fetchAllAttachments(opp.Id);
		String strOpportunityId = opp.Id;
        String commentStr = 'Test Comments';        
        FTRWSOpportunityController.getWSQuickQuote(strOpportunityId, commentStr);        
        FTRWSOpportunityController.getSterlingQuoteItems(opp.Id);
        FTRWSOpportunityController.getSterlingQuoteItemExport(opp.Id);
		Test.stopTest();
        
    }
}