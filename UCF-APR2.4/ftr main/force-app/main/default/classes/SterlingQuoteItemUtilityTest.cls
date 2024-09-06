/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 4
**/
@isTest //(seeAllData = true)

private class SterlingQuoteItemUtilityTest {
    
    @TestSetup
    static void makeData(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Frontier Sales User'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Alternate Channel' limit 1].Id,
            isActive=true
        );
        insert u;
        User usr = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamamaAdmin.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Alternate Channel' limit 1].Id,
            isActive=true
        );
        insert usr;
        System.runAs(usr) {
            Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
            Account globalAcc = new Account();
            globalAcc.Name = 'GLOBAL ACCOUNT';
            globalAcc.RecordTypeId = globalRecId;
            insert globalAcc;
        }
    }
    
    static testmethod void updateSQI() {
        User u = [SELECT Id FROM USER WHERE Email = 'puser000@amamama.com' and isactive=true limit 1];
        
        list<SterlingQuoteItem__c> sqiList;
        Account globalAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Global' LIMIT 1];
        Account objAcc = new Account();
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
        objAcc.OwnerId=u.Id;
        objAcc.ParentId = globalAcc.Id;
        insert objAcc;        
        
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
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];        
        
        System.RunAs(u) {
            Opportunity objOpp = new Opportunity();
            objOpp.Name ='Testing Name';
            objOpp.AccountId= objAcc.Id;
            objOpp.CloseDate = date.today();
            objOpp.StageName ='Verbal Commit';
            objOpp.Expected_Billed_Date__c = date.today();
            objOpp.Bypass_Validation__c = true;
            insert objOpp;
            
            Opportunity objOpp2 = new Opportunity();
            objOpp2.Name ='Testing Name';
            objOpp2.AccountId= objAcc.Id;
            objOpp2.CloseDate = date.today();
            objOpp2.StageName ='Verbal Commit';
            objOpp2.Expected_Billed_Date__c = date.today();
            objOpp2.Bypass_Validation__c = true;
            insert objOpp2;
            
            SterlingQuote__c objquote = new SterlingQuote__c();
            objquote.Name='Testing Name';
            objquote.ExpirationDate__c=date.today();
            objquote.OpportunityId__c=objOpp.id;
            objquote.Account_Name__c= objAcc.Id;
            objquote.IsSyncing__c=false;
            objquote.RecordTypeId = recordtypeid[0].Id; 
            //objquote.MinorLine__c = 0;
            insert objquote;   
            SterlingQuote__c objquote2 = new SterlingQuote__c();
            objquote2.Name='Testing Name';
            objquote2.ExpirationDate__c=date.today();
            objquote2.OpportunityId__c=objOpp2.id;
            objquote2.Account_Name__c= objAcc.Id;
            objquote2.IsSyncing__c=false;
            objquote2.RecordTypeId = recordtypeid[0].Id; 
            //objquote.MinorLine__c = 0;
            insert objquote2;  
            
            PricebookEntry objPricebookEntry2= new PricebookEntry(
                UnitPrice=1000,
                pricebook2ID =Test.getStandardPricebookId(),
                IsActive = true,
                UseStandardPrice = false,
                Product2Id=objProduct2_1.Id
            );
            insert objPricebookEntry2; 
            
            sqiList = new list<SterlingQuoteItem__c>();
            
            SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
            objst.name='test';
            objst.Description__c='Running Test Class';
            objst.SterlingQuote__c = objquote2.id;
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
            objst.OwnerId= userinfo.getUserId(); 
            objst.ItemOwner__c =userinfo.getUserId();
            objst.ApprovalPriority__c='Normal';
            objst.Locality__c='Indiana'; 
            objst.StateProvince__c='IN' ;
            objst.NXX__c='10';
            objst.SetNextApprover__c= true;
            objst.OverallStatus__c='';
            objst.SIFT_Required__c=true;
            objst.SIFT_InquiryId__c='1234';
            objst.NetNewMRR__c=10.00;
            
            sqiList.add(objst);
            
            SterlingQuoteItem__c objst1 = new SterlingQuoteItem__c();
            objst1.name='test';
            objst1.SterlingQuote__c = objquote.id;
            objst1.IsInFrontierFootprint__c=false;
            objst1.OverallStatus__c ='pending';
            objst1.DiscountType__c ='ICB';
            objst1.ApprovalTerritory__c ='Indiana';
            objst1.ApprovalRouting__c='Customer Build';
            objst1.ApprovalRegion__c='IN';
            objst1.StandardMRC__c= 10.00;
            objst1.StandardNRC__c=10.00;
            objst1.AdjustedMRC__c=10.00;
            objst1.AdjustedNRC__c=10.00;
            objst1.Quantity__c=10;
            objst1.OwnerId= userinfo.getUserId(); 
            objst1.ItemOwner__c =userinfo.getUserId();
            objst1.ApprovalPriority__c='Normal';
            objst1.Locality__c='Indiana'; 
            objst1.StateProvince__c='IN' ;
            objst1.NXX__c='10';
            objst1.SetNextApprover__c= true;
            objst1.OverallStatus__c='';
            objst1.SIFT_Required__c=true;
            objst1.SIFT_InquiryId__c='1234';
            objst1.NetNewMRR__c=10.00;
            
            sqiList.add(objst1);  
            
            insert sqiList;
        }
        
        Test.startTest();
        
        sqiList[0].SetNextApprover__c = true;
        sqiList[0].CurrentStatus__c = 'Pending - Sales Engineering Manager';
        sqiList[0].ApprovalRouting__c = 'Renewal / Special Pricing';
        sqiList[1].CurrentStatus__c = 'Pending - Sales Engineering Manager';
        sqiList[1].ApprovalTerritory__c = 'National';
        update sqiList;
        sqiList[0].CurrentStatus__c='Pending - Engineering';
        update sqiList[0];
        SterlingQuoteItem__c duplicateSQI = sqiList[0];
        duplicateSQI.Id = null;
        duplicateSQI.discountType__c = 'ICBA';
        insert duplicateSQI;
        
        Test.stopTest();
    }
    
    static testmethod void checkSQI() {
        User u = [SELECT Id FROM USER WHERE Email = 'puser000@amamama.com' and isactive=true limit 1];
        list<SterlingQuoteItem__c> sqiList;
        Account globalAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Global' LIMIT 1];
        Account objAcc = new Account();
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
        objAcc.OwnerId=u.Id;
        objAcc.ParentId = globalAcc.Id;
        insert objAcc;
        
        
        list<Product2> sqProduct2;

        sqProduct2 = new list<Product2>();
        
        Product2 objProduct2_1 = new Product2(
            Name ='Testing Name',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Family = 'Ethernet',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        sqProduct2.add(objProduct2_1);

        Product2 objProduct2_2 = new Product2(
            Name ='Testing Name 2',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Family = 'Cloud Managed Solutions',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        sqProduct2.add(objProduct2_2);


        Product2 objProduct2_3 = new Product2(
            Name ='Testing Name 3',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Family = 'Manage Enterprise WiFi',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        sqProduct2.add(objProduct2_3);


        Product2 objProduct2_4 = new Product2(
            Name ='Testing Name 4',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Family = 'Frontier AnyWare',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        sqProduct2.add(objProduct2_4);
        
        insert sqProduct2;
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];        
        
        System.RunAs(u) {
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity objOpp = new Opportunity();
            objOpp.Name ='Testing Name';
            objOpp.AccountId= objAcc.Id;
            objOpp.CloseDate = date.today();
            objOpp.StageName ='Verbal Commit';
            objOpp.Expected_Billed_Date__c = date.today();
            objOpp.Bypass_Validation__c = true;
            oppList.add(objOpp);
            
            Opportunity objOpp2 = new Opportunity();
            objOpp2.Name ='Testing Name';
            objOpp2.AccountId= objAcc.Id;
            objOpp2.CloseDate = date.today();
            objOpp2.StageName ='Verbal Commit';
            objOpp2.Expected_Billed_Date__c = date.today();
            objOpp2.Bypass_Validation__c = true;
            oppList.add(objOpp2);
            insert oppList;
            
            List<SterlingQuote__c> quoteList = new List<SterlingQuote__c>();
            SterlingQuote__c objquote = new SterlingQuote__c();
            objquote.Name='Testing Name';
            objquote.ExpirationDate__c=date.today();
            objquote.OpportunityId__c=objOpp.id;
            objquote.Account_Name__c= objAcc.Id;
            objquote.IsSyncing__c=false;
            objquote.RecordTypeId = recordtypeid[0].Id; 
            //objquote.MinorLine__c = 0;
            quoteList.add(objquote);   
            SterlingQuote__c objquote2 = new SterlingQuote__c();
            objquote2.Name='Testing Name';
            objquote2.ExpirationDate__c=date.today();
            objquote2.OpportunityId__c=objOpp2.id;
            objquote2.Account_Name__c= objAcc.Id;
            objquote2.IsSyncing__c=false;
            objquote2.RecordTypeId = recordtypeid[0].Id; 
            //objquote.MinorLine__c = 0;
            quoteList.add(objquote2);  
            insert quoteList;  
            
            PricebookEntry objPricebookEntry2= new PricebookEntry(
                UnitPrice=1000,
                pricebook2ID =Test.getStandardPricebookId(),
                IsActive = true,
                UseStandardPrice = false,
                Product2Id=sqProduct2[0].Id
            );
            insert objPricebookEntry2; 
            
            sqiList = new list<SterlingQuoteItem__c>();
            
            SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
            objst.name='test';
            objst.Description__c='Running Test Class';
            objst.SterlingQuote__c = objquote2.id;
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
            objst.OwnerId= userinfo.getUserId(); 
            objst.ItemOwner__c =userinfo.getUserId();
            objst.ApprovalPriority__c='Normal';
            objst.Locality__c='Indiana'; 
            objst.StateProvince__c='IN' ;
            objst.NXX__c='10';
            objst.SetNextApprover__c= true;
            objst.OverallStatus__c='';
            objst.SIFT_Required__c=true;
            objst.SIFT_InquiryId__c='1234';
            objst.NetNewMRR__c=10.00;
            objst.Products__c = sqProduct2[0].Id;
            
            sqiList.add(objst);
            
            SterlingQuoteItem__c objst1 = new SterlingQuoteItem__c();
            objst1.name='test';
            objst1.SterlingQuote__c = objquote.id;
            objst1.IsInFrontierFootprint__c=false;
            objst1.OverallStatus__c ='pending';
            objst1.DiscountType__c ='ICB';
            objst1.ApprovalTerritory__c ='Indiana';
            objst1.ApprovalRouting__c='Customer Build';
            objst1.ApprovalRegion__c='IN';
            objst1.StandardMRC__c= 10.00;
            objst1.StandardNRC__c=10.00;
            objst1.AdjustedMRC__c=10.00;
            objst1.AdjustedNRC__c=10.00;
            objst1.Quantity__c=10;
            objst1.OwnerId= userinfo.getUserId(); 
            objst1.ItemOwner__c =userinfo.getUserId();
            objst1.ApprovalPriority__c='Normal';
            objst1.Locality__c='Indiana'; 
            objst1.StateProvince__c='IN' ;
            objst1.NXX__c='10';
            objst1.SetNextApprover__c= true;
            objst1.OverallStatus__c='';
            objst1.SIFT_Required__c=true;
            objst1.SIFT_InquiryId__c='1234';
            objst1.NetNewMRR__c=10.00;
            objst1.Products__c = sqProduct2[1].Id;

            
            sqiList.add(objst1);  


            SterlingQuoteItem__c duplObjst1 = new SterlingQuoteItem__c();
            duplObjst1.name='test';
            duplObjst1.SterlingQuote__c = objquote.id;
            duplObjst1.IsInFrontierFootprint__c=false;
            duplObjst1.OverallStatus__c ='pending';
            duplObjst1.DiscountType__c ='ICBA';
            duplObjst1.ApprovalTerritory__c ='Indiana';
            duplObjst1.ApprovalRouting__c='Customer Build';
            duplObjst1.ApprovalRegion__c='IN';
            duplObjst1.StandardMRC__c= 10.00;
            duplObjst1.StandardNRC__c=10.00;
            duplObjst1.AdjustedMRC__c=10.00;
            duplObjst1.AdjustedNRC__c=10.00;
            duplObjst1.Quantity__c=10;
            duplObjst1.OwnerId= userinfo.getUserId(); 
            duplObjst1.ItemOwner__c =userinfo.getUserId();
            duplObjst1.ApprovalPriority__c='Normal';
            duplObjst1.Locality__c='Indiana'; 
            duplObjst1.StateProvince__c='IN' ;
            duplObjst1.NXX__c='10';
            duplObjst1.SetNextApprover__c= true;
            duplObjst1.OverallStatus__c='';
            duplObjst1.PriorStatus__c='Approved - Engineering Wireless';
            duplObjst1.CurrentStatus__c = 'Pending - Sales Engineering Manager';
            duplObjst1.SIFT_Required__c=true;
            duplObjst1.SIFT_InquiryId__c='1234';
            duplObjst1.NetNewMRR__c=10.00;
            duplObjst1.Products__c = sqProduct2[2].Id;
            duplObjst1.CIAC__c = 100;
            sqiList.add(duplObjst1);  

            SterlingQuoteItem__c duplObjst2 = new SterlingQuoteItem__c();
            duplObjst2.name='test';
            duplObjst2.SterlingQuote__c = objquote2.id;
            duplObjst2.IsInFrontierFootprint__c=false;
            duplObjst2.OverallStatus__c ='pending';
            duplObjst2.DiscountType__c ='CTRA';
            duplObjst2.ApprovalTerritory__c ='Indiana';
            duplObjst2.ApprovalRouting__c='Customer Build';
            duplObjst2.ApprovalRegion__c='IN';
            duplObjst2.StandardMRC__c= 10.00;
            duplObjst2.StandardNRC__c=10.00;
            duplObjst2.AdjustedMRC__c=10.00;
            duplObjst2.AdjustedNRC__c=10.00;
            duplObjst2.Quantity__c=10;
            duplObjst2.OwnerId= userinfo.getUserId(); 
            duplObjst2.ItemOwner__c =userinfo.getUserId();
            duplObjst2.ApprovalPriority__c='Normal';
            duplObjst2.Locality__c='Indiana'; 
            duplObjst2.StateProvince__c='IN' ;
            duplObjst2.NXX__c='10';
            duplObjst2.SetNextApprover__c= true;
            duplObjst2.PriorStatus__c='Approved - Engineering Wireless';
            duplObjst2.CurrentStatus__c='Pending - Engineering Wireless';
            duplObjst2.SIFT_Required__c=true;
            duplObjst2.SIFT_InquiryId__c='1234';
            duplObjst2.NetNewMRR__c=10.00;
            duplObjst2.Products__c = sqProduct2[3].Id;
            duplObjst2.CIAC__c = 100;
            sqiList.add(duplObjst2);  

            SterlingQuoteItem__c duplObjst3 = new SterlingQuoteItem__c();
            duplObjst3.name='test';
            duplObjst3.SterlingQuote__c = objquote2.id;
            duplObjst3.IsInFrontierFootprint__c=false;
            duplObjst3.OverallStatus__c ='pending';
            duplObjst3.DiscountType__c ='ICB';
            duplObjst3.ApprovalTerritory__c ='Indiana';
            duplObjst3.ApprovalRouting__c='Customer Build';
            duplObjst3.ApprovalRegion__c='IN';
            duplObjst3.StandardMRC__c= 10.00;
            duplObjst3.StandardNRC__c=10.00;
            duplObjst3.AdjustedMRC__c=10.00;
            duplObjst3.AdjustedNRC__c=10.00;
            duplObjst3.Quantity__c=10;
            duplObjst3.OwnerId= userinfo.getUserId(); 
            duplObjst3.ItemOwner__c =userinfo.getUserId();
            duplObjst3.ApprovalPriority__c='Normal';
            duplObjst3.Locality__c='Indiana'; 
            duplObjst3.StateProvince__c='IN' ;
            duplObjst3.NXX__c='10';
            duplObjst3.SetNextApprover__c= true;
            duplObjst3.PriorStatus__c='Assigned - Sales Engineer';
            duplObjst3.CurrentStatus__c='Pending - Engineering';
            duplObjst3.SIFT_Required__c=true;
            duplObjst3.SIFT_InquiryId__c='1234';
            duplObjst3.NetNewMRR__c=10.00;
            duplObjst3.Products__c = sqProduct2[3].Id;
            duplObjst3.CIAC__c = 100;
            sqiList.add(duplObjst3);  
            
            insert sqiList;
        }
        Test.startTest();
        SterlingQuoteItemUtility.checkOpportunityCheckboxes(false, false, sqiList, sqiList);
        SterlingQuoteItemUtility.checkOpportunityCheckboxes(false, true, sqiList, sqiList);
        SterlingQuoteItemUtility.checkOpportunityCheckboxes(true, false, sqiList, sqiList);
        Test.stopTest();
    }
    
    static testmethod void deleteSQI() {
        User u = [SELECT Id FROM USER WHERE Email = 'puser000@amamama.com' and isactive=true limit 1];
        list<SterlingQuoteItem__c> objSQi;
        Account globalAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Global' LIMIT 1];
        Account objAcc = new Account();
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
        objAcc.OwnerId=u.Id;
        objAcc.ParentId = globalAcc.Id;
        insert objAcc;
        
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
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];        
        
        System.RunAs(u) {
            Opportunity objOpp = new Opportunity();
            objOpp.Name ='Testing Name';
            objOpp.AccountId= objAcc.Id;
            objOpp.CloseDate = date.today();
            objOpp.StageName ='Verbal Commit';
            objOpp.Expected_Billed_Date__c = date.today();
            objOpp.Bypass_Validation__c = true;
            insert objOpp;
            
            Opportunity objOpp2 = new Opportunity();
            objOpp2.Name ='Testing Name';
            objOpp2.AccountId= objAcc.Id;
            objOpp2.CloseDate = date.today();
            objOpp2.StageName ='Verbal Commit';
            objOpp2.Expected_Billed_Date__c = date.today();
            objOpp2.Bypass_Validation__c = true;
            insert objOpp2;
            
            SterlingQuote__c objquote = new SterlingQuote__c();
            objquote.Name='Testing Name';
            objquote.ExpirationDate__c=date.today();
            objquote.OpportunityId__c=objOpp.id;
            objquote.Account_Name__c= objAcc.Id;
            objquote.IsSyncing__c=false;
            objquote.RecordTypeId = recordtypeid[0].Id; 
            //objquote.MinorLine__c = 0;
            insert objquote;   
            SterlingQuote__c objquote2 = new SterlingQuote__c();
            objquote2.Name='Testing Name';
            objquote2.ExpirationDate__c=date.today();
            objquote2.OpportunityId__c=objOpp2.id;
            objquote2.Account_Name__c= objAcc.Id;
            objquote2.IsSyncing__c=false;
            objquote2.RecordTypeId = recordtypeid[0].Id; 
            //objquote.MinorLine__c = 0;
            insert objquote2;  
            
            PricebookEntry objPricebookEntry2= new PricebookEntry(
                UnitPrice=1000,
                pricebook2ID =Test.getStandardPricebookId(),
                IsActive = true,
                UseStandardPrice = false,
                Product2Id=objProduct2_1.Id
            );
            insert objPricebookEntry2; 
            
            objSQi = new list<SterlingQuoteItem__c>();
            
            SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
            objst.name='test';
            objst.Description__c='Running Test Class';
            objst.SterlingQuote__c = objquote2.id;
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
            objst.OwnerId= userinfo.getUserId(); 
            objst.ItemOwner__c =userinfo.getUserId();
            objst.ApprovalPriority__c='Normal';
            objst.Locality__c='Indiana'; 
            objst.StateProvince__c='IN' ;
            objst.NXX__c='10';
            objst.SetNextApprover__c= true;
            objst.OverallStatus__c='';
            objst.SIFT_Required__c=true;
            objst.SIFT_InquiryId__c='1234';
            objst.NetNewMRR__c=10.00;
            
            objSQi.add(objst);
            
            SterlingQuoteItem__c objst1 = new SterlingQuoteItem__c();
            objst1.name='test';
            objst1.SterlingQuote__c = objquote.id;
            objst1.IsInFrontierFootprint__c=false;
            objst1.OverallStatus__c ='pending';
            objst1.DiscountType__c ='ICB';
            objst1.ApprovalTerritory__c ='Indiana';
            objst1.ApprovalRouting__c='Customer Build';
            objst1.ApprovalRegion__c='IN';
            objst1.StandardMRC__c= 10.00;
            objst1.StandardNRC__c=10.00;
            objst1.AdjustedMRC__c=10.00;
            objst1.AdjustedNRC__c=10.00;
            objst1.Quantity__c=10;
            objst1.OwnerId= userinfo.getUserId(); 
            objst1.ItemOwner__c =userinfo.getUserId();
            objst1.ApprovalPriority__c='Normal';
            objst1.Locality__c='Indiana'; 
            objst1.StateProvince__c='IN' ;
            objst1.NXX__c='10';
            objst1.SetNextApprover__c= true;
            objst1.OverallStatus__c='';
            objst1.SIFT_Required__c=true;
            objst1.SIFT_InquiryId__c='1234';
            objst1.NetNewMRR__c=10.00;
            
            objSQi.add(objst1);  
            
            insert objSQi;
        }
        delete objSQi[0];
    }
    
    static testmethod void uncheckSQI() {
        User u = [SELECT Id FROM USER WHERE Email = 'puser000@amamama.com' and isactive=true limit 1];

        list<SterlingQuoteItem__c> sqiList;
        list<SterlingQuoteItem__c> sqiListOld;
        Account globalAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Global' LIMIT 1];
        Account objAcc = new Account();
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
        objAcc.OwnerId=u.Id;
        objAcc.ParentId = globalAcc.Id;
        insert objAcc;

        list<Product2> sqProduct2;

        sqProduct2 = new list<Product2>();
        
        Product2 objProduct2_1 = new Product2(
            Name ='Testing Name',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Family = 'Ethernet',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        sqProduct2.add(objProduct2_1);

        Product2 objProduct2_2 = new Product2(
            Name ='Testing Name 2',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Family = 'Cloud Managed Solutions',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        sqProduct2.add(objProduct2_2);


        Product2 objProduct2_3 = new Product2(
            Name ='Testing Name 3',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Family = 'Manage Enterprise WiFi',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        sqProduct2.add(objProduct2_3);


        Product2 objProduct2_4 = new Product2(
            Name ='Testing Name 4',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Family = 'Frontier AnyWare',
            Item_Rate__c=10.00,
            MajorProduct__c=true,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        sqProduct2.add(objProduct2_4);
        
        insert sqProduct2;
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];        
        
        System.RunAs(u) {
            Opportunity objOpp = new Opportunity();
            objOpp.Name ='Testing Name 1';
            objOpp.AccountId= objAcc.Id;
            objOpp.CloseDate = date.today();
            objOpp.StageName ='Verbal Commit';
            objOpp.Expected_Billed_Date__c = date.today();
            objOpp.Bypass_Validation__c = true;
            insert objOpp;
            
            Opportunity objOpp2 = new Opportunity();
            objOpp2.Name ='Testing Name 2';
            objOpp2.AccountId= objAcc.Id;
            objOpp2.CloseDate = date.today();
            objOpp2.StageName ='Verbal Commit';
            objOpp2.Expected_Billed_Date__c = date.today();
            objOpp2.Bypass_Validation__c = true;
            insert objOpp2;

            Opportunity objOpp3 = new Opportunity();
            objOpp3.Name ='Testing Name 3';
            objOpp3.AccountId= objAcc.Id;
            objOpp3.CloseDate = date.today();
            objOpp3.StageName ='Verbal Commit';
            objOpp3.Expected_Billed_Date__c = date.today();
            objOpp3.Bypass_Validation__c = true;
            insert objOpp3;
            
            SterlingQuote__c objquote = new SterlingQuote__c();
            objquote.Name='Testing Name';
            objquote.ExpirationDate__c=date.today();
            objquote.OpportunityId__c=objOpp.id;
            objquote.Account_Name__c= objAcc.Id;
            objquote.IsSyncing__c=false;
            objquote.RecordTypeId = recordtypeid[0].Id; 
            //objquote.MinorLine__c = 0;
            insert objquote;   
            SterlingQuote__c objquote2 = new SterlingQuote__c();
            objquote2.Name='Testing Name';
            objquote2.ExpirationDate__c=date.today();
            objquote2.OpportunityId__c=objOpp2.id;
            objquote2.Account_Name__c= objAcc.Id;
            objquote2.IsSyncing__c=false;
            objquote2.RecordTypeId = recordtypeid[0].Id; 
            //objquote.MinorLine__c = 0;
            insert objquote2;  

            SterlingQuote__c objquote3 = new SterlingQuote__c();
            objquote3.Name='Testing Name';
            objquote3.ExpirationDate__c=date.today();
            objquote3.OpportunityId__c=objOpp3.id;
            objquote3.Account_Name__c= objAcc.Id;
            objquote3.IsSyncing__c=false;
            objquote3.RecordTypeId = recordtypeid[0].Id; 
            //objquote.MinorLine__c = 0;
            insert objquote3;  
            
            PricebookEntry objPricebookEntry2= new PricebookEntry(
                UnitPrice=1000,
                pricebook2ID =Test.getStandardPricebookId(),
                IsActive = true,
                UseStandardPrice = false,
                Product2Id=sqProduct2[0].Id
            );
            insert objPricebookEntry2; 
            
            sqiList = new list<SterlingQuoteItem__c>();
            sqiListOld = new list<SterlingQuoteItem__c>();
            
            SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
            objst.name='test';
            objst.Description__c='Running Test Class';
            objst.SterlingQuote__c = objquote2.id;
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
            objst.OwnerId= userinfo.getUserId(); 
            objst.ItemOwner__c =userinfo.getUserId();
            objst.ApprovalPriority__c='Normal';
            objst.Locality__c='Indiana'; 
            objst.StateProvince__c='IN' ;
            objst.NXX__c='10';
            objst.SetNextApprover__c= true;
            objst.OverallStatus__c='';
            objst.SIFT_Required__c=true;
            objst.SIFT_InquiryId__c='1234';
            objst.NetNewMRR__c=10.00;
            objst.Products__c = sqProduct2[0].Id;
            objst.CurrentStatus__c='Pending - Engineering Wireless Final';
            
            sqiList.add(objst);
            
            SterlingQuoteItem__c objst1 = new SterlingQuoteItem__c();
            objst1.name='test';
            objst1.SterlingQuote__c = objquote.id;
            objst1.IsInFrontierFootprint__c=false;
            objst1.OverallStatus__c ='pending';
            objst1.DiscountType__c ='ICB';
            objst1.ApprovalTerritory__c ='Indiana';
            objst1.ApprovalRouting__c='Customer Build';
            objst1.ApprovalRegion__c='IN';
            objst1.StandardMRC__c= 10.00;
            objst1.StandardNRC__c=10.00;
            objst1.AdjustedMRC__c=10.00;
            objst1.AdjustedNRC__c=10.00;
            objst1.Quantity__c=10;
            objst1.OwnerId= userinfo.getUserId(); 
            objst1.ItemOwner__c =userinfo.getUserId();
            objst1.ApprovalPriority__c='Normal';
            objst1.Locality__c='Indiana'; 
            objst1.StateProvince__c='IN' ;
            objst1.NXX__c='10';
            objst1.SetNextApprover__c= true;
            objst1.OverallStatus__c='';
            objst1.SIFT_Required__c=true;
            objst1.SIFT_InquiryId__c='1234';
            objst1.NetNewMRR__c=10.00;
            objst1.Products__c = sqProduct2[1].Id;
            objst1.CurrentStatus__c='Pending - Site Verification';
            
            sqiList.add(objst1);  

            SterlingQuoteItem__c duplObjst1 = new SterlingQuoteItem__c();
            duplObjst1.name='test';
            duplObjst1.SterlingQuote__c = objquote3.id;
            duplObjst1.IsInFrontierFootprint__c=false;
            duplObjst1.OverallStatus__c ='pending';
            duplObjst1.DiscountType__c ='CTRA';
            duplObjst1.ApprovalTerritory__c ='Indiana';
            duplObjst1.ApprovalRouting__c='Customer Build';
            duplObjst1.ApprovalRegion__c='IN';
            duplObjst1.StandardMRC__c= 10.00;
            duplObjst1.StandardNRC__c=10.00;
            duplObjst1.AdjustedMRC__c=10.00;
            duplObjst1.AdjustedNRC__c=10.00;
            duplObjst1.Quantity__c=10;
            duplObjst1.OwnerId= userinfo.getUserId(); 
            duplObjst1.ItemOwner__c =userinfo.getUserId();
            duplObjst1.ApprovalPriority__c='Normal';
            duplObjst1.Locality__c='Indiana'; 
            duplObjst1.StateProvince__c='IN' ;
            duplObjst1.NXX__c='10';
            duplObjst1.SetNextApprover__c= true;
            duplObjst1.OverallStatus__c='';
            duplObjst1.SIFT_Required__c=true;
            duplObjst1.SIFT_InquiryId__c='1234';
            duplObjst1.NetNewMRR__c=10.00;
            duplObjst1.Products__c = sqProduct2[2].Id;
            duplObjst1.CurrentStatus__c='Pending - Engineering Wireless';
            sqiList.add(duplObjst1);  

            SterlingQuoteItem__c duplObjst2 = new SterlingQuoteItem__c();
            duplObjst2.name='test';
            duplObjst2.SterlingQuote__c = objquote3.id;
            duplObjst2.IsInFrontierFootprint__c=false;
            duplObjst2.OverallStatus__c ='pending';
            duplObjst2.DiscountType__c ='ICBA';
            duplObjst2.ApprovalTerritory__c ='Indiana';
            duplObjst2.ApprovalRouting__c='Customer Build';
            duplObjst2.ApprovalRegion__c='IN';
            duplObjst2.StandardMRC__c= 10.00;
            duplObjst2.StandardNRC__c=10.00;
            duplObjst2.AdjustedMRC__c=10.00;
            duplObjst2.AdjustedNRC__c=10.00;
            duplObjst2.Quantity__c=10;
            duplObjst2.OwnerId= userinfo.getUserId(); 
            duplObjst2.ItemOwner__c =userinfo.getUserId();
            duplObjst2.ApprovalPriority__c='Normal';
            duplObjst2.Locality__c='Indiana'; 
            duplObjst2.StateProvince__c='IN' ;
            duplObjst2.NXX__c='10';
            duplObjst2.SetNextApprover__c= true;
            duplObjst2.OverallStatus__c='';
            duplObjst2.SIFT_Required__c=true;
            duplObjst2.SIFT_InquiryId__c='1234';
            duplObjst2.NetNewMRR__c=10.00;
            duplObjst2.Products__c = sqProduct2[3].Id;
            duplObjst2.ApprovalTerritory__c = 'National';
            duplObjst2.CurrentStatus__c ='Pending Ready for Review';
            sqiList.add(duplObjst2);  

            insert sqiList;

            SterlingQuoteItem__c duplObjst3 = new SterlingQuoteItem__c();
            duplObjst3.name='test';
            duplObjst3.SterlingQuote__c = objquote3.id;
            duplObjst3.IsInFrontierFootprint__c=false;
            duplObjst3.OverallStatus__c ='pending';
            duplObjst3.DiscountType__c ='ICB';
            duplObjst3.ApprovalTerritory__c ='Indiana';
            duplObjst3.ApprovalRouting__c='Customer Build';
            duplObjst3.ApprovalRegion__c='IN';
            duplObjst3.StandardMRC__c= 10.00;
            duplObjst3.StandardNRC__c=10.00;
            duplObjst3.AdjustedMRC__c=10.00;
            duplObjst3.AdjustedNRC__c=10.00;
            duplObjst3.Quantity__c=10;
            duplObjst3.OwnerId= userinfo.getUserId(); 
            duplObjst3.ItemOwner__c =userinfo.getUserId();
            duplObjst3.ApprovalPriority__c='Normal';
            duplObjst3.Locality__c='Indiana'; 
            duplObjst3.StateProvince__c='IN' ;
            duplObjst3.NXX__c='10';
            duplObjst3.SetNextApprover__c= true;
            duplObjst3.OverallStatus__c='';
            duplObjst3.SIFT_Required__c=true;
            duplObjst3.SIFT_InquiryId__c='1234';
            duplObjst3.NetNewMRR__c=10.00;
            duplObjst3.Products__c = sqProduct2[3].Id;
            sqiListOld.add(duplObjst3);  

            insert sqiListOld;
        }

        Test.startTest();
        SterlingQuoteItemUtility.uncheckOpportunityCheckboxes(false, false, sqiList, sqiList);
        SterlingQuoteItemUtility.uncheckOpportunityCheckboxes(false, true, sqiList, sqiList);
        SterlingQuoteItemUtility.uncheckOpportunityCheckboxes(true, false, sqiList, sqiList);
        SterlingQuoteItemUtility.uncheckOpportunityCheckboxes(true, false, sqiList, sqiListOld);
        Test.stopTest();
    }
}