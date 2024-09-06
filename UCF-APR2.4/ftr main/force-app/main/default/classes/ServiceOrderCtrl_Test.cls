/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
 * 
**/
@isTest
private class ServiceOrderCtrl_Test {
	@testSetup static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        
        /*Service_Order_Configuration__c soc = new Service_Order_Configuration__c();
        soc.Name = 'Settings';
        soc.ApiKey__c  = 'test';
        soc.EndPoint__c = 'https://api-qat03.frontier.com/m6service/v1/orders';
        soc.Password__c  = 'test';
        soc.UserName__c = 'test';
        insert soc;*/
        
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
        
        Account acc =new Account();
        acc.Name = 'testAcc';
        acc.ParentId = globalAcc.Id;
        insert acc;
        
        Order order = new Order();
        order.Name = 'testOrder';
        order.AccountId = acc.Id;
        order.EffectiveDate = System.today(); 
        order.Status  = 'Draft'; 
        insert order;
        
        Service_Order__c  so = new Service_Order__c();
        so.Order_Number__c = '123';
        so.Name = '1234567'; 
        so.Order__c = order.Id;
        so.RecordTypeId = [select id from RecordType where DeveloperName='M6_Service_Order'].Id;
        so.Item_Spec_Id__c = '1101';
        so.Is_Created_By_Velocity__c = true;
        insert so; // Complete
    }
    @isTest static void updateOrderStatus_Test() {
        Service_Order__c so = [select Id,Name from Service_Order__c limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        
        Test.startTest();
        	//ServiceOrderStage_Ctrl.updateSOStage(so.Id,so.Name);
        	ServiceOrderCtrl.syncServiceOrder(so);
        Test.stopTest();
		system.assertEquals('Stage 1 - Order Entry', [select Service_Order_Stage__c from Service_Order__c limit 1].Service_Order_Stage__c);
    }
    @isTest static void updateOrderStatus_Test_WithError() {
        Service_Order__c so = [select Id,Name from Service_Order__c limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Test'));

        Test.startTest();
            try{
                ServiceOrderStage_Ctrl.updateSOStage(so.Id,so.Name);
                //ServiceOrderCtrl.syncServiceOrder(so);
            }catch(Exception ee){
                system.debug('test res :: '+ee.getMessage());
                system.assert(ee.getMessage().contains('DML ERROR'));
            }
        Test.stopTest();
    } 
    @isTest static void returnServiceOrders_Test(){
        ServiceOrderCtrl.data data = ServiceOrderCtrl.returnServiceOrders([select id from order Limit 1].id);
        system.assertEquals(1, data.lstSo.size());
    }
   @isTest static void serviceOrder_Batch_Test(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        Test.startTest();
        	database.executeBatch(new ServiceOrder_Batch(null),50);
        Test.stopTest();
    }
    @isTest static void serviceOrder_Batch_Test_ForAllSOs(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        Test.startTest();
        	database.executeBatch(new ServiceOrder_Batch('All'),50);
        Test.stopTest();
    }
    /*@isTest static void serviceOrder_Batch_Sch_Test(){
        String CRON_EXP = '0 0 * * * ?';
        ServiceOrder_Batch_Sch sch = new ServiceOrder_Batch_Sch();
        system.schedule('Test Hourly sync service order from M6', CRON_EXP, sch);
    }*/
}