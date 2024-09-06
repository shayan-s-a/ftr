@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    String stage = '';
    global MockHttpResponseGenerator(String stage){
        this.stage = '\"'+stage+'\"';
    }
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        system.debug('EP :: '+req.getEndpoint()); 
        if(req.getEndpoint().contains('callout:SyncServiceOrderToM6')){//req.getEndpoint().contains('https://api-qat03.frontier.com/m6service/v1/orders')  
            res.setBody('{"next":{"$ref":"http://mssftr06.corp.pvt:8080/ords/ossdev/get_m6_order_info/get_salesforce_details/document_number/3369393?page=1"},"items":[{"document_number":3369393,"pon_or_order_number":"NCM10017553P4N-1","order_status":"Tasks Generated","order_leg":"-","order_stage":'+stage+',"dd_task_date":"2020-03-14T04:45:00Z","item_spec_id":1101,"last_cust_note":"CUST conf call with customer on Tuesday and he has asked that we keep this project open at the time and he is going back to the end user for further details and will get back with us."}]}');
        }
        res.setStatusCode(200);
        return res;
    }
}