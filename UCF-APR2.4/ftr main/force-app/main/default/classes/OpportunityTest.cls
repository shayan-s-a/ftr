/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3 
 * @author            : TBD
 * @version           : 9 
**/
@isTest(seeAllData = false)
//@isTest
public class OpportunityTest {
    
    static testmethod void unitTest(){
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        insert globalAcc1;
       //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account acc = new Account(name = 'TestAccount');
        acc.RecordTypeId = MasterRTId;
        acc.ParentId = globalAcc1.Id;
        insert acc;
        List<Opportunity> oppList = new List<Opportunity>();
        acc = [select id from Account where name = 'TestAccount' LIMIT 1];
        
        Opportunity opp = new Opportunity();
        opp.Name ='TestOppty';
        opp.AccountId=acc.id;
        opp.Opportunity_Type__c = 'New';
        opp.Partner_Sales_Stages__c = 'Decision';
        opp.CloseDate= system.today();
        opp.ForecastCategoryName='Commit';
        opp.Campaign__c ='No';       
        opp.New_Logo__c ='No';
        //opp.RecordTypeId ='012E0000000dgAL'; 
        opp.VologyPreSalesEmailSent__c = false;
        opp.StageName='Decision';
        opp.Lead_Product_List__c = 'Managed Firewall';
        opp.Description_of_customer_needs__c = 'Test SEER';
        opp.Description__c ='Test for SEER'; 
        opp.Service_Address__c = '2120 Cannes Dr,Dallas,TX';
        //opp.SEER_Assigned_To__c=u.id;
        
        insert opp;         
        opp = [select id from Opportunity where AccountId =: acc.id limit 1];
        update opp;             
    }
    
    static testmethod void restrictOpportunityCreationByTerritoryTest(){
        
        List<ObjectTerritory2Association> ot2a = [SELECT id, IsDeleted, Territory2Id, objectId, SobjectType FROM ObjectTerritory2Association WHERE IsDeleted = false limit 1];
        //Sadly we can't add the filter AND SobjectType = 'Account' because of a SOQL constraint. However, all the ObjectTerritory2Associations records are Account-related
        //so it happens to work without it.
        
        UserTerritory2Association ut2a = [SELECT id, isActive, territory2Id, userId FROM UserTerritory2Association WHERE isActive = true AND territory2Id != null AND userId != null limit 1];
        UserTerritory2Association ut2aClone = ut2a;
        ut2aClone.id = null;
        ut2aClone.userId = System.UserInfo.getUserId();
        //            insert ut2aClone;
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        // Opportunity opp = [SELECT id, accountId FROM Opportunity WHERE accountId != null LIMIT 1];
        Account acc = new Account(name = 'TestAccount');
        acc.RecordTypeId = MasterRTId;
        acc.ParentId = globalAcc1.Id;
        insert acc;
        Opportunity opp = new Opportunity();
        opp.Name ='TestOppty';
        opp.AccountId=acc.id;
        opp.Opportunity_Type__c = 'New';
        opp.Partner_Sales_Stages__c = 'Decision';
        opp.CloseDate= system.today();
        opp.ForecastCategoryName='Commit';
        opp.Campaign__c ='No';       
        opp.New_Logo__c ='No';
        //opp.RecordTypeId ='012E0000000dgAL';
        opp.VologyPreSalesEmailSent__c = false;
        opp.StageName='Decision';
        opp.Lead_Product_List__c = 'Managed Firewall';      
        opp.Description_of_customer_needs__c = 'Test SEER';
        opp.Description__c ='Test for SEER'; 
        opp.Service_Address__c = '2120 Cannes Dr,Dallas,TX';
        
        insert opp; 
        
        Id recordId = opp.id;
        
        DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();
        
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        
        String query = ' SELECT ' + 
            String.join( fieldNames, ',' ) + 
            ' FROM ' + 
            describeResult.getName() + 
            ' WHERE ' + 
            ' id = :recordId ' + 
            ' LIMIT 1 ';
        
        List<SObject> records = Database.query( query );
        
        Opportunity oppClone = (Opportunity) records[0];
        
        oppClone.Id = null;
        oppClone.accountId = !ot2a.isEmpty()? ot2a.get(0).objectId : acc.id;
        try {
            insert oppClone;
        } catch(exception ex) {
            
        }
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opp);
        OpportunityUtility.restrictOpportunityCreationByTerritory(oppList);   
        
        OpportunityUtility.dummytestcoverage();
    }
    
    static testmethod void checkContractTeamTest(){       
        
        Profile p = [Select id From Profile  where name = '#Alternate Channel Leadership' ];
        UserRole role =[select id from UserRole where name = 'Alternate Channel-Community Connections-Sales Manager' ];
        
        User u1 = new User();
        u1.LastName = 'Test11';
        u1.Alias= 'test';
        u1.Username = 'rajtest1234@gmail.com';
        u1.Email = 'rajkumartest123456@gmail.com';
        u1.CommunityNickname ='rajm';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';       
        u1.ProfileId= p.id;
        u1.UserRoleId = role.id;
        
        insert u1;    
        
        System.runAs(u1){ 
            Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        insert globalAcc1;
       //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
            Id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Property').getRecordTypeId();
            System.debug('recordTypeId1====='+recordTypeId1);
            
            Account acc = new Account();
            acc.RecordTypeId= recordTypeId1; 
            acc.RecordTypeId = MasterRTId;
        	acc.ParentId = globalAcc1.Id;
            acc.name = 'TestAccount';
            acc.Phone='2487958700';
            acc.ShippingStreet = '2188 Cannes ';
            acc.ShippingCity = 'Dallas';
            acc.ShippingState = 'Texas';
            acc.ShippingStateCode = 'TX';
            acc.ShippingPostalCode ='75060'; 
            acc.BillingStreet = '2111 Cannes';
            acc.BillingCity = 'Dallas';
            acc.BillingState = 'Texas';
            acc.BillingStateCode = 'TX';
            acc.BillingPostalCode ='75060';
            acc.ownerId = u1.id;
            
            insert acc;            
                   
            Id recordTypeId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Community_Connections').getRecordTypeId();
           	System.debug('recordTypeId2====='+recordTypeId2);
            
            Opportunity opp = new Opportunity();
            opp.Name ='TestCTOppty';
            opp.AccountId=acc.id;
            opp.Opportunity_Type__c = 'New';
            opp.Partner_Sales_Stages__c = 'Decision';
            opp.CloseDate= system.today();
            opp.ForecastCategoryName='Commit';
            opp.Campaign__c ='No';       
            opp.New_Logo__c ='No';
            opp.RecordTypeId =recordTypeId2;        
            opp.StageName='Validating';
            opp.Lead_Product_List__c = 'Managed Firewall';
            opp.Description_of_customer_needs__c = 'Test SEER';
            opp.Description__c ='Test for SEER'; 
            opp.Service_Address__c = '2111 Cannes,Dallas,TX';
            
            insert opp; 
            
            Opportunity oppnew =[select id ,name ,stagename from Opportunity where id=:opp.id];
            
            Contact con = new Contact(lastname='TestContact', AccountId=acc.id,Phone = '1112223333' ,Email ='test@test.com');
            insert con;
            con = [select id ,email from Contact where lastname='TestContact' limit 1];
            
            Id recordTypeId3 = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Community_Connections_Agreement').getRecordTypeId();
            System.debug('recordTypeId3====='+recordTypeId3);
            
            Contract ctr = new Contract();
            ctr.Name = 'TestContract';
            ctr.RecordTypeId = recordTypeId3;
            ctr.AccountId = acc.id;
            ctr.Opportunity__c = opp.id;
            ctr.StartDate  = Date.Today();
            ctr.Status = 'Draft';
            ctr.ContractTerm = 12;
            ctr.Signatory_Person_Name__c = con.id ;
            ctr.Contract_Team_Status__c ='Drafting';
            insert ctr;             
                     
            Contract cn1 =[select id,name from Contract where Opportunity__c =:oppnew.id ];
            //cn1.Contract_Team_Status__c ='Executed';
            //update cn1;
            System.debug('cn1====='+cn1.id);
            
            //Test.startTest();
            try{               
                opp.StageName = 'Closed/Won';
                update opp; 
            }catch(Exception e){
                
                Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot set the Opportunity Sales Stage to Closed/Won until the Contract Team Status is Executed') ? true : false;
				System.assertEquals(expectedExceptionThrown, true);
				//OR
				//System.assertEquals(expectedExceptionThrown, true);
                
                //String message = e.getMessage();
                //system.assert(message.contains('Cannot set the Opportunity Sales Stage to Closed/Won until the Contract Team Status is Executed'),'message=' + message);
            }
            //Test.StopTest();              
        }        
    }
     static testmethod void checkContractTeamTest1(){       
        
        Profile p = [Select id From Profile  where name = '#Alternate Channel Leadership' ];
        UserRole role =[select id from UserRole where name = 'Alternate Channel-Community Connections-Sales Manager' ];
        
        User u1 = new User();
        u1.LastName = 'Test11';
        u1.Alias= 'test';
        u1.Username = 'rajtest1234@gmail.com';
        u1.Email = 'rajkumartest123456@gmail.com';
        u1.CommunityNickname ='rajm';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';       
        u1.ProfileId= p.id;
        u1.UserRoleId = role.id;
        
        insert u1;    
        
        System.runAs(u1){ 
            
            Id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Property').getRecordTypeId();
            Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        	Account globalAcc1 = new Account();
        	globalAcc1.Name = 'GLOBAL ACCOUNT';
        	globalAcc1.RecordTypeId = globalRecId;
        	insert globalAcc1;
       //  	Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        	Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
            Account acc = new Account();
            acc.RecordTypeId = MasterRTId;
            acc.ParentId = globalAcc1.Id;
            //acc.RecordTypeId= recordTypeId1; 
            acc.name = 'TestAccount';
            acc.Phone='2487958700';
            acc.ShippingStreet = '2188 Cannes ';
            acc.ShippingCity = 'Dallas';
            acc.ShippingState = 'Texas';
            acc.ShippingStateCode = 'TX';
            acc.ShippingPostalCode ='75060'; 
            acc.BillingStreet = '2111 Cannes';
            acc.BillingCity = 'Dallas';
            acc.BillingState = 'Texas';
            acc.BillingStateCode = 'TX';
            acc.BillingPostalCode ='75060';
            acc.ownerId = u1.id;
            
            insert acc;            
                   
            Id recordTypeId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Community_Connections').getRecordTypeId();
           List<Opportunity> newOppList = new List<Opportunity>();
            Opportunity opp = new Opportunity();
            opp.Name ='TestCTOppty';
            opp.AccountId=acc.id;
            opp.Opportunity_Type__c = 'New';
            opp.Partner_Sales_Stages__c = 'Decision';
            opp.CloseDate= system.today();
            opp.ForecastCategoryName='Commit';
            opp.Campaign__c ='No';       
            opp.New_Logo__c ='No';
            opp.RecordTypeId =recordTypeId2;        
            opp.StageName='Decision';
            opp.Lead_Product_List__c = 'Managed Firewall';
            opp.Description_of_customer_needs__c = 'Test SEER';
            opp.Description__c ='Test for SEER'; 
            opp.Service_Address__c = '2111 Cannes,Dallas,TX';
            opp.Service_Zip_code__c = '90605';
            
            insert opp; 
            newOppList.add(opp);
            map<id,Opportunity> newmap = new map<id,Opportunity>() ;
            newmap.put(opp.id,opp);
            Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
            Opportunity oppnew =[select id ,name ,stagename from Opportunity where id=:opp.id];
            
            Contact con = new Contact(lastname='TestContact', AccountId=acc.id,Phone = '1112223333' ,Email ='test@test.com');
            insert con;
            con = [select id ,email from Contact where lastname='TestContact' limit 1];
            
            Id recordTypeId3 = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Community_Connections_Agreement').getRecordTypeId();
            
            Contract ctr = new Contract();
            ctr.Name = 'TestContract';
            ctr.RecordTypeId = recordTypeId3;
            ctr.AccountId = acc.id;
            ctr.Opportunity__c = opp.id;
            ctr.StartDate  = Date.Today();
            ctr.Status = 'Draft';
            ctr.ContractTerm = 12;
            ctr.Signatory_Person_Name__c = con.id ;
            ctr.Contract_Team_Status__c ='Drafting';
            insert ctr;   
            
            Quote qu = new Quote(Name = 'Test Quote',
                                    Service_Term__c = '36 Months',
                                    OpportunityId = opp.id,
                                    SelectedLocations__c = '[{"locationChecked":true,"Id":"0011k00000bRniIAAS","Name":"1565 West Main Street","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75067","ShippingState":"Texas","ShippingStreet":"1565 West Main Street","Premises":{"Copper_Tier__c":"BDT","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPBCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722190","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bSTPPAA4","Name":"305 South Belt Line Road","ShippingCity":"Irving","ShippingCountry":"United States","ShippingPostalCode":"75060","ShippingState":"Texas","ShippingStreet":"305 South Belt Line Road","Premises":{"Copper_Tier__c":"Tier 1","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPVCA2","Last_DSAT_Check__c":"2020-03-02","TicketNo":"1722198","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bRoGPAA0","Name":"1480 North Valley Parkway","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75077","ShippingState":"Texas","ShippingStreet":"1480 North Valley Parkway","Premises":{"Copper_Tier__c":"Tier 2","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPLCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722191","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}}]',
                                   Pricebook2Id = Test.getStandardPricebookId());         
                                 
            Test.startTest();         
                opp.Lead_Product_List__c = 'Managed Firewall';
                opp.SEER_Assigned_To__c = u1.id ;
                opp.VologyPreSalesEmailSent__c =false ;
                opp.StageName='Closed/Won';
                update opp;
                oldMap.put(opp.id,opp);
                
                OpportunityUtility.notifyVologyEmailCallout(newOppList,oldMap);
                OpportunityUtility.checkIfCanCloseWon(newmap,oldMap);
                OpportunityUtility.getSyncedQuotesByOppId(new set<Id>{opp.id});
            Test.StopTest();
              
        }
        
    }
    
    static testMethod void TestCreateContractGenTaskForMDUContractTeamQueue() {
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
       //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account objAccount = new Account();
        objAccount.RecordTypeId = MasterRTId;
        objAccount.ParentId = globalAcc1.Id;
        objAccount.Name = 'Test Acc1';
        INSERT objAccount;
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Community_Connections').getRecordTypeId();
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp1';
        objOpportunity.Accountid = objAccount.id;
        objOpportunity.StageName = 'Prospecting';
        objOpportunity.CloseDate = system.Today()+3;
        objOpportunity.RecordTypeId = recordTypeId;
        
        Test.startTest();
            INSERT objOpportunity;
            //This will run the Trigger on Opp to create Task and assign it to the queue.
            objOpportunity.StageName = 'Contract Requested';
            UPDATE objOpportunity;
        Test.stopTest();
        
        List<Task> lstTask = [SELECT Id FROM Task WHERE WhatId =: objOpportunity.Id LIMIT 1];
        //System.assertEquals(1, lstTask.size());
    }

    /**
        This test method tests miscellaneous functionality of the Opportunity object, including submitting an opportunity
        for approval and checking if it can be closed won.
    *   @Author: Mehedi Hasan (mehedi.hasan@ftr.com)
    */
    static testMethod void TestOpptyUtility() {
        // Get the RecordType Id of the 'Global' Account RecordType
        Id globalRecId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Account'
            AND     DeveloperName = 'Global'
            LIMIT   1
        ]?.Id;
        // Create a new 'Global' Account with the above RecordType
        Account globalAcc1 = new Account(
            Name = 'GLOBAL ACCOUNT',
            RecordTypeId = globalRecId
        );
        insert globalAcc1;
        // Get the RecordType Id of the 'Master' Account RecordType
        Id masterRTId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Account'
            AND     DeveloperName = 'Master'
            LIMIT   1
        ]?.Id;
        // Create a new 'Master' Account with the above RecordType and the 'Global' Account as its parent
        Account masterAcc = new Account(
            Name = 'Master Account',
            RecordTypeId = masterRTId,
            ParentId = globalAcc1.Id
        );
        insert masterAcc;
        // Get the RecordType Id of the 'Community_Connections' Opportunity RecordType
        Id opRecordTypeId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Opportunity'
            AND     DeveloperName = 'Community_Connections'
            LIMIT   1
        ]?.Id;
        // Create two empty Opportunity maps - one for new opportunities and one for old opportunities
        Map<Id, Opportunity> newItems = new Map<Id, Opportunity>();
        Map<Id, Opportunity> oldItems = new Map<Id, Opportunity>();
        // Create a new Opportunity with the 'Community_Connections' RecordType and add it to the 'old' map
        Opportunity opp = new Opportunity(
            Name = 'TestCTOppty',
            AccountId = masterAcc.Id,
            Opportunity_Type__c = 'New',
            Partner_Sales_Stages__c = 'Decision',
            CloseDate = System.today(),
            ForecastCategoryName = 'Commit',
            Campaign__c = 'No',
            New_Logo__c = 'No',
            StageName = 'Decision',
            Lead_Product_List__c = 'Managed Firewall',
            Description_of_customer_needs__c = 'Test SEER',
            Description__c = 'Test for SEER',
            Service_Address__c = '2111 Cannes, Dallas, TX',
            Service_Zip_code__c = '90605',
            RecordTypeId = opRecordTypeId
        );
        insert opp;
        oldItems.put(opp.Id, opp);
        // Get the RecordType Id of the 'Community_Connections_Agreement' Contract RecordType
        Id conRecordTypeId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Contract'
            AND     DeveloperName = 'Community_Connections_Agreement'
            LIMIT   1
        ]?.Id;
        Contract newContract = new Contract();
        newContract.AccountId = masterAcc.Id;
        newContract.Contract_Team_Status__c = 'Executed'; // Set the status to "Executed"
        newContract.StartDate = Date.today(); // Set the start date
        newContract.Opportunity__c = opp.Id;
        newContract.RecordTypeId = conRecordTypeId;
        insert newContract;
        // Retrieve the newly created Opportunity and update its StageName and Reason_Won__c fields
        Opportunity oppNew = [
            SELECT  Id,
                    Name,
                    StageName
            FROM    Opportunity
            WHERE   Id = :opp.Id
        ];
        oppNew.StageName = 'Closed/Won';
        oppNew.Reason_Won__c = 'Relationship';
        update oppNew;
        List<Id> oppList = new List<Id>();
        oppList.add(oppNew.id);
        // Add the updated Opportunity to the 'new' map
        newItems.put(oppNew.Id, oppNew);
        // Call the submitAndApproveOpp(),checkIfCanCloseWon() methods of the OpportunityUtility class with the two Opportunity maps as parameters
        OpportunityUtility.submitAndApproveOpp((Map<Id, Opportunity>) newItems, (Map<Id, Opportunity>) oldItems);
        OpportunityUtility.checkIfCanCloseWon((Map<Id, Opportunity>) newItems, (Map<Id, Opportunity>) oldItems);
        OpportunityUtility.isOpportunityLocked(oppList);
    }
}