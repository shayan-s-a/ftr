/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest //(SeeAllData=true)

public class WS_SFA_ManageAgreementTest {

   @testSetup static void dataSetUp() {
        Account objAcc = new Account();
        objAcc.Name ='testing Name';
        objAcc.Legal_Street__c='test';
        objAcc.Legal_City__c='test';
        objAcc.Legal_State__c='test';
        objAcc.ShippingStreet='test';
        objAcc.ShippingCity='NY';
        objAcc.ShippingState='New York';
        objAcc.ShippingPostalCode='44011';
        objAcc.ShippingCountry ='United States';
        objAcc.BillingStreet='test';
        objAcc.BillingCity='NY';
        objAcc.BillingState='New York';  
        objAcc.BillingPostalCode='44011';
        objAcc.BillingCountry ='United States';   
        insert objAcc;

        Profile p = [SELECT Id FROM Profile WHERE Name='Frontier Sales User']; 
        User u = new User(
            Alias = 'dt', Email='user1@test.com', EmailEncodingKey='UTF-8', LastName='LTest', FirstName ='FTest',
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='er1@trg.com'
        );
        insert u;
        User u2 = new User(
            Alias = 'dt', Email='user2@test.com', EmailEncodingKey='UTF-8', LastName='LTest', FirstName ='FTest',
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, ManagerId=u.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='er2@trg.com'
        );
        insert u2;
        
        Opportunity objOpp = new Opportunity(Name ='Testing Name',
                                                    AccountId= objAcc.Id,
                                                    CloseDate = date.today(),
                                                    Service_Address__c = 'Test',
                                                    Description__c = 'Test',
                                                    StageName ='Verbal Commit',
                                                    Expected_Billed_Date__c = date.today(),
                                                    System_the_Order_Entered_In__c = 'DPI');
        insert objOpp;
        system.debug('oppId from test : '+objOpp.Id);
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];        
        SterlingQuote__c objquote = new SterlingQuote__c();
        objquote.Name='Testing Name';
        objquote.ExpirationDate__c=date.today();
        objquote.OpportunityId__c=objOpp.id;
        objquote.Account_Name__c= objAcc.Id;
        objquote.RecordTypeId = recordtypeid[0].Id; 
        objquote.IsSyncing__c = true;
       
        //objquote.MinorLine__c = 0;
        insert objquote;
        
        contract objcon = new contract();
        objcon.Name='Test';
        objcon.AccountId=objAcc.Id;
        objcon.ShippingStreet='test';
        objcon.ShippingCity='NY';
        objcon.ShippingState='New York';
        objcon.ShippingPostalCode='44011';
        objcon.ShippingCountry ='United States';
        objcon.BillingStreet='test';
        objcon.BillingCity='NY';
        objcon.BillingState='New York';  
        objcon.BillingPostalCode='44011';
        objcon.BillingCountry ='United States'; 
        insert objcon;
        
        Schedule__c objSch = new Schedule__c();
        objSch.Schedule_Start_Date__c = system.today();
        objSch.Schedule_End_Date__c = system.today();
        objSch.New_Opportunity__c = objOpp.Id;
        objSch.Contract__c =  objcon.id;
        //objSch.SterlingQuoteItem__c = objLineItem.id; 10/16 raj
        //objSch.Name = 'Test Schedule';
        insert objSch;
        
        
        List<Product2> lstProduct2 = new List<Product2>();
        Product2 product = new Product2();
        product.Name = 'EIA';
        product.ProductCode = 'ENT_ETH_EIA_0001';
        product.IsActive = true;
        lstProduct2.add(product);
        
        Product2 prodEVC = new Product2();
        prodEVC.Name = 'EVC';
        prodEVC.ProductCode = 'ENT_ETH_EVC_0001';
        prodEVC.IsActive = true;
        lstProduct2.add(prodEVC);
        
        Product2 prodAccess = new Product2();
        prodAccess.Name = 'Access';
        prodAccess.ProductCode = 'ENT_ETH_ACCESS_0001';
        prodAccess.IsActive = true;
        lstProduct2.add(prodAccess);
        //Insert products
        insert lstProduct2;  
        id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = lstProduct2[0].Id,
            UnitPrice = 100, IsActive = true);
        insert standardPrice;

       
        SterlingQuoteItem__c objLineItem1 = new SterlingQuoteItem__c();
        objLineItem1.Quantity__c=10;
        objLineItem1.TermLength__c=24;
        objLineItem1.StandardMRC__c = 10;
        objLineItem1.StandardNRC__c = 10;
        objLineItem1.AdjustedMRC__c = 10;
        objLineItem1.AdjustedNRC__c = 10;
        objLineItem1.Renewal_MRR_Original__c = 10;
        objLineItem1.Locality__c = 'Indiana';
        objLineItem1.StateProvince__c ='IN';
        objLineItem1.ItemCode__c ='123'; 
        objLineItem1.ApprovalTerritory__c ='Indiana';
        objLineItem1.ApprovalRegion__c='central';
        objLineItem1.NPA__c ='10';
        objLineItem1.NXX__c = '10';
        objLineItem1.IsInFrontierFootprint__c = true;
        objLineItem1.SterlingQuote__c = objquote.id;
        //objLineItem1.Products__c = lstProduct2[0].Id;
        
        SterlingQuoteItem__c objLineItem2 = new SterlingQuoteItem__c();
        objLineItem2.Quantity__c=10;
        objLineItem2.TermLength__c=24;
        objLineItem2.StandardMRC__c = 10;
        objLineItem2.StandardNRC__c = 10;
        objLineItem2.AdjustedMRC__c = 10;
        objLineItem2.AdjustedNRC__c = 10;
        objLineItem2.Renewal_MRR_Original__c = 10;
        objLineItem2.Locality__c = 'Indiana';
        objLineItem2.StateProvince__c ='IN';
        objLineItem2.ItemCode__c ='123'; 
        objLineItem2.ApprovalTerritory__c ='Indiana';
        objLineItem2.ApprovalRegion__c='central';
        objLineItem2.NPA__c ='10';
        objLineItem2.NXX__c = '10';
        objLineItem2.IsInFrontierFootprint__c = true;
        objLineItem2.SterlingQuote__c = objquote.id;
        objLineItem2.Postcode__c = '12345';
        objLineItem2.StateProvince__c = 'test';
        objLineItem2.SA_StreetName__c = 'test';
        objLineItem2.SA_StreetSuffix__c = 'test';
        objLineItem2.SA_StreetNrFirst__c = 'test';
        objLineItem2.SA_StreetSubDescription__c = 'test';
        //objLineItem2.Products__c = lstProduct2[0].Id;
        insert new List<SterlingQuoteItem__c>{objLineItem2};
            
        Quote oQuote = new Quote();
        oQuote.Name = 'Testing Quote';
        oQuote.OpportunityId = objOpp.id;
        oQuote.Pricebook2Id = pricebookId;
        oQuote.Service_Term__c = '24 Months';
        //oQuote.Schedule_Number__c= objSch.Name; 
        oQuote.IsSyncing__c =true;
        oQuote.OwnerId = u2.Id;
        insert oQuote;
        

        Date d1=Date.newInstance(2023, 08, 11);
        Order oOrder = new Order();
        oOrder.Name = 'Testing Order';
        oOrder.OpportunityId = objOpp.id;
        oOrder.Pricebook2Id = pricebookId;
        oOrder.vlocity_cmt__QuoteId__c = oQuote.Id;
        oOrder.AccountId = objAcc.Id;
        oOrder.EffectiveDate = d1;
        oOrder.Status = 'Draft';
        oOrder.Product__c = 'EIA';
        oOrder.Product_Type__c = 'Ethernet';
        oOrder.Router_s__c = 'No Router';
        oOrder.vlocity_cmt__RequestedStartDate__c = d1;
        oOrder.vlocity_cmt__RequestedCompletionDate__c = d1;
        oOrder.Customer_Requested_Date__c = d1;
	    oOrder.Order_Stage__c='Assignment';
		oOrder.Vlocity_Schedule_ID__c=objSch.Id;
        insert oOrder;
        
        OrderItem oOLI = new OrderItem();
        oOLI.OrderId = oOrder.id;
        oOLI.PricebookEntryId = standardPrice.id;
        oOLI.vlocity_cmt__ServiceAccountId__c = objAcc.id;
        oOLI.Quantity = 1;
        oOLI.UnitPrice = 34.50;
        oOLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
        oOLI.vlocity_cmt__LineNumber__c = '0001';
        oOLI.vlocity_cmt__LineItemNumString__c = '1';
        //oOLI.Product2Id = lstProduct2[0].Id;
        insert oOLI;
    }
    
    public static testMethod void vlocityQuote_withId(){
    	Contract c = [Select Id, Name,contractnumber from Contract Limit 1];
        Order o = [SELECT Id, Vlocity_Schedule_ID__c FROM Order LIMIT 1];
        o.Vlocity_Schedule_ID__c = c.contractnumber;
        update o;
        WS_SFA_ManageAgreement.getProductsById(new List<String>{o.Vlocity_Schedule_ID__c});
        
    }
	
    public static testMethod void sterlingQuote_withId(){
    	Schedule__c objSch = [Select Id, Name, Schedule_Start_Date__c, Schedule_End_Date__c from Schedule__c Limit 1];
        
        WS_SFA_ManageAgreement.getProductsById(new List<String>{objSch.Name});
        
    }
    public static testMethod void sterlingQuote_withWrongAddress(){
        WS_SFA_ManageAgreement.CitizensServiceAddress CSA = new WS_SFA_ManageAgreement.CitizensServiceAddress();

        CSA.Locality = 'Indiana';
            CSA.Postcode = '12345';
            CSA.StateOrProvince = 'test12';
            CSA.StreetName = 'test';
            CSA.StreetNameSuffix = 'test';
            CSA.StreetNrFirst = 'test';
            CSA.StreetSubDescription = 'test';
        
    	Schedule__c objSch = [Select Id, Name, Schedule_Start_Date__c, Schedule_End_Date__c from Schedule__c limit 1];
        
        WS_SFA_ManageAgreement.getProductsByAddress(objSch.Name, CSA);
        
    }
    public static testMethod void sterlingQuote_withAddressSterling(){
        WS_SFA_ManageAgreement.CitizensServiceAddress CSA = new WS_SFA_ManageAgreement.CitizensServiceAddress();

        CSA.Locality = 'Indiana';
            CSA.Postcode = '12345';
            CSA.StateOrProvince = 'test';
            CSA.StreetName = 'test';
            CSA.StreetNameSuffix = 'test';
            CSA.StreetNrFirst = 'test';
            CSA.StreetSubDescription = 'test';
        
    	Schedule__c objSch = [Select Id, Name, Schedule_Start_Date__c, Schedule_End_Date__c from Schedule__c limit 1];
        
        WS_SFA_ManageAgreement.getProductsByAddress(objSch.Name, CSA);
        
    }
    public static testMethod void sterlingQuote_withAddressVelocity(){
        WS_SFA_ManageAgreement.CitizensServiceAddress CSA = new WS_SFA_ManageAgreement.CitizensServiceAddress();
		CSA.Locality = 'Indiana';
        CSA.Postcode = '12345';
        CSA.StateOrProvince = 'test';
        CSA.StreetName = 'test';
        CSA.StreetNameSuffix = 'test';
        CSA.StreetNrFirst = 'test';
        CSA.StreetSubDescription = 'test';

        
    	Schedule__c objSch = [Select Id, Name, Schedule_Start_Date__c, Schedule_End_Date__c from Schedule__c limit 1];
        
        WS_SFA_ManageAgreement.getProductsByAddress(objSch.Name, CSA);
        
    }
	
	public static testMethod void TestProductSchedule(){
        
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Testing Name'];
		SterlingQuote__c q = [SELECT Id FROM SterlingQuote__c WHERE Name = 'Testing Name' and OpportunityId__c = :opp.id];
		Schedule__c Schedule = [Select Id, Name, Schedule_Start_Date__c, Schedule_End_Date__c, Contract__c from Schedule__c where New_Opportunity__c =:opp.Id];
		Contract contract = [Select Id From Contract WHERE Id = :Schedule.Contract__c];
		List<SterlingQuoteItem__c> list_products = [SELECT Id,ST_AddressID__c,SA_StreetName__c,ST_SKU__c, Quantity__c,MajorLine__c,MinorLine__c, ST_LineKey__c, ST_ParentLineKey__c,Products__c,ItemCode__c,AdjustedMRC__c,AdjustedNRC__c,SA_UnitNumber__c,ServiceControlNumber__c,NPA__c,NXX__c,ServiceSequenceNumber__c,SA_WireCenter__c,SA_StreetDirection__c,SA_SubDivision__c,Locality__c,StateProvince__c,Postcode__c,SA_BuildingName__c,SA_unitDesignator__c,SA_StreetNrFirst__c,SA_StreetSuffix__c,SA_StreetSubDescription__c From SterlingQuoteItem__c WHERE SterlingQuote__c = :q.id];
		Map<Id, Product2> productsMap = new Map<Id,Product2> ([SELECT Id From Product2 WHERE Productcode = 'ENT_ETH_EIA_0001']);
        
		WS_SFA_ManageAgreement.ProductSchedule ps = new WS_SFA_ManageAgreement.ProductSchedule(true, Schedule,contract,list_products, productsMap);
		
	}
    
	public static testMethod void TestProductScheduleFalse(){
        
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Testing Name'];
		SterlingQuote__c q = [SELECT Id FROM SterlingQuote__c WHERE Name = 'Testing Name' and OpportunityId__c = :opp.id];
		Schedule__c Schedule = [Select Id, Name, Schedule_Start_Date__c, Schedule_End_Date__c, Contract__c from Schedule__c where New_Opportunity__c =:opp.Id];
		Contract contract = [Select Id,StartDate,EndDate,ScheduleID__c From Contract WHERE Id = :Schedule.Contract__c];
		List<SterlingQuoteItem__c> list_products = [SELECT Id,ST_AddressID__c,SA_StreetName__c,ST_SKU__c, Quantity__c,MajorLine__c,MinorLine__c, ST_LineKey__c, ST_ParentLineKey__c,Products__c,ItemCode__c,AdjustedMRC__c,AdjustedNRC__c,SA_UnitNumber__c,ServiceControlNumber__c,NPA__c,NXX__c,ServiceSequenceNumber__c,SA_WireCenter__c,SA_StreetDirection__c,SA_SubDivision__c,Locality__c,StateProvince__c,Postcode__c,SA_BuildingName__c,SA_unitDesignator__c,SA_StreetNrFirst__c,SA_StreetSuffix__c,SA_StreetSubDescription__c From SterlingQuoteItem__c WHERE SterlingQuote__c = :q.id];
		
		Map<Id, Product2> productsMap = new Map<Id,Product2> ([SELECT Id From Product2 WHERE Productcode = 'ENT_ETH_EIA_0001']);
        
		WS_SFA_ManageAgreement.ProductSchedule ps = new WS_SFA_ManageAgreement.ProductSchedule(false, Schedule,contract,list_products, productsMap);
		
	}
}