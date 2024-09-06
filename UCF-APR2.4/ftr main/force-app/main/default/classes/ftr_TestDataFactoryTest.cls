/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 5 
**/
@isTest
private class ftr_TestDataFactoryTest {
    @isTest static void myAccount() {
        Test.startTest();
        //creating accounts
        // List<Account> accts = ftr_TestDataFactory.getAccounts(5);
        // List<vlocity_cmt__Premises__c> Premises = ftr_TestDataFactory.getPremises(1);
        // List<Account> serviceaccts = ftr_TestDataFactory.getServAccountsWithPremise(1); 
        List<Opportunity> opptys = ftr_TestDataFactory.getOpportunities(5);
        List<Quote> quotes = ftr_TestDataFactory.getQuotes(5);
        List<QuoteLineItem> quotelineitems = ftr_TestDataFactory.getQLI(5,5);
        List<Order> orders = ftr_TestDataFactory.getOrders(5);
        string jsonattribute1 = ftr_TestDataFactory.getJSONAttribute('ENT_ETH_UNI_PSR_001');
        string jsonattribute2 = ftr_TestDataFactory.getJSONAttribute('ENT_ETH_EIA_EVC_PSR_001');
        string jsonattribute3 = ftr_TestDataFactory.getJSONAttribute('ENT_ETH_EVPL_EVC_PSR_001');
        Test.stopTest();
    }
    
    @isTest static void myAccount1() {
    	map <String, string > prodNamemap = new map <String, string >();
        prodNamemap.put('prod1', 'prod1');
        prodNamemap.put('prod2', 'prod2');
        Test.startTest();
        List<Product2>  comProducts = ftr_TestDataFactory.getProducts(prodNamemap, 2);
        List<PricebookEntry>  pbeList = ftr_TestDataFactory.getProductswithPbe(prodNamemap, 2);
        List<Product2>  products = ftr_TestDataFactory.getTechnicalProducts(prodNamemap, 2);
        List<OrderItem> ordItem = ftr_TestDataFactory.getOrderItems(2,prodNamemap);
        List<vlocity_cmt__FulfilmentRequestLine__c> FulfilmentRequestLines = ftr_TestDataFactory.getFulfilmentRequestLines(2,prodNamemap);
        List<vlocity_cmt__OrchestrationItem__c> OrchestrationItem = ftr_TestDataFactory.getOrchestrationItems(2,prodNamemap);
        Test.stopTest();
    }

    @isTest static void myAccount2() {
        Test.startTest();
        //creating accounts
        List<vlocity_cmt__OrchestrationPlan__c> OrchestrationPlan = ftr_TestDataFactory.getOrchestrationPlans(5);
        List<vlocity_cmt__FulfilmentRequest__c> FulfilmentRequest = ftr_TestDataFactory.getFulfilmentRequests(5);
        Map<String,vlocity_cmt__OrchestrationPlanDefinition__c> mapOrchestrationPlanDefinition = ftr_TestDataFactory.getOrchestrationPlanDefinitions();
        Map<String,vlocity_cmt__ItemImplementation__c> mapItemImplementation = ftr_TestDataFactory.getItemImplementations();
        Map<String,vlocity_cmt__SystemInterface__c> mapSystemInterface = ftr_TestDataFactory.getSystemInterfaces();
        Map<String,vlocity_cmt__OrchestrationItemDefinition__c> mapOrchestrationItemDefinition = ftr_TestDataFactory.getOrchestrationItemDefinitions();
        string jsonattribute4 = ftr_TestDataFactory.getOrderItemJSONAttribute('ENT_ETH_UNI_0001');
        string jsonattribute5 = ftr_TestDataFactory.getOrderItemJSONAttribute('ENT_ETH_EIA_0002');
        string jsonattribute6 = ftr_TestDataFactory.getOrderItemJSONAttribute('ENT_ETH_EVPL_0010');
        Test.stopTest();
    }

}