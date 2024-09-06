global class MACDAssetDIAIPBatch implements Database.Batchable<sObject>{
    private Set<String> diaCircuitNameSet = new Set<String>();
    //private Map < String, Set < String >> distinctAttributesByApiName = new Map < String, Set < String >> ();
    private List<AssetStagingJSONMapping__c> evplAssetJSONMappings;
    private List<AssetStagingJSONMapping__c> assetJSONMappings;
    private List<AssetStagingJSONMapping__c> uniAssetJSONMappings;
    private Map<Id, ftr_Asset_StagingCircuit__c> assetToCircuitMap;
    //private Map<String, Set<Id>> uniCircuitNameToDiaIdSet;
    private Map<String, ftr_Asset_StagingCircuit__c> uniCNameToCircuitMap;
    private Set<String> uniCircuitNameSet;
    public MACDAssetDIAIPBatch(Set<String> diaCircuitNameSet, Map<Id, ftr_Asset_StagingCircuit__c> assetToCircuitMap, Map<String, ftr_Asset_StagingCircuit__c> uniCNameToCircuitMap) {
        evplAssetJSONMappings = MACDAssetDIAIPBatchHelper.getAssetStagingEVPLAMappings();
        assetJSONMappings = MACDAssetDIAIPBatchHelper.getAssetStagingIPMappings();
        uniAssetJSONMappings = MACDAssetDIAIPBatchHelper.getAssetStagingUNIMappings();
        this.diaCircuitNameSet = diaCircuitNameSet;
        system.debug('circuit name set in new batch ' + diaCircuitNameSet);
        this.assetToCircuitMap = assetToCircuitMap;
        //this.uniCircuitNameToDiaIdSet = uniCircuitNameToDiaIdSet;
        this.uniCNameToCircuitMap = uniCNameToCircuitMap;
        system.debug('assetToCircuitMap in new btach ' + assetToCircuitMap);
        system.debug('uniCNameToCircuitMap in new btach ' + uniCNameToCircuitMap);
        this.uniCircuitNameSet = uniCNameToCircuitMap.keySet();
        system.debug('uniCircuitNameSet in new btach ' + uniCircuitNameSet);
       /* Map < String, Schema.SObjectField > fieldMap = Asset.sObjectType.getDescribe().fields.getMap();
        for (String field: fieldMap.keySet()) {
            if (field.contains('__c')) {
                
            }
            distinctAttributesByApiName.put(field, new Set < String > ());
        }
        distinctAttributesByApiName.put('Product2.Id', new Set < String > ());
        distinctAttributesByApiName.put('Product2.Name', new Set < String > ());
        queryString = 'SELECT ' + String.join((Iterable < String > ) fieldMap.keySet(), ',') + ' FROM Asset WHERE M6_CircuitId__c IN: diaCircuitNameSet OR M6_CircuitId__c IN: uniCircuitNameSet OR id =\'02i79000000SekPAAS\'';*/
    }
    global DataBase.QueryLocator start(Database.BatchableContext BC) {
        system.debug('limits heapszie 1 ' + limits.getHeapSize());
        //String queryString = 'SELECT Id FROM Asset WHERE M6_CircuitId__c IN: diaCircuitNameSet';
		String queryString = 'SELECT id,Quantity,Price,accountid,parentid,rootassetid,product2id,productcode,productfamily,name,vlocity_cmt__action__c,vlocity_cmt__effectiveonetimetotal__c,vlocity_cmt__effectivequantity__c,vlocity_cmt__effectiverecurringtotal__c,vlocity_cmt__jsonattribute__c,vlocity_cmt__linenumber__c,vlocity_cmt__onetimecalculatedprice__c,vlocity_cmt__onetimecharge__c,vlocity_cmt__onetimetotal__c,vlocity_cmt__pricelistid__c,vlocity_cmt__pricebookentryid__c,vlocity_cmt__producthierarchypath__c,vlocity_cmt__provisioningstatus__c,vlocity_cmt__rootitemid__c,vlocity_cmt__serviceaccountid__c,vlocity_cmt__productgroupkey__c,vlocity_cmt__producthierarchygroupkeypath__c,uni_host__c,uni_remote__c,m6_circuitid__c,dpi_wtn__c,m6_serviceitemid__c,Product2.Id,Product2.Name,RUID_1_Originating_CE_VLAN_ID__c,Product2.ProductCode,RUID_2_Terminating_CE_VLAN_ID__c,M6_Document_Number__c,M6_Cust_Acc_Number__c,M6_ParentServiceItemId__c, LAN_IP__c FROM Asset WHERE M6_CircuitId__c IN: diaCircuitNameSet OR M6_CircuitId__c IN: uniCircuitNameSet OR RUID_1_Originating_CE_VLAN_ID__c IN: uniCircuitNameSet OR RUID_2_Terminating_CE_VLAN_ID__c IN: uniCircuitNameSet';        Database.QueryLocator results = DataBase.getQueryLocator(queryString);
        Database.QueryLocatorIterator it = results.iterator();
        system.debug('it has next ' + it.hasNext());
        if (!it.hasNext()) {
            MACDAssetDIAIPBatchHelper.updateUNIToNeedReview(uniCNameToCircuitMap);
        }
        system.debug('limits heapszie 2 ' + limits.getHeapSize());
        return results;
    }

    global void execute(Database.BatchableContext BC, List < Asset > scope) {
        system.debug('batch scoped recods ' + scope);
        Set<Id> assetIds = new Set<Id>();
        //map from dia asset id to ip id if already existing
        Map<Id, Asset> diaToIPAssetMap = new Map<Id,Asset>();
        //to insert IP asset list finally
        List<Asset> ipAssetListInsert = new List<Asset>();
        List<Asset> ipAssetListUpsert = new List<Asset>();
        //map from dia assetId to asset
        Map<id, Asset> diaIdToAssetMap = new Map<Id,Asset>();
        //store IP Product
        //Product2 ipProduct = new Product2();
        //store ipPriceBookEntry
        PriceBookEntry ipPriceBookEntry = new PriceBookEntry();
        PriceBookEntry uniPriceBookEntry = new PriceBookEntry();
        PriceBookEntry evplAPriceBookEntry = new PriceBookEntry();
        PriceBookEntry evplZPriceBookEntry = new PriceBookEntry();
        PriceBookEntry managedRouterPriceBookEntry = new PriceBookEntry();
        //map from diaIdto dia Asset
        Map<Id, Asset> diaToDIAAssetIdMap = new Map<Id, Asset>();
        //circuitName to existing UNI Map
        Map<String, Asset> circNameToUNIMap = new Map<String, Asset>();
        //circuitName to existing DIA Map
        Map<String, Asset> circNameToDIAMap = new Map<String, Asset>();
        //circuitName to existing EVPL ASSET Map
        Map<String, List<Asset>> circNameToEVPLMap = new Map<String, List<Asset>>();
        //circuitName to uni ruid 2 map evpl
        Map<String, List<Asset>> circNameToUNIEVPLMap = new Map<String, List<Asset>>();
        Id priceListId;
        //evpl uni asset service acc track
        Map<String, Set<String>> evplUNIStreetAdd = new Map<String, Set<String>>();
        Map<String, Account> evplUNIToServAccMap = new Map<String, Account>();
        List<Asset> evplAAssetList = new List<Asset>();
        List<Asset> evplAAssetListUpdate = new List<Asset>();
        system.debug('limits heapszie 3 ' + limits.getHeapSize());
        if (!scope.isEmpty()) {
            //ipPriceBookEntry = [SELECT Id,ProductCode,Product2.Id,Product2.Name,Product2.vlocity_cmt__JSONAttribute__c FROM PriceBookEntry WHERE ProductCode = 'ENT_ETH_IP_0002' LIMIT 1];
            Set<String> prodCodeSet = new Set<String>{'ENT_ETH_EVPL_0002','ENT_ETH_UNI_0001','ENT_ETH_IP_0002','ENT_ETH_EVPL_0010','ENT_ETH_MR_001'};
            for (PriceBookEntry entry : [SELECT Id,ProductCode,Product2.Id,Product2.Name,Product2.vlocity_cmt__JSONAttribute__c FROM PriceBookEntry WHERE ProductCode IN: prodCodeSet]) {
                if (entry.ProductCode == 'ENT_ETH_IP_0002') {
                    ipPriceBookEntry = entry;
                } else if (entry.ProductCode == 'ENT_ETH_UNI_0001') {
                    uniPriceBookEntry = entry;
                } else if (entry.ProductCode == 'ENT_ETH_EVPL_0002') {
                    evplAPriceBookEntry = entry;
                } else if (entry.ProductCode == 'ENT_ETH_EVPL_0010') {
                    evplZPriceBookEntry = entry;
                } else if (entry.ProductCode == 'ENT_ETH_MR_001') {
                    managedRouterPriceBookEntry = entry;
                }
            }
            //ipProduct = [SELECT Id, Name, ProductCode, vlocity_cmt__JSONAttribute__c FROM Product2 WHERE ProductCode = 'ENT_ETH_IP_0002' LIMIT 1];
        }
        system.debug('limits heapszie 4 ' + limits.getHeapSize());
        //accountId to circuitName map
        Map<Id, Set<String>> accToCircuitNameMap = new Map<Id, Set<String>>();
        //circuitNameto acc map
        Map<String, Id> cNameToAccMap = new Map<String, Id>();
        Set<Id> diaIds = new Set<Id>();
        Set<String> diaWTNSet = new Set<String>();
        system.debug('limits heapszie 5 ' + limits.getHeapSize());
        for (Asset asset : scope) {
            /*if (diaCircuitNameSet.contains(asset.diaCircuitNameSet)) {
                
            }*/
            if (diaCircuitNameSet.contains(asset.M6_CircuitId__c)) {
                diaIdToAssetMap.put(asset.Id, asset);
                assetIds.add(asset.Id);
            }
            if (uniCircuitNameSet.contains(asset.M6_CircuitId__c)) {
                circNameToUNIMap.put(asset.M6_CircuitId__c,asset);
            }
            if (uniCircuitNameSet.contains(asset.RUID_1_Originating_CE_VLAN_ID__c)) {
                if (asset.Product2.ProductCode == 'ENT_ETH_EIA_0002') {
                    diaIds.add(asset.Id);
                    diaWTNSet.add(asset.DPI_WTN__c);
                    circNameToDIAMap.put(asset.RUID_1_Originating_CE_VLAN_ID__c,asset);
                    if (accToCircuitNameMap.containsKey(asset.AccountId)) {
                        Set<String> cNameSet = accToCircuitNameMap.get(asset.AccountId);
                        cNameSet.add(asset.RUID_1_Originating_CE_VLAN_ID__c);
                        accToCircuitNameMap.put(asset.AccountId, cNameSet);
                    } else {
                        Set<String> cNameSet = new Set<String>{asset.RUID_1_Originating_CE_VLAN_ID__c};
                            accToCircuitNameMap.put(asset.AccountId, cNameSet);
                    }
                    cNameToAccMap.put(asset.RUID_1_Originating_CE_VLAN_ID__c, asset.AccountId);
                    if (evplUNIStreetAdd.containsKey(uniCNameToCircuitMap.get(asset.RUID_1_Originating_CE_VLAN_ID__c).PriLocStreetAddress__c)) {
                        Set<String> cNameSet = evplUNIStreetAdd.get(uniCNameToCircuitMap.get(asset.RUID_1_Originating_CE_VLAN_ID__c).PriLocStreetAddress__c);
                        cNameSet.add(asset.RUID_1_Originating_CE_VLAN_ID__c);
                        evplUNIStreetAdd.put(uniCNameToCircuitMap.get(asset.RUID_1_Originating_CE_VLAN_ID__c).PriLocStreetAddress__c, cNameSet);
                    } else {
                        Set<String> cNameSet = new Set<String>{asset.RUID_1_Originating_CE_VLAN_ID__c};
                        evplUNIStreetAdd.put(uniCNameToCircuitMap.get(asset.RUID_1_Originating_CE_VLAN_ID__c).PriLocStreetAddress__c, cNameSet);
                    }
                } else if (asset.Product2.ProductCode == 'ENT_ETH_EVPL_0010') {
                    //circNameToEVPLMap.put(asset.RUID_1_Originating_CE_VLAN_ID__c,asset);
                    if (circNameToEVPLMap.containsKey(asset.RUID_1_Originating_CE_VLAN_ID__c)) {
                        List<Asset> assetList = circNameToEVPLMap.get(asset.RUID_1_Originating_CE_VLAN_ID__c);
                        assetList.add(asset);
                        circNameToEVPLMap.put(asset.RUID_1_Originating_CE_VLAN_ID__c, assetList);
                    } else {
                        List<Asset> assetList = new List<Asset>{asset};
                        circNameToEVPLMap.put(asset.RUID_1_Originating_CE_VLAN_ID__c, assetList);
                    }
                    if (accToCircuitNameMap.containsKey(asset.AccountId)) {
                        Set<String> cNameSet = accToCircuitNameMap.get(asset.AccountId);
                        cNameSet.add(asset.RUID_1_Originating_CE_VLAN_ID__c);
                        accToCircuitNameMap.put(asset.AccountId, cNameSet);
                    } else {
                        Set<String> cNameSet = new Set<String>{asset.RUID_1_Originating_CE_VLAN_ID__c};
                            accToCircuitNameMap.put(asset.AccountId, cNameSet);
                    }
                    cNameToAccMap.put(asset.RUID_1_Originating_CE_VLAN_ID__c, asset.AccountId);
                    if (evplUNIStreetAdd.containsKey(uniCNameToCircuitMap.get(asset.RUID_1_Originating_CE_VLAN_ID__c).PriLocStreetAddress__c)) {
                        Set<String> cNameSet = evplUNIStreetAdd.get(uniCNameToCircuitMap.get(asset.RUID_1_Originating_CE_VLAN_ID__c).PriLocStreetAddress__c);
                        cNameSet.add(asset.RUID_1_Originating_CE_VLAN_ID__c);
                        evplUNIStreetAdd.put(uniCNameToCircuitMap.get(asset.RUID_1_Originating_CE_VLAN_ID__c).PriLocStreetAddress__c, cNameSet);
                    } else {
                        Set<String> cNameSet = new Set<String>{asset.RUID_1_Originating_CE_VLAN_ID__c};
                        evplUNIStreetAdd.put(uniCNameToCircuitMap.get(asset.RUID_1_Originating_CE_VLAN_ID__c).PriLocStreetAddress__c, cNameSet);
                    }
                    //evplUNIStreetAdd.add(uniCNameToCircuitMap.get(asset.RUID_1_Originating_CE_VLAN_ID__c).PriLocStreetAddress__c);
                }
            }
            if (uniCircuitNameSet.contains(asset.RUID_2_Terminating_CE_VLAN_ID__c)) {
                if (asset.Product2.ProductCode == 'ENT_ETH_EVPL_0010') {
                    //circNameToUNIEVPLMap.put(asset.RUID_2_Terminating_CE_VLAN_ID__c, asset);
                    if (circNameToUNIEVPLMap.containsKey(asset.RUID_2_Terminating_CE_VLAN_ID__c)) {
                        List<Asset> assetList = circNameToUNIEVPLMap.get(asset.RUID_2_Terminating_CE_VLAN_ID__c);
                        assetList.add(asset);
                        circNameToUNIEVPLMap.put(asset.RUID_2_Terminating_CE_VLAN_ID__c, assetList);
                    } else {
                        List<Asset> assetList = new List<Asset>{asset};
                        circNameToUNIEVPLMap.put(asset.RUID_2_Terminating_CE_VLAN_ID__c, assetList);
                    }
                    if (accToCircuitNameMap.containsKey(asset.AccountId)) {
                        Set<String> cNameSet = accToCircuitNameMap.get(asset.AccountId);
                        cNameSet.add(asset.RUID_2_Terminating_CE_VLAN_ID__c);
                        accToCircuitNameMap.put(asset.AccountId, cNameSet);
                    } else {
                        Set<String> cNameSet = new Set<String>{asset.RUID_2_Terminating_CE_VLAN_ID__c};
                            accToCircuitNameMap.put(asset.AccountId, cNameSet);
                    }
                    cNameToAccMap.put(asset.RUID_2_Terminating_CE_VLAN_ID__c, asset.AccountId);
                     if (evplUNIStreetAdd.containsKey(uniCNameToCircuitMap.get(asset.RUID_2_Terminating_CE_VLAN_ID__c).PriLocStreetAddress__c)) {
                        Set<String> cNameSet = evplUNIStreetAdd.get(uniCNameToCircuitMap.get(asset.RUID_2_Terminating_CE_VLAN_ID__c).PriLocStreetAddress__c);
                        cNameSet.add(asset.RUID_2_Terminating_CE_VLAN_ID__c);
                        evplUNIStreetAdd.put(uniCNameToCircuitMap.get(asset.RUID_2_Terminating_CE_VLAN_ID__c).PriLocStreetAddress__c, cNameSet);
                    } else {
                        Set<String> cNameSet = new Set<String>{asset.RUID_2_Terminating_CE_VLAN_ID__c};
                        evplUNIStreetAdd.put(uniCNameToCircuitMap.get(asset.RUID_2_Terminating_CE_VLAN_ID__c).PriLocStreetAddress__c, cNameSet);
                    }
                    //evplUNIStreetAdd.add(uniCNameToCircuitMap.get(asset.RUID_2_Terminating_CE_VLAN_ID__c).PriLocStreetAddress__c);
                }
            }
            /*if (uniCircuitNameToDiaIdSet.containsKey(asset.M6_CircuitId__c)) {
                Set<Id> tempCIdSet = uniCircuitNameToDiaIdSet.get(asset.M6_CircuitId__c);
                for (Id cId : tempCIdSet) {
                    diaToDIAAssetIdMap.put(cId, asset);
                }
            }*/
            
        }
        system.debug('limits heapszie 6 ' + limits.getHeapSize());
        system.debug('evplUNIStreetAdd print ' + evplUNIStreetAdd);
        system.debug('accToCircuitNameMap print ' + accToCircuitNameMap);
        evplUNIToServAccMap = MACDAssetDIAIPBatchHelper.getServiceAccsForStreet(evplUNIStreetAdd, accToCircuitNameMap);
        system.debug('evplUNIToServAccMap print ' + evplUNIToServAccMap);
        system.debug('diaToDIAAssetIdcircNameToUNIMapMap nre batch ' + circNameToUNIMap);
        system.debug('circNameToDIAMap nre batch ' + circNameToDIAMap);
        system.debug('circNameToEVPLMap nre batch ' + circNameToEVPLMap);
        system.debug('circNameToUNIEVPLMap ' + circNameToUNIEVPLMap);
        system.debug('diaIdToAssetMap ' + diaIdToAssetMap);
        system.debug('assetIds ' + assetIds);
        system.debug('cNameToAccMap print ' + cNameToAccMap);
        Map < String, String > sameStreetCNameMap = new Map < String, String > ();
        Map<String, Account> uniCNameToServAccMap = new Map<String, Account>();
        Map<String, String> uniCNameAddressMap = new Map<String, String>();
        Id SerAccId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get('Service').getRecordTypeId();
        system.debug('evplUNIToServAccMap ' + evplUNIToServAccMap);
              for (String uniCName : evplUNIToServAccMap.keySet()) {
            system.debug('evplUNIToServAccMap key ' + uniCName + ' evplUNIToServAccMap value ' + evplUNIToServAccMap.get(uniCName));
        }
        system.debug('uniCNameToCircuitMap ' + uniCNameToCircuitMap);
        for (String uniCName : uniCNameToCircuitMap.keySet()) {
            if (cNameToAccMap.containsKey(uniCName)) {
                if (!evplUNIToServAccMap.containsKey(uniCName)) {
                    if (!sameStreetCNameMap.containsKey(uniCNameToCircuitMap.get(uniCName).PriLocStreetAddress__c)) {
                                Account acc = new Account(RecordTypeId = SerAccId);
                                //acc.Name = 'Service account';
                                acc.Name = uniCNameToCircuitMap.get(uniCName).PriLocStreetAddress__c + ', ' + uniCNameToCircuitMap.get(uniCName).PriLocPostalCode__c;
                                acc.ParentId = cNameToAccMap.get(uniCName);
                                acc.ShippingStreet = uniCNameToCircuitMap.get(uniCName).PriLocStreetAddress__c;
                                acc.ShippingCity = uniCNameToCircuitMap.get(uniCName).PriLocCity__c;
                                acc.BillingCity = uniCNameToCircuitMap.get(uniCName).PriLocCity__c;
                                acc.ShippingStateCode = uniCNameToCircuitMap.get(uniCName).PriLocState__c;
                                acc.ShippingPostalCode = uniCNameToCircuitMap.get(uniCName).PriLocPostalCode__c;
                                acc.BillingPostalCode = uniCNameToCircuitMap.get(uniCName).PriLocPostalCode__c;
                                acc.BillingStreet = uniCNameToCircuitMap.get(uniCName).PriLocStreetAddress__c;
                                acc.BillingStateCode = uniCNameToCircuitMap.get(uniCName).PriLocState__c;
                        acc.Source__c = Label.Service_Account_Created_From_MACD_Asset_Batch;
                        system.debug('acc.ParentId ' + acc.ParentId);
                        uniCNameToServAccMap.put(uniCName,acc);
                        sameStreetCNameMap.put(uniCNameToCircuitMap.get(uniCName).PriLocStreetAddress__c, uniCName);
                    } else if (sameStreetCNameMap.containsKey(uniCNameToCircuitMap.get(uniCName).PriLocStreetAddress__c)) {
                                uniCNameAddressMap.put(uniCName, sameStreetCNameMap.get(uniCNameToCircuitMap.get(uniCName).PriLocStreetAddress__c));
                     }
                } else {
                    uniCNameToServAccMap.put(uniCName, evplUNIToServAccMap.get(uniCName));
                }
            }
        }
        system.debug('limits heapszie 6 ' + limits.getHeapSize());
        system.debug('uniCNameToServAccMap print ' + uniCNameToServAccMap);
        for (String uniCName : uniCNameToServAccMap.keySet()) {
            system.debug('uniCNameToServAccMap key ' + uniCName + ' uniCNameToServAccMap value ' + uniCNameToServAccMap.get(uniCName));
        }
        Set<Account> newAccs = new Set<Account>(uniCNameToServAccMap.values());
        List<Account> serAccList = new List<Account>(newAccs);
        upsert serAccList;
        system.debug('limits heapszie 7 ' + limits.getHeapSize());
        //map from dia asset id to managed router id
        Map<Id, Asset> diaToManagedRouterMap = new Map<Id, Asset>();
        //query for IP assets for DIA Assets
        system.debug('diaIds ' + diaIds);
        system.debug('diaWTNSet ' + diaWTNSet);
        for (Asset asset : [SELECT Id,vlocity_cmt__RootItemId__c, Product2.ProductCode, M6_CircuitId__c, DPI_WTN__c, vlocity_cmt__JSONAttribute__c, M6_ServiceItemId__c, M6_ParentServiceItemId__c, M6_Document_Number__c, M6_Cust_Acc_Number__c FROM Asset WHERE (vlocity_cmt__RootItemId__c IN: assetIds AND Product2.ProductCode = 'ENT_ETH_IP_0002')
                           OR ((vlocity_cmt__RootItemId__c IN: diaIds OR DPI_WTN__c IN: diaWTNSet) AND Product2.ProductCode = 'ENT_ETH_MR_001')]) {
            if ((diaIds.contains(asset.vlocity_cmt__RootItemId__c) || diaWTNSet.contains(asset.DPI_WTN__C)) && asset.Product2.ProductCode == 'ENT_ETH_MR_001') {
                diaToManagedRouterMap.put(asset.vlocity_cmt__RootItemId__c, asset);
            } if (!assetIds.contains(asset.Id) && asset.Product2.ProductCode == 'ENT_ETH_IP_0002') {
                diaToIPAssetMap.put(asset.vlocity_cmt__RootItemId__c,asset);
            } 
            
        }
        system.debug('diaToManagedRouterMap ' + diaToManagedRouterMap);
        system.debug('diaToIPAssetMap ' + diaToIPAssetMap);
        priceListId = MACDAssetBatchNewCIDHelper.getPriceListId();
        List<ftr_Asset_StagingCircuit__c> updateList = new List<ftr_Asset_StagingCircuit__c>();
        system.debug('limits heapszie 9 ' + limits.getHeapSize());
        system.debug('assetids check ' + assetIds);
        //FOR ip aSSETS
        for (Id diaId : assetIds) {
            Asset s;
            //if IP asset already present, for DIA asset
            if (diaToIPAssetMap.containsKey(diaId)) {
                system.debug('went into existing');
                s = new Asset(Id = diaToIPAssetMap.get(diaId).Id, vlocity_cmt__JSONAttribute__c = diaToIPAssetMap.get(diaId).vlocity_cmt__JSONAttribute__c);
            } else if (!diaToIPAssetMap.containsKey(diaId)) {
                system.debug('went into existing');
                s = new Asset(vlocity_cmt__JSONAttribute__c = ipPriceBookEntry.Product2.vlocity_cmt__JSONAttribute__c);
            }
            s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
            s.vlocity_cmt__RootItemId__c = diaId;
                s.vlocity_cmt__ServiceAccountId__c = diaIdToAssetMap.get(diaId).vlocity_cmt__ServiceAccountId__c;
                s.AccountId = diaIdToAssetMap.get(diaId).AccountId;
                //s.Name = diaIdToAssetMap.get(diaId).Product2.Name;
                s.Name = 'IP';
                s.vlocity_cmt__LineNumber__c = diaIdToAssetMap.get(diaId).vlocity_cmt__LineNumber__c + '.' + '0001';
                //s.Product2Id =  diaIdToAssetMap.get(diaId).Product2Id;
                s.Product2Id = ipPriceBookEntry.Product2.Id;
                //s.vlocity_cmt__PricebookEntryId__c  = diaIdToAssetMap.get(diaId).vlocity_cmt__PricebookEntryId__c;
                s.vlocity_cmt__PricebookEntryId__c  = ipPriceBookEntry.Id;
                s.vlocity_cmt__JSONAttribute__c = MACDAssetDIAIPBatchHelper.getJSONAttribute(s.vlocity_cmt__JSONAttribute__c, assetToCircuitMap.get(diaId) , assetJSONMappings);
                //s.vlocity_cmt__JSONAttribute__c = diaIdToAssetMap.get(diaId).vlocity_cmt__LineNumber__c;
                system.debug('json attribute value reutnred in new btach ' + s.vlocity_cmt__JSONAttribute__c);
                s.vlocity_cmt__PriceListId__c  = diaIdToAssetMap.get(diaId).vlocity_cmt__PriceListId__c;
                s.vlocity_cmt__Action__c  = diaIdToAssetMap.get(diaId).vlocity_cmt__Action__c;
                s.vlocity_cmt__EffectiveOneTimeTotal__c  = diaIdToAssetMap.get(diaId).vlocity_cmt__EffectiveOneTimeTotal__c;
                s.vlocity_cmt__EffectiveQuantity__c  = diaIdToAssetMap.get(diaId).vlocity_cmt__EffectiveQuantity__c;
                s.Quantity  = diaIdToAssetMap.get(diaId).Quantity;
                s.vlocity_cmt__EffectiveRecurringTotal__c  = diaIdToAssetMap.get(diaId).vlocity_cmt__EffectiveRecurringTotal__c;
                s.vlocity_cmt__OneTimeCalculatedPrice__c  = diaIdToAssetMap.get(diaId).vlocity_cmt__OneTimeCalculatedPrice__c;
                s.vlocity_cmt__OneTimeCharge__c  = diaIdToAssetMap.get(diaId).vlocity_cmt__OneTimeCharge__c;
                s.vlocity_cmt__OneTimeTotal__c  = diaIdToAssetMap.get(diaId).vlocity_cmt__OneTimeTotal__c;
				s.vlocity_cmt__ProvisioningStatus__c  = diaIdToAssetMap.get(diaId).vlocity_cmt__ProvisioningStatus__c;
                s.Price  = diaIdToAssetMap.get(diaId).Price;
                s.M6_ServiceItemId__c  = diaIdToAssetMap.get(diaId).M6_ServiceItemId__c; 
            s.M6_ParentServiceItemId__c  = diaIdToAssetMap.get(diaId).M6_ParentServiceItemId__c; 
            	s.M6_Document_Number__c = diaIdToAssetMap.get(diaId).M6_Document_Number__c; 
				s.LAN_IP__c = diaIdToAssetMap.get(diaId).LAN_IP__c; 
            s.M6_Cust_Acc_Number__c = diaIdToAssetMap.get(diaId).M6_Cust_Acc_Number__c; 
                //s.M6_CircuitId__c  = diaIdToAssetMap.get(diaId).M6_CircuitId__c;  
             s.DPI_WTN__c  = diaIdToAssetMap.get(diaId).DPI_WTN__c; 
                ipAssetListInsert.add(s);
        }
        system.debug('limits heapszie 10 ' + limits.getHeapSize());
        system.debug('ipAssetListInsert after dia added ' + ipAssetListInsert);
        //List<Asset> uniAssetListUpsert = new List<Asset>();
        //upsert uni assets
        for (String uniCName : uniCircuitNameSet) {
            Asset s = new Asset(vlocity_cmt__JSONAttribute__c = uniPriceBookEntry.Product2.vlocity_cmt__JSONAttribute__c, Source__c = Label.Asset_Created_From_MACD_Asset_Batch);
            if (circNameToUNIMap.containsKey(uniCName)) {
                s.Id = circNameToUNIMap.get(uniCName).Id;
                s.vlocity_cmt__JSONAttribute__c = circNameToUNIMap.get(uniCName).vlocity_cmt__JSONAttribute__c;
            }
            if (circNameToDIAMap.containsKey(uniCName)) {
                if (uniCNameAddressMap.containsKey(uniCName)) {
                    String cName = uniCNameAddressMap.get(uniCName);
                    s.vlocity_cmt__ServiceAccountId__c = uniCNameToServAccMap.containsKey(cName) ? uniCNameToServAccMap.get(CName).Id : '';
                } else {
                    s.vlocity_cmt__ServiceAccountId__c = uniCNameToServAccMap.containsKey(uniCName) ? uniCNameToServAccMap.get(uniCName).Id : '';
                }
                s.AccountId = circNameToDIAMap.get(uniCName).AccountId;
                s.Name  = uniPriceBookEntry.Product2.name;
                s.vlocity_cmt__LineNumber__c =  uniCNameToCircuitMap.get(uniCName).Name.substringAfter('-');
                s.Product2Id = uniPriceBookEntry.Product2.Id;
                //s.vlocity_cmt__PricebookEntryId__c  = diaToDIAAssetIdMap.get(diaId).vlocity_cmt__PricebookEntryId__c;
                s.vlocity_cmt__PricebookEntryId__c  = uniPriceBookEntry.Id;
                //s.vlocity_cmt__JSONAttribute__c = uniPriceBookEntry.Product2.vlocity_cmt__JSONAttribute__c;
                s.vlocity_cmt__JSONAttribute__c = MACDAssetDIAIPBatchHelper.getJSONAttributeUNI(s.vlocity_cmt__JSONAttribute__c, uniCNameToCircuitMap.get(uniCName), uniAssetJSONMappings);
                s.vlocity_cmt__PriceListId__c = priceListId;
                s.vlocity_cmt__Action__c = 'Add';
                s.vlocity_cmt__EffectiveOneTimeTotal__c = 0;
                s.vlocity_cmt__EffectiveQuantity__c = 1;
                s.Quantity = 1;
                s.vlocity_cmt__EffectiveRecurringTotal__c = 0;
                s.vlocity_cmt__OneTimeCalculatedPrice__c = 0;
                s.vlocity_cmt__OneTimeCharge__c = 0;
                s.vlocity_cmt__OneTimeTotal__c = 0;
                s.vlocity_cmt__ProvisioningStatus__c = 'Active';
                s.Price = 0;
                s.M6_ServiceItemId__c = circNameToDIAMap.get(uniCName).M6_ServiceItemId__c;
                s.M6_ParentServiceItemId__c = circNameToDIAMap.get(uniCName).M6_ParentServiceItemId__c;
                s.M6_CircuitId__c = uniCName;
                s.M6_Document_Number__c = uniCNameToCircuitMap.get(uniCName).ftr_documentNumber__c;
				s.LAN_IP__c = uniCNameToCircuitMap.get(uniCName).LAN_IP__c;
                s.M6_Cust_Acc_Number__c = uniCNameToCircuitMap.get(uniCName).CUST_ACCT_NBR__c;
                s.DPI_WTN__c = uniCNameToCircuitMap.get(uniCName).WTN__c;
                circNameToUNIMap.put(uniCName, s);
            }
            else if (circNameToEVPLMap.containsKey(uniCName)) {
                if (uniCNameAddressMap.containsKey(uniCName)) {
                    String cName = uniCNameAddressMap.get(uniCName);
                    s.vlocity_cmt__ServiceAccountId__c = uniCNameToServAccMap.containsKey(cName) ? uniCNameToServAccMap.get(CName).Id : '';
                } else {
                    s.vlocity_cmt__ServiceAccountId__c = uniCNameToServAccMap.containsKey(uniCName) ? uniCNameToServAccMap.get(uniCName).Id : '';
                }
                //s.vlocity_cmt__ServiceAccountId__c = circNameToEVPLMap.get(uniCName).vlocity_cmt__ServiceAccountId__c;
                s.AccountId = circNameToEVPLMap.get(uniCName)[0].AccountId;
                s.Name  = uniPriceBookEntry.Product2.name;
                s.vlocity_cmt__LineNumber__c =  uniCNameToCircuitMap.get(uniCName).Name.substringAfter('-');
                s.Product2Id = uniPriceBookEntry.Product2.Id;
                //s.vlocity_cmt__PricebookEntryId__c  = diaToDIAAssetIdMap.get(diaId).vlocity_cmt__PricebookEntryId__c;
                s.vlocity_cmt__PricebookEntryId__c  = uniPriceBookEntry.Id;
                //s.vlocity_cmt__JSONAttribute__c = uniPriceBookEntry.Product2.vlocity_cmt__JSONAttribute__c;
                s.vlocity_cmt__JSONAttribute__c = MACDAssetDIAIPBatchHelper.getJSONAttributeUNI(s.vlocity_cmt__JSONAttribute__c, uniCNameToCircuitMap.get(uniCName), uniAssetJSONMappings);
                s.vlocity_cmt__PriceListId__c = priceListId;
                s.vlocity_cmt__Action__c = 'Add';
                s.vlocity_cmt__EffectiveOneTimeTotal__c = 0;
                s.vlocity_cmt__EffectiveQuantity__c = 1;
                s.Quantity = 1;
                s.vlocity_cmt__EffectiveRecurringTotal__c = 0;
                s.vlocity_cmt__OneTimeCalculatedPrice__c = 0;
                s.vlocity_cmt__OneTimeCharge__c = 0;
                s.vlocity_cmt__OneTimeTotal__c = 0;
                s.vlocity_cmt__ProvisioningStatus__c = 'Active';
                s.Price = 0;
                s.M6_ServiceItemId__c = circNameToEVPLMap.get(uniCName)[0].M6_ServiceItemId__c;
                s.M6_ParentServiceItemId__c = circNameToEVPLMap.get(uniCName)[0].M6_ParentServiceItemId__c;
                s.M6_CircuitId__c = uniCName;
                s.M6_Document_Number__c = uniCNameToCircuitMap.get(uniCName).ftr_documentNumber__c;
				s.LAN_IP__c = uniCNameToCircuitMap.get(uniCName).LAN_IP__c;
                s.M6_Cust_Acc_Number__c = uniCNameToCircuitMap.get(uniCName).CUST_ACCT_NBR__c;
                s.DPI_WTN__c = uniCNameToCircuitMap.get(uniCName).WTN__c;
                circNameToUNIMap.put(uniCName, s);
            }
            else if (circNameToUNIEVPLMap.containsKey(uniCName)) {
                if (uniCNameAddressMap.containsKey(uniCName)) {
                    String cName = uniCNameAddressMap.get(uniCName);
                    s.vlocity_cmt__ServiceAccountId__c = uniCNameToServAccMap.containsKey(cName) ? uniCNameToServAccMap.get(CName).Id : '';
                } else {
                    s.vlocity_cmt__ServiceAccountId__c = uniCNameToServAccMap.containsKey(uniCName) ? uniCNameToServAccMap.get(uniCName).Id : '';
                }
                //s.vlocity_cmt__ServiceAccountId__c = circNameToUNIEVPLMap.get(uniCName).vlocity_cmt__ServiceAccountId__c;
                s.AccountId = circNameToUNIEVPLMap.get(uniCName)[0].AccountId;
                s.Name  = uniPriceBookEntry.Product2.name;
                s.vlocity_cmt__LineNumber__c =  uniCNameToCircuitMap.get(uniCName).Name.substringAfter('-');
                s.Product2Id = uniPriceBookEntry.Product2.Id;
                //s.vlocity_cmt__PricebookEntryId__c  = diaToDIAAssetIdMap.get(diaId).vlocity_cmt__PricebookEntryId__c;
                s.vlocity_cmt__PricebookEntryId__c  = uniPriceBookEntry.Id;
                //s.vlocity_cmt__JSONAttribute__c = uniPriceBookEntry.Product2.vlocity_cmt__JSONAttribute__c;
                s.vlocity_cmt__JSONAttribute__c = MACDAssetDIAIPBatchHelper.getJSONAttributeUNI(s.vlocity_cmt__JSONAttribute__c, uniCNameToCircuitMap.get(uniCName), uniAssetJSONMappings);
                s.vlocity_cmt__PriceListId__c = priceListId;
                s.vlocity_cmt__Action__c = 'Add';
                s.vlocity_cmt__EffectiveOneTimeTotal__c = 0;
                s.vlocity_cmt__EffectiveQuantity__c = 1;
                s.Quantity = 1;
                s.vlocity_cmt__EffectiveRecurringTotal__c = 0;
                s.vlocity_cmt__OneTimeCalculatedPrice__c = 0;
                s.vlocity_cmt__OneTimeCharge__c = 0;
                s.vlocity_cmt__OneTimeTotal__c = 0;
                s.vlocity_cmt__ProvisioningStatus__c = 'Active';
                s.Price = 0;
                s.M6_ServiceItemId__c = circNameToUNIEVPLMap.get(uniCName)[0].M6_ServiceItemId__c;
                s.M6_ParentServiceItemId__c = circNameToUNIEVPLMap.get(uniCName)[0].M6_ParentServiceItemId__c;
                s.M6_CircuitId__c = uniCName;
                s.M6_Document_Number__c = uniCNameToCircuitMap.get(uniCName).ftr_documentNumber__c;
				s.LAN_IP__c = uniCNameToCircuitMap.get(uniCName).LAN_IP__c;
                s.M6_Cust_Acc_Number__c = uniCNameToCircuitMap.get(uniCName).CUST_ACCT_NBR__c;
                s.DPI_WTN__c = uniCNameToCircuitMap.get(uniCName).WTN__c;
                circNameToUNIMap.put(uniCName, s);
            }
            else {
                ftr_Asset_StagingCircuit__c circuitRec = new ftr_Asset_StagingCircuit__c(Id = uniCNameToCircuitMap.get(uniCName).Id,  Status__c = 'Needs Review', Error_Message__c = 'No DIA/EVPL Asset for UNI Found', Pass_Number__c = uniCNameToCircuitMap.get(uniCName).Pass_Number__c + 1);
                if (String.isNotBlank(uniCNameToCircuitMap.get(uniCName).WTN__c)) {
                    if (uniCNameToCircuitMap.get(uniCName).WTN__c.length() != 10) {
                    	circuitRec.Notes__c = 'WTN length should be exact 10';
                	}
                }
                system.debug('update list added ' + circuitRec);
                updateList.add(circuitRec);
                if (circNameToUNIMap.containsKey(uniCNameToCircuitMap.get(uniCName).ftr_circuitname__c)) {
                    circNameToUNIMap.remove(uniCNameToCircuitMap.get(uniCName).ftr_circuitname__c);
                }
            }
        }
        system.debug('limits heapszie 11 ' + limits.getHeapSize());
        system.debug('uniCNameToCircuitMap ' + uniCNameToCircuitMap);
        system.debug('ipAssetListInsert ' + ipAssetListInsert);
        system.debug('circNameToUNIMap ' + circNameToUNIMap);
        if (!ipAssetListInsert.isEmpty()) {
            upsert ipAssetListInsert;
            for (Asset ipAsset : [SELECT Id, vlocity_cmt__RootItemId__c, vlocity_cmt__ProductGroupKey__c, Product2.Id FROM Asset WHERE Id IN: ipAssetListInsert]) {
                Asset s = new Asset(Id = ipAsset.Id);
                s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                s.vlocity_cmt__ProductHierarchyPath__c = diaIdToAssetMap.get(ipAsset.vlocity_cmt__RootItemId__c).Product2.Id + '<' + ipPriceBookEntry.Product2.Id;
                s.vlocity_cmt__ProductHierarchyGroupKeyPath__c = diaIdToAssetMap.get(ipAsset.vlocity_cmt__RootItemId__c).vlocity_cmt__ProductGroupKey__c + '<' + ipAsset.vlocity_cmt__ProductGroupKey__c;
                ipAssetListUpsert.add(s);
            }
        }
        //map from circuitName to inserted uni map
        Map<String, Asset> circNameToUNIForEVPL = new Map<String, Asset>();
        Map<String, Asset> circNameToUNIForEVPLUpdate = new Map<String, Asset>();
        Map<String, Asset> managedRouterToCreate = new Map<String, Asset>();
        //map for evpl asset updates
            Map<Id, Asset> evplAssetUpdateMap = new Map<Id, Asset>();
        if (!circNameToUNIMap.isEmpty()) {
            Schema.SObjectField extField = Asset.fields.M6_CircuitId__c;
            Database.upsertResult[] upsertResult = Database.upsert(circNameToUNIMap.values(), extField, false);
            system.debug('upsertRes check for inserting uni assets ' + upsertResult);
            Set<String> successUNICName = new Set<String>();
            Set<String> failedUNICName = new Set<String>();
            for (Integer i=0;i<upsertResult.size();i++) {
            	String circuitName = circNameToUNIMap.values()[i].M6_CircuitId__c;
                String cId = uniCNameToCircuitMap.get(circuitName).Id;
                if (upsertResult[i].isSuccess()) {
                    if(circNameToEVPLMap.containsKey(circuitName)) {
                        circNameToUNIForEVPL.put(circuitName, circNameToUNIMap.values()[i]);
                    }
                    if (circNameToUNIEVPLMap.containsKey(circuitName)) {
                        circNameToUNIForEVPLUpdate.put(circuitName, circNameToUNIMap.values()[i]);
                    }
                    //if uni for dia, add for managed router creation
                    if (circNameToDIAMap.containsKey(circuitName) && uniCNameToCircuitMap.get(circuitName).Managed_Device__c == 'Y') {
                        managedRouterToCreate.put(circuitName, circNameToUNIMap.values()[i]);
                    }
                    ftr_Asset_StagingCircuit__c circuitRec = new ftr_Asset_StagingCircuit__c(Id = cId, Status__c = 'Complete', Error_Message__c = '', Pass_Number__c = uniCNameToCircuitMap.get(circuitName).Pass_Number__c + 1);
                    if (String.isNotBlank(uniCNameToCircuitMap.get(circuitName).WTN__c)) {
                        if (uniCNameToCircuitMap.get(circuitName).WTN__c.length() != 10) {
                    		circuitRec.Notes__c = 'WTN length should be exact 10';
                		}
                    }
                    
                    system.debug('updated list added ' + circuitRec);
                    updateList.add(circuitRec);
                    successUNICName.add(circuitName);
                } else if (!upsertResult[i].isSuccess()) {
                    ftr_Asset_StagingCircuit__c circuitRec = new ftr_Asset_StagingCircuit__c(Id = cId, Status__c = 'Needs Review', Error_Message__c = 'Asset failed to insert/update', Pass_Number__c = uniCNameToCircuitMap.get(circuitName).Pass_Number__c + 1);
                    if (String.isNotBlank(uniCNameToCircuitMap.get(circuitName).WTN__c)) {
                        if (uniCNameToCircuitMap.get(circuitName).WTN__c.length() != 10) {
                    		circuitRec.Notes__c = 'WTN length should be exact 10';
                		}
                    }
                    system.debug('updated list added ' + circuitRec);
                    updateList.add(circuitRec);
                }
        	}
            
            system.debug('circNameToDIAMap after insert ' + circNameToDIAMap.values());
            system.debug('circNameToUNIForEVPL check ' + circNameToUNIForEVPL);
            system.debug('circNameToUNIForEVPLUpdate chdeck ' + circNameToUNIForEVPLUpdate);
            Map<Id, String> evplZToLineNoMap = new Map<Id, String>();
            Map<Id,List<Asset>> uniToEvplZMap = new Map<Id,List<Asset>>();
            Map<Id, Asset> evplAExistingMap = new Map<Id, Asset>();
            for (Asset asset : [SELECT Id,UNI_Host__c, DPI_WTN__c,vlocity_cmt__ServiceAccountId__c, M6_ParentServiceItemId__c, AccountId,Name,vlocity_cmt__LineNumber__c,Product2Id,vlocity_cmt__PricebookEntryId__c ,vlocity_cmt__JSONAttribute__c,vlocity_cmt__PriceListId__c,vlocity_cmt__Action__c,vlocity_cmt__EffectiveOneTimeTotal__c,vlocity_cmt__EffectiveQuantity__c,Quantity,vlocity_cmt__EffectiveRecurringTotal__c,vlocity_cmt__OneTimeCalculatedPrice__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__ProvisioningStatus__c,Price,M6_ServiceItemId__c FROM Asset WHERE UNI_Host__c IN:circNameToUNIForEVPLUpdate.values()]) {
                evplAExistingMap.put(asset.UNI_Host__c, asset);
            }
            for (String uniCName : circNameToUNIForEVPLUpdate.keySet()) {
                Asset s;
                if (evplAExistingMap.containsKey(circNameToUNIForEVPLUpdate.get(uniCName).Id)) {
                    s = evplAExistingMap.get(circNameToUNIForEVPLUpdate.get(uniCName).Id);
                } else {
                    s = new Asset(vlocity_cmt__JSONAttribute__c = evplAPriceBookEntry.Product2.vlocity_cmt__JSONAttribute__c, Source__c = Label.Asset_Created_From_MACD_Asset_Batch);
                }
                s.vlocity_cmt__ServiceAccountId__c = circNameToUNIForEVPLUpdate.get(uniCName).vlocity_cmt__ServiceAccountId__c;
                s.AccountId = circNameToUNIForEVPLUpdate.get(uniCName).AccountId;
                s.Name  = evplAPriceBookEntry.Product2.name;
                //s.vlocity_cmt__LineNumber__c =  uniCNameToCircuitMap.get(uniCName).Name.substringAfter('-');
                s.vlocity_cmt__LineNumber__c = String.valueOf(Math.abs(Crypto.getRandomLong())).subString(0, 8);
                system.debug('evpl a line number random ' + s.vlocity_cmt__LineNumber__c);
                s.Product2Id = evplAPriceBookEntry.Product2.Id;
                //s.vlocity_cmt__PricebookEntryId__c  = diaToDIAAssetIdMap.get(diaId).vlocity_cmt__PricebookEntryId__c;
                s.vlocity_cmt__PricebookEntryId__c  = evplAPriceBookEntry.Id;
                //s.vlocity_cmt__JSONAttribute__c = evplAPriceBookEntry.Product2.vlocity_cmt__JSONAttribute__c;
                s.vlocity_cmt__JSONAttribute__c = MACDAssetDIAIPBatchHelper.getJSONAttributeUNI(s.vlocity_cmt__JSONAttribute__c, uniCNameToCircuitMap.get(uniCName), evplAssetJSONMappings);
                //s.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(s.vlocity_cmt__JSONAttribute__c,'','CircuitId',null);
                //s.vlocity_cmt__JSONAttribute__c = circNameToUNIForEVPL.get(uniCName).vlocity_cmt__JSONAttribute__c;
                s.vlocity_cmt__PriceListId__c = priceListId;
                s.vlocity_cmt__Action__c = 'Add';
                s.vlocity_cmt__EffectiveOneTimeTotal__c = 0;
                s.vlocity_cmt__EffectiveQuantity__c = 1;
                s.Quantity = 1;
                s.vlocity_cmt__EffectiveRecurringTotal__c = 0;
                s.vlocity_cmt__OneTimeCalculatedPrice__c = 0;
                s.vlocity_cmt__OneTimeCharge__c = 0;
                s.vlocity_cmt__OneTimeTotal__c = 0;
                s.vlocity_cmt__ProvisioningStatus__c = 'Active';
                s.Price = 0;
                s.M6_ServiceItemId__c = circNameToUNIForEVPLUpdate.get(uniCName).M6_ServiceItemId__c;
                s.M6_ParentServiceItemId__c = circNameToUNIForEVPLUpdate.get(uniCName).M6_ParentServiceItemId__c;
                s.UNI_Host__c = circNameToUNIForEVPLUpdate.get(uniCName).Id;
                s.M6_Document_Number__c = circNameToUNIForEVPLUpdate.get(uniCName).M6_Document_Number__c;
				s.LAN_IP__c = circNameToUNIForEVPLUpdate.get(uniCName).LAN_IP__c;
                s.DPI_WTN__c = circNameToUNIForEVPLUpdate.get(uniCName).DPI_WTN__c;
                s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                uniToEvplZMap.put(s.UNI_Host__c, circNameToUNIEVPLMap.get(uniCName));
                //populate evpl z asset to line number update map
                for (Asset a : circNameToUNIEVPLMap.get(uniCName)) {
                    evplZToLineNoMap.put(a.Id, s.vlocity_cmt__LineNumber__c);
                }
                //s.M6_CircuitId__c = uniCName;
                evplAAssetList.add(s);
            }
            
            if (!evplAAssetList.isEmpty()) {
                upsert evplAAssetList;
                for (Asset asset : [SELECT id,UNI_Host__c, vlocity_cmt__ProductGroupKey__c,Product2.Id FROM  Asset WHERE Id IN: evplAAssetList]) {
                    if (uniToEvplZMap.containsKey(asset.UNI_Host__c)) {
                        for (Asset a : uniToEvplZMap.get(asset.UNI_Host__c)) {
                            Asset s = new Asset(Id = a.Id);
                            s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                            s.vlocity_cmt__ProductHierarchyGroupKeyPath__c = asset.vlocity_cmt__ProductGroupKey__c + '<' + a.vlocity_cmt__ProductGroupKey__c;
                            s.vlocity_cmt__ProductHierarchyPath__c = asset.Product2.Id + '<' + evplZPriceBookEntry.Product2.Id;
                            s.vlocity_cmt__RootItemId__c = asset.Id;
                            evplAssetUpdateMap.put(s.Id, s);
                        }
                    }
                    asset.vlocity_cmt__ProductHierarchyGroupKeyPath__c = asset.vlocity_cmt__ProductGroupKey__c;
                    asset.vlocity_cmt__ProductHierarchyPath__c = asset.Product2.Id;
                    evplAAssetListUpdate.add(asset);
                }
            }
            for (String uniCName : circNameToUNIForEVPL.keySet()) {
                system.debug('came into circNameToUNIForEVPL keySet()');
                Asset s;
                for (Asset evpl : circNameToEVPLMap.get(uniCName)) {
                    if (evplAssetUpdateMap.containsKey(evpl.Id)) {
                        s = evplAssetUpdateMap.get(evpl.Id);
                        if (circNameToUNIForEVPL.containsKey(uniCName)) {
                            s.UNI_Remote__c = circNameToUNIForEVPL.get(uniCName).Id;
                            s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                        }
                    } else {
                        s = new Asset(Id = evpl.Id);
                        if (circNameToEVPLMap.containsKey(uniCName)) {
                            s.UNI_Remote__c = circNameToUNIForEVPL.get(uniCName).Id;
                            s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                        }
                        evplAssetUpdateMap.put(s.Id, s);
                	}
                }
            }
            for (String uniCName : circNameToUNIForEVPLUpdate.keySet()) {
                system.debug('came into circNameToUNIForEVPLUpdate keySet()');
                Asset s;
                for (Asset evpl : circNameToUNIEVPLMap.get(uniCName)) {
                    if (evplAssetUpdateMap.containsKey(evpl.Id)) {
                        s = evplAssetUpdateMap.get(evpl.Id);
                        if (circNameToUNIForEVPLUpdate.containsKey(uniCName)) {
                            s.UNI_Host__c = circNameToUNIForEVPLUpdate.get(uniCName).Id;
                            s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                        }
                    } else {
                        s = new Asset(Id =evpl.Id);
                        if (circNameToUNIEVPLMap.containsKey(uniCName)) {
                            s.UNI_Host__c = circNameToUNIForEVPLUpdate.get(uniCName).Id;
                            s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                        }
                        evplAssetUpdateMap.put(s.Id, s);
                    }
                }
            }
            for (Id evpl : evplZToLineNoMap.keySet()) {
                system.debug('came into evplZToLineNoMap keySet()');
                Asset s;
                if (evplAssetUpdateMap.containsKey(evpl)) {
                    s = evplAssetUpdateMap.get(evpl);
                    //sa = new Asset(Id = evpl);
                    s.vlocity_cmt__LineNumber__c = evplZToLineNoMap.get(evpl) + '.' + '0001';
                    s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                } else {
                    s = new Asset(Id = evpl);
                    s.vlocity_cmt__LineNumber__c = evplZToLineNoMap.get(evpl) + '.' + '0001';
                    s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                    evplAssetUpdateMap.put(s.Id, s);
                }
            }
            system.debug('evplAssetUpdateMap check ' + evplAssetUpdateMap);
            system.debug('ipAssetListUpsert after evpl uni added ' + ipAssetListUpsert);
            //update dia assets with uni rootitemid
            for (String cName : circNameToDIAMap.keySet()) {
                Asset s = new Asset(Id = circNameToDIAMap.get(cName).Id);
                s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                s.UNI_Host__c = circNameToUNIMap.get(cName).Id;
                ipAssetListUpsert.add(s);
            }
            List<AssetStagingJSONMapping__c> mRAssetJSONMappings = new List<AssetStagingJSONMapping__c>();
            if (!managedRouterToCreate.isEmpty()) {
                mRAssetJSONMappings = MACDAssetDIAIPBatchHelper.getAssetStagingMRMappings();
            }
            for (String cName : managedRouterToCreate.keySet()) {
                Asset s;
                if (diaToManagedRouterMap.containsKey(circNameToDIAMap.get(cName).Id)) {
                    system.debug('came inot mg update');
                    s = new Asset(Id = diaToManagedRouterMap.get(circNameToDIAMap.get(cName).Id).Id,vlocity_cmt__JSONAttribute__c=diaToManagedRouterMap.get(circNameToDIAMap.get(cName).Id).vlocity_cmt__JSONAttribute__c);
                } else {
                    system.debug('came inot mg insert');
                    s = new Asset();
                }
                s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                s.Name  = managedRouterPriceBookEntry.Product2.name;
                s.Product2Id = managedRouterPriceBookEntry.Product2.Id;
                s.AccountId = managedRouterToCreate.get(cName).AccountId;
                //s.vlocity_cmt__PricebookEntryId__c  = diaToDIAAssetIdMap.get(diaId).vlocity_cmt__PricebookEntryId__c;
                s.vlocity_cmt__PricebookEntryId__c  = managedRouterPriceBookEntry.Id;
                s.vlocity_cmt__JSONAttribute__c = MACDAssetDIAIPBatchHelper.getJSONAttributeManagedRouter(managedRouterPriceBookEntry.Product2.vlocity_cmt__JSONAttribute__c, uniCNameToCircuitMap.get(cName), mRAssetJSONMappings);
                s.vlocity_cmt__ServiceAccountId__c = managedRouterToCreate.get(cName).vlocity_cmt__ServiceAccountId__c;
                s.vlocity_cmt__LineNumber__c = circNameToDIAMap.get(cName).vlocity_cmt__LineNumber__c + '.' + '0002';
                s.DPI_WTN__c = circNameToDIAMap.get(cName).DPI_WTN__c;
                s.vlocity_cmt__PriceListId__c = priceListId;
                s.vlocity_cmt__Action__c = 'Add';
                s.vlocity_cmt__EffectiveOneTimeTotal__c = 0;
                s.vlocity_cmt__EffectiveQuantity__c = 1;
                s.Quantity = 1;
                s.vlocity_cmt__EffectiveRecurringTotal__c = 0;
                s.vlocity_cmt__OneTimeCalculatedPrice__c = 0;
                s.vlocity_cmt__OneTimeCharge__c = 0;
                s.vlocity_cmt__OneTimeTotal__c = 0;
                s.vlocity_cmt__ProvisioningStatus__c = 'Active';
                s.Price = 0;
                system.debug('maanger riuter ' + s);
                ipAssetListUpsert.add(s);
            }
        }
        system.debug('ipAssetListUpsert ' + ipAssetListUpsert);
        system.debug('updateList final ' + updateList);
        if (!ipAssetListUpsert.isEmpty()) {
            upsert ipAssetListUpsert;
        }
        if (!evplAssetUpdateMap.isEmpty()) {
            upsert evplAssetUpdateMap.values();
        }
        if (!evplAAssetListUpdate.isEmpty()) {
            update evplAAssetListUpdate;
        }
        if (!updateList.isEmpty()) {
                update updateList;
            }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}