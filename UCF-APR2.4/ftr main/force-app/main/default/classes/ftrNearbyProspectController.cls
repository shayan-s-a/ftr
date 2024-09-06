/**
*
* This class is used to control the NearestProspects LWC Component 
* @author  Eric Marcondes
* @since   2020-05-18
*
*/
public with sharing class ftrNearbyProspectController {

    public class ftrNearbyProspectControllerException extends Exception {}

    public class NearbyProspect {
        public NearbyProspect(Account a) {
            CompanyName = a.Name;
            AccountOwner = a.Account_Owner_Name__c;
            AccountId = a.Id;
            url = '/' + a.Id;
            D_B_Total_Wireline_Bill = a.D_B_Total_Wireline_Bill__c;
            Total_Domestic_Employees = a.Total_Domestic_Employees__c;
            
            BuildingType = String.isNotBlank(a.Building_Type__c) ? a.Building_Type__c : ' - ';
            Employees = String.valueOf(a.D_B_Total_Wireline_Bill__c) != null ? String.valueOf(a.D_B_Total_Wireline_Bill__c) : ' - ';
            WirelineBill = String.valueOf(a.Total_Global_Employees__c)  != null ? String.valueOf(a.Total_Global_Employees__c) : ' - ';
            for (Neustar_Data__c nd : a.Neustar_Data__r ) {
                CurrentProvider = nd.Current_SP__c == null ? ' - ' : nd.Current_SP__c;
                PreviousProvider = nd.Old_SP__c == null ? ' - ' : nd.Old_SP__c;
                ProviderLastChangedDate = nd.Port_Date__c == null ? ' - ' : Datetime.newInstance(nd.Port_Date__c, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
            }
        }
        public void setLatticeValues(LBI__Recommendation__c obj){
            Rating = obj.LBI__Rank__c;
        }
        
        @AuraEnabled
        public String CompanyName;
        @AuraEnabled
        public String AccountOwner;
        @AuraEnabled
        public String Rating = ' - ';
        @AuraEnabled
        public String ProviderLastChangedDate = ' - ';
        @AuraEnabled
        public String CurrentProvider = ' - ';
        @AuraEnabled
        public String PreviousProvider = ' - ';
        @AuraEnabled
        public String BuildingType = ' - ';
        @AuraEnabled
        public String AccountId;
        @AuraEnabled
        public String url;
        @AuraEnabled
        public String Employees;
        @AuraEnabled
        public String WirelineBill;
        
        @AuraEnabled
        public Decimal D_B_Total_Wireline_Bill;
        @AuraEnabled
        public Decimal Total_Domestic_Employees;
    }

    @AuraEnabled
    public static List<NearbyProspect> getNearbyProspects(String accountId, String distance, String units, String queryLimit) {
        system.debug(accountId);
        system.debug(distance);
        List<NearbyProspect> nbpList = new List<NearbyProspect>();
        List<String> nbpIDs = new List<String>();
        List<String> nbpPhones = new List<String>();
        Account currentAccount = [select id, ShippingLatitude, ShippingLongitude from Account where id =:accountId];
        String lat = String.valueOf(currentAccount.ShippingLatitude);
        String lon = String.valueOf(currentAccount.ShippingLongitude);
        Date today = Date.today();
        Date portDateLimit = Date.newInstance(today.year()-3, today.month(), today.day()).addMonths(6);
        system.debug('portDateLimit '+portDateLimit);
        if (lat == null || lon == null) {
            throw new ftrNearbyProspectControllerException('This company must have a valid service address to find nearby prospects.');
        }
        User aeUnassigned = [select id from user where name='Account Executive Unassigned' limit 1];
        List<String> owners = new List<String>{UserInfo.getUserId(), aeUnassigned.Id};
        String query = 'SELECT Name, Account_Owner_Name__c, Phone, Building_Type__c, D_B_Total_Wireline_Bill__c,Total_Domestic_Employees__c, Total_Global_Employees__c, (SELECT id, TN__c, Old_SP__c, Current_SP__c, Port_Date__c, Master_Account__c FROM Neustar_Data__r  order by port_date__c asc) ' +
            ' FROM Account ' + 
            ' WHERE (distance(ShippingAddress, geolocation({0}, {1}), \'\'{2}\'\') < {3}) AND Type = \'\'Prospect\'\' AND OwnerId IN :owners ' + 
            ' AND Id IN (SELECT Master_Account__c FROM Neustar_Data__c WHERE Port_Date__c < :portDateLimit ) ' +
            ' LIMIT {4}';
        // get prospects
        List<Account> prospectList;
        try {
            prospectList = database.Query(String.format(query, new List<String> { lat, lon, units, distance, queryLimit }));
        } catch (exception e) {
            throw new ftrNearbyProspectControllerException(e.getMessage());
        }
        system.debug('prospect list size -> ' + prospectList.size());
        for (Account acc : prospectList) {
            nbpIDs.add(acc.Id);
        }
        List<LBI__Recommendation__c> prospectRatings = [SELECT id, LBI__Rank__c, LBI__Account__c from LBI__Recommendation__c  WHERE LBI__Account__c IN :nbpIDs AND LBI__Status__c='Open' order by LastModifiedDate asc LIMIT 10000];
        
        for(Account acc : prospectList){
            NearbyProspect nbp = new NearbyProspect(acc);
            for (LBI__Recommendation__c score : prospectRatings) {
                if (score.LBI__Account__c == acc.Id) {
                    nbp.setLatticeValues(score);
                }
            }
            nbpList.add(nbp);
        }
        system.debug('nbpList-->' + JSON.serializePretty(nbpList));
        return nbpList;
    }
}