@isTest
public class UcfEmpInfoController_Test {
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
        
        Product2 p = new Product2();
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode = 'ENT_ETH_EIA_0002';
        p.isActive = true;
        p.vlocity_cmt__SubType__c='Collaboration';
        p.vlocity_cmt__SpecificationSubType__c= 'Conference Models';
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice1 = new PricebookEntry();
        standardPrice1.Pricebook2Id = pricebookId;
        standardPrice1.Product2Id = p.Id;
        standardPrice1.UnitPrice = 1;
        standardPrice1.IsActive = true;
        standardPrice1.UseStandardPrice = false;
        insert standardPrice1 ;
        
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = standardPb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Order o = new Order();
        o.Name = 'Sample Order';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 10;
        o.AccountId = a.id;
        o.Pricebook2Id =  standardPb.Id ;
        o.Products__c = 'SIP;EIA';
        o.Order_Stage__c = 'MSA Review';
        o.Contract__c=newContract.Id;
        Insert o;

        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.Id;
        i.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i.vlocity_cmt__Product2Id__c = p.Id;
        //i.Product_Type__c= 'sample';
        insert i;
        
        /////////////////Create test data for Order//////////////
        
        system.debug('New Order aab'+o.Id);
        
        // Create test data for Schedule__c
        List<Schedule__c> scheduleList = new List<Schedule__c>();
        for(integer sch=0;sch<5;sch++){
            Schedule__c schedule = new Schedule__c();
            Schedule.UCF_Name__c = 'Sample'+sch;
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
        for (Integer ml = 1; ml <= 12; ml++) {
            Menu_Line__c line = new Menu_Line__c();
            line.Menu__c = menu.Id; // Assuming a relationship field to Menu__c
            line.Sort_Order__c = ml;
            // Assign Number__c and Options__c based on the loop index
            if (ml <= 9) {
                line.Number__c = String.valueOf(ml);
            } else if (ml == 10) {
                line.Number__c = '0';
            } else if (ml == 11) {
                line.Number__c = '*';
                line.Options__c = 'Replay Menu';
            } else if (ml == 12) {
                line.Number__c = '#';
                line.Options__c = 'Previous Menu';
            }
            menuLines.add(line);
        }
        
        // Insert Menu Lines
        insert menuLines;
        
        
        
        ftr_DID_Location_Details__c did = new ftr_DID_Location_Details__c(
            OrderId__c=o.Id,
            
            BTN__c='1234567890'
        );
        insert did;
        
        ftr_DID_Number_Details__c num = new ftr_DID_Number_Details__c(
            DID_Number__c='1234567890',
            DIDLocationDetailsId__c=did.Id,
            Schedule__c=scheduleList[0].Id
        );
        insert num;
        
        Time_Period__c tp = new Time_Period__c(
            Name='Test Time Period',
            Menu__c=menu.Id,
            Schedule__c=scheduleList[0].Id);

            insert tp;
        

    }
    
    @isTest
    static void test_OrdetQuoteCounts() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<order> result = UcfEmpInfoController.ordetQuoteCounts(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, result);
    }
    @isTest
    static void test_GetProductPicklistsBySubtype() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        Map<String, List<String>> productPicklists = UcfEmpInfoController.getProductPicklistsBySubtype(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, productPicklists);
    }
    @isTest
    static void test_GetMDNOptions() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<String> mdnValues = UcfEmpInfoController.getMDNOptions(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, mdnValues);
    }

    @isTest
    static void test_GetProductPicklistsAndCountsBySubtype() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        Map<String, Object> getProductPicklistsAndCountsBySubtypeResponse = UcfEmpInfoController.getProductPicklistsAndCountsBySubtype(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, getProductPicklistsAndCountsBySubtypeResponse);
    }
    @isTest
    static void test_GetEmployeInformationDataForPM() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<ftr_DID_Number_Details__c> getEmployeInformationDataForPMResponse = UcfEmpInfoController.getEmployeInformationDataForPM(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, getEmployeInformationDataForPMResponse);
    }
    
    
    ///////////////////////////////////////////////////
    //5/12/2023////////////////
    ///////////////////////////////////////////////////
    @isTest
    static void test_getOrderItemsBySubType() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<OrderItem> getOrderItemsBySubType_Response = UcfEmpInfoController.getOrderItemsBySubType(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, getOrderItemsBySubType_Response);
    }
    @isTest
    static void test_hasCallRecording() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        Boolean hasCallRecording_Response = UcfEmpInfoController.hasCallRecording(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, hasCallRecording_Response);
    }
    
    @isTest
    static void test_getLisenceAccessoriesPL() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<OrderItem> getOrderItemsBySubType_Response = UcfEmpInfoController.getLisenceAccessoriesPL(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, getOrderItemsBySubType_Response);
    }
    @isTest
    static void test_getDeviceTypes() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<OrderItem> getOrderItemsBySubType_Response = UcfEmpInfoController.getDeviceTypes(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, getOrderItemsBySubType_Response);
    }
    
    //////////////////////////////////////
    /////////// 9/2/24 ////////////////
    
    
    @isTest
    static void test_getQuantitiesForVlocitySubType() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        Map<String, Integer> getQuantitiesForVlocitySubType_Response = UcfEmpInfoController.getQuantitiesForVlocitySubType(orderId, '');
        Test.stopTest();
        System.assertNotEquals(NULL, getQuantitiesForVlocitySubType_Response);
    }

	@isTest
    static void test_getQuantitiesForCallRecordingType() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        string p2Name = [select id,Name from Product2 LIMIT 1].Name;
        Test.startTest();
        Map<String, Integer> getQuantitiesForCallRecordingType_Response = UcfEmpInfoController.getQuantitiesForCallRecordingType(orderId, p2Name);
        Test.stopTest();
        System.assertNotEquals(NULL, getQuantitiesForCallRecordingType_Response);
    }   
    
    
    @isTest
    static void test_getQuantitiesForAudioMining() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        Map<String, Integer> getQuantitiesForAudioMining_Response = UcfEmpInfoController.getQuantitiesForAudioMining(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, getQuantitiesForAudioMining_Response);
    }
    
    @isTest
    static void test_getQuantitiesForScreenRecodring() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        Map<String, Integer> getQuantitiesForScreenRecodring_Response = UcfEmpInfoController.getQuantitiesForScreenRecodring(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, getQuantitiesForScreenRecodring_Response);
    }
    
    @isTest
    static void test_getQuantitiesForSpecificationSubType() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        Map<String, Integer> getQuantitiesForSpecificationSubType_Response = UcfEmpInfoController.getQuantitiesForSpecificationSubType(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, getQuantitiesForSpecificationSubType_Response);
    }
    
    @isTest
    static void test_getProductTypes() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        UcfEmpInfoController.ProductTypeWrapper getProductTypes_Response = UcfEmpInfoController.getProductTypes(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, getProductTypes_Response);
    }
    @isTest
    static void test_getQuantitiesForProductType() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        Map<String, Integer> getQuantitiesForProductType_Response = UcfEmpInfoController.getQuantitiesForProductType(orderId, '');
        Test.stopTest();
        System.assertNotEquals(NULL, getQuantitiesForProductType_Response);
    }
    
    
}