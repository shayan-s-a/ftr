@isTest
public class PromotionCodeMapperQLIServiceTest {
@TestSetup
    static void makeData(){
        ftr_PromotionCodeMapping__c[] sneList = new ftr_PromotionCodeMapping__c[]{};
            sneList.add(new ftr_PromotionCodeMapping__c(
                Product_Code__c='ENT_ETH_EIA_0002',
                Term__c='36 Months',
                Tier__c='Tier 1',
                State__c='TX'
            ));
        insert sneList;
        insert ftr_TestDataFactory.getQLI(2, 1);
        OrderItem[] olis = ftr_TestDataFactory.getOrderItems(2, new Map<String, String> {
            'EIA  (Ethernet Internet Access)' => 'ENT_ETH_EIA_0002',
            'EVPL (Ethernet Virtual Private Line)' => 'ENT_ETH_EVPL_0002',
            'EVPL EVC' => 'ENT_ETH_EVPL_0010',
            'Network Access' => 'ENT_ETH_ACCESS_0001'
        });
        Order o = ftr_TestDataFactory.getOrders(1)[0];
        insert o;
        for (OrderItem oi : olis) {
            oi.OrderId = o.Id;
        }
        insert olis;
    }

    @IsTest
    static void updateLineItems1(){
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        List<PromotionCodeMapperQLIService.PromotionRequest> PromotionRequestList = new List<PromotionCodeMapperQLIService.PromotionRequest>();
        PromotionCodeMapperQLIService.PromotionRequest PromotionRequestData = new PromotionCodeMapperQLIService.PromotionRequest();
        PromotionRequestData.quoteId=q.Id;
        PromotionRequestList.add(PromotionRequestData);
        //PromotionCodeMapperQLIService obj = new PromotionCodeMapperQLIService();
        PromotionCodeMapperQLIService.InvokePromotionUpdate(PromotionRequestList);
        Test.stopTest();
    }

    /*@IsTest
    static void updateLineItems2(){
        Order o = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        AttributeBasedSNEService service = new AttributeBasedSNEService(o.Id, 'Ethernet');
        service.updateLineItems();
        Test.stopTest();
    }

    @IsTest
    static void updateLineItems3(){
        Order q = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        AttributeBasedSNEService.updateLineItems(q.Id);
        Test.stopTest();
    }*/
}