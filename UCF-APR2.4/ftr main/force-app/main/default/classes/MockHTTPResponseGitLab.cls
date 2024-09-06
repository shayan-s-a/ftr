@isTest
global class MockHTTPResponseGitLab implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        String envname = URL.getSalesforceBaseUrl().toExternalForm().substringAfter('ftr--').substringBefore('.').toUpperCase();
        String body = envname+': variables: ENV_NAME: ' +envname+ ' SFDX_CLIENTID: 3MVG9zJJ_hX_0bb8yUWurIZ11J4muMgjk6VCYSL6PPQdxZ.Dn6J90jI_xTuwKyJmXudMXpW7WeFNWVVfYQ__2 SFDX_CLIENTID: 3MVG9Fy_1ZngbXqO6ZyUdcmUe1brs8dl_uScYQG6WM5X6kF47mE5rhII7B7DMHeYgMiJ5cllWfSqokatepm6B SFDX_USERNAME: "kris.rohde@ibm.com.ftr.gitlab.$ENV_NAME"';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}