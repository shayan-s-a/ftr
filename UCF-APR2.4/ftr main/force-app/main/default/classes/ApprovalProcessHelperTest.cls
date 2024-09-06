/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class ApprovalProcessHelperTest {

    @TestSetup
    static void makeData(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString;
        User u = new User(
          ProfileId = [SELECT Id FROM Profile WHERE Name = 'Frontier System Administrator' Limit 1].Id,
          LastName = 'last',
          Email = 'Cpt.Awesome@awesomesauce.com',
          Username = uniqueName+'@awesomesauce.com',
          CompanyName = 'Testing Co',
          Title = 'Captian',
          Alias = 'alias',
          TimeZoneSidKey = 'America/Los_Angeles',
          EmailEncodingKey = 'UTF-8',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Commercial Support & Center' Limit 1].Id
        );
        insert u;
        User u2 = new User(
          ProfileId = [SELECT Id FROM Profile WHERE Name = 'Frontier System Administrator' Limit 1].Id,
          LastName = 'last',
          Email = 'Cpt.Awesome@awesomesauce2.com',
          Username = uniqueName+'123@awesomesauce.com',
          CompanyName = 'Testing Co',
          Title = 'Captian',
          Alias = 'alias',
          TimeZoneSidKey = 'America/Los_Angeles',
          EmailEncodingKey = 'UTF-8',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          UserRoleId = [SELECT Id FROM UserRole WHERE  Name = 'Commercial Support & Center' Limit 1].Id,
          ManagerId = u.Id
        );
        insert u2;
    }

    @isTest
    static void methodName(){
        User u = [Select id from user where email='Cpt.Awesome@awesomesauce2.com' limit 1];
        Opportunity[] opps = ftr_TestDataFactory.getOpportunities(1);
        opps[0].put('OwnerId', u.Id);
        insert opps;
        Test.startTest();
        System.runAs(u) {
            ApprovalProcessHelper.autoSubmitAndApprove(opps[0].Id);
        }
        Test.stopTest();
        
    }
}