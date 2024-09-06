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
public class SterlingQuote_Extension_Test {
	public static testMethod void TestSterlingQuote_Extension() {
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
         
        Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Master' LIMIT 1]?.Id;
        
		Account objAcc = new Account();
        objAcc.Name ='testing Name';
        objAcc.Legal_Street__c='test';
        objAcc.Legal_City__c='test';
        objAcc.Legal_State__c='test';
        objAcc.ShippingStreet='test';
        objAcc.ShippingCity='NY';
        objAcc.ShippingState='New York';
        objAcc.BillingStreet='test';
        objAcc.BillingCity='NY';
        objAcc.BillingState='New York';
        objAcc.RecordTypeId=masterRecId;
        objAcc.ParentId = globalAcc.Id;
        
        insert objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name ='Testing Name';
        objOpp.AccountId= objAcc.Id;
        objOpp.CloseDate = date.today();
        objOpp.StageName ='Verbal Commit';
        objOpp.Expected_Billed_Date__c = date.today();
        insert objOpp;
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'Sterling' AND SobjectType = 'SterlingQuote__c'];        
        SterlingQuote__c objquote = new SterlingQuote__c();
        objquote.Name='Testing Name';
        objquote.ExpirationDate__c=date.today();
        objquote.OpportunityId__c=objOpp.id;
        objquote.Account_Name__c= objAcc.Id;
        objquote.RecordTypeId = recordtypeid[0].Id; 
        insert objquote;   
		Test.startTest();
		PageReference pageRef = Page.SterlingQuote;
		Test.setCurrentPage(pageRef);

		ApexPages.currentPage().getParameters().put('AccountId', objquote.Account_Name__c);
		ApexPages.currentPage().getParameters().put('OpportunityId', objquote.OpportunityId__c);
		ApexPages.currentPage().getParameters().put('AddressType', 'Billing');
		ApexPages.currentPage().getParameters().put('OptionType', 'NQ');
		
		SterlingQuote_Extension sqe = new SterlingQuote_Extension();
        sqe.navigateToOpportunity();
        Test.stopTest();
	}
}