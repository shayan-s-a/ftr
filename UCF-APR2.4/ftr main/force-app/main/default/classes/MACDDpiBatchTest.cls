@isTest
public class MACDDpiBatchTest {
	@testSetup
    static void setupTestData() {
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
        //acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Master').getRecordTypeId();
        acc.RecordTypeId = masterRecId;
        acc.ParentId = globalAcc.Id;
        acc.M6_Customer_Number__c = '7481290';
        accList.add(acc);
        insert accList;
        //insert service accounts
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
        //insert assets
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_JSONAttribute_Access' LIMIT 1];
        String runtimeJSON = sr.body.toString(); 
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
        
        Product2 pro6 = new Product2();
        pro6.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        pro6.Name = 'Temp Product Dummy';
        pro6.ProductCode = 'ENT_ETH_ABC_001';
        pro6.ftr_IsComboOrderEnabled__c = true;
        pro6.IsActive = true;
        pro6.vlocity_cmt__Scope__c = 'Downstream Order Item';
        pro6.Family = 'Ethernet';
        pro6.vlocity_cmt__JSONAttribute__c = runtimeJSON;
        prodList.add(pro6);
        insert prodList;
        List<ftr_Attribute_Based_SNE__c> sneList = new List<ftr_Attribute_Based_SNE__c >();
        sneList.add(new ftr_Attribute_Based_SNE__c(Product_Code__c = 'ENT_ETH_EVPL_0002', SNE_Code_MRC__c = 'MEDAG', SNE_Code_OTC__c = 'SSINS',SNE_Code_Term__c = 'EIA3Y'));
        sneList.add(new ftr_Attribute_Based_SNE__c(Product_Code__c = 'ENT_ETH_EVPL_0010', SNE_Code_MRC__c = 'MEDAG', SNE_Code_OTC__c = 'SSINS',SNE_Code_Term__c = 'EIA3Y'));
        sneList.add(new ftr_Attribute_Based_SNE__c(Product_Code__c = 'ENT_ETH_IP_0002', SNE_Code_MRC__c = 'MEDAG', SNE_Code_OTC__c = 'SSINS',SNE_Code_Term__c = 'EIA3Y'));
        sneList.add(new ftr_Attribute_Based_SNE__c(Product_Code__c = 'ENT_ETH_MR_001', SNE_Code_MRC__c = 'MEDAG', SNE_Code_OTC__c = 'SSINS',SNE_Code_Term__c = 'EIA3Y'));
        sneList.add(new ftr_Attribute_Based_SNE__c(Product_Code__c = 'ENT_ETH_EIA_0002', SNE_Code_MRC__c = 'MEDAG', SNE_Code_OTC__c = 'SSINS',SNE_Code_Term__c = 'EIA3Y'));
        sneList.add(new ftr_Attribute_Based_SNE__c(Product_Code__c = 'ENT_ETH_UNI_0001', SNE_Code_MRC__c = 'MEDAG', SNE_Code_OTC__c = 'SSINS',SNE_Code_Term__c = 'EIA3Y'));
        //sneList.add(new ftr_Attribute_Based_SNE__c(Product_Code__c = 'ENT_ETH_ABC_001', SNE_Code_MRC__c = 'MEDAG', SNE_Code_OTC__c = 'SSINS',SNE_Code_Term__c = 'EIA3Y'));  
        insert sneList;
        List<Asset> uniAssetList = new List<Asset>();
        uniAssetList.add(new Asset(Name = 'Test Asset 1 UNI', DPI_WTN__c = '190827345', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                               vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[2].Id));
        uniAssetList.add(new Asset(Name = 'Test Asset 2 UNI', DPI_WTN__c = '190827345', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                               vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[2].Id));
        uniAssetList.add(new Asset(Name = 'Test Asset 3 UNI', DPI_WTN__c = '190827345', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                               vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[2].Id));
        insert uniAssetList;
        List<Asset> assetList = new List<Asset>();
        assetList.add(new Asset(Name = 'Test Asset 1', UNI_HOST__c = uniAssetList[0].Id, DPI_WTN__c = '190827345', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                               vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[0].Id));
        assetList.add(new Asset(Name = 'Test Asset 2', UNI_HOST__c = uniAssetList[1].Id, DPI_WTN__c = '190827345', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                               vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[1].Id));
        assetList.add(new Asset(Name = 'Test Asset 3', UNI_HOST__c = uniAssetList[2].Id, DPI_WTN__c = '190827345', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                               vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[2].Id));
        assetList.add(new Asset(Name = 'Test Asset 4', DPI_WTN__c = '190827345', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                               vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[3].Id));
        assetList.add(new Asset(Name = 'Test Asset 5', DPI_WTN__c = '190827345', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                               vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[4].Id));
        assetList.add(new Asset(Name = 'Test Asset 6', DPI_WTN__c = '190827345', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                               vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[5].Id));
        assetList.add(new Asset(Name = 'Test Asset 7', DPI_WTN__c = '190827345', AccountId = accList[0].Id, vlocity_cmt__ServiceAccountId__c = servAcc.Id,
                               vlocity_cmt__JSONAttribute__c = runtimeJSON, Product2Id = prodList[6].Id));
        insert assetList;
        
        //insert accounts
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
        
        dpiList.add(new ftr_Asset_StagingCircuit_DPI__c (BTN__c = '187374374', CODE__c = 'EIA3Y', City_Short_Name__c = 'KGM', Control_Number__c = '72344', DESCRIPTION__c = 'Dedicated DIA 3 Year',
                                                        END_DT__c = '0', ENV__c = 'DT', ITEMRATE__c = 0, START_DT__c = '20201215', Status__c = 'Ready',
                                                        WTN__c = '187374374', Summary_TN__c = '9281888044', GAN__c = '0', Zipcode__c = '86401', City__c = 'KINGMAN', Service_Address__c = '3825 STOCKTON HILL RD',
                                                        State__c  = 'AZ'));
        dpiList.add(new ftr_Asset_StagingCircuit_DPI__c (BTN__c = '187374374', CODE__c = 'MEDAG', City_Short_Name__c = 'KGM', Control_Number__c = '72344', DESCRIPTION__c = '20 Mbps DIA SVC',
                                                        END_DT__c = '0', ENV__c = 'DT', ITEMRATE__c = 350, START_DT__c = '20201215', Status__c = 'Ready',
                                                        WTN__c = '187374374', Summary_TN__c = '9281888044', GAN__c = '0', Zipcode__c = '86401', City__c = 'KINGMAN', Service_Address__c = '3825 STOCKTON HILL RD',
                                                        State__c  = 'AZ'));
        dpiList.add(new ftr_Asset_StagingCircuit_DPI__c (BTN__c = '187374374', CODE__c = 'CKT', City_Short_Name__c = 'KGM', Control_Number__c = '72344', DESCRIPTION__c = 'Circuit Resides in M6',
                                                        END_DT__c = '0', ENV__c = 'DT', ITEMRATE__c = 0, START_DT__c = '20201215', Status__c = 'Ready',
                                                        WTN__c = '187374374', Summary_TN__c = '9281888044', GAN__c = '0', Zipcode__c = '86401', City__c = 'KINGMAN', Service_Address__c = '3825 STOCKTON HILL RD',
                                                        State__c  = 'AZ'));
        dpiList.add(new ftr_Asset_StagingCircuit_DPI__c (BTN__c = '190827345', CODE__c = 'EEVCI', City_Short_Name__c = 'KGM', Control_Number__c = '72344', DESCRIPTION__c = 'Circuit Resides in M6',
                                                        END_DT__c = '0', ENV__c = 'DT', ITEMRATE__c = 0, START_DT__c = '20201215', Status__c = 'Ready',
                                                        WTN__c = '190827345', Summary_TN__c = '9281888044', GAN__c = '0', Zipcode__c = '86401', City__c = 'KINGMAN', Service_Address__c = '3825 STOCKTON HILL RD',
                                                        State__c  = 'AZ'));
        insert dpiList;
    }
    static testMethod void testMACDDpiBatch () {
        Test.startTest();
        String cronExp = '0 0 0 * * ?';
        Database.executeBatch(new MACDDpiBatch(), 100);
        Test.stopTest();
    }
}