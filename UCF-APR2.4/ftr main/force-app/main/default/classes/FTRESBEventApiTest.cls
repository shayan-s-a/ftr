@isTest
public class FTRESBEventApiTest {

    @isTest
    static void myUnitTest() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('ESB Event'));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.addHeader('httpMethod', 'POST'); 
        req.requestUri = '/services/apexrest/esbeventapi/';       
        String postData = '{"Header": {"name": "OrderComplete","domain": "Quote","subType": "Order","source": "DPI","priority": "1","expiration": "24","id": "4184060273","correlationId": "F9C82001-966D-1A81-909D-0004AC1EA1AD","timestamp": "2022-05-09T12:37:23-05:00","property": ""},"Data": [{"applicationName": "EOC","identification": [{"key": "omOrderId","value": "1000306600"}]}]}';
        req.requestBody = Blob.valueof(postData);
        System.debug('requestbody'+postData);
        
        RestContext.request = req; 
        FTRESBEventApi.newEvent();
        RestContext.response= res;
        Test.stopTest();
    }
}