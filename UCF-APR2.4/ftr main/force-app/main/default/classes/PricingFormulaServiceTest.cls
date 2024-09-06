/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 5
**/
@isTest
public class PricingFormulaServiceTest {

    @IsTest
    static void testingPricingFormulaService1(){

        insert ftr_TestDataFactory.getQLI(1, 1);
        List<QuoteLineItem> qlis = [
            SELECT Id, vlocity_cmt__ServiceAccountId__c, Quantity, Term__c, Speed__c, vlocity_cmt__Product2Id__c, QuoteId, vlocity_cmt__BillingAccountId__c, 
            vlocity_cmt__LineNumber__c, Product2Id, vlocity_cmt__JSONAttribute__c, PricebookEntry.Product2.ProductCode
            FROM QuoteLineItem
        ];

        Quote parent = [select id, Service_Term__c from quote where id=:(Id)qlis[0].get('QuoteId')];
        
        Product2 prod = [SELECT vlocity_cmt__JSONAttribute__c FROM Product2 WHERE ProductCode = 'ENT_ETH_EIA_0002' LIMIT 1];
        prod.vlocity_cmt__JSONAttribute__c = qlis[0].vlocity_cmt__JSONAttribute__c;
        update prod;

        insert new Pricing_Formula_Var__c(
            Name = 'LitBuilding',
            Data_Type__c = 'Boolean',
            Field_API_Name__c = 'Boolean_1__c'
        );     


        insert new Pricing_Formula_Matrix__c(
            Product_Code__c = 'ENT_ETH_EIA_0002',
            Speed__c = 20,
            Term__c = 36,
            Formula_Name__c = 'Formula_0__c'
        );
        
        Test.startTest();
        
        PricingFormulaService pricingService = new PricingFormulaService();
        
        Map<String, object> priceHelperInput = new Map<String, object>{
                'productCode' => 'ENT_ETH_EIA_0002',
                'serviceAccountId' => qlis[0].vlocity_cmt__ServiceAccountId__c,
                'term' => '12 Months'
        };
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        
        priceHelperInput.put('parent', parent);
        priceHelperInput.put('itemList', qlis);
        
        pricingService.invokeMethod('getAllPricingOptionsByTerm', priceHelperInput, priceHelperOutput, priceHelperOptions);

        System.debug('priceHelperOutput: ' + JSON.serialize(priceHelperOutput));
                
        Test.stopTest();
        
    }

    @IsTest
    static void testingPricingFormulaService2(){

        insert ftr_TestDataFactory.getQLI(1, 1);
        List<QuoteLineItem> qlis = [
            SELECT Id, vlocity_cmt__ServiceAccountId__c, Quantity, Term__c, Speed__c, vlocity_cmt__Product2Id__c, QuoteId, vlocity_cmt__BillingAccountId__c, 
            vlocity_cmt__LineNumber__c, Product2Id, vlocity_cmt__JSONAttribute__c, PricebookEntry.Product2.ProductCode
            FROM QuoteLineItem
        ];

        Quote parent = [select id, Service_Term__c from quote where id=:(Id)qlis[0].get('QuoteId')];
        
        Product2 prod = [SELECT vlocity_cmt__JSONAttribute__c FROM Product2 WHERE ProductCode = 'ENT_ETH_EIA_0002' LIMIT 1];
        prod.vlocity_cmt__JSONAttribute__c = qlis[0].vlocity_cmt__JSONAttribute__c;
        update prod;

        insert new Pricing_Formula_Var__c(
            Name = 'LitBuilding',
            Data_Type__c = 'Boolean',
            Field_API_Name__c = 'Boolean_1__c'
        );     


        insert new Pricing_Formula_Matrix__c(
            Product_Code__c = 'ENT_ETH_EIA_0002',
            Speed__c = 20,
            Term__c = 36,
            Formula_Name__c = 'Formula_0__c'
        );
        
        Test.startTest();
        
        PricingFormulaService pricingService = new PricingFormulaService();
        
        Map<String, object> priceHelperInput = new Map<String, object>{
                'productCode' => 'ENT_ETH_EIA_0002',
                'serviceAccountId' => qlis[0].vlocity_cmt__ServiceAccountId__c
        };
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        
        priceHelperInput.put('parent', parent);
        priceHelperInput.put('itemList', qlis);
        
        pricingService.invokeMethod('GetAllPricingOptions', priceHelperInput, priceHelperOutput, priceHelperOptions);

        System.debug('priceHelperOutput: ' + JSON.serialize(priceHelperOutput));
                
        Test.stopTest();
        
    }

    @IsTest
    static void testingPricingFormulaService3(){

        insert ftr_TestDataFactory.getQLI(1, 1);
        List<QuoteLineItem> qlis = [
            SELECT Id, vlocity_cmt__ServiceAccountId__c, Quantity, Term__c, Speed__c, vlocity_cmt__Product2Id__c, QuoteId, vlocity_cmt__BillingAccountId__c, 
            vlocity_cmt__LineNumber__c, Product2Id, vlocity_cmt__JSONAttribute__c, PricebookEntry.Product2.ProductCode
            FROM QuoteLineItem
        ];

        Quote parent = [select id, Service_Term__c from quote where id=:(Id)qlis[0].get('QuoteId')];
        
        insert new Pricing_Formula_Var__c(
            Name = 'LitBuilding',
            Data_Type__c = 'Boolean',
            Field_API_Name__c = 'Boolean_1__c'
        );
        
        insert new Pricing_Formula_Matrix__c(
            Product_Code__c = 'ENT_ETH_EIA_0002',
            Speed__c = 20,
            Term__c = 36,
            Formula_Name__c = 'Formula_0__c'
        );
        
        Test.startTest();
        
        PricingFormulaService pricingService = new PricingFormulaService();
        
        Map<String, object> priceHelperInput = new Map<String, object>();
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        
        priceHelperInput.put('parent', parent);
        priceHelperInput.put('itemList', qlis);
        
        pricingService.invokeMethod('CalculatePrice', priceHelperInput, priceHelperOutput, priceHelperOptions);

        System.debug('priceHelperOutput: ' + JSON.serialize(priceHelperOutput));
        
        //system.assert(priceHelperOutput.get('Error') != null, JSON.serialize(priceHelperOutput.get('Error')));
        
        Test.stopTest();
        
    }
    static testmethod void testIncrement() {
        Test.startTest();
        PricingFormulaService.justIncrement();       
        Test.stopTest(); 
 }
}