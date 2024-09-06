/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
private class QuoteOpportunityUnlockControllerTest {
    
  
     static testmethod void unlockOpportunity_Test(){
	 Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Approved', CloseDate = Date.valueOf('2020-09-23'),Reason_Won_Lost__c = 'Other',Other_Reason_Lost_Details__c = 'Other');
     insert opp;
     approval.lock(opp.id);
     
	 Quote qt = new Quote (Name = 'Test Quote',Order_Opportunity_Unlocked__c = false, OpportunityId =opp.id);
	 insert qt;
       
        test.startTest();
        QuoteOpportunityUnlockController.unlockOpportunity(qt.id);
        test.stopTest();

    }
    
}