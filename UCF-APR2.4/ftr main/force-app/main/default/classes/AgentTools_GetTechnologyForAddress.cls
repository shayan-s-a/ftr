public class AgentTools_GetTechnologyForAddress{
    // version 1
    
    private static String getFBVApigeeToken() {
        String apigeeToken = '';
        WS_ESB_Settings__c esbSettings = WS_ESB_Settings__c.getInstance();
        apigeeToken = esbSettings.FBV_Apigee_Token__c;
        if (Test.isRunningTest()) {
            apigeeToken = '1234';
        }
        return apigeeToken; 
    }
    public static Boolean getTechnologyForAddress(String evCode,Integer serviceControlNumber){
        try{
            String Endpoint = 'callout:GetTechnologyforAddress'+'?environmentcode='+evCode+'&samcontrolnumber='+serviceControlNumber;
           // String APIKey='MW35cUl3YX0F4V23qd9ZWGuVocmRz10o';
            String APIKey= getFBVApigeeToken();
            Boolean value_to_return = false;
            HttpRequest req = new HttpRequest();
            req.setEndPoint(Endpoint);
            req.setMethod('GET');
            req.setTimeout(2 * 60 * 1000); 
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('apikey', APIKey);
            Http httpCls = new Http();
            HttpResponse response = httpCls.send(req);
            system.debug('response : '+ response.getBody());
            if(response.getStatusCode() ==200 ){
                AgentTools_GetTechForAddressRespJson respoJsn = (AgentTools_GetTechForAddressRespJson) System.JSON.deserialize(response.getBody(), AgentTools_GetTechForAddressRespJson.class);
                for(AgentTools_GetTechForAddressRespJson.cls_technology c:respoJsn.technology){
                    if(c.Name=='GPON' && c.features.contains('OVOIP')){
                        value_to_return = true;
                        break;
                    }              
                }
            }
            else{value_to_return=false;}
            return value_to_return;
        }
        Catch(Exception e){
            System.debug('Exception  : '+ e);
            System.debug('Exception Message : '+ e.getMessage());
            System.debug('Exception Stack Trace: '+ e.getStackTraceString());
            return False;
            
        }
        
    }
    class cls_technology {
        public String name;	//XPON
        public String[] features;
    }
    
    
    
}