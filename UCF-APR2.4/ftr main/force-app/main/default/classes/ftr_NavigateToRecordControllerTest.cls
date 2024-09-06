/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
 * 
**/
@isTest
public class ftr_NavigateToRecordControllerTest {
    
    @isTest
    public static void getBaseUrlTest(){
        ftr_NavigateToRecordController.getBaseUrl();
    }
    
    @isTest
    public static void getBaseUrlPortalUserTest(){
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
		Account globalAcc1 = new Account();
		globalAcc1.Name = 'GLOBAL ACCOUNT';
		globalAcc1.RecordTypeId = globalRecId;
		//globalAcc.RecordTypeId = '012E0000000fDc3IAE';
		insert globalAcc1;
		Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account a = new Account(name = 'test portal account', phone = '9999999999');
        a.RecordTypeId = MasterRTId;
		a.ParentId = globalAcc1.Id;
        insert a;
        Contact c = new Contact(AccountId = a.Id, lastName = 'Portal User', email = 'standarduser@ftr--test02.com', 	Contact_Role__c = 'Attorney');
        insert c;
        Profile p = [SELECT Id FROM Profile WHERE Name='Frontier Partner Portal User']; 
        User u = new User(Alias = 'standt', Email='standarduser@ftr--test02.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@ftr--test02.com', ContactId=c.Id);
        system.runAs(u){
            test.startTest();
            
            ftr_NavigateToRecordController.getBaseUrl(); 
            
            test.stopTest();
        }
    }
}