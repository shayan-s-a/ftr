@isTest
global class ftr_ReserveTnRestAPIMock implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
   
		String soapRequest = '{"environmentCode":"CT","action":"RESERVE","daysToReserve":"180","poolType":"FICT","quoteNumber":"vlocity order","TelephoneNumber":"8601962490"}';
  		// Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(soapRequest);
       	System.debug('Request Header correlation id :'+req);
        	System.debug('APIGEE endpoint is  :'+req.getEndpoint());
        HttpResponse responseElement = new HttpResponse();
		
       		responseElement.setStatusCode(200);
       		System.debug('Reserve tn response ** : '+responseElement.getBody());
  			return responseElement;
        }
  

}