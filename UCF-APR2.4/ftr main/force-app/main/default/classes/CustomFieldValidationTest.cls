/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
**/ 
@isTest
public class CustomFieldValidationTest {
    @TestSetup
    static void makeData(){
        List<Order> orderList = ftr_TestDataFactory.getOrders(1);
        insert orderList;
        CustomFieldValidation__mdt[] cfvList = new List<CustomFieldValidation__mdt>();
        Orderitem[] oLIs = ftr_TestDataFactory.getOrderItems(1, new Map<String,String> {
            'ENT_ETH_UNI_0001' => 'ENT_ETH_UNI_0001'
        });
        oLIs[0].OrderId =orderList[0].id;
        insert oLIs;
        Contact c = new Contact(
        	LastName = 'Test',
            FirstName= 'User',
            Email='Test@User.com',
            Phone= '1234581021'
        );
        insert c;
        insert new Location_Contact__c(
        	Role__c = 'Location Contact', 
            Order__c = orderList[0].Id, 
            Order_Product__c =olis[0].Id, 
            Name = 'John',
            Contact__c = c.Id
        );
    }

    @IsTest
    static void methodName(){
        String contextId = [SELECT Id FROM Order LIMIT 1].Id;
        Test.startTest();
        CustomFieldValidation cfv = new CustomFieldValidation(contextId, 'Submit Order');
        cfv.isValid();
        cfv.getErrors();
        Test.stopTest(); 
    }
}