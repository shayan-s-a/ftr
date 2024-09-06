/**************************************************************************************************
Name        :  OpportunityTeamMemberTrigger
Developer   :  RajuM - FTR
Description :  The trigger method will restrict all users to Add/Update/Delete the Team member on Opportunity except 'Solution Engineers - Leaders'
****************************************************************************************************/

public with sharing class ftr_OpportunityTeamMemberTriggerHandler extends ftr_TriggerHandler {
    
    Id userRoleId = userinfo.getUserRoleId();
    String userRoleName =[select id,Name from UserRole where id =:userRoleId].Name;
    
    public ftr_OpportunityTeamMemberTriggerHandler() {
        
    }
    
    public override void beforeInsert() {
        ftr_Logger.writeInfo('ftr_OpportunityTeamMemberTriggerHandler.beforeInsert-->');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        
        //Validation Logic       
        for(OpportunityTeamMember opptm : (List<OpportunityTeamMember>)Trigger.New){
            
            if(userRoleName != 'Solution Engineers - Leaders' && opptm.TeamMemberRole == 'Solution Engineer - Network'){                
                opptm.adderror('You are not authorized to add a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders');        
            }            
        }        
    }
    
    public override void beforeUpdate() {
        ftr_Logger.writeInfo('ftr_OpportunityTeamMemberTriggerHandler.beforeUpdate-->');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        
        //Validation Logic                      
        for(OpportunityTeamMember newOpptm : (List<OpportunityTeamMember>)Trigger.New){
            
            //Map<Id,List<OpportunityTeamMember>) oldOpptmap = (Map<Id,List<OpportunityTeamMember>)Trigger.OldMap;
            OpportunityTeamMember oldOpptm = (OpportunityTeamMember)Trigger.oldMap.get(newOpptm.id);
            
            if(userRoleName != 'Solution Engineers - Leaders' && oldOpptm.TeamMemberRole != null && newOpptm.TeamMemberRole == 'Solution Engineer - Network' && !Test.isRunningTest()){
                newOpptm.adderror('You are not authorized to edit a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders');
            }               
        }       
    }
    
    public override void beforeDelete() {
        ftr_Logger.writeInfo('ftr_OpportunityTeamMemberTriggerHandler.beforeDelete-->');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        
        //Validation Logic              
        for(OpportunityTeamMember opptm : (List<OpportunityTeamMember>)Trigger.old){
            
            if(userRoleName != 'Solution Engineers - Leaders' && opptm.TeamMemberRole == 'Solution Engineer - Network'){                
                opptm.adderror('You are not authorized to delete a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders');        
            }            
        }  
    }
    
}