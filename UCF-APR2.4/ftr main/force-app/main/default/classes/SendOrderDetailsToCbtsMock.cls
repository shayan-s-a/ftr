public class SendOrderDetailsToCbtsMock implements HttpCalloutMock {
    public String ratesResp = '{"SFOrderFA":{"SFOrderNumber":"10100440","OrderType":"New Installation","VendorId":"CBTS","VendorName":"CBTS","SFOrderFADetails":{"FAStatusCode":"200","FAStatus":"SUCCESS","FAStatusDate":"2023/05/31"}}}';
        public HttpResponse respond(HTTPRequest request) {
               
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('apikey', 'i.ApiKey_Header__c');
        response.setBody(ratesResp);
        response.setStatusCode(200);
        return response;  
    }
}