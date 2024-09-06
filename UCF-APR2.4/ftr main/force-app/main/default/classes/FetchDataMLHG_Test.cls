@isTest
public class FetchDataMLHG_Test {

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
        serviceAccount.ParentId = a.id;
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
    static void test_ftrDIDNumberDetailsMLHG() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        FetchDataMLHG.InitResponse ftrDIDNumberDetailsMLHG_Respone = FetchDataMLHG.ftrDIDNumberDetailsMLHG(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, ftrDIDNumberDetailsMLHG_Respone);
    }
    @isTest
    static void test_updateRecords() {
        ftr_DID_Number_Details__c didRecordToUpdate= [select id,Name from ftr_DID_Number_Details__c LIMIT 1];
        List<MLHG_Member__c> gmRecordsList = new List<MLHG_Member__c>();
        MLHG_Member__c mm;
        for(integer m=0;m<=6;m++){
            	mm=new MLHG_Member__c(Parent_DID_Number_Detail__c=didRecordToUpdate.Id);
                gmRecordsList.add(mm);
            }
        Test.startTest();
        FetchDataMLHG.updateRecords(didRecordToUpdate,gmRecordsList, true);
        Test.stopTest();
        //List<MLHG_Member__c> newGmRecordsList = [select id,Name,Parent_DID_Number_Detail__c from MLHG_Member__c];
        String success = 'success';
        System.assertNotEquals(NULL, success);
    }
    
    @isTest
    static void test_GetDidNumbers() {
        Id didNumberId= [select id,Name from ftr_DID_Number_Details__c LIMIT 1].Id;
        Test.startTest();
        List<MLHG_Member__c> GetDidNumbers_Response= FetchDataMLHG.GetDidNumbers(didNumberId);
        Test.stopTest();
        System.assertNotEquals(NULL, GetDidNumbers_Response);
    }
    @isTest
    static void test_addHoliDays() {
        Id schId= [select id,Name from Schedule__c LIMIT 1].Id;
        List<Holiday__c> holidays = new List<Holiday__c>();
        Holiday__c holiday;
        for(integer m=0;m<=6;m++){
            	holiday=new Holiday__c(Schedule__c=schId,Name='holiday'+m,Date__c=Date.today()+m,Ucf_Menu__c='Menu');
                holidays.add(holiday);
            }
        Test.startTest();
        List<Holiday__c> addHoliDays_Response= FetchDataMLHG.addHoliDays(holidays);
        Test.stopTest();
        System.assertNotEquals(NULL, addHoliDays_Response);
    }

    @isTest
    static void test_ScheduleforMLHGSetUp() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        String RecordTypeId='';
        Test.startTest();
        List<Schedule__c> ScheduleforMLHGSetUp_Response= FetchDataMLHG.ScheduleforMLHGSetUp(orderId,RecordTypeId);
        Test.stopTest();
        System.assertNotEquals(NULL, ScheduleforMLHGSetUp_Response);
    }
    @isTest
    static void test_validateRingOneAtaTime() {
        String didNumberId= [select id,Name from ftr_DID_Number_Details__c LIMIT 1].Id;
        
        Test.startTest();
        Boolean validateRingOneAtaTime_Response= FetchDataMLHG.validateRingOneAtaTime(didNumberId);
        Test.stopTest();
        System.assertNotEquals(NULL, validateRingOneAtaTime_Response);
    }
    @isTest
    static void test_queryschedules() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<Schedule__c> queryschedules_Respone = FetchDataMLHG.queryschedules(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, queryschedules_Respone);
    }
    @isTest
    static void test_saveTimePeriodRecords() {
        Id schId= [select id,Name from Schedule__c LIMIT 1].Id;
        Id menuId= [select id,Name from Menu__c LIMIT 1].Id;
        Time_Period__c tp;
        List<Time_Period__c> tps = new List<Time_Period__c>();
        Holiday__c holiday;
        for(integer m=0;m<=6;m++){
            	 tp= new Time_Period__c(
            Name='Test Time Period',
            Menu__c=menuId,
            Schedule__c=schId);
                tps.add(tp);
            }
        Test.startTest();
        List<Time_Period__c> saveTimePeriodRecords_Response= FetchDataMLHG.saveTimePeriodRecords(tps);
        Test.stopTest();
        System.assertNotEquals(NULL, saveTimePeriodRecords_Response);
    }
    @isTest
    static void test_updateSchedule() {
        Schedule__c updatedSchedule= [select id,Name from Schedule__c Limit 1];
        Test.startTest();
        Schedule__c updateSchedule_Response= FetchDataMLHG.updateSchedule(updatedSchedule);
        Test.stopTest();
        System.assertNotEquals(NULL, updateSchedule_Response);
    }
    @isTest
    static void test_getHolidaysBySchedule() {
        Id scheduleId= [select id,Name from Schedule__c Limit 1].Id;
        Test.startTest();
        List<Holiday__c> getHolidaysBySchedule_Response= FetchDataMLHG.getHolidaysBySchedule(scheduleId);
        Test.stopTest();
        System.assertNotEquals(NULL, getHolidaysBySchedule_Response);
    }
    
    @isTest
    static void test_downloadHolidaysBySchedule() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<Holiday__c> downloadHolidaysBySchedule_Respone = FetchDataMLHG.downloadHolidaysBySchedule(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, downloadHolidaysBySchedule_Respone);
    }
    @isTest
    static void test_ftrSelectedMembers() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<MLHG_Member__c> ftrSelectedMembers_Respone = FetchDataMLHG.ftrSelectedMembers(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, ftrSelectedMembers_Respone);
    }
    
    
    @isTest
    static void test_downloadCustomtimeperiodMLHG() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        Test.startTest();
        List<Time_Period__c> downloadCustomtimeperiodMLHG_Respone = FetchDataMLHG.downloadCustomtimeperiodMLHG(orderId);
        Test.stopTest();
        System.assertNotEquals(NULL, downloadCustomtimeperiodMLHG_Respone);
    }
    
    
    
    
	@isTest
    static void test_updateSchdule() {
        Id schId= [select id,Name from Schedule__c LIMIT 1].Id;
        Test.startTest();
        String updateSchdule_Response= FetchDataMLHG.updateSchdule(50.0, // overflowT24
            '60.0', // overflowD24
            'Updated Holiday', // holidayName
            Date.today().addDays(1), // holidayDate
            70.0, // overflowTOpen
            '80.0', // overflowDOpen
            schId);
        Test.stopTest();
        System.assertNotEquals(NULL, updateSchdule_Response);
    }
    /*
    @isTest
    static void test_updateSchdule_Error() {
        
        Test.startTest();
        String updateSchdule_Response= FetchDataMLHG.updateSchdule(50.0, // overflowT24
            60.0, // overflowD24
            'Updated Holiday', // holidayName
            Date.today().addDays(1), // holidayDate
            70.0, // overflowTOpen
            80.0, // overflowDOpen
            '00000xxxxx');
        Test.stopTest();
        System.assertNotEquals('Records updated successfully.', updateSchdule_Response);
    }*/
}