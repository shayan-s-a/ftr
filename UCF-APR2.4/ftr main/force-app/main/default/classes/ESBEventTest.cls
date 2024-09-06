@isTest
public class ESBEventTest {

    @TestSetup
    static void makeData(){
         Order o = ftr_TestDataFactory.getOrders(1)[0];
        insert o;
    }
    @isTest
    static void myUnitTest() {
        Order order = [SELECT Id, OrderNumber FROM Order LIMIT 1]; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('ESB Event'));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST'); 
        req.requestUri = '/services/apexrest/esbeventapi/';       
        String postData = '{';
        postData +='"Header": {';
        postData +='"correlationId": "CB710001-86BC-1A68-909A-0004AC1B518D",';
        postData +='"domain": "businessorder",';
        postData +='"expiration": "",';
        postData +='"id": "CB710001",';
        postData +='"name": "UCFOrderPOIssued",';
        postData +='"priority": "1",';
        postData +='"property": "",';
        postData +='"source": "InfiniumApi",';
        postData +='"subType": "Notification",';
        postData +='"timestamp": "2024-03-15T09:06:15-05:00"';
        postData +='},';
        postData +='"Identities": [';
        postData +='{';
        postData +='"applicationName": "EOC",';
        postData +='"identification": [';
        postData +='{';
        postData +='"key": "projectId",';
        postData +='"value": "8048c1d3-d9f4-45af-bcb3-ac9d93a6e2ec"';
        postData +='},';
        postData +='{';
        postData +='"key": "referenceId",';
        postData +='"value": "'+order.OrderNumber+'-2718-46e5-8c5a-18b620772ac5"';
        postData +='},';
        postData +='{';
        postData +='"key": "OLI",';
        postData +='"value": "[{\\"externalId\\":\\"1A68-909A\\",\\"requisitionNumber\\":\\"10001-86BC\\",\\"purchaseOrderNumber\\":\\"<4AC1B518\\",\\"purchaseOrderLine\\":\\"1\\"},';
        postData +='{\\"externalId\\":\\"1A68-909A\\",\\"requisitionNumber\\":\\"10001-86BC\\",\\"purchaseOrderNumber\\":\\"<4AC1B518\\",\\"purchaseOrderLine\\":\\"1\\"}]"';
        postData +='}';
        postData +=']';
        postData +='}';
        postData +=']';
        postData +='}';
        req.requestBody = Blob.valueOf(postData);
        System.debug('requestbody'+postData);
        
        RestContext.request = req; 
        FTRESBEventApi.newEvent();
        RestContext.response= res;
        Test.stopTest();
    }
}