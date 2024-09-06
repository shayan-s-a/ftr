@isTest
public class OrderWelcomeEmailBatchTest {

    @isTest
    static void testOrderWelcomeEmail() {

        //Premises
        vlocity_cmt__Premises__c Prms = new vlocity_cmt__Premises__c();
        Prms.WC_CLLI__c = 'MSTNWIXA';
        insert Prms; 
        
        
        
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
        Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
        Account accountList = new Account(Name = '1480 North Valley Parkway',
                                        BillingStreet = '123 Main Street',
                                        BillingCity = 'Anywhere',
                                        BillingState = 'Texas',
                                        BillingStateCode = 'TX',
                                        BillingPostalCode = '44088',
                                        ShippingStreet = '123 Main Street',
                                        ShippingCity = 'Anywhere',
                                        ShippingState = 'Texas',
                                        ShippingStateCode = 'TX',
                                        ParentId = globalAcc1.Id,
                                        RecordTypeId = masterRecId1,
                                        ShippingPostalCode = '44088');    
        
        insert accountList;
        
        Account serviceAccount1 = new Account();
        serviceAccount1.ParentId = globalAcc1.id;
        serviceAccount1.Name = '1480 North Valley Parkway';
        serviceAccount1.ShippingStreet = '1480 North Valley Parkway';
        serviceAccount1.ShippingCity = 'Lewisville';        
        serviceAccount1.ShippingState = 'Texas';
        serviceAccount1.ShippingPostalCode = '75067';
        serviceAccount1.BTN__c = '1234567';
        serviceAccount1.vlocity_cmt__PremisesId__c= Prms.Id;
        insert serviceAccount1;
        
        //insert opportunity
         Opportunity oppList = new Opportunity(Name = 'TestOpp',
                                        AccountId = accountList.id,
                                        CloseDate = System.today(),
                                        Service_Address__c = 'Test',
                                        Description__c = 'Test',
                                        StageName = 'Investigating',
                                        CPE_Product__c = 'No');    
        

        insert oppList;
        
        //insert quotes
        Quote quoteList = new Quote(Name = 'Test Quote',
                                    Service_Term__c = '36 Months',
                                    OpportunityId = oppList.id,
									Pricebook2Id = Test.getStandardPricebookId());    
        

        insert quoteList;
        
        // Retrieve the RecordType Id for "UCaaS New Order"
    	Id ucaasRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('UCaaS New Order').getRecordTypeId();
        //insert order
        Order orderList = new Order(Name = 'Test Order',
                                    Technical_Contact_Email__c = 'test@example.com',
                                    Order_Stage__c = 'In progress',
                                    AccountId = accountList.id,
                                    OpportunityId = oppList.id,
                                    RecordTypeId = ucaasRecordTypeId,
                                    QuoteId = quoteList.id,
                                    vlocity_cmt__QuoteId__c = quoteList.id,
                                    Pricebook2Id = Test.getStandardPricebookId(),
                                    Status = 'Draft',
                                    Product__c = 'Frontier AnyWare UCaaS + Ethernet',
                                    Product_Type__c = 'UCaaS/UCF',
                                    Products__c = 'UCF;UCaaS',
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
                                    ShippingPostalCode = '44088');    
        

        insert orderList;

        // Create a service location
        ftr_DID_Location_Details__c testServiceLocation = new ftr_DID_Location_Details__c(
            OrderId__c = orderList.Id,
            ServiceAccountId__c = serviceAccount1.Id,
            DueDate__c = Date.today().addDays(3) // This should be 3 days or more in the future
            // Add other required fields
        );
        insert testServiceLocation;

        // Create a number details record
        ftr_DID_Number_Details__c testNumberDetails = new ftr_DID_Number_Details__c(
            DIDLocationDetailsId__c = testServiceLocation.Id,
            Ucf_Extension__c = '123',
            DID_Number__c = '123456789',
            Ucf_User_Name__c = 'Test User',
            Ucf_Number_Use__c = 'DID'
            // Add other required fields
        );
        insert testNumberDetails;

        
        // Schedule the batch to run immediately
        Test.startTest();
        OrderWelcomeEmailBatch batch = new OrderWelcomeEmailBatch();
        String jobId = System.schedule('Test Order Welcome Email Batch', '0 0 23 * * ?', batch);

        Test.stopTest();

    }
}