@isTest
global class FTRWSDSATAddressControllerPostMock implements HttpCalloutMock  {
 global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('apikey', 'i.ApiKey_Header__c');
        response.setHeader('SIFT-Token', 'Bearer - token');
        response.setBody('{ "AQRecordId": null,"CPQId": null,"OpportunityId": null,"BusinessName": null,"Id": 1692264,"VFORecordId": null,"M6OrderNumber": null,"CreatedBy": "VFO user vyy965 and company Vlocity", "CreatorEmail": "SIFT.App.Support@ftr.com","CreatedById": 30890,"Opened": "2021-05-20T17:15:36.8891224-04:00", "InFootprint": true, "Market": "E","Level": "a","Products":    ["EIA","EVPL", "ELAN","IPVPN","Jumbo Frames","EPL","Connect Cloud","EPath","EReach"],"WireCenterCLLI": "OZONTXXA","SiteName": null,"WireCenterQoS": "Platinum","WireCenterSpeed": "1000MB","LitBuilding": false,"FiberDistance": "1079","CopperDistance": "5869","FiberTier": "1","CopperTier": "2","QualifiedAddress":    {"Address": "106 Medical Drive null","City": "Ozona","State": "TX","ZipCode": "76943","Latitude": 30.7221191,"Longitude": -101.2065615},"EReachProviders": [],"FiberQualification": "Qualified (max WC speed)","CopperQualification": "Qualified (up to 50MB)"}');
        response.setStatusCode(200);
        return response; 
        
    }
}