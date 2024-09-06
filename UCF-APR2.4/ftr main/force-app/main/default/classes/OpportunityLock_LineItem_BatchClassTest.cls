/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
private class OpportunityLock_LineItem_BatchClassTest {

    @TestSetup
    static void makeData(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Frontier Sales User'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Alternate Channel' limit 1].Id,
            isActive=true
        );
        insert u;
    }

    static testmethod void test() {
        Opportunity opp = ftr_TestDataFactory.getOpportunities(1)[0];
        QuoteLineItem qli = ftr_TestDataFactory.getQLI(1, 1)[0];
        Product2 prod = new Product2(Id=qli.Product2Id);
        OpportunityLineItem opli = new OpportunityLineItem();
        opp.recordtypeid ='012E0000000dgAK';
        opp.Opportunity_Type__c = 'New';
        opp.OwnerId = [SELECT Id FROM User WHERE email = 'puser000@amamama.com'].Id;
        insert opp;
        prod.Is_LegacyVlocityProduct__c = true;
        update prod;
        opli.Is_LegacyVlocityProduct__c = false;
        opli.Quantity=1;
        opli.PricebookEntryId = qli.PricebookEntryId;
        opli.UnitPrice = qli.UnitPrice;
        opli.opportunityId = opp.Id;
        insert opli;

        Test.startTest();
        Database.executeBatch(new OpportunityLock_LineItem_BatchClass(new List<String> {'Closed/Won','Closed/Lost','Decision'}));
        Test.stopTest();
    }
    
    static testmethod void testScheduleOpportunityLock() {
        ScheduleOpportunityLock reminder = new ScheduleOpportunityLock();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '0 0 20 * * ?';
        String jobID = System.schedule('Schedule to run Opportunity lock batch without Validating', sch, reminder);
    }
    
    static testmethod void testScheduleOpportunityLockWithValidating() {
        ScheduleOpportunityLockWithValidating reminder = new ScheduleOpportunityLockWithValidating();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '0 0 20 * * ?';
        String jobID = System.schedule('Schedule to run Opportunity lock batch without Validating', sch, reminder);
    }
}