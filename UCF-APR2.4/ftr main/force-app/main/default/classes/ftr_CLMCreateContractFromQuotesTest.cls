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
public class ftr_CLMCreateContractFromQuotesTest{
    
    @IsTest
    public static void testGetContractVersion(){
        User userObj = [Select Id from User where profile.Name = 'Frontier System Administrator' AND IsActive=true LIMIT 1];
        System.runAs(userObj){
            Contract_Template_List__c template = new Contract_Template_List__c();
            template.Name = 'CLM_TMPL_00010';
            template.Schedule_Type__c = 'FiberOptic & OneVoice Nationwide (copper)';
            template.Agreement_Type__c = 'Broadband FiberOptic & Voice Bundles - New Service';
            template.Template_Name__c = 'Fiber and OneVoice Schedule';
            insert template;
            
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
             testSAccount.BillingCity = 'Anywhere';
             testSAccount.BillingState = 'Ohio';
             testSAccount.BillingPostalCode = '44088';
             testSAccount.ShippingStreet = '123 Main Street';
             testSAccount.ShippingCity = 'Anywhere';
             testSAccount.ShippingState = 'Ohio';
             testSAccount.ShippingPostalCode = '44088';
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
             oQuote.Name = 'Testing Quote';
             oQuote.OpportunityId = Opp.id;
             oQuote.Pricebook2Id = pricebookId;
             oQuote.Products__c = 'EVPL';
             insert oQuote;
            Id recordTypeId = Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().get('Frontier Services Agreement').getRecordTypeId();
            Contract ctr = new Contract(Status = 'Draft', AccountId = a.id, Opportunity__c = opp.id, ICB_Flag__c = 'Y', Icb_for_email_for_test__c = true);
            ctr.BillingCity = 'Tampa';
            ctr.BillingCountry = 'United States';
            ctr.BillingState = 'Florida';
            ctr.BillingStreet = '4900 West Kennedy Boulevard';
            ctr.BillingPostalCode = '75068';
            ctr.Status = 'Draft';
            ctr.vlocity_cmt__QuoteId__c = oQuote.Id;
            ctr.ShippingCity = 'Tampa';
            ctr.ShippingCountry = 'United States';
            ctr.ShippingState = 'Florida';
            ctr.ShippingStreet = '321 East Commerce Street';
            ctr.ShippingPostalCode = '75068';
            ctr.RecordTypeId = recordTypeId;
            insert  ctr; 
            
            System.Test.startTest();
                ftr_CLMCreateContractFromQuotes.getContractVersion(oQuote.Id, null, null,null);
            System.Test.stopTest();
        }
    }
}