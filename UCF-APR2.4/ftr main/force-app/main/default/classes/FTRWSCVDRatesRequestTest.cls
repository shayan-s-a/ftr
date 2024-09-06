/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class FTRWSCVDRatesRequestTest {

    @isTest
    public static void TestFTRWSCVDRatesRequest() {
        Test.startTest();
        Opportunity opp = new Opportunity();
        opp.StageName = 'Investigating';
        opp.CloseDate= System.today();
        opp.Name = 'TestOpp';
        insert opp;
        FTRWSCVDRatesRequest req = new FTRWSCVDRatesRequest();
        FTRWSAddress__c address = new FTRWSAddress__c();
        address.Opportunity_ID__c = opp.Id;
        insert address;
        req.addressId=address.Id;
        req.pNUM=''; 
        
        req.locTier=''; 
        req.region='';
        req.spec='';
    
        req.los='';
        req.vta=''; 
        
        req.product=''; 
        req.serviceTierPort='';
        req.circuitType='';
        
        req.usocTier='';
        req.usocType=''; 
        req.uniSpeed=''; 
        req.evcSpeed='';
        req.nrcUsoc='';
    
        req.mrcUsoc='';
        req.cntrlKey=''; 
        
       
        req.address='';
        req.city=''; 
        req.stateCd=''; 
        req.swc='';
        Test.stopTest();
    }
}