@isTest
public class CustomizationsNotesUcfControllerTest {

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
        
        ftr_911_Notifications__c testNotification = new ftr_911_Notifications__c();
        testNotification.Order__c = o.Id;
        testNotification.Name = 'Test Notification';
        testNotification.Department_System__c = 'System'; 
        testNotification.Method__c = 'Email';
        insert testNotification;

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
        ftr_DID_Number_Details__c num2 = new ftr_DID_Number_Details__c(
            DID_Number__c='1234567890',
            
            DIDLocationDetailsId__c=did.Id,
            Schedule__c=scheduleList[0].Id
        );
        insert num2;
        
        Time_Period__c tp = new Time_Period__c(
            Name='Test Time Period',
            Menu__c=menu.Id,
            Schedule__c=scheduleList[0].Id);

            insert tp;
        List<MLHG_Member__c> MLHGList =new List<MLHG_Member__c>();
        MLHG_Member__c mm;
        for(integer m=0;m<=6;m++){
            	mm=new MLHG_Member__c(Parent_DID_Number_Detail__c=num.Id);
                MLHGList.add(mm);
            }
		insert 	MLHGList;
    }
    
    @isTest
    static void test_loadData() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        CustomizationsNotesUcfController.InitResponse loadData_Response = CustomizationsNotesUcfController.loadData(orderId);
        Test.stopTest();
        //System.assertNotEquals(NULL, loadData_Response);
    }
    @isTest
    static void test_loadData_2() {
        String orderId= 'abcd';
        Test.startTest();
        CustomizationsNotesUcfController.InitResponse loadData_Response = CustomizationsNotesUcfController.loadData(orderId);
        Test.stopTest();
        //System.assertNotEquals(NULL, loadData_Response);
    }
    @isTest
    static void test_updateOrder() {
        Order orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1];
        Test.startTest();
        CustomizationsNotesUcfController.updateOrder(orderId);
        String Response= 'Success';
        Test.stopTest();
        //System.assertNotEquals(NULL, Response);
        
    }
    
    
    @isTest
    static void test_update911Notifications() {
        
        List<ftr_911_Notifications__c> updatedRecords = [SELECT Id, Email_Address__c FROM ftr_911_Notifications__c LIMIT 1];
        updatedRecords[0].Email_Address__c = 'newemail@example.com';
        Test.startTest();
        String result = CustomizationsNotesUcfController.update911Notifications(updatedRecords);
        Test.stopTest();
        
        //System.assertEquals('Success', result, 'The method should return success message');
        ftr_911_Notifications__c updatedRecord = [SELECT Email_Address__c FROM ftr_911_Notifications__c WHERE Id = :updatedRecords[0].Id];
        //System.assertEquals('newemail@example.com', updatedRecord.Email_Address__c, 'Email address should be updated');
    }
    
    @isTest
    static void test_ftrDIDNumberDetailsDepartment() {
        // Setup test data
        // ... (Create ftr_DID_Number_Details__c records linked to an Order)
        
        String orderId = [SELECT Id FROM Order LIMIT 1].Id;
        
        // Perform test
        Test.startTest();
        List<ftr_DID_Number_Details__c> details = CustomizationsNotesUcfController.ftrDIDNumberDetailsDepartment(orderId);
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(0, details.size(), 'Details should be fetched for the order');
        // Additional assertions as necessary
    }

    
    @isTest
    static void test_insertNotification() {
        
        
        String orderId = [SELECT Id FROM Order LIMIT 1].Id;
        
        // Perform test
        Test.startTest();
        String result = CustomizationsNotesUcfController.insertNotification('Test Name', 'System', 'Dept Name', 'Both', 1234567890, 'email@example.com', orderId);
        Test.stopTest();
        
        // Assertions
        //System.assertEquals('Record inserted successfully.', result, 'The method should return success message');
        List<ftr_911_Notifications__c> notifications = [SELECT Name FROM ftr_911_Notifications__c WHERE Order__c = :orderId];
        //System.assertEquals(1, notifications.size(), 'One notification should be created');
        //System.assertEquals('Test Name', notifications[0].Name, 'The notification name should match');
    }

    
}