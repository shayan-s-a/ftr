public class ServiceOrderStageVlocityM6 {
 	public static String apikey;  
    public static Boolean runningInASandbox;
    
    public static HttpResponse retrieveM6SOStage(String orderNum){
        if(ServiceOrderStageVlocityM6.runningInASandbox == null){
            Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
            ServiceOrderStageVlocityM6.runningInASandbox = org.IsSandbox;
        }
        if(ServiceOrderStageVlocityM6.apikey == null){            
            for(IntegrationAPIConfig__mdt mdt : [select MasterLabel, ApiKey__c   from IntegrationAPIConfig__mdt where MasterLabel IN ('ServiceOrderApiKey_SB','ServiceOrderApiKey_PROD')]){
                if(ServiceOrderStageVlocityM6.runningInASandbox && mdt.MasterLabel == 'ServiceOrderApiKey_SB')
                    ServiceOrderStageVlocityM6.apikey = mdt.ApiKey__c;
                else if(!ServiceOrderStageVlocityM6.runningInASandbox && mdt.MasterLabel == 'ServiceOrderApiKey_PROD')
                    ServiceOrderStageVlocityM6.apikey = mdt.ApiKey__c;
            }
            if(Test.isRunningTest())
                ServiceOrderStageVlocityM6.apikey = 'test';
        }
        //Service_Order_Configuration__c soc = Service_Order_Configuration__c.getInstance('Settings');
        if(ServiceOrderStageVlocityM6.apikey == null){
            throw new ServiceOrderStage_Ctrl.ServiceOrderStage_Exception(JSON.serialize(new ServiceOrderStage_Ctrl.ErrorMessage('Custom MetaData Issue','Custom MetaData is not configured with name ServiceOrderApiKey')));
        }
        /*Blob beforeblob = Blob.valueOf(soc.UserName__c+':'+soc.Password__c);
        string authorization = EncodingUtil.base64Encode(beforeblob);*/
        system.debug('ServiceOrderStageVlocityM6.apikey :: '+ServiceOrderStageVlocityM6.apikey);
        Http http = new Http(); // SyncServiceOrderToM6 
        HttpRequest request = new HttpRequest();  
        //request.setEndpoint(soc.EndPoint__c+orderNum);
        request.setEndpoint('callout:SyncServiceOrderToM6/'+orderNum);
        request.setMethod('GET');
        //request.setHeader('Authorization','Basic '+authorization);
        request.setHeader('apikey',ServiceOrderStageVlocityM6.apikey/*soc.ApiKey__c*/);
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response = http.send(request);
        
        return response;
    }
    
    
}