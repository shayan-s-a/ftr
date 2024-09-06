@isTest
public class ftr_InfiniumOrderCreationTest {

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
            
        
        
            vlocity_cmt__Premises__c Prms = new vlocity_cmt__Premises__c(vlocity_cmt__City__c='NYC',vlocity_cmt__State__c='NC',WC_CLLI__c = 'MSTNWIXA');
            //Prms.WC_CLLI__c = 'MSTNWIXA';
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
                BTN__c='1234567890',
                Email_List__c='abc@test.com'
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
                                        vlocity_cmt__SubType__c= 'RingCentral'
                                         ,Family = 'UCF',
                                         vlocity_cmt__SpecificationSubType__c='Yealink Phones')); 
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
        Service_Location__c sl =new Service_Location__c(Order__c=o.Id,City__c='NYC',State__c='NY',Location_Address__c='NYC USA',Shipping_Location__c = 'Same as Service Location');
        insert sl;
        List<UCF_S_E_Item_Code__c> itemList=new List<UCF_S_E_Item_Code__c>();
        UCF_S_E_Item_Code__c itemCode1 = new UCF_S_E_Item_Code__c(DPI_S_E__c='YEA61',Vlocity_UCF_Equipment_name__c='UCF 2 Port ATA',Equipment_name_on_PDW__c='Single Port ATA  *Obi300 VoIP Telephone Adapter   NOTE:  MUST BE ADDED AS A TAG ALONG TO ANALOG SEAT',Part_number__c='2200-49530-001');
        itemList.add(itemCode1);
        UCF_S_E_Item_Code__c itemCode2 = new UCF_S_E_Item_Code__c(DPI_S_E__c='YEA61',Vlocity_UCF_Equipment_name__c='UCF 2 Port ATA',Equipment_name_on_PDW__c='Single Port ATA  *Obi300 VoIP Telephone Adapter   NOTE:  MUST BE ADDED AS A TAG ALONG TO ANALOG SEAT',Part_number__c='2200-49530-001');
        itemList.add(itemCode2);
        insert itemList;
        //system.debug('itemList:: '+itemList);
        List<ftr_UCFExchangeDetail__c> liUCFExchangeDetails = new List<ftr_UCFExchangeDetail__c>();
        ftr_UCFExchangeDetail__c UCFExchangeDetail = new ftr_UCFExchangeDetail__c (City__c='NYC',State__c='NC',Exchange_Name__c='Andrews',Tariff_Name__c='Frontier Communications of the Carolinas, INC Tariff 1 (NCC)');
        liUCFExchangeDetails.add(UCFExchangeDetail);
        insert liUCFExchangeDetails;
        
    }
    
    @isTest
    static void sendRequestTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Order o = [Select Id,Name From Order Limit 1];
        Test.startTest();
        ftr_InfiniumOrderCreation.sendRequest(o.Id);
        String calculateDueDate_result=ftr_InfiniumOrderCreation.calculateDueDate();
        Test.stopTest();
    }
    
    @isTest
    static void sendRequestTest2(){
        List<OrderItem> oi = [select Id,SNE_Code_MRC__c,SNE_Code_OTC__c From OrderItem Limit 2];
        for(OrderItem i :oi){
            i.SNE_Code_MRC__c = NULL;
            i.SNE_Code_OTC__c= NULL;
        }
        update oi;
            Order o = [Select Id,Name From Order Limit 1];
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        ftr_InfiniumOrderCreation.sendRequest(o.Id);
        String calculateDueDate_result=ftr_InfiniumOrderCreation.calculateDueDate();
        Test.stopTest();
    }
    @isTest
    static void sendRequestTest3(){
        Order ord = [Select Id,Name From Order Limit 1];
        List<Service_Location__c> sl = [select Id,City__c,State__c From Service_Location__c where Order__c= :ord.Id ];
        delete sl;
            
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        ftr_InfiniumOrderCreation.sendRequest(ord.Id);
        String calculateDueDate_result=ftr_InfiniumOrderCreation.calculateDueDate();
        Test.stopTest();
    }
    @isTest
    static void sendRequestTest4(){
        Order ord = [Select Id,Name From Order Limit 1];
        List<OrderItem> oi = [select Id,vlocity_cmt__ServiceAccountId__c From OrderItem where OrderId= :ord.Id ];
        delete oi;
            
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        ftr_InfiniumOrderCreation.sendRequest(ord.Id);
        String calculateDueDate_result=ftr_InfiniumOrderCreation.calculateDueDate();
        Test.stopTest();
    }
    /*
    @isTest
    static void testHttpCalloutInfinium_Success() {
        // Test data setup
        // Create test data needed for the method
        
        // Call the method
        Test.startTest();
        ftr_InfiniumOrderCreation.httpCalloutInfinium('{"example":"payload"}', 'lineItemIds', 'OrderId', 'orderNumber', 'serviceLocationOrderKey');
        Test.stopTest();
        
        // Assertions
        // Verify expected behavior
    }
    
    @isTest
    static void testHttpCalloutInfinium_Failure() {
        // Test data setup
        // Create test data needed for the method
        
        // Mock HTTP response to simulate failure
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method
        Test.startTest();
        ftr_InfiniumOrderCreation.httpCalloutInfinium('{"example":"payload"}', 'lineItemIds', 'OrderId', 'orderNumber', 'serviceLocationOrderKey');
        Test.stopTest();
        
        // Assertions
        // Verify expected behavior
    }
    */
    @isTest
    static void testCreateTaskOnFailure() {
        // Test data setup
        // Create test data needed for the method
        Order o = [Select Id,Name From Order Limit 1];
        // Call the method
        Test.startTest();
        ftr_InfiniumOrderCreation.createTaskOnFailure(o.Id, 'serviceLocationOrderKey', 'response');
        Test.stopTest();
        
        // Assertions
        // Verify expected behavior
    }
    
public class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement the respond method to simulate the HTTP response
    public HTTPResponse respond(HTTPRequest req) {
        // Create a new HTTPResponse object
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"key": "value"}');
        res.setStatusCode(200);
        return res;
    }
}
}