/**
* @description       : This test class covers the following Apex classes:
*      TBD_CLASS1
*      TBD_CLASS2
*      TBD_CLASS3
* @author            : TBD
* @version           : 1 
**/
@isTest
public class SterlingQuoteItemTriggerHandler_Test {
    @TestSetup
    static void makeData(){
        aps_VlocityQuoteHandler.stopTrigger = true;
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
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
        objAcc.ParentId = globalAcc.Id;
        insert objAcc; 
        Opportunity testOpp = new Opportunity();
        testOpp.Name ='Test 1';
        testOpp.AccountId= objAcc.Id;
        testOpp.CloseDate = date.today();
        testOpp.StageName ='Investigating';
        testOpp.Expected_Billed_Date__c = date.today();
        testOpp.Bypass_Validation__c = true;
        testOpp.Pricebook2Id = Test.getStandardPricebookId();
        insert testOpp;
    }
   /* @isTest
    private static void sqiTriggerHandlerTest() {
        aps_VlocityQuoteHandler.stopTrigger = true;
        Opportunity testOpp = [SELECT Id,Name,StageName,CloseDate,Pricebook2Id FROM Opportunity LIMIT 1];
        Test.startTest();
        SterlingQuote__c testQuote = Test_Fixture_Factory.createTestQuote(testOpp.Id, '', '');
        List<SterlingQuoteItem__c> items = [SELECT Id, Quantity__c FROM SterlingQuoteItem__c WHERE SterlingQuote__c = :testQuote.Id];
        for (SterlingQuoteItem__c item : items) {
            item.Quantity__c = 2;
        }
        update items;
        Test.stopTest();
    }*/
    
    @isTest
    private static void sqiTriggerHandlerTest2() {
        aps_VlocityQuoteHandler.stopTrigger = true;
        Opportunity testOpp = [SELECT Id,Name,StageName,CloseDate,Pricebook2Id FROM Opportunity LIMIT 1];
        
        SterlingQuote__c testQuote = Test_Fixture_Factory.createTestQuote(testOpp.Id, '', '', false);
        List<SterlingQuoteItem__c> items = [SELECT Id, Quantity__c FROM SterlingQuoteItem__c WHERE SterlingQuote__c = :testQuote.Id LIMIT 1];
        for (SterlingQuoteItem__c item : items) {
            item.Quantity__c = 2;
        }
        Test.startTest();
        update items;
        delete items;
        Test.stopTest();
    }
}