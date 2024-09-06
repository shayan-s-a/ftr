/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
**/
@isTest
public class PartnerAgentFormApprovalControllerTest {
    
    @TestSetup
    static void makeData(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Frontier Sales User'].Id,
            LastName = 'last',
            Email = 'puser111@gmail.com',
            Username = 'puser111@gmail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Commercial Support & Center' limit 1].Id,
            isActive=true
        );
        insert u;
    }    
    
    @isTest
    static void userProvisioingUpdate(){
        
        User u = [SELECT Id FROM USER WHERE Email = 'puser111@gmail.com' limit 1];
        
        System.runas(u) {
            
            String userId = u.id;            
            Agent__c ag = new Agent__c();
            ag.Name = 'RGH';
            ag.Agent_State__c = 'TX';
            ag.Agent_Email__c = 'rajkur@gmail.com';
            ag.Partner_Community_Access__c = true;
            
            insert ag;
            
            User_Provisioning__c upRec = new User_Provisioning__c();
            
            upRec.Street_Address__c = '2120 Cannes Dr';
            upRec.City__c = 'Carrollton';
            upRec.Postal_Code__c = '75660' ;         
            upRec.Timezone__c = 'America/Chicago';
            upRec.User__c = u.id;
            
            insert upRec;            
            
            String cname = 'RGH1';               
            String sagent = 'RGH11';           
            string tit = 'Mr';                
            string sadd = '2120 Cannes Dr';              
            string cit = 'Carrollton';            
            string st =  'Texas';            
            string pc = '75661' ;             
            string tm = 'America/Chicago';             
            
            PartnerAgentFormApprovalController.updateUserProvisioingObj(cname,sagent,tit,sadd,cit,pc,st,tm);
            
            PartnerAgentFormApprovalController.getAgents();
        }
    }    
}