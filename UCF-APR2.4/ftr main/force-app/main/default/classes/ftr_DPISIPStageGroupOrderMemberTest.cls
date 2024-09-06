/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest(seeAllData = false)
public class ftr_DPISIPStageGroupOrderMemberTest {
	static testMethod void myUnitTest() {
    	String url = '';
       	String path = ''; 
        String testJsonInput = '{"orderStageCode":"END","dpiOrderId":{"orderNumber":"049792398","environment":"MS"}}';
        Map<String, Object> input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
        ftr_DPISIPStageGroupOrderMemberInterf service = new ftr_DPISIPStageGroupOrderMemberInterf();
        service.getOrchestrationTaskName();
        service.createDPIRequestType( url, path, input);

    }
}