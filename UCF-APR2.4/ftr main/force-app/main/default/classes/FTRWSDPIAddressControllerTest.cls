/**
* @description       : This test class covers the following Apex classes:
*      TBD_CLASS1
*      TBD_CLASS2
*      TBD_CLASS3
* @author            : TBD
* @version           : 7
**/
@isTest
public class FTRWSDPIAddressControllerTest {
    
    @isTest
    public static void testRetreiveCustomerFacility() {
        Test.setMock(WebServiceMock.class, new FTRWSDPIAddressValResultMock());
        ftr_addressBean addressBean1 = new ftr_addressBean();
        FTRWSDPIAddressController.retreiveCustomerFacility(addressBean1); 
        
        Test.setMock(WebServiceMock.class, new FTRWSDPIAddressValResultMock());
        ftr_addressBean addressBean = new ftr_addressBean();
        addressBean.addressLine1 = '2001 SOLAR DR';
        addressBean.cityName = 'OXNARD';
        addressBean.state = 'CA';
        addressBean.zipCode = '93036';
        String unitNumber = '275 STE';    
        FTRWSDPIAddressController.retreiveMatchingCustomerFacility(addressBean, unitNumber);        
    }
    
    @isTest
    public static void testRetreiveCustomerFacilityPredictive() {
        WS_ESB_Settings__c setting = new WS_ESB_Settings__c(Apigee_Token__c = 'r3MUlqybToeRGmBgw1YSW7FnDUTTwWV7',
                                                            EC_ApplicationID__c = 'SFDC', EC_EmployeeID__c = '123456', EC_UserID__c = 'ESB_REG');
        insert setting;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSDPIPredictiveAddressValResultMock());
        ftr_addressBean addressBean1 = new ftr_addressBean();
        FTRWSDPIAddressController.retreiveCustomerFacilityBulk(addressBean1, 'kjhgfhjkl'); 
        
        Test.setMock(HttpCalloutMock.class, new FTRWSDPIPredictiveAddressValResultMock());
        ftr_addressBean addressBean = new ftr_addressBean();
        addressBean.addressLine1 = '2001 SOLAR DR';
        addressBean.cityName = 'OXNARD';
        addressBean.state = 'CA';
        addressBean.zipCode = '93036';
        String unitNumber = '478 Unit';    
        FTRWSDPIAddressController.retreiveMatchingCustomerFacilityBulk(addressBean, unitNumber);
        unitNumber = '275 STE'; 
        Test.setMock(HttpCalloutMock.class, new FTRWSDPIPredictiveAddressValResultMock());
        FTRWSDPIAddressController.retreiveMatchingCustomerFacilityBulk(addressBean, unitNumber);
        Test.stopTest();        
    }
    
    public class FTRWSDPIPredictiveAddressValResultMock implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ \"addresses\": [ { \"addressKey\": \"61e94fe2-0ebf-464b-909c-a6a1ae41a5e6\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Ste 478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Ste\", \"unitNumber\": \"478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"235756\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"7b1eb613-e847-4e92-8d35-ec5bbb46be3d\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Unit 478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Unit\", \"unitNumber\": \"478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"786567\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"6d7681df-80ce-45e6-ad91-f9852a6c6153\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Spc 1478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Spc\", \"unitNumber\": \"1478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"2500757\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"4603a67c-e27e-47e2-918b-715c617462a5\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Spc 9208\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Spc\", \"unitNumber\": \"9208\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"1661125\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"a5d48440-36bd-46f3-9c26-9d7340dbabb6\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Rm 326\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Rm\", \"unitNumber\": \"326\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"5639241\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"64be8e3f-c093-495a-a3e0-5bc1d796635f\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Rm 5\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Rm\", \"unitNumber\": \"5\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"1237941\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"47f456cf-60be-42e4-b970-75e29c901f99\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Ste K9009\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Ste\", \"unitNumber\": \"K9009\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"766421\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"5c14c2e7-b1af-4cef-9db0-e81c15aef18c\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Ste R009Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Ste\", \"unitNumber\": \"R009Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"3852729\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"60c8cbde-ba82-4f83-ba9c-42d6deb1a7fc\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Ste R012Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Ste\", \"unitNumber\": \"R012Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"3694042\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"5c2180f0-8119-490a-bb66-fc537f8d2f4c\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Ste R016Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Ste\", \"unitNumber\": \"R016Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"1135582\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true } ], \"totalCount\": 9171, \"links\": [ { \"href\": \"/v1/AddressSearch/Predictive?address=112+Plaza+Dr%2c+478%2c+West+Covina%2c+CA%2c+91790&pageIndex=2&pageSize=10\", \"rel\": \"next\", \"verb\": \"GET\" }, { \"href\": \"/v1/AddressSearch/Predictive?address=112+Plaza+Dr%2c+478%2c+West+Covina%2c+CA%2c+91790&pageIndex=918&pageSize=10\", \"rel\": \"last\", \"verb\": \"GET\" } ] }');
            res.setStatusCode(200);
            return res;
        }
    }
    
}