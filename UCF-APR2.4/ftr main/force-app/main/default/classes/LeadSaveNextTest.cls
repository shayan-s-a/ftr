/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class LeadSaveNextTest {
    
    static testMethod void getLeadsTest(){
        Lead testLead = new Lead();
        String recordTyepId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Alt Channel').getRecordTypeId();
                
        testLead.RecordTypeId = recordTyepId;
        testLead.FirstName= 'FName';
        testLead.LastName = 'LName';
        testLead.Company = 'Test Company';
        testLead.Email = 'TestEmail@testemail.com';
        insert testLead;
        List<Id> LeadIds = LeadSaveNext.getLeads();
    }

}