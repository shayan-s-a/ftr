public with sharing class FieldAssignmentTriggerHandler implements ITriggerHandler {
    
    public static Boolean TriggerDisabled = false;
    public static Boolean isFirstTimeExecuted = true;
 
    public Boolean IsDisabled()
    {
        return false;
    }
    
	public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        ftr_Logger.writeInfo('FieldAssignmentTriggerHandler.afterUpdate');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        if(isFirstTimeExecuted){
        	updateOutOfOffice((Map<Id,FieldAssignment__c>) newItems, (Map<Id,FieldAssignment__c>) oldItems); 

        }
    }
    
    public void AfterInsert(Map<Id, SObject> newItems) {
        ftr_Logger.writeInfo('FieldAssignmentTriggerHandler.afterUpdate');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        if(isFirstTimeExecuted){
        	updateOutOfOffice((Map<Id,FieldAssignment__c>) newItems, null);
        }
    }
    
    public void BeforeInsert(List<SObject> newItems) {
        validateUserProfile(newItems);
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        validateUserProfile(newItems.values());
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}

    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}

    public static void validateUserProfile(List<SObject> records) {
        Map<Id, String> userProfileMap = new Map<Id, String>();
        Map<Id, String> workgroupProfileMap = new Map<Id, String>();

        // get workgroupIds and userIds
        for (SObject fieldAssignment : records) {
            userProfileMap.put((Id)fieldAssignment.get('UserId__c'), '-');
            workgroupProfileMap.put((Id)fieldAssignment.get('WorkGroupId__c'), '-');
        }
        // query all user profile names
        for (User u : [SELECT Id, Profile.Name FROM User WHERE Id IN :userProfileMap.keySet()]) {
            userProfileMap.put(u.Id, u.Profile.Name);
        }
        // query all workgroup profile names
        for (WorkGroup__c workgroup : [SELECT Id, Profiles__c FROM WorkGroup__c WHERE Id IN :workgroupProfileMap.keySet()]) {
            workgroupProfileMap.put(workgroup.Id, workgroup.Profiles__c);
        }
        // make sure the user profile is in the workgroup profile list
        for (SObject fieldAssignment : records) {
            if (workgroupProfileMap.get((Id)fieldAssignment.get('WorkGroupId__c')) != null) {
                String[] workgroupProfiles = workgroupProfileMap.get((Id)fieldAssignment.get('WorkGroupId__c')).split(';');
                String userProfile = userProfileMap.get((Id)fieldAssignment.get('UserId__c'));
                System.debug('workgroupProfiles: '+workgroupProfiles);
                System.debug('userProfile: '+userProfile);
                if (!workgroupProfiles.contains(userProfile)) {
                    fieldAssignment.addError('Assignee must have one of the following profiles: ' + String.join(workgroupProfiles, ', '));
                }
            }
        }
    }
    
    public static void updateOutOfOffice(Map<Id,FieldAssignment__c> newMap, Map<Id,FieldAssignment__c> oldMap) {
		Map<Id,Boolean> userIdOooMap = new Map<Id, Boolean>();
        Map<Id,FieldAssignment__c> fieldAssignmentMap = new Map<Id,FieldAssignment__c>();
        Set<Id> fieldAssignmentIdSet = new Set<Id>();
        for(FieldAssignment__c fa: newMap.values()) {
            if( Trigger.isInsert ){
				userIdOooMap.put(fa.UserId__c, fa.OutOfOffice__c);
				fieldAssignmentIdSet.add(fa.Id);
			}
			if( Trigger.isUpdate && fa.OutOfOffice__c != oldMap.get(fa.Id).OutOfOffice__c ){
				userIdOooMap.put(fa.UserId__c, fa.OutOfOffice__c);
				fieldAssignmentIdSet.add(fa.Id);
			}
        }
        
        for(FieldAssignment__c fa: [SELECT Id, OutOfOffice__c, UserId__c from FieldAssignment__c where UserId__c IN :userIdOooMap.keySet() AND ID NOT IN :fieldAssignmentIdSet ]) {
            if(fa.OutOfOffice__c != userIdOooMap.get(fa.UserId__c) ) {
                fa.OutOfOffice__c = userIdOooMap.get(fa.UserId__c);
                fieldAssignmentMap.put(fa.Id, fa);
            }
        }
        
        if(fieldAssignmentMap.size() > 0) {
            isFirstTimeExecuted = false;
            update fieldAssignmentMap.values();
        }
	}
}