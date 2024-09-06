/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3 
**/
@isTest
public class XOMAutoTask_SIPCreateDPIServiceOrdTest {
	@isTest static void myAccount() {
        vlocity_cmt__FulfilmentRequestLine__c frl = ftr_TestDataFactory.getFulfilmentRequestLines(1, new Map<String, String> { 'ENT_ETH_DPI_CIRCUIT_BILLING' => 'ENT_ETH_DPI_CIRCUIT_BILLING' })[0];
        frl.vlocity_cmt__JSONAttribute__c = ftr_TestDataFactory.getJSONAttribute('ENT_ETH_DPI_CIRCUIT_BILLING');  
        insert frl;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        XOMAutoTask_SIPCreateDPIServiceOrder service = new XOMAutoTask_SIPCreateDPIServiceOrder();
        service.executeBatch(
            new List<vlocity_cmt__OrchestrationItem__c> { 
                new vlocity_cmt__OrchestrationItem__c(
                    vlocity_cmt__FulfilmentRequestLineId__c= frl.Id
                ) 
            }
        );
        Test.stopTest();
        String billingTelephoneNumber = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'BillingTelephoneNumber') ;
        System.assert(
            [SELECT Id FROM Service_Order__c WHERE Billing_Number__c = :billingTelephoneNumber].size() > 0
        );
    }
}