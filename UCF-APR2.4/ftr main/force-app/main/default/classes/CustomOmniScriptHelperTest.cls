/**
 * @description       : This test class covers the following Apex class:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 4
**/
@isTest
public class CustomOmniScriptHelperTest {
    @TestSetup
    static void makeData() {
         Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
       //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account a = new Account(Name = 'TestAccount');
        a.RecordTypeId = MasterRTId;
        a.ParentId = globalAcc1.Id;
      /*  insert ac1;
        Account a = ftr_TestDataFactory.getAccounts(1)[0];*/
        a.Customer_Number__c = '123';
        insert a;
        insert new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', Phone = '5555551234');
        insert new ftr_DPIBillingDetails__c(BillingTelephoneNumber__c = '12345', Customer_Number__c = '123');
        //insert ftr_TestDataFactory.getAccounts(1);
        Group q = [SELECT Id, Email FROM Group WHERE DeveloperName = 'Managed_Services_Architect' AND Type = 'Queue'];
        if (q == null) {
            insert new Group(
                Email = 'test@test.com',
                DeveloperName = 'Managed_Services_Architect',
                Name = 'Managed_Services_Architect',
                Type = 'Queue'
            );
        } else {
            q.Email = 'test@test.com';
            update q;
        }
    }

    @IsTest
    static void getOptionalChildProductsToAddTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        input.put('ProductCode', '1234');
        input.put('ServiceAccountId', '001238dafkj9');
        input.put('ProductCodeToAdd', '001238dafkj9');
        input.put('ContextId', '123414');
        Test.startTest();

        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('getOptionalChildProductsToAdd', input, output, options);
        Test.stopTest();
    }

    @IsTest
    static void updateAccountStatusTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();

        Test.startTest();

        input.put('AccountId', [SELECT Id FROM Account LIMIT 1].Id);
        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('updateAccountStatus', input, output, options);
        input.put('AccountId', [SELECT Id FROM Account LIMIT 1].Id);
        try {
            testing.invokeMethod('updateAccountStatus', input, output, options);
        } catch (Exception e) {
            System.debug('Exception thrown, as expected!');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void transformGoogleAddressComponentsTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();

        List<Object> addressComponents = (List<Object>) JSON.deserializeUntyped('[{"long_name": "277","short_name": "277","types": ["street_number"]},{"long_name": "Bedford Avenue","short_name": "Bedford Ave","types": ["route"]},{"long_name": "Williamsburg","short_name": "Williamsburg","types": ["neighborhood","political"]},{"long_name": "Brooklyn","short_name": "Brooklyn","types": ["political","sublocality","sublocality_level_1"]},{"long_name": "Kings County","short_name": "Kings County","types": ["administrative_area_level_2","political"]},{"long_name": "New York","short_name": "NY","types": ["administrative_area_level_1","political"]},{"long_name": "United States","short_name": "US","types": ["country","political"]},{"long_name": "11211","short_name": "11211","types": ["postal_code"]}]');
        input.put('address_components', addressComponents);

        Test.startTest();

        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('transformGoogleAddressComponents', input, output, options);
        Test.stopTest();
    }

    @IsTest
    static void getUniqueBTNDetailsTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();

        Test.startTest();

        input.put('CustomerNumber', '123');
        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('getUniqueBTNDetails', input, output, options);
    }
    @IsTest
    static void sendMSAEmailTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        input.put('OrderNumber', '1234');
        input.put('ContextId', '001238dafkj9');
        Test.startTest();

        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('sendMSAEmail', input, output, options);
        Test.stopTest();
    }

    @IsTest
    static void updateOrderStageTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        Order[] orders = ftr_TestDataFactory.getOrders(1);
        insert orders;
        input.put('OrderId', orders[0].Id);
        input.put('OrderStage', 'IT Review');
        Test.startTest();

        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('updateOrderStage', input, output, options);
        Test.stopTest();
    }
     @IsTest
    static void updateOrderProductTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        // Create test data
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId = MasterRTId;
        testAccount.ParentId = globalAcc1.Id;
        //Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        id pricebookId=Test.getStandardPricebookId();
        Opportunity op=new Opportunity(Name = 'TestOpp',
                                        AccountId = testAccount.Id,
                                        CloseDate = System.today(),
                                        Service_Address__c = 'Test',
                                        Description__c = 'Test',
                                        StageName = 'Investigating',
                                        CPE_Product__c = 'No');
       
       Product2 p = new Product2();
        p.Name = 'Managed Security - Advanced';
        p.Description='Managed Security - Advanced';
        p.productCode = 'ENT_ETH_ADV_01';
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
                                    Pricebook2Id = pricebookId
                                  );                               
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
        
        OrderItem testOrderItem = new OrderItem();
        testOrderItem.OrderId = testOrder.Id;
        testOrderItem.Quantity = 1;
        testOrderItem.UnitPrice = 100;
        testOrderItem.PricebookEntryId = standardPrice1.Id;
        testOrderItem.vlocity_cmt__Product2Id__c = p.Id;
        testOrderItem.UNI_Host__c = null;
        testOrderItem.UNI_Remote__c = null;
        testOrderItem.VLAN_Tag_Config__c = '';
        insert testOrderItem;
        input.put('OrderId', testOrder.Id);
        Test.startTest();

        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('updateOrderProduct', input, output, options);
        Test.stopTest();
    }
    @IsTest
    static void updateOrderProductTest1() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        // Create test data
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId = MasterRTId;
        testAccount.ParentId = globalAcc1.Id;
        //Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        id pricebookId=Test.getStandardPricebookId();
        Opportunity op=new Opportunity(Name = 'TestOpp',
                                        AccountId = testAccount.Id,
                                        CloseDate = System.today(),
                                        Service_Address__c = 'Test',
                                        Description__c = 'Test',
                                        StageName = 'Investigating',
                                        CPE_Product__c = 'No');
       
       Product2 p = new Product2();
        p.Name = 'Managed Security - Standard';
        p.Description='Managed Security - Standard';
        p.productCode = 'ENT_ETH_STD_01';
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
                                    Pricebook2Id = pricebookId
                                  );                               
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
        
        OrderItem testOrderItem = new OrderItem();
        testOrderItem.OrderId = testOrder.Id;
        testOrderItem.Quantity = 1;
        testOrderItem.UnitPrice = 100;
        testOrderItem.PricebookEntryId = standardPrice1.Id;
        testOrderItem.vlocity_cmt__Product2Id__c = p.Id;
        testOrderItem.UNI_Host__c = null;
        testOrderItem.UNI_Remote__c = null;
        testOrderItem.VLAN_Tag_Config__c = '';
        insert testOrderItem;
        input.put('OrderId', testOrder.Id);
        Test.startTest();

        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('updateOrderProduct', input, output, options);
        Test.stopTest();
    }
    @IsTest
    static void updateOrderProductTest2() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        // Create test data
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId = MasterRTId;
        testAccount.ParentId = globalAcc1.Id;
        //Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        id pricebookId=Test.getStandardPricebookId();
        Opportunity op=new Opportunity(Name = 'TestOpp',
                                        AccountId = testAccount.Id,
                                        CloseDate = System.today(),
                                        Service_Address__c = 'Test',
                                        Description__c = 'Test',
                                        StageName = 'Investigating',
                                        CPE_Product__c = 'No');
       
       Product2 p = new Product2();
        p.Name = 'Managed Wi-Fi';
        p.Description='Managed Wi-Fi';
        p.productCode = 'ENT_ETH_WIFI_01';
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
                                    Pricebook2Id = pricebookId
                                  );                               
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
        
        OrderItem testOrderItem = new OrderItem();
        testOrderItem.OrderId = testOrder.Id;
        testOrderItem.Quantity = 1;
        testOrderItem.UnitPrice = 100;
        testOrderItem.PricebookEntryId = standardPrice1.Id;
        testOrderItem.vlocity_cmt__Product2Id__c = p.Id;
        testOrderItem.UNI_Host__c = null;
        testOrderItem.UNI_Remote__c = null;
        testOrderItem.VLAN_Tag_Config__c = '';
        insert testOrderItem;
        input.put('OrderId', testOrder.Id);
        Test.startTest();

        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('updateOrderProduct', input, output, options);
        Test.stopTest();
    }

    @IsTest
    static void shareServiceAccRecordsTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();

        User u = ftr_TestDataFactory.getUsers(new List<String>{ 'Frontier Sales User' })[0];
        insert u;

        input.put('OrderItem', new Map<String, Object>{ 'ServiceAccountId' => [SELECT Id FROM Account LIMIT 1].Id });
        Test.startTest();
        System.runAs(u) {
            CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
            testing.invokeMethod('shareServiceAccRecords', input, output, options);
        }
        Test.stopTest();
    }

    @IsTest
    static void searchTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();

        input.put('objectName', 'Contact');
        input.put('searchFields', 'Name');
        input.put('returnFields', 'Name');
        input.put('searchTerm', 'Test');
        input.put('filter', 'LastName = \'Contact\'');

        Test.startTest();
        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('search', input, output, options);
        Test.stopTest();
    }
    
    /*@IsTest
    static void deleteTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        
        Account accList = ftr_TestDataFactory.getServAccountsWithPremise(1);
        update accList;

        input.put('recordId', accList.Id);

        Test.startTest();
        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('deleteRecord', input, output, options);
        Test.stopTest();
    }
    
  @IsTest
    static void getRecordTypeIdTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();

        input.put('objectName', 'Case');
        input.put('recordTypeName', 'Account Creation');

        Test.startTest();
        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('getRecordTypeId', input, output, options);
        Test.stopTest();
    }*/


    @IsTest
    static void associateUNIsTest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        // Create test data
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId = MasterRTId;
        testAccount.ParentId = globalAcc1.Id;
        //Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        id pricebookId=Test.getStandardPricebookId();
        Opportunity op=new Opportunity(Name = 'TestOpp',
                                        AccountId = testAccount.Id,
                                        CloseDate = System.today(),
                                        Service_Address__c = 'Test',
                                        Description__c = 'Test',
                                        StageName = 'Investigating',
                                        CPE_Product__c = 'No');
       
       Product2 p = new Product2();
        p.Name = 'Managed Security - Standard';
        p.Description='Managed Security - Standard';
        p.productCode = 'ENT_ETH_UNI_0001';
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
                                    Pricebook2Id = pricebookId
                                  );                               
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
       // Account servAccs = ftr_TestDataFactory.getServAccountsWithPremise(1);
        //update servAccs;
        OrderItem testOrderItem = new OrderItem();
        testOrderItem.OrderId = testOrder.Id;
        testOrderItem.Quantity = 1;
        testOrderItem.UnitPrice = 100;
        testOrderItem.PricebookEntryId = standardPrice1.Id;
        testOrderItem.vlocity_cmt__Product2Id__c = p.Id;
        testOrderItem.UNI_Host__c = null;
        testOrderItem.UNI_Remote__c = null;
        testOrderItem.VLAN_Tag_Config__c = '';
        //testOrderItem.vlocity_cmt__ServiceAccountId__c =servAccs.id;
        insert testOrderItem;
        input.put('OrderId', testOrder.Id);
        Test.startTest();

        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('associateUNIs', input, output, options);
        Test.stopTest();
    }
    
    @IsTest
    static void addUNITest() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, String> prodMap = new Map<String, string>{ 'ENT_ETH_UNI_0001' => 'ENT_ETH_UNI_0001', 'ENT_ETH_EIA_0002' => 'ENT_ETH_EIA_0002' };
        
        insert ftr_TestDataFactory.getQLI(1, 1);
        List<QuoteLineItem> qlis = [
            SELECT Id, vlocity_cmt__ServiceAccountId__c, Quantity, Term__c, Speed__c, vlocity_cmt__Product2Id__c, QuoteId, vlocity_cmt__BillingAccountId__c, 
            vlocity_cmt__LineNumber__c, Product2Id, vlocity_cmt__JSONAttribute__c, PricebookEntry.Product2.ProductCode
            FROM QuoteLineItem Limit 1
        ];

        Quote qt = [select id, Service_Term__c from quote where id=:(Id)qlis[0].get('QuoteId')];
        qt.OmniscriptData__c = '[ { "ATTR_PHY_MEDIUM": "Fiber Single Mode 1310nm" } ]';
        update qt;
        
        Integer numOfProdForEachProdCode = 1;
        List<PricebookEntry> pbeList = ftr_TestDataFactory.getProductswithPbe(prodMap, numOfProdForEachProdCode);
        insert pbeList;
        
        input.put('cartId', qt.Id);
        Test.startTest();

        CustomOmniScriptHelper testing = new CustomOmniScriptHelper();
        testing.invokeMethod('addUNI', input, output, options);
        Test.stopTest();
    }
    
}