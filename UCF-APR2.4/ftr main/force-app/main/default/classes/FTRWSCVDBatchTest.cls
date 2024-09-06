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
public class FTRWSCVDBatchTest {
    
    @testSetup static void methodName() {
     Id carrierRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
    Account acc = new Account();
    acc.Name='testAccount';
    acc.RecordTypeId = carrierRecId;
    insert acc;
    
    
 Opportunity opp = new Opportunity();
    opp.Name='Test Opp';
    opp.StageName='Decision';
    opp.AccountId=acc.id;
    //opp.Wholesale_ACNA__c=;
    //opp.Wholesale_Pnum__c=;
    opp.CloseDate= System.today();
    opp.ForecastCategoryName='Commit';
    insert opp;
        
        FTRWSAcna__c ac = new FTRWSAcna__c();
        ac.Name ='GIM';
        ac.ACNA__c='GIM';
        ac.Company__c=acc.id;
       insert ac;
}
    
    public static testmethod void getPnumsTest(){
        String acna = 'GIM';
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new FTRWSCVDPnumsMock());
        FTRWSCVDBatch btch = new FTRWSCVDBatch();
        database.executeBatch(btch, 200);
        Test.stopTest();
        
    }
    public static testmethod void getPnumsTest1(){
        String acna = 'GIM';
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new FTRWSCVDPnumsMock());
        FTRWSCVDBatchScheduler btch = new FTRWSCVDBatchScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('FTRWSCVDBatchSchedule', sch, btch);
        Test.stopTest();
        
    }
    
}