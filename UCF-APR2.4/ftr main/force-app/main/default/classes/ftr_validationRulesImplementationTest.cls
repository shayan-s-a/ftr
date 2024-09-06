@isTest
private class ftr_validationRulesImplementationTest {
    
       @isTest
    static void ftr_ValidateQuickQuoteProcessTest1() { 
        
        Map<String,String> prodNameCodeMap = new Map<String,String>();
        List<vlocity_cmt.ItemWrapper> itemsList = new list<vlocity_cmt.ItemWrapper>();
        prodNameCodeMap.put('ENT_ETH_WIFI_01','ENT_ETH_WIFI_01');
        prodNameCodeMap.put('ENT_ETH_WIFI_02','ENT_ETH_WIFI_02');
        List<Product2> lstProducts = ftr_TestDataFactory.getProducts(prodNameCodeMap,1); 
        List<QuoteLineItem> qlis = ftr_TestDataFactory.getQLI(2,2);
        insert qlis;
        
        qlis[0].vlocity_cmt__Product2Id__c = lstProducts[0].Id; 
        qlis[1].vlocity_cmt__Product2Id__c = lstProducts[1].Id;
        List<vlocity_cmt.ItemWrapper> vmlist = new List<vlocity_cmt.ItemWrapper>();
        for(QuoteLineItem ql:qlis){
            
            SObject bn;
            vlocity_cmt.ItemWrapper vm =new vlocity_cmt.ItemWrapper((SObject) new QuoteLineItem());
            vm.itemSObject = (SObject) new QuoteLineItem();
            vm.itemSObject = (SObject) ql;
            vmlist.add(vm);
        }
        Test.startTest();
        ftr_ValidationRulesImplementation.validateLineItems(vmlist);
        Test.stopTest();
    }
}