/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
**/
@isTest
public class FTRWSCVDInterfaceTest {

    @isTest
    public static void testGetCVDRates() {
		Test.setMock(HttpCalloutMock.class, new FTRWSCVDRatesMock());

        FTRWSCVDRatesRequest request = new FTRWSCVDRatesRequest();
        request.address = '434 Park Street';
        request.city = 'Cherryvale';
        request.stateCd = 'KS';
        request.cntrlKey = '5299';
        request.pNUM = 'EIA001AKQSCM326';
        request.swc = 'ABDLFLXA';
        //request.quoteLineId = null; //change this later when we start creating new quotes/quotelineid
        FTRWSCVDInterface.getCVDRates(request);
    }
    
        @isTest
    public static void testGetPNUMs() {
        Test.setMock(HttpCalloutMock.class, new FTRWSCVDPNumsMock());
        String acna = 'GIM'; 
        String actualValue = FTRWSCVDInterface.getPNUMs(acna);//(new FTRWSCVDRatesRequest());
        //System.assert(
    }
    
   /* public static void testGetPNUMs() {
        String acna = 'GIM';
        Test.startTest();
        FTRWSCVDInterface.getPNUMs(acna);
        Test.stopTest();
    }
    
    public static void testGetPNUMEndPoint() {
        String acna = 'GIM';
        Test.startTest();
        FTRWSCVDInterface.getPNUMEndPoint();
        Test.stopTest();
    }*/

}