@RestResource(urlMapping='/Assets/*')

global with sharing class ECPAssetWebService {
    
    //==================================================================================================
    // *** REST GET *** : Require field should not be empty, method to validate provided account Circuit
    //==================================================================================================  
    
    @HttpGet
    global static void doGet() {
        
        String ganid = RestContext.request.params.get('gan');
        
        // validate Input parameters.
        ECPHandler.Error resBody = validateInputParams(ganid);
        
        if (resBody != null)
        {
            List<ECPHandler.Error> listval = new List<ECPHandler.Error>();
            listval.add(resBody);
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(listval));
        }
        else
        {
            try{
                // Now we are good to process the request.   
                ECPHandler ecp = new ECPHandler(); 
                RestContext.response.responseBody = Blob.valueOf(ecp.getAssets(ganid));  
                // WebServiceLogger.createLog(resBody, RestContext.response.responseBody,'SUCCESS', 'GET', false, '');
            } catch(Exception e) {
                RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(new ECPHandler.Error('1100', e.getMessage())));
                //  WebServiceLogger.createLog(resBody, '', 'Error', 'GET', true, e.getMessage());   
            }       
                     
        }
         try 
            {   
                Map<String, Object> logOutput = new Map<String, Object>();
                Map<String, Object> logInput = new Map<String, Object>();
                logInput.put('request', RestContext.request.params);
                logInput.put('response', JSON.deserializeUntyped(RestContext.response.responseBody.toString()));
                logInput.put('interface', 'GetAssets');
                logInput.put('system', 'DataWareHouse');
                logInput.put('convertToXML', false);
                
                Object ResObject = JSON.deserializeUntyped(RestContext.response.responseBody.toString()); 
                Map<String, Object> ResMap;
                
                if(ResObject InstanceOf List<Object>){
                    ResMap = (Map<String,Object>)((List<Object>)ResObject).get(0);
                    
                }else if (ResObject InstanceOf Map<String,Object>){
                    ResMap = (Map<String,Object>) ResObject;
                }
                if( ResMap.containsKey('FaultCode')){
                    logInput.put('status', 'ERROR');
                    logInput.put('errorMessage', ResMap.get('FaultDescription'));
                    logInput.put('errorCode', ResMap.get('FaultCode'));
                }else{
                    logInput.put('status', 'SUCCESS');
                }
                
                APILogger log = new APILogger();
                log.createEntry(logInput, logOutput);
            } catch (Exception ex) {
                ftr_Logger.write(ex);
                System.debug('Unable to create log');
                System.debug(ex.getMessage());
            } 
        
    }
    
    global static ECPHandler.Error validateInputParams(String ganid)
    {
        ECPHandler.Error resBody;
        boolean isGANEmpty = String.isEmpty(ganid);
        
        if (isGANEmpty) {
            resBody = new ECPHandler.Error();
            resBody.FaultCode = '1000';
            resBody.FaultDescription = 'Input Parameter Missing: GAN is a mandatory attribute to process the request.';
        }      
        
        return resBody;
    }
    
}