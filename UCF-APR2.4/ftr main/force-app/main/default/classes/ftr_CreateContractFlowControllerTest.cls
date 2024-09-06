/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
**/
@isTest
public class ftr_CreateContractFlowControllerTest {
    
    
    @testSetup
    public static void setup(){
        Id globalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        //Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master').getRecordTypeId();
        
        Account testGAccount = new Account(
            Name = 'Test Global Account',
            BillingStreet = '123 Main Street',
            BillingCity = 'Anywhere',
            BillingState = 'Ohio',
            BillingPostalCode = '44088',
            ShippingStreet = '123 Main Street',
            ShippingCity = 'Anywhere',
            ShippingState = 'Ohio',
            ShippingPostalCode = '44088',
            Phone = '9023214560',
            type = 'Prospect',
            Customer_Status__c = 'Active',
            RecordTypeId = globalRecordTypeId
        );
        insert testGAccount;
        
        Account testSAccount = new Account(
            Name = 'Test Service Account',
            BillingStreet = '123 Main Street',
            BillingCity = 'Anywhere',
            BillingState = 'Ohio',
            BillingPostalCode = '44088',
            ShippingStreet = '123 Main Street',
            ShippingCity = 'Anywhere',
            ShippingState = 'Ohio',
            ShippingPostalCode = '44088',
            Phone = '9023214560',
            type = 'Prospect',
            Customer_Status__c = 'Active',
            ParentId = testGAccount.Id
        );
        // System.runAs(u){
               
        //Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master').getRecordTypeId();
        insert testSAccount;
        // }
        Opportunity opp = new Opportunity();
        opp.Name = 'RefreshTestOpp';
        opp.AccountId = testSAccount.id;
        opp.CloseDate=System.today();
        opp.StageName='Investigating';
        insert opp;
        
        Id pricebookId = Test.getStandardPricebookId();     
        
        
        Quote oQuote = new Quote();
        oQuote.Name = 'Testing Quote';
        oQuote.OpportunityId = Opp.id;
        oQuote.Pricebook2Id = pricebookId;
        oQuote.Status = 'Approved';
        oQuote.Approval_Status__c = 'Approved';
        oQuote.Service_Term__c = '12 Months';
        oQuote.Products__c = 'UCF;EIA';
        oQuote.BillingCity  = 'New York';
        oQuote.BillingCountry  = 'United States';
        oQuote.BillingState  = 'New York';
        oQuote.BillingStreet  = 'Test';
        oQuote.BillingPostalCode  = '12345';
        oQuote.ShippingCity  = 'New York';
        oQuote.ShippingCountry  = 'United States';
        oQuote.ShippingState  = 'New York';
        oQuote.ShippingStreet  = 'Test';
        oQuote.ShippingPostalCode  = '12345';
        insert oQuote;


        QuoteLineItem[] qlis = ftr_TestDataFactory.getQLI(2, 1);
        qlis[0].QuoteId = oQuote.Id;
        update new Product2(Id=qlis[0].Product2Id, Family ='Ethernet');
        insert qlis;
        // qlis = ftr_TestDataFactory.getQLI(1, 1);
        // qlis[0].QuoteId = oQuote.Id;
        // insert qlis;
        
        String contractToquoteRecords = '[{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef1"},"Name":"a8T3D0000008syZUAQ","vlocity_cmt__DestinationFieldName__c":"AccountId","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"AccountId","vlocity_cmt__SourceFieldSObjectType__c":"Account","vlocity_cmt__SourceFieldType__c":"reference","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef2"},"Name":"a8T3D0000008syaUAA","vlocity_cmt__DestinationFieldName__c":"BillingCity","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"BillingCity","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef3"},"Name":"a8T3D0000008sybUAA","vlocity_cmt__DestinationFieldName__c":"BillingCountry","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"BillingCountry","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef4"},"Name":"a8T3D0000008syeUAA","vlocity_cmt__DestinationFieldName__c":"BillingPostalCode","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"BillingPostalCode","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef5"},"Name":"a8T3D0000008sycUAA","vlocity_cmt__DestinationFieldName__c":"BillingState","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"BillingState","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef6"},"Name":"a8T3D0000008sydUAA","vlocity_cmt__DestinationFieldName__c":"BillingStreet","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"BillingStreet","vlocity_cmt__SourceFieldType__c":"textarea","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef7"},"Name":"a8T3D0000008synUAA","vlocity_cmt__DestinationFieldName__c":"Bulk_Total_Current_MRC__c","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"Opportunity.Net_New_MRR__c","vlocity_cmt__SourceFieldSObjectType__c":"Opportunity","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef8"},"Name":"a8T3D0000008syqUAA","vlocity_cmt__DestinationFieldName__c":"EffectiveOneTimeTotal__c","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__EffectiveOneTimeTotal__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef9"},"Name":"a8T3D0000008syrUAA","vlocity_cmt__DestinationFieldName__c":"EffectiveRecurringTotal__c","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__EffectiveRecurringTotal__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef10"},"Name":"a8T3D0000008sypUAA","vlocity_cmt__DestinationFieldName__c":"Opportunity__c","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"OpportunityId","vlocity_cmt__SourceFieldSObjectType__c":"Opportunity","vlocity_cmt__SourceFieldType__c":"reference","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef11"},"Name":"a8T3D0000008syoUAA","vlocity_cmt__DestinationFieldName__c":"Previous_Total_MRC__c","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"Opportunity.Renewal_MRR__c","vlocity_cmt__SourceFieldSObjectType__c":"Opportunity","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef12"},"Name":"a8T110000000CaGEAU","vlocity_cmt__DestinationFieldName__c":"Products__c","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"Products__c","vlocity_cmt__SourceFieldType__c":"multipicklist","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef13"},"Name":"a8T3D0000008syiUAA","vlocity_cmt__DestinationFieldName__c":"ShippingCity","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"ShippingCity","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef14"},"Name":"a8T3D0000008syjUAA","vlocity_cmt__DestinationFieldName__c":"ShippingCountry","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"ShippingCountry","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef15"},"Name":"a8T3D0000008symUAA","vlocity_cmt__DestinationFieldName__c":"ShippingPostalCode","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"ShippingPostalCode","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef16"},"Name":"a8T3D0000008sykUAA","vlocity_cmt__DestinationFieldName__c":"ShippingState","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"ShippingState","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef17"},"Name":"a8T3D0000008sylUAA","vlocity_cmt__DestinationFieldName__c":"ShippingStreet","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"ShippingStreet","vlocity_cmt__SourceFieldType__c":"textarea","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef18"},"Name":"a8T3D0000008sygUAA","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__PriceListId__c","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__PriceListId__c","vlocity_cmt__SourceFieldSObjectType__c":"vlocity_cmt__PriceList__c","vlocity_cmt__SourceFieldType__c":"reference","vlocity_cmt__SourceSObjectType__c":"Quote"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef19"},"Name":"a8T3D0000008syfUAA","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__QuoteId__c","vlocity_cmt__DestinationSObjectType__c":"Contract","vlocity_cmt__SourceFieldName__c":"Id","vlocity_cmt__SourceFieldType__c":"id","vlocity_cmt__SourceSObjectType__c":"Quote"}]';
        insert (List<vlocity_cmt__CustomFieldMap__c>) JSON.deserializeStrict(contractToquoteRecords, List<vlocity_cmt__CustomFieldMap__c>.class);
        String qliTOcliRecords = '[{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef1"},"Name":"a8T1h0000004Gf5EAE","vlocity_cmt__DestinationFieldName__c":"Premise_Detail__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"Premise_Detail__c","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef2"},"Name":"QuoteLineItem>ContractLineItem1","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__Quantity__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"Quantity","vlocity_cmt__SourceFieldType__c":"double","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef3"},"Name":"QuoteLineItem>ContractLineItem3","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__Product2Id__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"Product2Id","vlocity_cmt__SourceFieldSObjectType__c":"Product2","vlocity_cmt__SourceFieldType__c":"reference","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef4"},"Name":"QuoteLineItem>ContractLineItem4","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__PricebookEntryId__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"PricebookEntryId","vlocity_cmt__SourceFieldSObjectType__c":"PricebookEntry","vlocity_cmt__SourceFieldType__c":"reference","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef5"},"Name":"QuoteLineItem>ContractLineItem5","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__AttributesData__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__JSONAttribute__c","vlocity_cmt__SourceFieldType__c":"textarea","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef6"},"Name":"QuoteLineItem>ContractLineItem6","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OverageDiscountPrice__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OverageDiscountPrice__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef7"},"Name":"QuoteLineItem>ContractLineItem7","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OverageUOM__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OverageUOM__c","vlocity_cmt__SourceFieldType__c":"picklist","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef8"},"Name":"QuoteLineItem>ContractLineItem8","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OverageTotal__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OverageTotal__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef9"},"Name":"QuoteLineItem>ContractLineItem9","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OverageManualDiscount__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OverageManualDiscount__c","vlocity_cmt__SourceFieldType__c":"percent","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef10"},"Name":"QuoteLineItem>ContractLineItem10","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OverageCharge__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OverageCharge__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef11"},"Name":"QuoteLineItem>ContractLineItem11","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__RecurringDiscountPrice__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__RecurringDiscountPrice__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef12"},"Name":"QuoteLineItem>ContractLineItem12","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OneTimeDiscountPrice__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OneTimeDiscountPrice__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef13"},"Name":"QuoteLineItem>ContractLineItem14","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OneTimeCharge__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OneTimeCharge__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef14"},"Name":"QuoteLineItem>ContractLineItem15","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__ServiceAccountId__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__ServiceAccountId__c","vlocity_cmt__SourceFieldSObjectType__c":"Account","vlocity_cmt__SourceFieldType__c":"reference","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef15"},"Name":"QuoteLineItem>ContractLineItem16","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__SerialNumber__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__SerialNumber__c","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef16"},"Name":"QuoteLineItem>ContractLineItem17","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__BillingAccountId__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__BillingAccountId__c","vlocity_cmt__SourceFieldSObjectType__c":"Account","vlocity_cmt__SourceFieldType__c":"reference","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef17"},"Name":"QuoteLineItem>ContractLineItem18","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__EffectiveStartDate__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__ConnectDate__c","vlocity_cmt__SourceFieldType__c":"datetime","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef18"},"Name":"QuoteLineItem>ContractLineItem20","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__EffectiveEndDate__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__DisconnectDate__c","vlocity_cmt__SourceFieldType__c":"datetime","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef19"},"Name":"QuoteLineItem>ContractLineItem21","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OneTimeManualDiscount__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OneTimeManualDiscount__c","vlocity_cmt__SourceFieldType__c":"percent","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef20"},"Name":"QuoteLineItem>ContractLineItem22","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__UnitPrice__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"UnitPrice","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef21"},"Name":"QuoteLineItem>ContractLineItem23","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OneTimeTotal__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OneTimeTotal__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef22"},"Name":"QuoteLineItem>ContractLineItem25","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OverageCalculatedPrice__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OverageCalculatedPrice__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef23"},"Name":"QuoteLineItem>ContractLineItem26","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__RecurringUOM__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__RecurringUOM__c","vlocity_cmt__SourceFieldType__c":"picklist","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef24"},"Name":"QuoteLineItem>ContractLineItem27","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__RecurringTotal__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__RecurringTotal__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef25"},"Name":"QuoteLineItem>ContractLineItem28","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__RecurringManualDiscount__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__RecurringManualDiscount__c","vlocity_cmt__SourceFieldType__c":"percent","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef26"},"Name":"QuoteLineItem>ContractLineItem29","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__RecurringCharge__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__RecurringCharge__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef27"},"Name":"QuoteLineItem>ContractLineItem30","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__RecurringCalculatedPrice__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__RecurringCalculatedPrice__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef28"},"Name":"QuoteLineItem>ContractLineItem31","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__LineNumber__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__LineNumber__c","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef29"},"Name":"QuoteLineItem>ContractLineItem32","vlocity_cmt__DestinationFieldName__c":"vlocity_cmt__OneTimeCalculatedPrice__c","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"vlocity_cmt__OneTimeCalculatedPrice__c","vlocity_cmt__SourceFieldType__c":"currency","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"},{"attributes":{"type":"vlocity_cmt__CustomFieldMap__c","referenceId":"vlocity_cmt__CustomFieldMap__cRef30"},"Name":"QuoteLineItem>ContractLineItem33","vlocity_cmt__DestinationFieldName__c":"Name","vlocity_cmt__DestinationSObjectType__c":"vlocity_cmt__ContractLineItem__c","vlocity_cmt__SourceFieldName__c":"PricebookEntry.Name","vlocity_cmt__SourceFieldSObjectType__c":"PricebookEntry","vlocity_cmt__SourceFieldType__c":"string","vlocity_cmt__SourceSObjectType__c":"QuoteLineItem"}]';
        insert (List<vlocity_cmt__CustomFieldMap__c>) JSON.deserializeStrict(qliTOcliRecords, List<vlocity_cmt__CustomFieldMap__c>.class);

    }
    
    @isTest
    public static void createContractTest(){
        Quote oQuote = [SELECT Id, AccountId FROM Quote LIMIT 1];
        
        System.debug(oQuote);
        
        Contract fsContract = new Contract();
        fsContract.AccountId = oQuote.AccountId;
        fsContract.BillingCity  = 'New York';
        fsContract.BillingCountry  = 'United States';
        fsContract.BillingState  = 'New York';
        fsContract.BillingStreet  = 'Test';
        fsContract.BillingPostalCode  = '12345';
        fsContract.ShippingCity  = 'New York';
        fsContract.ShippingCountry  = 'United States';
        fsContract.ShippingState  = 'New York';
        fsContract.ShippingStreet  = 'Test';
        fsContract.ShippingPostalCode  = '12345';
        fsContract.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Frontier Services Agreement').getRecordTypeId();
        
        insert fsContract;
        
        Contract psContract = new Contract();
        psContract.AccountId = oQuote.AccountId;
        psContract.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Product Schedule').getRecordTypeId();
        psContract.BillingCity  = 'New York';
        psContract.BillingCountry  = 'United States';
        psContract.BillingState  = 'New York';
        psContract.BillingStreet  = 'Test';
        psContract.BillingPostalCode  = '12345';
        psContract.ShippingCity  = 'New York';
        psContract.ShippingCountry  = 'United States';
        psContract.ShippingState  = 'New York';
        psContract.ShippingStreet  = 'Test';
        psContract.ShippingPostalCode  = '12345';
        insert psContract;
        
        ftr_CreateContractFlowController.ContractData contractData = new ftr_CreateContractFlowController.ContractData();
        
        Test.startTest();
        contractData.quoteId = oQuote.Id;
        contractData.contractType = 'PS';
        ftr_CreateContractFlowController.createContract(new List< ftr_CreateContractFlowController.ContractData> {contractData});
        Test.stopTest();
    }
    
    @isTest
    public static void createContractTest2(){
        Quote oQuote = [SELECT Id, AccountId FROM Quote LIMIT 1];
        
        System.debug(oQuote);
        
        oQuote.ftr_IsBundle__c = true;
        
        update oQuote;
        
        Contract fsContract = new Contract();
        fsContract.AccountId = oQuote.AccountId;
        fsContract.BillingCity  = 'New York';
        fsContract.BillingCountry  = 'United States';
        fsContract.BillingState  = 'New York';
        fsContract.BillingStreet  = 'Test';
        fsContract.BillingPostalCode  = '12345';
        fsContract.ShippingCity  = 'New York';
        fsContract.ShippingCountry  = 'United States';
        fsContract.ShippingState  = 'New York';
        fsContract.ShippingStreet  = 'Test';
        fsContract.ShippingPostalCode  = '12345';
        fsContract.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Frontier Services Agreement').getRecordTypeId();
        
        insert fsContract;
        
        Contract psContract = new Contract();
        psContract.AccountId = oQuote.AccountId;
        psContract.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Product Schedule').getRecordTypeId();
        psContract.BillingCity  = 'New York';
        psContract.BillingCountry  = 'United States';
        psContract.BillingState  = 'New York';
        psContract.BillingStreet  = 'Test';
        psContract.BillingPostalCode  = '12345';
        psContract.ShippingCity  = 'New York';
        psContract.ShippingCountry  = 'United States';
        psContract.ShippingState  = 'New York';
        psContract.ShippingStreet  = 'Test';
        psContract.ShippingPostalCode  = '12345';
        insert psContract;
        
        ftr_CreateContractFlowController.ContractData contractData = new ftr_CreateContractFlowController.ContractData();
        
        Test.startTest();
        contractData.quoteId = oQuote.Id;
        contractData.contractType = 'PS';
        ftr_CreateContractFlowController.createContract(new List< ftr_CreateContractFlowController.ContractData> {contractData});
        Test.stopTest();
    }
}