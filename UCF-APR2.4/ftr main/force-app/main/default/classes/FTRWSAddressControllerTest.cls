/**
 * @description       : This test class covers the following Apex classes:
 *      FTRWSAddressController
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 6
**/
@isTest
public class FTRWSAddressControllerTest {
    @testsetup
    static void setupTestData() {
        WS_ESB_Settings__c setting = new WS_ESB_Settings__c(Apigee_Token__c = 'r3MUlqybToeRGmBgw1YSW7FnDUTTwWV7',
                                                            EC_ApplicationID__c = 'SFDC', EC_EmployeeID__c = '123456', EC_UserID__c = 'ESB_REG');
        insert setting;
    }
    
    
    @isTest
    public static void testGetSuggestions() {
        
        
        Test.startTest(); 
        String input = '1401 S MacArthur Blvd';
        Test.setMock(HttpCalloutMock.class, new GoogleSuggestionsTestMock());
        String actualValue = FTRWSAddressController.getSuggestions(input);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetPlaceDetails() {
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GooglePlaceDetailsTestMock());
        String placeId = 'ChIJt2EXx36DToYRW6Am0ycK0BI'; 
        String actualValue = FTRWSAddressController.getPlaceDetails(placeId);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetPlaceDetailsByLatLng() {
        
         Id carrierSerRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;  
      Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierSerRecId;
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleLatLngTestMock());
        String lat = '40.714224'; 
        String lng = '-73.961452';
        FTRWSAddressController.getPlaceDetailsWithLatLng(opp.Id, lat, lng);
        Test.stopTest();
    }    
    
    @isTest
    //Need to implement this later once DSAT response object becomes available
    //Need to pass the Opportunity id also
    public static void testGet_SaveAddress(){
        String gAddressStr = '{"actionStr":"CREATE","streetNo":"2001","streetName":"Solar Drive","city":"Oxnard", '+ 
            '"state":"California","unitNo":"","zipcode":"93036","opportunityId":"0065500000IyiJQAAZ","gLat":34.2203155,"gLng":-119.1458787}';
        Test.startTest();
        
        FTRWSAddressController.get_SaveAddress(gAddressStr);
        Test.stopTest();
    }
    
    @isTest
    public static void testGet_UpdateAddress() {
        Id carrierSerRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;  
        Account acc = new Account();
        acc.Name='testAccount';        
        acc.RecordTypeId = carrierSerRecId;
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        String gAddressStr = '{"actionStr":"CREATE","streetNo":"2001","streetName":"Solar Drive","city":"Oxnard", '+ 
            '"state":"California","unitNo":"","zipcode":"93036","gLat":34.2203155,"gLng":-119.1458787}';
        FTRWSGoogleAddress gAddress = (FTRWSGoogleAddress)JSON.deserialize(gAddressStr, FTRWSGoogleAddress.class);
        FTRWSAddress__c  address = new FTRWSAddress__c();
        address.Street_Number__c = gAddress.streetNo;
        address.Street_Name__c = gAddress.streetName;
        address.Street_Number__c = gAddress.streetNo;
        address.City__c = gAddress.city;
        address.State__c = gAddress.state;
        address.Zip_Code__c = gAddress.zipcode;
        address.Opportunity_ID__c = opp.id;
        address.G_Latitude__c = gAddress.gLat;
        address.G_Longitude__c = gAddress.gLng;
        
        insert address;
        
        //*************************************
        
        //FTRWSAddress__c address =[select id from FTRWSAddress__c limit 1];
        ID addressId = address.Id;
        
        FTRWSDPIAddressResponse dpiData = new FTRWSDPIAddressResponse();
        dpiData.clliCode = 'ELRICAXFDS0';
        dpiData.svcControlNo = '5850005';
        dpiData.wirecenter = '805988';
        dpiData.latitude = '+034.220261';
        dpidata.longitude = '-119.145638';
        dpidata.streetName = '2001';
        dpiData.streetNumber = 'Solar Drive';
        dpiData.unit = '1';
        dpiData.cityName = 'Oxnard';
        dpiData.state = 'California';
        dpiData.zipCode = '93036';
        dpiData.status = 'SUCCESS';
        address.Comments__c = '';
        FTRWSDSATAddressResponse dsatData = getDSATDummyData();
        
        Test.startTest();
        FTRWSAddressController.get_UpdateAddress(addressId, 'UPDATE_DPI', dpiData, null);
        FTRWSAddressController.get_UpdateAddress(addressId, 'UPDATE_DPI_SERVICE', dpiData, null);
        FTRWSAddressController.get_UpdateAddress(addressId, 'UPDATE_DSAT', null, dsatData);
        Test.stopTest();
        
        
        
    }
    
    private static FTRWSDSATAddressResponse getDSATDummyData() {
        
        FTRWSDSATAddressResponse dsatResponse = new FTRWSDSATAddressResponse();
        
        dsatResponse.businessName = '';
        
        dsatResponse.copperDistance = '9996';
        dsatResponse.copperQualification = 'BDT';//'Qualified (up to 50MB)';
        dsatResponse.copperTier = '2';
        
        dsatResponse.fiberDistance = '393';
        dsatResponse.fiberQualification = 'BDT';//'Qualified (max WC speed)';
        dsatResponse.fiberTier = '1';
        
        dsatResponse.createdBy = 'Hemantha Gujjar';
        dsatResponse.createdById = 'hgg395';
        dsatResponse.creatorEmail = 'hgg395@ftr.com';
        
        dsatResponse.inFootprint = true;
        dsatResponse.dsatId = '1655092';
        dsatResponse.market = 'D';
        dsatResponse.level = 'b';
        dsatResponse.litBuilding = true;
        dsatResponse.opened = '2021-05-17T13:56:16.6292161-04:00';
        dsatResponse.products = 'EIA, EVPL, ELAN, IPVPN, Jumbo Frames, EPL, Connect Cloud, EPath, EReach';
        
        dsatResponse.siteName = '';
        dsatResponse.latitude = '34.220407916631316';
        dsatResponse.longitude = '-119.14580691804325';
        
        dsatResponse.m6OrderNumber = '';
        dsatResponse.vfoRecordId = '';
        
        dsatResponse.wireCenterCLLI = 'ELRICAXF';
        dsatResponse.wireCenterQoS = 'Platinum';
        dsatResponse.wireCenterSpeed = '1000MB';
        return dsatResponse;
    }
    
    
    @isTest
    public static void testGetDPIValResultWithAddressId() {
        Id carrierSerRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;  
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierSerRecId;
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        String gAddressStr = '{"actionStr":"CREATE","streetNo":"2001","streetName":"Solar Drive","city":"Oxnard", '+ 
            '"state":"California","unitNo":"","zipcode":"93036","gLat":34.2203155,"gLng":-119.1458787}';
        FTRWSGoogleAddress gAddress = (FTRWSGoogleAddress)JSON.deserialize(gAddressStr, FTRWSGoogleAddress.class);
        FTRWSAddress__c  address = new FTRWSAddress__c();
        address.Street_Number__c = gAddress.streetNo;
        address.Street_Name__c = gAddress.streetName;
        address.Street_Number__c = gAddress.streetNo;
        address.City__c = gAddress.city;
        address.State__c = gAddress.state;
        address.Zip_Code__c = gAddress.zipcode;
        address.Opportunity_ID__c = opp.id;
        address.G_Latitude__c = gAddress.gLat;
        address.G_Longitude__c = gAddress.gLng;
        
        insert address;
        
        //*************************************************************
        // FTRWSAddress__c address =[select id from FTRWSAddress__c limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSDPIPredictiveAddressValResultMock());
        FTRWSAddressController.getDPIValResultWithAddressId(address.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetDPIValResultWithAddressIdSingle() {
        Id carrierSerRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;  
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierSerRecId;
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        String gAddressStr = '{"actionStr":"CREATE","streetNo":"2001","streetName":"Solar Drive","city":"Oxnard", '+ 
            '"state":"California","unitNo":"","zipcode":"93036","gLat":34.2203155,"gLng":-119.1458787}';
        FTRWSGoogleAddress gAddress = (FTRWSGoogleAddress)JSON.deserialize(gAddressStr, FTRWSGoogleAddress.class);
        FTRWSAddress__c  address = new FTRWSAddress__c();
        address.Street_Number__c = gAddress.streetNo;
        address.Street_Name__c = gAddress.streetName;
        address.Street_Number__c = gAddress.streetNo;
        address.City__c = gAddress.city;
        address.State__c = gAddress.state;
        address.Zip_Code__c = gAddress.zipcode;
        address.Opportunity_ID__c = opp.id;
        address.G_Latitude__c = gAddress.gLat;
        address.G_Longitude__c = gAddress.gLng;
        
        insert address;
        
        //*************************************************************
        // FTRWSAddress__c address =[select id from FTRWSAddress__c limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSDPIPredictiveAddressValResultMockSingle());
        FTRWSAddressController.getDPIValResultWithAddressId(address.Id);
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
    public class FTRWSDPIPredictiveAddressValResultMockSingle implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{\"addresses\":[{\"addressKey\":\"61e94fe2-0ebf-464b-909c-a6a1ae41a5e6\",\"parentKey\":\"57db6a7a-73b3-4510-8e21-b68617f2db35\",\"address\":{\"addressLine1\":\"112 Plaza Dr\",\"addressLine2\":\"Ste 478\",\"city\":\"West Covina\",\"stateProvince\":\"CA\",\"zipCode\":\"91790-2805\"},\"parsedAddress\":{\"streetNumber\":\"112\",\"streetPreDirectional\":\"\",\"streetName\":\"Plaza\",\"streetSuffix\":\"Dr\",\"streetPostDirectional\":\"\",\"unitType\":\"Ste\",\"unitNumber\":\"478\",\"city\":\"West Covina\",\"stateProvince\":\"CA\",\"zipCodeBase\":\"91790\",\"zipCodePlus4\":\"2805\"},\"samRecords\":[{\"environment\":\"CZ\",\"controlNumber\":\"235756\"}],\"latitude\":34.06947,\"longitude\":-117.927343,\"isParent\":false,\"inFootprint\":true}],\"totalCount\":9171,\"links\":[{\"href\":\"/v1/AddressSearch/Predictive?address=112+Plaza+Dr%2c+478%2c+West+Covina%2c+CA%2c+91790&pageIndex=2&pageSize=10\",\"rel\":\"next\",\"verb\":\"GET\"},{\"href\":\"/v1/AddressSearch/Predictive?address=112+Plaza+Dr%2c+478%2c+West+Covina%2c+CA%2c+91790&pageIndex=918&pageSize=10\",\"rel\":\"last\",\"verb\":\"GET\"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    
    @isTest
    public static void testGetAddressValidationResults() {
        Id carrierSerRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;  
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierSerRecId;
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        String gAddressStr = '{"actionStr":"CREATE","streetNo":"2001","streetName":"Solar Drive","city":"Oxnard", '+ 
            '"state":"California","unitNo":"","zipcode":"93036","gLat":34.2203155,"gLng":-119.1458787}';
        FTRWSGoogleAddress gAddress = (FTRWSGoogleAddress)JSON.deserialize(gAddressStr, FTRWSGoogleAddress.class);
        FTRWSAddress__c  address = new FTRWSAddress__c();
        address.Street_Number__c = gAddress.streetNo;
        address.Street_Name__c = gAddress.streetName;
        address.Street_Number__c = gAddress.streetNo;
        address.City__c = gAddress.city;
        address.State__c = gAddress.state;
        address.Zip_Code__c = gAddress.zipcode;
        address.Opportunity_ID__c = opp.id;
        address.G_Latitude__c = gAddress.gLat;
        address.G_Longitude__c = gAddress.gLng;
        
        insert address;
        
        //*************************************************************
        // FTRWSAddress__c address =[select id from FTRWSAddress__c limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSDPIPredictiveAddressValResultMock());
        //ftr_addressBean addressBean = new ftr_addressBean();
        //FTRWSDPIAddressController.retreiveCustomerFacility(addressBean);
        FTRWSAddressController.getAddressValidationResults(address.Id);
        Test.stopTest();
    }
    
    
    public static testmethod void testGetDSATValResultWithAddressId() {
        Id carrierSerRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierSerRecId;
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        String gAddressStr = '{"actionStr":"CREATE","streetNo":"2001","streetName":"Solar Drive","city":"Oxnard", '+ 
            '"state":"California","unitNo":"","zipcode":"93036","gLat":34.2203155,"gLng":-119.1458787}';
        FTRWSGoogleAddress gAddress = (FTRWSGoogleAddress)JSON.deserialize(gAddressStr, FTRWSGoogleAddress.class);
        FTRWSAddress__c  address = new FTRWSAddress__c();
        address.Street_Number__c = gAddress.streetNo;
        address.Street_Name__c = gAddress.streetName;
        address.Street_Number__c = gAddress.streetNo;
        address.City__c = gAddress.city;
        address.State__c = gAddress.state;
        address.Zip_Code__c = gAddress.zipcode;
        address.Opportunity_ID__c = opp.id;
        address.G_Latitude__c = gAddress.gLat;
        address.G_Longitude__c = gAddress.gLng;
        
        insert address;
        
        
        //****************************************************************
        //FTRWSAddress__c address =[select id from FTRWSAddress__c limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSDSATAddressControllerPostMock());
        FTRWSAddressController.getDSATValResultWithAddressId(address.Id);
        Test.stopTest();
        
        
        //FTRWSDSATAddressControllerPostMock
    }
    
    public static testmethod void testGetDSATValResultWithAddressIdLat() {
        Id carrierSerRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierSerRecId;
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        String gAddressStr = '{"actionStr":"CREATE","streetNo":"2001","streetName":"Solar Drive","city":"Oxnard", '+ 
            '"state":"California","unitNo":"","zipcode":"93036","gLat":34.2203155,"gLng":-119.1458787}';
        FTRWSGoogleAddress gAddress = (FTRWSGoogleAddress)JSON.deserialize(gAddressStr, FTRWSGoogleAddress.class);
        
        FTRWSAddress__c  address1 = new FTRWSAddress__c();
        address1.Street_Number__c = gAddress.streetNo;
        address1.Street_Name__c = gAddress.streetName;
        address1.Street_Number__c = gAddress.streetNo;
        address1.City__c = gAddress.city;
        address1.State__c = gAddress.state;
        address1.Zip_Code__c = gAddress.zipcode;
        address1.Opportunity_ID__c = opp.id;
        address1.Latitude__c = null;
        address1.Longitude__c = null;
        
        insert address1;
        
        //****************************************************************
        //FTRWSAddress__c address =[select id from FTRWSAddress__c limit 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FTRWSDSATAddressControllerPostMock());
        FTRWSAddressController.getDSATValResultWithAddressId(address1.Id);
        address1.Zip_Code__c = '12345';
        update address1;
        Test.stopTest();
        //FTRWSDSATAddressControllerPostMock
    }
    
    
}