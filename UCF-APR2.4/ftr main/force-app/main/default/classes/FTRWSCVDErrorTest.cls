/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class FTRWSCVDErrorTest {

    @isTest
    public static void TestFTRWSCVDError(){
        Test.startTest();
    	FTRWSCVDError error = new FTRWSCVDError();
        error.message = 'Clli not found';
        error.status = 'Internal Server Errror occured';
        error.statusCode = '500';
        Test.stopTest();
	}
    
}