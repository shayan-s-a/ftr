/********************************************************************************************
Name : ZAddressTriggerHandler
Created By : Mohan Talluri (mohan.talluri@ftr.com)
Created Date : June 13, 2016
********************************************************************************************/

public with sharing class ZAddressTriggerHandler implements ITriggerHandler
{
    public static Boolean TriggerDisabled = false;
 
    public Boolean IsDisabled()
    {
        if (TriggerSettings__c.getOrgDefaults().ZAddressTriggerDisabled__c)
            return true;
        else
            return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) {}
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        ZAddressUtility.updateSQI(newItems);
        //method to update Opportunity line items with ZAddress
    	if (!TriggerSettings__c.getOrgDefaults().UpdateOpptyLineItemsWithZAddress_Disable__c){       
        	ZAddressUtility.updateOpptyLineItems(newItems);
    	}
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        ZAddressUtility.updateSQI(newItems);
        //method to update Opportunity line items with ZAddress
    	if (!TriggerSettings__c.getOrgDefaults().UpdateOpptyLineItemsWithZAddress_Disable__c){       
        	ZAddressUtility.updateOpptyLineItems(newItems);
    	}
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {   
        ZAddressUtility.processDelete((List<ZAddress__c>)oldItems.values());
    }
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}