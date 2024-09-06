global class PartnerAgentFormApprovalController {
    
    // This method is used to create User provisioning Record    
    @AuraEnabled
    public static void updateUserProvisioingObj(string masterAgent,string subAgent,string title,string streetAddress,string city,string postalCode,string state,string timezone){    
                
        System.debug('Master Agent==='+masterAgent);        
        String userId = UserInfo.getUserId();        
        
        List<User_Provisioning__c> upList = [Select id,User__c,Company_Name__c,Sub_Agent__c,Title__c,Street_Address__c,City__c,State_Picklist__c,Postal_Code__c,Timezone__c,isAgentFormSubmitted__c from User_Provisioning__c where User__c =:userId ];
        List<User_Provisioning__c> updateList = new List<User_Provisioning__c>();
        
        for(User_Provisioning__c upRec : upList){
            
            System.debug('get userid==='+userId);
            upRec.Company_Name__c = masterAgent;
            upRec.Sub_Agent__c =  subAgent;
            upRec.Title__c =  title;
            upRec.Street_Address__c = streetAddress;
            upRec.City__c = city;            
            upRec.Postal_Code__c = postalCode ;
            upRec.State_Picklist__c = state;
            upRec.Timezone__c = timezone ; 
 			upRec.isAgentFormSubmitted__c = true;            
            
            updateList.add(upRec);
        }
        
        if(updateList.size() > 0){
            System.debug('list===='+updateList);
            update updateList;         
        }        
    }
    
    @AuraEnabled
    public static List<String> getAgents(){        
        List<Agent__c> agentsLt = [SELECT Id, Name, Agent_State__c, Agent_Email__c, Partner_Community_Access__c FROM Agent__c where Partner_Community_Access__c = true];
        List<String> agentsList = new List<String>();
        System.debug('Agents List======='+agentsList);
        
        for(Agent__c ag : agentsLt){
            agentsList.add(ag.Name);           
        }
        
        return agentsList;        
    }
    
    @AuraEnabled
    public static boolean getSubmitFormStatus(){
        
        Boolean Status = false;
        String userId = userinfo.getUserId();
        
        for(User_Provisioning__c upRec : [Select id,User__c,isAgentFormSubmitted__c from User_Provisioning__c where User__c =:userId AND isAgentFormSubmitted__c = true ]){
            
            Status = true;
        }
        
        return Status;        
    }
}