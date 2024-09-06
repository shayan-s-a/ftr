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
public class ConfigureSelfRegHandlerCommunityTest{
    
    @TestSetup
    static void testData(){
         Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        testAccount.ParentId = globalAcc.Id;
        insert testAccount;
    }
    
    @isTest
    static void codeCoverage(){
        Profile p = [Select Id From Profile  where name = 'Standard User' limit 1];
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Map<SObjectField, String> registrationAttributes = new Map<SObjectField, String>();
        registrationAttributes.put(User.LastName, 'Test');
        ConfigureSelfRegHandlerCommunity crc = new ConfigureSelfRegHandlerCommunity();
        crc.createUser(acc.Id, p.Id, registrationAttributes, '');
    }
}