/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class ftr_addressBeanTest {
    
    @isTest
    public static void ftradressBeanTest(){
        Test.startTest();
        ftr_addressBean adBean = new ftr_addressBean();
        adBean.addressLine1 = '1123';
        adBean.cityName = 'NYC';
        adBean.state = 'NY';
        adBean.zipCode = '1234';
        Test.stopTest();
    }
}