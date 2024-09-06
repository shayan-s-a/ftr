@IsTest
public with sharing class ftrDIAAccountHanddlerTest {
    
    @IsTest
    public static void getAccountByAdressAndNameTest_1(){
        Integer masterAccountQuantity = 10;
        Integer serviceAccountQuantity = 10;
        String serviceStateCode = 'TX';
        
        setOrgTestData(masterAccountQuantity, serviceAccountQuantity, serviceStateCode);

        Boolean exceptionOccurred = false;
        List<Map<String,String>> output = new List<Map<String,String>>();
        List<Map<String,String>> output2 = new List<Map<String,String>>();
        List<Map<String,String>> output3 = new List<Map<String,String>>();
        String msg = 'Expected number of account its not Ok';

        Map<String, Object> input = new Map<String, Object>{
            'idAccount'=>'Account',
            'ServiceCity'=>'Anywhere',
            'ServiceState'=>'TX',
            'ServiceStreet'=>'123 Main Street'
        };
        Map<String, Object> input2 = new Map<String, Object>{
            'idAccount'=>'',
            'ServiceCity'=>'Anywhere',
            'ServiceState'=>'TX',
            'ServiceStreet'=>'123 Main Street'
        };
        Map<String, Object> input3 = new Map<String, Object>{
            'idAccount'=>'',
            'ServiceCity'=>'Anywhere',
            'ServiceState'=>'FL',
            'ServiceStreet'=>'123 Main Street'
        };       
        
        //check Inserted Accounts*****
        List<Account> accl = [SELECT Id, Name, RecordType.Name From Account];
        List<Id> fixedSearchResults = new List<Id>();
        for(Account a : accl){
            fixedSearchResults.add(a.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
        
        output = ftrDIAAccountHanddler.getAccountsByAddressAndName(input);
        output2 = ftrDIAAccountHanddler.getAccountsByAddressAndName(input2);

       	try {
            output3 = ftrDIAAccountHanddler.getAccountsByAddressAndName(input3);
            
        } catch (Exception e) {
            exceptionOccurred = true;
        }
        
        Test.stopTest();

        System.assertEquals(20, output.size(), msg);
        System.assertEquals(10, output2.size(), msg);
        System.assertEquals(0, output3.size(), msg);
        /*               
        System.debug(LoggingLevel.INFO, 'Output size --> '+output.size());
        System.debug(LoggingLevel.INFO, 'Output size --> '+output2.size());
        System.debug(LoggingLevel.INFO, 'Output size --> '+output3.size());
        */
    }
    
    @IsTest
    public static void createCaseTest_1(){
        Integer masterAccountQuantity = 1;
        Integer serviceAccountQuantity = 1;
        String serviceStateCode = 'TX';
        
        setOrgTestData(masterAccountQuantity, serviceAccountQuantity, serviceStateCode);

        Boolean exceptionOccurred = false;
        Boolean output;
       
        String msg = 'Should Exist 1 Case Created';

        Account mastAcc = [SELECT Id FROM Account WHERE RecordType.Name ='Master' LIMIT 1];

        Map<String, Object> input = new Map<String, Object>{
            'newCaseAccountId'=> mastAcc.Id,            
            'newCaseSubject'=>'Subject',
            'newCaseZipCode'=>'33602',
            'newCaseState'=>'FL',
            'newCaseCity'=>'TAMPA',
            'newCaseStreet'=>'1145 E CASS ST',
            'newCasePhone'=>'9999999999',
            'newCaseAccountName'=>'Test_Master_Account0',
            'newCasePriority'=>'Medium',
            'newCaseRelatedTo'=>'Create Company',
            'newCaseBT'=>'Retail',
            'newCaseStatus'=>'New'           
        };         
        
        Test.startTest();
        
        output = ftrDIAAccountHanddler.createAccountManagementCase(input); 
        
        Test.stopTest();

        Case createdCase = [SELECT Id, RecordType.Name FROM Case WHERE RecordType.Name ='Account Management' LIMIT 1];

        System.assertEquals('Account Management', createdCase.RecordType.Name, msg);        
       
    }
    
    private static void setOrgTestData(Integer masterAccountQuantity, Integer serviceAccountQuantity, String serviceStateCode){
        Id globalAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();        
        Id serviceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        List<Account> masterAccountList = new List<Account>();
        List<Account> serviceAccountList = new List<Account>();        

        Account globalAccount = new Account(
            Name = 'Test_GlobalAccount',
            RecordTypeId = globalAccountRecordTypeId,
            BillingStreet = '123 Main Street',
            BillingCity = 'Anywhere',
            BillingState = 'Texas',
            BillingStateCode = 'TX',
            BillingPostalCode = '44088',
            ShippingStreet = '123 Main Street',
            ShippingCity = 'Anywhere',
            ShippingState = 'Texas',
            ShippingStateCode = 'TX',
            ShippingPostalCode = '44088'
        );

        insert globalAccount;

        for (Integer i = 0; i < masterAccountQuantity; i++) {
            
            Account masterAccount = new Account(
                Name = 'Test_Master_Account'+i,
                ParentId = globalAccount.Id,
                BillingStreet = '123 Main Street',
                BillingCity = 'Anywhere',
                BillingState = 'Texas',
                BillingStateCode = 'TX',
                BillingPostalCode = '44088',
                ShippingStreet = '123 Main Street',
                ShippingCity = 'Anywhere',
                ShippingState = 'Texas',
                ShippingStateCode = 'TX',
                ShippingPostalCode = '44088'
            );
            masterAccountList.add(masterAccount);            
        }
        insert masterAccountList;

        for (Integer i = 0; i < serviceAccountQuantity; i++) {
            
            Account serviceAccount = new Account(
                Name = 'Test_Service_Account'+i,
                RecordTypeId = serviceAccountRecordTypeId,
                ParentId = masterAccountList[i].Id,
                BillingStreet = '123 Main Street',
                BillingCity = 'Anywhere',
                BillingState = 'Texas',
                BillingStateCode = serviceStateCode,
                BillingPostalCode = '44088',
                ShippingStreet = '123 Main Street',
                ShippingCity = 'Anywhere',
                ShippingState = 'Texas',
                ShippingStateCode = serviceStateCode,
                ShippingPostalCode = '44088'
            );
            serviceAccountList.add(serviceAccount);           
        }
        insert serviceAccountList;

    }
}