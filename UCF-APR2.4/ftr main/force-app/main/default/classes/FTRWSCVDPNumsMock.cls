@isTest
global class FTRWSCVDPNumsMock implements HttpCalloutMock {
    // Implement this interface method
    //String reqbearer = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJDcmVhdGVkIjoiMjAxOS0xMC0zMFQxNDozMTozMS41NzQ1MDUyLTA0OjAwIiwiTmlja25hbWUiOiIsIFZGTyBBcHBsaWNhdGlvbiIsIkZpcnN0TmFtZSI6IlZGTyBBcHBsaWNhdGlvbiIsIkxhc3ROYW1lIjoiIiwiRW1haWxBZGRyZXNzIjoic3RhZ2VAc2lmdC50ZXN0IiwiTGFuSWQiOiJhcHA6IHZmbyBhcHBsaWNhdGlvbiIsIkdyb3VwSWRzIjpbMTcsMjNdLCJHcm91cE5hbWVzIjpbIkFwcGxpY2F0aW9ucyIsIlZGTyBBcHBsaWNhdGlvbiJdLCJSaWdodHMiOlszM10sIklkIjoyODM3NCwiVG9rZW5JZCI6MjQ2ODJ9.IccF4Ohx7Y67zoK7UO0izvX_Zkcrlpej6wCMR9Rdjdf';
    String pnumsResp = '{"ACCNA": "GIM", "PNum": "EIA001AKQSCM326,EIA001AKQSCM327,EIA001AKQSCM328,EIA001AKQSCM329"}';
    String reqresp = 'TEST STRING';
    global HttpResponse respond(HTTPRequest request) {
        // Create a mock pnums response
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('apikey', 'i.ApiKey_Header__c');
        response.setBody(pnumsResp);
        response.setStatusCode(200);
        return response;  
    }
}