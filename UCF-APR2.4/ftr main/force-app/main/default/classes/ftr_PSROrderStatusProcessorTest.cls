/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class ftr_PSROrderStatusProcessorTest {
    @testSetup static void setUpData(){
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        Order[] oList = ftr_TestDataFactory.getOrders(1);
		insert oList;
		insert new Service_Order__c(Name='3364347', Order__c=oList[0].Id);
	}
    static testMethod void myUnitTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 		//Order[] oList = ftr_TestDataFactory.getOrders(1);
        //insert oList;
        //insert new Service_Order__c(Name='3364347', Order__c=oList[0].Id);
        req.addHeader('httpMethod', 'POST'); 
        req.requestUri = '/services/apexrest/M6OrderStatusUpdateService/';       
        String postData = '{"ApplicationId__c":"M6","EmployeeId__c":"12345","UserId__c":"app_int","OrderType__c":"PSR","OrderDescription__c":"PSR","PSROrderId__c":"3364347","PSROrderStatus__c":"Complete","CircuitId__c":"4CUXP714389abcFTN","DueDate__c":"2020-03-31","PurchaseOrderNumber__c":"FCA10018945I1N"}';
        req.requestBody = Blob.valueof(postData);
        System.debug('requestbody'+postData);
        
        RestContext.request = req; 
        
        RestContext.response= res;
        
        ftr_PSROrderStatusProcessor.UpdateOrder();
        
        Test.stopTest();
    }
}