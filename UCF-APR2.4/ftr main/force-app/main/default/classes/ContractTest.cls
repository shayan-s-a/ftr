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
private class ContractTest {
    
    static testmethod void unitTest(){
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        Account acc = new Account(name = 'TestAccount');
        acc.RecordTypeId = MasterRTId;
        acc.ParentId = globalAcc1.Id;
        insert acc;
        acc = [select id from Account where name = 'TestAccount'];
        
        Opportunity opp = ftr_TestDataFactory.getOpportunities(1)[0];
        opp.AccountId = acc.id;
        insert opp;
        opp = [select id from Opportunity where AccountId =: acc.id limit 1]; 
        
        Contact con = new Contact(lastname='TestContact', AccountId=acc.id,Phone = '1112223333');
        insert con;
        con = [select id from Contact where lastname='TestContact' limit 1];
        Product2 singleProd = new Product2(
            Name = 'Test',
            ProductCode = 'Test',
            vlocity_cmt__EffectiveDate__c = System.today(),
            IsActive = true
        );
        insert singleProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                                Product2Id = singleProd.Id,
                                                UnitPrice = 100,
                                                IsActive = true,
                                                UseStandardPrice = false);
        insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem(UnitPrice = 3, OpportunityId=opp.id, Quantity=10, PricebookEntryId=pbe.id);
        insert oli;
        
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Contract.getRecordTypeInfosById();
        String rtId;
        for(Schema.RecordTypeInfo rt: rtMap.values()){
            if(rt.getName() == 'Alternate Channel - NDA')
                rtId = rt.getRecordTypeId();
        }
        
        Contract ctr = new Contract(AccountId = acc.id, Opportunity__c = opp.id, StartDate  = Date.Today(), ContractTerm = 12, RecordTypeId = rtId);
        insert ctr; 
        ctr = [select id from Contract where AccountId =: acc.id limit 1];    
        ctr.CustomerSignedDate = Date.Today();
        ctr.CompanySignedDate=Date.Today();
        
        update ctr;
        delete ctr;
        undelete ctr;
        
    }
}