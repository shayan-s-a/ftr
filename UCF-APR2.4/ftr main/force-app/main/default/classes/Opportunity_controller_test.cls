/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 7
**/
@isTest //(seealldata=true)
private class Opportunity_controller_test {
    static Account ObjAcc = null;
    static Opportunity ObjOpp = null;
    static OpportunityLineItem testOLI1 = null;

    static {
         Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account gblAcc1 = new Account();
        gblAcc1.Name = 'GLOBAL ACCOUNT';
        gblAcc1.RecordTypeId = globalRecId;
        insert gblAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;

        ObjAcc = new Account(Name = 'Testing Name');
        ObjAcc.Name = 'Testing Name';
        ObjAcc.ParentId = gblAcc1.Id;
        ObjAcc.RecordTypeId = MasterRTId;
        //ObjAcc = new Account();
    //ObjAcc.Name = 'Testing Name';
        ObjAcc.Legal_City__c = 'Plano';
        ObjAcc.Legal_Country__c = 'US';
        ObjAcc.Legal_State__c = 'TX';
        ObjAcc.Legal_Street__c = 'Test';
        ObjAcc.Legal_Zip__c = '1234';
        ObjAcc.BillingCity = 'Plano';
        ObjAcc.BillingCountry = 'United States';
        ObjAcc.BillingPostalCode = '1234';
        ObjAcc.BillingState = 'Texas';
        ObjAcc.BillingStreet = 'test';
        ObjAcc.ShippingCity = 'Plano';
        ObjAcc.ShippingCountry = 'United States';
        ObjAcc.ShippingPostalCode = '1234';
        ObjAcc.ShippingState = 'Texas';
        ObjAcc.ShippingStateCode = 'TX';
        ObjAcc.ShippingStreet = 'test';
        insert ObjAcc;

        ObjOpp = new Opportunity();
        ObjOpp.Name = 'Testing Name';
        ObjOpp.AccountId = objAcc.Id;
        ObjOpp.CloseDate = date.today();
        ObjOpp.StageName = 'Verbal Commit';
        ObjOpp.Opportunity_Type__c = 'New';
        ObjOpp.Expected_Billed_Date__c = date.today();
        insert ObjOpp;
        
        Product2 prodAccess = new Product2();
        prodAccess.Name = 'Access';
        prodAccess.ProductCode = 'ENT_ETH_ACCESS_0001';
        prodAccess.IsActive = true;
        insert prodAccess;

        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prodAccess.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert standardPrice;

        Quote oQuote = new Quote();
        oQuote.Name = 'Testing Quote';
        oQuote.OpportunityId = objOpp.id;
        oQuote.Pricebook2Id = Test.getStandardPricebookId();
        oQuote.Service_Term__c = '24 Months';
        insert oQuote;
        QuoteLineItem oQLI = new QuoteLineItem();
        oQLI.QuoteId = oQuote.id;
        oQLI.PricebookEntryId = standardPrice.id;
        oQLI.Quantity = 1;
        oQLI.UnitPrice = 34.50;
        oQLI.Term__c = '36 Months';
        oQLI.vlocity_cmt__Product2Id__c = prodAccess.Id;
        oQLI.Product2Id = prodAccess.Id;
        oQLI.Floor_Price_One_Time__c=11.01;
        oQLI.Floor_Price_Recurring__c = 11.01;
        insert oQLI;

        //PricebookEntry pb = [Select Id from PriceBookEntry where IsActive = true Limit 1];
        Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X', isActive = true);
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        testOLI1 = new OpportunityLineItem(PriceBookEntryId = pbEntry.Id, Quantity = 1, OpportunityID = ObjOpp.Id, UnitPrice = 10);
        insert testOLI1;
        List<Note> noteList = new List<Note>();
        for (integer i = 0; i < 3; i++) {
            noteList.add(new Note(title = 'Test' + i, parentId = ObjOpp.Id));
        }
        insert noteList;

        Attachment Newatt = new Attachment();
        Newatt.Body = Blob.valueOf('Unit Test Attachment Body');
        Newatt.Name = 'Testing Name';
        Newatt.parentId = ObjOpp.Id;
        insert Newatt;

        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        System.runAs(u) {
            Territory2Model t2m = new Territory2Model();
            t2m.DeveloperName = 'test';
            t2m.Name = 'test';
            insert t2m;

            Territory2Type t2t = [SELECT id FROM Territory2Type LIMIT 1];

            Territory2 tr2 = new Territory2();
            tr2.Name = 'Test TR';
            tr2.Territory2ModelId = t2m.Id;
            tr2.DeveloperName = 'test';
            tr2.Territory2TypeId = t2t.Id;
            insert tr2;

            ObjectTerritory2Association o2a = new ObjectTerritory2Association();
            o2a.ObjectId = objAcc.Id;
            o2a.Territory2Id = [SELECT Id FROM Territory2 LIMIT 1].id;
            o2a.AssociationCause = 'Territory2Manual';
            insert o2a;
        }

    }
  /*  static testMethod void opportunitycontollerEdit2() {
        //Contract cont1 = [select id from Contract where AccountId =:objAcc.ID limit 1];
        list<RecordType> recordtypeid = [
            SELECT BusinessProcessId, DeveloperName, Id, Name, SobjectType
            FROM RecordType
            WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'
        ];
        Id sliRecordTypeId = Schema.SObjectType.SterlingQuoteItem__c.getRecordTypeInfosByName().get('Sterling Line Item').getRecordTypeId();
        Id sterlingRecordTypeId = Schema.SObjectType.SterlingQuote__c.getRecordTypeInfosByName().get('Sterling').getRecordTypeId();
        SterlingQuoteItemTriggerStaticValues.isFirstAfterUpdate = false;
        SterlingQuote__c objquote = new SterlingQuote__c();
        objquote.Name = 'Testing Name';
        objquote.ExpirationDate__c = date.today();
        objquote.OpportunityId__c = objOpp.id;
        objquote.Account_Name__c = objAcc.Id;
        objquote.RecordTypeId = recordtypeid[0].Id;
        objquote.IsSyncing__c = true;
        //objquote.MinorLine__c = 0;
        insert objquote;
        list<SterlingQuoteItem__c> objSQi = new List<SterlingQuoteItem__c>();
        SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
        objst.name = 'test';
        objst.SterlingQuote__c = objquote.id;
        objst.IsInFrontierFootprint__c = false;
        objst.OverallStatus__c = 'pending';
        objst.DiscountType__c = 'ICB';
        objst.ApprovalTerritory__c = 'Indiana';
        objst.ApprovalRouting__c = 'Customer Build';
        objst.ApprovalRegion__c = 'IN';
        objst.StandardMRC__c = 10.00;
        objst.StandardNRC__c = 10.00;
        objst.AdjustedMRC__c = 10.00;
        objst.AdjustedNRC__c = 10.00;
        objst.Quantity__c = 10;
        //objst.Products__c=objProduct2_1.id;
        objst.OwnerId = userinfo.getUserId();
        objst.ItemOwner__c = userinfo.getUserId();
        objst.ApprovalPriority__c = 'Normal';
        objst.Locality__c = 'Indiana';
        objst.StateProvince__c = 'IN';
        // objst.State__c='IN'; 10/16 Raj
        objst.NXX__c = '10';
        Test.startTest();
        objst.SetNextApprover__c = true;
        objst.OverallStatus__c = '';
        objst.SIFT_Required__c = true;
        objst.SIFT_InquiryId__c = '1234';
        insert objst;
        objsqi.add(objst);

        ApexPages.currentPage().getParameters().put('Id', ObjOpp.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(ObjOpp);
        Opportunity_Controller objOppExtension = new Opportunity_Controller(sc);
        objOppExtension.SelectedId = objquote.Id;
        objOppExtension.sterlingquote();
        objOppExtension.editlinks();
        // Non-Query Methods
        objOppExtension.attFirst();
        objOppExtension.attLast();
        objOppExtension.attNext();
        objOppExtension.attPrevious();
        objOppExtension.closePopup();
        objOppExtension.closePopupQQ();
        objOppExtension.closeProposalPopup();
        objOppExtension.createProposal();
        objOppExtension.getProducts();
        objOppExtension.getSchedules();
        objOppExtension.redirectToNewAttachment();
        objOppExtension.redirectToNewNote();
        objOppExtension.reDirectToSFAQuote();
        objOppExtension.reDirectToSterling();
        objOppExtension.NewSfaQuote();
        objOppExtension.editaction();

        //End Non-Query Methods
        objOppExtension.getStrQuotes();
        objOppExtension.getSterlingQuote();
        objOppExtension.GetNoteItem1();
        objOppExtension.SterlingQuoteDelVal = objst.Id;
        objst.RecordTypeId = sliRecordTypeId;
        update objst;
        objQuote.RecordTypeId = sterlingRecordTypeId;
        update objQuote;
        objOppExtension.strOppProductEditval = objst.Id;
        objOppExtension.SelectedId = objQuote.Id;
        objOppExtension.editlinks();
        objOppExtension.editProductMethod();
        objOppExtension.delOppProductMethod();
        Test.stopTest();
    }*/

 /*   static testMethod void opportunitycontollerEdit() {
        //Contract cont1 = [select id from Contract where AccountId =:objAcc.ID limit 1];
        list<RecordType> recordtypeid = [
            SELECT BusinessProcessId, DeveloperName, Id, Name, SobjectType
            FROM RecordType
            WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'
        ];

        SterlingQuoteItemTriggerStaticValues.isFirstAfterUpdate = false;
        SterlingQuote__c objquote = new SterlingQuote__c();
        objquote.Name = 'Testing Name';
        objquote.ExpirationDate__c = date.today();
        objquote.OpportunityId__c = objOpp.id;
        objquote.Account_Name__c = objAcc.Id;
        objquote.RecordTypeId = recordtypeid[0].Id;
        objquote.IsSyncing__c = true;
        //objquote.MinorLine__c = 0;
        insert objquote;
        list<SterlingQuoteItem__c> objSQi = new List<SterlingQuoteItem__c>();
        SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
        objst.name = 'test';
        objst.SterlingQuote__c = objquote.id;
        objst.IsInFrontierFootprint__c = false;
        objst.OverallStatus__c = 'pending';
        objst.DiscountType__c = 'ICB';
        objst.ApprovalTerritory__c = 'Indiana';
        objst.ApprovalRouting__c = 'Customer Build';
        objst.ApprovalRegion__c = 'IN';
        objst.StandardMRC__c = 10.00;
        objst.StandardNRC__c = 10.00;
        objst.AdjustedMRC__c = 10.00;
        objst.AdjustedNRC__c = 10.00;
        objst.Quantity__c = 10;
        //objst.Products__c=objProduct2_1.id;
        objst.OwnerId = userinfo.getUserId();
        objst.ItemOwner__c = userinfo.getUserId();
        objst.ApprovalPriority__c = 'Normal';
        objst.Locality__c = 'Indiana';
        objst.StateProvince__c = 'IN';
        // objst.State__c='IN'; 10/16 Raj
        objst.NXX__c = '10';

        objst.SetNextApprover__c = true;
        objst.OverallStatus__c = '';
        objst.SIFT_Required__c = true;
        objst.SIFT_InquiryId__c = '1234';
        insert objst;
        objsqi.add(objst);
        ApexPages.currentPage().getParameters().put('Id', ObjOpp.Id);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(ObjOpp);
        Opportunity_Controller objOppExtension = new Opportunity_Controller(sc);
        objOppExtension.SelectedId = objquote.Id;

        SterlingQuote__c objSterlingQuote = [SELECT id, RecordType.name, recordtypeId FROM SterlingQuote__c WHERE id = :objquote.Id];

        recordtype record = [
            SELECT BusinessProcessId, DeveloperName, Id, Name, SobjectType
            FROM RecordType
            WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'
        ];
        objSterlingQuote.RecordTypeId = record.id;
        update objSterlingQuote;
        objOppExtension.strOppProductEditval = objst.Id;
        objOppExtension.editProductMethod();
        objOppExtension.fetchAllAttachments();
        objOppExtension.getAllQuotes();
        objOppExtension.getAttachments();
        contract objcon = new contract();
        objcon.Name = 'Test';
        objcon.AccountId = objAcc.Id;
        objcon.ShippingStreet = 'test';
        objcon.ShippingCity = 'NY';
        objcon.ShippingState = 'New York';
        objcon.ShippingPostalCode = '44011';
        objcon.ShippingCountry = 'United States';
        objcon.BillingStreet = 'test';
        objcon.BillingCity = 'NY';
        objcon.BillingState = 'New York';
        objcon.BillingPostalCode = '44011';
        objcon.BillingCountry = 'United States';

        insert objcon;
        objOppExtension.generateschedule();
        SterlingQuote__c strobj = [SELECT id FROM SterlingQuote__c WHERE id = :objquote.id];
        Opportunity_Controller.WrapperOpportunityProduct objopc = new Opportunity_Controller.WrapperOpportunityProduct(objst, testOLI1, null);
        objOppExtension.presentProduct = objst.id;
        objOppExtension.SubmitForICB();

        objOppExtension.currentProduct = objst.id;
        objOppExtension.submitforapproval();
        objOppExtension.updateSterlingQuote();
        objOppExtension.first();
        objOppExtension.showPopup();
        objoppExtension.showPopupQQ();
        objOppExtension.updateStandardSetController();
        objOppExtension.next();
        objOppExtension.last();
        objOppExtension.previous();

        // Non-Query
        objOppExtension.prdFirst();
        objOppExtension.prdLast();
        objOppExtension.prdPrevious();
        objOppExtension.prdNext();
        objOppExtension.getSchedule();
        objOppExtension.schFirst();
        objOppExtension.schLast();
        objOppExtension.schPrevious();
        objOppExtension.schNext();
        Boolean schHasNext = objOppExtension.schHasNext;
        Boolean schHasPrevious = objOppExtension.schHasPrevious;
        Boolean prdHasNext = objOppExtension.prdHasNext;
        Boolean prdHasPrevious = objOppExtension.prdHasPrevious;
        Boolean hasNext = objOppExtension.hasNext;
        Boolean hasPrevious = objOppExtension.hasPrevious;
        Integer pageNumber = objOppExtension.pageNumber;

        // End Non-Query

        Apexpages.currentpage().getparameters().put('strQuoteid', objQuote.Id);
        objOppExtension.productSyncClick();
        objOppExtension.productUnSyncClick();
        //       objOppExtension.retrieveAccountDetails();
        objOppExtension.getQQTypes();
        objOppExtension.getProposalTypes();

        ApexPages.StandardController sc1 = new ApexPages.standardController(objOpp);
        list<Opportunity_Controller.AttachmentWrapper> TT = new List<Opportunity_Controller.AttachmentWrapper>();
        Opportunity_Controller.AttachmentWrapper objattach = new Opportunity_Controller.AttachmentWrapper();

        objAttach.Name = 'Testing';
        objAttach.typeOf = 'test';
        objAttach.ID = '1234';
        objAttach.createdById = 'test';
        objAttach.createByName = 'test name';
        objAttach.urlRedirection = 'Testing Name';
        TT.add(objAttach);
        list<Opportunity_Controller.WrapperOpportunityProduct> TW = new List<Opportunity_Controller.WrapperOpportunityProduct>();
        Opportunity_Controller.WrapperOpportunityProduct objAttwrapper1 = new Opportunity_Controller.WrapperOpportunityProduct();
        objst.OverallStatus__c = 'Approved';
        objst.DiscountType__c = '';
        update objst;

        Opportunity_Controller.WrapperOpportunityProduct objAttwrapper = new Opportunity_Controller.WrapperOpportunityProduct();
        objAttwrapper.status = 'Test';
        objAttwrapper.Name = 'Test';
        objAttwrapper.Quantity = 10;
        objAttwrapper.IsPromoProduct = 'Test';
        objAttwrapper.NumInstallments = 12;
        objAttwrapper.TermLength = 36;

        TW.add(objAttwrapper);
        objOppExtension.setCurrentProduct();
        // Non=Query
        objOppExtension.getStateCode('Texas');
        objOppExtension.getStateCode('TX');
        objOppExtension.deleteAttachment();
        // end Non Query
        objOppExtension.deleteproducts();
        objOppExtension.delOppProductMethod();
        objOppExtension.getVZ3_CPQ_Disabled();
        objOppExtension.deletelink();

        OpportunityTriggerHandler.TriggerDisabled = false;
        ObjOpp = new Opportunity();
        ObjOpp.Name = 'Testing Name2';
        ObjOpp.AccountId = objAcc.Id;
        ObjOpp.CloseDate = date.today();
        ObjOpp.StageName = 'Verbal Commit';
        ObjOpp.Expected_Billed_Date__c = date.today();
        //insert ObjOpp;

        OpportunityUtility.restrictOpportunityCreationByTerritory(new List<Opportunity>{ ObjOpp });

        Test.stopTest();
    }*/

    @IsTest
    private static void quickQuoteAndProposalTest() {
        Test.startTest();
        list<RecordType> recordtypeid = [
            SELECT BusinessProcessId, DeveloperName, Id, Name, SobjectType
            FROM RecordType
            WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'
        ];
        SterlingQuote__c objquote = new SterlingQuote__c();
        objquote.Name = 'Testing Name';
        objquote.ExpirationDate__c = date.today();
        objquote.OpportunityId__c = objOpp.id;
        objquote.Account_Name__c = objAcc.Id;
        objquote.RecordTypeId = recordtypeid[0].Id;
        objquote.IsSyncing__c = true;
        //objquote.MinorLine__c = 0;
        insert objquote;
        Opportunity objOppTest1 = [
            SELECT id, Name, AccountId, CloseDate, StageName, Expected_Billed_Date__c
            FROM Opportunity
            WHERE id = :objquote.OpportunityId__c
        ];

        ApexPages.currentPage().getParameters().put('Id', objOppTest1.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(objOppTest1);
        Opportunity_Controller objOppTest1Extension = new Opportunity_Controller(sc);

        //        objOppTest1Extension.selectedQQT = null;
        PageReference testPage = objOppTest1Extension.quickQuoteQQ();

        objOppTest1Extension.selectedProposalType = 'UCaaS: Cash Payment';
        ApexPages.currentPage().getParameters().put('Id', objOppTest1.Id);
        testPage = objOppTest1Extension.generateproposalattachment();
        objOppTest1Extension.getProposalTypes();
        PageReference pdfPage = Page.CreateUCaaSProposal;
        Test.setCurrentPage(pdfPage);
        ApexPages.currentPage().getParameters().put('paymentMethod', 'UCaaS_Cash_Payment');
        ApexPages.currentPage().getParameters().put('oppId', objOppTest1.Id);
        GenerateUCaaSProposalExtension proposalController1 = new GenerateUCaaSProposalExtension();

        objOppTest1Extension.selectedProposalType = 'UCaaS: Frontier Financing';
        ApexPages.currentPage().getParameters().put('Id', objOppTest1.Id);
        testPage = objOppTest1Extension.generateproposalattachment();
        objOppTest1Extension.getProposalTypes();
        pdfPage = Page.CreateUCaaSProposal;
        Test.setCurrentPage(pdfPage);
        ApexPages.currentPage().getParameters().put('paymentMethod', 'UCaaS_Cash_Payment');
        ApexPages.currentPage().getParameters().put('oppId', objOppTest1.Id);
        GenerateUCaaSProposalExtension proposalController2 = new GenerateUCaaSProposalExtension();

        objOppTest1Extension.selectedProposalType = 'Cloud Managed IT';
        ApexPages.currentPage().getParameters().put('Id', objOppTest1.Id);
        testPage = objOppTest1Extension.generateproposalattachment();
        objOppTest1Extension.getProposalTypes();
        pdfPage = Page.CreateCloudManagedITProposal;
        Test.setCurrentPage(pdfPage);
        ApexPages.currentPage().getParameters().put('oppId', objOppTest1.Id);
        GenerateCloudManagedITProposalExtension proposalController3 = new GenerateCloudManagedITProposalExtension();

        objOppTest1Extension.selectedProposalType = null;
        ApexPages.currentPage().getParameters().put('Id', objOppTest1.Id);
        testPage = objOppTest1Extension.generateproposalattachment();
        objOppTest1Extension.getProposalTypes();
        pdfPage = Page.CreateProposal;
        Test.setCurrentPage(pdfPage);
        ApexPages.currentPage().getParameters().put('oppId', objOppTest1.Id);
        GenerateProposalExtension proposalController4 = new GenerateProposalExtension();
        Test.stopTest();
    }
    
  /*  @IsTest
    static void testVlocityMethods(){
        ApexPages.currentPage().getParameters().put('Id', ObjOpp.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(ObjOpp);
        Opportunity_Controller objOppExtension = new Opportunity_Controller(sc);
        Test.startTest();
        objOppExtension.currentVlocityQuoteId = [select id from quote where opportunityId=:ObjOpp.Id limit 1].Id;
        OpportunityLineItem oppLI = new OpportunityLineItem(
            Quantity=1,
            Term_Months__c=12,
            DiscountType__c='BDT',
            Renewal_MRR__c=1,
            CPQ_NetNewMRR__c=1,
            CPE_Gross_Margin__c=1,
            UnitPrice=1,
            CPE_NRC_Price__c=1,
            Speed__c='200 Mbps',
            vlocity_cmt__OneTimeCharge__c= 1,
            Product2Id=[select id FROM product2 WHERE ProductCode ='ENT_ETH_ACCESS_0001' limit 1 ].Id,
            vlocity_cmt__RecurringCharge__c=1,
            vlocity_cmt__ServiceAccountId__c=objAcc.Id,
            OpportunityId=ObjOpp.Id,
            Opportunity_Sync__c='Vlocity'
        );
        insert oppLI;
        
            Opportunity_Controller.WrapperOpportunityProduct obj = new Opportunity_Controller.WrapperOpportunityProduct(oppLI);
            objOppExtension.syncVlocityQuote();
            objOppExtension.unSyncVlocityQuote();
            objOppExtension.launchQuoteOmniscript();
            objOppExtension.launchEasyPassQuoteOmniscript();
            objOppExtension.editVlocityQuote();
            objOppExtension.deleteVlocityQuote();
        
            objOppExtension.isVelocity = true;
            objOppExtension.openQuoteForPartnerPortal();
            objOppExtension.openVelocityProductForPartnerPortal();
            objOppExtension.isVelocity = false;
            objOppExtension.openQuoteForPartnerPortal();
            objOppExtension.openVelocityProductForPartnerPortal();
            objOppExtension.launchBundleQuoteOmniscript();
            Boolean hasNext = objOppExtension.attHasNext;
            Boolean hasPrevious = objOppExtension.attHasPrevious;
            UpdatedMRRWrapper.cls_updatedMRR wrapObj = new UpdatedMRRWrapper.cls_updatedMRR();
            wrapObj.oliId = oppLI.Id;
            wrapObj.updatedMRRValue = '12.12';
            wrapObj.recurringCharge = '12';
            wrapObj.recurringTotal = '1';
            wrapObj.quantityValue = '1';
            UpdatedMRRWrapper clsObj = new UpdatedMRRWrapper();
            clsObj.updatedMRR = new List<UpdatedMRRWrapper.cls_updatedMRR>();
            clsObj.updatedMRR.add( wrapObj );
            Opportunity_Controller.updateOLIs( JSON.serialize(clsObj) ); 
            objOppExtension.objOpp.Opportunity_Type__c = 'Renewal';
            objOppExtension.reDirectToSterling();
            objOppExtension.hidePopupQQ();
           //delOppProductMethod
        Test.stopTest();
        
    } */
    
    @IsTest
    static void testCanCloseWon(){
        
        Test.startTest();
        ObjOpp.put('StageName', 'Closed/Won');
        try {
            update ObjOpp;
        } catch (Exception e) {
            System.debug('cant close won without a synced quote!');
        }
        Test.stopTest();
        
    }
    
    @isTest static void testOliTrigger() {
        
        ftr_OLITriggerHandler oliHandler = new ftr_OLITriggerHandler();
        oliHandler.BeforeDelete(new Map<Id, SObject>  {ObjOpp.Id => ObjOpp});
        oliHandler.AfterInsert(new Map<Id, SObject> {ObjOpp.Id => ObjOpp});
        oliHandler.AfterUndelete(new Map<Id, SObject> {ObjOpp.Id => ObjOpp});
        oliHandler.AfterDelete(new Map<Id, SObject> {ObjOpp.Id => ObjOpp});
    }

     @isTest 
     	static void testIncrement() {
            Opportunity_Controller.justIncrement();
            Opportunity_Controller.justIncrement1();
     }
}