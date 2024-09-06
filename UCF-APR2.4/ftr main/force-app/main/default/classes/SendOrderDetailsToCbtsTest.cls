@isTest
public class SendOrderDetailsToCbtsTest {
    //version 1
    @testSetup
    static void setuptestData() { 
        Test.setMock(HttpCalloutMock.class, new SendOrderDetailsToCbtsMock());
        WS_ESB_Settings__c setting = new WS_ESB_Settings__c(CBTS_API_Key__c = 'r3MUlqybToeRGmBgw1YSW7FnDUTTwWV7',
                                                            CBTS_Order_Endpoint__c = 'https://ky93livxf5.execute-api.us-east-2.amazonaws.com/createorder/testorder',Apigee_Token__c = 'r3MUlqybToeRGmBgw1YSW7FnDUTTwWV7',
                                                            EC_ApplicationID__c = 'SFDC', EC_EmployeeID__c = '123456', EC_UserID__c = 'ESB_REG');
        insert setting;
        List<Account> accList = ftr_TestDataFactory.getAccounts(1);
        insert accList;
        Opportunity testopNew = new Opportunity
                        (Name = 'testOpps', AccountId = accList[0].Id, Opportunity_Type__c ='New', CloseDate= Date.today(), StageName = 'New');
            insert testopNew;
        DGF__c dgf =  DGF_Test_Fixture_Factory.createTestDGF('ELINE', testopNew.Id);
        Physical_Site__c ps = DGF_Test_Fixture_Factory.createTestPhysicalSites(1, dgf.Id)[0];
        Product2 prod = new Product2(Name = 'Laptop X200',Family = 'Hardware', Description =  'TEST MNS TEST');
        insert prod;
        VendorJsonSNE__c sne = new VendorJsonSNE__c(Long_Description__c = 'Laptop X200', Speed__c = '5M', SE__C = 'DIA05');
        insert sne;
        Id pricebookId = Test.getStandardPricebookId();

            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert pbe;
        List<OpportunityLineItem> testOppLineItems = new List<OpportunityLineItem>();
            for(Integer i=0;i<2;i++) {
                testOppLineItems.add(new OpportunityLineItem(
                                            PricebookEntryId = pbe.Id,
                                            OpportunityId = testopNew.Id, TotalPrice = 33,
                                            Quantity = 5, Renewal_MRR__c = 33, CPQ_NetNewMRR__c = 333));
            }
            insert testOppLineItems;
        Contact con= new contact();
        con.LastName= 'Test';
        con.MobilePhone= '9898561236';
        con.Email = 'Test@gmail.com';
        insert con; 
        Order o = new Order(Name = 'Test Order',
        AccountId = accList[0].id, OpportunityId = testopNew.Id,
                            Technical_Contact_Name__c = 'Test',
                            Technical_Contact_Number__c = '1234567890',
        Pricebook2Id = Test.getStandardPricebookId(),
        Status = 'Draft',
        Product__c = 'EIA',
        Product_Type__c = 'Ethernet',
        Router_s__c = 'No Router',
        Customer_Requested_Date__c = System.today(),
        EffectiveDate = System.today(),
        BillingStreet = '123 Main Street',
        BillingCity = 'Anywhere',
        BillingState = 'Texas',
        BillingStateCode = 'TX',
        BillingPostalCode = '44088',
        ShippingStreet = '123 Main Street',
        ShippingCity = 'Anywhere',
        ShippingState = 'Texas',
        ShippingStateCode = 'TX',
        ShippingPostalCode = '44088',
        Implementor_PM__c = Userinfo.getUserId(),
        RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('New_Order').getRecordTypeId(),
                            DGF__c = dgf.Id,
                            Order_Stage__c = 'Customer Network Provisioning',
                            Technical_Contact__c = con.Id);
        insert o;    
        
        Order order1 = new Order(Name = 'Test Order 1',
        AccountId = accList[0].id, OpportunityId = testopNew.Id,
                            Technical_Contact_Name__c = 'Test',
                            Technical_Contact_Number__c = '1234567890',
        Pricebook2Id = Test.getStandardPricebookId(),
        Status = 'Draft',
        Product__c = 'EIA',
        Product_Type__c = 'Ethernet',
        Router_s__c = 'No Router',
        Customer_Requested_Date__c = System.today(),
        EffectiveDate = System.today(),
        BillingStreet = '123 Main Street',
        BillingCity = 'Anywhere',
        BillingState = 'Texas',
        BillingStateCode = 'TX',
        BillingPostalCode = '44088',
        ShippingStreet = '123 Main Street',
        ShippingCity = 'Anywhere',
        ShippingState = 'Texas',
        ShippingStateCode = 'TX',
        ShippingPostalCode = '44088',
        RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('New_Order').getRecordTypeId(),
                                DGF__c = dgf.Id,
                                Order_Stage__c = 'Customer Network Provisioning',
                                Technical_Contact__c = con.Id);
        insert order1;  
    }
    @isTest
    static void testBatch() {
        Test.startTest();
        List<Service_Order__c> servOrderList = [SELECT Id FROM Service_Order__c];
        System.assert(!servOrderList.isEmpty());
        Test.stopTest();
    }
}