/********************************************************************************************
Name : ContractTriggerHandler
Created By : Mohan Talluri (mohan.talluri@ftr.com)
Created Date : June 10, 2016
Description :  Contract trigger handler which sets the ICB Flag
********************************************************************************************/

public with sharing class ContractTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        if (TriggerSettings__c.getOrgDefaults().ContractTriggerDisabled__c)
            return true;
        else
            return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) {      
        ContractUtility.setICBFlag((List<Contract>)newItems);       
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {    
        ContractUtility.setICBFlag((List<Contract>)newItems.values());      
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {}
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {  
        
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}    
}