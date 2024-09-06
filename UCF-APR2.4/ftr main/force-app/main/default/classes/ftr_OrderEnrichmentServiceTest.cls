/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
**/
@isTest
private class ftr_OrderEnrichmentServiceTest {
     
    @testSetup static void createRecords(){
       // OrderUtility.bBypassTrigger = true;
        //Premises
        vlocity_cmt__Premises__c Prms = new vlocity_cmt__Premises__c();
		    Prms.WC_CLLI__c = 'MSTNWIXA';
        insert Prms;       
        //Custom Object Details
        ftr_PSRExchangeDetail__c Ex = new ftr_PSRExchangeDetail__c();
        Ex.WC_CLLI__c = 'MSTNWIXA';
        Ex.Company_Indicator_Code__c = 203;
        Ex.NPANXX__c = '608297';
        insert Ex;
        //Test Account Insert
        
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;	
        Account globalAcc1 = new Account();	
        globalAcc1.Name = 'GLOBAL ACCOUNT';	
        globalAcc1.RecordTypeId = globalRecId;	
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';	
        //insert globalAcc1;	
        Id MasterRTId = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;

        Account a = new Account();
        a.RecordTypeId = MasterRTId;
        a.Name = 'Test Account';
        a.ParentId = globalAcc1.Id;
       // insert a;
        Account serviceAccount = new Account();
        serviceAccount.ParentId = a.Id;
        serviceAccount.Name = 'Service Account';
        serviceAccount.ShippingStreet = '1480 North Valley Parkway';
        serviceAccount.ShippingCity = 'Lewisville';    	
        serviceAccount.ShippingState = 'Texas';
        serviceAccount.ShippingPostalCode = '75077';
        serviceAccount.vlocity_cmt__PremisesId__c= Prms.Id;
        //insert serviceAccount;
        Account serviceAccount1 = new Account();
        serviceAccount1.ParentId = a.Id;
        serviceAccount1.Name = 'Service Account 1';
        serviceAccount1.ShippingStreet = '1565 West Main Street';
        serviceAccount1.ShippingCity = 'Lewisville';    	
        serviceAccount1.ShippingState = 'Texas';
        serviceAccount1.ShippingPostalCode = '75067';
        serviceAccount1.vlocity_cmt__PremisesId__c= Prms.Id;
        //insert serviceAccount1;
        //Test Account 2
        Account a1 = new Account();
        a1.Name = 'Test Account 1';
         a1.RecordTypeId = MasterRTId;
        a1.ParentId = globalAcc1.Id;
        //insert a1;

        //Product-1
        Product2 p = new Product2();
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode = 'ENT_ETH_EIA_0002';
        p.isActive = true;
        insert p;
        //Product-2
        Product2 p2 = new Product2();
        p2.Name = ' Test EVPL EVC ';
        p2.Description='Test EVPL EVC';
        p2.productCode = 'ENT_ETH_EVPL_0010';
        p2.isActive = true;
        insert p2;
        //Product-3
        Product2 p3 = new Product2();
        p3.Name = ' Test UNI ';
        p3.Description='Test UNI';
        p3.productCode = 'ENT_ETH_UNI_0001';
        p3.isActive = true;
        insert p3;
          Product2 p4 = new Product2();
        p4.Name = ' Test IP ';
        p4.Description='Test IP';
        p4.productCode = 'ENT_ETH_IP_0002';
        p4.isActive = true;
        insert p4;
        Product2 p5 = new Product2();
        p5.Name = ' Test EVPL ';
        p5.Description='Test EVPL';
        p5.productCode = 'ENT_ETH_EVPL_0002';
        p5.isActive = true;
        insert p5;
        Product2 p6 = new Product2();
        p6.Name = ' Test SDWAN ';
        p6.Description='Test SDWAN';
        p6.productCode = 'ENT_ETH_SDWAN_001';
        p6.isActive = true;
        insert p6;
        Product2 p7 = new Product2();
        p7.Name = ' Test MR ';
        p7.Description='Test MR';
        p7.productCode = 'ENT_ETH_MR_001';
        p7.isActive = true;
        insert p7;
        //Pricebook Entry
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice1 = new PricebookEntry();
        standardPrice1.Pricebook2Id = pricebookId;
        standardPrice1.Product2Id = p.Id;
        standardPrice1.UnitPrice = 1;
        standardPrice1.IsActive = true;
        standardPrice1.UseStandardPrice = false;
        insert standardPrice1 ;
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = standardPb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        //Test Order Insert

        List<Account> accList = ftr_TestDataFactory.getAccounts(1);
        accList[0].vlocity_cmt__PremisesId__c= Prms.Id;
        insert accList;
        


        Order o = new Order(Name = 'Test Order',
        AccountId = accList[0].id,
        Pricebook2Id = Test.getStandardPricebookId(),
        Status = 'Draft',
        Product__c = 'EIA',
        Product_Type__c = 'Ethernet',
        Router_s__c = 'No Router',
        Customer_Requested_Date__c = System.today(),
        EffectiveDate = System.today(),
        BillingStreet = '123 Main Street',
        BillingCity = 'Anywhere',
        BillingState = 'Texas',
        BillingStateCode = 'TX',
        BillingPostalCode = '44088',
        ShippingStreet = '123 Main Street',
        ShippingCity = 'Anywhere',
        ShippingState = 'Texas',
        ShippingStateCode = 'TX',
        ShippingPostalCode = '44088');
        insert o;    
        system.debug('orderId1: '+ o.id);

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry where  Pricebook2Id=: Test.getStandardPricebookId()];

        //Order Item
        List<OrderItem> orderItemList = new List<OrderItem>();
        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=pbeList[0].id;
        i.vlocity_cmt__ServiceAccountId__c = accList[0].Id;
        i.vlocity_cmt__Product2Id__c = p.Id;
        orderItemList.add(i);

        OrderItem i5 = new OrderItem();
        i5.OrderId = o.id;
        i5.Quantity = 10;
        i5.UnitPrice = 20;
        i5.PricebookEntryId=pbeList[0].id;
        i5.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i5.vlocity_cmt__Product2Id__c = p5.Id;
        i5.vlocity_cmt__rootitemid__c = i.Id;
        i5.uni_host__c = i.Id;
        orderItemList.add(i5);
        
        OrderItem i1 = new OrderItem();
        i1.OrderId = o.id;
        i1.Quantity = 24;
        i1.UnitPrice = 240;
        i1.Product2id = p.id;
        i1.PricebookEntryId=pbeList[0].id;
        i1.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i1.vlocity_cmt__Product2Id__c = p2.Id;
        i1.vlocity_cmt__rootitemid__c = i.Id;
        i1.uni_host__c = i.Id;
        orderItemList.add(i1);

        //insert i1;
        //OrderItem-2
        OrderItem i2 = new OrderItem();
        i2.OrderId = o.id;
        i2.Quantity = 10;
        i2.UnitPrice = 20;
        i2.PricebookEntryId=pbeList[0].id;
        i2.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i2.vlocity_cmt__Product2Id__c = p3.Id;
        i2.vlocity_cmt__rootitemid__c = i.Id;
        i2.uni_host__c = i.Id;
        orderItemList.add(i2);

        //insert i2;
         OrderItem i4 = new OrderItem();
        i4.OrderId = o.id;
        i4.Quantity = 10;
        i4.UnitPrice = 20;
        i4.PricebookEntryId=pbeList[0].id;
        i4.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i4.vlocity_cmt__Product2Id__c = p4.Id;
        i4.vlocity_cmt__rootitemid__c = i.Id;
        i4.uni_host__c = i.Id;
        orderItemList.add(i4);

        OrderItem i41 = new OrderItem();
        i41.OrderId = o.id;
        i41.Quantity = 10;
        i41.UnitPrice = 20;
        i41.PricebookEntryId=pbeList[0].id;
        i41.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i41.vlocity_cmt__Product2Id__c = p7.Id;
        i41.vlocity_cmt__rootitemid__c = i.Id;
        i41.uni_host__c = i.Id;
        i41.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7be000000050xQAAQ","attributecategoryid__c":"a7ae0000000ElHKAA0","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_BANDWIDTH","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Speed","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QEAEA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"NA","sequence":1,"id":"b0966bd9-fd8a-64e8-c734-491d83f778f4","displayText":"NA"},{"value":"5 Mbps","sequence":5,"id":"4aba2306-23a9-9d57-df5e-6845e3943828","displayText":"5 Mbps"},{"value":"10 Mbps","sequence":10,"id":"1a208fd2-ccf1-e3ad-2f16-3009f90cb522","displayText":"10 Mbps"},{"value":"20 Mbps","sequence":20,"id":"8b45b7bf-7984-df2e-7378-108ef35bc8a5","displayText":"20 Mbps"},{"value":"30 Mbps","sequence":23,"id":"8e3195a8-38f9-7b18-d78b-87ef50d43f48","displayText":"30 Mbps"},{"value":"40 Mbps","sequence":26,"id":"8628d5bb-244e-41e2-db08-85d3cb246e8f","displayText":"40 Mbps"},{"value":"50 Mbps","sequence":30,"id":"f7bc4c42-ca8b-bd24-832f-a4a106b8173b","displayText":"50 Mbps"},{"value":"100 Mbps","sequence":40,"id":"ed22cdc9-eb1e-cd69-15a9-f5669740afb5","displayText":"100 Mbps"},{"value":"200 Mbps","sequence":50,"id":"3c2416ab-8c99-5331-c40b-ba36ca84bf72","displayText":"200 Mbps"},{"value":"300 Mbps","sequence":60,"id":"c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9","displayText":"300 Mbps"},{"value":"400 Mbps","sequence":70,"id":"fdebc972-b9ec-e456-1d6e-5d03c284ca67","displayText":"400 Mbps"},{"value":"500 Mbps","sequence":80,"id":"5b421e64-e57e-6aa5-fc1a-55c926e9e3dc","displayText":"500 Mbps"},{"value":"600 Mbps","sequence":90,"id":"f2af83f9-ab01-4700-0fe5-b02afe290f69","displayText":"600 Mbps"},{"value":"700 Mbps","sequence":100,"id":"0501fb70-8e20-540d-d4d5-2330d003a939","displayText":"700 Mbps"},{"value":"800 Mbps","sequence":110,"id":"e049798b-2162-1f86-1bdc-508c3e58a89d","displayText":"800 Mbps"},{"value":"900 Mbps","sequence":120,"id":"9e713b50-7ac2-2053-0aad-eeb42c9db47f","displayText":"900 Mbps"},{"value":"1 Gbps","sequence":130,"id":"3aa261dc-29ca-d36d-2a72-5e253b8937f3","displayText":"1 Gbps"},{"value":"2 Gbps","sequence":140,"id":"092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4","displayText":"2 Gbps"},{"value":"5 Gbps","sequence":170,"id":"ecd9008f-9dd8-2415-6574-a52930dc128f","displayText":"5 Gbps"},{"value":"10 Gbps","sequence":180,"id":"e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf","displayText":"10 Gbps"}],"default":[],"selectedItem":{"value":"20 Mbps","sequence":20,"id":"8b45b7bf-7984-df2e-7378-108ef35bc8a5","displayText":"20 Mbps"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7be000000050xSAAQ","attributecategoryid__c":"a7ae0000000ElHKAA0","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_CONTRACT_TERM","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Term","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QECEA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 Months","sequence":10,"id":"acf430f3-5767-4418-ae26-7ec4b80dbc8d","displayText":"12 Months"},{"value":"24 Months","sequence":20,"id":"7fca7a0e-1452-c879-31f2-baa9553ba1a9","displayText":"24 Months"},{"value":"36 Months","sequence":30,"id":"3ce165f6-d467-6a31-f2bf-edbbcad82725","displayText":"36 Months"},{"value":"60 Months","sequence":40,"id":"8782756f-f4d6-5b3a-951d-037e55539c20","displayText":"60 Months"}],"default":[],"selectedItem":{"value":"36 Months","sequence":30,"id":"3ce165f6-d467-6a31-f2bf-edbbcad82725","displayText":"36 Months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7be000000050xSAAQ","attributecategoryid__c":"a7ae0000000ElHKAA0","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_NSG_TYPE","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Term","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QECEA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01tg000000ADkgZAAT","attributeid__c":"a7be000000050xSAAQ","attributecategoryid__c":"a7ae0000000ElHKAA0","categorycode__c":"FTR_ENT_PRI_ATTCAT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"ATTR_PREMIER_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Term","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a7Yg00000019QECEA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{},"$$AttributeDefinitionEnd$$":null}]}';    

        orderItemList.add(i41);

        insert orderItemList;

        orderItemList[2].vlocity_cmt__rootitemid__c = orderItemList[1].Id;
        orderItemList[2].uni_host__c = orderItemList[1].Id;
        
        update orderItemList;


                
        //Test Order Insert
        Order o1 = new Order();
        o1.Name = 'Test Order 04.15.20';
        o1.Status = 'Draft';
        o1.EffectiveDate = system.today();
        o1.EndDate = system.today() + 10;
        o1.AccountId = a.id;
        o1.Pricebook2Id =  standardPb.Id ;
        //insert o1;
        system.debug('orderId1: '+ o1.id);
        //Test OrderItem on second insert
        OrderItem i3 = new OrderItem();
        i3.OrderId = o1.id;
        i3.Quantity = 20;
        i3.UnitPrice = 120;
        i3.PricebookEntryId=standardPrice.id;
        i3.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i3.vlocity_cmt__Product2Id__c = p.Id;
        //insert i3;
               
        OrderItem i6 = new OrderItem();
        i6.OrderId = o1.id;
        i6.Quantity = 105;
        i6.UnitPrice = 205;
        i6.PricebookEntryId=standardPrice.id;
        i6.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i6.vlocity_cmt__Product2Id__c = p6.Id;
        i6.vlocity_cmt__rootitemid__c = i.Id;
        i6.uni_host__c = i.Id;
        //insert i6;

        OrderItem i7 = new OrderItem();
        i7.OrderId = o1.id;
        i7.Quantity = 110;
        i7.UnitPrice = 210;
        i7.PricebookEntryId=standardPrice.id;
        i7.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i7.vlocity_cmt__Product2Id__c = p7.Id;
        i7.vlocity_cmt__rootitemid__c = i.Id;
        i7.uni_host__c = i.Id;
        
        //insert i7;
        
        //Test Order Insert
        Order o2 = new Order();
        o2.Name = 'Test Order for 04.15.22';
        o2.Status = 'Draft';
        o2.EffectiveDate = system.today();
        o2.EndDate = system.today() - 10;
        o2.AccountId = a.id;
        o2.Pricebook2Id =  standardPb.Id;
        //insert o2;
        system.debug('orderId2: '+ o2.id);
        //Test OrderItem on second insert
        //
        OrderItem i9 = new OrderItem();
        i9.OrderId = o.id;
        i9.Quantity = 24;
        i9.UnitPrice = 240;
        i9.Product2id = p.id;
        i9.PricebookEntryId=standardPrice.id;
        i9.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i9.vlocity_cmt__Product2Id__c = p.Id;
        //insert i9;
        OrderItem i8 = new OrderItem();
        i8.OrderId = o2.id;
        i8.Quantity = 20;
        i8.UnitPrice = 120;
        i8.Product2id = p7.id;
        i8.PricebookEntryId=standardPrice.id;
        i8.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i8.vlocity_cmt__Product2Id__c = p7.Id;
        i8.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';    
        //insert i8;

   }
    static testMethod void OrderEnrichmentSETest() {
        

        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();
        List<Order> oList = [Select Id from Order];
        inputMap.put('orderId', oList[0].id);

        Test.startTest();
        ftr_OrderEnrichmentService SubOrder = new ftr_OrderEnrichmentService();
        SubOrder.invokeMethod('getExchangeDetails', inputMap, outputMap, optionsMap);
        Test.stopTest();
        /*inputMap.put('orderId',o1.id);
        ftr_OrderEnrichmentService service = new ftr_OrderEnrichmentService();
        service.invokeMethod('getExchangeDetails', inputMap, outputMap, optionsMap);    */    
    }
     static testMethod void UpdateSNEAttributesTest() {
      

        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();

        List<Order> oList = [Select Id from Order];
        inputMap.put('orderId', oList[0].id);

        Test.startTest();
        ftr_OrderEnrichmentService SubOrder = new ftr_OrderEnrichmentService();
        SubOrder.invokeMethod('UpdateSNEAttributes', inputMap, outputMap, optionsMap);
        Test.stopTest();
        /*inputMap.put('orderId', o1.id);
        ftr_OrderEnrichmentService service = new ftr_OrderEnrichmentService();
        service.invokeMethod('UpdateSNEAttributes', inputMap, outputMap, optionsMap);
          inputMap.put('orderId', o1.id);
        ftr_OrderEnrichmentService serviceORD = new ftr_OrderEnrichmentService();
        serviceORD.invokeMethod('UpdateSNEAttributes', inputMap, outputMap, optionsMap);*/
   }
    /*static testMethod void UpdateSNEAttributesTest1() {
        List<Order> lstOrder = new List<Order>([Select Id from Order]);
        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();
        inputMap.put('orderId', lstOrder[2].id);
        ftr_OrderEnrichmentService serviceORD = new ftr_OrderEnrichmentService();
        serviceORD.invokeMethod('UpdateSNEAttributes', inputMap, outputMap, optionsMap);
    }*/
    static testMethod void updateOrderItemSequenceTest() {
      
        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();
        List<Order> oList = [Select Id from Order];
        inputMap.put('orderId', oList[0].id);

        Test.startTest();
        ftr_OrderEnrichmentService SubOrder = new ftr_OrderEnrichmentService();
        SubOrder.invokeMethod('updateOrderItemSequence', inputMap, outputMap, optionsMap);
        Test.stopTest();
        /*inputMap.put('orderId', o.id);
        ftr_OrderEnrichmentService service = new ftr_OrderEnrichmentService();
        service.invokeMethod('updateOrderItemSequence', inputMap, outputMap, optionsMap);*/
        
    }
    static testMethod void updateOrderItemSequenceEVPLTest() {
       // OrderUtility.bBypassTrigger = true;
             vlocity_cmt__Premises__c Prms = new vlocity_cmt__Premises__c();
		Prms.WC_CLLI__c = 'MSTNWIXA';
        insert Prms;       
        //Custom Object Details
        ftr_PSRExchangeDetail__c Ex = new ftr_PSRExchangeDetail__c();
        Ex.WC_CLLI__c = 'MSTNWIXA';
        Ex.Company_Indicator_Code__c = 203;
        Ex.NPANXX__c = '608297';
        insert Ex;
        //Test Account Insert
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;	
        Account globalAcc1 = new Account();	
        globalAcc1.Name = 'GLOBAL ACCOUNT';	
        globalAcc1.RecordTypeId = globalRecId;	
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';	
        insert globalAcc1;	
     Id MasterRTId = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;

        Account a = new Account();
        a.RecordTypeId = MasterRTId;
        a.Name = 'Test Account';
        a.ParentId = globalAcc1.Id;
       // insert a;
        Account serviceAccount = new Account();
        serviceAccount.ParentId = a.Id;
        serviceAccount.Name = 'Service Account';
        serviceAccount.ShippingStreet = '1480 North Valley Parkway';
        serviceAccount.ShippingCity = 'Lewisville';    	
        serviceAccount.ShippingState = 'Texas';
        serviceAccount.ShippingPostalCode = '75077';
        serviceAccount.vlocity_cmt__PremisesId__c= Prms.Id;
        //insert serviceAccount;
        //Test Account 2
        Account a1 = new Account();
        a1.Name = 'Test Account 1';
         a1.RecordTypeId = MasterRTId;
        a1.ParentId = globalAcc1.Id;
        //insert a1;
        Account serviceAccount1 = new Account();
        serviceAccount1.ParentId = a1.Id;
        serviceAccount1.Name = 'Service Account 1';
        serviceAccount1.ShippingStreet = '1565 West Main Street';
        serviceAccount1.ShippingCity = 'Lewisville';    	
        serviceAccount1.ShippingState = 'Texas';
        serviceAccount1.ShippingPostalCode = '75067';
        serviceAccount1.vlocity_cmt__PremisesId__c= Prms.Id;
       // insert serviceAccount1;
        //Product-1
        Product2 p = new Product2();
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode = 'ENT_ETH_EIA_0002';
        p.isActive = true;
        insert p;
        //Product-2
        Product2 p2 = new Product2();
        p2.Name = ' Test EVPL EVC ';
        p2.Description='Test EVPL EVC';
        p2.productCode = 'ENT_ETH_EVPL_0010';
        p2.isActive = true;
        insert p2;
        //Product-3
        Product2 p3 = new Product2();
        p3.Name = ' Test UNI ';
        p3.Description='Test UNI';
        p3.productCode = 'ENT_ETH_UNI_0001';
        p3.isActive = true;
        insert p3;
          Product2 p4 = new Product2();
        p4.Name = ' Test IP ';
        p4.Description='Test IP';
        p4.productCode = 'ENT_ETH_IP_0002';
        p4.isActive = true;
        insert p4;
        Product2 p5 = new Product2();
        p5.Name = ' Test EVPL ';
        p5.Description='Test EVPL';
        p5.productCode = 'ENT_ETH_EVPL_0002';
        p5.isActive = true;
        insert p5;
        Product2 p6 = new Product2();
        p6.Name = ' Test SDWAN ';
        p6.Description='Test SDWAN';
        p6.productCode = 'ENT_ETH_SDWAN_001';
        p6.isActive = true;
        insert p6;
        Product2 p7 = new Product2();
        p7.Name = ' Test MR ';
        p7.Description='Test MR';
        p7.productCode = 'ENT_ETH_MR_001';
        p7.isActive = true;
        insert p7;
        //Pricebook Entry
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice1 = new PricebookEntry();
        standardPrice1.Pricebook2Id = pricebookId;
        standardPrice1.Product2Id = p.Id;
        standardPrice1.UnitPrice = 1;
        standardPrice1.IsActive = true;
        standardPrice1.UseStandardPrice = false;
        insert standardPrice1 ;
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = standardPb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        //Test Order Insert
        Order o = new Order();
        o.Name = 'Test Order 04.10.2020 KE';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 10;
        o.AccountId = a.id;
        o.Pricebook2Id =  standardPb.Id ;
        //insert o;
        system.debug('orderId1: '+ o.id);
        //Order Item
       
        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.id;
        i.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i.vlocity_cmt__Product2Id__c = p.Id;
        //insert i;
         OrderItem i5 = new OrderItem();
        i5.OrderId = o.id;
        i5.Quantity = 10;
        i5.UnitPrice = 20;
        i5.PricebookEntryId=standardPrice.id;
        i5.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i5.vlocity_cmt__Product2Id__c = p5.Id;
        i5.vlocity_cmt__rootitemid__c = i.Id;
        i5.uni_host__c = i.Id;
        //insert i5;
         OrderItem i1 = new OrderItem();
        i1.OrderId = o.id;
        i1.Quantity = 24;
        i1.UnitPrice = 240;
        i1.Product2id = p.id;
        i1.PricebookEntryId=standardPrice.id;
        i1.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i1.vlocity_cmt__Product2Id__c = p2.Id;
        i1.vlocity_cmt__rootitemid__c = i.Id;
        i1.uni_host__c = i.Id;
        //insert i1;
        //OrderItem-2
        OrderItem i2 = new OrderItem();
        i2.OrderId = o.id;
        i2.Quantity = 10;
        i2.UnitPrice = 20;
        i2.PricebookEntryId=standardPrice.id;
        i2.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i2.vlocity_cmt__Product2Id__c = p.Id;
        i2.vlocity_cmt__rootitemid__c = i.Id;
        i2.uni_host__c = i.Id;
        //insert i2;
         OrderItem i4 = new OrderItem();
        i4.OrderId = o.id;
        i4.Quantity = 10;
        i4.UnitPrice = 20;
        i4.PricebookEntryId=standardPrice.id;
        i4.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i4.vlocity_cmt__Product2Id__c = p4.Id;
        i4.vlocity_cmt__rootitemid__c = i.Id;
        i4.uni_host__c = i.Id;
       // insert i4;
                
        //Test Order Insert
        Order o1 = new Order();
        o1.Name = 'Test Order 04.15.20';
        o1.Status = 'Draft';
        o1.EffectiveDate = system.today();
        o1.EndDate = system.today() + 10;
        o1.AccountId = a.id;
        o1.Pricebook2Id =  standardPb.Id ;
        //insert o1;
        system.debug('orderId1: '+ o1.id);
        //Test OrderItem on second insert
        OrderItem i3 = new OrderItem();
        i3.OrderId = o1.id;
        i3.Quantity = 20;
        i3.UnitPrice = 120;
        i3.PricebookEntryId=standardPrice.id;
        i3.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i3.vlocity_cmt__Product2Id__c = p.Id;
        //insert i3;
               
        OrderItem i6 = new OrderItem();
        i6.OrderId = o1.id;
        i6.Quantity = 105;
        i6.UnitPrice = 205;
        i6.PricebookEntryId=standardPrice.id;
        i6.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i6.vlocity_cmt__Product2Id__c = p6.Id;
        i6.vlocity_cmt__rootitemid__c = i.Id;
        i6.uni_host__c = i.Id;
        //insert i6;

        OrderItem i7 = new OrderItem();
        i7.OrderId = o1.id;
        i7.Quantity = 110;
        i7.UnitPrice = 210;
        i7.PricebookEntryId=standardPrice.id;
        i7.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i7.vlocity_cmt__Product2Id__c = p7.Id;
        i7.vlocity_cmt__rootitemid__c = i.Id;
        i7.uni_host__c = i.Id;
        
        //insert i7;
        
        //Test Order Insert
        Order o2 = new Order();
        o2.Name = 'Test Order for 04.15.22';
        o2.Status = 'Draft';
        o2.EffectiveDate = system.today();
        o2.EndDate = system.today() - 10;
        o2.AccountId = a.id;
        o2.Pricebook2Id =  standardPb.Id;
        //insert o2;
        system.debug('orderId2: '+ o2.id);
        //Test OrderItem on second insert
        //
        OrderItem i9 = new OrderItem();
        i9.OrderId = o.id;
        i9.Quantity = 24;
        i9.UnitPrice = 240;
        i9.Product2id = p.id;
        i9.PricebookEntryId=standardPrice.id;
        i9.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i9.vlocity_cmt__Product2Id__c = p.Id;
        //insert i9;
        OrderItem i8 = new OrderItem();
        i8.OrderId = o2.id;
        i8.Quantity = 20;
        i8.UnitPrice = 120;
        i8.Product2id = p7.id;
        i8.PricebookEntryId=standardPrice.id;
        i8.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i8.vlocity_cmt__Product2Id__c = p7.Id;
        i8.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';    
            
      //  List<OrderItem> lstOrderItem = new List<OrderItem>([Select Id,vlocity_cmt__Product2Id__r.ProductCode,OrderId from OrderItem where vlocity_cmt__Product2Id__r.ProductCode = 'ENT_ETH_EVPL_0002']);
        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();
        inputMap.put('orderId', o.id);
        ftr_OrderEnrichmentService SubOrder = new ftr_OrderEnrichmentService();
        SubOrder.invokeMethod('updateOrderItemSequence', inputMap, outputMap, optionsMap);
    }
    static testMethod void updateOrderItemSequenceMRTest() {
      //  OrderUtility.bBypassTrigger = true;
      	vlocity_cmt__Premises__c Prms = new vlocity_cmt__Premises__c();
		Prms.WC_CLLI__c = 'MSTNWIXA';
        insert Prms;       
        //Custom Object Details
        ftr_PSRExchangeDetail__c Ex = new ftr_PSRExchangeDetail__c();
        Ex.WC_CLLI__c = 'MSTNWIXA';
        Ex.Company_Indicator_Code__c = 203;
        Ex.NPANXX__c = '608297';
        insert Ex;
        //Test Account Insert
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;	
        Account globalAcc1 = new Account();	
        globalAcc1.Name = 'GLOBAL ACCOUNT';	
        globalAcc1.RecordTypeId = globalRecId;	
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';	
        insert globalAcc1;	
     Id MasterRTId = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;

        Account a = new Account();
        a.RecordTypeId = MasterRTId;
        a.Name = 'Test Account';
        a.ParentId = globalAcc1.Id;
       // insert a;
        Account serviceAccount = new Account();
        serviceAccount.ParentId = a.Id;
        serviceAccount.Name = 'Service Account';
        serviceAccount.ShippingStreet = '1480 North Valley Parkway';
        serviceAccount.ShippingCity = 'Lewisville';    	
        serviceAccount.ShippingState = 'Texas';
        serviceAccount.ShippingPostalCode = '75077';
        serviceAccount.vlocity_cmt__PremisesId__c= Prms.Id;
        //insert serviceAccount;
        //Test Account 2
        Account a1 = new Account();
        a1.Name = 'Test Account 1';
         a1.RecordTypeId = MasterRTId;
        a1.ParentId = globalAcc1.Id;
        //insert a1;
        Account serviceAccount1 = new Account();
        serviceAccount1.ParentId = a1.Id;
        serviceAccount1.Name = 'Service Account 1';
        serviceAccount1.ShippingStreet = '1565 West Main Street';
        serviceAccount1.ShippingCity = 'Lewisville';    	
        serviceAccount1.ShippingState = 'Texas';
        serviceAccount1.ShippingPostalCode = '75067';
        serviceAccount1.vlocity_cmt__PremisesId__c= Prms.Id;
       // insert serviceAccount1;
        //Product-1
        Product2 p = new Product2();
        p.Name = ' Test EIA ';
        p.Description='Test EIA (Ethernet Internet Access)';
        p.productCode = 'ENT_ETH_EIA_0002';
        p.isActive = true;
        insert p;
        //Product-2
        Product2 p2 = new Product2();
        p2.Name = ' Test EVPL EVC ';
        p2.Description='Test EVPL EVC';
        p2.productCode = 'ENT_ETH_EVPL_0010';
        p2.isActive = true;
        insert p2;
        //Product-3
        Product2 p3 = new Product2();
        p3.Name = ' Test UNI ';
        p3.Description='Test UNI';
        p3.productCode = 'ENT_ETH_UNI_0001';
        p3.isActive = true;
        insert p3;
          Product2 p4 = new Product2();
        p4.Name = ' Test IP ';
        p4.Description='Test IP';
        p4.productCode = 'ENT_ETH_IP_0002';
        p4.isActive = true;
        insert p4;
        Product2 p5 = new Product2();
        p5.Name = ' Test EVPL ';
        p5.Description='Test EVPL';
        p5.productCode = 'ENT_ETH_EVPL_0002';
        p5.isActive = true;
        insert p5;
        Product2 p6 = new Product2();
        p6.Name = ' Test SDWAN ';
        p6.Description='Test SDWAN';
        p6.productCode = 'ENT_ETH_SDWAN_001';
        p6.isActive = true;
        insert p6;
        Product2 p7 = new Product2();
        p7.Name = ' Test MR ';
        p7.Description='Test MR';
        p7.productCode = 'ENT_ETH_MR_001';
        p7.isActive = true;
        insert p7;
        //Pricebook Entry
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice1 = new PricebookEntry();
        standardPrice1.Pricebook2Id = pricebookId;
        standardPrice1.Product2Id = p.Id;
        standardPrice1.UnitPrice = 1;
        standardPrice1.IsActive = true;
        standardPrice1.UseStandardPrice = false;
        insert standardPrice1 ;
        Pricebook2 standardPb = new Pricebook2(Name = 'vlocitytest', Description = 'Price Book vlocity Products', IsActive = true);
        insert standardPb;
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = standardPb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        //Test Order Insert
        Order o = new Order();
        o.Name = 'Test Order 04.10.2020 KE';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 10;
        o.AccountId = a.id;
        o.Pricebook2Id =  standardPb.Id ;
        //insert o;
        system.debug('orderId1: '+ o.id);
        //Order Item
       
        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.id;
        i.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i.vlocity_cmt__Product2Id__c = p.Id;
        //insert i;
         OrderItem i5 = new OrderItem();
        i5.OrderId = o.id;
        i5.Quantity = 10;
        i5.UnitPrice = 20;
        i5.PricebookEntryId=standardPrice.id;
        i5.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i5.vlocity_cmt__Product2Id__c = p5.Id;
        i5.vlocity_cmt__rootitemid__c = i.Id;
        i5.uni_host__c = i.Id;
        //insert i5;
         OrderItem i1 = new OrderItem();
        i1.OrderId = o.id;
        i1.Quantity = 24;
        i1.UnitPrice = 240;
        i1.Product2id = p.id;
        i1.PricebookEntryId=standardPrice.id;
        i1.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i1.vlocity_cmt__Product2Id__c = p2.Id;
        i1.vlocity_cmt__rootitemid__c = i.Id;
        i1.uni_host__c = i.Id;
        //insert i1;
        //OrderItem-2
        OrderItem i2 = new OrderItem();
        i2.OrderId = o.id;
        i2.Quantity = 10;
        i2.UnitPrice = 20;
        i2.PricebookEntryId=standardPrice.id;
        i2.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i2.vlocity_cmt__Product2Id__c = p.Id;
        i2.vlocity_cmt__rootitemid__c = i.Id;
        i2.uni_host__c = i.Id;
        //insert i2;
         OrderItem i4 = new OrderItem();
        i4.OrderId = o.id;
        i4.Quantity = 10;
        i4.UnitPrice = 20;
        i4.PricebookEntryId=standardPrice.id;
        i4.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i4.vlocity_cmt__Product2Id__c = p4.Id;
        i4.vlocity_cmt__rootitemid__c = i.Id;
        i4.uni_host__c = i.Id;
       // insert i4;
                
        //Test Order Insert
        Order o1 = new Order();
        o1.Name = 'Test Order 04.15.20';
        o1.Status = 'Draft';
        o1.EffectiveDate = system.today();
        o1.EndDate = system.today() + 10;
        o1.AccountId = a.id;
        o1.Pricebook2Id =  standardPb.Id ;
        //insert o1;
        system.debug('orderId1: '+ o1.id);
        //Test OrderItem on second insert
        OrderItem i3 = new OrderItem();
        i3.OrderId = o1.id;
        i3.Quantity = 20;
        i3.UnitPrice = 120;
        i3.PricebookEntryId=standardPrice.id;
        i3.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i3.vlocity_cmt__Product2Id__c = p.Id;
        //insert i3;
               
        OrderItem i6 = new OrderItem();
        i6.OrderId = o1.id;
        i6.Quantity = 105;
        i6.UnitPrice = 205;
        i6.PricebookEntryId=standardPrice.id;
        i6.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i6.vlocity_cmt__Product2Id__c = p6.Id;
        i6.vlocity_cmt__rootitemid__c = i.Id;
        i6.uni_host__c = i.Id;
        //insert i6;

        OrderItem i7 = new OrderItem();
        i7.OrderId = o1.id;
        i7.Quantity = 110;
        i7.UnitPrice = 210;
        i7.PricebookEntryId=standardPrice.id;
        i7.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i7.vlocity_cmt__Product2Id__c = p7.Id;
        i7.vlocity_cmt__rootitemid__c = i.Id;
        i7.uni_host__c = i.Id;
        
        //insert i7;
        
        //Test Order Insert
        Order o2 = new Order();
        o2.Name = 'Test Order for 04.15.22';
        o2.Status = 'Draft';
        o2.EffectiveDate = system.today();
        o2.EndDate = system.today() - 10;
        o2.AccountId = a.id;
        o2.Pricebook2Id =  standardPb.Id;
        //insert o2;
        system.debug('orderId2: '+ o2.id);
        //Test OrderItem on second insert
        //
        OrderItem i9 = new OrderItem();
        i9.OrderId = o.id;
        i9.Quantity = 24;
        i9.UnitPrice = 240;
        i9.Product2id = p.id;
        i9.PricebookEntryId=standardPrice.id;
        i9.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        i9.vlocity_cmt__Product2Id__c = p.Id;
        //insert i9;
        OrderItem i8 = new OrderItem();
        i8.OrderId = o2.id;
        i8.Quantity = 20;
        i8.UnitPrice = 120;
        i8.Product2id = p7.id;
        i8.PricebookEntryId=standardPrice.id;
        i8.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        i8.vlocity_cmt__Product2Id__c = p7.Id;
        i8.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xQAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QEAEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "NA", "sequence": 1, "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "displayText": "NA" }, { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" }, { "value": "10 Mbps", "sequence": 10, "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "displayText": "10 Mbps" }, { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" }, { "value": "30 Mbps", "sequence": 23, "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "displayText": "30 Mbps" }, { "value": "40 Mbps", "sequence": 26, "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "displayText": "40 Mbps" }, { "value": "50 Mbps", "sequence": 30, "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "displayText": "50 Mbps" }, { "value": "100 Mbps", "sequence": 40, "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "displayText": "100 Mbps" }, { "value": "200 Mbps", "sequence": 50, "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "displayText": "200 Mbps" }, { "value": "300 Mbps", "sequence": 60, "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "displayText": "300 Mbps" }, { "value": "400 Mbps", "sequence": 70, "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "displayText": "400 Mbps" }, { "value": "500 Mbps", "sequence": 80, "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "displayText": "500 Mbps" }, { "value": "600 Mbps", "sequence": 90, "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "displayText": "600 Mbps" }, { "value": "700 Mbps", "sequence": 100, "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "displayText": "700 Mbps" }, { "value": "800 Mbps", "sequence": 110, "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "displayText": "800 Mbps" }, { "value": "900 Mbps", "sequence": 120, "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "displayText": "900 Mbps" }, { "value": "1 Gbps", "sequence": 130, "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "displayText": "1 Gbps" }, { "value": "2 Gbps", "sequence": 140, "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "displayText": "2 Gbps" }, { "value": "5 Gbps", "sequence": 170, "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "displayText": "5 Gbps" }, { "value": "10 Gbps", "sequence": 180, "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "displayText": "10 Gbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01tg000000ADkgZAAT", "attributeid__c": "a7be000000050xSAAQ", "attributecategoryid__c": "a7ae0000000ElHKAA0", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CONTRACT_TERM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Term", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Yg00000019QECEA2", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "24 Months", "sequence": 20, "id": "7fca7a0e-1452-c879-31f2-baa9553ba1a9", "displayText": "24 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" }, { "value": "60 Months", "sequence": 40, "id": "8782756f-f4d6-5b3a-951d-037e55539c20", "displayText": "60 Months" } ], "default": [ ], "selectedItem": { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } }, "$$AttributeDefinitionEnd$$": null } ] }';    
               Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();
        inputMap.put('orderId', o.id);
        ftr_OrderEnrichmentService SubOrder = new ftr_OrderEnrichmentService();
        SubOrder.invokeMethod('updateOrderItemSequence', inputMap, outputMap, optionsMap);
    }
       
}