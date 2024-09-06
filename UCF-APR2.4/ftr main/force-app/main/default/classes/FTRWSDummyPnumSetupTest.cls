/**
* @description       : This test class covers the following Apex classes:
*      FTRWSDummyPnumSetup
*      TBD_CLASS2
*      TBD_CLASS3
* @author            : TBD
* @version           : 5 
*
**/
@isTest
public class FTRWSDummyPnumSetupTest {
    
    @testSetup static void makeData() {
         Id carrierRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierRecId;
        insert acc;
        
        FTRWSAcna__c acna = new FTRWSAcna__c();
        acna.Name = 'GIM';
        acna.Company__c = acc.id;
        insert acna;
        
        FTRWSAcna__c acna2 = new FTRWSAcna__c();
        acna2.Name = 'ATX';
        acna2.Company__c = acc.id;
        insert acna2;
        
        FTRWSPnum__c pnumObj1 = new FTRWSPnum__c();
        pnumObj1.PNum__c = 'EDGECOLOBASICICB';
        pnumObj1.Name = 'EDGECOLOBASICICB';
        pnumObj1.Wholesale_ACNA__c = acna.Id;
        insert pnumObj1;
        
        FTRWSPnum__c pnumObj2 = new FTRWSPnum__c();
        pnumObj2.PNum__c = 'DKFIBERBASICICB';
        pnumObj2.Name = 'DKFIBERBASICICB';
        pnumObj2.Wholesale_ACNA__c = acna.Id;
        insert pnumObj2;        
        
    }
    
    @isTest
    public static void codeCoverage() {
        Test.startTest();
        FTRWSDummyPnumSetup.createDummyPnumsForWholsaleACNA();
        Test.stopTest();
    }
    
}