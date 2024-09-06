@IsTest
private class ftr_DeleteTestDataBatchJobTest {

    @TestSetup
    static void makeData(){
        insert ftr_TestDataFactory.getQLI(1, 1);
    }

    @IsTest
    static void deleteTestData(){
		Opportunity opp = [SELECT Account.Name FROM Opportunity LIMIT 1];        
        Test.startTest();
        ftr_DeleteTestDataBatchJob.deleteTestData(opp.Account.Name, true);
        Test.stopTest();
    }
    
    @IsTest
    static void deleteTestDataError1(){
        
        Test.startTest();
        try {
            ftr_DeleteTestDataBatchJob.deleteTestData(null, true);
        } catch (Exception e) {
            System.debug('Exception is expected here.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void deleteTestDataError2(){
        
        Test.startTest();
        try {
            ftr_DeleteTestDataBatchJob.deleteTestData('abcd', false);
        } catch (Exception e) {
            System.debug('Exception is expected here.');
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void deleteTestDataError3(){
		Opportunity opp = [SELECT Account.Name FROM Opportunity LIMIT 1];    
        Test.startTest();    
        ftr_DeleteTestDataBatchJob deletejob = new ftr_DeleteTestDataBatchJob(opp.Account.Name);
        deletejob.exceptions.add(new ftr_DeleteTestDataBatchJob.DeleteDataException('Error!!!'));
        Database.executeBatch(deletejob);
        Test.stopTest();
    }
}