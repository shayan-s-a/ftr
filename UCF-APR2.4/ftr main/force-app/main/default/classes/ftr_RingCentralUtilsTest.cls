@isTest
private class ftr_RingCentralUtilsTest {
    @isTest static void testUpdateServiceAccountField() {
        // Create test data
        Map<String,String> prodNameCodeMap = new Map<String,String>{

           'EIA  (Ethernet Internet Access)' => 'ENT_ETH_EIA_0002',
            'EVPL (Ethernet Virtual Private Line)' => 'ENT_ETH_EVPL_0002',
            'EVPL EVC' => 'ENT_ETH_EVPL_0010',
            'Network Access' => 'ENT_ETH_ACCESS_0001',
                'M6 UNI SIP PSR RESOURCE SPEC' => 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010',
                'M6 SIP EVC  PSR RESOURCE SPEC' => 'SIP_EVC_PSR_RES_SPEC_0010'

          

        };
        
        // global id insert
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;	
        Account globalAcc1 = new Account();	
        globalAcc1.Name = 'GLOBAL ACCOUNT';	
        globalAcc1.RecordTypeId = globalRecId;	
        insert globalAcc1;
        
        //insert account
        Account testAccount = new Account(Name = 'TestAccount', 
                                        BillingStreet = '123 Main Street',
                                        BillingCity = 'Anywhere',
                                        BillingState = 'Texas',
                                        BillingStateCode = 'TX',
                                        BillingPostalCode = '44088',
                                        ShippingStreet = '123 Main Street',
                                        ShippingCity = 'Anywhere',
                                        ShippingState = 'Texas',
                                        ShippingStateCode = 'TX',
                                        ParentId = globalAcc1.Id,
                                        ShippingPostalCode = '44088');
        insert testAccount;
        System.debug('testAccount' +testAccount);
        
        Opportunity testOpportunity = new Opportunity(Name = 'TestOpp',
                                        AccountId = testAccount.id,
                                        CloseDate = System.today(),
                                        Service_Address__c = 'Test',
                                        Description__c = 'Test',
                                        StageName = 'Investigating',
                                        CPE_Product__c = 'No');
        
        insert testOpportunity;
        System.debug('testOpportunity' +testOpportunity);
        
        
        
       vlocity_cmt__Premises__c premise= new vlocity_cmt__Premises__c(vlocity_cmt__StreetAddress__c = '12 Main Street',
                                                        vlocity_cmt__City__c = 'Anywhere',
                                                        vlocity_cmt__State__c = 'California',
                                                        vlocity_cmt__PostalCode__c = '4407',
                                                        vlocity_cmt__Status__c = 'Connected',
                                                        DSAT_Ticket__c = '211212',
                                                        Copper_Tier__c = 'Tier 1',
                                                        Fiber_Tier__c = 'Tier 1',
                                                        Last_DSAT_Check__c = System.today(),
                                                        WC_QOS__c = 'Platinum',
                                                        WC_Speed__c = '1000MB',
                                                        Market__c = 'B',
                                                        Level__c = 'a',
                                                        WC_CLLI__c = 'MONRNYXA');
        insert premise;
        System.debug('premise' +premise);
        
        Account servAccountList = new Account(Name = 'TestAccount', 
                                        BillingStreet = '123 Main Street',
                                        BillingCity = 'Anywhere',
                                        BillingState = 'Texas',
                                        BillingStateCode = 'TX',
                                        BillingPostalCode = '44088',
                                        ShippingStreet = '123 Main Street',
                                        ShippingCity = 'Anywhere',
                                        ShippingState = 'Texas',
                                        ShippingStateCode = 'TX',
                                        ParentId = globalAcc1.Id,
                                        ShippingPostalCode = '44088',
                                             vlocity_cmt__PremisesId__c=premise.Id);
        insert servAccountList;
        
        Account servAccountList2 = new Account(Name = 'TestAccount2', 
                                        BillingStreet = '123 Main Street',
                                        BillingCity = 'Anywhere',
                                        BillingState = 'Texas',
                                        BillingStateCode = 'TX',
                                        BillingPostalCode = '44088',
                                        ShippingStreet = '123 Main Street',
                                        ShippingCity = 'Anywhere',
                                        ShippingState = 'Texas',
                                        ShippingStateCode = 'TX',
                                        ParentId = globalAcc1.Id,
                                        ShippingPostalCode = '44088',
                                             vlocity_cmt__PremisesId__c=premise.Id);
        insert servAccountList2;
      

        
        Product2 testproduct = new Product2(Name = 'testproduct',
                                    ProductCode = prodNameCodeMap.get('DPI Circuit Billing CFS'),
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true); 
        insert testproduct;
        System.debug('testproduct' +testproduct);
        
                PricebookEntry pbe=new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = testproduct.Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false);
        
        insert pbe;
        System.debug('pbe' +pbe);
        
        Quote testQuote = new Quote(Name = 'Test Quote',
                                    Service_Term__c = '36 Months',
                                    OpportunityId = testOpportunity.id,
                                    SelectedLocations__c = '[{"locationChecked":true,"Id":"0011k00000bRniIAAS","Name":"1565 West Main Street","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75067","ShippingState":"Texas","ShippingStreet":"1565 West Main Street","Premises":{"Copper_Tier__c":"BDT","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPBCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722190","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bSTPPAA4","Name":"305 South Belt Line Road","ShippingCity":"Irving","ShippingCountry":"United States","ShippingPostalCode":"75060","ShippingState":"Texas","ShippingStreet":"305 South Belt Line Road","Premises":{"Copper_Tier__c":"Tier 1","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPVCA2","Last_DSAT_Check__c":"2020-03-02","TicketNo":"1722198","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bRoGPAA0","Name":"1480 North Valley Parkway","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75077","ShippingState":"Texas","ShippingStreet":"1480 North Valley Parkway","Premises":{"Copper_Tier__c":"Tier 2","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPLCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722191","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}}]',
                                    Pricebook2Id = Test.getStandardPricebookId());
        insert testQuote;
        System.debug('testQuote' +testQuote);
        
        QuoteLineItem testQLI = new QuoteLineItem(quoteId = testQuote.id,
                                                PricebookEntryId = pbe.id,
                                                Quantity = 1,
                                                vlocity_cmt__ServiceAccountId__c = servAccountList.Id,
                                                UnitPrice = 34.50,
                                                Term__c = '36 Months',
                                                Speed__c = '20 Mbps',
                                                vlocity_cmt__Product2Id__c = pbe.Product2Id,
                                                vlocity_cmt__LineNumber__c = '000',
                                                Product2Id = pbe.Product2Id,
                                                vlocity_cmt__BaseRecurringCharge__c = 100,
                                                vlocity_cmt__RecurringCharge__c = 95);
        insert testQLI;
        
        QuoteLineItem testQLI2 = new QuoteLineItem(quoteId = testQuote.id,
                                                PricebookEntryId = pbe.id,
                                                Quantity = 1,
                                                vlocity_cmt__ServiceAccountId__c = servAccountList2.Id,
                                                UnitPrice = 34.50,
                                                Term__c = '36 Months',
                                                Speed__c = '20 Mbps',
                                                vlocity_cmt__Product2Id__c = pbe.Product2Id,
                                                vlocity_cmt__LineNumber__c = '000',
                                                Product2Id = pbe.Product2Id,
                                                vlocity_cmt__BaseRecurringCharge__c = 100,
                                                vlocity_cmt__RecurringCharge__c = 95);
        
        insert testQLI2;
        
        
        System.debug('testQLI' +testQLI);
        
        // Set up input map
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('ServiceAccountId', servAccountList.Id);
        inputMap.put('cartId', testQuote.Id);
        
        // Set up output map
        Map<String, Object> outputMap = new Map<String, Object>();
         
        // Set up options map
        Map<String, Object> options = new Map<String, Object>();
        
        ftr_RingCentralUtils ringCentralUtils = new ftr_RingCentralUtils();
        
       Boolean result = ringCentralUtils.updateServiceAccountField(inputMap, new Map<String, Object>(), new Map<String, Object>());
       
        Boolean result2 = ringCentralUtils.invokeMethod('updateServiceAccountField', inputMap, outputMap, options);
        
        QuoteLineItem updatedQLI = [SELECT vlocity_cmt__ServiceAccountId__c FROM QuoteLineItem WHERE Id = :testQLI.Id];
        QuoteLineItem updatedQLI2 = [SELECT vlocity_cmt__ServiceAccountId__c FROM QuoteLineItem WHERE Id = :testQLI2.Id];
        
         System.assertEquals(true, result, 'The updateServiceAccountField method should return true');
        System.assertEquals(true, result2, 'The invoke method should return true');
       System.assertEquals(servAccountList.Id, updatedQLI.vlocity_cmt__ServiceAccountId__c);
      //  System.assertEquals(servAccountList.Id, updatedQLI2.vlocity_cmt__ServiceAccountId__c);
    }
    
  /*  @isTest static void testUpdateServiceAccountFieldwithException() {
        
       Map<String,String> prodNameCodeMap = new Map<String,String>{

           'EIA  (Ethernet Internet Access)' => 'ENT_ETH_EIA_0002',
            'EVPL (Ethernet Virtual Private Line)' => 'ENT_ETH_EVPL_0002',
            'EVPL EVC' => 'ENT_ETH_EVPL_0010',
            'Network Access' => 'ENT_ETH_ACCESS_0001',
                'M6 UNI SIP PSR RESOURCE SPEC' => 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010',
                'M6 SIP EVC  PSR RESOURCE SPEC' => 'SIP_EVC_PSR_RES_SPEC_0010'

          

        };
        
        // global id insert
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;	
        Account globalAcc1 = new Account();	
        globalAcc1.Name = 'GLOBAL ACCOUNT';	
        globalAcc1.RecordTypeId = globalRecId;	
        insert globalAcc1;
        
        //insert account
        Account testAccount = new Account(Name = 'TestAccount', 
                                        BillingStreet = '123 Main Street',
                                        BillingCity = 'Anywhere',
                                        BillingState = 'Texas',
                                        BillingStateCode = 'TX',
                                        BillingPostalCode = '44088',
                                        ShippingStreet = '123 Main Street',
                                        ShippingCity = 'Anywhere',
                                        ShippingState = 'Texas',
                                        ShippingStateCode = 'TX',
                                        ParentId = globalAcc1.Id,
                                        ShippingPostalCode = '44088');
        insert testAccount;
        System.debug('testAccount' +testAccount);
        
        Opportunity testOpportunity = new Opportunity(Name = 'TestOpp',
                                        AccountId = testAccount.id,
                                        CloseDate = System.today(),
                                        Service_Address__c = 'Test',
                                        Description__c = 'Test',
                                        StageName = 'Investigating',
                                        CPE_Product__c = 'No');
        
        insert testOpportunity;
        System.debug('testOpportunity' +testOpportunity);
        
        
        
       vlocity_cmt__Premises__c premise= new vlocity_cmt__Premises__c(vlocity_cmt__StreetAddress__c = '12 Main Street',
                                                        vlocity_cmt__City__c = 'Anywhere',
                                                        vlocity_cmt__State__c = 'California',
                                                        vlocity_cmt__PostalCode__c = '4407',
                                                        vlocity_cmt__Status__c = 'Connected',
                                                        DSAT_Ticket__c = '211212',
                                                        Copper_Tier__c = 'Tier 1',
                                                        Fiber_Tier__c = 'Tier 1',
                                                        Last_DSAT_Check__c = System.today(),
                                                        WC_QOS__c = 'Platinum',
                                                        WC_Speed__c = '1000MB',
                                                        Market__c = 'B',
                                                        Level__c = 'a',
                                                        WC_CLLI__c = 'MONRNYXA');
        insert premise;
        System.debug('premise' +premise);
        
        Account servAccountList = new Account(Name = 'TestAccount', 
                                        BillingStreet = '123 Main Street',
                                        BillingCity = 'Anywhere',
                                        BillingState = 'Texas',
                                        BillingStateCode = 'TX',
                                        BillingPostalCode = '44088',
                                        ShippingStreet = '123 Main Street',
                                        ShippingCity = 'Anywhere',
                                        ShippingState = 'Texas',
                                        ShippingStateCode = 'TX',
                                        ParentId = globalAcc1.Id,
                                        ShippingPostalCode = '44088',
                                             vlocity_cmt__PremisesId__c=premise.Id);
        insert servAccountList;
        
        Account servAccountList2 = new Account(Name = 'TestAccount2', 
                                        BillingStreet = '123 Main Street',
                                        BillingCity = 'Anywhere',
                                        BillingState = 'Texas',
                                        BillingStateCode = 'TX',
                                        BillingPostalCode = '44088',
                                        ShippingStreet = '123 Main Street',
                                        ShippingCity = 'Anywhere',
                                        ShippingState = 'Texas',
                                        ShippingStateCode = 'TX',
                                        ParentId = globalAcc1.Id,
                                        ShippingPostalCode = '44088',
                                             vlocity_cmt__PremisesId__c=premise.Id);
        insert servAccountList2;
      

        
        Product2 testproduct = new Product2(Name = 'testproduct',
                                    ProductCode = prodNameCodeMap.get('DPI Circuit Billing CFS'),
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true); 
        insert testproduct;
        System.debug('testproduct' +testproduct);
        
                PricebookEntry pbe=new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = testproduct.Id,
                                            UnitPrice = 100,
                                            IsActive = true,
                                            UseStandardPrice = false);
        
        insert pbe;
        System.debug('pbe' +pbe);
        
        Quote testQuote = new Quote(Name = 'Test Quote',
                                    Service_Term__c = '36 Months',
                                    OpportunityId = testOpportunity.id,
                                    SelectedLocations__c = '[{"locationChecked":true,"Id":"0011k00000bRniIAAS","Name":"1565 West Main Street","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75067","ShippingState":"Texas","ShippingStreet":"1565 West Main Street","Premises":{"Copper_Tier__c":"BDT","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPBCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722190","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bSTPPAA4","Name":"305 South Belt Line Road","ShippingCity":"Irving","ShippingCountry":"United States","ShippingPostalCode":"75060","ShippingState":"Texas","ShippingStreet":"305 South Belt Line Road","Premises":{"Copper_Tier__c":"Tier 1","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPVCA2","Last_DSAT_Check__c":"2020-03-02","TicketNo":"1722198","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}},{"locationChecked":true,"Id":"0011k00000bRoGPAA0","Name":"1480 North Valley Parkway","ShippingCity":"Lewisville","ShippingCountry":"United States","ShippingPostalCode":"75077","ShippingState":"Texas","ShippingStreet":"1480 North Valley Parkway","Premises":{"Copper_Tier__c":"Tier 2","Fiber_Tier__c":"Tier 1","Id":"aAc1k0000004FPLCA2","Last_DSAT_Check__c":"2020-03-01","TicketNo":"1722191","WC_QOS__c":"Platinum","WC_Speed__c":"1000MB"}}]',
                                    Pricebook2Id = Test.getStandardPricebookId());
        insert testQuote;
        System.debug('testQuote' +testQuote);
        
        QuoteLineItem testQLI = new QuoteLineItem(QuoteId = testQuote.id,
                                                PricebookEntryId = pbe.id,
                                                Quantity = 1,
                                                vlocity_cmt__ServiceAccountId__c = servAccountList.Id,
                                                UnitPrice = 34.50,
                                                Term__c = '36 Months',
                                                Speed__c = '20 Mbps',
                                                vlocity_cmt__Product2Id__c = pbe.Product2Id,
                                                vlocity_cmt__LineNumber__c = '000',
                                                Product2Id = pbe.Product2Id,
                                                vlocity_cmt__BaseRecurringCharge__c = 100,
                                                vlocity_cmt__RecurringCharge__c = 95);
        insert testQLI;
        
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('ServiceAccountId', 'InvalidServiceAccountId'); 
        inputMap.put('cartID', 'InvalidCartID'); 
        
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        ftr_RingCentralUtils ringCentralUtils = new ftr_RingCentralUtils();
        
        Test.startTest();
        Boolean result = ringCentralUtils.updateServiceAccountField(inputMap, outputMap, options);
        
        Test.stopTest();
        
        QuoteLineItem updatedQLI = [SELECT vlocity_cmt__ServiceAccountId__c FROM QuoteLineItem WHERE Id = :testQLI.Id];
        System.assertEquals(false, result, 'The updateServiceAccountField method should return false when an exception occurs');
        System.assertEquals('InvalidServiceAccountId', updatedQLI.vlocity_cmt__ServiceAccountId__c, 'Service Account ID should not be updated');
    }*/
}