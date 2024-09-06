@IsTest //(seeAllData=true)
public class RecordListWithDeleteControllerTest{

    @isTest static void DIDLocDeletetest1() {
    
         User u = new User(
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
        
        Account acc = new Account(name = 'TestAccount',Customer_Number__c='1234');        
        insert acc;
        
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        
        Account acc1 = new Account(name = 'TestAccount Service',Customer_Number__c='12345',ShippingStreet = '1919 McKinney Avenue',ShippingCity = 'Dallas',ShippingState = 'Texas',ShippingPostalCode = '75201',ShippingCountry = 'United States',RecordTypeid =RecordTypeIdAccount);        
        insert acc1;
        
        Opportunity testOpportunity= new Opportunity(Name = 'Test 1', StageName = 'Investigating', AccountId = acc.Id , CloseDate = Date.today(), Pricebook2Id = Test.getStandardPricebookId());
        insert testOpportunity;   
        
        Id RecordTypeIdOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Contract Renewal').getRecordTypeId();
        
        Order ord = new Order();
        ord.Accountid=acc.id;
        //ord.OwnerId =g1.id;
        ord.Order_Stage__c = 'New';
        ord.RecordTypeid =RecordTypeIdOrder;
        ord.Multi_Location__c='No';
        ord.EffectiveDate=System.today();
        //ord.Contract_Schedule__c=contr.id;
        ord.Order_Point_of_Contact__c=u.ID;
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
        
        list<ftr_DID_Location_Details__c > didlocList = new list<ftr_DID_Location_Details__c>();
        
        ftr_DID_Location_Details__c didlico = new ftr_DID_Location_Details__c();
        didlico.Name ='Test DID1';
        didlico.OrderId__c=ord.id;
        didlico.ServiceAccountId__c=acc1.id;
        didlocList.add(didlico);
        
        ftr_DID_Location_Details__c didlico2 = new ftr_DID_Location_Details__c();
        didlico2.Name ='Test DID1';
        didlico2.OrderId__c=ord.id;
        didlico2.ServiceAccountId__c=acc1.id;
        didlocList.add(didlico2);
        
        
        insert didlocList ;
        
        //delete didlocList;
                        
        RecordListWithDeleteController.getRecords(ord.id);
                
        RecordListWithDeleteController.DeleteRecord(didlocList);
        
    }

}