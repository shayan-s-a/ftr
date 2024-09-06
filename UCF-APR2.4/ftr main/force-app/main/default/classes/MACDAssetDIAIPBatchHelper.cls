public class MACDAssetDIAIPBatchHelper {
    public static Map<String, String> ipBlocksMap = new Map<String, String> ();
    public static Map<String, String> ipTopologyMap = new Map<String, String>{'FLAT LAN' => 'Flat', 'WAN/LAN' => 'LAN/WAN'};
	public static List<AssetStagingJSONMapping__c> getAssetStagingIPMappings() {
        List<AssetStagingJSONMapping__c> mappingList = new List<AssetStagingJSONMapping__c>();
        for (AssetStagingJSONMapping__c mapping : AssetStagingJSONMapping__c.getAll().values()) {
            if (mapping.IP_Applicable__c) {
                mappingList.add(mapping);
            }
        }
        return mappingList;
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
    public static List<AssetStagingJSONMapping__c> getAssetStagingEVPLAMappings() {
        List<AssetStagingJSONMapping__c> mappingList = new List<AssetStagingJSONMapping__c>();
        for (AssetStagingJSONMapping__c mapping : AssetStagingJSONMapping__c.getAll().values()) {
            if (mapping.EVPL_A__c) {
                mappingList.add(mapping);
            }
        }
        return mappingList;
    }
    public static List<AssetStagingJSONMapping__c> getAssetStagingMRMappings() {
        List<AssetStagingJSONMapping__c> mappingList = new List<AssetStagingJSONMapping__c>();
        for (AssetStagingJSONMapping__c mapping : AssetStagingJSONMapping__c.getAll().values()) {
            if (mapping.Managed_Router_Applicable__c) {
                mappingList.add(mapping);
            }
        }
        return mappingList;
    }
    public static Map<String, String> getIPBlockMappings () {
        Map<String, String> ipMap = new Map<String, String>();
        for (IP_BlockSize_Mapping__c ipMapping : IP_BlockSize_Mapping__c.getAll().values()) {
            ipMap.put(ipMapping.IP_BLOCK_SIZE__c, ipMapping.ATTR_IP_BLOCKS__c);
        }
        return ipMap;
    }
    
    public static String getJSONAttributeUNI (String jsonAttribute, ftr_Asset_StagingCircuit__c circuitRec, List<AssetStagingJSONMapping__c> mappingList) {
        Map<String,Object> attrValueMap = new Map<String,Object>();
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
                value = MACDAssetBatchNewCIDHelper.modifyBandwidthValue(value);
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
        String updatedJSONAttribute = (String) ftr_CpqHelper.setJSONAttributes(jsonAttribute, '{}', attrValueMap);
        system.debug('updated json attribute in helper new batch ' + updatedJSONAttribute);
      	return updatedJSONAttribute;
    }
    public static String getJSONAttributeManagedRouter(String jsonAttribute, ftr_Asset_StagingCircuit__c circuitRec, List<AssetStagingJSONMapping__c> mappingList) {
        Map<String,Object> attrValueMap = new Map<String,Object>();
        //*store jurisdiction mappings
        //Map<String, String> jurisCodeMap = new Map<String, String>{'0'=>'Ignore','1'=>'Interstate','2'=>'Intrastate'};
            /*if (!ipBlocksMap.isEmpty()) {
                ipBlocksMap = getIPBlockMappings();
                system.debug('ipBlocksMap print ' + ipBlocksMap);
                system.debug('ipBlocksMap executed only once');
            }*/
        for (AssetStagingJSONMapping__c mapping : mappingList) {
            if (String.isBlank((String)circuitRec.get(mapping.StagingField__c))) {
                continue;
            }
            if (String.isNotBlank((String)circuitRec.get(mapping.StagingField__c))) {
               attrValueMap.put(mapping.AttributeCode__c,circuitRec.get(mapping.StagingField__c)); 
            }
            
        }
        system.debug('attrValueMap print in helper new bacth ' + attrValueMap);
        String updatedJSONAttribute = (String) ftr_CpqHelper.setJSONAttributes(jsonAttribute, '{}', attrValueMap);
        system.debug('updated json attribute in helper new batch ' + updatedJSONAttribute);
      	return updatedJSONAttribute;
    }
    public static String getJSONAttribute (String jsonAttribute, ftr_Asset_StagingCircuit__c circuitRec, List<AssetStagingJSONMapping__c> mappingList) {
        Map<String,Object> attrValueMap = new Map<String,Object>();
        //store jurisdiction mappings
        //Map<String, String> jurisCodeMap = new Map<String, String>{'0'=>'Ignore','1'=>'Interstate','2'=>'Intrastate'};
            if (ipBlocksMap.isEmpty()) {
                ipBlocksMap = getIPBlockMappings();
                system.debug('ipBlocksMap print ' + ipBlocksMap);
                system.debug('ipBlocksMap executed only once');
            }
        for (AssetStagingJSONMapping__c mapping : mappingList) {
            if (!circuitRec.isSet(mapping.StagingField__c)) {
                continue;
            }
            if (String.isBlank((String)circuitRec.get(mapping.StagingField__c))) {
                continue;
            }
            if (mapping.AttributeCode__c == 'ATTR_IP_BLOCKS') {
                String value = ipBlocksMap.containsKey((String)circuitRec.get(mapping.StagingField__c))?ipBlocksMap.get((String)circuitRec.get(mapping.StagingField__c)):(String)circuitRec.get(mapping.StagingField__c);
                system.debug('ATTR_IP_BLOCKS value afte preocess for ip asset ' + value);
                if (String.isNotBlank(value)) {
                    attrValueMap.put(mapping.AttributeCode__c,(Object)value);
                }
                continue;
            }
            if (mapping.AttributeCode__c == 'ATTR_TOPO') {
                String value = ipTopologyMap.containsKey((String)circuitRec.get(mapping.StagingField__c))?ipTopologyMap.get((String)circuitRec.get(mapping.StagingField__c)):(String)circuitRec.get(mapping.StagingField__c);
                system.debug('ATTR_TOPO value afte preocess for ip asset ' + value);
                if (String.isNotBlank(value)) {
                    attrValueMap.put(mapping.AttributeCode__c,(Object)value);
                }
                continue;
            }
            if (mapping.AttributeCode__c == 'ATTR_BANDWIDTH') {
                String value = (String)circuitRec.get(mapping.StagingField__c);
                value = MACDAssetBatchNewCIDHelper.modifyBandwidthValue(value);
                system.debug('bandiwth value afte preocess for ip asset ' + value);
                attrValueMap.put(mapping.AttributeCode__c,value); 
                continue;
            }
            if (String.isNotBlank((String)circuitRec.get(mapping.StagingField__c))) {
               attrValueMap.put(mapping.AttributeCode__c,circuitRec.get(mapping.StagingField__c)); 
            }
        }
        system.debug('attrValueMap print in helper new bacth ' + attrValueMap);
        String updatedJSONAttribute = (String) ftr_CpqHelper.setJSONAttributes(jsonAttribute, '{}', attrValueMap);
        system.debug('updated json attribute in helper new batch ' + updatedJSONAttribute);
      	return updatedJSONAttribute;
    }
    public static Map<String, Account> getServiceAccsForStreet(Map<String, Set<String>> streetAddress, Map<Id,Set<String>> accToCircuitNameMap) {
        Map<String, Account> uniCNameToServAccMap = new Map<String, Account>();
        if (streetAddress.isEmpty()) {
            return uniCNameToServAccMap;
        }
        for(Account acc :[SELECT Id,Customer_Number__c,ParentId,Parent.Customer_Number__c,ShippingStreet from Account where (ShippingStreet IN: streetAddress.keySet() AND ParentId IN: accToCircuitNameMap.keySet()) and RecordType.developername ='Service' and ParentId != null] ) {
            if (accToCircuitNameMap.containsKey(acc.ParentId)) {
                if (streetAddress.containsKey(acc.ShippingStreet.toLowerCase())) {
                    Set<String> cNameSet =   streetAddress.get(acc.ShippingStreet.toLowerCase());     
                    for (String cName : cNameSet) {
                        uniCNameToServAccMap.put(cName, acc);
                    }
                }
            }
        }
        return uniCNameToServAccMap;
    }
    public static void updateUNIToNeedReview (Map<String, ftr_Asset_StagingCircuit__c> uniCNameToCircuitMap) {
        if (uniCNameToCircuitMap.isEmpty()) {
            return;
        }
        List<ftr_Asset_StagingCircuit__c> circuitUpdateList = new List<ftr_Asset_StagingCircuit__c>();
        for (ftr_Asset_StagingCircuit__c circuitRec : uniCNameToCircuitMap.values()) {
            ftr_Asset_StagingCircuit__c circuit = new ftr_Asset_StagingCircuit__c(Id = circuitRec.Id,  Status__c = 'Needs Review', Error_Message__c = 'No DIA/EVPL Asset for UNI Found', Pass_Number__c = circuitRec.Pass_Number__c + 1);
            if (String.isNotBlank(circuitRec.WTN__c)) {
                    if (circuitRec.WTN__c.length() != 10) {
                		circuit.Notes__c = 'WTN length should be exact 10';
            		}
                }
            system.debug('added into  circuit update lsit updateUNIToNeedReview');
            circuitUpdateList.add(circuit);
        }
        system.debug('circuitUpdateList print in updateUNIToNeedReview ' + circuitUpdateList);
        if (!circuitUpdateList.isEmpty()) {
            update circuitUpdateList;
        }
    }
}