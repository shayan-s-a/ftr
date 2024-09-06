@isTest
global class ftr_StageGroupOrderMock implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
   
		String soapRequest = '{"orderStageCode":"END","dpiOrderId":{"orderNumber":"079111602","environment":"FT"}}';
  		// Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(soapRequest);
       	System.debug('Request Header correlation id :'+req);
        	System.debug('APIGEE endpoint is  :'+req.getEndpoint());
        HttpResponse responseElement = new HttpResponse();
		
       		responseElement.setStatusCode(200);
       		System.debug('Stage order response  ** : '+responseElement.getBody());
  			return responseElement;
        }
  

}