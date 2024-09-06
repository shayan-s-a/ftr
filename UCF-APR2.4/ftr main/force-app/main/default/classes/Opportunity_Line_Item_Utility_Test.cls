/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@IsTest(seeAllData = true)
public class Opportunity_Line_Item_Utility_Test {
    @IsTest
    private static Void getOpportunityLineItemsMap_Test() {
     	Opportunity opp=[Select Id from Opportunity limit 1];
        Map<Id, OpportunityLineItem> oliMap = Opportunity_Line_Item_Utility.getOpportunityLineItemsMapFromOpportunity(opp.Id);
        System.debug('oliMap: ' + oliMap);
      //  System.assert(oliMap.size() == 1, 'getOpportunityLineItemsMap.size() should have been 1 but was ' + oliMap.size());
    }

}