public with sharing class ftr_OLITriggerHandler implements ITriggerHandler{
	public static Boolean TriggerDisabled = false; 
    
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getOrgDefaults().OliTriggerDisabled__c) return true;
        else return TriggerDisabled;
    }
    public void BeforeInsert(List<SObject> newItems) {}
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { //vlocity_cmt__RecurringCharge__c
        
        for(SObject oli : newItems.values()){
            
            OpportunityLineItem  lineItem = (OpportunityLineItem) oli;
            //OpportunityLineItem oldItem = (OpportunityLineItem) oldItems.get(lineItem.Id);
            if(lineItem.Opportunity_Sync__c !=null && lineItem.Opportunity_Sync__c == 'Vlocity'){
	             // lineItem.CPQ_NetNewMRR__c = lineItem.Quantity * ((lineItem.vlocity_cmt__RecurringCharge__c!=null?lineItem.vlocity_cmt__RecurringCharge__c:0)-(lineItem.Renewal_MRR__c!=null?lineItem.Renewal_MRR__c:0));//oldItem.CPQ_NetNewMRR__c;
                 lineItem.NRC_Price__c = (lineItem.vlocity_cmt__OneTimeCharge__c!=null?lineItem.vlocity_cmt__OneTimeCharge__c:0) * lineItem.Quantity;
            }
             
        }
    }
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    public void AfterInsert(Map<Id, SObject> newItems) {}
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    public void AfterDelete(Map<Id, SObject> oldItems) {}
}