/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
 * 
**/
@isTest
public class ftr_ContractTokenExtractorTest {
    @isTest static void testgetTokenData(){    
        User userObj = [Select Id from User where profile.Name = 'Frontier System Administrator' AND IsActive=true LIMIT 1];
        System.runAs(userObj){
            Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        	Account globalAcc1 = new Account();
        	globalAcc1.Name = 'GLOBAL ACCOUNT';
        	globalAcc1.RecordTypeId = globalRecId;
        	//globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        	insert globalAcc1;
        	Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
            Account ac = new Account();
            ac.RecordTypeId = MasterRTId;
			ac.ParentId = globalAcc1.Id;
            ac.Name = 'test Acc';
            ac.Legal_Street__c='test';
            ac.Legal_City__c='test';
            ac.Legal_State__c='test';
            ac.ShippingStreet='test';
            ac.ShippingCity='NY';
            ac.ShippingState='New York';
            ac.BillingStreet='test';
            ac.BillingCity='NY';
            ac.BillingState='New York';
            ac.Primary_ACNA__c = 'AB56';
            ac.Channel_Affiliations__c = 'DIGITAL PAID SEARCH';
            ac.Website = 'www.google.com';
            ac.Phone = '3456789398';
            insert ac;
            
            Opportunity op  = new Opportunity();
            op.AccountId=ac.Id;
            op.Name= 'test';
            op.StageName = 'Prospecting';
            op.CloseDate = Date.newInstance(2016, 12, 9);
            op.Expected_Billed_Date__c = date.today();
            insert op;
    
            SterlingQuote__c strQuote = new SterlingQuote__c();
            strQuote.OpportunityId__c = op.Id;
            strQuote.Name = 'testQuote';
            insert strQuote;
            
            SterlingQuoteItem__c strQuoteItem = new SterlingQuoteItem__c();
            strQuoteItem.Locality__c = 'Queens';
            strQuoteItem.SA_StreetName__c = 'test';
            strQuoteItem.Postcode__c = '67848';
            strQuoteItem.StateProvince__c = 'New York';
            strQuoteItem.SterlingQuote__c = strQuote.Id;
            insert strQuoteItem;
            
            
            Contract c = new Contract();
            c.Name = 'test';
            c.BillingStreet='test';
            c.BillingCity='NY';
            c.BillingState='New York';  
            c.BillingPostalCode = '45678';
            c.BillingCountry='United States';
            c.ShippingStreet='test';
            c.ShippingCity='NY';
            c.ShippingState='New York';  
            c.ShippingPostalCode = '45678';
            c.ShippingCountry='United States';
            c.AccountId = ac.Id;
            c.Status = 'draft';
            c.StartDate =  Date.newInstance(2016, 12, 9);
            c.ContractTerm = 12;
            c.Contract_Status__c ='Pending';
            c.Document_Status__c  ='Document Generated';
            c.vlocity_cmt__OpportunityId__c = op.id;
            c.Opportunity__c = op.id;
            c.ContractTerm = 24; 
            c.Phone__c = '2042164567'; 
            c.Schedule_Type__c = 'Frontier SmartVoice';
            c.StartDate = Date.today();
            c.PNUM__c = '45678';
            c.Requested_Install_Date__c = Date.newInstance(2016,12,12);
            insert c;
            
            Product2 p = new Product2(Name='Fake Name',IsActive=true, Description='This is fake');
            insert p;
            
            vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
            cli.vlocity_cmt__ContractId__c = c.Id;
            cli.vlocity_cmt__Product2Id__c = p.Id;
            cli.Template_Name__c = 'FakeTemplate';
            cli.vlocity_cmt__OnetimeCharge__c = 100;
            cli.vlocity_cmt__Quantity__c = 2;
            cli.vlocity_cmt__RecurringCharge__c = 10;
            cli.vlocity_cmt__RecurringTotal__c = 10;
            cli.SterlingQuoteLineItem__c = strQuoteItem.Id;
            insert cli;
        
        
            Map<String,Object> input = new Map<String,Object>();
            Map<String,Object> output= new Map<String,Object>();
            Map<String,Object> option = new Map<String,Object>();
            input.put('contextId', c.Id);
            ftr_ContractTokenExtractor cte = new ftr_ContractTokenExtractor();
            Boolean check = (Boolean) cte.invokeMethod('getTokenData', input, output, option);
            System.assert(check);
        }
    }
    @isTest static void add2Decimals(){
        string testStr = ftr_ContractTokenExtractor.add2Decimals(12);
        System.assert(testStr == '12.00');
        testStr = ftr_ContractTokenExtractor.add2Decimals(12.1);
        System.assert(testStr == '12.10');
    }
}