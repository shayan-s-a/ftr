/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
private class SchedulerforOpportunityLockBatchJobTest {
    
  
     static testmethod void SchedulerforOpportunityLockBatchJob_Test(){
	 Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Approved', CloseDate = Date.valueOf('2020-09-23'),Reason_Won_Lost__c = 'Other',Other_Reason_Lost_Details__c = 'Other');
     insert opp;
     approval.lock(opp.id);
     
	 Quote qt = new Quote (Name = 'Test Quote',Order_Opportunity_Unlocked__c = true, OpportunityId =opp.id);
	 insert qt;
       
        test.startTest();
		SchedulerforOpportunityLockBatchJob  reminder = new SchedulerforOpportunityLockBatchJob();
		String str = '0 0 22 * * ?';
		String jobID = System.schedule('Schedule to run OpportunityLockBatchJob',str, reminder);   

        test.stopTest();

    }
    
}