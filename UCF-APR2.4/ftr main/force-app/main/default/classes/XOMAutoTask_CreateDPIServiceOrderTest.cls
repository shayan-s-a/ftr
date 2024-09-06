/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class XOMAutoTask_CreateDPIServiceOrderTest {
	@isTest static void myAccount() {
        vlocity_cmt__FulfilmentRequestLine__c frl = ftr_TestDataFactory.getFulfilmentRequestLines(1, new Map<String, String> { 'ENT_ETH_DPI_CIRCUIT_BILLING' => 'ENT_ETH_DPI_CIRCUIT_BILLING' })[0];
        frl.vlocity_cmt__JSONAttribute__c = ftr_TestDataFactory.getJSONAttribute('ENT_ETH_DPI_CIRCUIT_BILLING');  
        insert frl;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        XOMAutoTask_CreateDPIServiceOrder service = new XOMAutoTask_CreateDPIServiceOrder();
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
    
     @isTest static void myRCServiceOrder() {
        vlocity_cmt__FulfilmentRequestLine__c frl = ftr_TestDataFactory.getFulfilmentRequestLines(1, new Map<String, String> { 'ENT_ETH_DPI_CIRCUIT_BILLING' => 'ENT_ETH_DPI_CIRCUIT_BILLING' })[0];
        frl.vlocity_cmt__JSONAttribute__c = ftr_TestDataFactory.getJSONAttribute('ENT_ETH_DPI_CIRCUIT_BILLING');  
        insert frl;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        XOMAutoTask_RCCreateServiceOrder service = new XOMAutoTask_RCCreateServiceOrder();
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