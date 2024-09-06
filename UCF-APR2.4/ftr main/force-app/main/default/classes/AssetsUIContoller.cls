global with sharing class AssetsUIContoller implements vlocity_cmt.VlocityOpenInterface {
  
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        try {
            System.debug('Enter AssetsUIContoller:' + methodName);
            if (methodName == 'getAssetUIMappingJSON') {                
				String jsonString = getAssetUIMappingJSON();
                outputMap.put('ResultJSON', jsonString);
                return true;
            } 
            return true;
        } catch (Exception ex) { 
            System.debug(ex + ' : ' + ex.getMessage());
            return false;
        } 
    }
    
    public String getAssetUIMappingJSON(){
        String jsonString;
		//Assets_UI_Field_Mapping__mdt  assetUIMappingJSON = Assets_UI_Field_Mapping__mdt.getInstance('JSON_String');
		List<Assets_UI_Field_Mapping__mdt> lstAssetUIFieldMapMeta = [SELECT id, Mappings_JSON__c 
                                                  			         FROM Assets_UI_Field_Mapping__mdt
                                                                     LIMIT 1];
        if(lstAssetUIFieldMapMeta[0].Mappings_JSON__c != null){
            jsonString = lstAssetUIFieldMapMeta[0].Mappings_JSON__c;
        }
        return jsonString;
    }
}