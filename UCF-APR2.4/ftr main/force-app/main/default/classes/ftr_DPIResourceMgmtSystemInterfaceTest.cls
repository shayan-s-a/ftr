/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
**/
@isTest
public class ftr_DPIResourceMgmtSystemInterfaceTest {
    
    @isTest
    public static void invokeTest(){
        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();
        inputMap.put('addressBean', new ftr_addressBean());
        inputMap.put('wirecenter', 'test');
        inputMap.put('env', 'test');
        inputMap.put('maxTnNumbers', 12);
        inputMap.put('tn', 'test');
        Test.startTest();
            //ftr_DPIResourceManagmentSystemInterface dpi = new ftr_DPIResourceManagmentSystemInterface();
            Test.setMock(WebServiceMock.class, new ftr_WebServiceMockImpl());
            ftr_DPIResourceManagmentSystemInterface.invoke('retrieveCustomerFacilities', inputMap);
            ftr_DPIResourceManagmentSystemInterface.invoke('reserveTelephoneNumber', inputMap);
            ftr_DPIResourceManagmentSystemInterface.invoke('findAvailableTelephoneNumbers', inputMap);
        Test.stopTest();
    }
    
    @isTest
    public static void testCustomerFacilityTest(){
        Test.startTest();
            Test.setMock(WebServiceMock.class, new ftr_WebServiceMockImpl());
            ftr_DPIResourceManagmentSystemInterface.testCustomerFacility(); 
        Test.stopTest();
    }
    @isTest
    public static void testRetrievePrefferedExchange(){
        Test.startTest();
           // Test.setMock(WebServiceMock.class, new ftr_WebServiceMockImpl());
            ftr_DPIResourceManagmentSystemInterface.testRetrievePreferredExchange();
        Test.stopTest();
    }
    @isTest
    public static void testFindAvailableTnsTest(){
        Test.startTest();
            Test.setMock(WebServiceMock.class, new ftr_WebServiceMockImpl());
            ftr_DPIResourceManagmentSystemInterface.testFindAvailableTns();
        Test.stopTest();
    }
    
 /*   @isTest
    public static void testReserveTelephoneNumberTest(){
        Test.startTest();
            Test.setMock(WebServiceMock.class, new ftr_WebServiceMockImpl());
            ftr_DPIResourceManagmentSystemInterface.testReserveTelephoneNumber();
        Test.stopTest();
    }*/
}