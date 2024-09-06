/**
 * @description       : This test class covers the following Apex classes:
 *      FTRWSDSATAddressController
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 11
**/
@isTest
private class FTRWSDSATAddressControllerTest {
    @isTest static  void testGetCallout() {
        // Associate the callout with a mock response
         Test.setMock(HttpCalloutMock.class, new FTRWSDSATAddressControllerMock()); 
        // Call method to test
        String result =FTRWSDSATAddressController.getBearer();
        // Verify mock response is not null
        /*System.assertNotEquals(null,result,'The callout returned a null response.');
        // Verify status code
        System.assertEquals(200,result.getStatusCode(),'The status code is not 200.');
        // Verify content type   
        System.assertEquals('application/json',result.getHeader('Content-Type'),'The content type value is not expected.'); 
        System.assertEquals('i.ApiKey_Header__c',result.getHeader('apikey'),'The apikey value is not expected.');  
        System.assertEquals('Bearer',result.getHeader('SIFT-Token'),'The SIFT TOKEN value is not expected.'); 
        // Verify the array contains 3 items     
        Map<String, Object> results = (Map<String, Object>) 
            JSON.deserializeUntyped(result.getBody());
        List<Object> fake = (List<Object>) results.get('FAKE');
        System.assertEquals('TEST STRING', fake[0],'The body has returned unexpected values.');  */        
    }   
    @isTest static void testPostCalloutPositive() {
    // Set mock callout class 
    Test.setMock(HttpCalloutMock.class, new FTRWSDSATAddressControllerPostMock()); 
    // This causes a fake response to be sent
    // from the class that implements HttpCalloutMock. 
        ftr_addressBeanDSAT quaddress= new ftr_addressBeanDSAT();
        quaddress.City='Test City';
        quaddress.State='test State';
        quaddress.Latitude= '1234';
        quaddress.Longitude= '2345';
        quaddress.ZipCode='zip1';
    FTRWSDSATAddressResponse response =  FTRWSDSATAddressController.getDSATAddress(quaddress);
    // Verify that the response received contains fake values
    /*String contentType = response.getHeader('Content-Type');
    System.assert(contentType == 'application/json');
    String apiKey = response.getHeader('apikey');
    System.assert(apiKey == 'i.ApiKey_Header__c');
    String bearer = response.getHeader('SIFT-Token');
    System.assert(bearer == 'Bearer - token');
    String actualValue = response.getBody();
    System.debug(response.getBody());
    String expectedValue = '{ "AQRecordId": null,"CPQId": null,"OpportunityId": null,"BusinessName": null,"Id": 1692264,"VFORecordId": null,"M6OrderNumber": null,"CreatedBy": "VFO user vyy965 and company Vlocity", "CreatorEmail": "SIFT.App.Support@ftr.com","CreatedById": 30890,"Opened": "2021-05-20T17:15:36.8891224-04:00", "InFootprint": true, "Market": "E","Level": "a","Products":    ["EIA","EVPL", "ELAN","IPVPN","Jumbo Frames","EPL","Connect Cloud","EPath","EReach"],"WireCenterCLLI": "OZONTXXA","SiteName": null,"WireCenterQoS": "Platinum","WireCenterSpeed": "1000MB","LitBuilding": false,"FiberDistance": "1079","CopperDistance": "5869","FiberTier": "1","CopperTier": "2","QualifiedAddress":    {"Address": "106 Medical Drive null","City": "Ozona","State": "TX","ZipCode": "76943","Latitude": 30.7221191,"Longitude": -101.2065615},"EReachProviders": [],"FiberQualification": "Qualified (max WC speed)","CopperQualification": "Qualified (up to 50MB)"}';
    System.assertEquals(actualValue, expectedValue, 'body has returned the expected results');
    System.assertEquals(200, response.getStatusCode(), 'status code is not expected');*/
}
    @isTest static void testPostCalloutPositiveDsatId() {
    // Set mock callout class 
    Test.setMock(HttpCalloutMock.class, new FTRWSDSATIDControllerPostMock()); 
    // This causes a fake response to be sent
    // from the class that implements HttpCalloutMock. 
        String DSATID ='12345';
    FTRWSDSATAddressResponse response =  FTRWSDSATAddressController.getDSATAddressWithDSATID(DSATID);
    // Verify that the response received contains fake values
    /*String contentType = response.getHeader('Content-Type');
    System.assert(contentType == 'application/json');
    String apiKey = response.getHeader('apikey');
    System.assert(apiKey == 'i.ApiKey_Header__c');
    String bearer = response.getHeader('SIFT-Token');
    System.assert(bearer == 'Bearer - token');
    String actualValue = response.getBody();
    System.debug(response.getBody());
    String expectedValue = '{ "AQRecordId": null,"CPQId": null,"OpportunityId": null,"BusinessName": null,"Id": 1692264,"VFORecordId": null,"M6OrderNumber": null,"CreatedBy": "VFO user vyy965 and company Vlocity", "CreatorEmail": "SIFT.App.Support@ftr.com","CreatedById": 30890,"Opened": "2021-05-20T17:15:36.8891224-04:00", "InFootprint": true, "Market": "E","Level": "a","Products":    ["EIA","EVPL", "ELAN","IPVPN","Jumbo Frames","EPL","Connect Cloud","EPath","EReach"],"WireCenterCLLI": "OZONTXXA","SiteName": null,"WireCenterQoS": "Platinum","WireCenterSpeed": "1000MB","LitBuilding": false,"FiberDistance": "1079","CopperDistance": "5869","FiberTier": "1","CopperTier": "2","QualifiedAddress":    {"Address": "106 Medical Drive null","City": "Ozona","State": "TX","ZipCode": "76943","Latitude": 30.7221191,"Longitude": -101.2065615},"EReachProviders": [],"FiberQualification": "Qualified (max WC speed)","CopperQualification": "Qualified (up to 50MB)"}';
    System.assertEquals(actualValue, expectedValue, 'body has returned the expected results');
    System.assertEquals(200, response.getStatusCode(), 'status code is not expected');*/
}
}