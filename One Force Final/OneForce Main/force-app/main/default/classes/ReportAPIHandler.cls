public with sharing class ReportAPIHandler {
    @AuraEnabled(cacheable=true)
    public static String getReportData(String reportId) {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('/services/data/v52.0/analytics/reports/' + reportId + '/instances');
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        return res.getBody();
    }
}