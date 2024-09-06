@IsTest
public class ftr_AssociateUNIAssetsTest {
    //version1
    static Map<String, String> prodNameCodeMap = new Map<String, String>{ 
        'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001' 
    };

	@TestSetup
	static void makeData() {
       // Account[] accounts = ftr_TestDataFactory.getAccounts(1);
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
		Account globalAcc1 = new Account();
		globalAcc1.Name = 'GLOBAL ACCOUNT';
		globalAcc1.RecordTypeId = globalRecId;
		//globalAcc.RecordTypeId = '012E0000000fDc3IAE';
		insert globalAcc1;
		Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
         Account accounts = new Account(Name ='Test Acc');
        accounts.RecordTypeId = MasterRTId;
		accounts.ParentId = globalAcc1.Id;
        insert accounts;
        Order order = new Order (
            Name = 'Test Order',
            AccountId = accounts.Id,
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId(),
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
            ShippingPostalCode = '44088'
        );
        insert order;
        OrderItem[] orderItems = ftr_TestDataFactory.getOrderItems(2, prodNameCodeMap);
        orderItems[0].OrderId = order.Id;
        orderItems[1].OrderId = order.Id;
        insert orderItems;
        orderItems[0].UNI_Host__c = orderItems[1].Id;
        update orderItems;
        insert new Asset(
            Name = 'Test',
        	vlocity_cmt__OrderProductId__c = orderItems[0].Id,
            Product2Id = orderItems[0].Product2Id, 
            vlocity_cmt__PricebookEntryId__c = orderItems[0].PricebookEntryId,
            vlocity_cmt__JSONAttribute__c = orderItems[0].vlocity_cmt__JSONAttribute__c, 
            Quantity = 1,
            Price = 0.00,
            AccountId = order.AccountId
        );
	}

	@IsTest
	static void associateUNIsTest1() {
		Test.startTest();
        List<vlocity_cmt__OrchestrationItem__c> items = ftr_TestDataFactory.getOrchestrationItems(1, prodNameCodeMap);
        insert items;
		ftr_AssociateUNIAssets service = new ftr_AssociateUNIAssets();
        service.executeBatch(items);
		Test.stopTest();
	}

    @IsTest
	static void associateUNIsTest2() {
		Test.startTest();
		Map<Id, Order> items = new Map<Id, Order>([SELECT Id FROM Order]);
		ftr_AssociateUNIAssets service = new ftr_AssociateUNIAssets();
        service.executeBatch(items.keySet());
        service.executeBatch(items.values().get(0).Id);
		Test.stopTest();
	}
}