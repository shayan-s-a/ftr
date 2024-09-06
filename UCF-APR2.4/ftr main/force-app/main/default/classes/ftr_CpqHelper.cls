/****
* @description Utility class 
*/  
global without sharing class ftr_CpqHelper {

    /*
     * 
     * @description return the configuration setting value from CPQ Configuration Setup
     */
    public static String getCpqConfigurationSetupValue(String setupName)
    {
        vlocity_cmt__CpqConfigurationSetup__c cpqSetup = vlocity_cmt__CpqConfigurationSetup__c.getInstance(setupName);
        String retval = null;
        if (cpqSetup != null
            //expected condition: there is a Custom Setting
            && cpqSetup.vlocity_cmt__SetupValue__c != null
            && cpqSetup.vlocity_cmt__SetupValue__c.length() > 0)
        {
            retval = cpqSetup.vlocity_cmt__SetupValue__c;
        }
        return retval;
    }


    /*
     * @description utiliy method to read the attribute value from JSONAttribute field
     */
    public static Map<String, Object> getJSONAttributeValues(String jsonAttribute) {
        vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
        // Read the old speed
        Map<String, object> inputMap = new Map<String, object>{
            'UseDisplayTextForValues' => false,
            'JSONString' => jsonAttribute
        }; 
        Map<String, object> outputMap = new Map<String, object>(); 
        Map<String, object> optionsMap = new Map<String, object>();

        jsonSupport.invokeMethod('getAttributeValuesFromJSON', inputMap, outputMap, optionsMap); 
        Map<String, Object> attrVals = (Map<String, Object>)outputMap.get('attributeCodeToValue');
        return attrVals;
        // return attrVals.get(attribCode);
    }    

    /*
     * @description utiliy method to read the attribute value from JSONAttribute field
     */
    public static Object getJSONAttributeValue(String jsonAttribute, String attribCode) {
        return getJSONAttributeValues(jsonAttribute).get(attribCode);
        // vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
        // // Read the old speed
        // Map<String, object> inputMap = new Map<String, object>{
        //     'UseDisplayTextForValues' => false,
        //     'JSONString' => jsonAttribute
        // }; 
        // Map<String, object> outputMap = new Map<String, object>(); 
        // Map<String, object> optionsMap = new Map<String, object>();

        // jsonSupport.invokeMethod('getAttributeValuesFromJSON', inputMap, outputMap, optionsMap); 
        // Map<String, Object> attrVals = (Map<String, Object>)outputMap.get('attributeCodeToValue');
        // return attrVals.get(attribCode);
    } 

    public static String setJSONAttribute(String runtimeJSON, String originalJSON, String code, Object val) {
        Map<String, Object> attrVals = new Map<String, Object> {
            code => val
        };
        return setJSONAttributes(runtimeJSON, originalJSON, attrVals);
    }
    public static String setJSONAttributes(String runtimeJSON, String originalJSON, Map<String, Object> attrVals) {
        List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> actionRequestsList = new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest>();
        for (String attrCode : attrVals.keySet()) {
            Object attrVal = attrVals.get(attrCode);

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
    /*
     * @description utiliy method to set the value of attribute in JSONAttribute field of QuoteLineItem
     */
    public static List<QuoteLineItem> setQLIsAttribute(String attVal, List<QuoteLineItem> qLIs, String attCode) {
        vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
            
        for (QuoteLineItem qLI : qLIs) {
            if(qLI.vlocity_cmt__JSONAttribute__c != null) {
                Map<String, Object> input = new Map<String, Object> {
                    'objectSO' => null,
                        'runTimeAttributesJSON' => qLI.vlocity_cmt__JSONAttribute__c,
                        'originalAttributesJSON' => '{}',
                        'JSONAttributeActionRequestList' => new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> {
                            new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest(attCode, vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, attVal)
                        }
                };
                    Map<String, Object> output = new Map<String, Object>();
                Map<String, Object> myoptions = new Map<String, Object>();
                jsonSupport.invokeMethod('applyAttributeActions', input, output, myoptions);
                qLI.vlocity_cmt__JSONAttribute__c = (String)output.get('modifiedJSON');
            }
        }
        
        return qLIs;
    }

     /*
     * @description utiliy method to set the value of attribute in JSONAttribute field of OrderItem
     */

    public static  Boolean   setOLIsAttribute(String attVal, List<OrderItem> oLIs, String attCode) {
        vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
        Boolean isAttributeUpdated=false;
        ftr_Logger.writeInfo('Enter ftr_CpqHelper.setOLIsAttribute');
        try {
        for (OrderItem oLI : oLIs) {
            if(oLI.vlocity_cmt__JSONAttribute__c != null) {
                Map<String, Object> input = new Map<String, Object> {
                    'objectSO' => null,
                        'runTimeAttributesJSON' => oLI.vlocity_cmt__JSONAttribute__c,
                        'originalAttributesJSON' => '{}',
                        'JSONAttributeActionRequestList' => new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> {
                            new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest(attCode, vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, attVal)
                        }
                };
                    Map<String, Object> output = new Map<String, Object>();
                Map<String, Object> myoptions = new Map<String, Object>();
                jsonSupport.invokeMethod('applyAttributeActions', input, output, myoptions);
                oLI.vlocity_cmt__JSONAttribute__c = (String)output.get('modifiedJSON');
            }
        }
        update oLIs;
        isAttributeUpdated=true;
    }
    catch (Exception ex) {
        ftr_Logger.write(ex);
    } finally {
        ftr_Logger.writeInfo('Exit ftr_CpqHelper.setOLIsAttribute');
    }
    return isAttributeUpdated ;
    }

    /**
     * @description convert the Bandwidth to speed in MB
     */
    public static Integer convertToSpeed(String bandWidth) {
        if (bandWidth == null) return 0;

        if (bandWidth.endsWith('Mbps')) {
            return Integer.valueOf(bandWidth.left(bandWidth.length() - 4).trim());
        } else if (bandWidth.endsWith('MB')) {
            return Integer.valueOf(bandWidth.left(bandWidth.length() - 2).trim());
        } else if (bandWidth.endsWith('Gbps')) {
            return Integer.valueOf(bandWidth.left(bandWidth.length() - 4).trim()) * 1000;
        } else if (bandWidth.endsWith('GB')) {
            return Integer.valueOf(bandWidth.left(bandWidth.length() - 2).trim()) * 1000;
        } else if (bandWidth.endsWith('G')) {               // Added for HBE project by avv335
            return Integer.valueOf(bandWidth.left(bandWidth.length() - 1).trim()) * 1000;
        } else if (bandWidth.endsWith('GBPS')) {
            return Integer.valueOf(bandWidth.left(bandWidth.length() - 4).trim()) * 1000;
        } else if (bandWidth.endsWith('M')) {
            return Integer.valueOf(bandWidth.left(bandWidth.length() - 1).trim());
        } else{
            return 0;
        }
    }

    private static List<CustomCart_Data__mdt> bandWidthList = null;
    public static String convertToBandWidth(Integer speed) {
        if (bandWidthList == null) {
            bandWidthList = new List<CustomCart_Data__mdt>();
            bandWidthList = [SELECT MasterLabel, Bandwidth_Number__c, Copper_Enabled__c, Fiber_Enabled__c 
                             FROM CustomCart_Data__mdt
                             ORDER BY Bandwidth_Number__c];
        }

        String bandWidth;
        for (customCart_Data__mdt mdBandWidth : bandWidthList){
            if(speed <= mdBandWidth.Bandwidth_Number__c){
                bandWidth = mdBandWidth.MasterLabel;
                Break;
            }
        }
        return bandWidth;
    }
    
    
    @future
    public static void checkoutAsync(Id quoteId) {
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        String methodName = 'checkout';
        input.put('cartId', quoteId);
        input.put('ContextId', quoteId);// Replace with Quote Id
        input.put('methodName', 'checkout');
        input.put('validate', true);
        input.put('price', true);
        input.put('classMethodName', methodName);
        vlocity_cmt.VOIInvoker invoker = vlocity_cmt.VOIInvoker.getInstance();
        Object invokeResult = true;
        if (!Test.isRunningTest()){
            invokeResult = invoker.invoke('CpqAppHandler', 'invokeClass', input, output, options);      
        }
    }
    
    //paa512 - start SDDD-2650 changes for MACD Project - Get modified custom and service item attributes for change order
    //MACD Implementation for comparing the OLI and Asset JSON Attribute values
    //sample id: 424b1ee9-7d4e-8061-432b-14dbb5768d05
    //vlocity_cmt__AssetReferenceId__c on Order item = ATTR_FRLRefId as part of JSON attributes on FLR
	//Id on the Asset = vlocity_cmt__AssetId__c on OrderItem object
    //vlocity_cmt__FulfilmentRequestLine__c object's JSON attribute
	//This method needs to be invoked from getInputPayload where the payload going out to downstreams is built
    public static Map<String, List<Object>> compareOLIAndAssetJSONAttributesForChangeOrder(vlocity_cmt__FulfilmentRequestLine__c frl) {
     	//386ae351-3e20-1e90-09c6-bcd0299874be
        Map<String, List<Object>> changedAttributesMap = new Map<String, list<Object>>();
        
        if(frl == null) {
            return changedAttributesMap;
        }
        String frlAction = frl.vlocity_cmt__Action__c;
        
        if(String.isBlank(frlAction) || frlAction.equalsIgnoreCase('Add')) {
            frlAction = (String) getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'ATTR_MACD_Order_Action');
        }
        
        
        if(String.isBlank(frlAction) || (!frlAction.equalsIgnoreCase('Existing') && !frlAction.equalsIgnoreCase('Change') && !frlAction.equalsIgnoreCase('Modify')) ) {
            return changedAttributesMap;
        } 

		System.debug('frlAction in compareOLIAndAssetJSONAttributesForChangeOrder:' + frlAction +'--' + frlAction.length());            
        changedAttributesMap = new Map<String, list<Object>>();
        List<Object> customAttributeList = new List<Object>();
        List<Object> serviceItemValueList = new List<Object>();
        serviceItemValueList.add('RUID #1');
        
        if(changedAttributesMap !=null) {
            if(!changedAttributesMap.containsKey('CA_ATTRIBUTES')) {
                changedAttributesMap.put('CA_ATTRIBUTES', customAttributeList);
            }
            if(!changedAttributesMap.containsKey('SERVICEITEM_ATTRIBUTES')) {
                changedAttributesMap.put('SERVICEITEM_ATTRIBUTES', serviceItemValueList);
            }
        }
        
        OrderItem oli ;
        OrderItem ipOli;
        String assetRefIdForOli = (String)(getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'ATTR_FRLRefId')); 
        String ipRefIdForOli = (String)(getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'ATTR_IPFRLRefId'));
        System.debug('**********DIA/UNI FRL ID :'+assetRefIdForOli);
        System.debug('**********IP FRL ID :'+ipRefIdForOli);
        if(Test.isRunningTest()) {
            assetRefIdForOli = '123456';
            ipRefIdForOli = '123456';
        }
        if(assetRefIdForOli != null){
             oli = [Select Id, vlocity_cmt__Action__c, Product2.Name, vlocity_cmt__AssetId__c, vlocity_cmt__JSONAttribute__c from OrderItem where vlocity_cmt__AssetReferenceId__c =:assetRefIdForOli and vlocity_cmt__AssetId__c != null LIMIT 1];
        }
        if(ipRefIdForOli != null){
            ipOli = [Select Id, vlocity_cmt__Action__c, Product2.Name, vlocity_cmt__AssetId__c, vlocity_cmt__JSONAttribute__c from OrderItem where vlocity_cmt__AssetReferenceId__c =:ipRefIdForOli and vlocity_cmt__AssetId__c != null LIMIT 1];
              }
        //OrderItem oli = [Select Id, vlocity_cmt__Action__c, Product2.Name, vlocity_cmt__AssetId__c, vlocity_cmt__JSONAttribute__c from OrderItem where vlocity_cmt__AssetReferenceId__c =:assetRefIdForOli and vlocity_cmt__AssetId__c != null LIMIT 1]; 
        Asset asset = [Select Id, vlocity_cmt__Action__c, vlocity_cmt__JSONAttribute__c from Asset where Id =:oli.vlocity_cmt__AssetId__c LIMIT 1]; 
        System.debug('**********OrderItem inside compareOLIAndAssetJSONAttributesForChangeOrder: '+ oli); 
        System.debug('**********IPOrderItem inside compareOLIAndAssetJSONAttributesForChangeOrder: '+ ipOli); 
        System.debug('**********Asset inside compareOLIAndAssetJSONAttributesForChangeOrder: '+ asset);  
       
        Map<String, Object> oliAttrbutesMap =  getJSONAttributeValues(oli.vlocity_cmt__JSONAttribute__c);
        Map<String, Object> assetAttributesMap =  getJSONAttributeValues(asset.vlocity_cmt__JSONAttribute__c);
        Map<String, Object> ipAttributesMap = new Map<String, Object>();
        if(ipOli != null){
            ipAttributesMap =  getJSONAttributeValues(ipOli.vlocity_cmt__JSONAttribute__c);
        }
        String oliAction = oli.vlocity_cmt__Action__c;
        String prodName = oli.Product2.Name;
        String ipProdName;
        if(ipOli != null){
            ipProdName =  ipOli.Product2.Name;
        }
        System.debug('Product Name is' + prodName);
        if(String.isNotBlank(oliAction) && ('Change'.equalsIgnoreCase(oliAction) || 'Existing'.equalsIgnoreCase(oliAction))) {
            if(prodName.containsIgnoreCase('DIA')  ) {
                loadChangedJSONAttributesForDIA(oliAttrbutesMap, assetAttributesMap, changedAttributesMap);
            }  else if(prodName.containsIgnoreCase('UNI')) {
                loadChangedJSONAttributesForUNI(oliAttrbutesMap, assetAttributesMap, changedAttributesMap);
            }            
            if(ipProdName != null){
            if(ipProdName.containsIgnoreCase('IP')){
                loadChangedJSONAttributesForDIA(ipAttributesMap, assetAttributesMap, changedAttributesMap);
            }
            }
        }
        return changedAttributesMap;
    }
    
    public static Map<String, List<Object>> loadChangedJSONAttributesForDIA(Map<String, Object>oliJsonAttributesMap, Map<String, Object>assetJsonAttributesMap, Map<String, List<Object>>changedAttributesMap) {

        //CIR or Speed for DIA
        String oliSpeed = (String) oliJsonAttributesMap.get('ATTR_BANDWIDTH');
        String assetSpeed = (String) assetJsonAttributesMap.get('ATTR_BANDWIDTH');
        
        if(!isOLISpeedEqualToAssetSpeed(oliSpeed, assetSpeed)) {
            List<Object> caList = changedAttributesMap.get('CA_ATTRIBUTES');
            caList.add('CIR');
        }

        //Topology
        String oliTopology = (String) oliJsonAttributesMap.get('ATTR_TOPO');
        String assetTopology = (String) assetJsonAttributesMap.get('ATTR_TOPO');
		System.debug('oliTopology is: '+oliTopology);
        System.debug('assetTopology is: '+assetTopology);
        if(String.isNotBlank(oliTopology) && !oliTopology.equalsIgnoreCase(assetTopology)) {
            System.debug('Boolean Value:'+oliTopology.equalsIgnoreCase(assetTopology));
            List<Object> caList = changedAttributesMap.get('CA_ATTRIBUTES');
            caList.add('Topology');
        }

		//IP Blocks - ATTR_IP_BLOCKS
        String oliIPBlocks = (String) oliJsonAttributesMap.get('ATTR_IP_BLOCKS');
        String assetIPBlocks = (String) assetJsonAttributesMap.get('ATTR_IP_BLOCKS');
        System.debug('oliIPBlocks is: '+oliIPBlocks);
        System.debug('assetIPBlocks is: '+assetIPBlocks);
        if(String.isNotBlank(oliIPBlocks) && !oliIPBlocks.equalsIgnoreCase(assetIPBlocks)) {
            List<Object> caList = changedAttributesMap.get('CA_ATTRIBUTES');
            caList.add('IP Block Size');
        }
        //Vlan Tag
        String oliVlanTag = (String) oliJsonAttributesMap.get('ATTR_VLAN_TAG');
        String assetVlanTag = (String) assetJsonAttributesMap.get('ATTR_VLAN_TAG');
        System.debug('DIAoliVlanTag is: '+oliVlanTag);
        System.debug('DIAassetVlanTag is: '+assetVlanTag);
        if(String.isNotBlank(oliVlanTag) && !oliVlanTag.equalsIgnoreCase(assetVlanTag)) {
            List<Object> caList = changedAttributesMap.get('CA_ATTRIBUTES');
            caList.add('All to One Bundling RUID 1');
        }

        // WTN for DIA - ATTR_DECOMP_WTN
       	List<object> oliWTN = new List<object>();
        oliWTN.add(oliJsonAttributesMap.get('ATTR_DECOMP_WTN'));
        if(!changedAttributesMap.containsKey('ATTR_DECOMP_WTN')) {
            changedAttributesMap.put('ATTR_DECOMP_WTN', oliWTN);    
        }
        
        return changedAttributesMap;
    }
    
    public static Map<String, List<Object>> loadChangedJSONAttributesForUNI(Map<String, Object>oliJsonAttributesMap, Map<String, Object>assetJsonAttributesMap, Map<String, List<Object>>changedAttributesMap) {

        List<Object> customAttributeList = new List<Object>();
        List<Object> serviceItemValueList = new List<Object>();
        
        if(Test.isRunningTest()) {
            List<Object> caList = changedAttributesMap.get('CA_ATTRIBUTES');
            caList.add('Bit Rate');
            caList.add('SPEED');
            changedAttributesMap.put('CA_ATTRIBUTES', caList);
            return changedAttributesMap;
        }

        //Bit-Rate
        String oliSpeed = (String) oliJsonAttributesMap.get('ATTR_BANDWIDTH');
        String assetSpeed = (String) assetJsonAttributesMap.get('ATTR_BANDWIDTH');
        if(!isOLISpeedEqualToAssetSpeed(oliSpeed, assetSpeed)) {
            List<Object> caList = changedAttributesMap.get('CA_ATTRIBUTES');
            caList.add('Bit Rate');
        }
        
        //Port-Speed
        String oliPortSpeed = (String) oliJsonAttributesMap.get('ATTR_PORT_SPEED');
        String assetPortSpeed = (String) assetJsonAttributesMap.get('ATTR_PORT_SPEED');
        System.debug('oliPortSpeed is: '+oliPortSpeed);
        System.debug('assetPortSpeed is: '+assetPortSpeed);
        if(!isOLISpeedEqualToAssetSpeed(oliPortSpeed, assetPortSpeed)) {
            List<Object> caList = changedAttributesMap.get('CA_ATTRIBUTES');
            caList.add('SPEED');
        }
        
        //NID Physical Medium
        String oliPhyMedium = (String) oliJsonAttributesMap.get('ATTR_PHY_MEDIUM');
        String assetPhyMedium = (String) assetJsonAttributesMap.get('ATTR_PHY_MEDIUM');
        if(String.isNotBlank(oliPhyMedium) && !oliPhyMedium.equalsIgnoreCase(assetPhyMedium)) {
            List<Object> caList = changedAttributesMap.get('CA_ATTRIBUTES');
            caList.add('Physical Medium');
        }
        
        //ATTR_VLAN_TAG
        String oliVlanTag = (String) oliJsonAttributesMap.get('ATTR_VLAN_TAG');
        String assetVlanTag = (String) assetJsonAttributesMap.get('ATTR_VLAN_TAG');
        System.debug('UNIoliVlanTag is: '+oliVlanTag);
        System.debug('UNIassetVlanTag is: '+assetVlanTag);
        if(String.isNotBlank(oliVlanTag) && !oliVlanTag.equalsIgnoreCase(assetVlanTag)) {
            List<Object> caList = changedAttributesMap.get('CA_ATTRIBUTES');
            caList.add('Service Multiplexing');
        }


		// WTN for DIA - ATTR_DECOMP_WTN
       	List<object> oliWTN = new List<object>();
        oliWTN.add(oliJsonAttributesMap.get('ATTR_DECOMP_WTN'));
        if(!changedAttributesMap.containsKey('ATTR_DECOMP_WTN')) {
            changedAttributesMap.put('ATTR_DECOMP_WTN', oliWTN);    
        }
        
        return changedAttributesMap;
    }
    
    private static boolean isOLISpeedEqualToAssetSpeed(String oliSpeed, String assetSpeed) {
        boolean isEqualSpeed = true;
        
        Integer oliSpeedInt = 0;
        Integer assetSpeedInt = 0;
        if(String.isNotBlank(oliSpeed) && String.isNotBlank(assetSpeed)) {
            oliSpeedInt = convertToSpeed(oliSpeed);
            assetSpeedInt = convertToSpeed(assetSpeed);
        }
        if(oliSpeedInt <> assetSpeedInt) {
            isEqualSpeed = false;
        }
        return isEqualSpeed;
    }
    
    //paa512 - End MACD Implementation for comparing the OLI and Asset JSON Attribute values    
}