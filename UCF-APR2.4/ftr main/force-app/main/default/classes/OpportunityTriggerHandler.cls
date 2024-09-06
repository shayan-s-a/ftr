/********************************************************************************************
    Name : OpportunityTriggerHandler 
    Created By : Mohan Talluri (mohan.talluri@ftr.com)
    Created Date : June 13, 2016
    ********************************************************************************************/
    
    public with sharing class OpportunityTriggerHandler  implements ITriggerHandler
    {
        public static Boolean TriggerDisabled = false;
        public static Boolean isUpdatingOpportunity = false;
        public static Boolean isFirstBeforeUpdate = true;
        public static Boolean isFirstAfterUpdate = true;
     
        public Boolean IsDisabled()
        {
            if (TriggerSettings__c.getOrgDefaults().OpportunityTriggerDisabled__c)
                return true;
            else
                return TriggerDisabled;
        }
     
        public void BeforeInsert(List<SObject> newItems) {
            OpportunityUtility.updateRegionAndTerritory((List<Opportunity>)newItems);
        /*Commented out by Shane Baumgartner on 1/6/20 per John Creswell and Teresa Miles' request.
            OpportunityUtility.restrictOpportunityCreationByTerritory((List<Opportunity>) newItems);
       */ 
           // OpportunityUtility.oppOwnerByState((List<Opportunity>)newItems, new List<Opportunity>());
        }
     
        public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
            
            system.debug('Enter OpportunityTriggerHandler.beforeUpdate');
            //OpportunityUtility.oppOwnerByState((List<Opportunity>)newItems.values(), (List<Opportunity>)oldItems.values());
            OpportunityUtility.updateRegionAndTerritory((List<Opportunity>)newItems.values());
            if (isFirstBeforeUpdate) {
                isFirstBeforeUpdate = false;
                OpportunityUtility.checkIfCanCloseWon((Map<Id, Opportunity>) newItems, (Map<Id, Opportunity>) oldItems);
            }
            //OpportunityUtility.lockOpportunities(newItems);
            system.debug('Exit OpportunityTriggerHandler.beforeUpdate');
            
            //method to check the Contract Team Status should be 'Executed' when Opportunity Sales Stage to Closed/Won
            if (!TriggerSettings__c.getOrgDefaults().checkContractTeamStatusOnClosedOwn__c){       
                OpportunityUtility.checkContractTeamStatusOnClosedOwn((List<Opportunity>)newItems.values(), (Map<Id,Opportunity>)oldItems);       
            }
        }
     
        public void BeforeDelete(Map<Id, SObject> oldItems) {}
     
        public void AfterInsert(Map<Id, SObject> newItems) {
            OpportunityUtility.updateHistoryList((List<Opportunity>)newItems.values(), new List<Opportunity>(), 'INSERT');
        }
     
        public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
            OpportunityUtility.updateHistoryList((List<Opportunity>)newItems.values(), (List<Opportunity>)oldItems.values(), 'UPDATE');
            isUpdatingOpportunity = true;
            
            //callout method to Vology email service for pre-sales notification
            if (!TriggerSettings__c.getOrgDefaults().NotifyVologyEmailCallout_Disable__c){       
                OpportunityUtility.notifyVologyEmailCallout((List<Opportunity>)newItems.values(), (Map<Id,Opportunity>)oldItems);       
            }      
            
            if (isFirstAfterUpdate) {
                isFirstAfterUpdate = false;
                OpportunityUtility.submitAndApproveOpp((Map<Id, Opportunity>) newItems, (Map<Id, Opportunity>) oldItems);
            }
    
            //Add this method to generate task automatically for MDU Contract team queue when MDU Sales team moves an opportunity to 'Contract Requested' stage.
            OpportunityUtility.createContractGenTaskForMDUContractTeamQueue((List<Opportunity>)newItems.values(), (Map<Id,Opportunity>)oldItems); 
            
        }
     
        public void AfterDelete(Map<Id, SObject> oldItems) {}
     
        public void AfterUndelete(Map<Id, SObject> oldItems) {}
    }