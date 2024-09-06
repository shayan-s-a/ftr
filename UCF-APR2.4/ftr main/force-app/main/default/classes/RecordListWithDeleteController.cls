public with sharing class RecordListWithDeleteController {
    @AuraEnabled
    public static List<ftr_DID_Location_Details__c> getRecords(Id orderId) {
        return [select id,Name,OrderId__c,ServiceAccountId__r.Name,ServiceAccountId__c  from ftr_DID_Location_Details__c where OrderId__c=:orderId];
    }
     @AuraEnabled
    public static void DeleteRecord(List<ftr_DID_Location_Details__c> DeleteIds) {
        
        List<ftr_DID_Location_Details__c> delacccon = new List<ftr_DID_Location_Details__c>();
        for(ftr_DID_Location_Details__c con : [SELECT Id, Name FROM ftr_DID_Location_Details__c WHERE Id IN : DeleteIds]){
            delacccon.add(con);
        }
         
        if(delacccon.size() > 0){
            Delete  delacccon;
        }
         
    }
}