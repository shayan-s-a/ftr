/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
/********************************************************************************************
Name : SupportTeamMemberTest
Created By : Mohan Talluri (mohan.talluri@ftr.com)
Created Date : June 10, 2016
Description :  Test coverage for the SupportTeamMember Utility to support Trigger Handler.
********************************************************************************************/

@isTest(seeAllData = false)

private class SupportTeamMemberTest {
       
        static testmethod void unitTest(){
             Account acc = new Account(name = 'TestAccount', Customer_Number__c = '1234');
             insert acc;
             acc = [select id from Account where name = 'TestAccount'];
             
             Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
             User u = new User(Alias = 'dt', Email='user@test.com', EmailEncodingKey='UTF-8', LastName='LTest', FirstName ='FTest',
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='er@trg.com');
             insert u;
             u = [select id, LastName, FirstName from User where UserName='er@trg.com' limit 1];
             
             Support_Team_Member__c stm = new Support_Team_Member__c(Support_Role__c = 'FAB', Account__c = acc.id, 
                                                                     Team_Member__c = u.id);
             insert stm;
             stm = [select id, Support_Role__c from Support_Team_Member__c where Team_Member__c =: u.id limit 1];     
             stm.Support_Role__c = 'Enterprise CSA';
             update stm;
			 stm = [select id, Support_Role__c from Support_Team_Member__c where Team_Member__c =: u.id limit 1];
			 stm.Support_Role__c = 'Regional SAM';
             update stm;
			 stm = [select id, Support_Role__c from Support_Team_Member__c where Team_Member__c =: u.id limit 1];
			 stm.Support_Role__c = 'National SAM';
             update stm;
			 
             delete stm;
             undelete stm;
             
        }
}