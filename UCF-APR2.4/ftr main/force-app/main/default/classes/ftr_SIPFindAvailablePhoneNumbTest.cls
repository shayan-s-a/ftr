/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
**/
@isTest(seeAllData = false)
public class ftr_SIPFindAvailablePhoneNumbTest {
	static testMethod void myUnitTest() {
    	String url = '';
       	String path = ''; 
        String testJsonInput = '{"FindAvailableTelephoneNumbers" :{"findAvailableTelephoneNumbersInput" :{"exchangeFilter":{"env":"LF","maxTnNumbers":"5","itemSequence":"4", "stateAbbreviation":"CA" }}}}';
        Map<String, Object> input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
        ftr_SIPFindAvailablePhoneNumbInterface service = new ftr_SIPFindAvailablePhoneNumbInterface();
        service.getOrchestrationTaskName();
        service.processDPIResponseType(url, path, input);
        service.createDPIRequestType( url, path, input);
        
    }
}