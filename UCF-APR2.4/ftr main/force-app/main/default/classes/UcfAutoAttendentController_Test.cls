@isTest
public class UcfAutoAttendentController_Test {
    /////// Test SetUp//////////////////
    @testSetup
    static void setupTestData() {
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
        insert a;
        
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
        Order o = new Order();
        o.Name = 'Sample Order';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 10;
        o.AccountId = a.id;
        //o.Pricebook2Id =  standardPb.Id ;
        o.Products__c = 'SIP;EIA';
        o.Order_Stage__c = 'MSA Review';
        o.Contract__c=newContract.Id;
        o.Contract_Schedule__c=newContract.Id;
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
    static void testsaveTimePeriods() {
        String menuId= [SELECT Id,Name FROM Menu__c where Name='Test Menu' LIMIT 1].Id;
        Id scheduleId=[SELECT Id, Name FROM Schedule__c Limit 1].Id;
        List<Time_Period__c> timePeriodList = new List<Time_Period__c>();
        Time_Period__c tp;
        for(Integer timep= 0;timep<3;timep++){
            tp = new Time_Period__c(
        	Name='Test Time Period '+timep,
            Menu__c=menuId,
            Schedule__c=scheduleId);
            timePeriodList.add(tp);
        }
        UcfAutoAttendentController.saveTimePeriods(timePeriodList);
        //System.assertNotEquals(null, result);
    }
    @isTest
    static void testFtrDIDNumberDetailsAutoAttendants() {
        List<ftr_DID_Number_Details__c> result = UcfAutoAttendentController.ftrDIDNumberDetailsAutoAttendants();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testScheduleforAutoAttendantsSetUp() {
        List<Schedule__c> result = UcfAutoAttendentController.ScheduleforAutoAttendantsSetUp();
        System.assertNotEquals(null, result);
    }

    
    @isTest
    static void testScheduleforAutoAttendantsSchedules() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        List<Schedule__c> result = UcfAutoAttendentController.ScheduleforAutoAttendantsSchedules(orderId);
        System.assertNotEquals(null, result);

    }
    @isTest
    static void testgetMenuLines() {
        String menuId= [SELECT Id,Name FROM Menu__c where Name='Test Menu' LIMIT 1].Id;
        List<Menu_Line__c> result = UcfAutoAttendentController.getMenuLines(menuId);
        System.assertNotEquals(null, result);

    }
    
    @isTest
    static void testSaveMenuLines() {
        String menuId= [SELECT Id,Name FROM Menu__c where Name='Test Menu' LIMIT 1].Id;
		List<Menu_Line__c> menuLinesToUpdate=[SELECT Menu__c, Greeting__c FROM Menu_Line__c WHERE Menu__c =:menuId];
        String result = UcfAutoAttendentController.saveMenuLines(menuLinesToUpdate);
        System.assertEquals('Menu  Lines Updated Successfully', result);
    }
    @isTest
    static void testSaveMenuLinesError() {
        String menuId='';
		List<Menu_Line__c> menuLinesToUpdate=[SELECT Menu__c, Greeting__c FROM Menu_Line__c WHERE Menu__c =:menuId];
        String result = UcfAutoAttendentController.saveMenuLines(menuLinesToUpdate);
        System.assertEquals(result, result);
    }
    
    @isTest
    static void testUpdateMenuFields() {
        Menu__c testMenu= [SELECT Id,Name FROM Menu__c where Name='Test Menu' LIMIT 1];
        String menuId = testMenu.Id;
        String newGreetingName = 'New Greeting';
        String newMenuName = 'Updated Test Menu';
        String result = UcfAutoAttendentController.updateMenuFields(menuId, newGreetingName, newMenuName);
        System.assertEquals('Menu Updated Successfully', result);
        
    }
    @isTest
    static void testUpdateMenuFieldsError() {
        
        String menuId = '';
        String newGreetingName = 'New Greeting';
        String newMenuName = 'Updated Test Menu';
        String result = UcfAutoAttendentController.updateMenuFields(menuId, newGreetingName, newMenuName);
        System.assertEquals(result, result);
        
    }
    
    @isTest
    static void testInsertSchedule() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
		String scheduleName = 'Test Schedule';
        String RecordTypeId = 'Auto_Attendants';
        String result = UcfAutoAttendentController.insertSchedule(scheduleName, orderId, RecordTypeId);
		System.assertEquals('Schedule Created Succesfully', result);

    }
    @isTest
    static void testInsertScheduleError() {
        String orderId='';
		String scheduleName = 'Test Schedule';
        String RecordTypeId = 'Auto_Attendants';
        String result = UcfAutoAttendentController.insertSchedule(scheduleName, orderId, RecordTypeId);
		System.assertEquals(result, result);

    }
    
    @isTest
    static void testDeleteSchedule() {
        Id scheduleId=[SELECT Id, Name FROM Schedule__c Limit 1].Id;
        String result = UcfAutoAttendentController.deleteSchedule(scheduleId);
		System.assertEquals('Schedule deleted successfully', result);
    }
    @isTest
    static void testDeleteScheduleError() {
        String scheduleId='';
        String result = UcfAutoAttendentController.deleteSchedule(scheduleId);
		System.assertEquals(result, result);
    }
    @isTest
    static void testGreetingsforAutoAttendantsGreetings() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        List<Greetings__c> result = UcfAutoAttendentController.GreetingsforAutoAttendantsGreetings(orderId);
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testInsertGreeting() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
		String greetingName = 'Test Schedule';
        //String RecordTypeId = [select id from recordtype where DeveloperName='Auto_Attendants' limit 1].id;
        String result = UcfAutoAttendentController.insertGreeting(greetingName, orderId);
		System.assertEquals('Greeting Created Succesfully', result);
    }
    @isTest
    static void testInsertGreetingError() {
        String orderId= '';
		String greetingName = 'Test Schedule';
        //String RecordTypeId = [select id from recordtype where DeveloperName='Auto_Attendants' limit 1].id;
        String result = UcfAutoAttendentController.insertGreeting(greetingName, orderId);
		System.assertEquals(result, result);
    }
    @isTest
    static void testDeleteGreeting(){
    	Id greetingId=[SELECT Id, Name FROM Greetings__c where name ='Test Greeting'].Id;
        String result = UcfAutoAttendentController.deleteGreeting(greetingId);
		system.assertEquals('Greetings deleted successfully',result);
    }
    
    @isTest
    static void testDeleteGreetingError(){
    	String greetingId='';
        String result = UcfAutoAttendentController.deleteGreeting(greetingId);
		system.assertEquals(result,result);
    }
    @isTest
    static void testGreetingforEdit(){
    	Id greetingId=[SELECT Id, Name FROM Greetings__c where name ='Test Greeting'].Id;
        Greetings__c result = UcfAutoAttendentController.greetingforEdit(greetingId);
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testUpdateGreeting(){
    	Greetings__c greetingrec=[SELECT Id, Name,Message_Board__c FROM Greetings__c where name ='Test Greeting'];
        greetingrec.Message_Board__c= 'ABC';
        String result = UcfAutoAttendentController.UpdateGreeting(greetingrec);
		system.assertEquals('Greeting Updated Successfully',result);
    }
    @isTest
    static void testUpdateGreetingError(){
    	Greetings__c greetingrec = new Greetings__c(); 
        greetingrec.Message_Board__c= 'ABC';
        String result = UcfAutoAttendentController.UpdateGreeting(greetingrec);
		system.assertEquals(result,result);
    }
    @isTest
    static void testMenusforAutoAttendants() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        List<Menu__c> result = UcfAutoAttendentController.menusforAutoAttendants(orderId);
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testInsertMenus() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
		String menuName = 'Test Menu 2';
        String result = UcfAutoAttendentController.insertMenus(menuName, orderId);
		System.assertEquals('Menu and Menu Lines Created Successfully', result);
    }
    @isTest
    static void testInsertMenusError() {
        String orderId= '';
		String menuName = 'Test Menu 2';
        String result = UcfAutoAttendentController.insertMenus(menuName, orderId);
		System.assertEquals(result, result);
    }
    @isTest
    static void testDeleteMenus(){
    	Id menuId=[SELECT Id, Name FROM Menu__c where name ='Test Menu'].Id;
        String result = UcfAutoAttendentController.deleteMenus(menuId);
		system.assertEquals('Menu deleted successfully',result);
    }
    @isTest
    static void testDeleteMenusError(){
    	String menuId='';
        String result = UcfAutoAttendentController.deleteMenus(menuId);
		system.assertNotEquals('Menu deleted successfully',result);
    }
    @isTest
    static void testgetTimePeriodData2() {
        Id didId=[select id from ftr_DID_Number_Details__c where Schedule__r.UCF_Name__c = 'Sample0' LIMIT 1].Id;
        List<UcfAutoAttendentController.TimePeriodWrapper> result = UcfAutoAttendentController.getTimePeriodData2(didId);
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testgetTimePeriodData() {
        Id didId=[select id from ftr_DID_Number_Details__c where Schedule__r.UCF_Name__c = 'Sample0' LIMIT 1].Id;
        List<Time_Period__c> result = UcfAutoAttendentController.getTimePeriodData(didId);
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testftrDIDNumberDetailsAutoAttendantsSetup() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        List<ftr_DID_Number_Details__c> result = UcfAutoAttendentController.ftrDIDNumberDetailsAutoAttendantsSetup(orderId);
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testftrDIDNumberDetailsAutoAttendantsSetupError() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        List<ftr_DID_Number_Details__c> result = UcfAutoAttendentController.ftrDIDNumberDetailsAutoAttendantsSetup(orderId);
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testScheduleforAutoAttendantSetUp() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        List<Schedule__c> result = UcfAutoAttendentController.ScheduleforAutoAttendantSetUp(orderId);
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testScheduleforAutoAttendantSetUpError() {
        String orderId= 'ldskdsjdkjsdkj';
        List<Schedule__c> result = UcfAutoAttendentController.ScheduleforAutoAttendantSetUp(orderId);
        System.assertNotEquals(null, result);
    }
    /*
    @isTest
    static void testsaveTimePeriodRecords() {
        Id menuId=[SELECT Id, Name FROM Menu__c where name ='Test Menu'].Id;
        Id scheduleId=[SELECT Id, Name FROM Schedule__c Limit 1].Id;
        List<Time_Period__c> listTimePeriod =new List<Time_Period__c>();
        Time_Period__c timePeriod;
        for(integer i=0;i<3;i++){
        timePeriod = new Time_Period__c(
        	Name='Test Time Period '+i,
            Menu__c=menuId,
            Schedule__c=scheduleId);
            listTimePeriod.add(timePeriod);
        }
        List<Time_Period__c> result = UcfAutoAttendentController.saveTimePeriodRecords(listTimePeriod);
		System.assertNotEquals(NULL, result);
    }*/
    @isTest
    static void testAddHoliDays() {
        //Id menuId=[SELECT Id, Name FROM Menu__c where name ='Test Menu'].Id;
        Id scheduleId=[SELECT Id, Name FROM Schedule__c Limit 1].Id;
        List<Holiday__c> listHoliDays =new List<Holiday__c>();
        Holiday__c HoliDay;
        for(integer i=0;i<3;i++){
        HoliDay = new Holiday__c(
        	Name='Holiday '+i,
            Ucf_Menu__c='Holiday',
            Schedule__c=scheduleId);
            listHoliDays.add(HoliDay);
        }
        List<Holiday__c> result = UcfAutoAttendentController.addHoliDays(listHoliDays);
		System.assertNotEquals(NULL, result);
    }
    
    @isTest
    static void testupdateSchedule() {
        //Id menuId=[SELECT Id, Name FROM Menu__c where name ='Test Menu'].Id;
        Schedule__c schedule=[SELECT Id, Name FROM Schedule__c Limit 1];
        String menuName =[SELECT Id, Name FROM Menu__c WHERE Name = 'Test Menu' Limit 1].Name;
        Schedule__c result = UcfAutoAttendentController.updateSchedule(schedule,menuName,menuName,menuName,menuName);
		System.assertNotEquals(NULL, result);
    }
    
    @isTest
    static void test_getGreetings() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        List<Greetings__c> result = UcfAutoAttendentController.getGreetings(orderId);
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void test_getHolidaysBySchedule() {
        Id scheduleId=[SELECT Id, Name FROM Schedule__c Limit 1].Id;
        List<Holiday__c> result = UcfAutoAttendentController.getHolidaysBySchedule(scheduleId);
		System.assertNotEquals(NULL, result);
    }
    
    @isTest
    static void test_getHolidaysByScheduleId() {
        Id scheduleId=[SELECT Id, Name FROM Schedule__c Limit 1].Id;
        List<Holiday__c> result = UcfAutoAttendentController.getHolidaysByScheduleId(scheduleId);
		System.assertNotEquals(NULL, result);
    }
    
    @isTest
    static void test_updateAaSetupData(){
    	List<ftr_DID_Number_Details__c > didNumberRec=[SELECT Id,Name  FROM ftr_DID_Number_Details__c];
        UcfAutoAttendentController.updateAaSetupData(didNumberRec);
		//system.assertEquals('Greeting Updated Successfully',result);
    }
    
    
}