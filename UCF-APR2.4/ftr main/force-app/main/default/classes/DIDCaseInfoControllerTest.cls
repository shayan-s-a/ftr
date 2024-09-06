@IsTest //(seeAllData=true) 
public class DIDCaseInfoControllerTest {
       
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
        
        Id RecordTypeIdcase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TNAC').getRecordTypeId();
        
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
        
        
        ftr_DID_Location_Details__c serloc = new ftr_DID_Location_Details__c();
        serloc.Name = 'Test 1';
        serloc.OrderId__c = ord.id;
        
        insert serloc;
                
        
        list<Case> caseRecCreationlst = new list<Case>();
        list<string> caseRecstring = new list<string>();
        case caseRecCreation = new case();
        caseRecCreation.recordTypeId = RecordTypeIdcase;
        //caseRecCreation.vlocity_cmt__ServiceAccountId__c = Cust_ID;
        //caseRecCreation.vlocity_cmt__PremisesId__c =Cust_SrvlocID;
        caseRecCreation.BTN__c = '1232';
        caseRecCreation.NPA_NXX_Requested__c = '1232';
        caseRecCreation.of_numbers_needed__c = '1';
        caseRecCreation.Restriction_Notes__c = 'Test1';
        caseRecCreation.Orderz__c = ord.id;
        caseRecCreation.AccountID = td.acc.id;
        caseRecCreation.Subject = 'TN Reservation - Reserve TNs';
        caseRecCreation.Origin = 'Salesforce';
        caseRecCreationlst.add(caseRecCreation);
        
        insert caseRecCreationlst;  
        caseRecstring.add(caseRecCreationlst[0].id);
                        
        string usmail = 'Test@test.com';
        //DIDCaseInfoController.Save();
        DIDCaseInfoController tw = new DIDCaseInfoController();
        tw.Save();               
        
        PageReference pageRef = page.DIDCaseInputInfo;
        //PageReference   objPageRef1 =  tw.doSubmit();
        //PageReference   objPageRef2 =  tw.doCancel();
        //Test.setCurrentPage(pageRef);
        
        //pageRef.getParameters().put(serloc.id);
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('didLocationId',serloc.id);
        tw.page_load();
                
        DIDCaseInfoController.CaseCreatesendEmail(caseRecCreation,usmail );
        DIDCaseInfoController.CaseClosesendEmail(caseRecstring);

        
    }
    
}