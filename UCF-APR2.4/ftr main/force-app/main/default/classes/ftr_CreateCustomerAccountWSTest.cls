/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2.0 
**/
@isTest
private class ftr_CreateCustomerAccountWSTest {

    @isTest
    static void createCustomerAccountSuccessTest(){
        Test.setMock(WebServiceMock.class, new ftr_CreateCustomerAccountWSMock());
        
        Map<String, Object> inputMap = new Map<String, Object>();
        
        inputMap.put('AccountId', 'JOE1');
        inputMap.put('AccountName', 'Joes Garage #191002');
        inputMap.put('ShippingStreet', '1112 Jefferson');
        inputMap.put('ShippingStateCode', 'NY');
        inputMap.put('ShippingPostalCode', '14623');
        inputMap.put('ShippingCity', 'Rochester');

        ftr_CreateCustomerAccountWS createCustAcc = new ftr_CreateCustomerAccountWS();
        String custAcctNbr;   
        Test.startTest();
        custAcctNbr = createCustAcc.createCustomerAccount(inputMap);
        Test.stopTest();

        System.assertEquals(null,custAcctNbr);
    }

    @isTest
    static void incorrectStreenName(){
        Test.setMock(WebServiceMock.class, new ftr_CreateCustomerAccountWSMock());

        Map<String, Object> inputMap = new Map<String, Object>();

        inputMap.put('AccountId', 'JOE1');
        inputMap.put('AccountName', 'Joes Garage #191002');
        inputMap.put('ShippingStreet', 'Jefferson');
        inputMap.put('ShippingStateCode', 'NY');
        inputMap.put('ShippingPostalCode', '14623');
        inputMap.put('ShippingCity', 'Rochester');

        String error = 'Incorrect Street Name : Ending position out of bounds: -1';
        ftr_CreateCustomerAccountWS createCustAcc = new ftr_CreateCustomerAccountWS();
  
        Test.startTest();
        try {
            createCustAcc.createCustomerAccount(inputMap);
        } catch(Exception e){
            System.assertEquals(error,e.getMessage());
        }
        Test.stopTest();

    }
    

}