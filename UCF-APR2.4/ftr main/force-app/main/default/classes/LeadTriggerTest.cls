/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class LeadTriggerTest
{
    @isTest
    public static void testLeadInsert ()
    {
        Test.startTest();
        Date dt = DateTime.now().Date();
        //Id recId = [SELECT Id, Name FROM RecordType Where name = 'Alt Channel - OTM' Limit 1].Id;
        Id recId = [SELECT Id, Name FROM RecordType Where name = 'Alt Channel' Limit 1].Id;
	    Lead objLead = new Lead (LastName = 'Test data', 
                                 Email = 'test@gmail.com', 
                                 mobilephone = '+1234567890', 
                                 Company = 'Test company',
                                 Status = 'Open',
                                 Reason_made_with_targeted_account__c = 'No Answer',
                                 Q5_Outcome_with_non_DM__c = 'DM Unavailable',
                                 Follow_Up_Appt_Date__c = dt.addDays(-2),
                                 RecordtypeId = recId);
		Database.SaveResult result = Database.insert(objLead, false);
		Test.stopTest();
    }
}