@isTest
global class ftr_OssApiCallOutMock implements HttpCalloutMock {
   
  global HTTPResponse respond(HTTPRequest req) {   
     
         System.debug('Endpoint : '+req.getEndpoint());
  			System.debug('correlation id ** : '+req.getHeader('Correlationid'));
      	System.debug('Authorization ** : '+req.getHeader('Authorization'));
      System.debug('UserName ** : '+req.getHeader('UserName'));
        System.debug('Endpoint  ** : '+req.getEndpoint());
       HttpResponse responseElement = new HttpResponse();
      
                //  *responseElement.setEndpoint('https://c813d24618ae07aece6312da9ef6cd9d.m.pipedream.net');
        //   responseElement.setMethod('GET');
           responseElement.setHeader('Content-Type', 'application/json');
      if(req.getHeader('Authorization') != null){
           responseElement.setHeader('Authorization', req.getHeader('Authorization'));
      }
           if(req.getHeader('OssAuthToken') != null){
               responseElement.setHeader('OssAuthToken',req.getHeader('OssAuthToken'));  //from Custom Meta data types
           }
             if(req.getHeader('UserName') != null){
                  responseElement.setHeader('UserName', req.getHeader('UserName')); //from Custom Meta data types
             }
      if(req.getHeader('Correlationid') != null){
                  responseElement.setHeader('Correlationid',req.getHeader('Correlationid'));
             }
             if(req.getHeader('ApiKey') != null){
                 	responseElement.setHeader('ApiKey',req.getHeader('ApiKey'));
             }
         // responseElement.setTimeout(100000);
           
            responseElement.setHeader('Content-Length', '0' );
           
    //  responseElement.setBody('{"next":{"$ref":"http://mssftr06.corp.pvt:8080/ords/ossdev/get_m6_order_info/get_salesforce_details/document_number/3369393?page=1"},"items":[{"document_number":3369393,"pon_or_order_number":"NCM10017553P4N-1","order_status":"Tasks Generated","order_leg":"-","order_stage":stage1,"dd_task_date":"2020-03-14T04:45:00Z","item_spec_id":1101,"last_cust_note":"CUST conf call with customer on Tuesday and he has asked that we keep this project open at the time and he is going back to the end user for further details and will get back with us."}]}');
    String respBody ='{"orderDetails":{"documentNumber":3181333,"typeOfSr":"PSR","orderNumber":"3181333","pon":"FCA10010199P1N","projectIdentification":"","versionIdentification":"","desiredDueDate":"04/08/2019","requestType":"","orderActivity":"Change","supplementType":"","ccna":"","acna":"FTR","custAcctNbr":"1901586","customerName":"COUNTY OF RIVERSIDE","serviceRequestStatus":"COMPLETE","orderNpaNxx":"951652","orderCircuits":[{"circuitActivity":"New Installation","circuitDesignId":10062002,"circuitName":"45/CUXP/692404/ /FTNC/ ","circuitDetails":[{"circuitDesignId":10062002,"svcTypeLongDesc":"Identifies a Metro Ethernet Virtual Connection or Operator Virtual Connection (An association of two or more Physical Ethernet Access\r\nLinks)"}],"orderRuids":[{"ruidNbr":"1","ruidCircuitName":"45/L1XN/692403/ /FTNC/ ","ruidCircuitDesignId":10061996,"ruidNcCode":"KRFJ","ruidNciCode":"08LN9.1GE","effectiveDate":"03/29/2019","managedRouterIndicator":0},{"ruidNbr":"2","ruidCircuitName":"45/L1XN/663241/ /FTNC/ ","ruidCircuitDesignId":9766264,"ruidNcCode":"KRE0","ruidNciCode":"02LNF.A04","effectiveDate":"01/17/2018","managedRouterIndicator":0}]}]}}';

        String replaceIllegal=respBody.replaceAll('\n','').replaceAll('\r','');
      responseElement.setBody(replaceIllegal);
     
      System.debug('Response  ** : '+responseElement);
      		responseElement.setStatusCode(200);
       Map<String,Object> provisioningOrderDetailsMap=new  Map<String,Object>();
      
            return responseElement;
      //  response.put('response_x', responseElement); 
   }
}