/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
 * 
**/
@isTest
public class ftr_ContractServiceTest {
    
    @isTest
    public static void checkIfFSAExistingTest(){
         Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
       //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testSAccount = new Account();
        testSAccount.RecordTypeId = MasterRTId;
        testSAccount.ParentId = globalAcc1.Id;
        testSAccount.Name = 'Test Service Account';
        testSAccount.BillingStreet = '123 Main Street';
        testSAccount.BillingCity = 'Anywhere';
        testSAccount.BillingState = 'Ohio';
        testSAccount.BillingPostalCode = '44088';
        testSAccount.ShippingStreet = '123 Main Street';
        testSAccount.ShippingCity = 'Anywhere';
        testSAccount.ShippingState = 'Ohio';
        testSAccount.ShippingPostalCode = '44088';
        testSAccount.Phone = '9023214560';
        //testSAccount.RecordTypeId = getRecordType('Service');
        //testSAccount.Parent_Account__c = testAccount.id;
        insert testSAccount;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'RefreshTestOpp';
        opp.AccountId = testSAccount.id;
        Date d1=Date.newInstance(2019, 05, 11);
        opp.CloseDate=d1;
        opp.StageName='Investigating';
        opp.CPE_Product__c='No';
        insert opp;
        
        id pricebookId = Test.getStandardPricebookId();
         
        
        
        Quote oQuote = new Quote();
        oQuote.Name = 'Testing Quote';
        oQuote.OpportunityId = Opp.id;
        oQuote.Pricebook2Id = pricebookId;
        oQuote.Status = 'Draft';
        oQuote.Approval_Status__c = 'N/A';
        
        insert oQuote;
        
        ftr_ContractService.checkIfFSAExisting(new List<Id>{oQuote.Id});
    }
}