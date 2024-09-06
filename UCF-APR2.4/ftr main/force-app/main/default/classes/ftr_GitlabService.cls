/**
 * @description       : Service Class for the GitLab connected app at Frontier Communications
 * @author            : eric.marcondes@ftr.com
**/
global without sharing class ftr_GitlabService {
    global static String consumerKey;
    private static String clientIdFileEndpoint = '/repository/files/.gitlab%2Ftemplates%2Fenv-vars.gitlab-ci.yml';
    private static String sbxName = URL.getSalesforceBaseUrl().toExternalForm().substringAfter('ftr--').substringBefore('.').toUpperCase();
    private static String branchName = 'develop';
    global ftr_GitlabService() {
    }

    /**
    * @description method will grab the consumer key from the GitLab ConnectedApp
    * @author eric.marcondes@ftr.com | 2021-10-14 
    * @return String 
    **/
    global static String getClientId() {
        if (consumerKey == null) {
            MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
            metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
            metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
            MetadataService.ConnectedApp connectedApp; 
            if (Test.isRunningTest()) {
                connectedApp = new MetadataService.ConnectedApp();
                connectedApp.oauthConfig = new MetadataService.ConnectedAppOauthConfig();
                connectedApp.oauthConfig.consumerKey = '1234';
            } else {
                connectedApp = (MetadataService.ConnectedApp)metadataservice.readMetadata('ConnectedApp', new String[] { 'GitLab' }).getRecords()[0];
            }
            MetadataService.ConnectedAppOauthConfig oAuth = connectedApp.oauthConfig;
            System.debug('GitLab ConnectedApp Consumer Key: ' + oAuth.consumerKey);
            consumerKey = oAuth.consumerKey;
        }
        return consumerKey;
    }

    /**
    * @description: method will make a REST callout to GitLab and grab the raw env-vars.gitlab-ci.yml file
    * @author eric.marcondes@ftr.com | 2021-10-14 
    * @return String 
    **/
    global static String getClientIdFileFromRepository() {
        Http httpProtocol = new Http();

        //instantiate an HttpRequest instance  
        HttpRequest request = new HttpRequest();

        //Set the request parameters 
        request.setEndpoint('callout:GitLab' + clientIdFileEndpoint + '/raw?ref=' + branchName);
        request.setMethod('GET');
        request.setHeader('grant_type', 'Bearer');
        request.setHeader('Authorization', 'Bearer {!$Credential.Password}' );
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-type', 'application/json');

        //Make the request and capture the response
        HttpResponse response = httpProtocol.send(request);

        return response.getBody();
    }

    global static void updateClientIdInRepository(String branchName) {
        branchName = branchName;
        updateClientIdInRepository();
    }
    
    /**
    * @description: method will grab make a REST callout to update the SFDX_CLIENTID in the env-vars.gitlab-ci.yml file
    * @author eric.marcondes@ftr.com | 2021-10-14 
    **/
    @Future(callout=true)
    global static void updateClientIdInRepository() {
        String clientIdFile = getClientIdFileFromRepository();
        try {
            if (!clientIdFile.deleteWhitespace().containsIgnoreCase('ENV_NAME:'+sbxName+'SFDX_CLIENTID')) {
                System.debug('Sandbox not found in /env-vars.gitlab-ci.yml');
                return;
            }
            String cleanedFile = clientIdFile.deleteWhitespace();
            String parsedFile = cleanedFile.substringBetween('ENV_NAME:'+sbxName, 'SFDX_USERNAME');
            if (parsedFile == null) {
                parsedFile = cleanedFile.substringBetween('ENV_NAME:'+sbxName.toLowerCase(), 'SFDX_USERNAME');
            }
            String oldClientId = parsedFile.substringAfter('SFDX_CLIENTID:');
            String newClientId = getClientId();
            if (oldClientId == newClientId) {
                System.debug('client Id is already updated in GitLab.');
                return;
            }
            String newFileBody = clientIdFile.replaceAll(oldClientId, newClientId);
            System.debug(LoggingLevel.INFO, 'old: ' + oldClientId);
            System.debug(LoggingLevel.INFO, 'new: ' + newClientId);
            
            Http httpProtocol = new Http();

            //instantiate an HttpRequest instance  
            HttpRequest request = new HttpRequest();

            //Set the request parameters 
            // request.setEndPoint(gitlabclientIdarEnvsFileEndpoint);
            request.setEndpoint('callout:GitLab'+clientIdFileEndpoint);
            request.setMethod('PUT');
            request.setHeader('grant_type', 'Bearer');
            request.setHeader('Authorization', 'Bearer {!$Credential.Password}' );
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-type', 'application/json');

            //create the request Body
            Map<String, String> requestObject = new Map<String,String>();
            requestObject.put('branch', branchName);
            requestObject.put('commit_message', 'pipeconf - ' + sbxName + ' clientId update via apex');
            requestObject.put('content', newFileBody);
            
            String jsonBody = json.serialize(requestObject);

            request.setBody(jsonBody);

            //Make the request and capture the response
            HttpResponse response = httpProtocol.send(request);
        } catch (Exception e) {
            System.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw e;
        }
	    
    }
}