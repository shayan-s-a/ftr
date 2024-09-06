/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class FTRCVDAddressTest {

    @isTest
    public static void ftrCVDAdressBeanTest(){
        Test.startTest();
    	FTRWSCVDAddress cvdAddress = new FTRWSCVDAddress();
        cvdAddress.address = '';
        cvdAddress.city = '';
        cvdAddress.stateCd = '';
        cvdAddress.zipCd = '';
        cvdAddress.swc = '';
        cvdAddress.lookUpUsed = '';
        Test.stopTest();
	}
    
}