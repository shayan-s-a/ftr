@isTest
public with sharing class EmailWithCheckboxControllerTest {

    //version 1.0

    @TestSetup
    static void makeData(){
        //Add user
        Id profileId0=[SELECT Id FROM Profile WHERE Name = 'Frontier Sales User'].Id;
        Id userRoleId0=[SELECT Id FROM UserRole WHERE Name = 'DealDeskApprover' limit 1].Id;

        User u = new User(
            ProfileId =profileId0,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            //CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = userRoleId0,
            isActive=true
        );
        insert u;

    }

    @IsTest
    static void testSendEmail(){
       
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;

        Account globalAc = new Account();
        globalAc.Name = 'Carrier Service';
        globalAc.recordtypeid = globalRecId;
        INSERT globalAc;

        FTRWSAcna__c acna = new FTRWSAcna__c();
        acna.ACNA__c = 'GIM';
        acna.Company__c = globalAc.id;
        acna.Name = 'GIM';
        INSERT acna;

        FTRWSPnum__c pnum = new FTRWSPnum__c();
        pnum.PNum__c = 'EIAV001GIM300484';
        pnum.Name = 'EIAV001GIM300484';
        pnum.Wholesale_ACNA__c = acna.Id;
        INSERT pnum;


        Opportunity opp2 = new Opportunity();
        opp2.Name='Test Opp2';
        opp2.StageName='Decision';
        opp2.AccountId=globalAc.id;
        opp2.CloseDate= System.today();
        opp2.ForecastCategoryName='Commit';
        opp2.Wholesale_ACNA__c = acna.Id;
        opp2.Wholesale_Pnum__c = pnum.Id;
        //opp2.Pricebook2Id = pricebookId;//customPB.Id;
        insert opp2;
        
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'Carrier_Service' AND SobjectType = 'SterlingQuote__c'];

        SterlingQuote__c objquote = new SterlingQuote__c();
        objquote.Name='Testing Name';
        objquote.ExpirationDate__c=date.today();
        objquote.OpportunityId__c=opp2.id;
        objquote.Account_Name__c= globalAc.Id;
        objquote.IsSyncing__c=false;
        objquote.RecordTypeId = recordtypeid[0].Id; 
        //objquote.MinorLine__c = 0;
        insert objquote;   
        
        
        User u = [SELECT Id from User WHERE Email = 'puser000@amamama.com' LIMIT 1];
        
        List<Id> idList= new List<Id>();
        idList.add(u.Id);

        Test.startTest();
        
        EmailWithCheckboxController.sendemail(idList,objquote.Id);
        
        Test.stopTest();
        
    }
}