@isTest(seeAllData = true)
private class AgentToolsTest {
// version 1
    static testMethod void myUnitTest() {
        AgentTools agnTools = new AgentTools();
        AgentTools_AddressValidation.LeadObject newLead = new AgentTools_AddressValidation.LeadObject();
        agnTools.showBatchProcessMessage = true;
        agnTools.multipleAddressLookup = new List<AgentTools_AddressValidation.LeadObject>();
        agnTools.multipleAddressLookup.add(newLead);
        
        List<string> str = new List<string>{'asdf'};
        List<List<String>> strList = new List<List<String>>();
        strList.add(str);
        agnTools.multipleAddressFile = blob.valueof('1225 Storyglen St., Apt. No. 345, (469)-623-7789,' +'PO, Box, 4567,'+ ', Tx, 75062, 654 \n'+
                                                    '1525 Storyglen St., Apt. No. 345, (469)-623-7789, dallas' +'PO, Box, 4567,'+ ', Tx, 75062, 654 \n');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSDPIPredictiveAddressValResultMock());
        agnTools.ReadMultiFile();
        Test.stopTest();
        agnTools.AddressValidation_Submit();
        boolean ren = agnTools.getBusinessTechnologyRender();
        agnTools.getResidentialTechnologyRender();
        List<SelectOption> selOpt = agnTools.getSearchCriteria();
        Test.setMock(HttpCalloutMock.class, new FTRWSDPIPredictiveAddressValResultMock());
        agnTools.ReadMultiFile();
        agnTools.AddressValidation = new AgentTools_AddressValidation(newLead);
        //agnTools.AddressValidation_Reset();
    }
    @isTest
    public static void testRetreiveCustomerFacilityPredictive() {
        AgentTools agnTools = new AgentTools();
        AgentTools_AddressValidation.LeadObject newLead = new AgentTools_AddressValidation.LeadObject();
        agnTools.showBatchProcessMessage = true;
        agnTools.multipleAddressLookup = new List<AgentTools_AddressValidation.LeadObject>();
        agnTools.multipleAddressLookup.add(newLead);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSDPIPredictiveAddressValResultMock());
        AgentTools_AddressValidation.LeadObject reqAdd = new AgentTools_AddressValidation.LeadObject();
        reqAdd.Street = '2120 cannes dr';
        reqAdd.City = 'Carrollton';
        reqAdd.State = 'TX';
        reqAdd.PostalCode ='75006';
        reqAdd.Telephone = '2145554411';
        agnTools.singleAddressLookup = new AgentTools_AddressValidation.LeadObject();
        agnTools.singleAddressLookup = reqAdd;
        
        agnTools.searchAddressText = 'test';
        agnTools.doPredictiveSearch();
        String strAddressKey = agnTools.objAddressWrapper != null && 
            agnTools.objAddressWrapper.addresses != null && !agnTools.objAddressWrapper.addresses.isEmpty() ? agnTools.objAddressWrapper.addresses[0].addressKey : '';
        String strAddressDisplay = agnTools.objAddressWrapper != null && 
            agnTools.objAddressWrapper.addresses != null && !agnTools.objAddressWrapper.addresses.isEmpty() ? agnTools.objAddressWrapper.addresses[0].strAddressDisplay : '';
        String strAddress = agnTools.objAddressWrapper != null && 
            agnTools.objAddressWrapper.addresses != null && !agnTools.objAddressWrapper.addresses.isEmpty() ? agnTools.objAddressWrapper.addresses[0].strAddress : '';
        agnTools.selectedAddress = strAddress;
        agnTools.processAddressSelected();
        agnTools.AddressValidation = new AgentTools_AddressValidation(newLead);
        agnTools.AddressValidation.objServiceAddress = new List<ServiceAddressWrapper>();
        Test.setMock(HttpCalloutMock.class, new FTRWSDPIPredictiveAddressValResultMock());
        agnTools.AddressValidation_Submit();
        agnTools.AddressValidation_Reset();
        Test.stopTest();        
    }
    public class FTRWSDPIPredictiveAddressValResultMock implements HttpCalloutMock {
        // Implement this interface method
        public Boolean boolIdentifier;
        /*public FTRWSDPIPredictiveAddressValResultMock(Boolean boolIdentifier) {
            this.boolIdentifier = boolIdentifier;
        }*/
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            
            // Create a fake respon
            if (req.getEndpoint().contains('Predictive')) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{ \"addresses\": [ { \"addressKey\": \"61e94fe2-0ebf-464b-909c-a6a1ae41a5e6\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Ste 478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Ste\", \"unitNumber\": \"478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"235756\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"7b1eb613-e847-4e92-8d35-ec5bbb46be3d\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Unit 478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Unit\", \"unitNumber\": \"478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"786567\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"6d7681df-80ce-45e6-ad91-f9852a6c6153\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Spc 1478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Spc\", \"unitNumber\": \"1478\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"2500757\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"4603a67c-e27e-47e2-918b-715c617462a5\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Spc 9208\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Spc\", \"unitNumber\": \"9208\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"1661125\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"a5d48440-36bd-46f3-9c26-9d7340dbabb6\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Rm 326\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Rm\", \"unitNumber\": \"326\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"5639241\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"64be8e3f-c093-495a-a3e0-5bc1d796635f\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Rm 5\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Rm\", \"unitNumber\": \"5\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"1237941\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"47f456cf-60be-42e4-b970-75e29c901f99\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Ste K9009\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Ste\", \"unitNumber\": \"K9009\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"766421\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"5c14c2e7-b1af-4cef-9db0-e81c15aef18c\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Ste R009Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Ste\", \"unitNumber\": \"R009Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"3852729\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"60c8cbde-ba82-4f83-ba9c-42d6deb1a7fc\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Ste R012Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Ste\", \"unitNumber\": \"R012Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"3694042\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true }, { \"addressKey\": \"5c2180f0-8119-490a-bb66-fc537f8d2f4c\", \"parentKey\": \"57db6a7a-73b3-4510-8e21-b68617f2db35\", \"address\": { \"addressLine1\": \"112 Plaza Dr\", \"addressLine2\": \"Ste R016Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCode\": \"91790-2805\" }, \"parsedAddress\": { \"streetNumber\": \"112\", \"streetPreDirectional\": \"\", \"streetName\": \"Plaza\", \"streetSuffix\": \"Dr\", \"streetPostDirectional\": \"\", \"unitType\": \"Ste\", \"unitNumber\": \"R016Z\", \"city\": \"West Covina\", \"stateProvince\": \"CA\", \"zipCodeBase\": \"91790\", \"zipCodePlus4\": \"2805\" }, \"samRecords\": [ { \"environment\": \"CZ\", \"controlNumber\": \"1135582\" } ], \"latitude\": 34.06947, \"longitude\": -117.927343, \"isParent\": false, \"inFootprint\": true } ], \"totalCount\": 9171, \"links\": [ { \"href\": \"/v1/AddressSearch/Predictive?address=112+Plaza+Dr%2c+478%2c+West+Covina%2c+CA%2c+91790&pageIndex=2&pageSize=10\", \"rel\": \"next\", \"verb\": \"GET\" }, { \"href\": \"/v1/AddressSearch/Predictive?address=112+Plaza+Dr%2c+478%2c+West+Covina%2c+CA%2c+91790&pageIndex=918&pageSize=10\", \"rel\": \"last\", \"verb\": \"GET\" } ] }');
                res.setStatusCode(200);
                return res;
            } else {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{\"offers\":[\"fiberExpansion\",\"challenger2\",\"challenger1b\"],\"address\":{\"streetNumber\":\"1234\",\"streetName\":\"EAGLE PATH\",\"city\":\"VICTOR\",\"state\":\"NY\",\"zipCode\":\"145648824\"},\"serviceAddressMasterId\":{\"controlNumber\":558007,\"environment\":\"LR\"},\"timeZone\":{\"timeZone\":\"America/New_York\",\"gmtOffset\":-3,\"observesDST\":true},\"buildingType\":\"SINGLE_FAMILY\",\"buildingUse\":\"RESIDENTIAL\",\"plantArea\":\"VICTOR EAST\",\"plantType\":\"COPPER\",\"homingExchange\":585742,\"tariff\":\"ROC\",\"rateCenter\":\"VICTOR\",\"wireCenter\":585742,\"centralOfficeClliCode\":\"VCTRNYXARS0\",\"remoteOfficeClliCode\":\"VCTRNYXARS0\",\"isHoaRestrictedAddress\":false,\"hasActiveServiceAtAddress\":false,\"isPaClecAddress\":false,\"hasLocalFranchiseAgreement\":true,\"proximityToFootprint\":\"IN_FOOTPRINT\",\"fiberBuildOutProjectId\":\"2022 FTTH\",\"fiberBuildOutStatus\":\"PENDING\",\"fiberBuildOutPreSalesOrdering\":\"CREATE_PROSPECT\",\"technology\":[{\"name\":\"XPON\",\"medium\":\"FIBER\",\"group\":\"FIBER\",\"marketingSpeed\":\"5.0G/5.0G\",\"features\":[\"VOIP\"],\"availableDate\":\"2025-01-09\"},{\"name\":\"ADSL2BOND\",\"medium\":\"COPPER\",\"group\":\"IPDSL\",\"item\":\"ADSL+\",\"marketingSpeed\":\"12.0M/1.0M\",\"features\":[\"VOIP\"]},{\"name\":\"DATA-ADSL\",\"medium\":\"COPPER\",\"group\":\"IPDSL\",\"marketingSpeed\":\"3.0M/384K\"},{\"name\":\"ADSL2+\",\"medium\":\"COPPER\",\"group\":\"HSMAX\",\"marketingSpeed\":\"3.0M/384K\"},{\"name\":\"ADSL\",\"medium\":\"COPPER\",\"group\":\"HSMAX\",\"marketingSpeed\":\"1.0M/128K\"},{\"group\":\"Smartvoice\",\"features\":[\"VOIP\"]}]}');
                res.setStatusCode(200);
                return res;
            }
            
        }
    }
}