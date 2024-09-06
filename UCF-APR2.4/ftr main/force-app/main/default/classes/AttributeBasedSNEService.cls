/**
 * @description       : This is a service class for retrieving SNE Codes based on line item configurations.
 *                      Components that go along with this class include:
 *                          - ftr_Attribute_Based_SNE__c (custom object)
 * @author            : eric.marcondes@ftr.com
 * @version           : 2 
**/
global without sharing class AttributeBasedSNEService {
    private static Map<String, String> attrCodeToFieldNameMap;
    private static String[] fieldNames;
    
    static {
        attrCodeToFieldNameMap = new Map<String, String>{
            'ATTR_TECH_JURIS' => 'Jurisdiction__c',
            'ATTR_CONTRACT_TERM' => 'Term__c',
            'ATTR_BANDWIDTH' => 'Speed__c',
            'ATTR_ELIGBL_PARTNRD'=>'ftr_Partnered__c',
            'ATTR_CoS' => 'CoS__c',                     
            'ATTR_IP_BLOCKS' => 'IP_Blocks__c',
            'ATTR_MIN_BLOCKS' => 'MinuteBlocks__c',
            'ATTR_BUYING_OPTION' => 'Purchase_Type__c',
            'ATTR_MAINT_TERM' => 'NBD_Remote_Maint_Term__c',
            'ATTR_COV_PROD' => 'NBD_Remote_Maint_Product__c',
            'ATTR_SDWAN_SPEED' => 'SDWAN_Speed__c',
            'ATTR_SDWAN_HA' => 'High_Availability__c',
            'ATTR_IKE_AWS' => 'IKEv2_VPN__c',
            'ATTR_ROUTER_MODEL'=>'ftr_Router_Model__c',
            'ATTR_INSTANCE_TYPE'=>'ftr_Instance_Type__c',
            'ATTR_ROUTER_INSTALL_TYPE'=>'ftr_Router_Install_Type__c',
            'ATTR_INSTALL_KIT'=>'ftr_Install_Kit_Type__c',
            'ATTR_INC_LD_BOT'=>'ftr_LD_MinuteBlocks__c',
            'ATTR_MULTILOCATION'=>'ftr_Multi_Location__c',
            'ATTR_EVC_SPEED'=>'ftr_EVC_Speed__c',
            'ATTR_RCK_MT_BRACKET'=>'ftr_rck_mt__c',
            'ATTR_FIREWALL'=>'ftr_Firewall_Model__c',
            'ATTR_MF_TRANSCEIVER'=>'ftr_Firewall_Transceiver__c',
            'ATTR_TIME_MNGT'=>'ftr_Firewall_TimeMngt__c'
            
            
        };
        fieldNames = new String[]{
            'SNE_Code_MRC__c',
            'SNE_Code_OTC__c',
            'SNE_Code_Term__c',
            'SF_Product_Code__c',
            'Part_Number__c'
        };
    }
    
    private Id contextId;
    private String productFamily;
    private Set<String> productCodes = new Set<String>();
    private Map<String, Set<String>> attrCodesForKey = new Map<String, Set<String>>();

    global AttributeBasedSNEService(String contextId) {
        this.contextId = contextId;
        this.productFamily = null;
    }

    global AttributeBasedSNEService(String contextId, String productFamily) {
        this.contextId = contextId;
        this.productFamily = productFamily;
    }

    webservice static void updateLineItems(String contextId) {
        AttributeBasedSNEService service = new AttributeBasedSNEService(contextId);
        service.updateLineItems();
    }

    public Map<String, Object> updateLineItems() {
        print('Start', debugLimits());
        Map<String, Object> result = new Map<String, Object> {
            'error' => 'OK'
        };

        try {
            List<SObject> itemsToUpdate = new List<SObject>();

            SObject[] lineItems = getLineItems();
            if (lineItems.size() == 0) {
                result.put('message', 'no line items to update');
                return result;
            }

            for(SObject item : lineItems) {
                productCodes.add((String)item.getSObject('PricebookEntry').getSObject('Product2').get('ProductCode'));
            }

            Map<String, ftr_Attribute_Based_SNE__c> attrBasedSNEMap = getAttrBasedSNEMap();
            print('attrBasedSNEMap', attrBasedSNEMap);
                        
            for(SObject item : lineItems) {

                String sneKey = getItemKey(item);

                if (sneKey == null) continue;

                print('sneKey: '+sneKey, item);

                ftr_Attribute_Based_SNE__c objAttrBasedSNE = attrBasedSNEMap.get(sneKey); 
				system.debug('objAttrBasedSNE'+objAttrBasedSNE);
                if(objAttrBasedSNE != null){
                    item.put('SNE_Code_MRC__c', objAttrBasedSNE.SNE_Code_MRC__c);
                    item.put('SNE_Code_OTC__c', objAttrBasedSNE.SNE_Code_OTC__c);

                    if (contextId.getSObjectType() != Schema.Order.SObjectType) {
                        item.put('SNE_Code_Term__c', objAttrBasedSNE.SNE_Code_TERM__c);
                        item.put('SF_Product_Code__c', objAttrBasedSNE.SF_Product_Code__c);
                        item.put('Part_Number__c', objAttrBasedSNE.Part_Number__c);
                    }
					//Vishu - 061623 - Added code to update SNE term in OLI from create vlocity order omniscript
                    if (contextId.getSObjectType() == Schema.Order.SObjectType) {
                        item.put('SNE_Code_Term__c', objAttrBasedSNE.SNE_Code_TERM__c);
                    }
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
                
            result.put('records', itemsToUpdate);
            result.put('message', 'updated ' + itemsToUpdate.size() + ' line items.');
        } catch (Exception ex) {
            print(ex.getLineNumber(), ex.getMessage());
            result.put('error', ex.getLineNumber() + ': ' + ex.getMessage());
            throw ex;
        } finally {
            print('End', debugLimits());
        }
        return result;
    }

    /**
     * @description :   returns line items based on product families & contextId (Opportunity, Quote, or Order)
     *                  if no family passed in, returns all line items.
     */
    public SObject[] getLineItems() {
        // query line items based on context id and product families
        String query = ' SELECT Id, vlocity_cmt__JSONAttribute__c, PricebookEntry.Product2.ProductCode ';
        if (contextId.getSobjectType() == Schema.Quote.SObjectType) {
            query += ', Quote.IsSyncing__c, Quote.OpportunityId FROM QuoteLineItem WHERE QuoteId =:contextId ';

        } else if (contextId.getSobjectType() == Schema.Order.SObjectType) {
            query += ' FROM OrderItem WHERE OrderId =:contextId ';

        } else if (contextId.getSobjectType() == Schema.Opportunity.SObjectType) {
            query += ' FROM OpportunityLineItem WHERE OpportunityId =:contextId ';

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
    public String getItemKey(SObject lineItem) {
        String productCode = (String) lineItem.getSObject('PricebookEntry').getSObject('Product2').get('ProductCode');
        String[] key = new String[]{ productCode };
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

    /**
     * @description :   returns ftr_Attribute_Based_SNE__c[] based on product codes
     *                  and sets the attribute codes needed for building the attr map key
     */
    public ftr_Attribute_Based_SNE__c[] getAttributeBasedSNERecords() {
        String query = ' SELECT Id, Product_Code__c, ' + String.join(fieldNames, ', ') + ', ' + String.join(attrCodeToFieldNameMap.values(), ', ') + ' FROM ftr_Attribute_Based_SNE__c WHERE Product_Code__c IN :productCodes ';
        return (ftr_Attribute_Based_SNE__c[])Database.query(query);
    }

    /**
     * @description :   builds the map
     */
    public Map<String, ftr_Attribute_Based_SNE__c> getAttrBasedSNEMap() {
        Map<String, ftr_Attribute_Based_SNE__c> attrMap = new Map<String, ftr_Attribute_Based_SNE__c>();
        ftr_Attribute_Based_SNE__c[] absList = getAttributeBasedSNERecords();
        // build a map of attribute codes that will be used for each products key
        for (ftr_Attribute_Based_SNE__c attrBasedSNE : absList) {

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
        for (ftr_Attribute_Based_SNE__c attrBasedSNE : absList) {
            String[] key = new String[]{ attrBasedSNE.Product_Code__c };
            for (String field : attrCodeToFieldNameMap.values()) {
                if (attrBasedSNE.get(field) != null) {
                    key.add((String)attrBasedSNE.get(field));
                }
            }
            attrMap.put(String.join(key, '_'), attrBasedSNE);
        }
        return attrMap;
    }

    public static String debugLimits() {
        return '(Cpu:' + String.valueOf(Limits.getCpuTime()) + ', Query:' + String.valueOf(Limits.getQueries()) + '-' + String.valueOf(Limits.getQueryRows()) + ', DML:' + String.valueOf(Limits.getDMLStatements()) + '-'  + String.valueOf(Limits.getDMLRows()) + ', Heap:' + String.valueOf(Limits.getHeapSize()) + ')';
    }

    public static void print(Object name, Object obj) {
        System.debug(JSON.serialize(name) + ' -> ' + JSON.serialize(obj));
    }
}