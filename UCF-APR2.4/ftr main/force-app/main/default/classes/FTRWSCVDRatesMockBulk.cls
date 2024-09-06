@isTest
public class FTRWSCVDRatesMockBulk implements HttpCalloutMock {
   public String ratesResp = '{"Address":{"Address": "1 BROOKLYN RD","City":"FREEVILLE","StateCd":"NY","ZipCd":"13068","UsocTier":"3","lookUpUsed":"Address"},"Rate":[{"PNum": "EIAV001GOV300484","standard": "Y","locTier": null,"region": "A","spec": null,"los": "BASIC","vta": "MTM","product": "EIA","serviceTierPort": null,"circuitType": "EVC","usocTier": "003","usocType": null,"uniSpeed": "1000M","evcSpeed": "100M","nrcUsoc": "EIANR","nrc": "1500.00", "mrcUsoc": "EIATK","mrc": "1750.00","airlineMileageUsoc": null,"airlineMileageRate": "","fixedMileageUsoc": null,"fixedMileageRate": "","internetPortUsoc": null,"internetPortRate": "","mileageThresholdUsoc": null,"mileageThresholdRate": ""}]}';
        public HttpResponse respond(HTTPRequest request) {
               
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('apikey', 'i.ApiKey_Header__c');
        response.setBody(ratesResp);
        response.setStatusCode(200);
        return response;  
    }
}