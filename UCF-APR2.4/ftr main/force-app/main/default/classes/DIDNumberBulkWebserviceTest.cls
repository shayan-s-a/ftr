@isTest 
public class DIDNumberBulkWebserviceTest {
	@isTest
    static string createOrder() {
        Id  globalrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                      .get('Global').getRecordTypeId();
        
        Id  masterrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                      .get('Master').getRecordTypeId();
        
       // RecordType rec= [Select Id from RecordType where Name ='Master' AND SobjectType ='Account'];
        
         Account masterAccount = new Account(Name='Master Account',RecordTypeId  = globalrecordTypeId);
        insert masterAccount;
        
         // create a test account
        Account parentAccount = new Account(Name='Parent Account',RecordTypeId  = globalrecordTypeId);
        insert parentAccount;
        
        
        // create a test account
        Account testAccount = new Account(Name='Test Account',RecordTypeId = globalrecordTypeId) ;
        insert testAccount;
        
        // create a test contact
       // Contact testContact = new Contact(FirstName='John', LastName='Doe', AccountId=masterAccount.Id);
       // insert testContact;
        
        // create a test product
        Product2 testProduct = new Product2(Name='Test Product', IsActive=true);
        insert testProduct;
        
        // create a test price book entry
        PricebookEntry testPricebookEntry = new PricebookEntry(Product2Id=testProduct.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=100.00, IsActive=true);
        insert testPricebookEntry;
        
        // create the order record
        Order testOrder = new Order();
        testOrder.AccountId = testAccount.Id;
       // testOrder.Order_Contact__c = testContact.Id;
        testOrder.EffectiveDate = Date.today();
        testOrder.Status = 'Draft';
        testOrder.Pricebook2Id = Test.getStandardPricebookId();
        testOrder.Description = 'Test Order';
        
        insert testOrder;
        
        // assert that the order was created 
        Order insertedOrder = [SELECT Id, AccountId, Order_Contact__c,OrderNumber, EffectiveDate, Status, Pricebook2Id, Description FROM Order WHERE Id = :testOrder.Id];
        System.assertEquals(testOrder.AccountId, insertedOrder.AccountId);
        System.assertEquals(testOrder.Order_Contact__c, insertedOrder.Order_Contact__c);
        System.assertEquals(testOrder.EffectiveDate, insertedOrder.EffectiveDate);
        System.assertEquals(testOrder.Status, insertedOrder.Status);
        System.assertEquals(testOrder.Pricebook2Id, insertedOrder.Pricebook2Id);
        System.assertEquals(testOrder.Description, insertedOrder.Description);
        return insertedOrder.OrderNumber;
    }

    
    @isTest
    static void testDidNumberBulkOrder(){
        string orderNum = createOrder();
        ftr_DID_Number_Details__c testDidNumber1 = new ftr_DID_Number_Details__c(
             DID_Number__c = '3342544617'
             );
     ftr_DID_Number_Details__c testDidNumber2 = new ftr_DID_Number_Details__c(
        DID_Number__c = '3342544618');

        insert new List<ftr_DID_Number_Details__c>{ testDidNumber1,testDidNumber2};
         RestRequest req = new RestRequest();
         req.requestURI = '/services/apexrest/DIDBulkOrders';
         req.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>{
           'body' => new Map<String, Object>{
           'clientTransactionId' => orderNum+'.3342544617',
           'orders' => new List<Map<String, Object>>{
             new Map<String, Object>{
             'workingTelephoneNumber' => '3342544618',
             'status' => 'SUCCESS',
             'orderNumber'=> orderNum},
         new Map<String, Object>{
             'workingTelephoneNumber' => '3342544617',
             'status' => 'FAILED',
             'orderNumber'=> orderNum
             }
            }
        }
        };

        String requestBodyJson = JSON.serialize(requestBody);
        req.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = req;

        Test.startTest();
        DIDNumberBulkWebservice.DIDNumberBulkWebserviceResponse response = DIDNumberBulkWebservice.didNumberBulkOrder();
       Test.stopTest();

        System.assertEquals('Success', response.Status);
        System.assertEquals('VOM-200', response.StatusCode);
        System.assertEquals('DPI Order Events Processed Successfully', response.Message);


       List<ftr_DID_Number_Details__c> updatedDidNumbers = [SELECT IsProcessed__c, DID_Status__c,DID_Number__c FROM ftr_DID_Number_Details__c WHERE DID_Number__c IN ('3342544617', '3342544618')];
       System.assertEquals(2, updatedDidNumbers.size());
       for (ftr_DID_Number_Details__c didNum : updatedDidNumbers) {
     System.assertEquals(true, didNum.IsProcessed__c);
         if (didNum.DID_Number__c == '3342544618') {
     System.assertEquals('Success', didNum.DID_Status__c);
         } else if (didNum.DID_Number__c == '3342544617') {
     System.assertEquals('Failed', didNum.DID_Status__c);
    }
    }
     }
}