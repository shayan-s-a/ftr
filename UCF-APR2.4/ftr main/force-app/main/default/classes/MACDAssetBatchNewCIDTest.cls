@isTest
public class MACDAssetBatchNewCIDTest {
    @testSetup
    static void createTestData() {
        // Pricelist entry
        vlocity_cmt__PriceList__c PL = new vlocity_cmt__PriceList__c();
        PL.Name = 'Enterprise';
        PL.vlocity_cmt__Code__c = 'FTR_ENT_PL';
        insert PL;
        // JSON Attribute entry
        List<AssetStagingJSONMapping__c> jsonMappingList = new List<AssetStagingJSONMapping__c>();
        AssetStagingJSONMapping__c JSONMap = new AssetStagingJSONMapping__c();
        JSONMap.Asset_Applicable__c = true;
        JSONMap.AttributeCode__c = 'ATTR_DECOMP_WTN';
        JSONMap.IP_Applicable__c = true;
        JSONMap.StagingField__c = 'WTN__c';
        JSONMap.UNI_Applicable__c = true;
        JSONMap.EVPL_A__c = true;
        JSONMap.Name = 'wtn attr';
        jsonMappingList.add(JSONMap);
        jsonMappingList.add(new AssetStagingJSONMapping__c(Asset_Applicable__c = true, IP_Applicable__c = true, UNI_Applicable__c = true, EVPL_A__c = true, AttributeCode__c = 'ATTR_TECH_JURIS', StagingField__c = 'ftr_PSR_Jurisdiction__c', Name = 'JURISDICTION_CODE'));
        jsonMappingList.add(new AssetStagingJSONMapping__c(Asset_Applicable__c = true, IP_Applicable__c = true, UNI_Applicable__c = true, EVPL_A__c = true, AttributeCode__c = 'ATTR_BANDWIDTH', StagingField__c = 'ftr_PSR_RateCode__c', Name = 'RATE_CODE2'));
        jsonMappingList.add(new AssetStagingJSONMapping__c(Asset_Applicable__c = true, IP_Applicable__c = true, UNI_Applicable__c = true, EVPL_A__c = true, AttributeCode__c = 'NO_MAPPING_FIELD', StagingField__c = 'Term__c', Name = 'No Mapping Field'));
        jsonMappingList.add(new AssetStagingJSONMapping__c(Asset_Applicable__c = false, IP_Applicable__c = false, UNI_Applicable__c = true, EVPL_A__c = false, AttributeCode__c = 'MANAGED_DEVICE_UNI', StagingField__c = 'Managed_Device__c', Name = 'Managed Device'));
        jsonMappingList.add(new AssetStagingJSONMapping__c(Asset_Applicable__c = false, IP_Applicable__c = false, UNI_Applicable__c = false, EVPL_A__c = false, Managed_Router_Applicable__c  = true, AttributeCode__c = 'ATTR_DIA_MNGD_ROUTER_MODEL', StagingField__c = 'Managed_Device_Type__c', Name = 'Managed Device Type'));
        jsonMappingList.add(new AssetStagingJSONMapping__c(Asset_Applicable__c = false, IP_Applicable__c = true, UNI_Applicable__c = false, EVPL_A__c = false, Managed_Router_Applicable__c  = false, AttributeCode__c = 'ATTR_IP_BLOCKS', StagingField__c = 'ftr_IPBlockSize__c', Name = 'IP BLOCKS'));
        jsonMappingList.add(new AssetStagingJSONMapping__c(Asset_Applicable__c = false, IP_Applicable__c = true, UNI_Applicable__c = false, EVPL_A__c = false, Managed_Router_Applicable__c  = false, AttributeCode__c = 'ATTR_TOPO', StagingField__c = 'ftr_IPTopology__c', Name = 'TOPOLOGY'));
		jsonMappingList.add(new AssetStagingJSONMapping__c(Asset_Applicable__c = false, IP_Applicable__c = false, UNI_Applicable__c = true, EVPL_A__c = false, Managed_Router_Applicable__c  = false, AttributeCode__c = 'ATTR_TECH_JURISDICTION', StagingField__c = 'ftr_PSR_Jurisdiction__c', Name = 'UNI Judistriction Code'));
        jsonMappingList.add(new AssetStagingJSONMapping__c(Asset_Applicable__c = true, IP_Applicable__c = true, UNI_Applicable__c = true, EVPL_A__c = true, AttributeCode__c = 'ATTR_BANDWIDTH', StagingField__c = 'SPEED__c', Name = 'BANDIWDTH SPEED'));
        insert jsonMappingList;
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_JSONAttribute_Access' LIMIT 1];
        String runtimeJSON = sr.body.toString(); 
        List < Product_Mapping__c > productMappingList = new List < Product_Mapping__c > ();
        //Product Mapping Entry for UNI
        productMappingList.add(new Product_Mapping__c(Name='ProdMapping1', Product_Code__c = 'ENT_ETH_UNI_0001', Product_Item_Alias__c = 'UNI'));
        //Product Mapping Entry for EVPL-P2P
        productMappingList.add(new Product_Mapping__c(Name='ProdMapping2', Product_Code__c = 'ENT_ETH_EVPL_0010', Product_Item_Alias__c = 'EVPL - P2P'));
        //Product Mapping Entry for EVPL-EIA
        productMappingList.add(new Product_Mapping__c(Name='ProdMapping3', Product_Code__c = 'ENT_ETH_EIA_0002', Product_Item_Alias__c = 'EVPL - EIA'));
        insert productMappingList;
        List < Product2 > prodList = new List < Product2 > ();
        // Product entry
        Product2 pro = new Product2();
        pro.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        pro.Name = 'DIA (Dedicated Internet Access)';
        pro.ProductCode = 'ENT_ETH_EIA_0002';
        pro.ftr_IsComboOrderEnabled__c = true;
        pro.IsActive = true;
        pro.vlocity_cmt__Scope__c = 'Order Item';
        pro.Family = 'Ethernet';
        pro.vlocity_cmt__JSONAttribute__c = runtimeJSON;
        prodList.add(pro);

        Product2 pro1 = new Product2();
        pro1.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        pro1.Name = 'EVPL (A Location)';
        pro1.ProductCode = 'ENT_ETH_EVPL_0002';
        pro1.ftr_IsComboOrderEnabled__c = false;
        pro1.IsActive = true;
        pro1.vlocity_cmt__Scope__c = 'Order Item';
        pro1.Family = 'Ethernet';
        pro1.vlocity_cmt__JSONAttribute__c = runtimeJSON;
        prodList.add(pro1);

        Product2 pro2 = new Product2();
        pro2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        pro2.Name = 'User to Network Interface (UNI) Port';
        pro2.ProductCode = 'ENT_ETH_UNI_0001';
        pro2.ftr_IsComboOrderEnabled__c = true;
        pro2.IsActive = true;
        pro2.vlocity_cmt__Scope__c = 'Order Item';
        pro2.Family = 'Ethernet';
        pro2.vlocity_cmt__JSONAttribute__c = runtimeJSON;
        prodList.add(pro2);

        Product2 pro3 = new Product2();
        pro3.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        pro3.Name = 'IP';
        pro3.ProductCode = 'ENT_ETH_IP_0002';
        pro3.ftr_IsComboOrderEnabled__c = false;
        pro3.IsActive = true;
        pro3.vlocity_cmt__Scope__c = 'Order Item';
        pro3.Family = 'Ethernet';
        pro3.vlocity_cmt__JSONAttribute__c = runtimeJSON;
        prodList.add(pro3);

        Product2 pro4 = new Product2();
        pro4.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        pro4.Name = 'EVPL (Z Location)';
        pro4.ProductCode = 'ENT_ETH_EVPL_0010';
        pro4.ftr_IsComboOrderEnabled__c = true;
        pro4.IsActive = true;
        pro4.vlocity_cmt__Scope__c = 'Downstream Order Item';
        pro4.Family = 'Ethernet';
        pro4.vlocity_cmt__JSONAttribute__c = runtimeJSON;
        prodList.add(pro4);
        
        Product2 pro5 = new Product2();
        pro5.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        pro5.Name = 'Managed Router';
        pro5.ProductCode = 'ENT_ETH_MR_001';
        pro5.ftr_IsComboOrderEnabled__c = true;
        pro5.IsActive = true;
        pro5.vlocity_cmt__Scope__c = 'Downstream Order Item';
        pro5.Family = 'Ethernet';
        pro5.vlocity_cmt__JSONAttribute__c = runtimeJSON;
        prodList.add(pro5);
        insert prodList;
        List < PricebookEntry > pbeList = new List < PricebookEntry > ();
        for (Product2 prod: prodList) {
            PricebookEntry pbe = new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 0, IsActive = true);
            pbeList.add(pbe);
        }
        insert pbeList;
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc;
        Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='master' LIMIT 1]?.Id;
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Customer_Number__c = '7481290';
        acc.Name = 'AMERICAN AIRLINES';
        acc.ParentId = globalAcc.Id;
        //acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Master').getRecordTypeId();
        acc.RecordTypeId = masterRecId;
        acc.M6_Customer_Number__c = '7481290';
        accList.add(acc);
        //this acounts m6 customer numebr will be updated as ocam is picked
        Account acc1 = new Account();
        acc1.Customer_Number__c = '7481245';
        acc1.Name = 'AMERICAN AIRLINES';
        acc1.ParentId = globalAcc.Id;
        //acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Master').getRecordTypeId();
        acc1.RecordTypeId = masterRecId;
        accList.add(acc1);
        Account acc2 = new Account();
        acc2.Customer_Number__c = '56129034';
        acc2.Name = 'SOUTHWEST ARILINES';
        //acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Master').getRecordTypeId();
        acc2.RecordTypeId = masterRecId;
        acc2.ParentId = globalAcc.Id;
        accList.add(acc2);
        insert accList;
        for (Account accRec : accList) {
            accRec.account_id_caps__c = String.valueOf(accRec.Id).toUpperCase();
        }
        update accList;
        List<Account> newAccList = new List<Account>();
        newAccList.add(new Account(Customer_Number__c = '812093732', Name = 'MACDAccountIdCapsUpdateBatchScheduler Account', RecordTypeId = masterRecId, ParentId = globalAcc.Id));
        insert newAccList;
        Account servAcc = new Account();
        servAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        servAcc.Name = '2300 E BAKER STREET '+ ', ' + '75201';
                            servAcc.ParentId = accList[0].Id;
                            servAcc.ShippingStreet = '2300 E BAKER STREET';
                            servAcc.ShippingCity = 'DALLAS';
                            servAcc.BillingCity = 'DALLAS';
                            servAcc.ShippingStateCode = 'TX';
                            servAcc.ShippingPostalCode = '75201';
                            servAcc.BillingPostalCode = '75201';
                            servAcc.BillingStreet = '2300 E BAKER STREET';
                            servAcc.BillingStateCode = 'TX';
        insert servAcc;
        // OCAM 
        List<ftr_Asset_Staging_OCAM__c> ocamList = new List<ftr_Asset_Staging_OCAM__c>();
        ftr_Asset_Staging_OCAM__c OCAM = new ftr_Asset_Staging_OCAM__c();
        OCAM.CUST_NO__c = '7481290';
        OCAM.ACCT_BTN__c = '9721970896';
        OCAM.BTN__c = '9721970896';
        ocamList.add(OCAM);
        ftr_Asset_Staging_OCAM__c OCAM1 = new ftr_Asset_Staging_OCAM__c();
        OCAM1.CUST_NO__c = accList[0].Id;
        OCAM1.ACCT_BTN__c = '9721970896';
        OCAM1.BTN__c = '9721970000';
        ocamList.add(OCAM1);
        ftr_Asset_Staging_OCAM__c OCAM2 = new ftr_Asset_Staging_OCAM__c();
        OCAM2.CUST_NO__c = '7481245';
        OCAM2.ACCT_BTN__c = '97132727392';
        OCAM2.BTN__c = '97132727392';
        ocamList.add(OCAM2);
        
        ftr_Asset_Staging_OCAM__c OCAM3 = new ftr_Asset_Staging_OCAM__c();
        OCAM3.CUST_NO__c = '7481290';
        OCAM3.ACCT_BTN__c = '9756780896';
        OCAM3.BTN__c = '9756780896';
        ocamList.add(OCAM3);
        ftr_Asset_Staging_OCAM__c OCAM4 = new ftr_Asset_Staging_OCAM__c();
        OCAM4.CUST_NO__c = accList[0].account_id_caps__c;
        OCAM4.ACCT_BTN__c = '9721970949';
        OCAM4.BTN__c = '9721970949';
        ocamList.add(OCAM4);
        ftr_Asset_Staging_OCAM__c OCAM5 = new ftr_Asset_Staging_OCAM__c();
        OCAM5.CUST_NO__c = '56129034';
        OCAM5.ACCT_BTN__c = '190827345';
        OCAM5.BTN__c = '190827345';
        ocamList.add(OCAM5);
        insert ocamList;
        
        List<ftr_Asset_StagingCircuit_DPI__c> dpiList = new List<ftr_Asset_StagingCircuit_DPI__c >();
        dpiList.add(new ftr_Asset_StagingCircuit_DPI__c (BTN__c = '190827345', CODE__c = 'EIA3Y', City_Short_Name__c = 'KGM', Control_Number__c = '72344', DESCRIPTION__c = 'Dedicated DIA 3 Year',
                                                        END_DT__c = '0', ENV__c = 'DT', ITEMRATE__c = 0, START_DT__c = '20201215', Status__c = 'Ready',
                                                        WTN__c = '190827345', Summary_TN__c = '9281888044', GAN__c = '0', Zipcode__c = '86401', City__c = 'KINGMAN', Service_Address__c = '3825 STOCKTON HILL RD',
                                                        State__c  = 'AZ'));
        dpiList.add(new ftr_Asset_StagingCircuit_DPI__c (BTN__c = '190827345', CODE__c = 'MEDAG', City_Short_Name__c = 'KGM', Control_Number__c = '72344', DESCRIPTION__c = '20 Mbps DIA SVC',
                                                        END_DT__c = '0', ENV__c = 'DT', ITEMRATE__c = 350, START_DT__c = '20201215', Status__c = 'Ready',
                                                        WTN__c = '190827345', Summary_TN__c = '9281888044', GAN__c = '0', Zipcode__c = '86401', City__c = 'KINGMAN', Service_Address__c = '3825 STOCKTON HILL RD',
                                                        State__c  = 'AZ'));
        dpiList.add(new ftr_Asset_StagingCircuit_DPI__c (BTN__c = '190827345', CODE__c = 'CKT', City_Short_Name__c = 'KGM', Control_Number__c = '72344', DESCRIPTION__c = 'Circuit Resides in M6',
                                                        END_DT__c = '0', ENV__c = 'DT', ITEMRATE__c = 0, START_DT__c = '20201215', Status__c = 'Ready',
                                                        WTN__c = '190827345', Summary_TN__c = '9281888044', GAN__c = '0', Zipcode__c = '86401', City__c = 'KINGMAN', Service_Address__c = '3825 STOCKTON HILL RD',
                                                        State__c  = 'AZ'));
        insert dpiList;
        
        List<ftr_Asset_StagingCircuit__c> circuitList = new List<ftr_Asset_StagingCircuit__c>();
        ftr_Asset_StagingCircuit__c circuit1 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, CUST_ACCT_NBR__c = '7481290', M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - EIA', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970895', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - EIA',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/686121//FTNC/', ftr_RUID2__c = '1952 /GE10  /DLLSTX979DW/IRNGTXXA38W',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/686122/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345',
            Speed__c = '100 MBPS');
        //duplicate circuit with same circuit name so that one will fail
        ftr_Asset_StagingCircuit__c circuit12 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, CUST_ACCT_NBR__c = '7481290', M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - EIA', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970895', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - EIA',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/686121//FTNC/', ftr_RUID2__c = '1952 /GE10  /DLLSTX979DW/IRNGTXXA38W',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/686122/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //DIA FOR UNI
        ftr_Asset_StagingCircuit__c circuit21 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, CUST_ACCT_NBR__c = '7481290', M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - EIA', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970895', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - EIA',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/123456//FTNC/', ftr_RUID2__c = '1952 /GE10  /DLLSTX979DW/IRNGTXXA38W',
            ftr_SECNCI__c = '02VLN.V', Speed__c = '100 GBPS', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/561847/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        // UNI for DIA
 
 		ftr_Asset_StagingCircuit__c circuit2 = new ftr_Asset_StagingCircuit__c (Pass_Number__c=0,CUST_ACCT_NBR__c='7481290',M6_Status__c='In Service', PSR_EVC_Type__c='PSR EVPL - P2P',PSR_SDWAN__c='N',PSR_Virtual_Broadband_Service_Category__c='EVC',PriLocCity__c='DALLAS',PriLocPostalCode__c='75261',
                                                            PriLocState__c='TX',PriLocStreetAddress__c='2300 E CENTRAL PARK STREET',SecLocCity__c='DALLAS',SecLocPostalCode__c='75207',SecLocState__c='TX',SecLocStreetAddress__c='MSAG 1950 N STEMMONS FREEWAY',Status__c='Pending', WTN__c='9721970802',
                                                                         ftr_Account_Name__c='AMERICAN AIRLINES', ftr_Circuit_Id__c='10686121', ftr_CompanyIndicator__c='374',ftr_IPAddressType__c='IPv4', ftr_IPBlockSize__c='', ftr_IPTopology__c='',ftr_Item_Alias__c='UNI',ftr_ManagedFirewall__c='N',
                                                                         ftr_NCI__c='02VLN.V',Speed__c = '100 G', ftr_NPA_NXX__c='972973', ftr_PSR_CIR__c='50 M',ftr_PSR_Jurisdiction__c='2',ftr_PSR_RateCode__c='50 MBPS',ftr_PSR_parentServiceItemId__c='7900724',ftr_RUID1__c='13/L1XN/632873//FTNC/', ftr_RUID2__c='13/L1XN/679511//FTNC/',
                                                                         ftr_SECNCI__c='02VLN.V',ftr_SPEC_GRP_ID__c='1112',ftr_ServiceItemId__c='7946166',ftr_circuitName__c='13/L1XN/123456//FTNC/',ftr_documentNumber__c='3666662', LAN_IP__c='',Managed_Device__c = 'Y',Managed_Device_Type__c='dummy managed device type');
        
        //evpl asset
        ftr_Asset_StagingCircuit__c circuit3 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E 16TH STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970896', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', Speed__c = '100 M', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/686121//FTNC/', ftr_RUID2__c = '13/CUXP/632877/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/686678/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //no account found for circuit
        ftr_Asset_StagingCircuit__c circuit18 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E 16TH STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '8232490409', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/686121//FTNC/', ftr_RUID2__c = '13/CUXP/632877/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/6898762/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //evpl asset
        ftr_Asset_StagingCircuit__c circuit13 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9756780896', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/451221//FTNC/', ftr_RUID2__c = '13/CUXP/093277/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/0123478/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //evpl asset
        //evpl asset
        ftr_Asset_StagingCircuit__c circuit14 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, CUST_ACCT_NBR__c='7481290', M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9756780896', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/452221//FTNC/', ftr_RUID2__c = '13/CUXP/013277/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/0129078/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //evpl asset for account update
        ftr_Asset_StagingCircuit__c circuit11 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E 16TH STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '97132727392', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/626121//FTNC/', ftr_RUID2__c = '13/CUXP/902877/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/999678/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //uni1 fro evpl
        ftr_Asset_StagingCircuit__c circuit4 = new ftr_Asset_StagingCircuit__c (Pass_Number__c=0,
                                                                                M6_Status__c='In Service', PSR_EVC_Type__c='PSR EVPL - P2P',PSR_SDWAN__c='N',PSR_Virtual_Broadband_Service_Category__c='EVC',PriLocCity__c='DALLAS',
                                                                                PriLocPostalCode__c='75261',PriLocState__c='TX',PriLocStreetAddress__c='2300 E 16TH STREET',SecLocCity__c='DALLAS',
                                                                                SecLocPostalCode__c='75207',SecLocState__c='TX',SecLocStreetAddress__c='MSAG 1950 N STEMMONS FREEWAY',Status__c='Pending', 
                                                                                ftr_Account_Name__c='AMERICAN AIRLINES', ftr_Circuit_Id__c='10686122', ftr_CompanyIndicator__c='374',
                                                                                ftr_IPAddressType__c='IPv4', ftr_IPBlockSize__c='', ftr_IPTopology__c='',ftr_Item_Alias__c='UNI',
                                                                                ftr_ManagedFirewall__c='N', ftr_NCI__c='02VLN.V',ftr_NPA_NXX__c='972973', ftr_PSR_CIR__c='50 M',
                                                                                ftr_PSR_Jurisdiction__c='2',ftr_PSR_RateCode__c='50 MBPS',ftr_PSR_parentServiceItemId__c='7900724',
                                                                                ftr_RUID1__c='13/L1XN/632873//FTNC/', ftr_RUID2__c='13/L1XN/679511//FTNC/',ftr_SECNCI__c='02VLN.V',
                                                                                ftr_SPEC_GRP_ID__c='1101',ftr_ServiceItemId__c='7900726',ftr_circuitName__c='13/CUXP/632877/   /FTNC/',
                                                                                ftr_documentNumber__c='3615911', LAN_IP__c='');
        //uni2 for evpl
        
        ftr_Asset_StagingCircuit__c circuit5 = new ftr_Asset_StagingCircuit__c (Pass_Number__c=0,M6_Status__c='In Service', PSR_EVC_Type__c='PSR EVPL - P2P',PSR_SDWAN__c='N',PSR_Virtual_Broadband_Service_Category__c='EVC',
                                                                                PriLocCity__c='DALLAS',PriLocPostalCode__c='75261',PriLocState__c='TX',PriLocStreetAddress__c='2300 E 16TH STREET',SecLocCity__c='DALLAS',SecLocPostalCode__c='75207',
                                                                                SecLocState__c='TX',SecLocStreetAddress__c='MSAG 1950 N STEMMONS FREEWAY',Status__c='Pending', ftr_Account_Name__c='AMERICAN AIRLINES', ftr_Circuit_Id__c='10686122',
                                                                                ftr_CompanyIndicator__c='374',ftr_IPAddressType__c='IPv4', ftr_IPBlockSize__c='', ftr_IPTopology__c='',ftr_Item_Alias__c='UNI',ftr_ManagedFirewall__c='N', ftr_NCI__c='02VLN.V',
                                                                                ftr_NPA_NXX__c='972973', ftr_PSR_CIR__c='50 M',ftr_PSR_Jurisdiction__c='2',ftr_PSR_RateCode__c='50 MBPS',ftr_PSR_parentServiceItemId__c='7900724',ftr_RUID1__c='13/L1XN/632873//FTNC/', 
                                                                                ftr_RUID2__c='13/L1XN/679511//FTNC/',ftr_SECNCI__c='02VLN.V',ftr_SPEC_GRP_ID__c='1101',ftr_ServiceItemId__c='7900726',ftr_circuitName__c='13/CUXP/632877/   /FTNC/',ftr_documentNumber__c='3615911', LAN_IP__c='');
        
        
                //evpl asset
        ftr_Asset_StagingCircuit__c circuit6 = new ftr_Asset_StagingCircuit__c(CUST_ACCT_NBR__c=accList[0].Id, Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E 16TH STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970869', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/686121//FTNC/', ftr_RUID2__c = '13/CUXP/632877/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/686978/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //evpl asset
        ftr_Asset_StagingCircuit__c circuit15 = new ftr_Asset_StagingCircuit__c(CUST_ACCT_NBR__c=accList[0].Id, Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970869', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/133000//FTNC/', ftr_RUID2__c = '13/CUXP/143143/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/158678/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //evpl asset
        ftr_Asset_StagingCircuit__c circuit16 = new ftr_Asset_StagingCircuit__c(CUST_ACCT_NBR__c=accList[0].Id, Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9768670869', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 GBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/398273000//FTNC/', ftr_RUID2__c = '13/CUXP/189273/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/09832764/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        
        //evpl asset
        ftr_Asset_StagingCircuit__c circuit17 = new ftr_Asset_StagingCircuit__c(CUST_ACCT_NBR__c=accList[0].Id, Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '97896879869', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 G', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/908459//FTNC/', ftr_RUID2__c = '13/CUXP/87681294/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/1982738/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        ftr_Asset_StagingCircuit__c circuit7 = new ftr_Asset_StagingCircuit__c( Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970000', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/686121//FTNC/', ftr_RUID2__c = '13/CUXP/632877/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/680000/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //aliasACSET does not scontain alias scenario
        ftr_Asset_StagingCircuit__c circuit19 = new ftr_Asset_StagingCircuit__c( Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970000', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL-P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/686121//FTNC/', ftr_RUID2__c = '13/CUXP/632877/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/680000/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //multiple wtns scenario
        ftr_Asset_StagingCircuit__c circuit20 = new ftr_Asset_StagingCircuit__c( Pass_Number__c = 0, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970000', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/612341//FTNC/', ftr_RUID2__c = '13/CUXP/1232877/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/680123/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //pri loc street address blank scenario
		ftr_Asset_StagingCircuit__c circuit8 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, CUST_ACCT_NBR__c = '7481290', M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - EIA', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '8721970895', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - EIA',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/686121//FTNC/', ftr_RUID2__c = '1952 /GE10  /DLLSTX979DW/IRNGTXXA38W',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/686122/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345'); 
        //wtn blank for circuit not uni
        ftr_Asset_StagingCircuit__c circuit9 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, CUST_ACCT_NBR__c = '7481290', M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - EIA', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - EIA',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/686121//FTNC/', ftr_RUID2__c = '1952 /GE10  /DLLSTX979DW/IRNGTXXA38W',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/686122/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        //WTN BLANK FOR CIRCUIT UNI
        ftr_Asset_StagingCircuit__c circuit10 = new ftr_Asset_StagingCircuit__c (Pass_Number__c=0,M6_Status__c='In Service', PSR_EVC_Type__c='PSR EVPL - P2P',PSR_SDWAN__c='N',PSR_Virtual_Broadband_Service_Category__c='EVC',
                                                                                PriLocCity__c='DALLAS',PriLocPostalCode__c='75261',PriLocState__c='TX',PriLocStreetAddress__c='2300 E 16TH STREET',SecLocCity__c='DALLAS',SecLocPostalCode__c='75207',
                                                                                SecLocState__c='TX',SecLocStreetAddress__c='MSAG 1950 N STEMMONS FREEWAY',Status__c='Pending', ftr_Account_Name__c='AMERICAN AIRLINES', ftr_Circuit_Id__c='10686122',
                                                                                ftr_CompanyIndicator__c='374',ftr_IPAddressType__c='IPv4', ftr_IPBlockSize__c='', ftr_IPTopology__c='',ftr_Item_Alias__c='UNI',ftr_ManagedFirewall__c='N', ftr_NCI__c='02VLN.V',
                                                                                ftr_NPA_NXX__c='972973', ftr_PSR_CIR__c='50 M',ftr_PSR_Jurisdiction__c='2',ftr_PSR_RateCode__c='50 MBPS',ftr_PSR_parentServiceItemId__c='7900724',ftr_RUID1__c='13/L1XN/632873//FTNC/', 
                                                                                ftr_RUID2__c='13/L1XN/679511//FTNC/',ftr_SECNCI__c='02VLN.V',ftr_SPEC_GRP_ID__c='1101',ftr_ServiceItemId__c='7900726',ftr_circuitName__c='13/CUXP/632877/   /FTNC/',ftr_documentNumber__c='3615911', LAN_IP__c='');
         //new evpl asset for account_id_caps__c scenario
        ftr_Asset_StagingCircuit__c circuit22 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, CUST_ACCT_NBR__c = accList[0].account_id_caps__c, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = '2300 E 16TH STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970896', ftr_Account_Name__c = 'AMERICAN AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/CUXP/046106//FTNC/', ftr_RUID2__c = '13/CUXP/817516//FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/309485794//FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        
        //uni1 fro evpl
        ftr_Asset_StagingCircuit__c circuit23 = new ftr_Asset_StagingCircuit__c (Pass_Number__c=0,
                                                                                M6_Status__c='In Service', PSR_EVC_Type__c='PSR EVPL - P2P',PSR_SDWAN__c='N',PSR_Virtual_Broadband_Service_Category__c='EVC',PriLocCity__c='DALLAS',
                                                                                PriLocPostalCode__c='75261',PriLocState__c='TX',PriLocStreetAddress__c='2300 E 16TH STREET',SecLocCity__c='DALLAS',
                                                                                SecLocPostalCode__c='75207',SecLocState__c='TX',SecLocStreetAddress__c='MSAG 1950 N STEMMONS FREEWAY',Status__c='Pending', 
                                                                                ftr_Account_Name__c='AMERICAN AIRLINES', ftr_Circuit_Id__c='10686122', ftr_CompanyIndicator__c='374',
                                                                                ftr_IPAddressType__c='IPv4', ftr_IPBlockSize__c='', ftr_IPTopology__c='',ftr_Item_Alias__c='UNI',
                                                                                ftr_ManagedFirewall__c='N', ftr_NCI__c='02VLN.V',ftr_NPA_NXX__c='972973', ftr_PSR_CIR__c='50 M',
                                                                                ftr_PSR_Jurisdiction__c='2',ftr_PSR_RateCode__c='50 MBPS',ftr_PSR_parentServiceItemId__c='7900724',
                                                                                ftr_RUID1__c='13/L1XN/632873//FTNC/', ftr_RUID2__c='13/L1XN/679511//FTNC/',ftr_SECNCI__c='02VLN.V',
                                                                                ftr_SPEC_GRP_ID__c='1101',ftr_ServiceItemId__c='7900726',ftr_circuitName__c='13/CUXP/046106//FTNC/',
                                                                                ftr_documentNumber__c='3615911', LAN_IP__c='');
        //uni2 for evpl
        
        ftr_Asset_StagingCircuit__c circuit24 = new ftr_Asset_StagingCircuit__c (Pass_Number__c=0,M6_Status__c='In Service', PSR_EVC_Type__c='PSR EVPL - P2P',PSR_SDWAN__c='N',PSR_Virtual_Broadband_Service_Category__c='EVC',
                                                                                PriLocCity__c='DALLAS',PriLocPostalCode__c='75261',PriLocState__c='TX',PriLocStreetAddress__c='2300 E CENTRAL PARK STREET',SecLocCity__c='DALLAS',SecLocPostalCode__c='75207',
                                                                                SecLocState__c='TX',SecLocStreetAddress__c='MSAG 1950 N STEMMONS FREEWAY',Status__c='Pending', ftr_Account_Name__c='AMERICAN AIRLINES', ftr_Circuit_Id__c='10686122',
                                                                                ftr_CompanyIndicator__c='374',ftr_IPAddressType__c='IPv4', ftr_IPBlockSize__c='', ftr_IPTopology__c='',ftr_Item_Alias__c='UNI',ftr_ManagedFirewall__c='N', ftr_NCI__c='02VLN.V',
                                                                                ftr_NPA_NXX__c='972973', ftr_PSR_CIR__c='50 M',ftr_PSR_Jurisdiction__c='2',ftr_PSR_RateCode__c='50 MBPS',ftr_PSR_parentServiceItemId__c='7900724',ftr_RUID1__c='13/L1XN/632873//FTNC/', 
                                                                                ftr_RUID2__c='13/L1XN/679511//FTNC/',ftr_SECNCI__c='02VLN.V',ftr_SPEC_GRP_ID__c='1101',ftr_ServiceItemId__c='7900726',ftr_circuitName__c='13/CUXP/817516//FTNC/',ftr_documentNumber__c='3615911', LAN_IP__c='');
        

        //evpl asset
        ftr_Asset_StagingCircuit__c circuit25 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, CUST_ACCT_NBR__c='783874638', M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - P2P', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
            PriLocPostalCode__c = '75261', PriLocState__c = 'TX', PriLocStreetAddress__c = 'CENTRAL PARK EASTERN STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
            SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '190827345', ftr_Account_Name__c = 'SOUTHWEST AIRLINES',
            ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - P2P',
            ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
            ftr_PSR_RateCode__c = '100 MBPS', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/190827345//FTNC/', ftr_RUID2__c = '13/CUXP/19082748/   /FTNC/',
            ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/190827345/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        circuitList.add(circuit1);
        circuitList.add(circuit2);
        circuitList.add(circuit3);
        circuitList.add(circuit4);
        circuitList.add(circuit5);
        circuitList.add(circuit6);
        circuitList.add(circuit7);
        circuitList.add(circuit8);
        circuitList.add(circuit9);
        circuitList.add(circuit10);
        circuitList.add(circuit11);
        circuitList.add(circuit12);
        circuitList.add(circuit13);
        circuitList.add(circuit14);
        circuitList.add(circuit15);
        circuitList.add(circuit16);
        circuitList.add(circuit17);
        circuitList.add(circuit18);
        circuitList.add(circuit19);
        circuitList.add(circuit20);
        circuitList.add(circuit21);
        circuitList.add(circuit22);
        circuitList.add(circuit23);
        circuitList.add(circuit24);
        circuitList.add(circuit25);
        insert circuitList;
        
        
    }
    
    
    static testMethod void testMACDAssetBatchNewCIDScheduler () {
        Test.startTest();
        String cronExp = '0 0 0 * * ?';
        //Database.executeBatch(new MACDAssetBatchNewCID(), 100);
        MACDAssetBatchNewCIDScheduler cidScheduler = new MACDAssetBatchNewCIDScheduler();
        system.schedule('test', cronExp, cidScheduler);
        //Database.executeBatch(new MACDDpiBatch(), 100);
        Test.stopTest();
    }
    
    static testMethod void testMACDAccountIdCapsUpdateBatchScheduler () {
        Test.startTest();
        String cronExp = '0 0 0 * * ?';
        //Database.executeBatch(new MACDAssetBatchNewCID(), 100);
        MACDAccountIdCapsUpdateBatchScheduler accScheduler = new MACDAccountIdCapsUpdateBatchScheduler();
        system.schedule('test', cronExp, accScheduler);
        Test.stopTest();
    }
}