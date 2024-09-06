/**
 * @description       : Service class for preparing a sandbox
 * @author            : eric.marcondes@ftr.com
**/
public without sharing class ftr_PrepareSandboxService {
    private static String testEnvName;
    private static String sbxName;
    private static String[] possibleEnvs = new String[]{ 'qat01', 'qat02', 'qat03' };
    private static MetadataService.MetadataPort metadataservice;
    public ftr_PrepareSandboxService() {

    }

    @Future(callout=true)
    public static void updateMetadata() {
        testEnvName = getTestEnvName();
        metadataservice = new MetadataService.MetadataPort();
        metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
        metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
        updateNamedCreds();
        createRemoteSites();
    }

    public static void updateNamedCreds() {
        List<MetadataService.NamedCredential> credentials = new List<MetadataService.NamedCredential>();
        for (NamedCredential credential : [SELECT Id, MasterLabel, DeveloperName, Endpoint, PrincipalType FROM NamedCredential]) {
            if (credential.Endpoint.contains('api-prod') || Test.isRunningTest()) {
                MetadataService.NamedCredential cred = new MetadataService.NamedCredential();
                cred.fullName = credential.DeveloperName;
                cred.label  = credential.MasterLabel;
                cred.principalType  = credential.PrincipalType;
                cred.protocol  = 'Password';
                cred.endpoint = credential.Endpoint.replaceAll('api-prod', 'api-'+testEnvName);
                credentials.add(cred); 
            }
        }

        if (credentials.size() == 0 || Test.isRunningTest()) return;
        MetadataService.SaveResult[] srList = metadataservice.updateMetadata(credentials);    
        for (MetadataService.SaveResult sr : srList) {
            if (sr.success) {
                System.debug('Successfully updated: ' + sr.fullName);
            } else {
                System.debug('Error updating: ' + sr.fullName + ': ' + sr.errors[0].message);
            }
        }
    }

    public static void createRemoteSites() {
        List<MetadataService.RemoteSiteSetting> remoteSiteSettings = new List<MetadataService.RemoteSiteSetting>();
        
        // remote site for the sandbox
        MetadataService.RemoteSiteSetting cpqRemoteSite = new MetadataService.RemoteSiteSetting();
        cpqRemoteSite.fullName = sbxName;
        cpqRemoteSite.url = 'https://ftr--'+sbxName+'--c.visualforce.com';
        cpqRemoteSite.description = 'Remote site setting for ' +sbxName+ '. Created from apex after refresh.';
        cpqRemoteSite.isActive = true;
        cpqRemoteSite.disableProtocolSecurity = false;
        remoteSiteSettings.add(cpqRemoteSite); 

        // Gitlab remote site
        MetadataService.RemoteSiteSetting gitlabRemoteSite = new MetadataService.RemoteSiteSetting();
        gitlabRemoteSite.fullName = 'Gitlab';
        gitlabRemoteSite.url = 'https://gitlab.com';
        gitlabRemoteSite.description = 'Remote site setting for Gitlab. Created from apex after refresh.';
        gitlabRemoteSite.isActive = true;
        gitlabRemoteSite.disableProtocolSecurity = false;
        remoteSiteSettings.add(gitlabRemoteSite); 

        // remote sites used for QAT0X
        for (String env : possibleEnvs) {
            MetadataService.RemoteSiteSetting remoteSite = new MetadataService.RemoteSiteSetting();
            remoteSite.fullName = env.toUpperCase();
            remoteSite.url = 'https://api-'+env+'.frontier.com';
            remoteSite.description = 'Remote site setting for ' +env.toUpperCase()+ '. Created from apex after refresh.';
            remoteSite.isActive = true;
            remoteSite.disableProtocolSecurity = false;
            remoteSiteSettings.add(remoteSite); 
        }

        if (remoteSiteSettings.size() == 0 || Test.isRunningTest()) return;
        MetadataService.SaveResult[] srList = metadataservice.createMetadata(remoteSiteSettings);    
        for (MetadataService.SaveResult sr : srList) {
            if (sr.success) {
                System.debug('Successfully created: ' + sr.fullName);
            } else {
                System.debug('Error creating: ' + sr.fullName + ': ' + sr.errors[0].message);
            }
        }
    }

    @Future
    public static void updateDeveloperProfiles() {
        list<permissionSetAssignment> permset = [SELECT AssigneeId, Assignee.IsActive FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Developer_Permissions'];
        Profile p = [select id from profile where name='Frontier System Administrator'];
        list<user> users = new List<user>();
        for (permissionSetAssignment permUser : permset){
            if (permUser.Assignee.IsActive) {
                users.add(new User(
                    Id = permUser.AssigneeId,
                    ProfileId = p.Id
                ));
            }
        }
        Database.update(users, false);
    }

    public static String getTestEnvName() {
        String testEnvName = 'qat02';
        sbxName = URL.getSalesforceBaseUrl().toExternalForm().substringAfter('ftr--').substringBefore('.');
        if (sbxName.equalsIgnoreCase('TEST01')) {
            testEnvName = 'qat01';
        } else if (sbxName.equalsIgnoreCase('TEST03')) {
            testEnvName = 'qat03';
        } else if (sbxName.equalsIgnoreCase('PREPROD')) {
            testEnvName = 'pprd';
        }
        return testEnvName;
    }
}
