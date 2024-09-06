public class FTRWSCVDInterface {
    
        class FTRWSCVDInterfaceException extends Exception {}
    
    private static String getPNUMEndPoint() {
        //TODO: configure the endpoint in the custom settings later
        //req.setEndPoint('callout:GetDSATAuthirize');
        WS_ESB_Settings__c esbSettings = WS_ESB_Settings__c.getInstance();
        String endpoint = esbSettings.CVD_GetPNums_Endpoint__c;
		//endpoint = end
        //String endpoint = 'http://tst-csdapi.ftr.com/CVDLookup/GetPNUMs?';
        return endpoint;
    }
    
    private static String getCVDRatesEndPoint() {
        //CVD_Service_Manager__c cvdSVCManager = CVD_Service_Manager__c.getInstance();
        WS_ESB_Settings__c esbSettings = WS_ESB_Settings__c.getInstance();
        String endpoint = '';
        if(Test.isRunningTest()) {
            endPoint = 'https://api-qat02.frontier.com/csdpats/v1/cvdlookup/rates';
        } else {
            endpoint = esbSettings.CVD_GetRates_Endpoint__c;
        }
        //String endpoint = 'http://tst-csdapi.ftr.com/CVDLookup/GetRates?';
        return endpoint;
    }
    
    private static String getApigeeToken() {
        String apigeeToken = '';
         if(Test.isRunningTest()) {
            apigeeToken = '12345567';
        } else {
        WS_ESB_Settings__c esbSettings = WS_ESB_Settings__c.getInstance();
        apigeeToken = esbSettings.Apigee_Token__c;
        System.debug('Apigee token for cvd:' + apigeeToken);
        }
        return apigeeToken; //uncomment this before deployment
    }
    
    @testVisible
    private static String getAuthorizationHeader() {
      
        
        String authorizationHeader = ''; 
        if(Test.isRunningTest()) {
            authorizationHeader = 'Basic ' + 'fjhajfh';
        } else {
            Blob headerValue = Blob.valueOf(WS_ESB_Settings__c.getOrgDefaults().HDR_Authorization__c);
            System.debug('Apigee authorizationHeader for CVD service:' + WS_ESB_Settings__c.getOrgDefaults().HDR_Authorization__c);
            authorizationHeader ='Basic ' + EncodingUtil.base64Encode(headerValue);
        }
        
        
      	return authorizationHeader;
    }
    
    public static String getPNUMs(String acna) {
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', getAuthorizationHeader());
        
		String endpoint = getPNUMEndPoint();
        endpoint = endpoint + 'ACNA=' + acna;
        System.debug('Get pnums endpoint:' + endpoint);
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(2 * 60 * 1000); 
        req.setHeader('Content-Type', 'application/json');
        String apiKey = getApigeeToken();
        req.setHeader('apikey', apiKey);
        
        Http httpCls = new Http();
        HttpResponse response = httpCls.send(req);
        if(response.getStatusCode() == 200){            
               system.debug('Successfully retrieving PNUMs from the CVD database');
            String pNumsResponse = response.getBody();//.replace('"','');
              system.debug('Get PNums actual response : '+pNumsResponse);
            return pNumsResponse;
           }
        else{
            System.debug('@Get PNUMs request failed with StatusCode'+response.getStatusCode());
            System.debug('@Get PNUMs request failed with Status:'+response.getStatus());
            return null;
        }
        
    }
    
     public static FTRWSCVDRatesResponse getCVDRates(FTRWSCVDRatesRequest request){
       	HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', getAuthorizationHeader());
        String endPoint = getCVDRatesEndPoint();
        System.debug('Get cvd rates endpoint:' + endpoint);
        req.setEndPoint(endPoint);
        req.setMethod('POST');
        req.setTimeout(2 * 60 * 1000); 
        req.setHeader('Content-Type', 'application/json');
        String apiKey = getApigeeToken();
        req.setHeader('apikey', apiKey);

         String body= JSON.serialize(request);
         System.debug('CVD Request for getRates'+body);
         req.setBody(body);
        Http httpCls = new Http();
        HttpResponse response = httpCls.send(req);
         FTRWSCVDRatesResponse cvdResponse = new FTRWSCVDRatesResponse();
        if(response.getStatusCode() == 200){            
            system.debug('Get CVD Product rates success response: '+response.getBody());
            System.debug('Deserialised response: '+(FTRWSCVDRatesResponse) System.JSON.deserialize(response.getBody(), FTRWSCVDRatesResponse.class));
            cvdResponse = (FTRWSCVDRatesResponse) System.JSON.deserialize(response.getBody(), FTRWSCVDRatesResponse.class);
			//cvdResponse.addressId = request.addressId;
            //cvdResponse.quoteLineId = request.quoteLineId;            
                return cvdResponse;
        } else if(response.getStatusCode() == 503) {
            return cvdResponse;
        }
        else{
            System.debug('Failed CVD GetRates StatusCode: '+response.getStatusCode());
                        System.debug('Failed CVD GetRates Status: '+response.getStatus());
            cvdResponse = (FTRWSCVDRatesResponse) System.JSON.deserialize(response.getBody(), FTRWSCVDRatesResponse.class); 

            return cvdResponse;
        }
    }


}