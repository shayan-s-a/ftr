/**
* @author Rishu Singla
* @date 04 Mar 2020
* @group Vlocity Quote Trigger Handler Test Class
* @description Test class for Quote Trigger Handler
*/ 

@isTest
private class ftr_QuoteTriggerHandlerTest {
    
    @isTest
    static void TestQuoteTermUpdationWithOneQuote(){
        
        List<Quote> quoteList = ftr_TestDataFactory.getQuotes(1);
        insert quoteList;
        List<Quote> newQuoteList = new List<Quote>();
        
        for(Quote q:[SELECT Id,Service_Term__c from Quote]){
            
            q.Service_Term__c='24 Months';
            newQuoteList.add(q);
            
        }
        
        update newQuoteList;
        
        
        List<Quote> chkQuote = [SELECT Id,Service_Term__c from Quote where Service_Term__c='24 Months'];
        Integer sizechkQuote=chkQuote.size();
        
        System.assertEquals(1, sizechkQuote);
        System.assertNotEquals(0, sizechkQuote);
        
        delete newQuoteList;
         ftr_TriggerHandler TrigrObj = new  ftr_TriggerHandler();
        TrigrObj.clearMaxLoopCount();
    }
    
    @isTest
    static void testApprovalPortion(){
        Integer numOfQLIforEachQuote = 2;
        Integer numOfQuote = 1;
        List<QuoteLineItem> qliToUpdate = new List<QuoteLineItem>();
        List<QuoteLineItem> qlis = ftr_TestDataFactory.getQLI(numOfQLIforEachQuote, numOfQuote);
        insert qlis;

        // List<ProcessInstanceWorkItem> piWi = ftr_TestDataFactory.getProcessInstanceWorkItem();
        // insert piWi;

        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'Network Access' => 'ENT_ETH_ACCESS_0001'
        };
        Integer numOfProdForEachProdCode = 1;
        List<PricebookEntry> pbeList = ftr_TestDataFactory.getProductswithPbe(prodNameCodeMap, numOfProdForEachProdCode);
        insert pbeList;
        
        for(QuoteLineItem q:[SELECT Id,vlocity_cmt__RecurringCharge__c,vlocity_cmt__BaseRecurringCharge__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__BaseOneTimeCharge__c from QuoteLineItem]){
            
            q.vlocity_cmt__RecurringCharge__c=1;
            q.vlocity_cmt__BaseRecurringCharge__c = 10;
            q.vlocity_cmt__OneTimeCharge__c = 1;
            q.vlocity_cmt__BaseOneTimeCharge__c = 10;
            qliToUpdate.add(q);
            
        }
        
        update qliToUpdate;
       
    }
    
    @isTest
    static void testApprovalPortion2(){
        Integer numOfQLIforEachQuote = 2;
        Integer numOfQuote = 1;
        List<QuoteLineItem> qliToUpdate = new List<QuoteLineItem>();
        List<QuoteLineItem> qlis = ftr_TestDataFactory.getQLI(numOfQLIforEachQuote, numOfQuote);
        insert qlis;

        // List<ProcessInstanceWorkItem> piWi = ftr_TestDataFactory.getProcessInstanceWorkItem();
        // insert piWi;

        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'Network Access' => 'ENT_ETH_ACCESS_0001'
        };
        Integer numOfProdForEachProdCode = 1;
        List<PricebookEntry> pbeList = ftr_TestDataFactory.getProductswithPbe(prodNameCodeMap, numOfProdForEachProdCode);
        insert pbeList;
        
        for(QuoteLineItem q: qlis){
            
            q.UnitPrice = 1;
            qliToUpdate.add(q);
            
        }
        
        update qliToUpdate;
       
    }
        
    @isTest
    
    static void TestTriggerHandlerLoop(){
        
        ftr_TriggerHandler.LoopCount testLoop = new ftr_TriggerHandler.LoopCount();
        ftr_TriggerHandler.LoopCount testLoop2 = new ftr_TriggerHandler.LoopCount(2);
        Boolean testInc = testLoop.increment();
        testLoop.setMax(2);
        testLoop.getMax();
        testLoop.getCount();
        ftr_TriggerHandler.bypass('ftr_TriggerHandler');
        ftr_TriggerHandler.clearBypass('ftr_TriggerHandler');
        Boolean isBypass=ftr_TriggerHandler.isBypassed('ftr_TriggerHandler');
        ftr_TriggerHandler.clearAllBypasses();
        
        
    }
    
    static testmethod void testIncrement() {
        Test.startTest();
        ftr_QuoteTriggerHandler.justIncrement();
        Test.stopTest(); 
 }
    

}