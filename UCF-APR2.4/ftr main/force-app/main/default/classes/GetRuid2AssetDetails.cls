public class GetRuid2AssetDetails {
    @TestVisible private static final String API_CONFIG_SETTINGS = 'OSSAPIAuthentication';
    @TestVisible private static Map<String, String> apiConfigMap=new Map<String,String>();
    @TestVisible private static IntegrationAPIConfig__mdt apiconfig;
    private static final String ERR_NULL_INPUT ='Null ApiKey/Timeout';
    public static String getRuid2Asset(List<M6ProvisionDetailsWrapper.OrderCircuits> orderCircuits) {
        String ruid2CircuitDesignId ;
        if (orderCircuits?.get(1)?.orderRuids != null) {
            for (M6ProvisionDetailsWrapper.OrderRuids ruid : orderCircuits.get(1).orderRuids) {
                if (ruid.ruidNbr == '2') {
                    ruid2CircuitDesignId = String.valueOf(ruid.ruidCircuitDesignId);
                    break;
                }
            }
        }
        return ruid2CircuitDesignId;
    }
    public class ftr_M6GetProvisioningOrderDetailsException extends Exception {}
    public static MACDRuid2Wrapper makeRuid2Callout(String ruidCircuitDesignId) {
        MACDRuid2Wrapper wrapper;
        try {
            List<IntegrationAPIConfig__mdt> apiConfigs = [SELECT Timeout__c, ApiKey__c,Authorization_Header__c ,Correlationid__c,OssAuthToken__c,UserName__c,Endpoint__c FROM IntegrationAPIConfig__mdt WHERE DeveloperName=: API_CONFIG_SETTINGS LIMIT 1];
            
            if ( !Test.isRunningTest() && (apiConfigs.isEmpty() || String.isBlank(apiConfigs[0].ApiKey__c) || apiConfigs[0].Timeout__c == null 
                                           || String.isBlank(apiConfigs[0].Correlationid__c)
                                           || String.isBlank(apiConfigs[0].OssAuthToken__c))) {
                                               
                                               throw new ftr_M6GetProvisioningOrderDetailsException(ERR_NULL_INPUT);
                                           }
            System.debug('apiconfig--'+apiConfigs);
            apiconfig=apiConfigs[0];
            
            // throw an exception if nothing is found, set the variable otherwise
            
            String Timeout=String.valueOf(apiConfig.Timeout__c);
            apiConfigMap.put('Timeout', Timeout);
            apiConfigMap.put('ApiKey', apiConfig.ApiKey__c);
            apiConfigMap.put('AuthHeader', apiConfig.Authorization_Header__c);
            apiConfigMap.put('Correlationid', apiConfig.Correlationid__c);
            apiConfigMap.put('OssAuthToken', apiConfig.OssAuthToken__c);
            apiConfigMap.put('UserName', apiConfig.UserName__c);
            
            Map<String,Object> ossAPICalloutMap =new  Map<String,Object>();
            Http http = new Http();
            String authorizationHeader ;
            String correlationId = apiConfigMap.get('Correlationid');
            String ossAuth = apiConfigMap.get('OssAuthToken');
            System.debug('authheader--'+apiConfigMap.get('AuthHeader'));
            if(apiConfigMap.get('AuthHeader') != null){  authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(Blob.valueOf(apiConfigMap.get('AuthHeader'))); 
                                                      }
            
            String KeyAPI = apiConfigMap.get('ApiKey');
            String username = apiConfigMap.get('UserName');
            //String timeout  = apiConfigMap.get('Timeout');  
            
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint('callout:OSSRUID2APIApigeeCredentials'+'/'+ruidCircuitDesignId);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);  
            request.setHeader('OssAuthToken',ossAuth);//from Custom Meta data types
            request.setHeader('UserName', apiConfigMap.get('UserName')); 
            request.setHeader('Correlationid',correlationId);//from Custom Meta data types
            request.setHeader('ApiKey', apiConfigMap.get('ApiKey'));
            request.setTimeout(120000);//THis should in Meta Data Configurable
            request.setHeader('Content-Length', '0' );
            //request.setHeader('Correlationid','');
            HTTPResponse m6Response = http.send(request);
            system.debug('res status code ' + m6Response.getStatusCode());
            system.debug('res body ' + m6Response.getBody());
            Map<String, Object> logOutput = new Map<String, Object>();
            Map<String, Object> logInput = new Map<String, Object> {
                    'response' => JSON.deserializeUntyped(m6Response.getBody()),
                    'interface' => 'GetRuid2AssetDetails',
                    'system' => 'M6',
                    'status' => m6Response.getStatus() == 'OK' ? 'Success' : 'Error',
                        'errorMessage' => m6Response.getStatusCode()  == 200 ? null : m6Response.getBody(),
                            'errorCode' => m6Response.getStatusCode()  == 200 ? null : m6Response.getStatusCode(),
                                'convertToXML' => false
                                };  
                                    APILogger log = new APILogger();
            log.createEntry(logInput, logOutput);
            
            if (m6Response.getStatusCode() == 200) {
                wrapper = MACDRuid2Wrapper.parse(m6Response.getBody());
                system.debug('wrapper ' + wrapper);
            }
        } catch (Exception ex){
            System.debug('exception ' + ex.getMessage());
            ftr_Logger.write(ex);
        }
        return wrapper;
    }
}