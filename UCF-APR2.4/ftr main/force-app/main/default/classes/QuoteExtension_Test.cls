/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 7
**/
@isTest
private class QuoteExtension_Test{
    static  testMethod  void  QuoteExtensionEdit2() {
        // Get the RecordType Id of the 'Global' Account RecordType
        Id globalRecId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Account'
            AND     DeveloperName = 'Global'
            LIMIT   1
        ]?.Id;
        // Create a new 'Global' Account with the above RecordType
        Account globalAcc1 = new Account(
            Name = 'GLOBAL ACCOUNT',
            RecordTypeId = globalRecId
        );
        insert globalAcc1;

        Account objAcc = new Account();
        objAcc.ParentId = globalAcc1.Id;
        objAcc.Name ='testing Name';
        objAcc.Legal_Street__c='test';
        objAcc.Legal_City__c='test';
        objAcc.Legal_State__c='test';
        objAcc.ShippingStreet='test';
        objAcc.ShippingCity='NY';
        objAcc.ShippingState='New York';
        objAcc.BillingStreet='test';
        objAcc.BillingCity='NY';
        objAcc.BillingState='New York';
        
        insert objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name ='Testing Name';
        objOpp.AccountId= objAcc.Id;
        objOpp.CloseDate = date.today();
        objOpp.StageName ='Verbal Commit';
        objOpp.Expected_Billed_Date__c = date.today();
        insert objOpp;
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];        
        SterlingQuote__c objquote = new SterlingQuote__c();
        objquote.Name='Testing Name';
        objquote.ExpirationDate__c=date.today();
        objquote.OpportunityId__c=objOpp.id;
        objquote.Account_Name__c= objAcc.Id;
        objquote.RecordTypeId = recordtypeid[0].Id; 
        //objquote.MinorLine__c = 0;
        insert objquote;      

        Id standardPB = Test.getStandardPricebookId();
        Product2 objProduct2_1 = new Product2(
            Name ='Testing Name',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        insert objProduct2_1;

        PricebookEntry objPricebookEntry1= new PricebookEntry(
            UnitPrice=1000,
            pricebook2ID =standardPB,
            IsActive = true,
            UseStandardPrice = false,
            Product2Id=objProduct2_1.Id
        );
        insert objPricebookEntry1;

        list<SterlingQuoteItem__c> objSQi = new list<SterlingQuoteItem__c>();
        SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
        objst.name='test';
        objst.SterlingQuote__c = objquote.id;
        objst.IsInFrontierFootprint__c=false;
        objst.OverallStatus__c ='pending';
        objst.DiscountType__c ='ICB';
        objst.ApprovalTerritory__c ='Indiana';
        objst.ApprovalRouting__c='Customer Build';
        objst.ApprovalRegion__c='IN';
        objst.StandardMRC__c= 10.00;
        objst.StandardNRC__c=10.00;
        objst.AdjustedMRC__c=10.00;
        objst.AdjustedNRC__c=10.00;
        objst.Quantity__c=10;
        objst.Products__c=objProduct2_1.id;
        objst.OwnerId= userinfo.getUserId(); 
        objst.ItemOwner__c =userinfo.getUserId();
        objst.ApprovalPriority__c='Normal';
        objst.Locality__c='Indiana'; 
        objst.StateProvince__c='IN' ;
        //objst.State__c='IN';  10/16 raj
        objst.NXX__c='10';
        
        objst.SetNextApprover__c= true;
        objst.OverallStatus__c='';
        objst.SIFT_Required__c=true;
        objst.SIFT_InquiryId__c='1234';
        objst.NetNewMRR__c=10.00;
        insert objst;
        objsqi.add(objst);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',objquote.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(objquote);
        Quote_Extension objQuoteExtension = new Quote_Extension(sc);
        objQuoteExtension.redirectToNewSfaProduct(); 
        objQuoteExtension.reDirectToSFAQuote();
        apexpages.currentpage().getparameters().put('id',objQuote.id);
        objQuoteExtension.editAction(); 
        objQuoteExtension.showPopup();
        objQuoteExtension.SaveCustom();
        objQuoteExtension.StrQuote = objquote.Id;
        objQuoteExtension.deleteCustom();
        objQuoteExtension.ShowCreateOrderButton = true;
        objQuoteExtension.ShowLaunchEONButton = true;
        objQuoteExtension.LaunchEON();
        Test.stopTest();
    }
    static  testMethod  void  QuoteExtensionEdit() { 
        // Get the RecordType Id of the 'Global' Account RecordType
        Id globalRecId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Account'
            AND     DeveloperName = 'Global'
            LIMIT   1
        ]?.Id;
        // Create a new 'Global' Account with the above RecordType
        Account globalAcc1 = new Account(
            Name = 'GLOBAL ACCOUNT',
            RecordTypeId = globalRecId
        );
        insert globalAcc1;

        Account objAcc = new Account();
        objAcc.ParentId = globalAcc1.Id;
        objAcc.Name ='testing Name';
        objAcc.Legal_Street__c='test';
        objAcc.Legal_City__c='test';
        objAcc.Legal_State__c='test';
        objAcc.ShippingStreet='test';
        objAcc.ShippingCity='NY';
        objAcc.ShippingState='New York';
        objAcc.BillingStreet='test';
        objAcc.BillingCity='NY';
        objAcc.BillingState='New York';
        
        insert objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name ='Testing Name';
        objOpp.AccountId= objAcc.Id;
        objOpp.CloseDate = date.today();
        objOpp.StageName ='Verbal Commit';
        objOpp.Expected_Billed_Date__c = date.today();
        insert objOpp;
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];        
        SterlingQuote__c objquote = new SterlingQuote__c();
        objquote.Name='Testing Name';
        objquote.ExpirationDate__c=date.today();
        objquote.OpportunityId__c=objOpp.id;
        objquote.Account_Name__c= objAcc.Id;
        objquote.RecordTypeId = recordtypeid[0].Id; 
        //objquote.MinorLine__c = 0;
        insert objquote;      
        
        Id standardPB = Test.getStandardPricebookId();
        Product2 objProduct2_1 = new Product2(
            Name ='Testing Name',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        insert objProduct2_1;
        
        PricebookEntry objPricebookEntry1= new PricebookEntry(
            UnitPrice=1000,
            pricebook2ID =standardPB,
            IsActive = true,
            UseStandardPrice = false,
            Product2Id=objProduct2_1.Id
        );
        insert objPricebookEntry1;        
        
        list<SterlingQuoteItem__c> objSQi = new list<SterlingQuoteItem__c>();
        SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
        objst.name='test';
        objst.SterlingQuote__c = objquote.id;
        objst.IsInFrontierFootprint__c=false;
        objst.OverallStatus__c ='pending';
        objst.DiscountType__c ='ICB';
        objst.ApprovalTerritory__c ='Indiana';
        objst.ApprovalRouting__c='Customer Build';
        objst.ApprovalRegion__c='IN';
        objst.StandardMRC__c= 10.00;
        objst.StandardNRC__c=10.00;
        objst.AdjustedMRC__c=10.00;
        objst.AdjustedNRC__c=10.00;
        objst.Quantity__c=10;
        objst.Products__c=objProduct2_1.id;
        objst.OwnerId= userinfo.getUserId(); 
        objst.ItemOwner__c =userinfo.getUserId();
        objst.ApprovalPriority__c='Normal';
        objst.Locality__c='Indiana'; 
        objst.StateProvince__c='IN' ;
        //objst.State__c='IN';  10/16 raj
        objst.NXX__c='10';
        
        objst.SetNextApprover__c= true;
        objst.OverallStatus__c='';
        objst.SIFT_Required__c=true;
        objst.SIFT_InquiryId__c='1234';
        objst.NetNewMRR__c=10.00;
        insert objst;
        objsqi.add(objst);
        
        
        Test.startTest();
        // list<recordtype> lstrType =[select id from recordType where developerName ='SFA' And SobjectType='Sterlinquote__c'];       
        // objquote.RecordTypeId = lstrType[0].Id; 
        ApexPages.currentPage().getParameters().put('Id',objquote.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(objquote);
        Quote_Extension objQuoteExtension = new Quote_Extension(sc);
        objQuoteExtension.BackCustom();
        objQuoteExtension.closePopup();
        ObjQuoteExtension.ClosePopUpCreateOrder();
        //ObjQuoteExtension.createOrder();
        objQuoteExtension.getSterlingQuoteItems();
        objQuoteExtension.getRecordType();
        objQuoteExtension.editQuoteItemMethod();
        Quote_Extension.productSync(objquote.Id,objquote);
        ObjQuoteExtension.deleteCustom();
        //ObjQuoteExtension.deleteAction();
        // ObjQuoteExtension.CreateOrder();
        Test.stopTest();
        
    }
    
    static  testMethod  void  QuoteExtensionEdit3() { 
        // Get the RecordType Id of the 'Global' Account RecordType
        Id globalRecId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Account'
            AND     DeveloperName = 'Global'
            LIMIT   1
        ]?.Id;
        // Create a new 'Global' Account with the above RecordType
        Account globalAcc1 = new Account(
            Name = 'GLOBAL ACCOUNT',
            RecordTypeId = globalRecId
        );
        insert globalAcc1;

        Account objAcc = new Account();
        objAcc.ParentId = globalAcc1.Id;
        objAcc.Name ='testing Name';
        objAcc.Legal_Street__c='test';
        objAcc.Legal_City__c='test';
        objAcc.Legal_State__c='test';
        objAcc.ShippingStreet='test';
        objAcc.ShippingCity='NY';
        objAcc.ShippingState='New York';
        objAcc.BillingStreet='test';
        objAcc.BillingCity='NY';
        objAcc.BillingState='New York';
        
        insert objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name ='Testing Name';
        objOpp.AccountId= objAcc.Id;
        objOpp.CloseDate = date.today();
        objOpp.StageName ='Verbal Commit';
        objOpp.Expected_Billed_Date__c = date.today();
        insert objOpp;
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];        
        SterlingQuote__c objquote = new SterlingQuote__c();
        objquote.Name='Testing Name';
        objquote.ExpirationDate__c=date.today();
        objquote.OpportunityId__c=objOpp.id;
        objquote.Account_Name__c= objAcc.Id;
        objquote.RecordTypeId = recordtypeid[0].Id; 
        //objquote.MinorLine__c = 0;
        insert objquote;      
        
        Id standardPB = Test.getStandardPricebookId();
        Product2 objProduct2_1 = new Product2(
            Name ='Testing Name',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        insert objProduct2_1;
        
        PricebookEntry objPricebookEntry1= new PricebookEntry(
            UnitPrice=1000,
            pricebook2ID =standardPB,
            IsActive = true,
            UseStandardPrice = false,
            Product2Id=objProduct2_1.Id
        );
        insert objPricebookEntry1;        
        
        list<SterlingQuoteItem__c> objSQi = new list<SterlingQuoteItem__c>();
        SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
        objst.name='test';
        objst.SterlingQuote__c = objquote.id;
        objst.IsInFrontierFootprint__c=false;
        objst.OverallStatus__c ='pending';
        objst.DiscountType__c ='ICB';
        objst.ApprovalTerritory__c ='Indiana';
        objst.ApprovalRouting__c='Customer Build';
        objst.ApprovalRegion__c='IN';
        objst.StandardMRC__c= 10.00;
        objst.StandardNRC__c=10.00;
        objst.AdjustedMRC__c=10.00;
        objst.AdjustedNRC__c=10.00;
        objst.Quantity__c=10;
        objst.Products__c=objProduct2_1.id;
        objst.OwnerId= userinfo.getUserId(); 
        objst.ItemOwner__c =userinfo.getUserId();
        objst.ApprovalPriority__c='Normal';
        objst.Locality__c='Indiana'; 
        objst.StateProvince__c='IN' ;
        //objst.State__c='IN';  10/16 raj
        objst.NXX__c='10';
        
        objst.SetNextApprover__c= true;
        objst.OverallStatus__c='';
        objst.SIFT_Required__c=true;
        objst.SIFT_InquiryId__c='1234';
        objst.NetNewMRR__c=10.00;
        insert objst;
        objsqi.add(objst);
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',objquote.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(objquote);
        Quote_Extension objQuoteExtension = new Quote_Extension(sc);
        objQuoteExtension.productSyncClick();
        objQuoteExtension.productUnSyncClick();
        Test.stopTest();
    }
    
}