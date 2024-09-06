/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
**/
@isTest
public class NewContractControllerTest {
    @isTest
    public static void testprofileRetrieveMethod(){
        profile p =[select id from profile where Name='Frontier Commissions Team'];
        String Profilename = NewContractController.getProfileName(p.id);
        system.debug('custom label'+system.Label.AltNewContract);
        System.assertEquals('Frontier Commissions Team', Profilename);
    }
    @isTest
    public static void testIsValidProfile(){
        Test.startTest();
         
       Profile profile1 = [Select Id from Profile where name = '#Alternate Channel - Community Connections Sales'];
       // Profile profile1 = [Select Id from Profile where name = '#Alternate Channel - Community Connections AE'];
       System.debug('What is the profile id ' + profile1);
       UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
       date tDate = date.today();
       date uDate = Date.today().addDays(30);
        
         User u = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'sreeni@ftr.com',
            Alias = '2',
            Email='sreeni@ftr.com',
            EmailEncodingKey='UTF-8',
            Firstname='Tony',
            Lastname='Start',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago');
            insert u;
            System.debug ('Here is the user id ' + u.id);
        
        User u1 = [SELECT id from User WHERE username = 'sreeni@ftr.com' LIMIT 1];
        system.debug('MC Users ='+ ' ' + u1);
        System.runas(u1) {
            Map<String, Object> result = NewContractController.isValidProfile();
            system.assertEquals(true, Boolean.valueOf(result.get('isValid')));
        }
    }
}