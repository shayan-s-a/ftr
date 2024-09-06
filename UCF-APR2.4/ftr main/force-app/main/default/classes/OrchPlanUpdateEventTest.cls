/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class OrchPlanUpdateEventTest {

    @TestSetup
    static void makeData(){
        vlocity_cmt__OrchestrationPlan__c[] plans = ftr_TestDataFactory.getOrchestrationPlans(1);
        insert plans;
        vlocity_cmt__OrchestrationItem__c[] items = ftr_TestDataFactory.getOrchestrationItems(1, new Map<String,String> {'ENT_ETH_EVPL_0010'=>'ENT_ETH_EVPL_0010'});
        items[0].vlocity_cmt__OrchestrationPlanId__c = plans[0].Id;
        insert items;
    }
    @IsTest
    static void testDecomposeAndCreatePlan(){
        
        Test.startTest();
        List<OrchPlanEvent__e> eventList = new List<OrchPlanEvent__e>();
        eventList.add(new OrchPlanEvent__e(
            OrderId__c = '12345',
            MethodName__c = 'DecomposeAndCreatePlan'
        ));
        EventBus.publish(eventList);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testAssignQueues(){
        
        Test.startTest();   
        Order[] orders = ftr_TestDataFactory.getOrders(1);
        insert orders;
        vlocity_cmt__OrchestrationPlan__c plan = [SELECT Id, vlocity_cmt__OrderId__c FROM vlocity_cmt__OrchestrationPlan__c LIMIT 1];
        plan.vlocity_cmt__OrderId__c = orders[0].Id;
        update plan;
        
        List<OrchPlanEvent__e> eventList = new List<OrchPlanEvent__e>();
        eventList.add(new OrchPlanEvent__e(
            OrderId__c = orders[0].Id,
            MethodName__c = 'AssignQueues'
        ));
        EventBus.publish(eventList);
        Test.stopTest();
        
    }
}