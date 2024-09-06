@isTest
global class ftr_ResourceManagementMock implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
 
		String soapRequest = '				<orderNumber>077999475</orderNumber>';
  		// **Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(soapRequest);
       	System.debug('Request Header correlation id :'+req);
        	System.debug('APIGEE endpoint is  :'+req.getEndpoint());
        HttpResponse responseElement = new HttpResponse();
          	String respBody ='<soapenv:Envelopexmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"xmlns:xsd="http://www.w3.org/2001/XMLSchema"xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"xmlns:snv="http://www.webserviceX.NET"xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header/><soapenv:Body><bons2:SubmitGroupOrderMemberResponsexmlns:bons030="http://esb.frontier.com/sharedType"xmlns:bons2="http://esb.frontier.com/CustomerOrderManagement"><submitGroupOrderMemberOutput><response><bons030:correlationId>8171970140</bons030:correlationId><bons030:requestingApplication>VlocityOM</bons030:requestingApplication><forEsbUseOnly><trackingId>b6dc17ee-5f6f-4aad-839b-462b9985925b</trackingId><correlationId>b6dc17ee-5f6f-4aad-839b-462b9985925b</correlationId></forEsbUseOnly><operationStatus>TRUE</operationStatus><executionStatusMessage><severity>INFO</severity><service>CustomerOrderManagement</service><operation>SubmitGroupOrderMember</operation><operationStatusCode>000-000-0000</operationStatusCode><operationStatusDescription>Success</operationStatusDescription><executionStatusMessage><severity>INFO</severity><service>API_SubmitOrderManager</service><operation>submitGroupOrderMember</operation><operationStatusCode>0</operationStatusCode><operationStatusDescription>L/340426/QPGMR/RUN09192</operationStatusDescription></executionStatusMessage></executionStatusMessage></response><leadOrderId><orderNumber>078963542</orderNumber><environment>FT</environment></leadOrderId><groupMemberOrderId><orderNumber>078963542</orderNumber><environment>FT</environment></groupMemberOrderId></submitGroupOrderMemberOutput></bons2:SubmitGroupOrderMemberResponse></soapenv:Body></soapenv:Envelope>';   
    		String replaceIllegal=respBody.replaceAll('\n','').replaceAll('\r','');
      		responseElement.setBody(replaceIllegal);			
       		responseElement.setStatusCode(200);
       		System.debug('Response  ** : '+responseElement.getBody());
  			return responseElement;
        }
  

}