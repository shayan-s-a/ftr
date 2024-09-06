@isTest
global class ftr_SubmitGroupMemberOrderMock implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) { 
   /*     String soapRequest = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:snv="http://www.webserviceX.NET" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
	' <soapenv:Body>'+
	' <bons2:SubmitGroupOrderMemberResponse xmlns:bons030="http://esb.frontier.com/sharedType" xmlns:bons2="http://esb.frontier.com/CustomerOrderManagement">'+
	'		<submitGroupOrderMemberOutput>'+
	'			 <response>'+
	'			<bons030:correlationId>O678683332.01</bons030:correlationId>'+
	'			 <bons030:requestingApplication>CommercialAgent</bons030:requestingApplication>'+
	'				 <forEsbUseOnly>'+
	'				 <trackingId>712dbe09-b57e-45db-a9e4-22c8f1a6982a</trackingId>'+
	'			<correlationId>712dbe09-b57e-45db-a9e4-22c8f1a6982a</correlationId>'+
	'		 </forEsbUseOnly>'+
	'		<operationStatus>TRUE</operationStatus>'+
	'	 <executionStatusMessage>'+
	'			<severity>INFO</severity>'+
	'			<service>CustomerOrderManagement</service>'+
	'			<operation>SubmitGroupOrderMember</operation>'+
	'					 <operationStatusCode>000-000-0000</operationStatusCode>'+
	'					<operationStatusDescription>Success</operationStatusDescription>'+
	'					<executionStatusMessage>'+
	'					<severity>INFO</severity>'+
	'					<service>API_SubmitOrderManager</service>'+
	'					<operation>submitGroupOrderMember</operation>'+
	'					  <operationStatusCode>0</operationStatusCode>'+
	'					<operationStatusDescription>L/391575/QPGMR/RUN09192</operationStatusDescription>'+
	'				 <miscellaneousInformation>Exchange not found in RTRTM nor in SYDBEXTZ.</miscellaneousInformation>'+
	'				<executionStatusMessage>'+
	'					  <severity/>'+
	'					<service>API_SubmitOrderManager</service>'+
	'					 <operation>submitGroupOrderMember</operation>'+
	'					<operationStatusCode>39146</operationStatusCode>'+
	'					 </executionStatusMessage>'+
	'					 </executionStatusMessage>'+
	'					</executionStatusMessage>'+
	'					 </response>'+
	'				  <leadOrderId>'+
	'				<orderNumber>077999475</orderNumber>'+
	'				<environment>FT</environment>'+
	'				 </leadOrderId>'+
	'					 <groupMemberOrderId>'+
	'					<orderNumber>077999475</orderNumber>'+
	'					 <environment>FT</environment>'+
	'					</groupMemberOrderId>'+
	'					</submitGroupOrderMemberOutput>'+
	'					</bons2:SubmitGroupOrderMemberResponse>'+
	'				 </soapenv:Body>'+
	'			</soapenv:Envelope>';*/
		String soapRequest = '				<orderNumber>077999475</orderNumber>';
  		// Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(soapRequest);
       	System.debug('Request Header correlation id :'+req);
        	System.debug('APIGEE endpoint is  :'+req.getEndpoint());
        HttpResponse responseElement = new HttpResponse();
     /*   responseElement.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        responseElement.setHeader('Authorization', req.getHeader('Authorization'));
       	responseElement.setHeader('Correlationid',req.getHeader('Correlationid'));
        responseElement.setHeader('ApiKey',req.getHeader('ApiKey'));*/
        //String respBody ='{"orderDetails":{"documentNumber":3181333,"typeOfSr":"PSR","orderNumber":"3181333","pon":"FCA10010199P1N","projectIdentification":"","versionIdentification":"","desiredDueDate":"04/08/2019","requestType":"","orderActivity":"Change","supplementType":"","ccna":"","acna":"FTR","custAcctNbr":"1901586","customerName":"COUNTY OF RIVERSIDE","serviceRequestStatus":"COMPLETE","orderNpaNxx":"951652","orderCircuits":[{"circuitActivity":"New Installation","circuitDesignId":10062002,"circuitName":"45/CUXP/692404/ /FTNC/ ","circuitDetails":[{"circuitDesignId":10062002,"svcTypeLongDesc":"Identifies a Metro Ethernet Virtual Connection or Operator Virtual Connection (An association of two or more Physical Ethernet Access\r\nLinks)"}],"orderRuids":[{"ruidNbr":"1","ruidCircuitName":"45/L1XN/692403/ /FTNC/ ","ruidCircuitDesignId":10061996,"ruidNcCode":"KRFJ","ruidNciCode":"08LN9.1GE","effectiveDate":"03/29/2019","managedRouterIndicator":0},{"ruidNbr":"2","ruidCircuitName":"45/L1XN/663241/ /FTNC/ ","ruidCircuitDesignId":9766264,"ruidNcCode":"KRE0","ruidNciCode":"02LNF.A04","effectiveDate":"01/17/2018","managedRouterIndicator":0}]}]}}';
      	String respBody ='<soapenv:Envelopexmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"xmlns:xsd="http://www.w3.org/2001/XMLSchema"xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"xmlns:snv="http://www.webserviceX.NET"xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header/><soapenv:Body><bons2:SubmitGroupOrderMemberResponsexmlns:bons030="http://esb.frontier.com/sharedType"xmlns:bons2="http://esb.frontier.com/CustomerOrderManagement"><submitGroupOrderMemberOutput><response><bons030:correlationId>8171970140</bons030:correlationId><bons030:requestingApplication>VlocityOM</bons030:requestingApplication><forEsbUseOnly><trackingId>b6dc17ee-5f6f-4aad-839b-462b9985925b</trackingId><correlationId>b6dc17ee-5f6f-4aad-839b-462b9985925b</correlationId></forEsbUseOnly><operationStatus>TRUE</operationStatus><executionStatusMessage><severity>INFO</severity><service>CustomerOrderManagement</service><operation>SubmitGroupOrderMember</operation><operationStatusCode>000-000-0000</operationStatusCode><operationStatusDescription>Success</operationStatusDescription><executionStatusMessage><severity>INFO</severity><service>API_SubmitOrderManager</service><operation>submitGroupOrderMember</operation><operationStatusCode>0</operationStatusCode><operationStatusDescription>L/340426/QPGMR/RUN09192</operationStatusDescription></executionStatusMessage></executionStatusMessage></response><leadOrderId><orderNumber>078963542</orderNumber><environment>FT</environment></leadOrderId><groupMemberOrderId><orderNumber>078963542</orderNumber><environment>FT</environment></groupMemberOrderId></submitGroupOrderMemberOutput></bons2:SubmitGroupOrderMemberResponse></soapenv:Body></soapenv:Envelope>';   
    		String replaceIllegal=respBody.replaceAll('\n','').replaceAll('\r','');
      		responseElement.setBody(replaceIllegal);			
       		responseElement.setStatusCode(200);
       		System.debug('Response  ** : '+responseElement.getBody());
  			return responseElement;
        }
  

}