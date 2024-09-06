/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class FulfilmentRequestEventTest {

    @IsTest
    static void testUpdateFRLs(){
        FulfilmentRequestEvent__e[] events = new FulfilmentRequestEvent__e[]{};
        vlocity_cmt__FulfilmentRequestLine__c[] frls = ftr_TestDataFactory.getFulfilmentRequestLines(1, new Map<String,String>{ 'ENT_ETH_DPI_CIRCUIT_BILLING'=>'ENT_ETH_DPI_CIRCUIT_BILLING' });
        insert frls;
        Test.startTest();
        events.add(new FulfilmentRequestEvent__e(
            FRL_Id__c=frls[0].Id,
            JSONAttribute__c=frls[0].vlocity_cmt__JSONAttribute__c,
            MethodName__c='updateFRLs'
        ));
        EventBus.publish(events);
        Test.stopTest();
        
    }
}