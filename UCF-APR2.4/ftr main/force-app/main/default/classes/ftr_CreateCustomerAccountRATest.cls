/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
private class ftr_CreateCustomerAccountRATest {

    @isTest
    static void createCustomerAccountSuccessTest(){
        Test.setMock(WebServiceMock.class, new ftr_CreateCustomerAccountWSMock());
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        inputMap.put('AccountId', 'JOE1');
        inputMap.put('AccountName', 'Joes Garage #191002');
        inputMap.put('ShippingStreet', '1112 Jefferson');
        inputMap.put('ShippingStateCode', 'NY');
        inputMap.put('ShippingPostalCode', '14623');
        inputMap.put('ShippingCity', 'Rochester');

        ftr_CreateCustomerAccountRA createCust = new ftr_CreateCustomerAccountRA();
        Boolean result;
        Test.startTest();
        result = createCust.invokeMethod('createCustomerAccount',inputMap, outputMap, options);
        Test.stopTest();

        System.assertEquals(true,result);
    }

    @isTest
    static void createCustomerAccountFailureTest(){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        inputMap.put('AccountId', 'JOE1');
        inputMap.put('AccountName', 'Joes Garage #191002');
        inputMap.put('ShippingStreet', 'Jefferson');
        inputMap.put('ShippingStateCode', 'NY');
        inputMap.put('ShippingPostalCode', '14623');
        inputMap.put('ShippingCity', 'Rochester');
        inputMap.put('QuoteType', 'Install');

        ftr_CreateCustomerAccountRA createCust = new ftr_CreateCustomerAccountRA();
        Boolean result;

        Test.startTest();
        result = createCust.invokeMethod('createCustomerAccount',inputMap, outputMap, options);
        Test.stopTest();

   //     System.assertEquals(false,result);
    }


    @isTest
    static void createCustomerAccountNullInput(){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        ftr_CreateCustomerAccountRA createCust = new ftr_CreateCustomerAccountRA();
        Boolean result;

        Test.startTest();
        result = createCust.invokeMethod('createCustomerAccount',inputMap, outputMap, options);
        Test.stopTest();

       // System.assertEquals(false,result);

    }

    @isTest
    static void incorrectMethodName(){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        ftr_CreateCustomerAccountRA createCust = new ftr_CreateCustomerAccountRA();
        Boolean result;

        Test.startTest();
        result = createCust.invokeMethod('createCustomer',inputMap, outputMap, options);
        Test.stopTest();

        System.assertEquals(true,result);

    }

}