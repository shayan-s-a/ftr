global class AgentTools_GetTechforAdrRespMock implements HttpCalloutMock{
    // version 1 
 global HTTPResponse respond(HTTPRequest request) {
     //String resp = '{"environment": "FT","controlNumber": "536670","technology": [{"name": "XPON","features": ["VOIP"]},{"name": "GPON","features": ["VOIP","OVOIP"]},{"name": "BPON","features": ["VOIP","POTS"]}],"success": true}';
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('apikey', 'i.ApiKey_Header__c');
        //response.setHeader('SIFT-Token', 'Bearer - token');
        response.setBody('{"environment": "FT","controlNumber": "536670","technology": [{"name": "XPON","features": ["VOIP"]},{"name": "GPON","features": ["VOIP","OVOIP"]},{"name": "BPON","features": ["VOIP","POTS"]}],"success": true}');
                         response.setStatusCode(200);
        return response; 
        
    }
}