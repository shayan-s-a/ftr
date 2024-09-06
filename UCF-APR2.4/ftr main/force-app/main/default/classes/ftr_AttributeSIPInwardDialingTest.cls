@isTest
public class ftr_AttributeSIPInwardDialingTest {
   


    static testMethod void sipInwardtest(){

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

        Product2 p8 = new Product2();
        p8.Name = ' Test SIP_TRUNKING_CFS_0010 ';
        p8.Description='Test SIP_TRUNKING_CFS_0010';
        p8.productCode = 'SIP_TRUNKING_CFS_0010';
        p8.isActive = true;
        insert p8;

        Product2 p9 = new Product2();
        p9.Name = ' Test SIP_TRUNKING_DPI_BILLING_RES_SPEC_0010 ';
        p9.Description='Test SIP_TRUNKING_DPI_BILLING_RES_SPEC_0010';
        p9.productCode = 'SIP_TRUNKING_DPI_BILLING_RES_SPEC_0010';
        p9.isActive = true;
        insert p9;
        
        Product2 p10 = new Product2();
        p10.Name = ' Test SIP_NETWORK_ACCESS ';
        p10.Description='Test SIP_NETWORK_ACCESS';
        p10.productCode = 'SIP_NETWORK_ACCESS';
        p10.isActive = true;
        insert p10;
        
        Product2 p11 = new Product2();
        p11.Name = ' Test SIP_ROUTER_INSTALL_CHARGE ';
        p11.Description='Test SIP_ROUTER_INSTALL_CHARGE';
        p11.productCode = 'SIP_ROUTER_INSTALL_CHARGE';
        p11.isActive = true;
        insert p11;

        Product2 p12 = new Product2();
        p12.Name = ' Test SIP_MANAGED_ROUTER_001 ';
        p12.Description='Test SIP_MANAGED_ROUTER_001';
        p12.productCode = 'SIP_MANAGED_ROUTER_001';
        p12.isActive = true;
        insert p12;
        
        Product2 p13 = new Product2();
        p13.Name = ' Test SIP_RACK_BRACKET ';
        p13.Description='Test SIP_RACK_BRACKET';
        p13.productCode = 'SIP_RACK_BRACKET';
        p13.isActive = true;
        insert p13;

        Product2 p14 = new Product2();
        p14.Name = ' Test SIP_INSTALL_KIT ';
        p14.Description='Test SIP_INSTALL_KIT';
        p14.productCode = 'SIP_INSTALL_KIT';
        p14.isActive = true;
        insert p14;
        
        // MDN Products
        Product2 mdn1 = new Product2();
        mdn1.Name = ' Test SIP_DIRECT_INWARD_DIALING ';
        mdn1.Description='Test SIP_DIRECT_INWARD_DIALING';
        mdn1.productCode = 'SIP_DIRECT_INWARD_DIALING';
        mdn1.isActive = true;
        insert mdn1;
       
        Product2 mdn2 = new Product2();
        mdn2.Name = ' Test SIP_LD_BLOCK_OF_TIME_INCLUDED ';
        mdn2.Description='Test SIP_LD_BLOCK_OF_TIME_INCLUDED';
        mdn2.productCode = 'SIP_LD_BLOCK_OF_TIME_INCLUDED';
        mdn2.isActive = true;
        insert mdn2;
        
        Product2 mdn3 = new Product2();
        mdn3.Name = ' Test SIP_INTL_TALK_TO_WORLD ';
        mdn3.Description='Test SIP_INTL_TALK_TO_WORLD';
        mdn3.productCode = 'SIP_INTL_TALK_TO_WORLD';
        mdn3.isActive = true;
        insert mdn3;
        
        Product2 mdn4 = new Product2();
        mdn4.Name = ' Test SIP_TF_NUMBER ';
        mdn4.Description='Test SIP_TF_NUMBER';
        mdn4.productCode = 'SIP_TF_NUMBER';
        mdn4.isActive = true;
        insert mdn4;
        
        Product2 mdn5 = new Product2();
        mdn5.Name = ' Test SIP_TF_ADDITIONAL_BLOCKS ';
        mdn5.Description='Test SIP_TF_ADDITIONAL_BLOCKS';
        mdn5.productCode = 'SIP_TF_ADDITIONAL_BLOCKS';
        mdn5.isActive = true;
        insert mdn5;
        
        Product2 mdn6 = new Product2();
        mdn6.Name = ' Test SIP_LD_BLOCK_OF_TIME ';
        mdn6.Description='Test SIP_LD_BLOCK_OF_TIME';
        mdn6.productCode = 'SIP_LD_BLOCK_OF_TIME';
        mdn6.isActive = true;
        insert mdn6;


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
         
        OrderItem ij = new OrderItem();
        ij.OrderId = o.id;
        ij.Quantity = 10;
        ij.UnitPrice = 20;
        ij.PricebookEntryId=pbeList[0].id;
        ij.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        ij.vlocity_cmt__Product2Id__c = p8.Id;
        ij.vlocity_cmt__rootitemid__c = i.Id;
        ij.uni_host__c = i.Id;
        orderItemList.add(ij);
        
        OrderItem ig = new OrderItem();
        ig.OrderId = o.id;
        ig.Quantity = 10;
        ig.UnitPrice = 20;
        ig.PricebookEntryId=pbeList[0].id;
        ig.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        ig.vlocity_cmt__Product2Id__c = p9.Id;
        ig.vlocity_cmt__rootitemid__c = i.Id;
        ig.uni_host__c = i.Id;
        orderItemList.add(ig);
        
        OrderItem ih = new OrderItem();
        ih.OrderId = o.id;
        ih.Quantity = 10;
        ih.UnitPrice = 20;
        ih.PricebookEntryId=pbeList[0].id;
        ih.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        ih.vlocity_cmt__Product2Id__c = p10.Id;
        ih.vlocity_cmt__rootitemid__c = i.Id;
        ih.uni_host__c = i.Id;
        orderItemList.add(ih);
        
        OrderItem ik = new OrderItem();
        ik.OrderId = o.id;
        ik.Quantity = 10;
        ik.UnitPrice = 20;
        ik.PricebookEntryId=pbeList[0].id;
        ik.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        ik.vlocity_cmt__Product2Id__c = p11.Id;
        ik.vlocity_cmt__rootitemid__c = i.Id;
        ik.uni_host__c = i.Id;
        orderItemList.add(ik);
        
        OrderItem il = new OrderItem();
        il.OrderId = o.id;
        il.Quantity = 10;
        il.UnitPrice = 20;
        il.PricebookEntryId=pbeList[0].id;
        il.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        il.vlocity_cmt__Product2Id__c = p12.Id;
        il.vlocity_cmt__rootitemid__c = i.Id;
        il.uni_host__c = i.Id;
        orderItemList.add(il);
        
        OrderItem im = new OrderItem();
        im.OrderId = o.id;
        im.Quantity = 10;
        im.UnitPrice = 20;
        im.PricebookEntryId=pbeList[0].id;
        im.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        im.vlocity_cmt__Product2Id__c = p13.Id;
        im.vlocity_cmt__rootitemid__c = i.Id;
        im.uni_host__c = i.Id;
        orderItemList.add(im);
        
        OrderItem io = new OrderItem();
        io.OrderId = o.id;
        io.Quantity = 10;
        io.UnitPrice = 20;
        io.PricebookEntryId=pbeList[0].id;
        io.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        io.vlocity_cmt__Product2Id__c = p14.Id;
        io.vlocity_cmt__rootitemid__c = i.Id;
        io.uni_host__c = i.Id;
        orderItemList.add(io);
        
        OrderItem omdn1 = new OrderItem();
        omdn1.OrderId = o.id;
        omdn1.Quantity = 10;
        omdn1.UnitPrice = 20;
        omdn1.PricebookEntryId=pbeList[0].id;
        omdn1.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        omdn1.vlocity_cmt__Product2Id__c = mdn1.Id;
        omdn1.vlocity_cmt__rootitemid__c = i.Id;
        omdn1.uni_host__c = i.Id;
        orderItemList.add(omdn1);
        
        OrderItem omdn2 = new OrderItem();
        omdn2.OrderId = o.id;
        omdn2.Quantity = 10;
        omdn2.UnitPrice = 20;
        omdn2.PricebookEntryId=pbeList[0].id;
        omdn2.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        omdn2.vlocity_cmt__Product2Id__c = mdn2.Id;
        omdn2.vlocity_cmt__rootitemid__c = i.Id;
        omdn2.uni_host__c = i.Id;
        orderItemList.add(omdn2);
        
        OrderItem omdn3 = new OrderItem();
        omdn3.OrderId = o.id;
        omdn3.Quantity = 10;
        omdn3.UnitPrice = 20;
        omdn3.PricebookEntryId=pbeList[0].id;
        omdn3.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        omdn3.vlocity_cmt__Product2Id__c = mdn3.Id;
        omdn3.vlocity_cmt__rootitemid__c = i.Id;
        omdn3.uni_host__c = i.Id;
        orderItemList.add(omdn3);
        
        OrderItem omdn4 = new OrderItem();
        omdn4.OrderId = o.id;
        omdn4.Quantity = 10;
        omdn4.UnitPrice = 20;
        omdn4.PricebookEntryId=pbeList[0].id;
        omdn4.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        omdn4.vlocity_cmt__Product2Id__c = mdn4.Id;
        omdn4.vlocity_cmt__rootitemid__c = i.Id;
        omdn4.uni_host__c = i.Id;
        orderItemList.add(omdn4);
        
        OrderItem omdn5 = new OrderItem();
        omdn5.OrderId = o.id;
        omdn5.Quantity = 10;
        omdn5.UnitPrice = 20;
        omdn5.PricebookEntryId=pbeList[0].id;
        omdn5.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        omdn5.vlocity_cmt__Product2Id__c = mdn5.Id;
        omdn5.vlocity_cmt__rootitemid__c = i.Id;
        omdn5.uni_host__c = i.Id;
        orderItemList.add(omdn5);
        
        OrderItem omdn6 = new OrderItem();
        omdn6.OrderId = o.id;
        omdn6.Quantity = 10;
        omdn6.UnitPrice = 20;
        omdn6.PricebookEntryId=pbeList[0].id;
        omdn6.vlocity_cmt__ServiceAccountId__c = serviceAccount1.Id;
        omdn6.vlocity_cmt__Product2Id__c = mdn6.Id;
        omdn6.vlocity_cmt__rootitemid__c = i.Id;
        omdn6.uni_host__c = i.Id;
        orderItemList.add(omdn6);

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
        Test.startTest();
        ftr_AttributeSIPInwardDialing.setAttributeSIPInwardDialing(o.id);
       
        Test.stopTest();
    }
}