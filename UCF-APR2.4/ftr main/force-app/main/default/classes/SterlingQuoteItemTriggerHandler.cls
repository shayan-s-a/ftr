/********************************************************************************************
Name : SterlingQuoteItemTriggerHandler
Created By : Mohan Talluri (mohan.talluri@ftr.com)
Created Date : June 13, 2016
********************************************************************************************/

public with sharing class SterlingQuoteItemTriggerHandler implements ITriggerHandler {
    
    public static Boolean TriggerDisabled = false;
    @testVisible public static Boolean stopTrigger = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        if (TriggerSettings__c.getOrgDefaults().SterlingQuoteItemTriggerDisabled__c)
            return true;
        else
            return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) { }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 
        if (SterlingQuoteItemTriggerStaticValues.isFirstBeforeUpdate) {
            SterlingQuoteItemTriggerStaticValues.isFirstBeforeUpdate = false;
            SterlingQuoteItemUtility.setApproverAndOwner((List<SterlingQuoteItem__c>)newItems.values());
        }
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) { 
        if (Test.isRunningTest() && stopTrigger) {
            return;
        }
        if (SterlingQuoteItemTriggerStaticValues.isFirstAfterInsert) {
            SterlingQuoteItemTriggerStaticValues.isFirstAfterInsert = false;
            SterlingQuoteItemUtility.deleteDuplicateQuoteLineItems(false, (List<SterlingQuoteItem__c>)newItems.values());
            SterlingQuoteItemUtility.updateQuoteLineItems(false, (List<SterlingQuoteItem__c>)newItems.values());
            SterlingQuoteItemUtility.setisSyncallowed ((List<SterlingQuoteItem__c>)newItems.values());
            SterlingQuoteItemUtility.updateTotalCIACCharge((List<SterlingQuoteItem__c>)newItems.values());
       		Quote_Extension.autoSyncProducts(newItems);
        }
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 
        if (SterlingQuoteItemTriggerStaticValues.isFirstAfterUpdate) {
            SterlingQuoteItemTriggerStaticValues.isFirstAfterUpdate = false;
            SterlingQuoteItemUtility.updateQuoteLineItems(false, (List<SterlingQuoteItem__c>)newItems.values());
            SterlingQuoteItemUtility.setisSyncallowed ((List<SterlingQuoteItem__c>)newItems.values());
            SterlingQuoteItemUtility.updateTotalCIACCharge((List<SterlingQuoteItem__c>)newItems.values());
            Quote_Extension.autoSyncProducts(newItems);
        }
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {
        if (SterlingQuoteItemTriggerStaticValues.isFirstAfterDelete) {
            SterlingQuoteItemTriggerStaticValues.isFirstAfterDelete = false;
            SterlingQuoteItemUtility.updateQuoteLineItems(true, (List<SterlingQuoteItem__c>)oldItems.values());
            SterlingQuoteItemUtility.setisSyncallowed ((List<SterlingQuoteItem__c>)oldItems.values());
            SterlingQuoteItemUtility.updateTotalCIACCharge((List<SterlingQuoteItem__c>)oldItems.values());
            Quote_Extension.autoSyncProducts(oldItems);
        } 
    }
 
    public void AfterUndelete(Map<Id, SObject> newItems) {
        SterlingQuoteItemUtility.updateTotalCIACCharge((List<SterlingQuoteItem__c>)newItems.values());
    }
}