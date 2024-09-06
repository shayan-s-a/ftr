/**
 * ───────────────────────────────────────────────────────────────────────────────────────────────┐
* Update Rev_Net_New_MRR__c, Rev_Renewal_MRR__c,Rev_Incremental_MRR__c fields
* Based on the roll-up summary fields
* ────────────────────────────────────────────────────────────────────────────────────────────────
* @param    not applicable
* @return   successfull message on completion via System Debug
* ───────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global without sharing class ProdRevenueOppUpdateBatch implements Database.Batchable<SObject>{
    global static Boolean isProRevRunning = false;
    //fetching current User Id
    Id currentUserId = UserInfo.getUserId();

    global Database.QueryLocator start(Database.BatchableContext bc){
        //only taking updated opportunities
        return Database.getQueryLocator
        ('SELECT Id,Rev_Net_New_MRR__c,Rev_Renewal_MRR__c,Net_New_MRR__c,Renewal_MRR__c,LastModifiedBy.Id, ' +
            'Opportunity_Type__c,Rev_Incremental_MRR__c,LastModifiedDate FROM Opportunity ' +
            'WHERE LastModifiedDate >= Yesterday AND LastModifiedBy.Id !=: currentUserId');
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> opportunityItems){
        isProRevRunning = true;
        try{
            //updating REV Fields
            for(Opportunity op : opportunityItems){
                //opportunity type = NEW, Copy the value from NET NEW MRR to REV NET NEW MRR, Set REV INCREMENTAL MRR to 0
                //opportunity type != NEW, Copy the value from NET NEW MRR to REV INCREMENTAL MRR, Set the REV NET NEW MRR to 0
                if(op.Opportunity_Type__c == 'New'){
                    if(op.Rev_Net_New_MRR__c != op.Net_New_MRR__c){
                        op.Rev_Net_New_MRR__c = op.Net_New_MRR__c;
                    }
                    if(op.Rev_Incremental_MRR__c != 0){
                        op.Rev_Incremental_MRR__c = 0;
                    }
                }
                else{
                    if(op.Rev_Incremental_MRR__c != op.Net_New_MRR__c){
                        op.Rev_Incremental_MRR__c = op.Net_New_MRR__c;
                    }
                    if(op.Rev_Net_New_MRR__c != 0){
                        op.Rev_Net_New_MRR__c = 0;
                    }
                }

                //update only if Renewal_MRR__c is updated
                if(op.Rev_Renewal_MRR__c != op.Renewal_MRR__c){
                    op.Rev_Renewal_MRR__c = op.Renewal_MRR__c;
                }
            }

            Database.update(opportunityItems, false);
        }
        catch(Exception e){
            System.debug('Exception occured: '+ e.getMessage());
        }
    }

    global void finish(Database.BatchableContext bc){
        isProRevRunning = false;
        System.debug('Successfully updated OPP Rev~');
    }
}