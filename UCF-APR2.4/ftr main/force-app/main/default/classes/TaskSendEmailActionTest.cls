@IsTest
public class TaskSendEmailActionTest {
    
    
    @IsTest
    public static void testinvokeMethod(){
        
        
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
                                    SelectedLocations__c = '[{"locationChecked":true,"Id":"0011k00000bRniIAAS","Name":"1565 West Main Street","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75067","ShippingState":"Texas","ShippingStreet":"1565 West Main Street","Premises":{"Copper_Tier__c":"BDT","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPBCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722190","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bSTPPAA4","Name":"305 South Belt Line Road","ShippingCity":"Irving","ShippingCountry":"United States","ShippingPostalCode":"75060","ShippingState":"Texas","ShippingStreet":"305 South Belt Line Road","Premises":{"Copper_Tier__c":"Tier 1","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPVCA2","Last_DSAT_Check__c":"2020-03-02","TicketNo":"1722198","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bRoGPAA0","Name":"1480 North Valley Parkway","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75077","ShippingState":"Texas","ShippingStreet":"1480 North Valley Parkway","Premises":{"Copper_Tier__c":"Tier 2","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPLCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722191","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}}]',
                                    Pricebook2Id = Test.getStandardPricebookId());    
        

        insert quoteList;
        
        //insert order
        Order orderList = new Order(Name = 'Test Order',
                                    AccountId = accountList.id,
                                    OpportunityId = oppList.id,
                                    QuoteId = quoteList.id,
                                    Order_Stage__c = 'In Progress',
                                    vlocity_cmt__QuoteId__c = quoteList.id,
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
                                    ShippingPostalCode = '44088');    
        

        insert orderList;
        Map<String,String> prodNameCodeMap = new Map<String,String>{
                    'DPI Circuit Billing CFS' => 'ENT_ETH_DPI_CIRCUIT_BILLING'
    };
        
        List<Product2> prodList = new List<Product2>();

        for (Integer i = 0; i < 1; i++) {
            for(String prodName : prodNameCodeMap.keySet()) {
                prodList.add(new Product2(Name = prodName,
                                        ProductCode = prodNameCodeMap.get(prodName),
                                        vlocity_cmt__EffectiveDate__c = System.today(),
                                        IsActive = true,
                                        vlocity_cmt__SubType__c= 'RingCentral')); 
            }   
        }
       insert prodList;
        List<PricebookEntry> pbeList =new List<PricebookEntry>();
        pbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prodList[0].Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false));
        insert pbeList;
        
        OrderItem orderItemList= new OrderItem(Product2Id = prodList[0].Id, 
                                            PricebookEntryId = pbeList[0].Id,
                                            vlocity_cmt__Product2Id__c = prodList[0].Id,
                                            //vlocity_cmt__JSONAttribute__c = jsonAttribute,
                                            vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id,
                                            UNI_Host__c = null, 
                                            UNI_Remote__c = null,
                                            VLAN_Tag_Config__c = '',
                                            SNE_Code_MRC__c = 'AWLBR',
                                            SNE_Code_OTC__c = 'AWLBR',
                                            vlocity_cmt__RecurringCharge__c=0.00,
                                            vlocity_cmt__OneTimeCharge__c = 4.95,
                                            Quantity = 1,
                                            OrderId=orderList.Id,
                                            UnitPrice = 0.00); 
            
        

        insert orderItemList;
        
        Contact c = new Contact(
        	LastName = 'Test',
            FirstName= 'User',
            Email='Test@User.com',
            Phone= '1234581021'
        );
        insert c;
        insert new Location_Contact__c(
        	Role__c = 'Location Contact', 
            Order__c = orderList.Id, 
            Order_Product__c =orderItemList.Id, 
            Name = 'John',
            Contact__c = c.Id
        );
        //get task recordType Ids for D1 and DC	
        Id dC711RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DC_711_Order').getRecordTypeId();
        Id dI711RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('D1_711_Order').getRecordTypeId();
        
        Group grp = [Select Id from Group where Type = 'Queue' AND DeveloperName  ='Network_COE_UCaas' Limit 1];
        
        Task taskDI = new Task();
        taskDI.Subject = 'DI 711 Order';
        taskDI.Description = 'BPO Need to create DI 711 Order on DPI System For'+'-'+'1480 North Valley Parkway';
        taskDI.OwnerId = grp.Id;
        taskDI.Priority = 'High';
        taskDI.WhatId = orderList.Id;
        taskDI.RecordTypeId = dI711RecordTypeId;
        taskDI.Status ='Not Started';
        taskDI.ActivityDate = Date.Today() + 3;
        insert taskDI;

		Task taskDC = new Task();
        taskDC.Subject = 'DC 711 Order';
        taskDC.Description = 'BPO Need to create DI 711 Order on DPI System For'+'-'+'1480 North Valley Parkway';
        taskDC.OwnerId = grp.Id;
        taskDC.Priority = 'High';
        taskDC.WhatId = orderList.Id;
        taskDC.RecordTypeId = dC711RecordTypeId;
        taskDC.Status ='Not Started';
        taskDC.ActivityDate = Date.Today() + 2;
        insert taskDC;
        
        Test.startTest(); 
        TaskSendEmailAction.EmailSendData abc = new TaskSendEmailAction.EmailSendData();
        abc.taskId = taskDI.Id;
        abc.EmailTo = 'abc@gmail.com';
        List<TaskSendEmailAction.EmailSendData> emailData = new List<TaskSendEmailAction.EmailSendData>();
        emailData.add(abc);
        List<TaskSendEmailAction.EmailReturnData> returnData = TaskSendEmailAction.sendEmailExpectedUser(emailData);
        
        TaskSendEmailAction.EmailSendData abcDC = new TaskSendEmailAction.EmailSendData();
        abcDC.taskId = taskDC.Id;
        abcDC.EmailTo = 'abcDC@gmail.com';
        List<TaskSendEmailAction.EmailSendData> emailDataDC = new List<TaskSendEmailAction.EmailSendData>();
        emailDataDC.add(abcDC);
        List<TaskSendEmailAction.EmailReturnData> returnDataDC = TaskSendEmailAction.sendEmailExpectedUser(emailDataDC);
        
        // Test the storeContentVersions method
        List<Id> contentVersionIds = TaskSendEmailAction.storeContentVersions(orderList.Id, 'base64data');
        
        // Add debug statements
        System.debug('ContentVersionIds: ' + contentVersionIds);
        
        // Add assertions to verify ContentVersion and ContentDocumentLink creation
        System.assertNotEquals(0, contentVersionIds.size(), 'ContentVersion should be created');
        Id contentVersionId = contentVersionIds[0];
        
        // Verify ContentVersion creation
        ContentVersion cv = [SELECT Id, Title, VersionData, ContentLocation FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals('PMEnrichment', cv.Title, 'ContentVersion title should be PMEnrichment');
        System.assertEquals('S', cv.ContentLocation, 'ContentVersion content location should be S');
        
        // Verify ContentDocumentLink creation
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :orderList.Id];
        System.assertEquals(orderList.Id, cdl.LinkedEntityId, 'ContentDocumentLink LinkedEntityId should be the orderId');
        
        
        Test.stopTest();
        
        
    }
    
}