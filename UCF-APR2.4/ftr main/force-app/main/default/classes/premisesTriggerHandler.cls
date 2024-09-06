/********************************************************************************************
Name : PremisesTriggerHandler
Created Date : 09/10/2020
Description :  premises trigger handler which sets the key
********************************************************************************************/
public with sharing class premisesTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        if (TriggerSettings__c.getOrgDefaults().Premises_Trigger_Disabled__c)
            return true;
        else
            return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) {      
        premisesUtility.setKey((List<vlocity_cmt__Premises__c>)newItems);
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {    
        premisesUtility.setKey((List<vlocity_cmt__Premises__c>)newItems.values());
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {}
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {  
        
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {} 
}