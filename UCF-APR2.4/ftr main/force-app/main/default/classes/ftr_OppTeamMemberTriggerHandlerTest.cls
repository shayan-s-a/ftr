/**
 * @description       : This test class covers the following Apex classes:
 *      OpportunityTeamMemberTrigger
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
 * 
**/
/**************************************************************************************************
Name        :  OpportunityTeamMemberTriggerTest
Developer   :  RajuM -FTR
Description :  Test class for OpportunityTeamMemberTrigger
****************************************************************************************************/
@isTest
public class ftr_OppTeamMemberTriggerHandlerTest { 
    
    @testSetup static void setup() {
        
        User u1 = new User();
        u1.LastName = 'ekammd';
        u1.Alias= 'kikuk';
        u1.Username = 'raj123456ere@gmail.com';
        u1.Email = 'rajkumar123456ere8@gmail.com';
        u1.CommunityNickname ='mir';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';
        Profile p = [Select id From Profile  where name = '#Solution Engineer Supervisor' limit 1];
        UserRole role =[select id,Name from UserRole where name = 'Solution Engineers - Leaders' limit 1];
        u1.ProfileId= p.id;
        u1.UserRoleId = role.id;
        
        insert u1;
        
        //Id userRoleId = userinfo.getUserRoleId();        
        
        User u2 = new User();
        u2.LastName = 'kumdfad';
        u2.Alias= 'ragfdf';
        u2.Username = 'raj12345645@gmail.com';
        u2.Email = 'rajkumar123456845@gmail.com';
        u2.CommunityNickname ='lio';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.EmailEncodingKey = 'UTF-8';
        u2.LanguageLocaleKey = 'en_US';
        u2.LocaleSidKey = 'en_US';
        Profile p1 = [Select id From Profile  where name = '#Solution Engineer Supervisor' limit 1];
        UserRole role1 =[select id,Name from UserRole where name = 'Solution Engineer - SA' limit 1];
        u2.ProfileId= p1.id;
        u2.UserRoleId = role1.id;
        
        insert u2;        
        
    }
        
    @isTest
    static void beforeInsertTest(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
               Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
         
              Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Master' LIMIT 1]?.Id;
        
        Account a = new Account();
        a.RecordTypeId=masterRecId; 
        a.name = 'TestAccount';
        a.Phone='2487958700';
        a.ShippingStreet = '2120 Cannes Dr';
        a.ShippingCity = 'Dallas';
        a.ShippingState = 'Texas';
        a.ShippingStateCode = 'TX';
        a.ShippingPostalCode ='75060'; 
        a.ParentId = globalAcc.Id;
        
        insert a;
        
        System.runAs(thisUser){
            
            Account acc = [select id,name from Account limit 1];
            
            Opportunity opp = new Opportunity();
            opp.Name ='TestOppty';
            opp.AccountId=acc.id;
            opp.Opportunity_Type__c = 'New';
            opp.Partner_Sales_Stages__c = 'Decision';
            opp.CloseDate= system.today();
            opp.ForecastCategoryName='Commit';
            opp.Campaign__c ='No';       
            opp.New_Logo__c ='No';
            opp.RecordTypeId ='012E0000000dgAK';
            //opp.VologyPreSalesEmailSent__c = false;
            opp.StageName='Decision';
            opp.Lead_Product_List__c = 'Managed Firewall';
            opp.Description__c ='Test for SEER'; 
            opp.Description_of_customer_needs__c = 'Test SEER';
            opp.Service_Address__c = '2120 Cannes Dr,Dallas,TX';
            //opp.SEER_Assigned_To__c=u.id;
            
            insert opp;        
            
            user u = [select id,Name from User where Username = 'raj12345645@gmail.com' limit 1];
            //opportunity opp =[select id,Name,AccountId,Opportunity_Type__c,Partner_Sales_Stages__c,CloseDate,VologyPreSalesEmailSent__c,Lead_Product_List__c,Description__c from opportunity limit 1];
            
            OpportunityTeamMember opptm = new OpportunityTeamMember();
            opptm.OpportunityId = opp.id;
            opptm.UserId = u.id ;
            opptm.TeamMemberRole ='Solution Engineer - Network';
            opptm.OpportunityAccessLevel = 'Read'; 
            
            try {
                insert opptm;
            }Catch(DMLexception ex){
                system.assert(ex.getMessage().contains('You are not authorized to add a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders'),'You are not authorized to add a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders');
            }
            /*
            try{
                delete opptm;
            }catch(DMLexception e){
                system.assert(e.getMessage().contains('You are not authorized to delete a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders'),'You are not authorized to delete a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders');
            }*/
        }
    }
    
    @isTest
    static void beforeUpdateTest(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
         Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc3 = new Account();
        globalAcc3.Name = 'GLOBAL ACCOUNT';
        globalAcc3.RecordTypeId = globalRecId;
        insert globalAcc3;
         
         Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Master' LIMIT 1]?.Id;
        
        Account a = new Account();
        a.RecordTypeId=masterRecId; 
        a.name = 'TestAccount';
        a.Phone='2487958700';
        a.ShippingStreet = '2120 Cannes Dr';
        a.ShippingCity = 'Dallas';
        a.ShippingState = 'Texas';
        a.ShippingStateCode = 'TX';
        a.ShippingPostalCode ='75060';   
        a.ParentId = globalAcc3.Id;
        
        insert a;
        
        System.runAs(thisUser){
            
            Account acc = [select id,name from Account limit 1];
            
            Opportunity opp = new Opportunity();
            opp.Name ='TestOppty';
            opp.AccountId=acc.id;
            opp.Opportunity_Type__c = 'New';
            opp.Partner_Sales_Stages__c = 'Decision';
            opp.CloseDate= system.today();
            opp.ForecastCategoryName='Commit';
            opp.Campaign__c ='No';       
            opp.New_Logo__c ='No';
            opp.RecordTypeId ='012E0000000dgAK';
            //opp.VologyPreSalesEmailSent__c = false;
            opp.StageName='Decision';
            opp.Lead_Product_List__c = 'Managed Firewall';
            opp.Description__c ='Test for SEER'; 
            opp.Description_of_customer_needs__c = 'Test SEER';
            opp.Service_Address__c = '2120 Cannes Dr,Dallas,TX';
            //opp.SEER_Assigned_To__c=u.id;
            
            insert opp;        
            
            user u1 = [select id,Name from User where Username = 'raj12345645@gmail.com' limit 1];
            //opportunity opp =[select id,Name,AccountId,Opportunity_Type__c,Partner_Sales_Stages__c,CloseDate,VologyPreSalesEmailSent__c,Lead_Product_List__c,Description__c from opportunity limit 1];
            
            OpportunityTeamMember opptm = new OpportunityTeamMember();
            opptm.OpportunityId = opp.id;
            opptm.UserId = u1.id ;
            opptm.TeamMemberRole ='	CPE Manager';
            opptm.OpportunityAccessLevel = 'Read'; 
            
            //try {
                insert opptm;
            //}Catch(DMLexception ex){
            //    system.assert(ex.getMessage().contains('You are not authorized to add a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders'),'You are not authorized to add a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders');
           // }
            
            try{                
                opptm.TeamMemberRole ='Solution Engineer - Network';
                update opptm;
            }catch(DMLexception e){
                system.assert(e.getMessage().contains('You are not authorized to edit a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders'),'You are not authorized to edit a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders');
            }
        }
    }
    
    @isTest
    static void beforeDeleteTest(){
        
          Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        insert globalAcc1;
         
          Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Master' LIMIT 1]?.Id;        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account a = new Account();
        a.RecordTypeId=masterRecId; 
        a.name = 'TestAccount';
        a.Phone='2487958700';
        a.ShippingStreet = '2120 Cannes Dr';
        a.ShippingCity = 'Dallas';
        a.ShippingState = 'Texas';
        a.ShippingStateCode = 'TX';
        a.ShippingPostalCode ='75060';      
        a.ParentId = globalAcc1.Id;
        insert a;
        
        System.runAs(thisUser){
            
            Account acc = [select id,name from Account limit 1];
            
            Opportunity opp = new Opportunity();
            opp.Name ='TestOppty';
            opp.AccountId=acc.id;
            opp.Opportunity_Type__c = 'New';
            opp.Partner_Sales_Stages__c = 'Decision';
            opp.CloseDate= system.today();
            opp.ForecastCategoryName='Commit';
            opp.Campaign__c ='No';       
            opp.New_Logo__c ='No';
            opp.RecordTypeId ='012E0000000dgAK';
            //opp.VologyPreSalesEmailSent__c = false;
            opp.StageName='Decision';
            opp.Lead_Product_List__c = 'Managed Firewall';
            opp.Description__c ='Test for SEER'; 
            opp.Description_of_customer_needs__c = 'Test SEER';
            opp.Service_Address__c = '2120 Cannes Dr,Dallas,TX';
            //opp.SEER_Assigned_To__c=u.id;
            
            insert opp;        
            
            user u1 = [select id,Name from User where Username = 'raj12345645@gmail.com' limit 1];
            //opportunity opp =[select id,Name,AccountId,Opportunity_Type__c,Partner_Sales_Stages__c,CloseDate,VologyPreSalesEmailSent__c,Lead_Product_List__c,Description__c from opportunity limit 1];
            
            OpportunityTeamMember opptm = new OpportunityTeamMember();
            opptm.OpportunityId = opp.id;
            opptm.UserId = u1.id ;
            opptm.TeamMemberRole ='	CPE Manager';
            opptm.OpportunityAccessLevel = 'Read'; 
            
            //try {
                insert opptm;
            //}Catch(DMLexception ex){
            //    system.assert(ex.getMessage().contains('You are not authorized to add a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders'),'You are not authorized to add a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders');
           // }
            
            try{                
                opptm.TeamMemberRole ='Solution Engineer - Network';
                delete opptm;
            }catch(DMLexception e){
                system.assert(e.getMessage().contains('You are not authorized to delete a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders'),'You are not authorized to delete a Team member under Solution Engineer-Network, Please reach out to your Solution Engineers-Leaders');
            }
        }
    }
    
}