/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class AttributeBasedSNEServiceTest {

    //@TestSetup
    static void makeData(){
        ftr_Attribute_Based_SNE__c[] sneList = new ftr_Attribute_Based_SNE__c[]{};
            sneList.add(new ftr_Attribute_Based_SNE__c(
                Product_Code__c='ENT_ETH_EIA_0002',
                Term__c='36 Months',
                SNE_Code_MRC__c='123',
                SNE_Code_OTC__c='456'
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
        //insert o;
        for (OrderItem oi : olis) {
            oi.OrderId = o.Id;
        }
        //insert olis;
    }

    @IsTest
    static void updateLineItems1(){
        //Quote q = [SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        ftr_Attribute_Based_SNE__c[] sneList = new ftr_Attribute_Based_SNE__c[]{};
            sneList.add(new ftr_Attribute_Based_SNE__c(
                Product_Code__c='ENT_ETH_EIA_0002',
                Term__c='36 Months',
                SNE_Code_MRC__c='123',
                SNE_Code_OTC__c='456'
            ));
        insert sneList;
        //Quote q =ftr_TestDataFactory.getQuotes(1)[0];
        //insert q;
        insert ftr_TestDataFactory.getQLI(2, 1);
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        AttributeBasedSNEService service = new AttributeBasedSNEService(q.Id);
        service.updateLineItems();
        Test.stopTest();
    }
	
    /*
    @IsTest
    static void updateLineItems2(){
        //Order o = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        ftr_Attribute_Based_SNE__c[] sneList = new ftr_Attribute_Based_SNE__c[]{};
            sneList.add(new ftr_Attribute_Based_SNE__c(
                Product_Code__c='ENT_ETH_EIA_0002',
                Term__c='36 Months',
                SNE_Code_MRC__c='123',
                SNE_Code_OTC__c='456'
            ));
        insert sneList;
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
        AttributeBasedSNEService service = new AttributeBasedSNEService(o.Id, 'Ethernet');
        service.updateLineItems();
        Test.stopTest();
    }

    @IsTest
    static void updateLineItems3(){
        //Order q = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        Order q = ftr_TestDataFactory.getOrders(1)[0];
        insert q;
        AttributeBasedSNEService.updateLineItems(q.Id);
        Test.stopTest();
    }
	*/
    
}