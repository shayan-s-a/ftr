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
private class RemoveDupAccounts_Test {
    @testSetup static void dataSetUp() {
        List<Profile> prof = [select id from profile where name LIKE '%Admin%' limit 1];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof[0].id;
        user.username = 'test123778@gmail.com';
        user.email = 'test123778@gmail.com';
        //user.IsActive = false;
        user.Alias = 'test';
        user.TimeZoneSidKey = 'America/New_York';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        insert user;
        
        insert new TriggerSettings__c(SetupOwnerId=UserInfo.getOrganizationId(), AccountTriggerDisabled__c =True);
        
          Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
        
    	Account accToKeep = new Account();
        accToKeep.Name='test';
        accToKeep.Phone = '1234567890';
        accToKeep.parent__c = true;
        accToKeep.Customer_Number__c = '12345';
        accToKeep.RecordTypeId = [Select id from RecordType where DeveloperName='Master' AND SobjectType = 'Account'].Id;
        accToKeep.ParentId = globalAcc.Id;
        insert accToKeep;
        
        Account accToDelete = new Account();
        accToDelete.Name='testToDelete';
        accToDelete.Phone = '1234568890';
        accToDelete.Customer_Number__c = '12345';
        accToDelete.RecordTypeId = [Select id from RecordType where DeveloperName='Master' AND SobjectType = 'Account'].Id;
        accToDelete.ParentId = globalAcc.Id;
        insert accToDelete;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = accToDelete.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Qualification';
        opp.Name = 'testOpp';
        
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = accToKeep.Id;
        opp1.CloseDate = system.today().addDays(1);
        opp1.StageName = 'Qualification';
        opp1.Name = 'testOpp1';
        opp1.OwnerId = user.id;
        insert new List<Opportunity>{opp};
        
        Case cse = new Case();
        cse.AccountId = accToDelete.Id;
        cse.Subject = 'mobile Not working';
        cse.Origin = 'Web';
        
        Case cse1 = new Case();
        cse1.AccountId = accToDelete.Id;
        cse1.Subject = 'mobile Not working';
        cse1.Origin = 'Web';
        cse1.OwnerId = user.id;
        insert new List<Case>{cse,cse1};
        
        
        Contact con = new Contact();
        con.AccountId = accToDelete.Id;
        con.LastName = 'test';
        con.Phone = '1112223333';
        
        Contact con1 = new Contact();
        con1.AccountId = accToDelete.Id;
        con1.LastName = 'test';
        con1.OwnerId = user.id;
        con1.Phone = '1112223333';
        insert new List<Contact>{con1,con};
        
        Order ord = new Order();
        ord.AccountId = accToDelete.Id;
        ord.Name = 'test';
        ord.EffectiveDate = system.today();
        ord.Status = 'Draft';
        
        Order ord1 = new Order();
        ord1.AccountId = accToDelete.Id;
        ord1.Name = 'test';
        ord1.EffectiveDate = system.today();
        ord1.Status = 'Draft';
        ord1.OwnerId = user.id;
        insert new List<Order>{ord1,ord};
        
        Contract cont = new Contract();
        cont.AccountId = accToDelete.Id;
        cont.Name = 'testContract';
        cont.BillingStreet  = 'test';
        cont.BillingCity  = 'test';
        cont.BillingState  = 'New York';
        cont.BillingCountry  = 'United States';
        cont.BillingPostalCode  = '10036';
        cont.ShippingStreet  = 'test';
        cont.ShippingCity  = 'test';
        cont.ShippingState  = 'New York';
        cont.ShippingCountry  = 'United States';
        cont.ShippingPostalCode  = '10036';
        
        Contract cont1 = new Contract();
        cont1.AccountId = accToDelete.Id;
        cont1.Name = 'testContract';
        cont1.OwnerId = user.id;
        cont1.BillingStreet  = 'test';
        cont1.BillingCity  = 'test';
        cont1.BillingState  = 'New York';
        cont1.BillingCountry  = 'United States';
        cont1.BillingPostalCode  = '10036';
        cont1.ShippingStreet  = 'test';
        cont1.ShippingCity  = 'test';
        cont1.ShippingState  = 'New York';
        cont1.ShippingCountry  = 'United States';
        cont1.ShippingPostalCode  = '10036';
        insert new List<Contract>{cont1,cont};
    } 
    static testMethod void validateVoidedCheck(){
        
        Account accToKeep = [select id,Customer_Number__c from Account where Name = 'test'];
        Test.startTest();
        	database.executeBatch(new RemoveDupAccounts(),1);
        Test.stopTest();
        system.assertEquals(true, [select id,Duplicate_Account__c from Account where Name = 'testToDelete'].Duplicate_Account__c);
        
    }
    static testMethod void scheduleJobTest(){
        Test.startTest();
        	RemoveDupAccounts.scheduleJob();
        Test.stopTest();
        system.assertEquals('RemoveDupAccounts Job', [SELECT Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name = 'RemoveDupAccounts Job' limit 1].CronJobDetail.Name);
    }
    
}