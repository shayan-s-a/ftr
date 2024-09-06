/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class FTRWSAddressResponseTest {

      @isTest
    public static void TestFTRWSAddressResponse() {
        Test.startTest();
        FTRWSAddressResponse response = new FTRWSAddressResponse();
        response.dpiResponseList = new List<FTRWSDPIAddressResponse>();
        response.dsatResponse = new FTRWSDSATAddressResponse();
        response.dpiSuccess = true;
        response.dsatSuccess = true;
        response.multipleDPIResults = true;
        Test.stopTest();
    }
}