global class MACDUpdateAssetBatch implements Database.Batchable < sObject >,Database.Stateful  {
    public MACDUpdateAssetBatch() {
        assetEVPLJSONMappings = getAssetStagingMappings();
        assetUNIJSONMappings = getAssetStagingUNIMappings();
        aliasToProductCodeMap = getAliasToProductCodeMap();
        circuitQueryString = 'SELECT id,name,bit_rate__c,ftr_Account_Name__c,cust_acct_nbr__c,class_of_service__c,error_message__c,managed_device__c,psr_evc_type__c,psr_sdwan__c,psr_virtual_broadband_service_category__c,pass_number__c,priloccity__c,prilocpostalcode__c,prilocstate__c,prilocstreetaddress__c,speed__c,secloccity__c,seclocpostalcode__c,seclocstate__c,seclocstreetaddress__c,status__c,term__c,wtn__c,ftr_circuit_id__c,ftr_companyindicator__c,ftr_ipaddresstype__c,ftr_ipblocksize__c,ftr_iptopology__c,ftr_item_alias__c,ftr_managedfirewall__c,ftr_npa_nxx__c,ftr_psr_cir__c,ftr_psr_jurisdiction__c,ftr_psr_ratecode__c,ftr_psr_parentserviceitemid__c,ftr_ruid1__c,ftr_ruid2__c,ftr_secnci__c,ftr_serviceitemid__c,ftr_circuitname__c,ftr_documentnumber__c,lan_ip__c,managed_device_type__c,wan_ip__c,Service_Address_From_DPI__c,City_DPI__c,Serviceaddress_DPI__c,State_DPI__c,Zipcode_DPI__c FROM ftr_Asset_StagingCircuit__c WHERE ftr_NPA_NXX__c IN: npaNxxSet ';    
    }
   //Set<Id> assetSet = new Set<Id>{'02i0h00000AdxlwAAB'};
        String queryString = 'SELECT Id, NPA_NXX__c, ProductCode, Account.X18_Digit_Acct_ID__c, Product2.vlocity_cmt__JSONAttribute__c ,vlocity_cmt__JSONAttribute__c FROM Asset WHERE Purpose__c = null AND NPA_NXX__c  != null';
    String circuitQueryString;
    private List<AssetStagingJSONMapping__c> assetEVPLJSONMappings;
    private List<AssetStagingJSONMapping__c> assetUNIJSONMappings;
    global Id priceListId = getPriceListId();
    global Map<String, String> aliasToProductCodeMap = new Map<String, String>();
    global DataBase.QueryLocator start(Database.BatchableContext BC) {
        system.debug('aliasToProductCodeMap ==> ' + aliasToProductCodeMap);
        return DataBase.getQueryLocator(queryString);
    }
    global void execute(Database.BatchableContext BC, List < Asset > scope) {
        Set<String> npaNxxSet = new Set<String>();
        Map<ftr_Asset_StagingCircuit__c, Asset> circuitToAssetMap = new Map<ftr_Asset_StagingCircuit__c, Asset>();
        Map<String, Asset> npaToAssetMap = new Map<String, Asset>();
        List<Asset> assetListToUpdate = new List<Asset>();
        Map<Id, ftr_Asset_StagingCircuit__c> circuitMap = new Map<Id, ftr_Asset_StagingCircuit__c>();
        Set<Id> assetIds = new Set<Id>();
        Set<String> prodCodeSet = new Set<String>();
        for (Asset asset: scope) {
            //String npa = (String)ftr_CpqHelper.getJSONAttributeValue(asset.vlocity_cmt__JSONAttribute__c, 'ATTR_NPA_NXX');
            if (String.isNotBlank(asset.NPA_NXX__c) && String.isNotBlank(asset.ProductCode)) {
                npaNxxSet.add(asset.NPA_NXX__c);
                npaToAssetMap.put(asset.NPA_NXX__c + '-' + asset.ProductCode, asset);
                prodCodeSet.add(asset.ProductCode);
            }
        }
        if (npaNxxSet.isEmpty()) {
            return;
        }
        Map<String, ftr_Attribute_Based_SNE__c> attrSNEMap = getAttributeBasedSNEMappings(prodCodeSet);
        for (ftr_Asset_StagingCircuit__c circuit : Database.query(circuitQueryString)) {
            
            system.debug('circuit.CUST_ACCT_NBR__c ==> ' + circuit.CUST_ACCT_NBR__c);
            
            system.debug(aliasToProductCodeMap.containsKey(circuit.ftr_Item_Alias__c));
            system.debug('asset.ProductCode ==> ' + asset.ProductCode);
            system.debug('aliasToProductCodeMap.get(circuit.ftr_Item_Alias__c) == .' + aliasToProductCodeMap.get(circuit.ftr_Item_Alias__c));
            if (!(aliasToProductCodeMap.containsKey(circuit.ftr_Item_Alias__c))) {
                continue;
            }
            system.debug('circuit.ftr_NPA_NXX__c ==> ' + circuit.ftr_NPA_NXX__c);
            system.debug('aliasToProductCodeMap.get(circuit.ftr_Item_Alias__c) ==> ' + aliasToProductCodeMap.get(circuit.ftr_Item_Alias__c));
            if (!npaToAssetMap.containsKey(circuit.ftr_NPA_NXX__c + '-' + aliasToProductCodeMap.get(circuit.ftr_Item_Alias__c))) {
                continue;
            }
            Asset asset = npaToAssetMap.get(circuit.ftr_NPA_NXX__c + '-' + aliasToProductCodeMap.get(circuit.ftr_Item_Alias__c));
            system.debug('asset.Account.X18_Digit_Acct_ID__c ==> ' + asset.Account.X18_Digit_Acct_ID__c);
            if (asset.Account.X18_Digit_Acct_ID__c != circuit.CUST_ACCT_NBR__c) {
                continue;
            }
            if (!(aliasToProductCodeMap.containsKey(circuit.ftr_Item_Alias__c) && aliasToProductCodeMap.get(circuit.ftr_Item_Alias__c) == asset.ProductCode)) {
                continue;
            }
            circuitToAssetMap.put(circuit, asset);
            circuitMap.put(circuit.id, circuit);
            system.debug('asset ==> ' + asset);
            Asset s = new Asset(Id = asset.Id);
            
            String productCode = aliasToProductCodeMap.get(circuit.ftr_Item_Alias__c);
            
           // s.vlocity_cmt__LineNumber__c =  circuit.Name.substringAfter('-');
            Map<String, Object> attrValueMap = new Map<String, Object>();
            attrValueMap = ftr_CpqHelper.getJSONAttributeValues(asset.vlocity_cmt__JSONAttribute__c);
            if (attrValueMap == null) {
                continue;
            }
            system.debug('attrValueMap ==> ' + attrValueMap);
            if (attrValueMap != null && attrValueMap.containsKey('ATTR_BANDWIDTH') && attrValueMap.containsKey('ATTR_CONTRACT_TERM')) {
                String speed = (String)attrValueMap.get('ATTR_BANDWIDTH');
                String term = (String)attrValueMap.get('ATTR_CONTRACT_TERM');
                if (String.isNotBlank(speed) && String.isNotBlank(term) && attrSNEMap.containsKey(asset.ProductCode + '-' + term + '-' + speed)) {
                    attrValueMap.put('ATTR_DECOMP_MRCSNE', attrSNEMap.get(asset.ProductCode + '-' + term + '-' + speed).SNE_Code_MRC__c);
                    attrValueMap.put('ATTR_DECOMP_TERM_SNE', attrSNEMap.get(asset.ProductCode + '-' + term + '-' + speed).SNE_Code_Term__c);
                }
            }
            if (productCode == 'ENT_ETH_EIA_0002') {
                s.vlocity_cmt__JSONAttribute__c = getJSONAttribute(attrValueMap, asset.Product2.vlocity_cmt__JSONAttribute__c, circuit , assetEVPLJSONMappings);
            } else if (productCode == 'ENT_ETH_UNI_0001') {
                s.vlocity_cmt__JSONAttribute__c = getJSONAttributeUNI(attrValueMap, asset.Product2.vlocity_cmt__JSONAttribute__c, circuit , assetUNIJSONMappings);
            } else {
                continue;
            }
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
            s.M6_ServiceItemId__c = circuit.ftr_ServiceItemId__c;
            s.M6_ParentServiceItemId__c = circuit.ftr_PSR_parentServiceItemId__c;
            s.M6_CircuitId__c = circuit.ftr_circuitName__c;
            //to store uni ciruict name
            s.RUID_1_Originating_CE_VLAN_ID__c = circuit.ftr_RUID1__c;
            s.RUID_2_Terminating_CE_VLAN_ID__c = circuit.ftr_RUID2__c;
            s.DPI_WTN__c = circuit.WTN__c;
            s.M6_Cust_Acc_Number__c = circuit.CUST_ACCT_NBR__c;
            s.M6_Document_Number__c = circuit.ftr_documentNumber__c;
            s.LAN_IP__c = circuit.LAN_IP__c;
            s.Purpose__c = Label.Purpose_Value_for_MACD;
            system.debug('asset updated ' + s);
            assetListToUpdate.add(s);
        }
        if (!assetListToUpdate.isempty()) {
            //Schema.SObjectField extField = Asset.fields.M6_CircuitId__c;
            Database.upsertResult[] upsertResult = Database.upsert(assetListToUpdate, false);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    public static Map<String,String> getAliasToProductCodeMap() {
        Map<String,String> aliasToProductCodeMap = new Map<String,String>();
        for (Product_Mapping__c mapping : Product_Mapping__c.getAll().values()) {
            aliasToProductCodeMap.put(mapping.Product_Item_Alias__c, mapping.Product_Code__c);
        }
        return aliasToProductCodeMap;
    }
    public static String getJSONAttribute (Map<String, Object> attrValueMap, String jsonAttribute, ftr_Asset_StagingCircuit__c circuitRec, List<AssetStagingJSONMapping__c> mappingList) {
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
        String updatedJSONAttribute = (String) setJSONAttributes(jsonAttribute, '{}', attrValueMap);
        system.debug('updated json attribute in helper ' + updatedJSONAttribute);
        return updatedJSONAttribute;
    }
    public static List<AssetStagingJSONMapping__c> getAssetStagingMappings() {
        List<AssetStagingJSONMapping__c> mappingList = new List<AssetStagingJSONMapping__c>();
        for (AssetStagingJSONMapping__c mapping : AssetStagingJSONMapping__c.getAll().values()) {
            if (mapping.Asset_Applicable__c) {
                mappingList.add(mapping);
            }
        }
        return mappingList;
    }
    public static Id getPriceListId () {
        return [SELECT id FROM vlocity_cmt__PriceList__c WHERE vlocity_cmt__Code__c = 'FTR_ENT_PL' LIMIT 1]?.Id;
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
    public static String setJSONAttributes(String runtimeJSON, String originalJSON, Map<String, Object> attrVals) {
        List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> actionRequestsList = new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest>();
        for (String attrCode : attrVals.keySet()) {
            Object attrVal = attrVals.get(attrCode);
            if (attrVal == null) {
                continue;
            }
            actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest(
                attrCode, 
                vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, 
                attrVal)
                                  );
        }
        
        vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
        Map<String, Object> myInputMap = new Map<String, Object> {
            'objectSO' => null,
                'runTimeAttributesJSON' => runtimeJSON,
                'originalAttributesJSON' => originalJSON,
                'JSONAttributeActionRequestList' => actionRequestsList
                };
                    Map<String, Object> myOutputMap = new Map<String, Object>();
        Map<String, Object> myOptionsMap = new Map<String, Object>();
        
        jsonSupport.invokeMethod('applyAttributeActions', myInputMap, myOutputMap, myOptionsMap);
        String modifiedJSON = (String)myOutputMap.get('modifiedJSON');
        
        return modifiedJSON;
    }
    public static Map<String, ftr_Attribute_Based_SNE__c> getAttributeBasedSNEMappings(Set<String> prodCodeSet) {
        Map<String, ftr_Attribute_Based_SNE__c> attrSNEMap = new Map<String, ftr_Attribute_Based_SNE__c>();
        for (ftr_Attribute_Based_SNE__c sne : [SELECT Id, CoS__c, Product_Code__c, Product_Name__c, SNE_Code_MRC__c, SNE_Code_OTC__c, SNE_Code_Term__c, Speed__c, Term__c FROM ftr_Attribute_Based_SNE__c WHERE Product_Code__c IN: prodCodeSet]) {
            if (String.isNotBlank(sne.Product_Code__c) && String.isNotBlank(sne.Term__c) && String.isNotBlank(sne.Speed__c)) {
                attrSNEMap.put(sne.Product_Code__c + '-' + sne.Term__c + '-' + sne.Speed__c, sne);
            }
        }
        return attrSNEMap;
    }
    public static List<AssetStagingJSONMapping__c> getAssetStagingUNIMappings() {
        List<AssetStagingJSONMapping__c> mappingList = new List<AssetStagingJSONMapping__c>();
        for (AssetStagingJSONMapping__c mapping : AssetStagingJSONMapping__c.getAll().values()) {
            if (mapping.UNI_Applicable__c) {
                mappingList.add(mapping);
            }
        }
        return mappingList;
    }
    public static String getJSONAttributeUNI (Map<String, Object> attrValueMap, String jsonAttribute, ftr_Asset_StagingCircuit__c circuitRec, List<AssetStagingJSONMapping__c> mappingList) {
        //store jurisdiction mappings
        Map<String, String> jurisCodeMap = new Map<String, String>{'0'=>'Ignore','1'=>'Interstate','2'=>'Intrastate'};
            /*if (!ipBlocksMap.isEmpty()) {
                ipBlocksMap = getIPBlockMappings();
                system.debug('ipBlocksMap print ' + ipBlocksMap);
                system.debug('ipBlocksMap executed only once');
            }*/
        for (AssetStagingJSONMapping__c mapping : mappingList) {
            if (String.isBlank((String)circuitRec.get(mapping.StagingField__c))) {
                continue;
            }
            if (mapping.AttributeCode__c == 'ATTR_BANDWIDTH') {
                String value = (String)circuitRec.get(mapping.StagingField__c);
                value = modifyBandwidthValue(value);
                system.debug('bandiwth value afte preocess in dia ip batch ' + value);
                attrValueMap.put(mapping.AttributeCode__c,value); 
                continue;
            }
            if (mapping.AttributeCode__c == 'ATTR_TECH_JURISDICTION') {
                String value = jurisCodeMap.containsKey((String)circuitRec.get(mapping.StagingField__c))?jurisCodeMap.get((String)circuitRec.get(mapping.StagingField__c)):(String)circuitRec.get(mapping.StagingField__c);
                if (String.isNotBlank(value)) {
                    attrValueMap.put(mapping.AttributeCode__c,(Object)value);
                }
                continue;
            }
            if (mapping.AttributeCode__c == 'MANAGED_DEVICE_UNI') {
                String value = (String)circuitRec.get(mapping.StagingField__c);
                value = value == 'Y'?'Yes':(value == 'N'?'No':value);
                system.debug('MANAGED_DEVICE_UNI value afte preocess in dia ip batch ' + value);
                attrValueMap.put(mapping.AttributeCode__c,value); 
                continue;
            }
            if (String.isNotBlank((String)circuitRec.get(mapping.StagingField__c))) {
               attrValueMap.put(mapping.AttributeCode__c,circuitRec.get(mapping.StagingField__c)); 
            }
            
        }
        system.debug('attrValueMap print in helper new bacth ' + attrValueMap);
        String updatedJSONAttribute = (String) setJSONAttributes(jsonAttribute, '{}', attrValueMap);
        system.debug('updated json attribute in helper new batch ' + updatedJSONAttribute);
      	return updatedJSONAttribute;
    }
}