/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
 * 
**/
@IsTest
public class ftr_CLMCreateContractsFromAccountTest{

    @IsTest
    public static void testinvokeMethod(){
        User userObj = [Select Id from User where profile.Name = 'Frontier System Administrator' AND IsActive=true LIMIT 1];
        System.runAs(userObj){
        Contract_Template_List__c template = new Contract_Template_List__c();
        template.Name = 'CLM_TMPL_00010';
        template.Schedule_Type__c = 'FiberOptic & OneVoice Nationwide (copper)';
        template.Agreement_Type__c = 'Broadband FiberOptic & Voice Bundles - New Service';
        template.Template_Name__c = 'Fiber and OneVoice Schedule';
        insert template;
        
        Contract_Template_List__c template1 = new Contract_Template_List__c();
        template1.Name = 'CLM_TMPL_000101';
        template1.Schedule_Type__c = 'FSA_Standard';
        template1.Agreement_Type__c = 'FSA_Standard';
        template1.Template_Name__c = 'FSA_Standard';
        insert template1;
        
            Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
            
        Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Master' LIMIT 1]?.Id;
        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = masterRecId;
        a.ParentId = globalAcc.Id;
        insert a;
            Id servRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Service' LIMIT 1]?.Id;
         Account testSAccount = new Account();
         testSAccount.Name = 'Test Service Account';
            testSAccount.RecordTypeId = servRecId;
         testSAccount.BillingStreet = '123 Main Street';
         testSAccount.BillingCity = 'New Milford';
         testSAccount.BillingState = 'Connecticut';
         testSAccount.BillingPostalCode = '44088';
         testSAccount.BillingCountry = 'United States';
         testSAccount.BillingCountryCode = 'US';
         testSAccount.BillingStateCode = 'CT';
         
         testSAccount.ShippingStreet = '123 Main Street';
         testSAccount.ShippingCity = 'New Milford';
         testSAccount.ShippingState = 'Connecticut';
         testSAccount.ShippingPostalCode = '44088';
         testSAccount.ShippingCountry = 'United States';
         testSAccount.ShippingCountryCode = 'US';
         testSAccount.ShippingStateCode = 'CT';
            testSAccount.ParentId = a.Id;
         insert testSAccount;
        
         Opportunity opp = new Opportunity();
         opp.Name = 'RefreshTestOpp';
         opp.AccountId = a.id;
         Date d1=Date.newInstance(2019, 05, 11);
         opp.CloseDate=d1;
         opp.StageName='Investigating';
         opp.CPE_Product__c='No';
         insert opp;
        
         id pricebookId = Test.getStandardPricebookId();
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
        
         PricebookEntry standardPrice = new PricebookEntry(
             Pricebook2Id = pricebookId, 
             Product2Id = lstProduct2[0].Id,
             UnitPrice = 100, IsActive = true);
         insert standardPrice;
        
         Quote oQuote = new Quote();
         //oQuote.Account = testSAccount.Id;
         oQuote.Name = 'Testing Quote';
         oQuote.OpportunityId = opp.id;
         oQuote.Pricebook2Id = pricebookId;
         oQuote.Service_Term__c = '36 Months';
         insert oQuote;
        
         QuoteLineItem oQLI = new QuoteLineItem();
         oQLI.QuoteId = oQuote.id;
         oQLI.PricebookEntryId = standardPrice.id;
         oQLI.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
         oQLI.Quantity = 1;
         oQLI.UnitPrice = 34.50;
         oQLI.Term__c = '36 Months';
         oQLI.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
         oQLI.Product2Id = lstProduct2[0].Id;
         oQLI.Agreement_Type__c = 'Broadband FiberOptic & Voice Bundles - New Service';
         oQLI.Schedule_Type__c = 'FiberOptic & OneVoice Nationwide (copper)';
         insert oQLI;
        
         oQLI.vlocity_cmt__RootItemId__c = oQLI.id;
         update oQLI;
         
         QuoteLineItem oQLI1 = new QuoteLineItem();
         oQLI1.QuoteId = oQuote.id;
         oQLI1.PricebookEntryId = standardPrice.id;
         oQLI1.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
         oQLI1.Quantity = 1;
         oQLI1.UnitPrice = 34.50;
         oQLI1.Term__c = '36 Months';
         oQLI1.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
         oQLI1.Product2Id = lstProduct2[0].Id;
         oQLI1.Agreement_Type__c = 'Do Not Add';
         oQLI1.Schedule_Type__c = 'Do Not Add';
         insert oQLI1;
         
         QuoteLineItem oQLI2 = new QuoteLineItem();
         oQLI2.QuoteId = oQuote.id;
         oQLI2.PricebookEntryId = standardPrice.id;
         oQLI2.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
         oQLI2.Quantity = 1;
         oQLI2.UnitPrice = 34.50;
         oQLI2.Term__c = '36 Months';
         oQLI2.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
         oQLI2.Product2Id = lstProduct2[0].Id;
         oQLI2.Agreement_Type__c = 'Manual';
         oQLI2.Schedule_Type__c = 'Manual';
         insert oQLI2;
         
         QuoteLineItem oQLI3 = new QuoteLineItem();
         oQLI3.QuoteId = oQuote.id;
         oQLI3.PricebookEntryId = standardPrice.id;
         oQLI3.vlocity_cmt__ServiceAccountId__c = testSAccount.id;
         oQLI3.Quantity = 1;
         oQLI3.UnitPrice = 34.50;
         oQLI3.Term__c = '36 Months';
         oQLI3.vlocity_cmt__Product2Id__c = lstProduct2[0].Id;
         oQLI3.Product2Id = lstProduct2[0].Id;
         oQLI3.Agreement_Type__c = null;
         oQLI3.Schedule_Type__c = null;
         insert oQLI3;
         
         String templateName = ftr_CLMContractCreation.getTemplateName('Broadband FiberOptic & Voice Bundles - New Service', 'FiberOptic & OneVoice Nationwide (copper)');
         
         vlocity_cmt__DocumentTemplate__c templateObj = new vlocity_cmt__DocumentTemplate__c();
         templateObj.vlocity_cmt__IsActive__c = true;
         templateObj.Name = 'Fiber and OneVoice Schedule';
         insert templateObj;
         
         vlocity_cmt__DocumentTemplate__c templateObj1 = new vlocity_cmt__DocumentTemplate__c();
         templateObj1.vlocity_cmt__IsActive__c = true;
         templateObj1.Name = 'FSA_Extended';
         insert templateObj1;
         vlocity_cmt__DocumentTemplate__c templateObj2 = new vlocity_cmt__DocumentTemplate__c();
         templateObj2.vlocity_cmt__IsActive__c = true;
         templateObj2.Name = 'Frontier FSA';
         insert templateObj2;
         
         ftr_CLMContractCreation.getContractTemplateId(templateName);
         oQuote.OpportunityId = opp.id;
         update oQuote;
         
         SterlingQuote__c objSQ = new SterlingQuote__c();
         objSQ.Name='Testing Name';
         objSQ.ExpirationDate__c = date.today();
         objSQ.OpportunityId__c = opp.Id;
         objSQ.Account_Name__c = testSAccount.id;
         objSQ.IsSyncing__c = true;
         insert objSQ;
        
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
         objLineItem.Agreement_Type__c = 'Broadband FiberOptic & Voice Bundles - New Service';
         objLineItem.Schedule_Type__c = 'FiberOptic & OneVoice Nationwide (copper)';
         insert objLineItem;
         
         SterlingQuoteItem__c objLineItem1 = new SterlingQuoteItem__c();
         objLineItem1.Quantity__c=10;
         objLineItem1.TermLength__c=24;
         objLineItem1.StandardMRC__c = 10;
         objLineItem1.StandardNRC__c = 10;
         objLineItem1.AdjustedMRC__c = 10;
         objLineItem1.AdjustedNRC__c = 10;
         objLineItem1.Locality__c = 'Indiana';
         objLineItem1.StateProvince__c ='IN';
         objLineItem1.ItemCode__c ='123'; 
         objLineItem1.ApprovalTerritory__c ='Indiana';
         objLineItem1.ApprovalRegion__c='central';
         objLineItem1.NPA__c ='10';
         objLineItem1.NXX__c = '10';
         objLineItem1.IsInFrontierFootprint__c = false;
         objLineItem1.SterlingQuote__c = objSQ.id;
         objLineItem1.Agreement_Type__c = 'Do Not Add';
         objLineItem1.Schedule_Type__c = 'Do Not Add';
         insert objLineItem1;
         
         SterlingQuoteItem__c objLineItem2 = new SterlingQuoteItem__c();
         objLineItem2.Quantity__c=10;
         objLineItem2.TermLength__c=24;
         objLineItem2.StandardMRC__c = 10;
         objLineItem2.StandardNRC__c = 10;
         objLineItem2.AdjustedMRC__c = 10;
         objLineItem2.AdjustedNRC__c = 10;
         objLineItem2.Locality__c = 'Indiana';
         objLineItem2.StateProvince__c ='IN';
         objLineItem2.ItemCode__c ='123'; 
         objLineItem2.ApprovalTerritory__c ='Indiana';
         objLineItem2.ApprovalRegion__c='central';
         objLineItem2.NPA__c ='10';
         objLineItem2.NXX__c = '10';
         objLineItem2.IsInFrontierFootprint__c = false;
         objLineItem2.SterlingQuote__c = objSQ.id;
         objLineItem2.Agreement_Type__c = 'Manual';
         objLineItem2.Schedule_Type__c = 'Manual';
         insert objLineItem2;
         
         SterlingQuoteItem__c objLineItem3 = new SterlingQuoteItem__c();
         objLineItem3.Quantity__c=10;
         objLineItem3.TermLength__c=24;
         objLineItem3.StandardMRC__c = 10;
         objLineItem3.StandardNRC__c = 10;
         objLineItem3.AdjustedMRC__c = 10;
         objLineItem3.AdjustedNRC__c = 10;
         objLineItem3.Locality__c = 'Indiana';
         objLineItem3.StateProvince__c ='IN';
         objLineItem3.ItemCode__c ='123'; 
         objLineItem3.ApprovalTerritory__c ='Indiana';
         objLineItem3.ApprovalRegion__c='central';
         objLineItem3.NPA__c ='10';
         objLineItem3.NXX__c = '10';
         objLineItem3.IsInFrontierFootprint__c = false;
         objLineItem3.SterlingQuote__c = objSQ.id;
         objLineItem3.Agreement_Type__c = null;
         objLineItem3.Schedule_Type__c = null;
         insert objLineItem3;
         
         
         System.Test.startTest();
             Map<String, Object> input = new Map<String, Object>();
             input.put('quoteId',oQuote.Id);
             Map<String, Object> output = new Map<String, Object>();
             Map<String, Object> options = new Map<String, Object>(); 
             System.debug('Opportunity Id: ' + opp.Id);
             System.debug('Quote Opportunity Id: ' + oQuote.Opportunity.Id);
             System.debug('AccountId: ' + oQuote.Account.Id);
             System.debug('Account Shipping Address: ' + oQuote.Account.ShippingAddress);
             ftr_CLMContractCreation.createContracts(input, output, options);
             
             input.clear();
             input.put('quoteId',objSQ.Id);
             ftr_CLMContractCreation.createContracts(input, output, options);
             
                input.clear();
                List<Object> QuoteList = new List<Object>();
                Map<String, Object> quoteMap1 = new Map<String, Object>();
                quoteMap1.put('Id', objSQ.Id);
                
                Map<String, Object> quoteMap2 = new Map<String, Object>();
                quoteMap2.put('Id', oQuote.Id);
                
                QuoteList.add(quoteMap1);
                QuoteList.add(quoteMap2);
                input.put('Quotes', QuoteList);
                input.put('ContractTerm',60);
                input.put('ContractStartDate', '2021-07-15');
                input.put('AccountId',testSAccount.Id);
                input.put('FSATemplateType', '5 Page');
                input.put('WholeSaleTeamFlag',true);
                input.put('PNUMText','Test123');
                input.put('opportunityId',opp.Id);
                input.put('MDUTemplatesflag', true);
                input.put('FSAExistsFlag', false);
                input.put('MDUTemplates','FSA_Standard');
                input.put('ChildContractTemplate','FSA_Standard');
                input.put('CallCenterProfileFlag',true);
                
                ftr_CLMCreateContractsFromAccount obj = new ftr_CLMCreateContractsFromAccount();
                obj.invokeMethod('checkFSAContracts', input, output, options);
                obj.invokeMethod('createContracts', input, output, options);
                
         System.Test.stopTest(); 
        }
    }
}