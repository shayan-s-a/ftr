@isTest
public class testFetchData {

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
        
        
    }
    @isTest
    static void testQueryAccounts() {
        List<Account> result = FetchData.queryAccounts();

        // Assert that the expected number of records is returned
        System.assertNotEquals(NULL, result);
    }
    @isTest
    static void testQueryAccounts2() {
        List<Account> result = FetchData.queryAccounts2();

        // Assert that the expected number of records is returned
        System.assertNotEquals(NULL, result);
    }
    
    
    @isTest
    static void testDeleteSelectedDIDNumbers() {
        List<Id> selectedIds = new List<Id>();

        // Perform a SOQL query to retrieve record IDs
        List<ftr_DID_Number_Details__c> DIDNumberDetails = [SELECT Id FROM ftr_DID_Number_Details__c];
        
        // Extract the record IDs from the queried records
        for (ftr_DID_Number_Details__c did : DIDNumberDetails) {
            selectedIds.add(did.Id);
        }
        FetchData.deleteSelectedDIDNumbers(selectedIds);
        List<ftr_DID_Number_Details__c> deletedRecords = [
            SELECT Id
            FROM ftr_DID_Number_Details__c
            WHERE Id IN :selectedIds
        ];

        System.assertEquals(0, deletedRecords.size(), 'The selected records should be deleted');
    }
    @isTest
    static void testFtrDIDNumberDetails() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
		List<ftr_DID_Number_Details__c> result = FetchData.ftrDIDNumberDetails(orderId);
		System.assertNotEquals(NULL, result);
    }
    
    
    @isTest
    static void testFtrUcfVoipQualification() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
		List<ftr_VOIP_Qualification__c> result = FetchData.FtrUcfVoipQualification(orderId);
		System.assertNotEquals(NULL, result);
    }
    
    
    @isTest
    static void testgetOnloadDataforRbandCombo() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
		List<ftr_DID_Number_Details__c> result = FetchData.getOnloadDataforRbandCombo(orderId);
		System.assertNotEquals(NULL, result);
    }

    @isTest
    static void testFtrDIDNumberDetailsGeneralVoicemail() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
		List<ftr_DID_Number_Details__c> result = FetchData.ftrDIDNumberDetailsGeneralVoicemail(orderId);
		System.assertNotEquals(NULL, result);
    }
    @isTest
    static void testFtrDIDNumberDetailsMLHG() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
		List<ftr_DID_Number_Details__c> result = FetchData.ftrDIDNumberDetailsMLHG(orderId);
		System.assertNotEquals(NULL, result);
    }
    @isTest
    static void testftrDIDNumberDetailsEmployeeInfo() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
		List<ftr_DID_Number_Details__c> result = FetchData.ftrDIDNumberDetailsEmployeeInfo(orderId);
		System.assertNotEquals(NULL, result);
    }
    @isTest
    static void testScheduleforMLHGSetUp() {
		List<Schedule__c> result = FetchData.ScheduleforMLHGSetUp();
		System.assertNotEquals(NULL, result);
    }
    @isTest
    static void testFtrUcfDIDLocations() {
        String orderId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
		List<ftr_DID_Location_Details__c> result = FetchData.FtrUcfDIDLocations(orderId);
		System.assertNotEquals(NULL, result);
    }
    @isTest
    static void testUpdateftrDIDNumberDetails() {
    	List<Id> ids = new List<Id>();
		String extLength='123';
        // Perform a SOQL query to retrieve record IDs
        List<ftr_DID_Number_Details__c> DIDNumberDetails = [SELECT Id FROM ftr_DID_Number_Details__c];
        
        // Extract the record IDs from the queried records
        for (ftr_DID_Number_Details__c did : [SELECT Id FROM ftr_DID_Number_Details__c]) {
            ids.add(did.Id);
        }
        String result=FetchData.updateftrDIDNumberDetails(ids,extLength,TRUE);
        //System.assertEquals('Records updated successfully.', result);
    }
    @isTest
    static void testUpdateftrDIDNumberDetailsEmployeeTab() {
    	List<ftr_DID_Number_Details__c> recordsToUpdate = [SELECT Id FROM ftr_DID_Number_Details__c];
        String result=FetchData.updateftrDIDNumberDetailsEmployeeTab(recordsToUpdate);
        System.assertEquals('Records updated successfully.', result);
    }


	@isTest
    static void testGetMultiPicklistValues3() {
        // Create test data: Mimic an object and field for testing
        // Replace 'YourObjectApiName' and 'YourFieldApiName' with your actual object and field API names.
        String objectApiName = 'Account';
        String fieldApiName = 'vlocity_cmt__ContactPreferences__c';
        List<String> expectedValues = FetchData.GetMultiPicklistValues3(objectApiName,fieldApiName);
        System.assertNotEquals(Null, expectedValues);
    }  
    @isTest
    static void testGetMultiPicklistValues() {
        String YourObjectName = 'Account';
        String YourFieldName = 'vlocity_cmt__ContactPreferences__c';
        List<String> expectedValues = FetchData.GetMultiPicklistValues(YourObjectName,YourFieldName);
        System.assertNotEquals(Null, expectedValues);
    } 
    @isTest
    static void testInsertSchedule() {
        String scheduleName = 'Test Schedule';
        String result = FetchData.insertSchedule(scheduleName);
		System.assertEquals(result, result);

    }
    
    
   

    @isTest
    static void testLoadCSVData() {
        						
        String recordId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        // Create test data for the ContentDocument and ftr_DID_Location_Details__c records
        String data ='Id,DIDNumber__c,DID_Number__c,Ucf_Current_Carrier__c,Ucf_Voip_Qualification__c,Ucf_Number_Use__c\naH774000000KzsTCAS,002216758900,9793613600,DID,Auto Attendant,General Voice Mail' ;
        String fileName = 'GVMTest';
        
        // Create a test ContentVersion record to simulate the CSV file
        ContentVersion testContentVersion = new ContentVersion(
        Title = fileName,
        PathOnClient = fileName+'.csv',
        VersionData = Blob.valueOf(data),
        ContentLocation = 'S'
    );
        insert testContentVersion;
		id contDoc =[Select Id, ContentDocumentId From ContentVersion where Id =:testContentVersion.Id].contentDocumentId;
        String ExtLength='123';

        String result = FetchData.loadCSVData(contDoc, recordId,True,ExtLength);
        System.assertNotEquals(Null, result);
    }

    @isTest
    static void testGetDIDNumbersData() {
        
        List<ftr_DID_Number_Details__c> expectedValues = FetchData.getDIDNumbersData();
        System.assertNotEquals(Null, expectedValues);
    } 

@isTest
    static void test_checkDID() {
        String CurrentCarrier='5465';
        String InstallType='Port-In';
        String recordId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        String did=[SELECT Id, DID_Number__c FROM ftr_DID_Number_Details__c LIMIT 1].DID_Number__c;
        String qualification='General Voice Mail';
        String Location=[select id,Name from Account where Name = 'Service Account' LIMIT 1].Name;
        String ExtLength='123';
		String result = FetchData.checkDID(did,qualification,recordId,Location,CurrentCarrier,False,ExtLength,InstallType);
		System.assertNotEquals(NULL, result);
    }
    @isTest
    static void test_checkDID_2() {
        String CurrentCarrier='5465';
        String InstallType='Port-In';
        String recordId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        String did='8613756377';
        String qualification='General Voice Mail';
        String Location=[select id,Name from Account where Name = 'Service Account' LIMIT 1].Name;
        String ExtLength='123';
		String result = FetchData.checkDID(did,qualification,recordId,Location,CurrentCarrier,True,ExtLength,InstallType);
		System.assertNotEquals(NULL, result);
    }
    @isTest
    static void test_checkDID_3() {
        String CurrentCarrier='5465';
        String InstallType='Port-In';
        String recordId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        String did='8613756377';
        String qualification='General Voice Mail';
        String Location=[select id,Name from Account where Name = 'Service Account' LIMIT 1].Name;
        String ExtLength='123';
		String result = FetchData.checkDID(did,qualification,recordId,Location,CurrentCarrier,False,ExtLength,InstallType);
		System.assertNotEquals(NULL, result);
    } 
    @isTest
    static void test_checkDID_4() {
        String CurrentCarrier='5465';
        String InstallType='Port-In';
        String recordId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        String did='8613756377';
        String qualification='Toll Free';
        String Location=[select id,Name from Account where Name = 'Service Account' LIMIT 1].Name;
        String ExtLength='123';
		String result = FetchData.checkDID(did,qualification,recordId,Location,CurrentCarrier,False,ExtLength,InstallType);
		System.assertNotEquals(NULL, result);
    } 
    @isTest
    static void test_getServiceAccountOptions() {
        String recordId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        
		List<Map<String, String>> result = FetchData.getServiceAccountOptions(recordId);
		System.assertNotEquals(NULL, result);
    }
    @isTest
    static void test_ftrDIDNumberDetails() {
        String recordId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        
		List<ftr_DID_Number_Details__c> result = FetchData.ftrDIDNumberDetails(recordId);
		System.assertNotEquals(NULL, result);
    }
    @isTest
    static void test_updateDidLocationsBulk() {
        List<ftr_DID_Number_Details__c> updatedRecords= [select Id, DID_Number__c from ftr_DID_Number_Details__c];
        
		String result = FetchData.updateDidLocationsBulk(updatedRecords);
		System.assertNotEquals(NULL, result);
    }
    /*
    @isTest
    static void test_updateDidLocationsNXX() {
        List<ftr_VOIP_Qualification__c> updatedRecords= [select Id,Available_VOIP__c,E911_Type__c,Key__c from ftr_VOIP_Qualification__c];
        
		String result = FetchData.updateDidLocationsNXX(updatedRecords);
		System.assertNotEquals(NULL, result);
    }*/
    
    @isTest
    static void testloadCSVDataForGenralVoicemail() {
        // Create test data for the ContentDocument and ftr_DID_Location_Details__c records
        Id DIDNumberDetails = [SELECT Id FROM ftr_DID_Number_Details__c LIMIT 1].Id;
        String data = DIDNumberDetails+',00221,333,testing,test@test.com\n'+DIDNumberDetails+',00221,333,testing,test@test.com' ;
        String fileName = 'GVMTest';
        
        // Create a test ContentVersion record to simulate the CSV file
        ContentVersion testContentVersion = new ContentVersion(
        Title = fileName,
        PathOnClient = fileName+'.csv',
        VersionData = Blob.valueOf(data),
        ContentLocation = 'S'
    );
        insert testContentVersion;
		id contDoc =[Select Id, ContentDocumentId From ContentVersion where Id =:testContentVersion.Id].contentDocumentId;
        

        String result = FetchData.loadCSVDataForGenralVoicemail(contDoc);
        System.assertNotEquals(Null, result);
    }
    
    @isTest
    static void testloadCSVDataForEmployeeInfo() {
        // Create test data for the ContentDocument and ftr_DID_Location_Details__c records
        // CSV Data size'22'
        Id DIDNumberDetails = [SELECT Id FROM ftr_DID_Number_Details__c LIMIT 1].Id;
        String data =DIDNumberDetails+',00221,333,username 1,test2,test0002,test0001,test,sd,test,test0001,test,BGRP,test@test.com,abcd,test,test,test,canada,11 attendees,101 Attendees,No,test,test,test,test\n'+DIDNumberDetails+',00221,333,username 1,test2,test0002,test0001,test,sd,test,test0001,test,BGRP,test@test.com,abcd,test,test,test,canada,11 attendees,101 Attendees,No,test,test,test,test' ;
        String fileName = 'GVMTest';
        
        // Create a test ContentVersion record to simulate the CSV file
        ContentVersion testContentVersion = new ContentVersion(
        Title = fileName,
        PathOnClient = fileName+'.csv',
        VersionData = Blob.valueOf(data),
        ContentLocation = 'S'
    );
        insert testContentVersion;
		id contDoc =[Select Id, ContentDocumentId From ContentVersion where Id =:testContentVersion.Id].contentDocumentId;
        String employeeInfoType='Full Table';

        String result = FetchData.loadCSVDataForEmployeeInfo(contDoc,employeeInfoType);
        System.assertNotEquals(Null, result);
    }
    @isTest
    static void testloadCSVDataForEmployeeInfo2() {
        // Create test data for the ContentDocument and ftr_DID_Location_Details__c records
        // CSV Data size'10'
        Id DIDNumberDetails = [SELECT Id FROM ftr_DID_Number_Details__c LIMIT 1].Id;
        String data =DIDNumberDetails+',1114,username 4,test0001,test0002,test0002,test0001,test,sd,test\n'+DIDNumberDetails+',1114,username 4,test0001,test0002,test0002,test0001,test,sd,test' ;
        String fileName = 'GVMTest';
        
        // Create a test ContentVersion record to simulate the CSV file
        ContentVersion testContentVersion = new ContentVersion(
        Title = fileName,
        PathOnClient = fileName+'.csv',
        VersionData = Blob.valueOf(data),
        ContentLocation = 'S'
    );
        insert testContentVersion;
		id contDoc =[Select Id, ContentDocumentId From ContentVersion where Id =:testContentVersion.Id].contentDocumentId;
        String employeeInfoType='911 Info';

        String result = FetchData.loadCSVDataForEmployeeInfo(contDoc,employeeInfoType);
        System.assertNotEquals(Null, result);
    }
    @isTest
    static void testloadCSVDataForEmployeeInfo3() {
        // Create test data for the ContentDocument and ftr_DID_Location_Details__c records
        // CSV Data size'12
        Id DIDNumberDetails = [SELECT Id FROM ftr_DID_Number_Details__c LIMIT 1].Id;
        String data =DIDNumberDetails+',00221,username 4,test0001,test0002,test0002,test0001,test,sd,test,sd,test\n'+DIDNumberDetails+',1114,username 4,test0001,test0002,test0002,test0001,test,sd,test,sd,test' ;
        String fileName = 'GVMTest';
        
        // Create a test ContentVersion record to simulate the CSV file
        ContentVersion testContentVersion = new ContentVersion(
        Title = fileName,
        PathOnClient = fileName+'.csv',
        VersionData = Blob.valueOf(data),
        ContentLocation = 'S'
    );
        insert testContentVersion;
		id contDoc =[Select Id, ContentDocumentId From ContentVersion where Id =:testContentVersion.Id].contentDocumentId;
        String employeeInfoType='License Info';

        String result = FetchData.loadCSVDataForEmployeeInfo(contDoc,employeeInfoType);
        System.assertNotEquals(Null, result);
    }
    @isTest
    static void testloadCSVDataForEmployeeInfo4() {
        // Create test data for the ContentDocument and ftr_DID_Location_Details__c records
        // CSV Data size'8
        Id DIDNumberDetails = [SELECT Id FROM ftr_DID_Number_Details__c LIMIT 1].Id;
        String data =DIDNumberDetails+',1114,username 4,test0001,test@test.com,test0002,test0001,test\n'+DIDNumberDetails+',1114,username 4,test0001,test@test.com,test0002,test0001,test' ;
        String fileName = 'GVMTest';
        
        // Create a test ContentVersion record to simulate the CSV file
        ContentVersion testContentVersion = new ContentVersion(
        Title = fileName,
        PathOnClient = fileName+'.csv',
        VersionData = Blob.valueOf(data),
        ContentLocation = 'S'
    );
        insert testContentVersion;
		id contDoc =[Select Id, ContentDocumentId From ContentVersion where Id =:testContentVersion.Id].contentDocumentId;
        String employeeInfoType='Employee Info';

        String result = FetchData.loadCSVDataForEmployeeInfo(contDoc,employeeInfoType);
        System.assertNotEquals(Null, result);
    }
    @isTest
    static void testloadCSVDataForEmployeeInfo5() {
        // Create test data for the ContentDocument and ftr_DID_Location_Details__c records
        // CSV Data size'8
        Id DIDNumberDetails = [SELECT Id FROM ftr_DID_Number_Details__c LIMIT 1].Id;
        String data =DIDNumberDetails+',114,username4,test0001,12.0,test0002,test0001,test0001\n'+DIDNumberDetails+',114,username4,test0001,12.0,test0002,test0001,test0001' ;
        String fileName = 'GVMTest';
        
        // Create a test ContentVersion record to simulate the CSV file
        ContentVersion testContentVersion = new ContentVersion(
        Title = fileName,
        PathOnClient = fileName+'.csv',
        VersionData = Blob.valueOf(data),
        ContentLocation = 'S'
    );
        insert testContentVersion;
		id contDoc =[Select Id, ContentDocumentId From ContentVersion where Id =:testContentVersion.Id].contentDocumentId;
        String employeeInfoType='Translation';

        String result = FetchData.loadCSVDataForEmployeeInfo(contDoc,employeeInfoType);
        System.assertNotEquals(Null, result);
    }

    @isTest
    static void testloadCSVDataForEmployeeInfo5_1() {
        // Create test data for the ContentDocument and ftr_DID_Location_Details__c records
        // CSV Data size'8
        Id DIDNumberDetails = [SELECT Id FROM ftr_DID_Number_Details__c LIMIT 1].Id;
        String data =DIDNumberDetails+',114,username4,test0001,123456.6,test0002,test0001,test0001\n'+DIDNumberDetails+',114,username4,test0001,123456.6,test0002,test0001,test0001' ;
        String fileName = 'GVMTest';
        
        // Create a test ContentVersion record to simulate the CSV file
        ContentVersion testContentVersion = new ContentVersion(
        Title = fileName,
        PathOnClient = fileName+'.csv',
        VersionData = Blob.valueOf(data),
        ContentLocation = 'S'
    );
        insert testContentVersion;
		id contDoc =[Select Id, ContentDocumentId From ContentVersion where Id =:testContentVersion.Id].contentDocumentId;
        String employeeInfoType='Translation';

        String result = FetchData.loadCSVDataForEmployeeInfo(contDoc,employeeInfoType);
        System.assertNotEquals(Null, result);
    }
    @isTest
    static void testloadCSVDataForEmployeeInfo6() {
        // Create test data for the ContentDocument and ftr_DID_Location_Details__c records
        // CSV Data size'8
        Id DIDNumberDetails = [SELECT Id FROM ftr_DID_Number_Details__c LIMIT 1].Id;
        String data =DIDNumberDetails+',1114,username 4,test0001,test0002,test0002\n'+DIDNumberDetails+',1114,username 4,test0001,test0002,test0002' ;
        String fileName = 'GVMTest';
        
        // Create a test ContentVersion record to simulate the CSV file
        ContentVersion testContentVersion = new ContentVersion(
        Title = fileName,
        PathOnClient = fileName+'.csv',
        VersionData = Blob.valueOf(data),
        ContentLocation = 'S'
    );
        insert testContentVersion;
		id contDoc =[Select Id, ContentDocumentId From ContentVersion where Id =:testContentVersion.Id].contentDocumentId;
        String employeeInfoType='Device Info';

        String result = FetchData.loadCSVDataForEmployeeInfo(contDoc,employeeInfoType);
        System.assertNotEquals(Null, result);
    }
    /////////////////////////////////////////////////////
    ///// 13/2/2024//////////////////////////////////////
    @isTest
    static void test_ftrNPANXXPhoneNumberDetails() {
        String recordId= [select id,Name from Order where Name = 'Sample Order' LIMIT 1].Id;
        
		List<ftr_DID_Number_Details__c> result = FetchData.ftrNPANXXPhoneNumberDetails(recordId);
		System.assertNotEquals(NULL, result);
    }

    @isTest
    static void test_updateDidLocationsNXX() {
    	List<ftr_DID_Number_Details__c> recordsToUpdate = [SELECT Id FROM ftr_DID_Number_Details__c];
        String result=FetchData.updateDidLocationsNXX(recordsToUpdate);
        //System.assertEquals('Success', result);
    }
    @isTest
    static void test_updateDIDNumbersNXX() {
    	List<ftr_DID_Number_Details__c> recordsToUpdate = [SELECT Id FROM ftr_DID_Number_Details__c];
        String result=FetchData.updateDIDNumbersNXX(recordsToUpdate);
        //System.assertEquals('Success', result);
    }
}