/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class FTRWSCVDRatesResponseTest {

    @isTest
    public static void TestFTRWSCVDRatesResponse() {
        Test.startTest();
        FTRWSCVDRatesResponse cvdRatesResp = new FTRWSCVDRatesResponse();
        cvdRatesResp.Address = new FTRWSCVDAddress();
        cvdRatesResp.error = new FTRWSCVDError();
        cvdRatesResp.Rate = new List<FTRWSCVDRate>();
        Test.stopTest();
    }
}