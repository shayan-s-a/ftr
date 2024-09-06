/**
 * ───────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for ProdRevenueOppUpdateBatch class
* ────────────────────────────────────────────────────────────────────────────────────────────────
* @param    not applicable
* @return   not applicable
* ───────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class ProdRevenueOppUpdateBatchTest {

    @testSetup static void setup() {
        //fetching current User Id
        Id currentUserId = UserInfo.getUserId();
        //fetching admin users except current user
        List<User> adminUsers = [
                                SELECT  Id,
                                        Profile.PermissionsModifyAllData
                                FROM    User
                                WHERE   Profile.PermissionsModifyAllData = true
                                AND     IsActive = true
                                AND     Id != :currentUserId
        ];

        //if admin users are present then run as admin user
        if(adminUsers.size() > 0) {
            System.runAs(adminUsers[0]) {

            Id acRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Carrier_Service').getRecordTypeId();

            Account ac = new Account(Name = 'Test Ac', RecordTypeId = acRecordTypeId);
            insert ac;

            Opportunity testopNew = new Opportunity
                        (Name = 'testOpps', AccountId = ac.Id, Opportunity_Type__c ='New', CloseDate= Date.today(), StageName = 'Won');
            insert testopNew;

            Opportunity testopRenew = new Opportunity
            (Name = 'testOpps', AccountId = ac.Id, Opportunity_Type__c ='Renewal', CloseDate= Date.today(), StageName = 'Won');
            insert testopRenew;

            Product2 prod = new Product2(Name = 'Laptop X200',Family = 'Hardware');
            insert prod;

            Id pricebookId = Test.getStandardPricebookId();

            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert pbe;

            List<OpportunityLineItem> testOppLineItems = new List<OpportunityLineItem>();
            for(Integer i=0;i<2;i++) {
                testOppLineItems.add(new OpportunityLineItem(
                                            PricebookEntryId = pbe.Id,
                                            OpportunityId = testopNew.Id, TotalPrice = 33,
                                            Quantity = 5, Renewal_MRR__c = 33, CPQ_NetNewMRR__c = 333));
            }
            insert testOppLineItems;

            List<OpportunityLineItem> testOppLineItemsRenewal = new List<OpportunityLineItem>();
            for(Integer i=0;i<2;i++) {
                testOppLineItemsRenewal.add(new OpportunityLineItem(
                                            PricebookEntryId = pbe.Id,
                                            OpportunityId = testopRenew.Id, TotalPrice = 1,
                                            Quantity = 3, Renewal_MRR__c = 344, CPQ_NetNewMRR__c = 12));
            }
            insert testOppLineItemsRenewal;
            }
        }
    }

    @isTest static void prodRevenueOppUpdateBatchTest() {
        Test.startTest();
        ProdRevenueOppUpdateBatch batch= new ProdRevenueOppUpdateBatch();
        Id jobid= Database.executeBatch(batch,20);
        Test.stopTest();

        List<Opportunity> oppNew =
                                [SELECT Id,
                                        Opportunity_Type__c,
                                        Rev_Net_New_MRR__c,
                                        Net_New_MRR__c,
                                        Renewal_MRR__c,
                                        Rev_Renewal_MRR__c,
                                        Rev_Incremental_MRR__c
                                FROM    Opportunity
                                WHERE   Opportunity_Type__c = 'New'];

        Assert.areEqual(oppNew[0].Rev_Net_New_MRR__c, oppNew[0].Net_New_MRR__c,'Rev_Net_New_MRR__c and Net_New_MRR__c should be same');
        Assert.areEqual(oppNew[0].Rev_Renewal_MRR__c, oppNew[0].Renewal_MRR__c,'Rev_Renewal_MRR__c and Renewal_MRR__c should be same' );

        List<Opportunity> oppRenewal =
                                [SELECT Id,
                                        Opportunity_Type__c,
                                        Rev_Net_New_MRR__c,
                                        Net_New_MRR__c,
                                        Renewal_MRR__c,
                                        Rev_Renewal_MRR__c,
                                        Rev_Incremental_MRR__c
                                FROM    Opportunity
                                WHERE   Opportunity_Type__c = 'Renewal'];

        Assert.areEqual(oppRenewal[0].Rev_Incremental_MRR__c, oppRenewal[0].Net_New_MRR__c, 'Rev_Incremental_MRR__c and Net_New_MRR__c should be same');
        Assert.areEqual(oppRenewal[0].Rev_Renewal_MRR__c, oppRenewal[0].Renewal_MRR__c,'Rev_Renewal_MRR__c and Renewal_MRR__c should be same' );
    }
}