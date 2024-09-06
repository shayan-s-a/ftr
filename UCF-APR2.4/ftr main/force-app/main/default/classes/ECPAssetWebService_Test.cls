@isTest
private class ECPAssetWebService_Test {

    static testMethod void myUnitTest1() {
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();         
        req.requestURI = '/services/apexrest/validateCircuit';  
        req.httpMethod = 'GET';
        req.addParameter('gan', '111');
        RestContext.request = req;
        RestContext.response = res;
        
        ECPAssetWebService.doGet();
        System.debug(res);
        
        RestRequest req1 = new RestRequest();         
        req1.requestURI = '/services/apexrest/Entitlements';  
        req1.httpMethod = 'GET';
        req1.addParameter('gan', '');
        RestContext.request = req1;
        RestContext.response = res;
        ECPAssetWebService.doGet();
        System.debug(res);     
    }
}