@isTest
private class OpportunityTriggerTest {
    @isTest static void TestDeleteOpportunityWithTriggerEnabled() {
        // *Test data setup
        // Create an account with an opportunity, and then try to delete it
        // Perform test
        Test.startTest();
        String globalstrRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Global'].Id;

		String masterstrRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Master'].Id;

        Account objAcc1 = new Account();
		objAcc1.Name = 'testaccount';
		objAcc1.OwnerId = userinfo.getUserId();
		objAcc1.Legal_Street__c = 'test';
		objAcc1.Legal_City__c = 'test';
		objAcc1.Legal_State__c = 'test';
		objAcc1.ShippingStreet = 'test';
		objAcc1.ShippingCity = 'NY';
		objAcc1.ShippingState = 'New York';
		objAcc1.BillingStreet = 'test';
		objAcc1.BillingCity = 'NY';
		objAcc1.BillingState = 'New York';
        objAcc1.RecordTypeId=globalstrRecordTypeId;
		insert objAcc1;
        
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingStreet = '123 Main Street';
        testAccount.BillingCity = 'Anywhere';
        testAccount.BillingState = 'Ohio';
        testAccount.BillingPostalCode = '44088';
        testAccount.ShippingStreet = '123 Main Street';
        testAccount.ShippingCity = 'Anywhere';
        testAccount.ShippingState = 'Ohio';
        testAccount.ShippingPostalCode = '44088';
        testAccount.Phone = '9023214560';
        testAccount.RecordTypeId=masterstrRecordTypeId;
        testAccount.ParentId=objAcc1.id;
        insert testAccount;

        
        Opportunity opp = new Opportunity();
        opp.Name = 'RefreshTestOpp';
        opp.AccountId = testAccount.id;
        Date d1=Date.newInstance(2019, 05, 11);
        opp.CloseDate=d1;
        opp.StageName='Investigating';
        opp.CPE_Product__c='No';
        opp.ftr_NumberOfQuickQuotes__c = 1;
        opp.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Lightning').getRecordTypeId();
        insert opp;
        
        // Disable the trigger
        TriggerSettings__c triggerSettings = new TriggerSettings__c(
            Name = 'Test Trigger Settings',
            OpportunityTriggerDisabled__c = true
        );
        insert triggerSettings;
        
        delete opp;
        Test.stopTest();

        // Verify that the trigger did not run
        // Since the trigger is disabled, it should not perform any actions
        // Assert the expected behavior here based on your trigger implementation

        // Perform additional assertions or verifications as needed
    }

}
