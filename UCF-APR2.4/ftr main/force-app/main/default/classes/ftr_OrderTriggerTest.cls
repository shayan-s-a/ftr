/**
 * @description       : This test class covers the following Apex classes:
 *      FieldAssignmentService
 *      ftr_OrderTriggerHandler
 * @author            : TBD
 * @version           : 2
**/
@isTest
public class ftr_OrderTriggerTest {
    @testSetup 
    static void prepareTestData() {

        Order[] orderList = ftr_TestDataFactory.getOrders(1);

        String orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Vlocity_OM_Order').getRecordTypeId();
        for (Order o : orderList) {
            o.RecordTypeId = orderRecordType;
        }
        insert orderList;
        
        insert ftr_TestDataFactory.getFieldAssignments(4);
    }
	
	@isTest 
    static void CNPTest() {

        Order ordObj = [SELECT Id, Order_Stage__c FROM Order LIMIT 1];
        ordObj.Order_Stage__c = 'Customer Network Provisioning';
        ordObj.Add_On_Products__c = 'SIP Trunking';
        
        Test.startTest();
        
        update ordObj;

        Test.stopTest();
	}

    @isTest 
    static void SDWANTest() {
        
        Order ordObj = [SELECT Id, Product_Type__c, Product__c, Router_s__c, Order_Stage__c FROM Order LIMIT 1];
        ordObj.Order_Stage__c = 'QA Review';
        ordObj.Product_Type__c = 'SDWAN';
        ordObj.Product__c = 'SDWAN - E-Reach/Off-Net Ethernet';
        ordObj.Add_On_Products__c = 'SIP Trunking';
        ordObj.Router_s__c = null;
        
        Test.startTest();
        
        update ordObj;

        Test.stopTest();
	}

    @isTest 
    static void sendOrderDetailsTest() {
        
        Order ordObj = [SELECT Id, Product_Type__c, OrderNumber, AccountId, OwnerId, Product__c, Router_s__c, Order_Stage__c FROM Order LIMIT 1];
        
        Test.startTest();
        
        FieldAssignmentService.sendOrderDetails(ordObj, ordObj, ordObj.OwnerId);

        Test.stopTest();
	}

    @isTest 
    static void noProvisionersTest() {
        delete [SELECT Id FROM FieldAssignment__c WHERE Field__c = 'Order Provisioner'];

        Order ordObj = [SELECT Id, Product_Type__c, Product__c, Router_s__c, Order_Stage__c FROM Order LIMIT 1];
        ordObj.Order_Stage__c = 'Customer Network Provisioning';
        ordObj.Product_Type__c = 'SDWAN';
        ordObj.Product__c = 'SDWAN - E-Reach/Off-Net Ethernet';

        Group q;
        try {
            q = [SELECT Id, Email FROM Group WHERE DeveloperName = 'CNP_Assignment_Notice' AND Type='Queue'];
            q.Email = 'test@test.com';
            update q;
        } catch (Exception e) {
            q = new Group (Email='test@test.com', DeveloperName = 'CNP_Assignment_Notice', Name='CNP_Assignment_Notice', Type='Queue');
            insert q;
            System.runAs(new User(Id=UserInfo.getUserId())) {
                QueuesObject testQueue = new QueueSObject(QueueID = q.id, SObjectType = 'Task');
                insert testQueue;
            }
        }
        
                
        Test.startTest();
        
        update ordObj;

        // FieldAssignmentService service = new FieldAssignmentService(ordObj, ordObj);
        // service.sendOrderExceptionEmail(q);

        Test.stopTest();
	}

    @isTest 
    static void deleteOrderTest() {

        Order ordObj = [SELECT Id, Product_Type__c, Product__c, Router_s__c, Order_Stage__c FROM Order LIMIT 1];
                
        Test.startTest();
        
        delete ordObj;

        Test.stopTest();
	}


}