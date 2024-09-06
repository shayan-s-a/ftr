/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3 
**/
@isTest(seeAllData = false)
public class ftr_SIPReserveTelephoneNumberTest {
	static testMethod void myUnitTest() {
    	String url = '';
       	String path = ''; 
        String testJsonInput = '{"ReserveTelephoneNumber" :{"reserveTelephoneNumberInput" :{"environment":"LF","maxTnNumbers":"5","itemSequence":"4", "stateAbbreviation":"CA","telephoneNumber":"3453453456" }}}';
        Map<String, Object> input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
        ftr_SIPReserveTelephoneNumberInterface service = new ftr_SIPReserveTelephoneNumberInterface();
        service.getOrchestrationTaskName();
        service.createDPIRequestType( url, path, input);
        service.processDPIResponseType(url, path, input);
    }
}