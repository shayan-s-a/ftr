@isTest
public class MACDUpdateAssetBatchTest {
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
        
        insert prodList;
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
        acc.RecordTypeId = masterRecId;
        //acc.RecordTypeId = '012E0000000fDc3IAE';
        acc.M6_Customer_Number__c = '7481290';
        acc.ParentId = globalAcc.Id;
        accList.add(acc);
        
        Account acc2 = new Account();
        acc2.Customer_Number__c = '7481291';
        acc2.Name = 'AMERICAN AIRLINES';
        acc.RecordTypeId = masterRecId;
        //acc2.RecordTypeId = '012E0000000fDc3IAE';
        acc2.M6_Customer_Number__c = '7481291';
        acc2.ParentId = globalAcc.Id;
        accList.add(acc2);
        insert accList;
        for (Account accRec : accList) {
            accRec.account_id_caps__c = String.valueOf(accRec.Id).toUpperCase();
        }
        update accList;
        
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
        
        List<Asset> assetList = new List<Asset>();
        Asset asset1 = new Asset(Name = 'Temp Asset 1', vlocity_cmt__JSONAttribute__c = runtimeJSON, AccountId = accList[0].Id,
                                 Product2Id = prodList[0].Id, NPA_NXX__c = '972973');
        
        Asset asset2 = new Asset(Name = 'Temp Asset 2', vlocity_cmt__JSONAttribute__c = runtimeJSON, AccountId = accList[1].Id,
                                 Product2Id = prodList[0].Id, NPA_NXX__c = '972974');
        Map<String, Object> attrValueMap = new Map<String, Object>();
        attrValueMap.put('ATTR_BANDWIDTH', '20 Mbps');
        attrValueMap.put('ATTR_CONTRACT_TERM', '36 Months');
        asset1.vlocity_cmt__JSONAttribute__c = MACDUpdateAssetBatch.setJSONAttributes(asset1.vlocity_cmt__JSONAttribute__c, '{}', attrValueMap);
        asset2.vlocity_cmt__JSONAttribute__c = MACDUpdateAssetBatch.setJSONAttributes(asset1.vlocity_cmt__JSONAttribute__c, '{}', attrValueMap);
        assetList.add(asset1);
        assetList.add(asset2);
        
        insert assetList;
        
        List<Asset> uniAssetList = new List<Asset>();
        uniAssetList.add(new Asset(Name = 'Test Asset 1 UNI', NPA_NXX__c = '977493', DPI_WTN__c = '9721970895', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                                   vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[1].Id));
        insert uniAssetList;
        
        
        List<ftr_Asset_StagingCircuit__c> circuitList = new List<ftr_Asset_StagingCircuit__c>();
        ftr_Asset_StagingCircuit__c circuit1 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, CUST_ACCT_NBR__c = accList[0].Id, M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - EIA', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
                                                                               PriLocPostalCode__c = '75261', PriLocState__c = 'TX', Serviceaddress_DPI__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
                                                                               SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970895', ftr_Account_Name__c = 'AMERICAN AIRLINES',
                                                                               ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - EIA',
                                                                               ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972973', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
                                                                               ftr_PSR_RateCode__c = '20 Mbps', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/686121//FTNC/', ftr_RUID2__c = '1952 /GE10  /DLLSTX979DW/IRNGTXXA38W',
                                                                               ftr_SECNCI__c = '02VLN.V', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/686122/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345',
                                                                               Speed__c = '100 MBPS');
        ftr_Asset_StagingCircuit__c circuit21 = new ftr_Asset_StagingCircuit__c(Pass_Number__c = 0, CUST_ACCT_NBR__c = '12312321', M6_Status__c = 'In Service', PSR_EVC_Type__c = 'PSR EVPL - EIA', PSR_SDWAN__c = 'N', PSR_Virtual_Broadband_Service_Category__c = 'EVC', PriLocCity__c = 'DALLAS',
                                                                                PriLocPostalCode__c = '75261', PriLocState__c = 'TX', Serviceaddress_DPI__c = '2300 E BAKER STREET', SecLocCity__c = 'DALLAS', SecLocPostalCode__c = '75207',
                                                                                SecLocState__c = 'TX', SecLocStreetAddress__c = 'MSAG 1950 N STEMMONS FREEWAY', Status__c = 'Pending', WTN__c = '9721970895', ftr_Account_Name__c = 'AMERICAN AIRLINES',
                                                                                ftr_Circuit_Id__c = '10686122', ftr_CompanyIndicator__c = '374', ftr_IPAddressType__c = 'IPv4', ftr_IPBlockSize__c = '/29', ftr_IPTopology__c = 'FLAT LAN', ftr_Item_Alias__c = 'EVPL - EIA',
                                                                                ftr_ManagedFirewall__c = 'N', ftr_NCI__c = '02VLN.UNT', ftr_NPA_NXX__c = '972974', ftr_PSR_CIR__c = '100 M', ftr_PSR_Jurisdiction__c = '1',
                                                                                ftr_PSR_RateCode__c = '20 Mbps', ftr_PSR_parentServiceItemId__c = '7946168', ftr_RUID1__c = '13/L1XN/123456//FTNC/', ftr_RUID2__c = '1952 /GE10  /DLLSTX979DW/IRNGTXXA38W',
                                                                                ftr_SECNCI__c = '02VLN.V', Speed__c = '100 GBPS', ftr_SPEC_GRP_ID__c = '1102', ftr_ServiceItemId__c = '7946169', ftr_circuitName__c = '13/CUXP/561847/   /FTNC/', ftr_documentNumber__c = '3666667', LAN_IP__c = '12345');
        // UNI for DIA
        
        ftr_Asset_StagingCircuit__c circuit2 = new ftr_Asset_StagingCircuit__c (Pass_Number__c=0,CUST_ACCT_NBR__c=accList[0].Id,M6_Status__c='In Service', PSR_EVC_Type__c='PSR EVPL - P2P',PSR_SDWAN__c='N',PSR_Virtual_Broadband_Service_Category__c='EVC',PriLocCity__c='DALLAS',PriLocPostalCode__c='75261',
                                                                                PriLocState__c='TX',Serviceaddress_DPI__c='2300 E CENTRAL PARK STREET',SecLocCity__c='DALLAS',SecLocPostalCode__c='75207',SecLocState__c='TX',SecLocStreetAddress__c='MSAG 1950 N STEMMONS FREEWAY',Status__c='Pending', WTN__c='9721970802',
                                                                                ftr_Account_Name__c='AMERICAN AIRLINES', ftr_Circuit_Id__c='10686121', ftr_CompanyIndicator__c='374',ftr_IPAddressType__c='IPv4', ftr_IPBlockSize__c='', ftr_IPTopology__c='',ftr_Item_Alias__c='UNI',ftr_ManagedFirewall__c='N',
                                                                                ftr_NCI__c='02VLN.V',Speed__c = '100 G', ftr_NPA_NXX__c='972975', ftr_PSR_CIR__c='50 M',ftr_PSR_Jurisdiction__c='2',ftr_PSR_RateCode__c='20 Mbps',ftr_PSR_parentServiceItemId__c='7900724',ftr_RUID1__c='13/L1XN/632873//FTNC/', ftr_RUID2__c='13/L1XN/679511//FTNC/',
                                                                                ftr_SECNCI__c='02VLN.V',ftr_SPEC_GRP_ID__c='1112',ftr_ServiceItemId__c='7946166',ftr_circuitName__c='13/L1XN/123456//FTNC/',ftr_documentNumber__c='3666662', LAN_IP__c='',Managed_Device__c = 'Y',Managed_Device_Type__c='dummy managed device type');
        
        ftr_Asset_StagingCircuit__c circuitUNI = new ftr_Asset_StagingCircuit__c (Pass_Number__c=0,CUST_ACCT_NBR__c=accList[0].Id,M6_Status__c='In Service', PSR_EVC_Type__c='PSR EVPL - P2P',PSR_SDWAN__c='N',PSR_Virtual_Broadband_Service_Category__c='EVC',PriLocCity__c='DALLAS',PriLocPostalCode__c='75261',
                                                                                PriLocState__c='TX',Serviceaddress_DPI__c='2300 E CENTRAL PARK STREET',SecLocCity__c='DALLAS',SecLocPostalCode__c='75207',SecLocState__c='TX',SecLocStreetAddress__c='MSAG 1950 N STEMMONS FREEWAY',Status__c='Pending', WTN__c='9721970802',
                                                                                ftr_Account_Name__c='AMERICAN AIRLINES', ftr_Circuit_Id__c='10686121', ftr_CompanyIndicator__c='374',ftr_IPAddressType__c='IPv4', ftr_IPBlockSize__c='', ftr_IPTopology__c='',ftr_Item_Alias__c='UNI',ftr_ManagedFirewall__c='N',
                                                                                ftr_NCI__c='02VLN.V',Speed__c = '100 G', ftr_NPA_NXX__c='977493', ftr_PSR_CIR__c='50 M',ftr_PSR_Jurisdiction__c='2',ftr_PSR_RateCode__c='20 Mbps',ftr_PSR_parentServiceItemId__c='7900724',ftr_RUID1__c='13/L1XN/632873//FTNC/', ftr_RUID2__c='13/L1XN/679511//FTNC/',
                                                                                ftr_SECNCI__c='02VLN.V',ftr_SPEC_GRP_ID__c='1112',ftr_ServiceItemId__c='7946166',ftr_circuitName__c='13/L1XN/123456//FTNC/',ftr_documentNumber__c='3666662', LAN_IP__c='',Managed_Device__c = 'Y',Managed_Device_Type__c='dummy managed device type');
        
        circuitList.add(circuit1);
        circuitList.add(circuit21);
        circuitList.add(circuit2);
        circuitList.add(circuitUNI); 
        insert circuitList;
        
        List<ftr_Attribute_Based_SNE__c> sneList = new List<ftr_Attribute_Based_SNE__c >();
        sneList.add(new ftr_Attribute_Based_SNE__c(Product_Code__c = 'ENT_ETH_EIA_0002', Term__c = '36 Months', Speed__c = '20 Mbps', SNE_Code_MRC__c = 'MEDAG', SNE_Code_OTC__c = 'SSINS',SNE_Code_Term__c = 'EIA3Y'));
        insert sneList;
    }
    
    static testMethod void testMACDUpdateAssetBatch () {
        Test.startTest();
        Database.executeBatch(new MACDUpdateAssetBatch(), 100);
        Test.stopTest();
        Asset objAsset = [SELECT Id, Purpose__c FROM Asset LIMIT 1];
        Assert.isTrue(objAsset.Purpose__c != null);
    }
    
    static testMethod void testMACDNPAUpdateAssetBatch () {
        Object npa = '12345';
        Asset objAsset = [SELECT Id, vlocity_cmt__JSONAttribute__c,NPA_NXX__c FROM Asset LIMIT 1];
        objAsset.NPA_NXX__c = null;
        Map<String,Object> attrValueMap = new Map<String, Object> {'ATTR_NPA_NXX' => npa};
            objAsset.vlocity_cmt__JSONAttribute__c = (String) ftr_CpqHelper.setJSONAttributes(objAsset.vlocity_cmt__JSONAttribute__c, '{}', attrValueMap);
        update objAsset;
        Test.startTest();
        Database.executeBatch(new MACDNPAUpdateBatch(), 100);
        Test.stopTest();
        objAsset = [SELECT Id, Purpose__c, NPA_NXX__c FROM Asset WHERE Id =: objAsset.Id LIMIT 1];
        Assert.isTrue(objAsset.NPA_NXX__c == (String)npa);
    }
    
}