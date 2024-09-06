/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
**/
@isTest(seeAllData = false)
public class ftr_SIPRetrieveCustomerFacilitiesITest {
	static testMethod void myUnitTest() {
    	String url = '';
       	String path = ''; 
        String testJsonInput = '{"RetrieveCustomerFacilities" :{"RetrieveCustomerFacilitiesInput" :{"address":{"streetName":"1602 Glasson Street","state":"IL","postalCode":"61704","city":"Bloomington"}}}}';
        Map<String, Object> input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
        ftr_SIPRetrieveCustomerFacilitiesInterf service = new ftr_SIPRetrieveCustomerFacilitiesInterf();
        service.getOrchestrationTaskName();
        service.createDPIRequestType( url, path, input);
        service.processDPIResponseType(url, path, input);
    }
}