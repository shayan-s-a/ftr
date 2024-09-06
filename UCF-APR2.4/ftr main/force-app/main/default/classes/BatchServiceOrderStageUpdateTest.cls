/**
 * @description       : This is a test class for apex class BatchServiceOrderStageUpdate
 * @author            : Yasin Khan
 * @version           : 1 
**/
@isTest
private class BatchServiceOrderStageUpdateTest {
    @testSetup static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Carrier Service').getRecordTypeId();
        
        Account acc =new Account();
        acc.Name = 'testAcc';
        acc.RecordTypeId = devRecordTypeId;
        insert acc;
        
        Order order = new Order();
        order.Name = 'testOrder';
        order.AccountId = acc.Id;
        order.EffectiveDate = System.today();
        order.Order_Stage__c = 'DPI Billing';
        order.Status  = 'Draft'; 
        insert order;
        
        Service_Order__c  so = new Service_Order__c();
        so.Order_Number__c = '123';
        so.Name = '1234567'; 
        so.Order__c = order.Id;
        so.RecordTypeId = [select id from RecordType where DeveloperName='M6_Service_Order'].Id;
        so.Item_Spec_Id__c = '1101';
        so.Is_Created_By_Velocity__c = true;
        so.Service_Order_Stage__c = 'Stage 1 - Order Entry';
        insert so; // Complete
    }

    @isTest static void updateOrderStatus_Test() {
        Date todaysDate = Date.today();
        Date exactDate = todaysDate.addDays(-365);
        Service_Order__c so = [select Id,Name from Service_Order__c limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 2 - Engineering Review'));
        BatchServiceOrderStageUpdate b = new BatchServiceOrderStageUpdate();
        List<Service_Order__c> ls = [
            SELECT Id, Name 
            From Service_Order__c 
            WHERE Service_Order_Stage__c != 'Completed' and CreatedDate >= :exactDate 
            and Order__r.Order_Stage__c != 'Complete' limit 1     
        ];
        System.debug('Size of ls: '+ls.size());

        Test.startTest();
        	//ServiceOrderStage_Ctrl.updateSOStage(so.Id,so.Name);
        	ServiceOrderCtrl.syncServiceOrder(so);
            Database.executeBatch(b, 1);
        Test.stopTest();
		system.assertEquals('Stage 2 - Engineering Review', [select Service_Order_Stage__c from Service_Order__c limit 1].Service_Order_Stage__c);
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

    @isTest static void testCreateCsvForUpdated() {
        Service_Order__c so = [select Id,Name from Service_Order__c limit 1];
        Map<String, String> mapToSend = new Map<String, String>();
        mapToSend.put(so.Id, so.Name);

        Test.startTest();
            CSVCreationForM6SOrderStageUpdate.createCsv(mapToSend, 'Updated');
        Test.stopTest();
    }

    @isTest static void testCreateCsvForNotUpdated() {
        Service_Order__c so = [select Id,Name from Service_Order__c limit 1];
        Map<String, String> mapToSend = new Map<String, String>();
        mapToSend.put(so.Id, so.Name);

        Test.startTest();
            CSVCreationForM6SOrderStageUpdate.createCsv(mapToSend, 'Not Updated');
        Test.stopTest();
    }

    @isTest static void testCreateCsvWithException() {
        Service_Order__c so = [select Id,Name from Service_Order__c limit 1];
        Map<String, String> mapToSend = new Map<String, String>();
        mapToSend.put(so.Id, so.Name);

        Test.startTest();
            CSVCreationForM6SOrderStageUpdate.createCsv(mapToSend, 'With Exception');
        Test.stopTest();
    }
}