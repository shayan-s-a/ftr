/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3 
**/
@isTest
public with sharing class ftr_FRLStatusUpdateEventDispatcherTest {

    @isTest  
    static void afterInsertTest() {

        FRL_Status_Update__e testEvent = new FRL_Status_Update__e();
        testEvent.FRL_Id__c = '1234567890';
        testEvent.FRL_Reference_Id__c = '0987654321';
        testEvent.JSONAttribute__c = 'jsonAttribute';
        testEvent.Object_Type__c = 'TestObjectType';
        testEvent.Orchestration_Item_Id__c = '1111111';
        testEvent.Plan_Id__c = '2222222';
        testEvent.Product_Code__c = 'ENT_ETH_UNI_PSR_001';
        testEvent.Status__c = 'Completed';

        test.startTest();
        EventBus.publish(testEvent);
        test.stopTest();
        
    }
}