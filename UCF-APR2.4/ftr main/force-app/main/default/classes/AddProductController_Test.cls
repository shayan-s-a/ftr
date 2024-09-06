/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 5
**/
@isTest
Private class AddProductController_Test {

    static testmethod void addProductControllertest(){
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

            // Get the RecordType Id of the 'Master' Account RecordType
            Id masterRTId = [
                SELECT  Id,
                        DeveloperName
                FROM    RecordType
                WHERE   SObjectType = 'Account'
                AND     DeveloperName = 'Master'
                LIMIT   1
            ]?.Id;

            // Create a new 'Master' Account with the above RecordType and the 'Global' Account as its parent
            Account masterAcc = new Account(
                Name = 'Master Account',
                RecordTypeId = masterRTId,
                ParentId = globalAcc1.Id
            );

            insert masterAcc;

            opportunity objopportunity= new opportunity(AccountId=masterAcc.Id);
            objopportunity.Name ='testing opp';
            objopportunity.StageName='verbal commit';
            objopportunity.CloseDate= date.today();
            objopportunity.Expected_Billed_Date__c = date.today();
            insert objopportunity;
            SterlingQuote__c objSQ = new SterlingQuote__c();
            objSQ.Name='Testing Name';
            objSQ.ExpirationDate__c = date.today();
            objSQ.OpportunityId__c = objopportunity.Id;
            objSQ.Account_Name__c = masterAcc.id;
            //objSQ.CreatedById = userinfo.getUserId();
            insert objSQ;
            //call constructor
           //clsSelectedProducts  objPro= new clsSelectedProducts();
            Product2 objprod = new Product2();
            objprod.Name='testing product';
            // MMG 10/14/2014 added unit price
            objprod.UnitPrice__c = '15.00';
            insert objProd;
            ApexPages.currentPage().getParameters().put('strId',objProd.id);
            ApexPages.StandardController sc2 = new ApexPages.standardController(objProd);
            addproductController objPCon = new AddProductController(sc2);
            //objOppItemEdit.saveQuoteAndItem();
            //Call Class used to display information
            //OppItemEditController.clsSelectedProducts objSelectedProduct= new OppItemEditController.clsSelectedProducts();
            objPCon.closePopup();
        	objPCon.fetchOnlySearchProducts();

            Product2 objProduct2_1 = new Product2(
            Name ='Testing Name',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Item_Rate__c=10.00,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
            insert objProduct2_1;

            PricebookEntry objPricebookEntry1= new PricebookEntry(
            UnitPrice=1000,
            pricebook2ID =Test.getStandardPricebookId(),
            IsActive = true,
            UseStandardPrice = false,
            Product2Id=objProduct2_1.Id
            );
            insert objPricebookEntry1;

            //objPCon.getAllOrSelectedProducts();
            //objOppItemEdit.getOnlySearchProducts();
            //when strSearchProduct != null
            Product2 objProduct2_2 = new Product2(
            Name='%Aid To Construction%',
            Item_Code__c='Code',
            Item_Rate__c=20.00,
            Item_Type__c='T',
            ProductCode='5678',
            Grandfathered_Product__c='');
            insert objProduct2_2;

            PricebookEntry objPricebookEntry2= new PricebookEntry(
            UnitPrice=1000,
            pricebook2ID =Test.getStandardPricebookId(),
            IsActive = true,
            UseStandardPrice = false,
            Product2Id=objProduct2_2.Id);
            insert objPricebookEntry2;

            objPCon.strSearchProduct='Aid To Construction';
            Product2 objProduct2_3 = new Product2(
            Name='%Product%',
            Family='CPE',
            Item_Code__c='code',
            Item_Rate__c=30.00,
            Item_Type__c='Y',
            ProductCode='9012',
            Grandfathered_Product__c='');
            insert objProduct2_3;
            PricebookEntry objPricebookEntry3= new PricebookEntry(
           // Name='price3',
            Pricebook2ID = Test.getStandardPricebookId(),
            unitprice = 1000,
            IsActive = true,
            UseStandardPrice = false,
            Product2Id=objProduct2_3.Id);
            insert objPricebookEntry3;

            objPCon.strSearchProduct='Product';
            objPCon.displayPopup=true;
            objPCon.bolVal=true;
            objPCon.bolShowRecords=true;
            objPCon.strOpportunityID ='testing';

            ApexPages.currentPage().getParameters().put('oppId',objopportunity.Id);
            objPCon.getProducts();
            objPCon.prdFirst();
            objPCon.prdLast();
            objPCon.prdPrevious();
            objPCon.prdNext();

            Boolean temp = objPCon.prdHasNext;
            temp = objPCon.prdHasPrevious;
            temp = objPCon.displayAddressGrid;

            SterlingQuoteItem__c objLineItem = new SterlingQuoteItem__c();
            objLineItem.Quantity__c=10;
            objLineItem.TermLength__c=24;
            objLineItem.StandardMRC__c = 10;
            objLineItem.StandardNRC__c = 10;
            objLineItem.AdjustedMRC__c = 10;
            objLineItem.AdjustedNRC__c = 10;
            objLineItem.Locality__c = 'Indiana';
            objLineItem.StateProvince__c ='IN';
            objLineItem.ItemCode__c ='123';
            objLineItem.ApprovalTerritory__c ='Indiana';
            objLineItem.ApprovalRegion__c='central';
            objLineItem.NPA__c ='10';
            objLineItem.NXX__c = '10';
            objLineItem.IsInFrontierFootprint__c = false;
            objLineItem.SterlingQuote__c = objSQ.id;
            insert objLineItem;

            List<RecordType> lstRT = [select id, name FROM RecordType WHERE DeveloperName = 'SFA' limit 1];
            ApexPages.currentPage().getParameters().put('strId','');
            ApexPages.StandardController sc = new ApexPages.standardController(objProd);
            AddproductController objOppItemEdit1 = new AddproductController (sc);
            List<AddproductController.clsSelectedProducts> tt = new List<AddproductController.clsSelectedProducts>();
            AddproductController.clsSelectedProducts objs = new AddproductController.clsSelectedProducts();
            objs.bolIsSelected=true;
            objs.strquantity ='10';
            objs.strunitprice = '10';
            objs.strRenewalMRC='10';
            objs.strNRC= '10';
            objs.strTerm ='10';
            objs.strCPENRC='10';
            objs.strCPEGross='10';
            objs.objSQI = objLineItem;
            tt.add(objs);

            String temp2 = objs.strMRC;
            temp2 = objs.strNRC1;
            temp2 = objs.RecordTypeId;

            AddproductController.clsSelectedProducts objs1 = new AddproductController.clsSelectedProducts();

            objs1.objSQI = objLineItem;
            objs1.bolIsSelected = true;
            tt.add(objs1);
/*
            objOppItemEdit1.fetchOnlySearchProducts();
            objOppItemEdit1.getOnlySelectedProducts();
            objOppItemEdit1.cancelProducts();
            objOppItemEdit1.sterlingQuoteItemList();
            objSQ.Name='Testing Name';
            objSQ.ExpirationDate__c = date.today();
            objSQ.OpportunityId__c = objopportunity.Id;
            objSQ.Account_Name__c = objAccount.id;
            update objSQ;

            objoppItemEdit1.saveQuoteAndItem();
            objOppItemEdit1.lstClsSelectedProductsToDB = tt;
            //objOppItemEdit1.strAddtype('test');
            objOppItemEdit1.saveProducts();
            objOppItemEdit1.lstClsSelectedProductsToDB = tt;
            objOppItemEdit1.strStateCode('test');

            objOppItemEdit1.getOnlySelectedProducts();
            ApexPages.currentPage().getParameters().put('oppId',objopportunity.Id);
*/
        }

    static testmethod void addProductControllertest2(){
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

        // Get the RecordType Id of the 'Master' Account RecordType
        Id masterRTId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Account'
            AND     DeveloperName = 'Master'
            LIMIT   1
        ]?.Id;

        // Create a new 'Master' Account with the above RecordType and the 'Global' Account as its parent
        Account masterAcc = new Account(
            Name = 'Master Account',
            RecordTypeId = masterRTId,
            ParentId = globalAcc1.Id
        );

        insert masterAcc;

        opportunity objopportunity= new opportunity(AccountId=masterAcc.Id);
        objopportunity.Name ='testing opp';
        objopportunity.StageName='verbal commit';
        objopportunity.CloseDate= date.today();
        objopportunity.Expected_Billed_Date__c = date.today();
        insert objopportunity;
        SterlingQuote__c objSQ = new SterlingQuote__c();
        objSQ.Name='Testing Name';
        objSQ.ExpirationDate__c = date.today();
        objSQ.OpportunityId__c = objopportunity.Id;
        objSQ.Account_Name__c = masterAcc.id;

        insert objSQ;
        Product2 objprod = new Product2();
        objprod.Name='testing product';
        objprod.UnitPrice__c = '15.00';
        insert objProd;

        Product2 objProduct2_1 = new Product2(
            Name ='Testing Name',
            IsActive=True,
            SKU__c='',
            Item_Code__c='Code',
            Item_Rate__c=10.00,
            Item_Type__c='A',
            ProductCode='1234',
            Grandfathered_Product__c='');
        insert objProduct2_1;

        PricebookEntry objPricebookEntry1= new PricebookEntry(
            UnitPrice=1000,
            pricebook2ID =Test.getStandardPricebookId(),
            IsActive = true,
            UseStandardPrice = false,
            Product2Id=objProduct2_1.Id
            );
        insert objPricebookEntry1;

        Product2 objProduct2_2 = new Product2(
            Name='%Aid To Construction%',
            Item_Code__c='Code',
            Item_Rate__c=20.00,
            Item_Type__c='T',
            ProductCode='5678',
            Grandfathered_Product__c='');
        insert objProduct2_2;

        PricebookEntry objPricebookEntry2= new PricebookEntry(
            UnitPrice=1000,
            pricebook2ID =Test.getStandardPricebookId(),
            IsActive = true,
            UseStandardPrice = false,
            Product2Id=objProduct2_2.Id);
        insert objPricebookEntry2;

        Product2 objProduct2_3 = new Product2(
            Name='%Product%',
            Family='CPE',
            Item_Code__c='code',
            Item_Rate__c=30.00,
            Item_Type__c='Y',
            ProductCode='9012',
            Grandfathered_Product__c='');
        insert objProduct2_3;
        PricebookEntry objPricebookEntry3= new PricebookEntry(
            Pricebook2ID = Test.getStandardPricebookId(),
            unitprice = 1000,
            IsActive = true,
            UseStandardPrice = false,
            Product2Id=objProduct2_3.Id);
        insert objPricebookEntry3;

        ApexPages.currentPage().getParameters().put('oppId',objopportunity.Id);

        SterlingQuoteItem__c objLineItem = new SterlingQuoteItem__c();
        objLineItem.Quantity__c=10;
        objLineItem.TermLength__c=24;
        objLineItem.StandardMRC__c = 10;
        objLineItem.StandardNRC__c = 10;
        objLineItem.AdjustedMRC__c = 10;
        objLineItem.AdjustedNRC__c = 10;
        objLineItem.Locality__c = 'Indiana';
        objLineItem.StateProvince__c ='IN';
        objLineItem.ItemCode__c ='123';
        objLineItem.ApprovalTerritory__c ='Indiana';
        objLineItem.ApprovalRegion__c='central';
        objLineItem.NPA__c ='10';
        objLineItem.NXX__c = '10';
        objLineItem.IsInFrontierFootprint__c = false;
        objLineItem.SterlingQuote__c = objSQ.id;
        insert objLineItem;

        List<RecordType> lstRT = [select id, name FROM RecordType WHERE DeveloperName = 'SFA' limit 1];
        ApexPages.currentPage().getParameters().put('strId','');
        ApexPages.StandardController sc = new ApexPages.standardController(objProd);
        AddproductController objOppItemEdit1 = new AddproductController (sc);
        List<AddproductController.clsSelectedProducts> tt = new List<AddproductController.clsSelectedProducts>();
        AddproductController.clsSelectedProducts objs = new AddproductController.clsSelectedProducts();
        objs.bolIsSelected=true;
        objs.strquantity ='10';
        objs.strunitprice = '10';
        objs.strRenewalMRC='10';
        objs.strNRC= '10';
        objs.strTerm ='10';
        objs.strCPENRC='10';
        objs.strCPEGross='10';
        objs.objSQI = objLineItem;
        tt.add(objs);

        String temp2 = objs.strMRC;
        temp2 = objs.strNRC1;
        temp2 = objs.RecordTypeId;

        AddproductController.clsSelectedProducts objs1 = new AddproductController.clsSelectedProducts();

        objs1.objSQI = objLineItem;
        objs1.bolIsSelected = true;
        tt.add(objs1);
        //objOppItemEdit1.fetchOnlySearchProducts();
        objOppItemEdit1.getOnlySelectedProducts();
        objOppItemEdit1.cancelProducts();
        objOppItemEdit1.sterlingQuoteItemList();
        objSQ.Name='Testing Name';
        objSQ.ExpirationDate__c = date.today();
        objSQ.OpportunityId__c = objopportunity.Id;
        objSQ.Account_Name__c = masterAcc.id;
        update objSQ;

        objoppItemEdit1.saveQuoteAndItem();
        objOppItemEdit1.lstClsSelectedProductsToDB = tt;
        objOppItemEdit1.saveProducts();
        objOppItemEdit1.lstClsSelectedProductsToDB = tt;
        objOppItemEdit1.strStateCode('test');

        objOppItemEdit1.getOnlySelectedProducts();
        ApexPages.currentPage().getParameters().put('oppId',objopportunity.Id);
    }


        /**
            This test method tests miscellaneous functionalities of the AddProductController class
        */

        static testmethod void addProductControllerMisc(){
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
            Account globalAcc = new Account(
                Name = 'GLOBAL ACCOUNT',
                RecordTypeId = globalRecId
            );
            insert globalAcc;

            // Get the RecordType Id of the 'Master' Account RecordType
            Id masterRTId = [
                SELECT  Id,
                        DeveloperName
                FROM    RecordType
                WHERE   SObjectType = 'Account'
                AND     DeveloperName = 'Master'
                LIMIT   1
            ]?.Id;

            // Create a new 'Master' Account with the above RecordType and the 'Global' Account as its parent
            Account masterAcc = new Account(
                Name = 'Master Account',
                RecordTypeId = masterRTId,
                ParentId = globalAcc.Id
            );

            insert masterAcc;

            //Id standardPricebookId = Test.getStandardPricebookId(); // Replace
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            update standardPricebook;

            standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
            opportunity objOpportunity= new opportunity(
                AccountId=masterAcc.Id,
                Name ='testing opp',
                StageName='verbal commit',
                CloseDate= date.today(),
                Expected_Billed_Date__c = date.today(),
                Pricebook2Id = standardPricebook.Id
            );
            insert objOpportunity;

            SterlingQuote__c objSQ = new SterlingQuote__c(
                Name='Testing Name',
                ExpirationDate__c = date.today(),
                OpportunityId__c = objOpportunity.Id,
                Account_Name__c = masterAcc.id
            );
            insert objSQ;

            Product2 objProdWithUnitPrice = new Product2(
                Name='testing product',
                UnitPrice__c = '15.00'
            );
            insert objProdWithUnitPrice;

            Product2 objProdTest = new Product2(
                Name ='Testing Name',
                IsActive=True,
                Item_Code__c='Code',
                Item_Rate__c=10.00,
                Item_Type__c='A',
                ProductCode='1234',
                Grandfathered_Product__c='');
            insert objProdTest;

            PricebookEntry objPricebookEntryWithTestProduct= new PricebookEntry(
                UnitPrice=1000,
                pricebook2ID = standardPricebook.Id,
                IsActive = true,
                UseStandardPrice = false,
                Product2Id=objProdTest.Id
                );
            insert objPricebookEntryWithTestProduct;

            Product2 objProdAidToConstruction = new Product2(
                Name='%Aid To Construction%',
                Item_Code__c='Code',
                Item_Rate__c=20.00,
                Item_Type__c='T',
                ProductCode='5678',
                Grandfathered_Product__c='');
            insert objProdAidToConstruction;

            PricebookEntry objPricebookEntryWithACProduct= new PricebookEntry(
                UnitPrice=1000,
                pricebook2ID = standardPricebook.Id,
                IsActive = true,
                UseStandardPrice = false,
                Product2Id=objProdAidToConstruction.Id);
            insert objPricebookEntryWithACProduct;

            Product2 objProdProduct = new Product2(
                Name='%Product%',
                Family='CPE',
                Item_Code__c='code',
                Item_Rate__c=30.00,
                Item_Type__c='Y',
                ProductCode='9012',
                Grandfathered_Product__c='');
            insert objProdProduct;

            PricebookEntry objPricebookEntryWithProdProduct= new PricebookEntry(
                Pricebook2ID = standardPricebook.Id,
                unitprice = 1000,
                IsActive = true,
                UseStandardPrice = false,
                Product2Id=objProdProduct.Id);
            insert objPricebookEntryWithProdProduct;

            ApexPages.currentPage().getParameters().put('oppId',objOpportunity.Id);

            Test.startTest();
            SterlingQuoteItem__c objLineItem = new SterlingQuoteItem__c(
                Quantity__c=10,
                TermLength__c=24,
                DiscountType__c = 'SVP',
                StandardMRC__c = 10,
                StandardNRC__c = 10,
                AdjustedMRC__c = 10,
                AdjustedNRC__c = 10,
                Locality__c = 'Indiana',
                StateProvince__c ='IN',
                ItemCode__c ='123',
                ApprovalTerritory__c ='Indiana',
                ApprovalRegion__c='central',
                NPA__c ='10',
                NXX__c = '10',
                IsInFrontierFootprint__c = false,
                SterlingQuote__c = objSQ.id
            );
            insert objLineItem;

            List<RecordType> lstRT = [select id, name FROM RecordType WHERE DeveloperName = 'SFA' limit 1];
            ApexPages.currentPage().getParameters().put('strId','');
            ApexPages.StandardController sc = new ApexPages.standardController(objProdWithUnitPrice);
            ApexPages.currentPage().getParameters().put('addressType','Legal');
            Addproductcontroller objOppItemEdit = new Addproductcontroller (sc);
            List<Addproductcontroller.clsSelectedProducts> selectedProdList = new List<Addproductcontroller.clsSelectedProducts>();

            Addproductcontroller.clsSelectedProducts selectedProd = new Addproductcontroller.clsSelectedProducts();
            selectedProd.bolIsSelected=true;
            selectedProd.strQuantity ='10';
            selectedProd.strUnitPrice = '10';
            selectedProd.strRenewalMRC='10';
            selectedProd.strNRC= '10';
            selectedProd.strUnitPrice1 = '10';
            selectedProd.strTerm ='10';
            selectedProd.strCPENRC='10';
            selectedProd.strCPEGross='10';
            selectedProd.objSQI = objLineItem;
            selectedProd.strProductCategory = 'CPE';
            selectedProdList.add(selectedProd);

            String strMRC = selectedProd.strMRC;
            strMRC = selectedProd.strNRC1;
            strMRC = selectedProd.RecordTypeId;

            objOppItemEdit.getOnlySelectedProducts();
            objOppItemEdit.cancelProducts();
            objOppItemEdit.getOnlySelectedProducts();
            objOppItemEdit.lstClsSelectedProductsToDB = selectedProdList;
            List < SterlingQuoteItem__c > objLineItemList = objOppItemEdit.sterlingQuoteItemList();
            Assert.isNotNull(objLineItemList, 'Sterling Line Item object should not be null');
            objSQ.Name='Testing Name';
            objSQ.ExpirationDate__c = date.today();
            objSQ.OpportunityId__c = objOpportunity.Id;
            objSQ.Account_Name__c = masterAcc.id;
            update objSQ;

            objOppItemEdit.saveQuoteAndItem();
            objOppItemEdit.lstClsSelectedProductsToDB = selectedProdList;
            objOppItemEdit.saveProducts();
            objOppItemEdit.lstClsSelectedProductsToDB = selectedProdList;
            String strStateCodeString = objOppItemEdit.strStateCode('test');
            Assert.isNull(strStateCodeString, 'State Code string should be null'); 
            objOppItemEdit.getOnlySelectedProducts();
            Test.stopTest();

        }
    }