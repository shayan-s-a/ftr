/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class ProductViewControllerTest {
    @IsTest
    static void testProductView(){
        QuoteLineItem[] lst = ftr_TestDataFactory.getQLI(1, 1);
        insert lst;
        update new Product2(
        	Id = lst[0].Product2Id,
            vlocity_cmt__Type__c = 'License',
            Family = 'UCF'
        );
        Opportunity opp = [select id from opportunity limit 1];
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(opp.Id));
        ProductViewController ctrl = new ProductViewController();
        ctrl.getAllData();
        ctrl.generateCSV();
        ctrl.setAllData(ctrl.allData);
        Test.stopTest();
        
    }
}