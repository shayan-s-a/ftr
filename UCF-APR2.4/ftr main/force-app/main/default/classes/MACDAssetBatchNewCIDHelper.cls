public class MACDAssetBatchNewCIDHelper {
 Public Static Map<Id,Account> getServiceAccId(Map < Id, ftr_Asset_StagingCircuit__c > circuitMap,Map<String,Set<Id>> CuNoCircuitIdMap,Map<String,Set<Id>> idAccCircuitIdMap, Set<Id> wtnSetIds, Set<String> Streetadd, Map<String,Set<Id>> M6CustNoToCircMap, Map<Id,Account> circuitAccMap){
     system.debug('In helper circuitMap' + circuitMap);
      system.debug('In helper CuNoWtnMap' + CuNoCircuitIdMap);
         Map<Id,Account> cIdAccSerMap = new Map<Id,Account>();
     for(Account acc :[SELECT Id,Customer_Number__c,ParentId,Parent.Customer_Number__c,Parent.account_id_caps__c ,Parent.M6_Customer_Number__c,ShippingStreet from Account where (ParentId IN: circuitAccMap.values() and ShippingStreet IN: Streetadd) and RecordType.developername ='Service' and ParentId != null] ) { 
         system.debug('check this service acc ' + acc);
         //system.debug('check this ' + CuNoWtnMap.get(acc.Parent_Account__r.Customer_Number__c));
         if (CuNoCircuitIdMap.containsKey(acc.Parent.Customer_Number__c)) {
             Set<Id> tempCIdSet = CuNoCircuitIdMap.get(acc.Parent.Customer_Number__c);
               for (Id cId : tempCIdSet) {
                   /*Set<String> wtnSet = streetAddrToWtnMap.get(acc.ShippingStreet);
                   if (wtnSet.contains(wtn)) {
                       WtnACCSerMap.put(wtn,acc);
                   }*/
                   ftr_Asset_StagingCircuit__c circuitRec = circuitMap.containsKey(cId)?circuitMap.get(cId):new ftr_Asset_StagingCircuit__c();
                   if (circuitRec.PriLocStreetAddress__c == acc.ShippingStreet) {
                       if(!cIdAccSerMap.containsKey(cId)) {
                            cIdAccSerMap.put(cId,acc);
                       }
                   }
               }
            // WtnAccSerMap.put(CuNoWtnMap.get(acc.Parent.Customer_Number__c),acc);
         } if (idAccCircuitIdMap.containsKey(acc.ParentId)) {
             Set<Id> tempCIdSet = idAccCircuitIdMap.get(acc.ParentId);
               for (Id cId : tempCIdSet) {
                   /*Set<String> wtnSet = streetAddrToWtnMap.get(acc.ShippingStreet);
                   if (wtnSet.contains(wtn)) {
                       WtnACCSerMap.put(wtn,acc);
                   }*/
                   ftr_Asset_StagingCircuit__c circuitRec = circuitMap.containsKey(cId)?circuitMap.get(cId):new ftr_Asset_StagingCircuit__c();
                   if (circuitRec.PriLocStreetAddress__c == acc.ShippingStreet) {
                       if(!cIdAccSerMap.containsKey(cId)) {
                            cIdAccSerMap.put(cId,acc);
                       }
                   }
               }
             //WtnAccSerMap.put(idAccWtnMap.get(acc.ParentId),acc);
         } if (M6CustNoToCircMap.containsKey(acc.Parent.account_id_caps__c )) {
             Set<Id> tempCIdSet = M6CustNoToCircMap.get(acc.Parent.account_id_caps__c );
               for (Id cId : tempCIdSet) {
                   /*Set<String> wtnSet = streetAddrToWtnMap.get(acc.ShippingStreet);
                   if (wtnSet.contains(wtn)) {
                       WtnACCSerMap.put(wtn,acc);
                   }*/
                   ftr_Asset_StagingCircuit__c circuitRec = circuitMap.containsKey(cId)?circuitMap.get(cId):new ftr_Asset_StagingCircuit__c();
                   if (circuitRec.PriLocStreetAddress__c == acc.ShippingStreet) {
                       if(!cIdAccSerMap.containsKey(cId)) {
                            cIdAccSerMap.put(cId,acc);
                       }
                   }
               }
         }
         if (M6CustNoToCircMap.containsKey(acc.Parent.M6_Customer_Number__c)) {
             Set<Id> tempCIdSet = M6CustNoToCircMap.get(acc.Parent.M6_Customer_Number__c);
               for (Id cId : tempCIdSet) {
                   /*Set<String> wtnSet = streetAddrToWtnMap.get(acc.ShippingStreet);
                   if (wtnSet.contains(wtn)) {
                       WtnACCSerMap.put(wtn,acc);
                   }*/
                   ftr_Asset_StagingCircuit__c circuitRec = circuitMap.containsKey(cId)?circuitMap.get(cId):new ftr_Asset_StagingCircuit__c();
                   if (circuitRec.PriLocStreetAddress__c == acc.ShippingStreet) {
                       if(!cIdAccSerMap.containsKey(cId)) {
                            cIdAccSerMap.put(cId,acc);
                       }
                   }
               }
         }
           
           }
 
    return cIdAccSerMap;
 }
     
    public static Map<String,PriceBookEntry> getAliasToProductIdMap(Set<String> aliasSet) {
        List<Product_Mapping__c> mappingList = Product_Mapping__c.getAll().values();
        Map<String,String> productCodeToAliasMap = new Map<String,String>();
        Map<String,PriceBookEntry> aliasToPriceBEntryMap = new Map<String,PriceBookEntry>();
        for (Product_Mapping__c mapping : mappingList) {
            productCodeToAliasMap.put(mapping.Product_Code__c, mapping.Product_Item_Alias__c);
        }
        for (PriceBookEntry entry : [SELECT Id,ProductCode,Product2.Id,Product2.Name,Product2.vlocity_cmt__JSONAttribute__c FROM PriceBookEntry WHERE ProductCode IN: productCodeToAliasMap.keySet()]) {
            aliasToPriceBEntryMap.put(productCodeToAliasMap.get(entry.ProductCode), entry);
        }
        return aliasToPriceBEntryMap;
    }
    public static Id getPriceListId () {
        return [SELECT id FROM vlocity_cmt__PriceList__c WHERE vlocity_cmt__Code__c = 'FTR_ENT_PL' LIMIT 1]?.Id;
    }
    /*public static List<AssetStagingJSONMapping__c> getAssetStagingMappings(Boolean isIPMappings) {
        List<AssetStagingJSONMapping__c> mappingList = AssetStagingJSONMapping__c.getAll().values();
        return mappingList;
    }*/
    public static List<AssetStagingJSONMapping__c> getAssetStagingMappings() {
        List<AssetStagingJSONMapping__c> mappingList = new List<AssetStagingJSONMapping__c>();
        for (AssetStagingJSONMapping__c mapping : AssetStagingJSONMapping__c.getAll().values()) {
            if (mapping.Asset_Applicable__c) {
                mappingList.add(mapping);
            }
        }
        return mappingList;
    }
    public static String getJSONAttribute (String jsonAttribute, ftr_Asset_StagingCircuit__c circuitRec, List<AssetStagingJSONMapping__c> mappingList) {
        Map<String,Object> attrValueMap = new Map<String,Object>();
        //store jurisdiction mappings
        Map<String, String> jurisCodeMap = new Map<String, String>{'0'=>'Ignore','1'=>'Interstate','2'=>'Intrastate'};
        for (AssetStagingJSONMapping__c mapping : mappingList) {
            if (String.isBlank((String)circuitRec.get(mapping.StagingField__c))) {
                continue;
            }
            if (mapping.AttributeCode__c == 'ATTR_TECH_JURIS') {
                String value = jurisCodeMap.containsKey((String)circuitRec.get(mapping.StagingField__c))?jurisCodeMap.get((String)circuitRec.get(mapping.StagingField__c)):'';
                if (String.isNotBlank(value)) {
                    attrValueMap.put(mapping.AttributeCode__c,(Object)value);
                }
                continue;
            }
            if (mapping.AttributeCode__c == 'ATTR_BANDWIDTH') {
                String value = (String)circuitRec.get(mapping.StagingField__c);
                value = modifyBandwidthValue(value);
                system.debug('bandiwth value afte preocess ' + value);
                attrValueMap.put(mapping.AttributeCode__c,value); 
                continue;
            }
            if (String.isNotBlank((String)circuitRec.get(mapping.StagingField__c))) {
               attrValueMap.put(mapping.AttributeCode__c,circuitRec.get(mapping.StagingField__c)); 
            }
        }
        system.debug('attrValueMap print in helper ' + attrValueMap);
        system.debug('parent srvice id ' + attrValueMap.get('parentServiceItemId'));
        system.debug('srvice item id ' + attrValueMap.get('serviceItemId'));
        String updatedJSONAttribute = (String) ftr_CpqHelper.setJSONAttributes(jsonAttribute, '{}', attrValueMap);
        system.debug('updated json attribute in helper ' + updatedJSONAttribute);
      	return updatedJSONAttribute;
    }
    public class AssetResult {
        public Set<Id> successCIds;
        public Set<Id> failedCIds;
        //map from assetId to its respective circuit record
        public Map<Id, ftr_Asset_StagingCircuit__c> assetToCircuitMap;
        //map from ruid 2 to asset Id Map only for evpl Z's
        public Map<String, List<Asset>> ruid2ToAssetMap;
        public AssetResult () {
            successCIds = new Set<Id>();
            failedCIds = new Set<Id>();
            assetToCircuitMap = new Map<Id, ftr_Asset_StagingCircuit__c>();
            ruid2ToAssetMap = new Map<String, List<Asset>>();
        }
    }
    public static AssetResult getAssetResult (Database.UpsertResult[] upsertResult, Map<String, Id> cNameToCIdMap, List<Asset> assetList,  Map < Id, ftr_Asset_StagingCircuit__c > circuitMap) {
        AssetResult assRes = new AssetResult();
        Id evplZProductId = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode = 'ENT_ETH_EVPL_0010' LIMIT 1]?.Id;
        for (Integer i=0;i<upsertResult.size();i++) {
            String circuitName = assetList[i].M6_CircuitId__c;
                String circuitId = cNameToCIdMap.get(circuitName);
            if (upsertResult[i].isSuccess()) {
                assRes.successCIds.add(circuitId);
                assRes.assetToCircuitMap.put(upsertResult[i].getId(), circuitMap.get(circuitId));
                system.debug('assetList[i].ProductCode == ' + assetList[i].ProductCode);
                if (assetList[i].Product2Id == evplZProductId) {
                    if (assRes.ruid2ToAssetMap.containsKey(assetList[i].RUID_2_Terminating_CE_VLAN_ID__c)) {
                        List<Asset> tempAssetList = assRes.ruid2ToAssetMap.get(assetList[i].RUID_2_Terminating_CE_VLAN_ID__c);
                        tempAssetList.add(assetList[i]);
                        assRes.ruid2ToAssetMap.put(assetList[i].RUID_2_Terminating_CE_VLAN_ID__c, tempAssetList);
                    } else {
                        List<Asset> tempAssetList = new List<Asset>{assetList[i]};
                        assRes.ruid2ToAssetMap.put(assetList[i].RUID_2_Terminating_CE_VLAN_ID__c, tempAssetList);
                    }
                }
            } else if (!upsertResult[i].isSuccess()) {
                assRes.failedCIds.add(circuitId);
            }
        }
        system.debug('assRes.ruid2ToAssetMap + ' + assRes.ruid2ToAssetMap);
        return assRes;
    }
    public static List<ftr_Asset_StagingCircuit__c> updateCircuitRecords (Set<Id> successCIds, Set<Id> failedCIds, Map<Id, ftr_Asset_StagingCircuit__c> circuitMap) {
        List<ftr_Asset_StagingCircuit__c> updateList = new List<ftr_Asset_StagingCircuit__c>();
        for (Id cId : successCIds) {
            ftr_Asset_StagingCircuit__c circuitRec = new ftr_Asset_StagingCircuit__c(Id = cId, Status__c = 'Complete', Error_Message__c = '', Pass_Number__c = circuitMap.get(cId).Pass_Number__c + 1);
            updateList.add(circuitRec);
        }
        for (Id cId : failedCIds) {
            ftr_Asset_StagingCircuit__c circuitRec = new ftr_Asset_StagingCircuit__c(Id = cId, Status__c = 'Needs Review', Error_Message__c = 'Asset failed to insert/update', Pass_Number__c = circuitMap.get(cId).Pass_Number__c + 1);
            updateList.add(circuitRec);
        }
        /*if (!updateList.isEmpty()) {
            update updateList;
        }*/
        //*
        return updateList;
    }
    public static String modifyBandwidthValue (String value) {
        if (String.isBlank(value)) {
            return value;
        }
        if (value.endsWith('MBPS')) {
            value = value.replace('MBPS', 'Mbps');
        } else if (value.endsWith('GBPS')) {
            value = value.replace('GBPS', 'Gbps');
        } else if (value.endsWith('G')) {
            value = value.replace('G', 'Gbps');
        } else if (value.endsWith('M')) {
            value = value.replace('M', 'Mbps');
        }
        return value;
    }
    public static void updateAccounts (Map<Id, Account> circAccMap, Map < Id, ftr_Asset_StagingCircuit__c > circuitMap) {
        system.debug('entered into update accounts');
        if (circAccMap.isEmpty()) {
            return;
        }
        system.debug('circAccMap==> ' + circAccMap);
        Map<Id, Account> updateMap = new Map<Id, Account>();
        for (Id cId : circAccMap.keySet()) {
            if (String.isBlank(circAccMap.get(cId).M6_Customer_Number__c) && String.isNotBlank(circuitMap.get(cId).CUST_ACCT_NBR__c)) {
                if (!circuitMap.get(cId).CUST_ACCT_NBR__c.startsWith('001')) {
                    Account acc = circAccMap.get(cId);
                    acc.M6_Customer_Number__c = circuitMap.get(cId).CUST_ACCT_NBR__c;
                    updateMap.put(acc.Id, acc);
                } else if (circuitMap.get(cId).CUST_ACCT_NBR__c.startsWith('001')) {
                    Account acc = circAccMap.get(cId);
                    acc.M6_Customer_Number__c = circuitMap.get(cId).CUST_ACCT_NBR__c;
                    updateMap.put(acc.Id, acc);
                }
            }
        }
        system.debug('updateMap==> ' + updateMap);
        if (!updateMap.isEmpty()) {
            update updateMap.values();
        }
    }
    public static Set<String> getAccNamesToIgnore() {
        List<MACD_Account_Name_Ignore__mdt> accNames = MACD_Account_Name_Ignore__mdt.getAll().values();
        Set<String> m6AccNums = new Set<String>();
        for (MACD_Account_Name_Ignore__mdt accName : accNames) {
            m6AccNums.add(accName.M6_CUST_ACCT_NBR__c);
        }
        return m6AccNums;
    }
}