/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1
 **/
@isTest
public class ftr_GuidedQuoteOSControllerTest {
	@isTest
	static void checkIfPremiseExistsTest1() {
		Map<String, Object> AddressMap = new Map<String, Object>();
		Map<String, Object> inputMap = new Map<String, Object>();
		Map<String, Object> outputMap = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();

		/*//inputMap.put('Address', '1 BLACHLEY RD, STAMFORD, CT, 06902');
        AddressMap.put('address', '1 BLACHLEY RD');
        AddressMap.put("City", "STAMFORD");
        AddressMap.put('State', 'CT');
        AddressMap.put('ZipCode', '06902');
        //inputMap.put('Country', 'US');
        inputMap.put('Address',AddressMap);*/

		string strJSON = '{"address" :{"Address":"1 BLACHLEY RD","City":"STAMFORD", "State" : "CT", "ZipCode":"06902"}}';
		inputMap = (Map<String, object>) JSON.deserializeUntyped(strJSON);

		ftr_GuidedQuoteOSController validatePremise = new ftr_GuidedQuoteOSController();
		Boolean result;
		Test.startTest();
		result = validatePremise.invokeMethod('getPremises', inputMap, outputMap, options);
		Test.stopTest();

		System.assertEquals(null, outputMap.get('Premises'));
	}

	@isTest
	static void checkIfPremiseExistsTest2() {
		Map<String, Object> AddressMap = new Map<String, Object>();
		Map<String, Object> inputMap = new Map<String, Object>();
		Map<String, Object> outputMap = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();

		/*//inputMap.put('Address', '1 BLACHLEY RD, STAMFORD, CT, 06902');
        AddressMap.put('address', '1 BLACHLEY RD');
        AddressMap.put("City", "STAMFORD");
        AddressMap.put('State', 'CT');
        AddressMap.put('ZipCode', '06902');
        //inputMap.put('Country', 'US');
        inputMap.put('Address',AddressMap);*/

		string strJSON = '{"address" :{"Address":"1 BLACHLEY RD","City":"STAMFORD", "State" : "CT", "ZipCode":"06902"}}';
		inputMap = (Map<String, object>) JSON.deserializeUntyped(strJSON);

		ftr_GuidedQuoteOSController validatePremise = new ftr_GuidedQuoteOSController();
		Boolean result;
		Test.startTest();
		result = validatePremise.invokeMethod('retrieveCustomerFacilities', inputMap, outputMap, options);
		Test.stopTest();

		System.assertEquals(null, outputMap.get('env'));
	}

	@isTest
	static void checkIfPremiseExistsTest3() {
		Map<String, Object> inputMap = new Map<String, Object>();
		Map<String, Object> outputMap = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> address = new Map<String, Object>();

        vlocity_cmt__Premises__c premises = ftr_TestDataFactory.getPremises(1)[0];
		insert premises;
        
        address.put('Address', premises.vlocity_cmt__StreetAddress__c);
        address.put('City', premises.vlocity_cmt__City__c);
        address.put('State', premises.vlocity_cmt__State__c);
        address.put('ZipCode', premises.vlocity_cmt__PostalCode__c);

        inputMap.put('address', address);

		ftr_GuidedQuoteOSController validatePremise = new ftr_GuidedQuoteOSController();
		Boolean result;
		Test.startTest();
		result = validatePremise.invokeMethod('retrieveCustomerFacilities', inputMap, outputMap, options);
		Test.stopTest();
        System.debug('outputMap: ' + outputMap);
		// System.assertEquals('', outputMap.get('env'));
	}
}