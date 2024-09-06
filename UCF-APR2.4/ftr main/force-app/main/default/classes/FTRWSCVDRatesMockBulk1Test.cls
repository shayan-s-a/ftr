/**
 * @description       : This is the mock test class:
 *      FTRWSMultipleFileUploaderTest
 * @author            : Vyshnavi Yalamareddy
 * @version           : 1
**/

@isTest
public class FTRWSCVDRatesMockBulk1Test implements HttpCalloutMock {
   public String ratesResp = '{"Address":{"Address": "1 BROOKLYN RD","City":"FREEVILLE","StateCd":"NY","ZipCd":"13068","UsocTier":"3","lookUpUsed":"Address"},"Rate":null}';
        public HttpResponse respond(HTTPRequest request) {
               
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('apikey', 'i.ApiKey_Header__c');
        response.setBody(ratesResp);
        response.setStatusCode(200);
        return response;  
    }
}