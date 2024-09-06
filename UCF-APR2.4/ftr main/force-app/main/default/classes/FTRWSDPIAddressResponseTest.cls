/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class FTRWSDPIAddressResponseTest {

        @isTest
    public static void TestFTRWSDPIAddressResponse(){
        Test.startTest();
        FTRWSDPIAddressResponse dpiResp = new FTRWSDPIAddressResponse();
        dpiResp.status = 'SUCCESS';
    dpiResp.addressLine1 = '1401 S MACARTHUR BLVD '; //for display purpose
    //1401 S MACARTHUR BLVD IRVING TX 75060
    dpiResp.streetNumber='1401'; //for sending in the dpi request after updating any address fields
    dpiResp.streetName = 'MACARTHUR';
    dpiResp.streetSuffix= 'BLVD';
    
    dpiResp.preDirectional = 'S';
    
    dpiResp.unit = '101'; //for display purpose
    dpiResp.secondaryDesignator = 'SOMETHING';
    dpiResp.secondaryNumber = '111';
    
    dpiResp.cityName = 'IRVING';
    dpiResp.state = 'TX';
    dpiResp.zipCode = '75060';
    dpiResp.svcControlNo = '4178385';
    dpiResp.wirecenter = '972513';
    dpiResp.clliCode = 'IRNGTXXDDS0'; 
    
    dpiResp.disableSave = false; 
    dpiResp.latitude = '32.7999746'; 
    dpiResp.longitude = '-96.9600006'; 

        
        Test.stopTest();
    }
}