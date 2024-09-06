@isTest
private class ECPValidateCircuitWebService_Test {

    static testMethod void myUnitTest1() {
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();         
        req.requestURI = '/services/apexrest/validateCircuit';  
        req.httpMethod = 'GET';
        req.addParameter('circuitid', '111');
        req.addParameter('ganid', '111');
        RestContext.request = req;
        RestContext.response = res;
        
        ECPValidateCircuitWebService.doGet();
        System.debug(res);
        
        RestRequest req1 = new RestRequest();         
        req1.requestURI = '/services/apexrest/Entitlements';  
        req1.httpMethod = 'GET';
        req1.addParameter('circuitid', '');
        req1.addParameter('ganid', '');
        RestContext.request = req1;
        RestContext.response = res;
        ECPValidateCircuitWebService.doGet();
        System.debug(res);
        
        req1 = new RestRequest();         
        req1.requestURI = '/services/apexrest/Entitlements';  
        req1.httpMethod = 'GET';
        req1.addParameter('circuitid', '111');
        req1.addParameter('ganid', '');
        RestContext.request = req1;
        RestContext.response = res;
        ECPValidateCircuitWebService.doGet();
        System.debug(res);
        
        req1 = new RestRequest();         
        req1.requestURI = '/services/apexrest/Entitlements';  
        req1.httpMethod = 'GET';
        req1.addParameter('circuitid', '');
        req1.addParameter('ganid', '111');
        RestContext.request = req1;
        RestContext.response = res;
        ECPValidateCircuitWebService.doGet(); 
        System.debug(res);        
    }
}