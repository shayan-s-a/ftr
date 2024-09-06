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
public with sharing class ftr_RefreshDSATBatchJobTest {

    static testMethod void testPremisesUpdate() {
        // Create Account
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
       //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
        testAccount.RecordTypeId = MasterRTId;
        testAccount.ParentId = globalAcc1.Id;
        testAccount.Name = 'Test Account';
        testAccount.BillingStreet = '123 Main Street';
        testAccount.BillingCity = 'Anywhere';
        testAccount.BillingState = 'Ohio';
        testAccount.BillingPostalCode = '44088';
        testAccount.ShippingStreet = '123 Main Street';
        testAccount.ShippingCity = 'Anywhere';
        testAccount.ShippingState = 'Ohio';
        testAccount.ShippingPostalCode = '44088';
        insert testAccount;
        
        vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
        oPremise.vlocity_cmt__Address1__c = '123 Main Street';
        oPremise.vlocity_cmt__City__c = 'Anywhere';
        oPremise.vlocity_cmt__State__c = 'California';
        oPremise.vlocity_cmt__PostalCode__c = '44076';
        oPremise.vlocity_cmt__Status__c = 'Connected';
        oPremise.DSAT_Ticket__c = '211212';
        oPremise.Copper_Tier__c = 'Tier 1';
        oPremise.Fiber_Tier__c = 'Tier 1';
        oPremise.Last_DSAT_Check__c = system.today();
        oPremise.WC_QOS__c = 'Platinum';
        oPremise.WC_Speed__c = '1000MB';
        oPremise.Market__c = 'B';
        oPremise.Level__c = 'a';
        oPremise.vlocity_cmt__Floor__c = '';
        oPremise.vlocity_cmt__PropertyOwnerAccountId__c = testAccount.Id;
        insert oPremise;
        
        Account testSAccount = new Account();
        testSAccount.Name = 'Test Service Account';
        testSAccount.BillingStreet = '123 Main Street';
        testSAccount.BillingCity = 'Anywhere';
        testSAccount.BillingState = 'Ohio';
        testSAccount.BillingPostalCode = '44088';
        testSAccount.ShippingStreet = '123 Main Street';
        testSAccount.ShippingCity = 'Anywhere';
        testSAccount.ShippingState = 'Ohio';
        testSAccount.ShippingPostalCode = '44088';
        testSAccount.vlocity_cmt__PremisesId__c = oPremise.id;
        testSAccount.MDU_WireCenter__c = 'Wire Center';
        testSAccount.ParentId = testAccount.Id;
        testSAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        insert testSAccount;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'RefreshTestOpp';
        opp.AccountId = testAccount.id;
        Date d1=Date.newInstance(2019, 05, 11);
        opp.CloseDate=d1;
        opp.StageName='Investigating';
        opp.Service_Address__c = 'Test';
        opp.Description__c = 'Test';
        opp.CPE_Product__c='No';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Lightning').getRecordTypeId();
        insert opp;

        Test.startTest();

        DataBase.executeBatch(new ftr_RefreshDSATBatchJob(), 1);
        
        Test.stopTest();
        
        vlocity_cmt__Premises__c updatedPrem = [select vlocity_cmt__Floor__c from vlocity_cmt__Premises__c where vlocity_cmt__PropertyOwnerAccountId__c = :testAccount.Id];
        system.debug('vlocity_cmt__Floor__c-->'+updatedPrem.vlocity_cmt__Floor__c);
        //system.assert(updatedPrem.vlocity_cmt__Floor__c == 'Updated');

    }
    
}