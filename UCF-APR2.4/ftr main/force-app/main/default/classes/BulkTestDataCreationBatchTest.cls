/**
 * @description       : This test class covers the Apex class:
 *      BulkTestDataCreationBatch
 * 
**/@isTest
public class BulkTestDataCreationBatchTest {

    @TestSetup
    static void setup(){
        List<Account> globalAccountsToInsert = new List<Account>();

       for(Integer i = 1; i <= 20; i++) {
           Account newAccount = new Account(
               Name = 'DevTest12 - Global Company - ' + i,
               RecordTypeId = '0128a000000tj2qAAA'
           );
           globalAccountsToInsert.add(newAccount);
       }
       insert globalAccountsToInsert;
       
       TriggerSettings__c triggerSettings = new TriggerSettings__c(
            Name = 'Test Trigger Settings',
            OpportunityTriggerDisabled__c = false
        );
        insert triggerSettings;
    }
    
    static testMethod void testGenerateData() {
        Test.startTest();
        BulkTestDataCreationBatch.generateData();
        Database.executeBatch(new BulkTestDataCreationBatch(), 50);
        Test.stopTest();
    }
}