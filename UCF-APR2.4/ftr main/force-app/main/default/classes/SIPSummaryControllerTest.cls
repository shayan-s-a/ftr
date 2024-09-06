/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class SIPSummaryControllerTest {
    
    @TestSetup
    static void makeData(){
        Order[] o = ftr_TestDataFactory.getOrders(1);
        Account[] servAccs = ftr_TestDataFactory.getServAccountsWithPremise(1);
        update servAccs;
        insert o;
        OrderItem[] oi = ftr_TestDataFactory.getOrderItems(1, new Map<String,String>{
            'SIP_TRUNKING_0010' => 'SIP_TRUNKING_0010'
        });
        oi[0].OrderId = o[0].Id;
        oi[0].vlocity_cmt__ServiceAccountId__c = servAccs[0].Id;
        insert oi;
        insert new ftr_EVC_Location_Details__c(
            OrderItem__c = oi[0].Id
        );
        oi = ftr_TestDataFactory.getOrderItems(1, new Map<String,String>{
            'ENT_ETH_UNI_0001' => 'ENT_ETH_UNI_0001'
        });
        oi[0].OrderId = o[0].Id;
        oi[0].vlocity_cmt__ServiceAccountId__c = servAccs[0].Id;
        insert oi;

        insert new ftr_UNI_Location_Details__c(
            OrderItem__c = oi[0].Id
        );

    }

    @IsTest
    static void methodName(){
        
        Test.startTest();
        SIPSummaryController ctrl = new SIPSummaryController();
        ctrl.recordId = [SELECT Id FROM Order LIMIT 1].Id;
        ctrl.getAllData();
        Test.stopTest();
        
    }
}