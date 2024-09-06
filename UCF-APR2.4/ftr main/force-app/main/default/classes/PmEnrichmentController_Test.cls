@isTest
public class PmEnrichmentController_Test {
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
        Service_Location__c sl=new Service_Location__c(Order__c=o.Id);
        insert sl;
    }
    
    @isTest
    static void testGetAccountList() {
        Test.startTest();
        List<Account> result = PmEnrichmentController.getAccountList();
        Test.stopTest();
        System.assertNotEquals(NULL, result);
    }
   /* 
    @isTest
    static void testIsTranslationUser() {
        Test.startTest();
        String profileName = PmEnrichmentController.isTranslationUser();
        Test.stopTest();
        System.assertNotEquals(NULL, profileName);
    } */
    @isTest
    static void testGetPremises() {
        
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<Service_Location__c> existingServiceLocations = PmEnrichmentController.getPremises(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, existingServiceLocations);
    }
    @isTest
    static void testGetPremises_WithoutServiceLocation() {
        
        
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Service_Location__c sl=[SELECT Id,Order__c FROM Service_Location__c WHERE Order__c = :orderId];
        Delete sl;
        Test.startTest();
        List<Service_Location__c> existingServiceLocations = PmEnrichmentController.getPremises(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, existingServiceLocations);
    }
    @isTest
    static void testGetPremises2() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<Service_Location__c> serviceLocation = PmEnrichmentController.getPremises2(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, serviceLocation);
    }
    @isTest
    static void testFtrDIDNumberDetailsEmployeeInfo() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<ftr_DID_Number_Details__c> ftrDIDNumberDetails = PmEnrichmentController.ftrDIDNumberDetailsEmployeeInfo(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, ftrDIDNumberDetails);
    }
    
    @isTest
    static void testUpdatePremiseFieldsList() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        List<Service_Location__c> recordsToUpdate=[select id,Name from Service_Location__c];
        Test.startTest();
        string recordsToUpdate_Response  = PmEnrichmentController.updatePremiseFieldsList(recordsToUpdate,recordsToUpdate,orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, recordsToUpdate_Response);
    }

    @isTest
    static void testUpdateDIDNumbersFieldsListt() {
        String EASPin='123';
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        string updateDIDNumbersFieldsList_Response  = PmEnrichmentController.updateDIDNumbersFieldsList(EASPin,orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, updateDIDNumbersFieldsList_Response);
    }
    @isTest
    static void testUpdatePremisesFieldsList() {
        List<Service_Location__c> recordsToUpdate=[select id,Name from Service_Location__c];
        Test.startTest();
        string recordsToUpdate_Response  = PmEnrichmentController.updatePremisesFieldsList(recordsToUpdate);
        Test.stopTest();
        System.assertNotEquals(NULL, recordsToUpdate_Response);
    }
    @isTest
    static void testUpdateServiceLoacationMoadalFields() {
        String constructionDetails='abc';
        Service_Location__c serLocRec= [select id,Name,Shipping_Address__c,Street__c,City__c,State__c,Zip__c from Service_Location__c ];
        String shippingAddress='12';
        Test.startTest();
        string updateAccountFields_Response  = PmEnrichmentController.updateServiceLoacationMoadalFields(serLocRec.Id,constructionDetails,serLocRec.Shipping_Address__c,serLocRec.Street__c,serLocRec.City__c,serLocRec.State__c,serLocRec.Zip__c);
        Test.stopTest();
        System.assertEquals('Record updated successfully', updateAccountFields_Response);
    }
    @isTest
    static void testGetRatingPicklistValues2() {
        Test.startTest();
        List<string> getRatingPicklistValues2_Response  = PmEnrichmentController.getRatingPicklistValues2();
        Test.stopTest();
        System.assertNotEquals(Null, getRatingPicklistValues2_Response);
    }
    @isTest
    static void testGetRatingPicklistValues() {
        Test.startTest();
        List<string> getRatingPicklistValues_Response  = PmEnrichmentController.getRatingPicklistValues();
        Test.stopTest();
        System.assertNotEquals(Null, getRatingPicklistValues_Response);
    }
    @isTest
    static void testGetAccounts() {
        Test.startTest();
        List<Account> GetAccounts_Response  = PmEnrichmentController.getAccounts();
        Test.stopTest();
        System.assertNotEquals(Null, GetAccounts_Response);
    }
    @isTest
    static void testGetDIDNumbersData() {
        Test.startTest();
        List<ftr_DID_Number_Details__c> GetDIDNumbersData_Response  = PmEnrichmentController.getDIDNumbersData();
        Test.stopTest();
        System.assertNotEquals(Null, GetDIDNumbersData_Response);
    }
    @isTest
    static void testUpsertAccounts() {
        
        String csvData = '[{"PhoneNumber": "123-456-7890", "Name": "Account 1"}, {"PhoneNumber": "987-654-3210", "Name": "Account 2"}]';
        Test.startTest();
        PmEnrichmentController.upsertAccounts(csvData);
   		Test.stopTest();
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account];
        System.assertNotEquals(NULL, insertedAccounts);
    }
    
    @isTest
    static void test_ftrPhoneNumberDetails() {
        
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<ftr_DID_Number_Details__c> updateDIDNumbersFieldsList_Response  = PmEnrichmentController.ftrPhoneNumberDetails(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, updateDIDNumbersFieldsList_Response);
    }
    @isTest
    static void test_isNetworkTranslation() {
        
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        Boolean isNetworkTranslation_Response  = PmEnrichmentController.isNetworkTranslation(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, isNetworkTranslation_Response);
    }
    
    @isTest
    static void test_getOrderStage() {
        
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        Boolean updateDIDNumbersFieldsList_Response  = PmEnrichmentController.getOrderStage(orderId);
        Test.stopTest();
        
    }
    
}