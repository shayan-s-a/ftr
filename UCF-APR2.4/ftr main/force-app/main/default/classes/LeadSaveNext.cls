public class LeadSaveNext {
     @AuraEnabled
    public static List<Id> getLeads(){
        List<Id> IdList = new List<Id>();
        Id ownerId = UserInfo.getUserId();
       	String recordTyepId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Alt Channel').getRecordTypeId();
            
          List<Lead> leadList =  [Select Id from Lead 
                               where OwnerId=: ownerId and Status='Open' and RecordTypeId =: recordTyepId 
                               			and (
                                            ((Follow_Up_Appt_Date__c != null and Follow_Up_Appt_Date__c <= TODAY))
                                            OR
                                            (Is_48_Hour_rule_applied__c = false and Is_Inactive__c = false and Number_of_Attempts_on_date__c <= 3)
                                        )
                              ]; 
        for(Lead l :leadList){
            IdList.add(l.Id);
        }
        return IdList;
    }
    

}