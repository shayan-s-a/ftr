@isTest
public class ftr_EOCShippingDetailsWebServiceMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message": "Success"}'); // Simulate the expected response
        res.setStatusCode(200); // Set the HTTP status code
        return res;
    }
}