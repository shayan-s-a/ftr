/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
**/
@isTest
public class FTRWSCVDProductResponseTest {

    @isTest
    public static void TestCVDProductResponse() {
        Test.startTest();
        FTRWSCVDProductResponse cvdProdResponse = new FTRWSCVDProductResponse();
        cvdProdResponse.error = new FTRWSCVDError();
        cvdProdResponse.items = new List<WSCatalogItems>();
        cvdProdResponse.cvdLookupUsed = 'CLLICd';
        cvdProdResponse.cvdPriceTier = '1';
        Test.stopTest();
    }
}