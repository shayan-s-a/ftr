@IsTest //(seeAllData=true) //  Main ftr_OrderTriggerHelperTest // ftr_OrderTest12 ftr_OrderTest
public class NCMAutomationOrderHandlerTest {
       
    private class TestData {
     
        public Account acc;
        public Opportunity testOpportunity;
        public Contract contr;
        public OutOfOffice ooo;
        public User u;
        public User u2;
    
        public TestData() {        
            this.u = new User(
                ProfileId = UserInfo.getProfileId(),
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                isActive=true
            );
            insert u;
        
            this.u2 = new User(
                    ProfileId = UserInfo.getProfileId(),
                    LastName = 'last2',
                    Email = 'puser2000@amamama.com',
                    Username = 'puser0002@amamama.com' + System.currentTimeMillis(),
                    CompanyName = 'TEST2',
                    Title = 'title',
                    Alias = 'alias',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    isActive=true
                );
                insert u2;
                
                
            this.ooo = new OutOfOffice(
                StartDate = Date.today(),
                EndDate = Date.today().addDays(1),
                Message='My message',
                IsEnabled = true,
                UserId = u.id //This should be a new user created in test class 
            );
            insert ooo;
                    
            Datetime current =ooo.StartDate;                
            Date local = date.newinstance(current.year(), current.month(), current.day());
            
            Group g1 = new Group(Name='Queue1', type='Queue');
            insert g1;
            
            System.runAs(new User(Id = UserInfo.getUserId())){        
                    QueuesObject q1 = new QueueSObject(QueueID = g1.id, SObjectType = 'Order');
                    insert q1 ;                      
            }                                   
            Test.startTest();
            this.acc = new Account(name = 'TestAccount',Customer_Number__c='1234');        
            insert acc;
                    
            //Opportunity testOpportunity= new Opportunity(Name = 'Test 1', StageName = 'Investigating', AccountId = acc.Id , CloseDate = Date.today(), Pricebook2Id = Test.getStandardPricebookId());
            this.testOpportunity= new Opportunity(Name = 'Test 1', StageName = 'Investigating', AccountId = acc.Id , CloseDate = Date.today(), Pricebook2Id = Test.getStandardPricebookId());
            insert testOpportunity;               
                
            this.contr = new Contract();
            contr.Accountid=acc.id;
            contr.Opportunity__c=testOpportunity.id;
            contr.Agreement_Type__c='VoIP';
            contr.Schedule_Type__c='IP Trunking';
            contr.Status='Draft';
            contr.StartDate=System.today();        // System.today() + 5;
            contr.ContractTerm=12;
            contr.CompanySignedid=u.id;
            contr.BillingStreet = '1919 McKinney Avenue';
            contr.BillingCity = 'Dallas';
            contr.BillingState = 'Texas';
            contr.BillingPostalCode = '75201';
            contr.BillingCountry = 'United States';
            contr.ShippingStreet = '1919 McKinney Avenue';
            contr.ShippingCity = 'Dallas';
            contr.ShippingState = 'Texas';
            contr.ShippingPostalCode = '75201';
            contr.ShippingCountry = 'United States';            
            
            insert contr;  
            Test.stopTest();
            system.debug(' contr @@@@@@@'+contr);             
            //Test.startTest();                       
        
        }
    
    }
       
    @isTest static void OrdertestContract1() {
        
        TestData td = new TestData();
        
        Group g1 = new Group(Name='Queue1', type='Queue');
        insert g1;
        
        System.runAs(new User(Id = UserInfo.getUserId())){        
                QueuesObject q1 = new QueueSObject(QueueID = g1.id, SObjectType = 'Order');
                insert q1 ;                      
        }                 
        
        Id RecordTypeIdWorkGrp = Schema.SObjectType.WorkGroup__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        
        WorkGroup__c workgrp = new WorkGroup__c();
        workgrp.Name ='Contract Renewal Customer';
        workgrp.RecordTypeid =RecordTypeIdWorkGrp;
        workgrp.Field__c='Network Cost Management';
        
        System.debug('workgrp.RecordTypeid==='+workgrp.RecordTypeid);
        insert workgrp;
        System.debug('workgrp==='+workgrp);
        
        Id RecordTypeIdfieldAss = Schema.SObjectType.FieldAssignment__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        
        FieldAssignment__c fieldAssig = new FieldAssignment__c();
        fieldAssig.WorkGroupId__c = workgrp.id;
        fieldAssig.Backup_Assignment__c = td.u2.id;
        fieldAssig.RecordTypeid =RecordTypeIdfieldAss;
        fieldAssig.Primary__c=True;
        fieldAssig.AccountId__c=td.acc.id;
        fieldAssig.Out_Of_Office_Start_Date__c = System.now(); //local;
        fieldAssig.UserId__c= td.u.id;//ooo.UserId ; //u.id; //
        fieldAssig.OutOfOffice__c = false; //ooo.IsEnabled; //false; //
        insert fieldAssig; 
        System.debug('fieldAssig==='+fieldAssig);
        
        Id RecordTypeIdOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Contract Renewal').getRecordTypeId();
        
        system.debug('td contr @@@@@@@'+td.contr);
        system.debug('td contr Id @@@@@@@'+td.contr.id);
        system.debug('td acc Id @@@@@@@'+td.acc.id);
        
        Order ord = new Order();
        ord.Accountid=td.acc.id;
        ord.OwnerId =g1.id;
        ord.Order_Stage__c = 'New';
        ord.RecordTypeid =RecordTypeIdOrder;
        ord.Multi_Location__c='No';
        ord.EffectiveDate=System.today();
        ord.Contract_Schedule__c=td.contr.id;
        ord.Order_Point_of_Contact__c=td.u.ID;
        ord.Is_there_a_Related_Vlocity_Order__c='No';
        ord.Out_of_Franchise__c='No';
        ord.Product_Type__c='Ethernet';
        ord.Product__c='E-LAN';
        ord.Router_s__c='No Router';
        ord.Is_this_an_E_Reach_Off_Net_Ethernet__c='No';
        ord.Status='Draft';
        ord.Technical_Contact_Name__c='Contact';
        ord.Technical_Contact_Number__c='9876543211';
        insert ord;
        
        ord.Order_Stage__c = 'Network Cost Management';
        update ord;                       
        
    }
    
    @isTest static void OrdertestContract2() {
        
        TestData td = new TestData();
        
        Group g1 = new Group(Name='Queue1', type='Queue');
        insert g1;
        
        System.runAs(new User(Id = UserInfo.getUserId())){        
                QueuesObject q1 = new QueueSObject(QueueID = g1.id, SObjectType = 'Order');
                insert q1 ;                      
        }                 
        
        Id RecordTypeIdWorkGrp = Schema.SObjectType.WorkGroup__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        
        WorkGroup__c workgrp = new WorkGroup__c();
        workgrp.Name ='Contract Renewal Customer';
        workgrp.RecordTypeid =RecordTypeIdWorkGrp;
        workgrp.Field__c='Network Cost Management';
        
        System.debug('workgrp.RecordTypeid==='+workgrp.RecordTypeid);
        insert workgrp;
        System.debug('workgrp==='+workgrp);
        
        Id RecordTypeIdfieldAss = Schema.SObjectType.FieldAssignment__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        
        FieldAssignment__c fieldAssig = new FieldAssignment__c();
        fieldAssig.WorkGroupId__c = workgrp.id;
        fieldAssig.Backup_Assignment__c = td.u2.id;
        fieldAssig.RecordTypeid =RecordTypeIdfieldAss;
        fieldAssig.Primary__c=false;
        fieldAssig.AccountId__c=td.acc.id;
        fieldAssig.Out_Of_Office_Start_Date__c = System.now(); //local;
        fieldAssig.UserId__c= td.u.id;//ooo.UserId ; //u.id; //
        fieldAssig.OutOfOffice__c = false; //ooo.IsEnabled; //false; //
        insert fieldAssig; 
        System.debug('fieldAssig==='+fieldAssig);
        
        Id RecordTypeIdOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Contract Renewal').getRecordTypeId();
        
        Order ord = new Order();
        ord.Accountid=td.acc.id;
        ord.OwnerId =g1.id;
        ord.Order_Stage__c = 'New';
        ord.RecordTypeid =RecordTypeIdOrder;
        ord.Multi_Location__c='No';
        ord.EffectiveDate=System.today();
        ord.Contract_Schedule__c=td.contr.id;
        ord.Order_Point_of_Contact__c= td.u.ID;
        ord.Is_there_a_Related_Vlocity_Order__c='No';
        ord.Out_of_Franchise__c='No';
        ord.Product_Type__c='Ethernet';
        ord.Product__c='E-LAN';
        ord.Router_s__c='No Router';
        ord.Is_this_an_E_Reach_Off_Net_Ethernet__c='No';
        ord.Status='Draft';
        ord.Technical_Contact_Name__c='Contact';
        ord.Technical_Contact_Number__c='9876543211';
        insert ord;
        
        ord.Order_Stage__c = 'Network Cost Management';
        update ord;                       
        
    }
    
    
    @isTest static void OrdertestDisconnect() {
    
        TestData td = new TestData();
        
        Group g1 = new Group(Name='Queue1', type='Queue');
        insert g1;
        
        System.runAs(new User(Id = UserInfo.getUserId())){        
                QueuesObject q1 = new QueueSObject(QueueID = g1.id, SObjectType = 'Order');
                insert q1 ;                      
        }                 
        
        Id RecordTypeIdWorkGrp = Schema.SObjectType.WorkGroup__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        
        WorkGroup__c workgrp = new WorkGroup__c();
        workgrp.Name ='Disconnect Customer';
        workgrp.RecordTypeid =RecordTypeIdWorkGrp;
        workgrp.Field__c='Network Cost Management';
        
        System.debug('workgrp.RecordTypeid==='+workgrp.RecordTypeid);
        insert workgrp;
        System.debug('workgrp==='+workgrp);
        
        Id RecordTypeIdfieldAss = Schema.SObjectType.FieldAssignment__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        
        FieldAssignment__c fieldAssig = new FieldAssignment__c();
        fieldAssig.WorkGroupId__c = workgrp.id;
        fieldAssig.Backup_Assignment__c = td.u2.id;
        fieldAssig.RecordTypeid =RecordTypeIdfieldAss;
        fieldAssig.Primary__c=false;
        fieldAssig.AccountId__c= td.acc.id;
        fieldAssig.Out_Of_Office_Start_Date__c = System.now(); //local;
        fieldAssig.UserId__c= td.u.id;//ooo.UserId ; //u.id; //
        fieldAssig.OutOfOffice__c = false; //ooo.IsEnabled; //false; //
        insert fieldAssig; 
        System.debug('fieldAssig==='+fieldAssig);       
                                                        
        //Id RecordTypeIdOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('New Order').getRecordTypeId();
        Id RecordTypeIdOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Disconnect Order').getRecordTypeId();
        
        Order ord = new Order();
        ord.Accountid= td.acc.id;
        ord.OwnerId =g1.id;
        ord.Order_Stage__c = 'New';
        ord.RecordTypeid =RecordTypeIdOrder;
        ord.Disconnect_Reason__c='Collections';
        ord.Circuit__c='1234';
        ord.Multi_Location__c='No';
        ord.EffectiveDate=System.today();
        ord.Contract_Schedule__c= td.contr.id;
        ord.Order_Point_of_Contact__c= td.u.ID;
        ord.Is_there_a_Related_Vlocity_Order__c='No';
        ord.Out_of_Franchise__c='No';
        ord.Product_Type__c='Ethernet';
        ord.Product__c='E-LAN';
        ord.Router_s__c='No Router';
        ord.Is_this_an_E_Reach_Off_Net_Ethernet__c='No';
        ord.Status='Draft';
        ord.Technical_Contact_Name__c='Contact';
        ord.Technical_Contact_Number__c='9876543211';
        insert ord;
        
        ord.Order_Stage__c = 'Network Cost Management';
        update ord;
    
    }
    
    @isTest static void OrdertestOtherRecordType1() {
    
        TestData td = new TestData();
        
        Group g1 = new Group(Name='Queue1', type='Queue');
        insert g1;
        
        System.runAs(new User(Id = UserInfo.getUserId())){        
                QueuesObject q1 = new QueueSObject(QueueID = g1.id, SObjectType = 'Order');
                insert q1 ;                      
        }   
        
        Id RecordTypeIdWorkGrp = Schema.SObjectType.WorkGroup__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        
        WorkGroup__c workgrp = new WorkGroup__c();
        workgrp.Name ='NCM Other Customer';
        workgrp.RecordTypeid =RecordTypeIdWorkGrp;
        workgrp.Field__c='Network Cost Management';
        
        System.debug('workgrp.RecordTypeid==='+workgrp.RecordTypeid);
        insert workgrp;
        System.debug('workgrp==='+workgrp);
        
        Id RecordTypeIdfieldAss = Schema.SObjectType.FieldAssignment__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        
        FieldAssignment__c fieldAssig = new FieldAssignment__c();
        fieldAssig.WorkGroupId__c = workgrp.id;
        fieldAssig.Backup_Assignment__c = td.u2.id;
        fieldAssig.RecordTypeid =RecordTypeIdfieldAss;
        fieldAssig.Primary__c=false;
        fieldAssig.AccountId__c=td.acc.id;
        fieldAssig.Out_Of_Office_Start_Date__c = System.now(); //local;
        fieldAssig.UserId__c= td.u.id;//ooo.UserId ; //u.id; //
        fieldAssig.OutOfOffice__c = false; //ooo.IsEnabled; //false; //
        insert fieldAssig; 
        System.debug('fieldAssig==='+fieldAssig);       
                                                        
        //Id RecordTypeIdOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('New Order').getRecordTypeId();
        Id RecordTypeIdOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Transfer Ownership Order').getRecordTypeId();
        
        Order ord = new Order();
        ord.Accountid=td.acc.id;
        ord.OwnerId =g1.id;
        ord.Order_Stage__c = 'New';
        ord.RecordTypeid =RecordTypeIdOrder;
        //ord.Disconnect_Reason__c='Collections';
        //ord.Circuit__c='1234';
        ord.Multi_Location__c='No';
        ord.EffectiveDate=System.today();
        ord.Contract_Schedule__c= td.contr.id;
        ord.Order_Point_of_Contact__c= td.u.ID;
        ord.Is_there_a_Related_Vlocity_Order__c='No';
        ord.Out_of_Franchise__c='No';
        ord.Product_Type__c='Ethernet';
        ord.Product__c='E-LAN';
        ord.Router_s__c='No Router';
        ord.Is_this_an_E_Reach_Off_Net_Ethernet__c='No';
        ord.Status='Draft';
        ord.Technical_Contact_Name__c='Contact';
        ord.Technical_Contact_Number__c='9876543211';
        insert ord;
        
        ord.Order_Stage__c = 'Network Cost Management';
        update ord;
        
    }
    
    
    @isTest static void OrdertestOtherRecordType2() {
        
        TestData td = new TestData();
        user u2 = new User(
                    ProfileId = UserInfo.getProfileId(),
                    LastName = 'last2',
                    Email = 'puser2000@amamama.com',
                    Username = 'puser0002@amamama.com' + System.currentTimeMillis(),
                    CompanyName = 'TEST2',
                    Title = 'title',
                    Alias = 'alias',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    isActive=true
                );
                insert u2;
        
        OutOfOffice ooo1 = new OutOfOffice(
            StartDate = Date.today(),
            EndDate = Date.today().addDays(1),
            Message='My message',
            IsEnabled = true,
            UserId = u2.id //This should be a new user created in test class 
        );
        insert ooo1;
                
        Group g1 = new Group(Name='Queue1', type='Queue');
        insert g1;
        
        System.runAs(new User(Id = UserInfo.getUserId())){        
                QueuesObject q1 = new QueueSObject(QueueID = g1.id, SObjectType = 'Order');
                insert q1 ;                      
        }      
        
        Account acc1 = new Account(name = 'TestAccount',Customer_Number__c='1234');        
        insert acc1;
            
        Id RecordTypeIdWorkGrp = Schema.SObjectType.WorkGroup__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        
        WorkGroup__c workgrp = new WorkGroup__c();
        workgrp.Name ='NCM Other Customer';
        workgrp.RecordTypeid =RecordTypeIdWorkGrp;
        workgrp.Field__c='Network Cost Management';
        
        System.debug('workgrp.RecordTypeid==='+workgrp.RecordTypeid);
        insert workgrp;
        System.debug('workgrp==='+workgrp);
        
        Id RecordTypeIdfieldAss = Schema.SObjectType.FieldAssignment__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        
        FieldAssignment__c fieldAssig = new FieldAssignment__c();
        fieldAssig.WorkGroupId__c = workgrp.id;
        fieldAssig.Backup_Assignment__c = u2.id;
        fieldAssig.RecordTypeid =RecordTypeIdfieldAss;
        fieldAssig.Primary__c=false;
        fieldAssig.ProcessedRecord__c=true;
        fieldAssig.AccountId__c= acc1.id; 
        fieldAssig.Out_Of_Office_Start_Date__c = System.now(); //local;
        fieldAssig.UserId__c= ooo1.UserId ; //u.id; //
        fieldAssig.OutOfOffice__c = ooo1.IsEnabled; //false; //
        insert fieldAssig; 
        System.debug('fieldAssig==='+fieldAssig);       
                                                        
        //Id RecordTypeIdOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('New Order').getRecordTypeId();
        Id RecordTypeIdOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Transfer Ownership Order').getRecordTypeId();
        
        Order ord = new Order();
        ord.Accountid=td.acc.id;
        ord.OwnerId =g1.id;
        ord.Order_Stage__c = 'New';
        ord.RecordTypeid =RecordTypeIdOrder;
        //ord.Disconnect_Reason__c='Collections';
        //ord.Circuit__c='1234';
        ord.Multi_Location__c='No';
        ord.EffectiveDate=System.today();
        ord.Contract_Schedule__c=td.contr.id;
        ord.Order_Point_of_Contact__c=td.u.ID;
        ord.Is_there_a_Related_Vlocity_Order__c='No';
        ord.Out_of_Franchise__c='No';
        ord.Product_Type__c='Ethernet';
        ord.Product__c='E-LAN';
        ord.Router_s__c='No Router';
        ord.Is_this_an_E_Reach_Off_Net_Ethernet__c='No';
        ord.Status='Draft';
        ord.Technical_Contact_Name__c='Contact';
        ord.Technical_Contact_Number__c='9876543211';
        insert ord;
        
        ord.Order_Stage__c = 'Network Cost Management';
        update ord;      
    
    }
    
    
}