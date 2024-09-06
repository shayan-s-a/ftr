public without sharing class QuoteOpportunityUnlockController {
    @AuraEnabled
    public static void unlockOpportunity(String quoteId){
        
        Quote qt = [Select Id, Order_Opportunity_Unlocked__c, OpportunityId, ownerid from Quote where Id=:quoteId];
        
       /* String profileid =   [select id from profile where name = 'Frontier System Administrator'].id;
        Boolean isUSerInGroup = false;
        for(GroupMember gp: [Select ID from GroupMember where UserOrGroupId =:UserInfo.getUserId() AND Group.Name = 'AllAccountExecs']){
            isUserInGroup = true;
        }*/
        
        if(qt.OpportunityId != null){ // && (isUserInGroup || qt.ownerid == userinfo.getUserId() || profileid == userinfo.getProfileId())){
            if (Approval.isLocked(qt.OpportunityId)){
                Approval.unlock(qt.OpportunityId);
                
                qt.Order_Opportunity_Unlocked__c = true;
            	update qt;
            }
            
            
        }           
    }
}