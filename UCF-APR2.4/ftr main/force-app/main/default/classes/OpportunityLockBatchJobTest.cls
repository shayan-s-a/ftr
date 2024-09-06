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
private class OpportunityLockBatchJobTest {
    
  
     static testmethod void unlockOpportunity_Test(){
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
	/* Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Approved', vlocity_cmt__pricelistid__c = 'Test',CloseDate = Date.valueOf('2020-09-23'),Reason_Won_Lost__c = 'Other',Other_Reason_Lost_Details__c = 'Other');
     insert opp;
     approval.lock(opp.id);
     
	 Quote qt = new Quote (Name = 'Test Quote',Order_Opportunity_Unlocked__c = true, OpportunityId =opp.id);
	 insert qt;*/
         
               vlocity_cmt__Premises__c prem =new vlocity_cmt__Premises__c(vlocity_cmt__Address1__c = '123 Main Street',
                                                        vlocity_cmt__City__c = 'Anywhere',
                                                        vlocity_cmt__State__c = 'California',
                                                        vlocity_cmt__PostalCode__c = '44076',
                                                        vlocity_cmt__Status__c = 'Connected',
                                                        DSAT_Ticket__c = '211212',
                                                        Copper_Tier__c = 'Tier 1',
                                                        Fiber_Tier__c = 'Tier 1',
                                                        Last_DSAT_Check__c = System.today(),
                                                        WC_QOS__c = 'Platinum',
                                                        WC_Speed__c = '1000MB',
                                                        Market__c = 'B',
                                                        Level__c = 'a');
        insert prem;
        Account accEval = new Account(Name = 'TestAccount', 
                                        ParentId = globalAcc.Id,
                                        BillingStreet = '123 Main Street',
                                        BillingCity = 'Anywhere',
                                        BillingState = 'Ohio',
                                        BillingPostalCode = '44088',
                                        ShippingStreet = '123 Main Street',
                                        ShippingCity = 'Anywhere',
                                        ShippingState = 'Ohio',
                                        ShippingPostalCode = '44088',
                                        vlocity_cmt__PremisesId__c = prem.id);
        insert accEval;
        
        vlocity_cmt__PriceList__c  prclst = new vlocity_cmt__PriceList__c(Name = 'TestPriceList', 
                                                                          vlocity_cmt__Code__c = 'test code',
                                      			vlocity_cmt__Pricebook2Id__c = Test.getStandardPricebookId());
        insert prclst;
        Opportunity opp = new Opportunity(Name = 'TestOpp',
                                        AccountId = accEval.id,
                                        vlocity_cmt__pricelistid__c = prclst.id,
                                        CloseDate = System.today(),
                                        Service_Address__c = 'Test',
                                        Description__c = 'Test',
                                        StageName = 'Investigating',
                                        CPE_Product__c = 'No');
        insert opp;
         
        Quote qu = new Quote(Name = 'Test Quote',
                                    Service_Term__c = '36 Months',
                                    OpportunityId = opp.id,
                             		vlocity_cmt__pricelistid__c = prclst.id,
                                    SelectedLocations__c = '[{"locationChecked":true,"Id":"0011k00000bRniIAAS","Name":"1565 West Main Street","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75067","ShippingState":"Texas","ShippingStreet":"1565 West Main Street","Premises":{"Copper_Tier__c":"BDT","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPBCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722190","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bSTPPAA4","Name":"305 South Belt Line Road","ShippingCity":"Irving","ShippingCountry":"United States","ShippingPostalCode":"75060","ShippingState":"Texas","ShippingStreet":"305 South Belt Line Road","Premises":{"Copper_Tier__c":"Tier 1","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPVCA2","Last_DSAT_Check__c":"2020-03-02","TicketNo":"1722198","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bRoGPAA0","Name":"1480 North Valley Parkway","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75077","ShippingState":"Texas","ShippingStreet":"1480 North Valley Parkway","Premises":{"Copper_Tier__c":"Tier 2","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPLCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722191","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}}]',
                                    Pricebook2Id = Test.getStandardPricebookId(),
                           			Order_Opportunity_Unlocked__c = true);
        insert qu;
       
        test.startTest();
        OpportunityLockBatchJob olb = new OpportunityLockBatchJob();
        database.executebatch(olb);
        test.stopTest();

    }
    
}