@isTest
private class ftr_EOCShippingDetailsWebServiceTest {

    @isTest
    static void testGetDPIOrder() {
        // Create test data
        // Create test data
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        insert globalAcc1;
        
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId = MasterRTId;
        testAccount.ParentId = globalAcc1.Id;
        insert testAccount;
        
        id pricebookId=Test.getStandardPricebookId();
        Opportunity op=new Opportunity(Name = 'TestOpp', AccountId = testAccount.Id, CloseDate = System.today(), Service_Address__c = 'Test', Description__c = 'Test', StageName = 'Investigating', CPE_Product__c = 'No');
        
        Product2 p = new Product2();
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode = 'ENT_ETH_EIA_003';
        p.isActive = true;
        insert p;
       
        PricebookEntry standardPrice1 = new PricebookEntry();
        standardPrice1.Pricebook2Id = pricebookId;
        standardPrice1.Product2Id = p.Id;
        standardPrice1.UnitPrice = 1;
        standardPrice1.IsActive = true;
        standardPrice1.UseStandardPrice = false;
       insert standardPrice1 ;                                 
       
       Quote qo= new Quote(Name = 'Test Quote',
       Service_Term__c = '12 Months',
       OpportunityId = op.id,
       SelectedLocations__c = '[{"locationChecked":true,"Id":"0011k00000bRniIAAS","Name":"1565 West Main Street","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75067","ShippingState":"Texas","ShippingStreet":"1565 West Main Street","Premises":{"Copper_Tier__c":"BDT","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPBCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722190","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bSTPPAA4","Name":"305 South Belt Line Road","ShippingCity":"Irving","ShippingCountry":"United States","ShippingPostalCode":"75060","ShippingState":"Texas","ShippingStreet":"305 South Belt Line Road","Premises":{"Copper_Tier__c":"Tier 1","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPVCA2","Last_DSAT_Check__c":"2020-03-02","TicketNo":"1722198","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bRoGPAA0","Name":"1480 North Valley Parkway","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75077","ShippingState":"Texas","ShippingStreet":"1480 North Valley Parkway","Premises":{"Copper_Tier__c":"Tier 2","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPLCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722191","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}}]',
       Pricebook2Id = pricebookId);
       Order testOrder = new Order();
       testOrder.AccountId = testAccount.Id;
       testOrder.Status = 'Draft';
       testOrder.ABS_Escalation__c= false;
       testOrder.OpportunityId = op.id;
       testOrder.QuoteId = qo.id;
       testOrder.vlocity_cmt__QuoteId__c = qo.id;
       testOrder.Pricebook2Id = pricebookId;
       testOrder.Status = 'Draft';
       testOrder.Product__c = 'EIA';
       testOrder.Product_Type__c = 'Ethernet';
       testOrder.Router_s__c = 'No Router';
       testOrder.EffectiveDate = System.today();
       testOrder.BillingStreet = '123 Main Street';
       testOrder.BillingCity = 'Anywhere';
       testOrder.BillingState = 'Texas';
       testOrder.BillingStateCode = 'TX';
       testOrder.BillingPostalCode = '44088';
       testOrder.ShippingStreet = '123 Main Street';
       testOrder.ShippingCity = 'Anywhere';
       testOrder.ShippingState = 'Texas';
       testOrder.ShippingStateCode = 'TX';
       testOrder.ShippingPostalCode = '44088';
       insert testOrder;
       
       Service_Order__c testServiceOrder = new Service_Order__c();
       testServiceOrder.Order_Number__c = '123';
       testServiceOrder.Name = 'TestOrder123';
       testServiceOrder.Order__c = testOrder.id;
       testServiceOrder.RecordTypeId = [select id from RecordType where DeveloperName='M6_Service_Order' limit 1].Id;
       testServiceOrder.Item_Spec_Id__c = '1101';
       testServiceOrder.Is_Created_By_Velocity__c = true;
       insert testServiceOrder;
       
       ShippingInformation__c testShippingInfo = new ShippingInformation__c(Order__c = testOrder.Id, Street__c = '123 Test Street', City__c = 'Test City', State__c = 'Test State', Zip__c = '12345', Country__c = 'Test Country');
       insert testShippingInfo;
       
       Shipping_Device__c testDevice = new Shipping_Device__c(Name = 'Test Device', Ship_Count__c = 1, SNE__c = 'TestSNE123', Shipping_Information__c = testShippingInfo.Id);
       insert testDevice;
       
       Test.setMock(HttpCalloutMock.class, new ftr_EOCShippingDetailsWebServiceMock());
       Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EOCShippingDetails';
        req.httpMethod = 'GET';
        req.addParameter('DPIOrderNumber', 'TestOrder123');
        req.addParameter('Envcode', 'TestEnv');
        RestContext.request = req;
        RestContext.response = res;

        ftr_EOCShippingDetailsWebService.getDPIOrder();

        Test.stopTest();
    }
}