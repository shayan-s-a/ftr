public class ftr_NavigateToRecordController {
    @AuraEnabled
    public static List<String> getBaseUrl(){
        List<String> urlToReturn = new String[2];
        String redirectSiteUrl = '';
        String userProfile = [SELECT Name
                              FROM Profile
                              WHERE Id =: userinfo.getProfileId()
                              LIMIT 1].Name;
        urlToReturn.add(0, userProfile);
        
        //Handling Frontier Partner Portal User
        if(userProfile == 'Frontier Partner Portal User'){
            ConnectApi.Community comm;
            if(!test.isRunningTest()) {
                String ntwrkId = Network.getNetworkId();
                comm = ConnectApi.Communities.getCommunity(ntwrkId);
                redirectSiteUrl = comm.siteUrl;
            }else {
                redirectSiteUrl = 'test.com';
            }
            
        }else {
            redirectSiteUrl = URL.getSalesforceBaseUrl().toExternalForm();
        }
        urlToReturn.add(1, redirectSiteUrl);
        
        return urlToReturn;
    }
}