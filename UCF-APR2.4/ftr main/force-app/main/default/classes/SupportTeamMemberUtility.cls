/********************************************************************************************
Name : SupportTeamMemberUtility
Created By : Mohan Talluri (mohan.talluri@ftr.com)
Created Date : June 10, 2016
Description :  Utility to support SupportTeamMember Trigger Handler.
********************************************************************************************/

public with sharing class SupportTeamMemberUtility {
    
    public static void matchUserRecord(List<Support_Team_Member__c> stmList){
    
        Map<Id,User> mapUsers = new Map<Id,User>();
        for(Support_Team_Member__c stm : stmList){
            System.debug(JSON.SerializePretty(stm));
            mapUsers.put(stm.Team_Member__c,null);
        }
        //When the user is input in the lookup field, the user will be queried within the map to get the userid
        for(User u : [SELECT Id, Name FROM User WHERE Id IN :mapUsers.keySet()]){
            mapUsers.put(u.Id,u);
        }
        //The support team member record name will be replaced with the name of the user in the lookup 
        for(Support_Team_Member__c stm : stmList){
            stm.Name = mapUsers.get(stm.Team_Member__c).Name;
            stm.ownerId = stm.Team_Member__c;
        }
        
    }
    
    public static void updateContractRenewalCaseOwner(Map<Id, SObject> newItems){
        string strCaseOwner = '';
        string strUsername = '';
        Id CRRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contract Renewal').getRecordTypeId();
        
        for (Support_Team_Member__c cse: (List<Support_Team_Member__c>)newItems.values()){
            if(String.isBlank(cse.Account__c)) continue;
            strCaseOwner = getCaseOwnerName(cse.Account__c);
            List<user> lstUser = [select id , firstname, lastname from user where id =: strCaseOwner];
            if(!lstUser.isEmpty())
                strUsername = lstUser[0].firstname+' '+lstUser[0].lastname;
            
            List<case> lstCase = [select id, ownerid,Case_Owner__c from case 
                                    where RecordTypeId =: CRRecordTypeId and status != 'Closed' and AccountId =: cse.Account__c];

            if(!lstCase.isEmpty()){
                for(case caseRecord : lstCase){
                    if(!String.isEmpty(strCaseOwner))
                        caseRecord.Ownerid = strCaseOwner ;
                    if(!String.isEmpty(strUsername)) 
                        caseRecord.case_owner__c = strUsername;  
                }
                update lstCase;
            }
        }
    }
    
    private static string getCaseOwnerName(string strCaseOwnerValue){
        
        list<Support_Team_Member__c> lstTeamMembers = [select id,Account__c,Support_Role__c,Team_Member__c, 
                                                        Team_Member__r.firstname,Team_Member__r.lastname
                                                        from Support_Team_Member__c 
                                                        where Account__c  =: strCaseOwnerValue order by createddate desc];
        
        string strCASEOwner = '';
        
        for(Support_Team_Member__c sTemMember : lstTeamMembers){
            if(sTemMember.Support_Role__c.contains('SAM')) {
                strCASEOwner = sTemMember.Team_Member__c; 
                break;
            }
            else if(sTemMember.Support_Role__c.contains('CSA') )
                strCASEOwner = sTemMember.Team_Member__c; 
        }
        
        return strCASEOwner;
    }
    
    /*
    public static void updateContractRenewalCaseOwner(Map<Id, SObject> newItems){
        string strCaseOwner = getCaseOwnerName(newItems);
        string strUsername = '';
        List<user> lstUser = [select id , firstname, lastname from user where id =: strCaseOwner];
        if(!lstUser.isEmpty()){
            strUsername = lstUser[0].firstname+' '+lstUser[0].lastname;
        }
        
        Id CRRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contract Renewal').getRecordTypeId();
        List<case> lstCase = [select id, ownerid,Case_Owner__c from case 
                                    where RecordTypeId =: CRRecordTypeId and status != 'Closed'];
        if(!lstCase.isEmpty()){
            for(case caseRecord : lstCase){
                if(!String.isEmpty(strCaseOwner))
                    caseRecord.Ownerid = strCaseOwner ;
                if(!String.isEmpty(strUsername)) 
                    caseRecord.case_owner__c = strUsername;  
            }
            update lstCase;
        }
    }
    
    private static string getCaseOwnerName(Map<Id, SObject> newItems){
        map<string,string> mapSAMTeammember = new map<string,string>();
        map<string,string> mapCSATeammember = new map<string,string>();
        
        set<string> setAccountidsinit = new set<string>();
         for (Support_Team_Member__c cse: (List<Support_Team_Member__c>)newItems.values()){
            //cse.Account__c =='Closed')
                //mapTeammember.put(cse.Account__c,cse.Team_Member__c);
                setAccountidsinit.add(cse.Account__c);        
        }
        system.debug('--setAccountidsinit--'+setAccountidsinit);
        list<Support_Team_Member__c> lstTeamMemebers = [select id,Account__c,Support_Role__c,Team_Member__c, 
                                                        Team_Member__r.firstname,Team_Member__r.lastname
                                                        from Support_Team_Member__c 
                                                        where Account__c  in :setAccountidsinit order by createddate desc];
        set<string> setAccountIds = new set<string>();
        string strCASEOwner = '';
        system.debug('--lstTeamMemebers --'+lstTeamMemebers );
        for(Support_Team_Member__c sTemMember : lstTeamMemebers){
            setAccountIds.add(sTemMember.Account__c); 
            if(sTemMember.Support_Role__c.contains('SAM') ){
                mapSAMTeammember.put(sTemMember.Account__c,sTemMember.ID);
                //strCASEOwner = sTemMember.Team_Member__r.firstname +' '+sTemMember.Team_Member__r.lastname; 
                strCASEOwner = sTemMember.Team_Member__c; 
                break;
            }
            else if(sTemMember.Support_Role__c.contains('CSA') ){
                mapCSATeammember.put(sTemMember.Account__c,sTemMember.Id); 
                //strCASEOwner = sTemMember.Team_Member__r.firstname +' '+sTemMember.Team_Member__r.lastname; 
                strCASEOwner = sTemMember.Team_Member__c; 
               // break;
            }
        }
       return strCASEOwner;  
    }    
    */
}