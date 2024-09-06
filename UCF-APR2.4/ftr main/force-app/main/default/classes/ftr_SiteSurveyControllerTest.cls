@isTest
public class ftr_SiteSurveyControllerTest {
	    static Map<String, Object> inputMap = new Map<String,Object>();
        static Map<String, Object> outputMap = new Map<String,Object>();
        static Map<String, Object> optionsMap = new Map<String,Object>();
    	static  Order o = new Order();
    @testSetup
    static void setupTestData(){
            Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
            Account globalAcc1 = new Account();
            globalAcc1.Name = 'GLOBAL ACCOUNT';
            globalAcc1.RecordTypeId = globalRecId1;
            //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
            insert globalAcc1;
            
            Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
            
            Account a = new Account();
            a.RecordTypeId = masterRecId1;
            a.Name = 'Test Account';
            a.ParentId = globalAcc1.Id;
            a.RecordTypeId = masterRecId1;
        	a.Account_Channel__c='Connected Community';
            insert a;
            
        
        
            vlocity_cmt__Premises__c Prms = new vlocity_cmt__Premises__c();
            Prms.WC_CLLI__c = 'MSTNWIXA';
            insert Prms;
            //Insert service account
            Account serviceAccount = new Account();
            serviceAccount.ParentId = globalAcc1.id;
            serviceAccount.Name = 'Service Account';
            serviceAccount.ShippingStreet = '1480 North Valley Parkway';
            serviceAccount.ShippingCity = 'Lewisville';     
            serviceAccount.ShippingState = 'Texas';
            serviceAccount.ShippingPostalCode = '75077';
            serviceAccount.vlocity_cmt__PremisesId__c= Prms.Id;
            insert serviceAccount;
            /////////////Create test data for Contract///////////
            
            Contract newContract = new Contract();
            newContract.Name = 'Sample Contract';
            newContract.BillingStreet = '123 Billing St';
            newContract.BillingCity = 'Medford';
            newContract.BillingState = 'Oregon';
            newContract.BillingPostalCode = '97501';
            newContract.BillingCountry = 'United States	';
            
            newContract.ShippingStreet = '123 Main St';
            newContract.ShippingCity = 'Anytown';
            newContract.ShippingState = 'Texas';
            newContract.ShippingPostalCode = '12345';
            newContract.ShippingCountry = 'United States';
            newContract.AccountId=a.Id;
            
            Insert newContract;
            system.debug('New Contract aab'+newContract.Id);
            /////////////////Create test data for Order//////////////
            o.Name = 'Sample Order';
            o.Status = 'Draft';
            o.EffectiveDate = system.today();
            o.EndDate = system.today() + 10;
            o.AccountId = a.id;
            o.Pricebook2Id = Test.getStandardPricebookId() ;
            o.Products__c = 'SIP;EIA';
            o.Order_Stage__c = 'MSA Review';
            o.Contract__c=newContract.Id;
            Insert o;
            system.debug('New Order aab'+o.Id);
    
            // Create test data for Schedule__c
            List<Schedule__c> scheduleList = new List<Schedule__c>();
            for(integer i=0;i<5;i++){
                Schedule__c schedule = new Schedule__c();
                Schedule.UCF_Name__c = 'Sample'+i;
                Schedule.UCF_Order__c = o.Id;
                schedule.Schedule_Start_Date__c=Date.today();
                schedule.Contract__c=o.Contract__c;
                scheduleList.Add(schedule);
            }
            insert scheduleList;
            // Insert Greeting
            Greetings__c greeting = new Greetings__c();
            greeting.Name = 'Test Greeting';
            greeting.Order__c = o.Id;
            insert greeting;
            // Insert Menu
            Menu__c menu = new Menu__c();
            menu.Name = 'Test Menu';
            menu.Order__c = o.Id;
            menu.Greeting__c=greeting.Id;
            insert menu;
    
            // Prepare to insert Menu Line Items
            List<Menu_Line__c> menuLines = new List<Menu_Line__c>();
            for (Integer i = 1; i <= 12; i++) {
                Menu_Line__c line = new Menu_Line__c();
                line.Menu__c = menu.Id; // Assuming a relationship field to Menu__c
                line.Sort_Order__c = i;
                // Assign Number__c and Options__c based on the loop index
                if (i <= 9) {
                    line.Number__c = String.valueOf(i);
                } else if (i == 10) {
                    line.Number__c = '0';
                } else if (i == 11) {
                    line.Number__c = '*';
                    line.Options__c = 'Replay Menu';
                } else if (i == 12) {
                    line.Number__c = '#';
                    line.Options__c = 'Previous Menu';
                }
                menuLines.add(line);
            }
    
            // Insert Menu Lines
            insert menuLines;
            
            
            
            ftr_DID_Location_Details__c did = new ftr_DID_Location_Details__c(
                OrderId__c=o.Id,
                UCFNameValidation__c='Service Account',
                ServiceAccountId__c=serviceAccount.Id,
                BTN__c='1234567890'
            );
            insert did;
    
        ftr_VOIP_Qualification__c qualification=new ftr_VOIP_Qualification__c(ServiceAccountId__c=serviceAccount.Id,NPA__c=123,NXX__c=456);
        insert qualification;
            ftr_DID_Number_Details__c num = new ftr_DID_Number_Details__c(
                DID_Number__c='1234567890',
                DIDLocationDetailsId__c=did.Id,
                Schedule__c=scheduleList[0].Id,
                Ucf_Voip_Qualification__c=qualification.Id
            );
            insert num;
            
            Time_Period__c tp = new Time_Period__c(
                Name='Test Time Period',
                Menu__c=menu.Id,
                Schedule__c=scheduleList[0].Id);
                 
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
        List<OrderItem> orderItemList = new List<OrderItem>();
       List<PricebookEntry> pbeList =new List<PricebookEntry>();
        pbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prodList[0].Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false));
        insert pbeList;
        
        for (Integer i = 0; i < 10; i++) {
            orderItemList.add(new OrderItem(vlocity_cmt__ServiceAccountId__c= serviceAccount.Id,
                                            PricebookEntryId = pbeList[0].Id,
                                            UNI_Host__c = null, 
                                            UNI_Remote__c = null,
                                            VLAN_Tag_Config__c = '',
                                            SNE_Code_MRC__c = 'YEA61',
                                            SNE_Code_OTC__c = 'YEA61',
                                            vlocity_cmt__RecurringCharge__c=0.00,
                                            vlocity_cmt__OneTimeCharge__c = 4.95,
                                            Quantity = 1,
                                            OrderId=o.Id,
                                            UnitPrice = 0.00)); 
            
        }

        insert orderItemList;
	System_Order_Info__c sysOrderInfo = new System_Order_Info__c(Order__c= o.Id,Control_Number__c='12345',Environment__c='1234',WTN__c='1234');
        insert sysOrderInfo;
        
    }
    
    //Premises
       // static vlocity_cmt__Premises__c Prms = new vlocity_cmt__Premises__c();
    //Custom Object Details
       /*	static ftr_PSRExchangeDetail__c Ex = new ftr_PSRExchangeDetail__c();
       	static Account globalAcc1 = new Account();
    	static Account a = new Account();
	    static Account serviceAccount = new Account();
	    static Account serviceAccount1 = new Account();
    	static Product2 p = new Product2();
	    static Product2 p2 = new Product2();
    	static Product2 p3 = new Product2();*/
    
    /*public static void LoadData (){
        Prms.WC_CLLI__c = 'MSTNWIXA';
        insert Prms;   
        
        Ex.WC_CLLI__c = 'MSTNWIXA';
        Ex.Company_Indicator_Code__c = 203;
        Ex.NPANXX__c = '608297';
        insert Ex;
        
        Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
        Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
        a.RecordTypeId = masterRecId1;
        a.Name = 'Test Account';
       	a.ParentId = globalAcc1.Id;
       	a.RecordTypeId = masterRecId1;
        insert a;
        
        serviceAccount.ParentId = a.id;
        serviceAccount.Name = 'Service Account';
        serviceAccount.ShippingStreet = '1480 North Valley Parkway';
        serviceAccount.ShippingCity = 'Lewisville';     
        serviceAccount.ShippingState = 'Texas';
        serviceAccount.ShippingPostalCode = '75077';
        serviceAccount.vlocity_cmt__PremisesId__c= Prms.Id;
        
        serviceAccount1.ParentId = a.id;
        serviceAccount1.Name = 'Service Account 1';
        serviceAccount1.ShippingStreet = '1565 West Main Street';
        serviceAccount1.ShippingCity = 'Lewisville';        
        serviceAccount1.ShippingState = 'Texas';
        serviceAccount1.ShippingPostalCode = '75067';
        serviceAccount1.vlocity_cmt__PremisesId__c= Prms.Id;
         // insert serviceAccount1;
         // 
        //Product-1
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode = 'ENT_ETH_EIA_0002';
        p.isActive = true;
        //insert p;
        
        //Product-2
        p2.Name = ' Test EVPL EVC ';
        p2.Description='Test EVPL EVC';
        p2.productCode = 'ENT_ETH_EVPL_0010';
        p2.isActive = true;
        //insert p2;
        //Product-3
    
        p3.Name = ' Test UNI ';
        p3.Description='Test UNI';
        p3.productCode = 'ENT_ETH_UNI_0001';
        p3.isActive = true;
        //insert p3;
        
        //PriceBooks
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice1 = new PricebookEntry();
        standardPrice1.Pricebook2Id = pricebookId;
        standardPrice1.Product2Id = p.Id;
        standardPrice1.UnitPrice = 1;
        standardPrice1.IsActive = true;
        standardPrice1.UseStandardPrice = false;
       // insert standardPrice1 ;
    }*/
     
    @isTest 
    static void createTestData() {
        IntegrationAPIConfig__mdt apiConfigs = new IntegrationAPIConfig__mdt(
            DeveloperName = 'DPIAuthentication',
            Timeout__c = 5000, 
            ApiKey__c = 'testApiKey',
            Authorization_Header__c = 'Bearer testToken',
            CustomerOrderMgmt_URI__c = 'https://example.com/customerOrder',
            OrderStaging_URI__c = 'https://example.com/orderStaging',
            BulkNumber_URI__c = 'https://example.com/bulkNumber'
        );

        Order o = [select Id From Order Limit 1];
        system.debug('o.Id : '+o.Id);
        inputMap.put('orderId',o.Id);
        ftr_SiteSurveyController siteSurvey = new ftr_SiteSurveyController();
        siteSurvey.invokeMethod('RetrieveCustomerFacilities',inputMap,outputMap,optionsMap);
        
        
        
        inputMap.put('orderId',o.Id);
        ftr_SiteSurveyController PhoneNubmer = new ftr_SiteSurveyController();
        PhoneNubmer.invokeMethod('FindAvailablePhoneNubmers',inputMap,outputMap,optionsMap);
        
        inputMap.put('orderId',o.Id);
        ftr_SiteSurveyController Telephonenubmers = new ftr_SiteSurveyController();
        Telephonenubmers.invokeMethod('ReserveTelephonenubmers',inputMap,outputMap,optionsMap);

          inputMap.put('orderId',o.Id);
        ftr_SiteSurveyController submitGroupOrderDI711 = new ftr_SiteSurveyController();
        submitGroupOrderDI711.invokeMethod('submitGroupOrderDI711Order',inputMap,outputMap,optionsMap);
   
        
    }
    
    
    
    
    
    
     @isTest
    static void testRetrieveCustomerFacilities() {
        Id globalRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId1;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        
        Id masterRecId1 = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
        
        Account a = new Account();
        a.RecordTypeId = masterRecId1;
        a.Name = 'Test Account';
        a.ParentId = globalAcc1.Id;
        a.RecordTypeId = masterRecId1;
        a.Account_Channel__c='Connected Community';
        insert a;
        
        Order testOrder = new Order(
            Name = 'Test Order',
            AccountId = a.id
            // Add other required fields
        );
        
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('orderId', testOrder.Id);
        
         Map<String, Object> outputMap = new Map<String, Object>();
        
         Map<String, Object> options = new Map<String, Object>();
        ftr_SiteSurveyController controller = new ftr_SiteSurveyController();
        Boolean result = controller.invokeMethod('RetrieveCustomerFacilities', inputMap, outputMap, options);
        
        
        ftr_SiteSurveyController controller1 = new ftr_SiteSurveyController();
        Boolean result1 = controller1.invokeMethod('FindAvailablePhoneNubmers', inputMap, outputMap, options);
        
        ftr_SiteSurveyController Telephonecontroller = new ftr_SiteSurveyController();
        Boolean result2 = Telephonecontroller.invokeMethod('Telephonenubmers', inputMap, outputMap, options);
        
        ftr_SiteSurveyController SubitGroupcontrollerDI711 = new ftr_SiteSurveyController();
        Boolean result3 = SubitGroupcontrollerDI711.invokeMethod('submitGroupOrderDI711Order', inputMap, outputMap, options);        

        // Add assertions
        System.assertEquals(false, result);
        // Add additional assertions based on the expected behavior of the method
    }
    
     /*
    @isTest
    static void testSubmitGroupOrderD1711() {
        // Create test data
        Contact con1 =new Contact();
        con1.LastName = 'test1';
        con1.Phone_Number_with_Extension__c = '(786) 234-2345 ext. 1234';
        insert con1;
        Order o = [select Id From Order Limit 1];
        Location_Contact__c locationContact = new Location_Contact__c(Contact__c = con1.Id,Order__c=o.Id,Name='Sample Location');
        insert locationContact;
		
        
        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new YourMockHttpResponse());

        // Call the method being tested
        Test.startTest();
        ftr_SiteSurveyController.submitGroupOrderD1711(o.id);
        Test.stopTest();

        // Assert results if applicable
        // Add assertions to verify the behavior and outcome of the method
    }
    
    public class YourMockHttpResponse implements HttpCalloutMock {
        // Implement the respond method to provide a fake response
        public HTTPResponse respond(HTTPRequest req) {
            // Create a new HTTPResponse object
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}'); // Example response body

            // Set the response status code
            res.setStatusCode(200); // Example status code

            return res;
        }
    }
   
    @isTest
    static void testSystemOrderDIOrderLeadOrderUpdate() {
        // Create test data
        // Assuming required test data setup including System_Order_Info__c and related records

        // Create test submitOrderMetadata
        Map<String, Object> submitOrderMetadata = new Map<String, Object>();

        // Example test data for submitOrderMetadata
        System_Order_Info__c systemOrderInfo = [SELECT Id, Order__c FROM System_Order_Info__c LIMIT 1];

        // Example systemSubmitOrder map
        Map<String, Object> systemSubmitOrder = new Map<String, Object>{
            'errorMessage' => null, // Set error message if needed
            'GroupMemberOrderId' => 'TestGroupMemberOrderId',
            'LeadOrderId' => 'TestLeadOrderId',
            'Request' => 'TestRequest',
            'Response' => 'TestResponse'
        };

        // Add systemSubmitOrder to submitOrderMetadata
        submitOrderMetadata.put(systemOrderInfo.Id, systemSubmitOrder);
		//Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock());
        // Call the method being tested
        Test.startTest();
        ftr_SiteSurveyController.systemOrderDIOrderLeadOrderUpdate(submitOrderMetadata);
        Test.stopTest();

    }
      */ 
  }