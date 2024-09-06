/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3
**/
@isTest
public class XOMAutoTask_SIPCreateDPIMDNServiceTestV2 {
	@isTest static void myAccount() {
        vlocity_cmt__FulfilmentRequestLine__c frl = ftr_TestDataFactory.getFulfilmentRequestLines(1, new Map<String, String> { 'ENT_ETH_DPI_CIRCUIT_BILLING' => 'ENT_ETH_DPI_CIRCUIT_BILLING' })[0];
        frl.vlocity_cmt__JSONAttribute__c = ftr_TestDataFactory.getJSONAttribute('ENT_ETH_DPI_CIRCUIT_BILLING');  
        insert frl;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        XOMAutoTask_SIPCreateDPIMDNServiceOrder service = new XOMAutoTask_SIPCreateDPIMDNServiceOrder();
        service.executeBatch(
            new List<vlocity_cmt__OrchestrationItem__c> { 
                new vlocity_cmt__OrchestrationItem__c(
                    vlocity_cmt__FulfilmentRequestLineId__c= frl.Id
                ) 
            }
        );
        Test.stopTest();
        
    }
}