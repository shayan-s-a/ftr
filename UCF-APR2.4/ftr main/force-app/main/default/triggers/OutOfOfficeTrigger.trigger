trigger OutOfOfficeTrigger on OutOfOffice (After insert,After update,after delete) {
    system.debug('===='+trigger.old);
    Map<id,OutOfOffice> userIdMap = new Map<id,OutOfOffice>();
    Set<Id> deleteOOOSet = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate){
        for(OutOfOffice ooo : Trigger.new){
                system.debug('trigger.new===='+trigger.new);
                System.debug('startDate===='+ooo.StartDate.date());
                userIdMap.put(ooo.UserId,ooo);            
        }
    }
    
    if(Trigger.isDelete){
        for(OutOfOffice ooo : Trigger.old){       
                deleteOOOSet.add(ooo.UserId);            
        }
    }
    
    List<FieldAssignment__c> lstFieldAssignment = new List<FieldAssignment__c>();
    for(FieldAssignment__c fa: [SELECT Id, OutOfOffice__c, UserId__c,userId__r.Backup_Assignment__c,Out_Of_Office_Start_Date__c,Out_Of_Office_End_Date__c  from FieldAssignment__c where (UserId__c IN :userIdMap.keySet() OR UserId__c IN :deleteOOOSet)]) {
        if(userIdMap.containsKey(fa.UserId__c)){
                fa.OutOfOffice__c =true;
                fa.Backup_Assignment__c = fa.userId__r.Backup_Assignment__c ;
                
                system.debug('userIdMap.get(fa.UserId__c).StartDate===='+userIdMap.get(fa.UserId__c).StartDate);
                fa.Out_Of_Office_Start_Date__c = userIdMap.get(fa.UserId__c).StartDate;
                fa.Out_Of_Office_End_Date__c = userIdMap.get(fa.UserId__c).EndDate;
                
                
        }
         else if (deleteOOOSet.contains(fa.UserId__c)){
                fa.OutOfOffice__c =false;
                fa.Backup_Assignment__c=null ;
                fa.Out_Of_Office_Start_Date__c=null;
                fa.Out_Of_Office_End_Date__c = null;
         }
                    
        lstFieldAssignment.add(fa);
    }
    
    if(lstFieldAssignment.size()>0){
        update lstFieldAssignment ;
    }    
    
}