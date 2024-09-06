/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public with sharing class ftr_M6OrderStatusUpdateEveDispatchTest {
 @isTest  
    static void afterInsertTest() {
          PSROrderUpdate__e obj = new PSROrderUpdate__e();
       	obj.PSROrderId__c = '123';
        obj.Circuitid__c = '456';
        obj.PSROrderStatus__c = 'Complete';
        test.startTest();
        EventBus.publish(obj);
        test.stopTest();
    }
}