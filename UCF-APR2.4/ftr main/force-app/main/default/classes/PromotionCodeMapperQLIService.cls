global class PromotionCodeMapperQLIService implements vlocity_cmt.VlocityOpenInterface{
    public static Map<String, String> attrCodeToFieldNameMap = new Map<String, String>{
            //'ATTR_TECH_JURIS' => 'Jurisdiction__c',
            'ATTR_CONTRACT_TERM' => 'Term__c',
            'ATTR_BANDWIDTH' => 'Speed__c',
            'ATTR_TIER2' => 'Tier__c'
            //'ATTR_IP_BLOCKS' => 'IP_Blocks__c',
            //'ATTR_MIN_BLOCKS' => 'MinuteBlocks__c',
            //'ATTR_BUYING_OPTION' => 'Purchase_Type__c',
            //'ATTR_MAINT_TERM' => 'NBD_Remote_Maint_Term__c',
            //'ATTR_COV_PROD' => 'NBD_Remote_Maint_Product__c',
            //'ATTR_SDWAN_SPEED' => 'SDWAN_Speed__c',
            //'ATTR_SDWAN_HA' => 'High_Availability__c',
            //'ATTR_IKE_AWS' => 'IKEv2_VPN__c',
            //'ATTR_ROUTER_MODEL'=>'ftr_Router_Model__c',
            //'ATTR_INSTANCE_TYPE'=>'ftr_Instance_Type__c',
            //'ATTR_ROUTER_INSTALL_TYPE'=>'ftr_Router_Install_Type__c',
            //'ATTR_INSTALL_KIT'=>'ftr_Install_Kit_Type__c',
            //'ATTR_INC_LD_BOT'=>'ftr_LD_MinuteBlocks__c',
            //'ATTR_MULTILOCATION'=>'ftr_Multi_Location__c',
            //'ATTR_EVC_SPEED'=>'ftr_EVC_Speed__c',
            //'ATTR_RCK_MT_BRACKET'=>'ftr_rck_mt__c',
            //'ATTR_FIREWALL'=>'ftr_Firewall_Model__c',
            //'ATTR_MF_TRANSCEIVER'=>'ftr_Firewall_Transceiver__c',
            //'ATTR_TIME_MNGT'=>'ftr_Firewall_TimeMngt__c'
            
        };
  	public static String[] fieldNames = new String[]{
            'Name',
            'State__c'
        };
    private static Id contextId;
    private static String productFamily;
    private static Set<String> productCodes = new Set<String>();
    private static Map<String,string> ProductVsStateCodes = new Map<String,string>();
    private static Map<String, Set<String>> attrCodesForKey = new Map<String, Set<String>>();
    global Boolean invokeMethod (String methodName,
                                     Map<String, Object> input,
                                     Map<String, Object> output,
                                     Map<String, Object> options)
    {
        try {
            if (methodName == 'updatePromoOnQLI')
            {
                updatePromoOnQLI(input, output, options);
                return true;
            } 
            return true;
        }
        catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex);
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            output.put('Error', ex.getMessage());
            return false;
        }
    }
    
    public static boolean updatePromoOnQLI(Map<String,Object> inputMap,Map<String,Object> outputMap,Map<String,Object> optionsMap){
        try{
            // reading QuoteId from input data
            contextId = (Id)inputMap.get('quoteId');
			List<SObject> itemsToUpdate = new List<SObject>();

            SObject[] lineItems = getLineItems();
            if (lineItems.size() == 0) {
                outputMap.put('message', 'no line items to update');
                //return result;
            }   
            for(SObject item : lineItems) {
                productCodes.add((String)item.getSObject('PricebookEntry').getSObject('Product2').get('ProductCode'));
                //ProductVsStateCodes.put((String)item.getSObject('PricebookEntry').getSObject('Product2').get('ProductCode'),(String)item.getSObject('Account').get('ShippingStateCode'));
            }
            system.debug('productCodes'+productCodes);
            
            /*for(SObject item : lineItems) {
                StateCodes.add((String)item.getSObject('Account').get('ShippingStateCode'));
            }*/

            Map<String, ftr_PromotionCodeMapping__c> attrBasedSNEMap = getAttrBasedSNEMap();
            
                         
            for(SObject item : lineItems) {

                String sneKey = getItemKey(item);
                if (sneKey == null) continue;
                ftr_PromotionCodeMapping__c objAttrBasedSNE = attrBasedSNEMap.get(sneKey);       

                if(objAttrBasedSNE != null){
                    item.put('ftr_PromoCode__c', objAttrBasedSNE.Name);

                    itemsToUpdate.add(item);
                }
            }
            if (itemsToUpdate.size() > 0) {
                update itemsToUpdate;

                if (contextId.getSObjectType() == Schema.Quote.SObjectType) {
                    // if the quote is synced, make sure the opp gets synced.
                    if ((Boolean)itemsToUpdate[0].getSObject('Quote').get('IsSyncing__c') == true && itemsToUpdate[0].getSObject('Quote').get('OpportunityId') != null) {
                        QuoteSyncService.Sync(new Quote(
                            Id = contextId, 
                            OpportunityId = (Id)itemsToUpdate[0].getSObject('Quote').get('OpportunityId')
                        ));
                    }
                }
            }
        }
        catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex);
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            outputMap.put('Error', ex.getMessage());
            return false;
        }
        return true;
    }
    
    /**
     * @description :   returns ftr_PromotionCodeMapping__c[] based on product codes
     *                  and sets the attribute codes needed for building the attr map key
     */
    public static ftr_PromotionCodeMapping__c[] getAttributeBasedSNERecords() {
        String query = ' SELECT Id, Product_Code__c, '  + String.join(fieldNames, ', ') + ', ' + String.join(attrCodeToFieldNameMap.values(), ', ') + ' FROM ftr_PromotionCodeMapping__c WHERE Product_Code__c IN :productCodes ';
        return (ftr_PromotionCodeMapping__c[])Database.query(query);
    }
    
    /**
     * @description :   builds the map
     */
    public static Map<String, ftr_PromotionCodeMapping__c> getAttrBasedSNEMap() {
        Map<String, ftr_PromotionCodeMapping__c> attrMap = new Map<String, ftr_PromotionCodeMapping__c>();
        ftr_PromotionCodeMapping__c[] absList = getAttributeBasedSNERecords();
        // build a map of attribute codes that will be used for each products key
        for (ftr_PromotionCodeMapping__c attrBasedSNE : absList) {

            for (String attrCode : attrCodeToFieldNameMap.keySet()) {
                String fieldName = attrCodeToFieldNameMap.get(attrCode);
                if (attrBasedSNE.get(fieldName) != null) {
                    String productCode = (String) attrBasedSNE.get('Product_Code__c');
                    if (attrCodesForKey.containsKey(productCode))
                        attrCodesForKey.get(productCode).add(attrCode);
                    else 
                        attrCodesForKey.put(productCode, new Set<String>{ attrCode });
                }
            }
        }
        // build a map of attribute Based SNE records by its configuration, built as a key
        for (ftr_PromotionCodeMapping__c attrBasedSNE : absList) {
            String[] key = new String[]{ attrBasedSNE.Product_Code__c,attrBasedSNE.State__c };
            for (String field : attrCodeToFieldNameMap.values()) {
                if (attrBasedSNE.get(field) != null) {
                    key.add((String)attrBasedSNE.get(field));
                }
            }
            system.debug('key formed'+String.join(key, '_'));
            attrMap.put(String.join(key, '_'), attrBasedSNE);
        }
        return attrMap;
    }

    /**
     * @description :   returns line items based on product families & contextId (Opportunity, Quote, or Order)
     *                  if no family passed in, returns all line items.
     */
    public static SObject[] getLineItems() {
        // query line items based on context id and product families
        String query = ' SELECT Id, vlocity_cmt__JSONAttribute__c, PricebookEntry.Product2.ProductCode,vlocity_cmt__ServiceAccountId__r.ShippingStateCode ';
        if (contextId.getSobjectType() == Schema.Quote.SObjectType) {
            query += ', Quote.IsSyncing__c, Quote.OpportunityId FROM QuoteLineItem WHERE QuoteId =:contextId ';

        }
        if (productFamily != null) {
            String[] productFamilies = productFamily.split(',');
            query += ' AND PricebookEntry.Product2.Family IN :productFamilies ';
        }
        return Database.query(query);
    }
    
    
/**
     * @description :   returns the key for a given line item
     */
    public static String getItemKey(SObject lineItem) {
        String productCode = (String) lineItem.getSObject('PricebookEntry').getSObject('Product2').get('ProductCode');
        String StateCode;
        if(lineItem.get('vlocity_cmt__ServiceAccountId__c')!=null){
            //system.debug('sObject Data'+lineItem.getSObject('vlocity_cmt__ServiceAccountId__r').get('ShippingStateCode'));
            //Map<String,String> getAccountDetails = (Map<String,String>)lineItem.get('vlocity_cmt__ServiceAccountId__c');
        	StateCode = (String)lineItem.getSObject('vlocity_cmt__ServiceAccountId__r').get('ShippingStateCode');
        }
        //String StateCode = (String)lineItem.getSObject('Account').get('ShippingStateCode');
        String[] key = new String[]{ productCode,StateCode };
        if (attrCodesForKey.get(productCode) == null) 
            return productCode;
        for (String attrCode : attrCodesForKey.get(productCode)) {
            Object attrVal;
            try {
                attrVal = (String)ftr_CpqHelper.getJSONAttributeValue((String)lineItem.get('vlocity_cmt__JSONAttribute__c'), attrCode);
            } catch (TypeException ex) {
                attrVal = (Boolean)ftr_CpqHelper.getJSONAttributeValue((String)lineItem.get('vlocity_cmt__JSONAttribute__c'), attrCode) == true ? 'YES' : 'NO';
            }
            key.add(String.valueOf(attrVal));
        }
        return String.join(key, '_');
    }
    
    @TestVisible
    public class PromotionRequest{
        @InvocableVariable
        public String quoteId;
        
    }
    
    @InvocableMethod(label='Update Promotion')
    public static void InvokePromotionUpdate(List<PromotionRequest> PromotionRequestData){
        Map<String,Object> inputMap = new Map<String,Object>{'quoteId'=>PromotionRequestData.get(0).quoteId};
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> optionsMap = new Map<String,Object>();
        String MethodName = 'updatePromoOnQLI';
        PromotionCodeMapperQLIService obj = new PromotionCodeMapperQLIService();
        obj.invokeMethod(MethodName,inputMap,outMap,optionsMap);
    }

}