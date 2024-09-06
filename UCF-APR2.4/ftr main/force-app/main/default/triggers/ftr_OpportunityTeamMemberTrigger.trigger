/**************************************************************************************************
Name        :  OpportunityTeamMemberTrigger
Developer   :  RajuM - FTR
Description :  Opportunity Team Member trigger that all routes trigger context
****************************************************************************************************/

trigger ftr_OpportunityTeamMemberTrigger on OpportunityTeamMember (before insert, before update, before delete ) {
    
    if (!TriggerSettings__c.getOrgDefaults().OpportunityTeamMember_Trigger_Disabled__c){
		new ftr_OpportunityTeamMemberTriggerHandler().run();
    }
}