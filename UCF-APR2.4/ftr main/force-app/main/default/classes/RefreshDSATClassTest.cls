/**
* @author Rishu Singla
* @date 15 Oct 2019
* @group Vlocity Refresh DSAT Class
* @description Test class for logic needed for Refresh of DSAT Class 
* @version 1
*/  
@isTest
public class RefreshDSATClassTest {

    @isTest
    static void getRefreshAPIDetailsTest(){
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        Map<String, Object> inputMapToUpdate = new Map<String, Object>();
        
        String methodName='getRefreshAPIDetails';
        String methodName1='DSAT_AddLocation';
        RefreshDSATClass rdc = new RefreshDSATClass();
        vlocity_cmt.IntegrationProcedureService intgProSer = new vlocity_cmt.IntegrationProcedureService();
        
        // Create Account
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
		Account globalAcc1 = new Account();
		globalAcc1.Name = 'GLOBAL ACCOUNT';
		globalAcc1.RecordTypeId = globalRecId;
		//globalAcc.RecordTypeId = '012E0000000fDc3IAE';
		insert globalAcc1;
		Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account();
        testAccount.RecordTypeId = MasterRTId;
		testAccount.ParentId = globalAcc1.Id;
        testAccount.Name = 'Test Account';
        testAccount.BillingStreet = '123 Main Street';
        testAccount.BillingCity = 'Anywhere';
        testAccount.BillingState = 'Ohio';
        testAccount.BillingPostalCode = '44088';
        testAccount.ShippingStreet = '123 Main Street';
        testAccount.ShippingCity = 'Anywhere';
        testAccount.ShippingState = 'Ohio';
        testAccount.ShippingPostalCode = '44088';
        insert testAccount;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'RefreshTestOpp';
        opp.AccountId = testAccount.id;
        Date d1=Date.newInstance(2019, 05, 11);
        opp.CloseDate=d1;
        opp.StageName='Investigating';
        opp.CPE_Product__c='No';
        insert opp;
        
        vlocity_cmt__Premises__c oPremise = new vlocity_cmt__Premises__c();
        oPremise.vlocity_cmt__Address1__c = '123 Main Street';
        oPremise.vlocity_cmt__City__c = 'Anywhere';
        oPremise.vlocity_cmt__State__c = 'California';
        oPremise.vlocity_cmt__PostalCode__c = '44076';
        oPremise.vlocity_cmt__Status__c = 'Connected';
        oPremise.DSAT_Ticket__c = '211212';
        oPremise.Copper_Tier__c = 'Tier 1';
        oPremise.Fiber_Tier__c = 'Tier 1';
        oPremise.Last_DSAT_Check__c = system.today();
        oPremise.WC_QOS__c = 'Platinum';
        oPremise.WC_Speed__c = '1000MB';
        oPremise.Market__c = 'B';
        oPremise.Level__c = 'a';
		insert oPremise;   
 
        input.put('ParentAccountId',opp.AccountId);
        input.put('ContextId',opp.Id);
        input.put('PremisesId', oPremise.Id);
        input.put('State','California');
        input.put('OpportunityId', opp.Id);
        
        //WHEN
        Test.startTest();
        Boolean bResult = rdc.invokeMethod(methodName, input, outMap, options);
        Test.stopTest();
    }
}