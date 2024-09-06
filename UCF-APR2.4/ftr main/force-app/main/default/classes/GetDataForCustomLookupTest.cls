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
public class GetDataForCustomLookupTest {

    @testSetup static void CreateTestData(){
         Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc;
        Account acc = new Account(Name='acc1',ParentId = globalAcc.Id);
        insert acc;
        Contact newContact = new Contact(firstName='Test',LastName='Name',AccountId=acc.Id);        
    }
    @isTest
    public static void CheckContact(){
        List<Account> acc = [select Id from Account where Name='acc1'];
        List<Contact> contactObj = GetDataForCustomLookup.getSuggestions(acc[0].id,'abc');
        system.assertNotEquals(null,contactObj);
    }
}