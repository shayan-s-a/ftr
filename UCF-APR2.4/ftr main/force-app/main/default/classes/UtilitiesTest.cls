/********************************************************************************************
Latest Modification By : Mehedi Hasan (mehedi.hasan@ftr.com)
Targeted Deployment Date:  7th September, 2023.
Description : Updated for code coverage v4
********************************************************************************************/
@isTest(seeAllData = true)
public class UtilitiesTest{
        @IsTest
    public static void isNumericOrDecimal_Test() {
        System.assert(Utilities.isNumericOrDecimal('1.1'), 'WHEN passed 1.1 THEN isNumericOrDecimal should return true but returned false.');
        System.assert(Utilities.isNumericOrDecimal('1'), 'WHEN passed 1 THEN isNumericOrDecimal should return true but returned false.');
        System.assert(!Utilities.isNumericOrDecimal('1.1.1'), 'WHEN passed 1.1.1 THEN isNumericOrDecimal should return false but returned true.');
        System.assert(!Utilities.isNumericOrDecimal('one'), 'WHEN passed one THEN isNumericOrDecimal should return false but returned true.');
    }
    public static testMethod void testUtilitys(){

        List<String> tes31 = Utilities.getFieldList('Opportunity');
        List<String> test2 = Utilities.getFieldList(null);
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
		Account globalAcc1 = new Account();
		globalAcc1.Name = 'GLOBAL ACCOUNT';
		globalAcc1.RecordTypeId = globalRecId;
		//globalAcc.RecordTypeId = '012E0000000fDc3IAE';
		insert globalAcc1;
		Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;

        Account a1 = new Account(Name = 'Test name for Account',phone = '585-777-777',memo__c ='inserted');
        a1.RecordTypeId = MasterRTId;
		a1.ParentId = globalAcc1.Id;
        insert a1;

        Opportunity o2 = new Opportunity(AccountId=a1.id, Name='Test Opp',StageName='Prospecting', CloseDate=Date.today(),memo__c ='inserted');
        insert o2;

        Opportunity o3 = o2;
        ApexPages.Standardcontroller stdcon12 = new ApexPages.Standardcontroller(o2);
        OpportunityOverride  qObj = new OpportunityOverride(stdcon12);
        qObj.getSavedMemoList();
        qObj.selectedSavedMemo = 'Sample Text';
        // qObj.getSelectedMemoList();

        o2.StageName='ClosedWon';
        // o2.memo__c = 'update Text';
        o2.Reason_Won_Lost__c = 'Dont know';
        update o2;

        opportunity objopportunity= new opportunity(AccountId=a1.Id);
        objopportunity.Name ='testing opp';
        objopportunity.StageName='verbal commit'; 
        objopportunity.CloseDate= date.today();
        objopportunity.Expected_Billed_Date__c = date.today();
        insert objopportunity;
        SterlingQuote__c objSQ = new SterlingQuote__c();
        objSQ.Name='Testing Name';
        objSQ.ExpirationDate__c = date.today();
        objSQ.OpportunityId__c = objopportunity.Id;
        objSQ.Account_Name__c = a1.id;

        insert objSQ;

        SterlingQuoteItem__c objLineItem = new SterlingQuoteItem__c();
        objLineItem.Quantity__c=10;
        objLineItem.TermLength__c=24;
        objLineItem.StandardMRC__c = 10;
        objLineItem.StandardNRC__c = 10;
        objLineItem.AdjustedMRC__c = 10;
        objLineItem.AdjustedNRC__c = 10;
        objLineItem.Locality__c = 'Indiana';
        objLineItem.StateProvince__c ='IN';
        objLineItem.ItemCode__c ='123';
        objLineItem.ApprovalTerritory__c ='Indiana';
        objLineItem.ApprovalRegion__c='central';
        objLineItem.NPA__c ='10';
        objLineItem.NXX__c = '10';
        objLineItem.IsInFrontierFootprint__c = false;
        objLineItem.SterlingQuote__c = objSQ.id;
        insert objLineItem;

        SterlingQuoteItem__c sqiTest = [SELECT id, name, SterlingQuote__c, ShanePoke__c FROM SterlingQuoteItem__c ORDER BY createddate DESC LIMIT 1];
        sqiTest.name = sqiTest.name + 'test';
        sqiTest.ShanePoke__c = ''+System.Now();
        update sqiTest;

        Utilities.setOpportunityLineItem(null, sqiTest, false, o2.Id, null, 'test');

        Utilities.delLineItem(sqiTest.Id+'', sqiTest.SterlingQuote__c+'');

        //End of Test Calls for all Methods in Utilities Class
    }
}