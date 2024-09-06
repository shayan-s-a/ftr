@isTest
global class ftr_DPIRCC360Mock implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) { 
       
       string reqBody='{"communicationPreference":"SMS","lineOfBusiness":"BUSINESS","phones":[{"phoneType":"Mobile","isPrimary":"true"}],"emails":[{"isPrimary":"true"}],"accountLifeCycle":"Customer","contact":{"GivenAndFamilyName":{"familyName":"Test Run","givenName":"RC"}},"address":{"environment":"FT","controlNumber":"192536"},"GivenAndFamilyName":{"familyName":"Test Run","givenName":"RC"},"businessName":"GRANITE TELECOM"}';
       HttpRequest request = new HttpRequest();
       request.setMethod('POST'); // Set the HTTP method
        request.setHeader('Content-Type', 'application/json'); 
        request.setBody(reqBody);

        HttpResponse responseElement = new HttpResponse();

        String respBody ='{"links":[{"url":"https://api-qat01.frontier.com/prospect-management/v2/prospect","verb":"POST","type":"Resource"}],"payload":{"phones":[],"emails":[],"partyPersonRowId":"67421532","serviceAddressId":"76311815","accountUUID":"da598921-6baf-493a-9c43-521742d8b6b4","partyAccountRowId":"67421531"}}';   
        
       responseElement.setBody(respBody);      
       responseElement.setStatusCode(200);
       System.debug('Response  ** : '+responseElement.getBody());
       return responseElement;
        }
  

}