/********************************************************************************************
Name : Account_TriggerHandler
Created By : Mohan Talluri (mohan.talluri@ftr.com)
Created Date : February 11, 2016
Description :  Account trigger handler which does the following

1. If account.isDPILoad = true, we split each record to 3 accounts at Summary/Billing/Member
   and then generate the hierarchy by inserting accounts in a sequence and then updating the
   parentid.
********************************************************************************************/

public with sharing class Account_TriggerHandler  implements ITriggerHandler
{
    // If you intend to stop this trigger from firing while in a unit test, you could just add the following code to the test:
    // Account_TriggerHandler.TriggerDisabled = true;
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        if (TriggerSettings__c.getOrgDefaults().AccountTriggerDisabled__c)
            return true;
        else
            return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) {
        System.debug('Before Invoking CreateHierarchy');
        
        for(Sobject sobj : newItems){
            if(sobj.get('Phone') != null)
                sobj.put('Need_To_Sync_With_NeuStar__c',true);
        }
        AccountUtility.createHierarchy(newItems);
        AccountUtility.newServiceAccountOwner(newItems);
        System.debug('CreateHierarchy Processed');
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug('Before Invoking updateHierarchy');
        for(Sobject sobj : newItems.values()){
            Id accId = Id.valueOf(String.valueOf(sobj.get('Id')));
            Account oldAcc = (Account) oldItems.get(accId);
            
            if(sobj.get('Phone') != null && oldAcc.Phone != String.valueOf(sobj.get('Phone')))
                sobj.put('Need_To_Sync_With_NeuStar__c',true);
        }
        AccountUtility.updateHierarchy(newItems.values());
        if(!AccountUtility.isRecursiveTrigger)
            AccountUtility.updateServiceAccountValidation(newItems.values(),oldItems);
        
        System.debug('updateHierarchy Processed');
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {
        
        //SDDD-3555 - prevent deletion from Organization accounts with child accounts.
        Set<Id> accIds = (Set<Id>) oldItems.keyset();
        boolean preventDeletion = false;
        if(accIds.size() == 1){
            for(Account acct : (List<Account>) oldItems.values()){
                List<Account> accChildList = [SELECT Id, parent.recordtype.Name FROM Account WHERE ParentId = :acct.Id];
                if (accChildList.size() > 0 && accChildList[0].parent.recordtype.Name == 'Organization'){
                    preventDeletion = true;
                }
                if(preventDeletion == true){
                    acct.addError('This Organization Account has child accounts. The child accounts must be updated before this account can be deleted. Please reach out to your Salesforce Admin for Assistance.'); 
                } 
            }
        }  
    }
 
    public void AfterInsert(Map<Id, SObject> newItems) {

        if(!Test.isRunningTest()){
        AccountUtility.setParentHierarchy(newItems);
        //Insert row in Alt_Channel_Form__c
        AccountUtility.insertAltChannelForm(newItems);
        AccountUtility.createTotal360Lead(newItems, null);
        /*if(newItems.values()[0].get('Phone') != null){
            String recId = String.valueOf(newItems.values()[0].get('Id'));
            String phn = String.valueOf(newItems.values()[0].get('Phone'));
            
            NeustartApiManager.makeApiCall(phn,recId);
        }*/
    }
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        AccountUtility.setParentHierarchy(newItems);
        //Update row in Alt_Channel_Form__c
        AccountUtility.updateAltChannelForm(newItems);        
        AccountUtility.createTotal360Lead(newItems, oldItems);
        /*if(newItems.values()[0].get('Phone') != null && newItems.values()[0].get('Phone') != oldItems.values()[0].get('Phone')){
            String recId = String.valueOf(newItems.values()[0].get('Id'));
            String phn = String.valueOf(newItems.values()[0].get('Phone'));
            
            NeustartApiManager.makeApiCall(phn,recId);
        }*/
        AccountUtility.serviceAccountOwnerChange(newItems.values(),oldItems);
        AccountUtility.OwnerChange(newItems.values(), oldItems);
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {
        //if(System.isBatch() || System.isQueueable ()) AccountUtility.delete_SupportTeamMember(oldItems.keyset());
        //else AccountUtility.deleteSupportTeamMember();
        AccountUtility.delete_SupportTeamMember(oldItems.keyset());
    }
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}