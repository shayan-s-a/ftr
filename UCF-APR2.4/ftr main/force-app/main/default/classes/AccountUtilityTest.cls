/**
* @description       : This test class covers the following Apex classes:
*      TBD_CLASS1
*      TBD_CLASS2
*      TBD_CLASS3
* @author            : TBD
* @version           : 2 
**/
@isTest(seeAllData = true)  
private class AccountUtilityTest { 
    
    
    static testmethod void unitTest1(){
        Account acc1 = new Account(RecordTypeId = '012E0000000fJrH', isDPILoad__c= 'true', Name = '2999999993.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999993.0', 
                                   Hierarchy_Level__c='SUMMARY',Library_Id__c = 'CZ', SMASequenceID__c = '2999999993.0', Total_360__c = true, FAW_UCaaS__c = true,
                                   BillingCity='Texas', ShippingCity='Texas');
        Account acc2 = new Account(RecordTypeId = '012E0000000fJrH', isDPILoad__c= 'true', Name = '2999999997.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999997.0', 
                                   Hierarchy_Level__c='SUMMARY',Library_Id__c = 'CZ', ParentSequenceId__c='2999999998.0', SMASequenceID__c = '2999999997.0', Total_360__c = true, FAW_UCaaS__c = true,
                                   BillingCity='Texas', ShippingCity='Texas');
        Account acc3 = new Account(RecordTypeId = '012E0000000fJrH', isDPILoad__c= 'false', Name = '2999999996.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999996.0', 
                                   Hierarchy_Level__c='SUMMARY',Library_Id__c = 'CZ', ParentSequenceId__c='2999999996.0', Total_360__c = true, FAW_UCaaS__c = true,
                                   BillingCity='Texas', ShippingCity='Texas');
        
        Account acc4 = new Account(RecordTypeId = '012E0000000fJrH', isDPILoad__c= 'true', Name = '2999999994.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999994.0', 
                                   Hierarchy_Level__c='BILLING',Library_Id__c = 'CZ', ParentSequenceId__c='2999999993.0', Total_360__c = true, FAW_UCaaS__c = true,
                                   BillingCity='Texas', ShippingCity='Texas');
        Account acc5 = new Account(RecordTypeId = '012E0000000fJrH', isDPILoad__c= 'true', Name = '2999999995.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999995.0', 
                                   Hierarchy_Level__c='MEMBER',Library_Id__c = 'CZ', ParentSequenceId__c='2999999994.0', Total_360__c = true, FAW_UCaaS__c = true,
                                   BillingCity='Texas', ShippingCity='Texas');
        
        AccountUtility acUtil = new AccountUtility();
        List<Account> accList = new List<Account>();               
        
        accList.add(acc1);
        accList.add(acc2);
        accList.add(acc3);
        accList.add(acc4);
        accList.add(acc5);
        AccountUtility.removeDuplicates(accList);
        insert accList;                                                                                                
        
        //accList = new List<Account>();               
        
        
        //insert accList;   
        
        //accList = new List<Account>();               
        
        
        //insert accList;  
        system.debug('accListNAme :: '+accList[0].Name);
        
        List<Account> accList1 = [select id,Territory_Name__c,isDPILoad__c,DPI_ConnectDate__c,TNSequenceId__c,Hierarchy_Level__c,Library_Id__c,ParentSequenceId__c,RecordTypeId,OwnerId from Account where name = '2999999995.0']; //where name like '2091390006.0'
        
        update accList1;    
        
        Account ac1 = new Account( isDPILoad__c= 'true', Name = '2999999992.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999992.0', 
                                  Hierarchy_Level__c='SUMMARY',Library_Id__c = 'CZ', SMASequenceID__c = '2999999992.0', Total_360__c = true, FAW_UCaaS__c = true);
        ac1.RecordTypeId = '0128a000000tj2qAAA';
        insert ac1;
        
        Id masterRecTypeId = [select id from recordType where sobjectType = 'Account' AND DeveloperName = 'Master'].Id;
        List<Account> lstMasterAccount = [select Id,ownerid from account where RecordtypeId =:masterRecTypeId limit 1];
        if(lstMasterAccount.size() > 0) {
            lstMasterAccount[0].OwnerId = [select id from user where isActive = true AND Id !=: userInfo.getUserId() limit 1].Id;
            lstMasterAccount[0].Territory_Name__c = 'testTerritory';
            lstMasterAccount[0].ParentId = ac1.Id;
            update lstMasterAccount;
        }
        
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alternate Channel').getRecordTypeId();
        
        List<Account> altChannelAccount = [select id, name, isDPILoad__c,DPI_ConnectDate__c,TNSequenceId__c,Hierarchy_Level__c,Library_Id__c,ParentSequenceId__c,RecordTypeId from Account where RecordTypeId = :devRecordTypeId LIMIT 1];
        if(altChannelAccount.size() > 0){
            altChannelAccount[0].id = null;
            insert altChannelAccount;
        }
        
        //AccountUtility.deleteSupportTeamMember();
        AccountUtility.delete_SupportTeamMember(new Set<Id>());
        //AccountUtility.deleteDPILoadRecords(new Map<Id, SObject>());
    }
    static testmethod void newServiceAccountOwner(){
        Id serviceRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        
        Id masterRecordTypeId = [select id from RecordType where RecordType.Name = 'Master' and SobjectType = 'Account'].Id;
        system.debug('serviceRecordTypeId T::: '+serviceRecordTypeId);
        system.debug('masterRecordTypeId T::: '+masterRecordTypeId);
        Account acc1 = new Account( isDPILoad__c= 'true', Name = '2999999993.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999993.0', BillingCity='Texas', 
                                   Hierarchy_Level__c='SUMMARY',Library_Id__c = 'CZ', SMASequenceID__c = '2999999993.0', Total_360__c = true, FAW_UCaaS__c = true);
        acc1.RecordTypeId = masterRecordTypeId;
        acc1.Customer_Number__c = '12341234';
        insert acc1;
        
        Account acc2 = new Account( isDPILoad__c= 'true', Name = '2999999997.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999997.0', ShippingCity='Texas',
                                   Hierarchy_Level__c='SUMMARY',Library_Id__c = 'CZ', ParentSequenceId__c='2999999998.0', SMASequenceID__c = '2999999997.0', Total_360__c = true, FAW_UCaaS__c = true);
        acc2.ParentId = acc1.Id;
        acc2.RecordTypeId = serviceRecordTypeId;
        insert acc2;
        
    }
    
    static testmethod void preventOrganizationDeletion(){
        
        Id OrganizationRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        
        Account acc1 = new Account( isDPILoad__c= 'true', Name = '2999999993.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999993.0', 
                                   Hierarchy_Level__c='SUMMARY',Library_Id__c = 'CZ', SMASequenceID__c = '2999999993.0', Total_360__c = true, FAW_UCaaS__c = true);
        acc1.RecordTypeId = GlobalRTId;
        insert acc1;
        
        Account acc2 = new Account( isDPILoad__c= 'true', Name = '2999999997.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999997.0',
                                   Hierarchy_Level__c='SUMMARY',Library_Id__c = 'CZ', ParentSequenceId__c='2999999998.0', SMASequenceID__c = '2999999997.0', Total_360__c = true, FAW_UCaaS__c = true);
        acc2.ParentId = acc1.Id;
        acc2.RecordTypeId = OrganizationRTId;
        insert acc2;
        
        Account acc3 = new Account( isDPILoad__c= 'true', Name = '2999999995.0', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999995.0',
                                   Hierarchy_Level__c='SUMMARY',Library_Id__c = 'CZ', ParentSequenceId__c='2999999998.0', SMASequenceID__c = '2999999995.0', Total_360__c = true, FAW_UCaaS__c = true);
        acc3.ParentId = acc2.Id;
        acc3.RecordTypeId = MasterRTId;
        insert acc3;
        try{
            delete acc2; 
        }
        catch(Exception e){
            Boolean message = e.getMessage().contains('This Organization Account has child accounts') ? true : false;
            System.AssertEquals(message, true);
        }
        
    }

    static testmethod void deleteTest(){
        Account acc5 = new Account(RecordTypeId = '012E0000000fJrH', isDPILoad__c= 'true', Name = '2999999995.2', DPI_ConnectDate__c = System.today(),  TNSequenceId__c = '2999999995.0', 
                                   Hierarchy_Level__c='MEMBER',Library_Id__c = 'CZ', ParentSequenceId__c='2999999994.0', Total_360__c = true, FAW_UCaaS__c = true,
                                   BillingCity='Texas', ShippingCity='Texas');
        insert acc5;
        delete acc5;
        
    }
}