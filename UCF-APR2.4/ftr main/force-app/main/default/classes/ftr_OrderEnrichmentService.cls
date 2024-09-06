/**
* @description webservice callout to ServiceItemRequest L2 interface
* @version :2
*/  
global with sharing class ftr_OrderEnrichmentService{
    private static final String GET_EXCHANGE_DETAILS_METHOD_NAME = 'getExchangeDetails';
    private static final String UPDATE_SNE_ATTRIBUTES_METHOD_NAME = 'UpdateSNEAttributes';
    private static final String UPDATE_ITEM_SEQ_METHOD_NAME = 'updateOrderItemSequence';
    
    public final static String ProductCode_EIA = 'ENT_ETH_EIA_0002';
    public final static String ProductCode_ELAN = 'ENT_ETH_ELAN_0001';
    public final static String ProductCode_SDWAN = 'ENT_ETH_SDWAN_001';
    public final static String ProductCode_EVPL_EVC = 'ENT_ETH_EVPL_0010';
    public final static String ProductCode_EVPL = 'ENT_ETH_EVPL_0002';
    public final static String ProductCode_UNI = 'ENT_ETH_UNI_0001';
    public final static String ProductCode_IP = 'ENT_ETH_IP_0002';
    public final static String ProductCode_ETH_MR = 'ENT_ETH_MR_001';
    public final static String ATTR_PREMIER_ID = 'PREMIER_IND';
    public final static String ATTR_NSG_TYPE = 'ATTR_DIA_MNGD_ROUTER_MODEL';
    public final static String DEFAULT_COMP_IND = '374';
     //MDIA codes
    public final static String ProductCode_MNS = 'ENT_ETH_EIA_003';
    public final static String ProductCode_MNS_MSS = 'ENT_ETH_STD_01';
    public final static String ProductCode_MNS_MSA = 'ENT_ETH_ADV_01';
    public final static String ProductCode_MNS_CELL = 'ENT_ETH_CELL_01';
    public final static String ProductCode_MNS_IND = 'ENT_ETH_WIFI_01';
    public final static String ProductCode_MNS_OUT = 'ENT_ETH_WIFI_02';
    //SIP PRODUCTS 
    public final static String ProductCode_SIP = 'SIP_TRUNKING_0010';
    public final static String ProductCode_SIP_DID = 'SIP_DID_NUMBER_INCLUDED';
    public final static String ProductCode_SIP_NA = 'SIP_NETWORK_ACCESS';
    public final static String ProductCode_SIP_RIC = 'SIP_ROUTER_INSTALL_CHARGE';
    public final static String ProductCode_SIP_MR = 'SIP_MANAGED_ROUTER_001';
    public final static String ProductCode_SIP_RB = 'SIP_RACK_BRACKET';
    public final static String ProductCode_SIP_INK = 'SIP_INSTALL_KIT';
 //// Product For MDN 
    public final static String ProductCode_SIP_DIWD= 'SIP_DIRECT_INWARD_DIALING';
    public final static String ProductCode_SIP_LDBT = 'SIP_LD_BLOCK_OF_TIME_INCLUDED';
    public final static String ProductCode_SIP_ITW = 'SIP_INTL_TALK_TO_WORLD';
    public final static String ProductCode_SIP_TFN = 'SIP_TF_NUMBER';
    public final static String ProductCode_SIP_TFAB = 'SIP_TF_ADDITIONAL_BLOCKS';
    public final static String ProductCode_SIP_LDBOT= 'SIP_LD_BLOCK_OF_TIME';
    
 // Ring Central 
    public final static String ProductCode_PremiumSeat= 'RC_PREMIUM_SEAT';
    public final static String ProductCode_StandardSeat = 'RC_STANDARD_SEAT';
    public final static String ProductCode_CentreB1 = 'RC_CENTREX_B1';
    public final static String ProductCode_EssentialSeat = 'RC_ESSENTIAL_SEAT';
    public final static String ProductCode_BasicSeat  = 'RC_BASIC_SEAT';
 
    //Map<String, Object> resultMap;
    global Map<String, Object> invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
         ftr_Logger.writeInfo('Enter ftr_OrderEnrichmentService.' + methodName);
         Map<string,Object> resultMap= new Map<String,Object>();
        try {
            String orderId = (String)inputMap.get('orderId');
            if (methodName == GET_EXCHANGE_DETAILS_METHOD_NAME) {                          
                resultMap= getExchangeDetails(orderId);
            } else if(methodName == UPDATE_SNE_ATTRIBUTES_METHOD_NAME){

                resultMap= UpdateSNEAttributes(orderId);
            }else if(methodName == UPDATE_ITEM_SEQ_METHOD_NAME){

                resultMap= updateOrderItemSequence(orderId);
            }
        //   resultMap.put('isSuccess', true);
        } catch (Exception ex) { resultMap.put('isSuccess', false); resultMap.put('errorMessage', ex.getMessage()); ftr_Logger.write(ex);
        } finally {
            ftr_Logger.writeInfo('Exit ftr_OrderEnrichmentService.' + methodName);
        }
        ftr_Logger.write('Return Result' +resultMap);
        return resultMap;  
    }

    public Map<String, Object> updateOrderItemSequence(string orderID) {
        ftr_Logger.writeInfo('Enter ftr_OrderEnrichmentService.updateOrderItemSequence-->');
        Map<string,Object> resultMap= new Map<String,Object>();
        try {           
            list<OrderItem> ItemToUpdate = new list<OrderItem>();
            list<OrderItem> lstUpdate = [SELECT Id, vlocity_cmt__JSONAttribute__c 
            FROM OrderItem WHERE OrderId =: orderID 
            And ( vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_EIA or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_EVPL_EVC
            or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_UNI or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_SIP or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_SIP_DIWD or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_MNS
            or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_PremiumSeat or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_StandardSeat or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_CentreB1 or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_EssentialSeat
  or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_ELAN or vlocity_cmt__Product2Id__r.ProductCode =: ProductCode_BasicSeat)];  
            Integer itemCount=lstUpdate.size();
            Integer itemSequence=0;
            for(OrderItem item : lstUpdate) {
                item.ItemSequence__c=itemSequence;
                item.LineItemsCount__c=itemCount;
                ItemToUpdate.add(item);
                itemSequence++;
            } 

            Update ItemToUpdate;
        } catch (Exception ex) { ftr_Logger.write(ex); resultMap.put('isSuccess', false); resultMap.put('errorMessage', ex.getMessage());
        } finally {
            ftr_Logger.writeInfo('Exit ftr_OrderEnrichmentService.updateOrderItemSequence');            
        }
         return  resultMap;   
        
        
        }

          /**
    * @description updating OrderItem.Location_Type__c on Network Access based on corresponding EVPL location
    * @param list of Quote Ids
    */
    public Map<String, Object> getExchangeDetails(string orderID) {
        ftr_Logger.writeInfo('Enter ftr_OrderEnrichmentService.CompanyIndicatorCode');
        Map<string,Object> resultMap= new Map<String,Object>();
        try {
            Map<string, List<OrderItem>> mapOLIUpdate = new  Map<string, List<OrderItem>>();
            //Query Orderline items for wirecenterclli and of the current order - lst
            set<string> setWireCLLI = new set<string>();
            list<OrderItem> lstUpdate = [SELECT Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.WC_CLLI__c FROM OrderItem WHERE OrderId =: orderID 
           And ( vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_EIA or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_EVPL_EVC
            or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_UNI or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_MNS
             or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_SIP
             or vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_ELAN)]; 
            
            //Integer itemCount=lstUpdate.size();
            
            for(OrderItem item : lstUpdate) {
                system.debug('Inside order Line'+item.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.WC_CLLI__c);
                String jsonAttribute = item.vlocity_cmt__JSONAttribute__c;
                String strClli = item.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.WC_CLLI__c;
                System.debug('item.CLLI: ' + strClli);           
                if(strClli != null)
                {
                    String clliKey = strClli+'%';
                    List<OrderItem> itemsByClli = mapOLIUpdate.get(clliKey);
                    if (itemsByClli == null) {
                        itemsByClli = new List<OrderItem>();
                        mapOLIUpdate.put(clliKey, itemsByClli);
                    }
                    itemsByClli.add(item);
                    //Set of unique CLLI to query for Attributes from ftr_psrExchangedetails
                    setWireCLLI.add(strClli+'%');  
                }
            }
            //Query ftr_PSRExchangeDetail__c to retrieve attribute values for the respective CLLIs
            map<string, ftr_PSRExchangeDetail__c> mapPSRExchange = new map<string, ftr_PSRExchangeDetail__c>();
            /* System.debug('Details: ' + JSON.serialize([select  WC_CLLI__c,Company_Indicator_Code__c,NPANXX__c 
                                from ftr_PSRExchangeDetail__c Where WC_CLLI__c like :setWireCLLI])); */
            
            for (ftr_PSRExchangeDetail__c objExchDtls : [select  WC_CLLI__c,Company_Indicator_Code__c,NPANXX__c 
            from ftr_PSRExchangeDetail__c Where WC_CLLI__c like :setWireCLLI]) 
            {
                string strCLLI = objExchDtls.WC_CLLI__c;
                
                mapPSRExchange.put(strCLLI.left(8)+'%', objExchDtls);
            }
            //Update attributes
            list<OrderItem> ItemToUpdate = new list<OrderItem>();
            //Integer itemSequence=0;
            for (string strCLLI:mapOLIUpdate.keyset())
            {

                //List of Order Items with current CLLI
                list<OrderItem> lstItems = mapOLIUpdate.get(strCLLI);
                //Attribute values for the current CLLI
                ftr_PSRExchangeDetail__c objpsrDetails = mapPSRExchange.get(strCLLI);
            for(OrderItem item:lstItems){
                    //setJSONAttributes(String runtimeJSON, String originalJSON, Map<String, Object> attrVals) 
                    String compIndicator='';
                    String npaNxx='';
                    if (objpsrDetails!=null) {
                        compIndicator=string.valueof(objpsrDetails.Company_Indicator_Code__c);
                        npaNxx=objpsrDetails.NPANXX__c;
                    }
                        Map<string,Object> attrVals = new Map<string,Object>{
                            'ATTR_NPA_NXX'=> npaNxx,
                            'ATTR_COMPANY_INDICATOR' => (compIndicator!=null&&compIndicator.length()>0)?compIndicator:DEFAULT_COMP_IND
                            //'ATTR_ItemSequence'=>itemSequence,
                            //'ATTR_ItemCount'=>itemCount
                        };
                    item.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttributes(item.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                    ItemToUpdate.add(item);
                    //itemSequence++;
                }

            }
            Update ItemToUpdate;
            resultMap.put('isSuccess', true);
        } catch (Exception ex) { ftr_Logger.write(ex); resultMap.put('isSuccess', false); resultMap.put('errorMessage', ex.getMessage());
        } finally {
            ftr_Logger.writeInfo('Exit ftr_OrderEnrichmentService.'+GET_EXCHANGE_DETAILS_METHOD_NAME);            
        }
         return  resultMap;       
    }

//

 /*
    * @description updating OrderItem.SNE's as per the relationShip to UniHostToEVPL and EIA Products
    * @param OrderId
*/
    public Map<String, Object> UpdateSNEAttributes(string orderID) {
        ftr_Logger.writeInfo('Enter ftr_OrderEnrichmentService.'+UPDATE_SNE_ATTRIBUTES_METHOD_NAME);
        Map<string,Object> resultMap= new Map<String,Object>(); 
        List<OrderItem> sipInwardDialingList = new List<OrderItem>();       
        Set<String> evplHostUNI = new Set<String>();
        Set<String> diaHostUNI = new Set<String>();
        
        try {
            Map<String,Map<String,Object>> SNEToUpdateMap=new Map <String,Map<String,Object>>();
            Map<String,Map<String,Object>> managedRouterAttr=new Map <String,Map<String,Object>>();
            Map<String,String> prodrelationShipMap=new Map<String,String>();       
            list<OrderItem> ItemToUpdateList = new list<OrderItem>();
            Map<string,Map<String,Object>> ordItemSIPSNEMapByRootItem= new Map<String,Map<String,Object>>();        
            Map<string,Object> ordItemSIPSNEMap= new Map<String,Object>();  
            ftr_AttributeSIPInwardDialing.setAttributeSIPInwardDialing(orderID);
            List<OrderItem> listOrderItem= [SELECT id,vlocity_cmt__rootitemid__c,uni_host__c, vlocity_cmt__ServiceAccountId__c,
                                                SNE_Code_MRC__c,SNE_Code_OTC__c,SNE_Code_TERM__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__EffectiveQuantity__c,
                                                     vlocity_cmt__JSONAttribute__c,vlocity_cmt__Product2Id__r.ProductCode FROM OrderItem Where OrderId=:orderID];
              
        for(OrderItem ordItem:listOrderItem){//START LOOP      
            System.debug('ftr_OrderEnrichmentService Start LOOP'+ordItem.vlocity_cmt__Product2Id__r.ProductCode);

            if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_IP) {
                Map<String,Object>  ordItemIPSNEMap = new Map<string,Object>{
                'IP_SNE_Code_MRC'=> ordItem.SNE_Code_MRC__c,
                'IP_SNE_Code_OTC'=> ordItem.SNE_Code_OTC__c,
                'IP_SNE_Code_TERM'=> ordItem.SNE_Code_TERM__c,
                'IP_OneTimeTotal'=> ordItem.vlocity_cmt__OneTimeCharge__c,
                'IP_RecurringCharge'=> ordItem.vlocity_cmt__RecurringCharge__c,
                'IP_Quantity'=> ordItem.vlocity_cmt__EffectiveQuantity__c
                };

                SNEToUpdateMap.put('IP_'+ordItem.vlocity_cmt__rootitemid__c,ordItemIPSNEMap);   
                prodrelationShipMap.put(ordItem.vlocity_cmt__rootitemid__c,ordItem.Id);    
            }else if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_ETH_MR) {
                
                //COM:Get the JSON Attributes
                String jsonAttribute = ordItem.vlocity_cmt__JSONAttribute__c;
                Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
                String attrPremierID = (String)myAttrVals.get(ATTR_PREMIER_ID);
                String attrIsNSG_TYPE = (String)myAttrVals.get(ATTR_NSG_TYPE);                
                Map<String,Object>  ordItemMRSNEMap = new Map<string,Object>{
                'MR_SNE_Code_MRC'=> ordItem.SNE_Code_MRC__c,                              
                'MR_RecurringCharge'=> ordItem.vlocity_cmt__RecurringCharge__c,
                'MR_Quantity'=> ordItem.vlocity_cmt__EffectiveQuantity__c                
                };
                Map<String,Object>  ordItemMRUNIMap = new Map<string,Object>{
                    ATTR_PREMIER_ID=> attrPremierID,
                    ATTR_NSG_TYPE=> attrIsNSG_TYPE
                };
                managedRouterAttr.put(ordItem.vlocity_cmt__rootitemid__c, ordItemMRUNIMap);                
                SNEToUpdateMap.put('MR_'+ordItem.vlocity_cmt__rootitemid__c,ordItemMRSNEMap);   
                  
            }
            else if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_MNS_MSS) {
                
                //COM:Get the JSON Attributes
                String jsonAttribute = ordItem.vlocity_cmt__JSONAttribute__c;
                Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
                Map<String,Object>  ordItemMRSNEMap = new Map<string,Object>{
                'MSS_SNE_Code_MRC'=> ordItem.SNE_Code_MRC__c,                              
                'MSS_RecurringCharge'=> ordItem.vlocity_cmt__RecurringCharge__c,
                'MSS_Quantity'=> ordItem.vlocity_cmt__EffectiveQuantity__c,
                'MSS_SNE_Code_TERM'=> ordItem.SNE_Code_TERM__c             
                };
                SNEToUpdateMap.put ('MSS_'+ordItem.vlocity_cmt__rootitemid__c,ordItemMRSNEMap);   
            }  
            else if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_MNS_MSA) {
                
                //COM:Get the JSON Attributes
                String jsonAttribute = ordItem.vlocity_cmt__JSONAttribute__c;
                Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
                Map<String,Object>  ordItemMRSNEMap = new Map<string,Object>{
                'MSA_SNE_Code_MRC'=> ordItem.SNE_Code_MRC__c,                              
                'MSA_RecurringCharge'=> ordItem.vlocity_cmt__RecurringCharge__c,
                'MSA_Quantity'=> ordItem.vlocity_cmt__EffectiveQuantity__c,
                'MSA_SNE_Code_TERM'=> ordItem.SNE_Code_TERM__c             
                };
                SNEToUpdateMap.put ('MSA_'+ordItem.vlocity_cmt__rootitemid__c,ordItemMRSNEMap);   
            } 
            else if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_MNS_CELL) {
                
                //COM:Get the JSON Attributes
                String jsonAttribute = ordItem.vlocity_cmt__JSONAttribute__c;
                Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
                Map<String,Object>  ordItemMRSNEMap = new Map<string,Object>{
                'CELL_SNE_Code_MRC'=> ordItem.SNE_Code_MRC__c,                              
                'CELL_RecurringCharge'=> ordItem.vlocity_cmt__RecurringCharge__c,
                'CELL_Quantity'=> ordItem.vlocity_cmt__EffectiveQuantity__c,
                'CELL_SNE_Code_TERM'=> ordItem.SNE_Code_TERM__c             
                };
                SNEToUpdateMap.put ('CELL_'+ordItem.vlocity_cmt__rootitemid__c,ordItemMRSNEMap);   
            } 
            else if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_MNS_IND) {
                
                //COM:Get the JSON Attributes
                String jsonAttribute = ordItem.vlocity_cmt__JSONAttribute__c;
                Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
                Map<String,Object>  ordItemMRSNEMap = new Map<string,Object>{
                'IND_SNE_Code_MRC'=> ordItem.SNE_Code_MRC__c,                              
                'IND_RecurringCharge'=> ordItem.vlocity_cmt__RecurringCharge__c,
                'IND_Quantity'=> ordItem.vlocity_cmt__EffectiveQuantity__c,
                'IND_SNE_Code_TERM'=> ordItem.SNE_Code_TERM__c             
                };
                SNEToUpdateMap.put ('IND_'+ordItem.vlocity_cmt__rootitemid__c,ordItemMRSNEMap);   
            } 
            else if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_MNS_OUT) {
                
                //COM:Get the JSON Attributes
                String jsonAttribute = ordItem.vlocity_cmt__JSONAttribute__c;
                Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
                Map<String,Object>  ordItemMRSNEMap = new Map<string,Object>{
                'OUT_SNE_Code_MRC'=> ordItem.SNE_Code_MRC__c,                              
                'OUT_RecurringCharge'=> ordItem.vlocity_cmt__RecurringCharge__c,
                'OUT_Quantity'=> ordItem.vlocity_cmt__EffectiveQuantity__c,
                'OUT_SNE_Code_TERM'=> ordItem.SNE_Code_TERM__c             
                };
                SNEToUpdateMap.put ('OUT_'+ordItem.vlocity_cmt__rootitemid__c,ordItemMRSNEMap);   
            }           
            else if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_EVPL){

                Map<String,Object>  ordItemEVPLSNEMap = new Map<string,Object>{
                'HostToEVPL'=> 'True',//Its not really a Host Just Preparing Host EVPL detail
                'EVPL_SNE_Code_MRC'=> ordItem.SNE_Code_MRC__c,
                'EVPL_SNE_Code_OTC'=> ordItem.SNE_Code_OTC__c,
                'EVPL_SNE_Code_TERM'=> ordItem.SNE_Code_TERM__c,
                'EVPL_OneTimeTotal'=> ordItem.vlocity_cmt__OneTimeCharge__c,
                'EVPL_RecurringCharge'=> ordItem.vlocity_cmt__RecurringCharge__c,
                'EVPL_Quantity'=> ordItem.vlocity_cmt__EffectiveQuantity__c
                };
                SNEToUpdateMap.put(ordItem.Id,ordItemEVPLSNEMap);                
            }
            else if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_EVPL_EVC){
                //Take the Parent of EVC and then its respective UNIHost and store in a Map                
                prodrelationShipMap.put(ordItem.uni_host__c,ordItem.vlocity_cmt__rootitemid__c); 
                evplHostUNI.add(ordItem.uni_host__c);                       
            } 
            else if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_EIA || ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_MNS){
                ItemToUpdateList.add(ordItem); 
                prodrelationShipMap.put('DIA_'+ordItem.uni_host__c,ordItem.vlocity_cmt__rootitemid__c); 
                diaHostUNI.add(ordItem.uni_host__c);   
                
            }                  
            else if (ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_UNI || ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP){
                ItemToUpdateList.add(ordItem);      

            }
           
           /* ====== Code related to DPI  =======
            else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode.startsWith('SIP_')){
                
                System.debug('ftr_OrderEnrichmentService SIP PRODUCTS MAP SIP_Code_ '+ ordItem.vlocity_cmt__Product2Id__r.ProductCode);
                System.debug('ftr_OrderEnrichmentService SIP PRODUCTS MAP SNE_Code_OTC__c'+ ordItem.SNE_Code_OTC__c);
                System.debug('ftr_OrderEnrichmentService SIP PRODUCTS MAP SNE_Code_OTC__c'+ ordItem.SNE_Code_MRC__c);
                if(ordItemSIPSNEMapByRootItem.size() > 0 && ordItemSIPSNEMapByRootItem.get(ordItem.vlocity_cmt__ServiceAccountId__c) != null){
                    ordItemSIPSNEMap = ordItemSIPSNEMapByRootItem.get(ordItem.vlocity_cmt__ServiceAccountId__c);  
                } else {
                    ordItemSIPSNEMap = new Map<String,Object>();  
                }   
                
                
                System.debug('ftr_OrderEnrichmentService SIP PRODUCTS MAP ordItemSIPSNEMapByRootItem'+ JSON.serialize(ordItemSIPSNEMapByRootItem));
                System.debug('ftr_OrderEnrichmentService SIP PRODUCTS MAP ordItemSIPSNEMap'+ JSON.serialize(ordItemSIPSNEMap));


                if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_NA){
                    if(ordItem.SNE_Code_OTC__c!=null){
                        ordItemSIPSNEMap.put('SIP_Code_NA',ordItem.SNE_Code_OTC__c);
                    }else{
                        ordItemSIPSNEMap.put('SIP_Code_NA',ordItem.SNE_Code_MRC__c);
                    }
                    ordItemSIPSNEMap.put('SIP_NA_RecurringCharge',ordItem.vlocity_cmt__RecurringCharge__c);
                    ordItemSIPSNEMap.put('SIP_CODE_NA_TERM',ordItem.SNE_Code_TERM__c);

                } else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_RIC){
                    ordItemSIPSNEMap.put('SIP_Code_MRINS',ordItem.SNE_Code_OTC__c);
                    ordItemSIPSNEMap.put('SIP_MRINS_OneTimeCharge',ordItem.vlocity_cmt__OneTimeCharge__c);
                    
                } else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_MR){
                    ordItemSIPSNEMap.put('SIP_Code_MR',ordItem.SNE_Code_MRC__c);
                    ordItemSIPSNEMap.put('SIP_MR_RecurringCharge',ordItem.vlocity_cmt__RecurringCharge__c);

                } else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_RB){
                    if(ordItem.SNE_Code_OTC__c!=null){ 
                        ordItemSIPSNEMap.put('SIP_Code_RB',ordItem.SNE_Code_OTC__c);
                        ordItemSIPSNEMap.put('SIP_RM_OneTimeCharge',ordItem.vlocity_cmt__OneTimeCharge__c);

                    }else{
                        ordItemSIPSNEMap.put('SIP_Code_RB',ordItem.SNE_Code_MRC__c);
                    }

                } else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_INK){
                    if(ordItem.SNE_Code_OTC__c!=null){
                        ordItemSIPSNEMap.put('SIP_Code_INSK',ordItem.SNE_Code_OTC__c);
                        ordItemSIPSNEMap.put('SIP_INSK_OneTimeCharge',ordItem.vlocity_cmt__OneTimeCharge__c);
                    }else{
                        ordItemSIPSNEMap.put('SIP_Code_INSK',ordItem.SNE_Code_MRC__c);
                    }

                } else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_DID){ ordItemSIPSNEMap.put('SIP_Code_DID',ordItem.SNE_Code_MRC__c);

                }
              
                else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP){ ordItemSIPSNEMap.put('DIP_SIP_Code_SIPT',ordItem.SNE_Code_MRC__c);

                }
                
                  else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_LDBT){
                    ordItemSIPSNEMap.put('DPI_SIP_Code_LBOTA',ordItem.SNE_Code_MRC__c);

                }
                else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_LDBOT){
                    ordItemSIPSNEMap.put('DIP_SIP_Code_LBOT',ordItem.SNE_Code_MRC__c);

                }
                  else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_TFAB){
                    ordItemSIPSNEMap.put('DPI_SIP_Code_TFAB',ordItem.SNE_Code_MRC__c);

                }
                
                else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_ITW){
                    ordItemSIPSNEMap.put('DPI_SIP_Code_ITW',ordItem.SNE_Code_MRC__c);

                }
                
                else if(ordItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_TFN){
                    ordItemSIPSNEMap.put('DPI_SIP_Code_TFN',ordItem.SNE_Code_MRC__c);

                }

                System.debug('ftr_OrderEnrichmentService SIP PRODUCTS MAP ORDER ITEM ID -> '+ ordItem.Id);
                System.debug('ftr_OrderEnrichmentService SIP PRODUCTS ordItemSIPSNEMap -> '+ ordItemSIPSNEMap);
                if(ordItemSIPSNEMap.size() > 0 ){
                    ordItemSIPSNEMapByRootItem.put(ordItem.vlocity_cmt__ServiceAccountId__c, ordItemSIPSNEMap);
                    SNEToUpdateMap.put('SIP_'+ordItem.vlocity_cmt__ServiceAccountId__c,ordItemSIPSNEMapByRootItem.get(ordItem.vlocity_cmt__ServiceAccountId__c));   
                    System.debug('ftr_OrderEnrichmentService SIP SNEToUpdateMap -> '+ JSON.serialize(SNEToUpdateMap));
                    prodrelationShipMap.put(ordItem.vlocity_cmt__rootitemid__c,ordItem.Id);
                }    
            }  */
            

        }//END LOOP     
       //Prepare the SNE Update for UNIHostToEVPL and EIA
       for(OrderItem orderItem:ItemToUpdateList){
        //Update  ATTR_DECOMP_SharedUNI-->True for EIA which has shared UNI with EVPL Host
        System.debug('ftr_OrderEnrichmentService.orderItem.uni_host__c-->'+orderItem.uni_host__c);
        if ((orderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_EIA || orderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_MNS) && evplHostUNI.contains(orderItem.uni_host__c)){
            
            System.debug('ftr_OrderEnrichmentService.Shared UNI exists for EIA-->'+orderItem.id);
            orderItem.SharedUNI__c='True';          

        }else if (orderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_UNI && 
                              evplHostUNI.contains(orderItem.id)
                                  && diaHostUNI.contains(orderItem.id)){
        //Shared UNI exists
                                    orderItem.SharedUNI__c='True'; 
            //Update the MR attributes to UNI
            if (managedRouterAttr.containsKey(prodrelationShipMap.get('DIA_'+orderItem.Id))){
            Map<String,Object>  mrAttrToUpdate =managedRouterAttr.get(prodrelationShipMap.get('DIA_'+orderItem.Id));
            orderItem.ftr_MR_Premier__c=(String)mrAttrToUpdate.get(ATTR_PREMIER_ID);
               orderItem.ftr_MR_NSG_TYPE__c=(String)mrAttrToUpdate.get(ATTR_NSG_TYPE);
            }

        }else if (orderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_UNI &&
        managedRouterAttr.containsKey(prodrelationShipMap.get('DIA_'+orderItem.Id))){
//            System.debug('ftr_OrderEnrichmentService.orderItem.managedRouterAttr-->'+'DIA_'+orderItem.Id);
            
              Map<String,Object>  mrAttrToUpdate =managedRouterAttr.get(prodrelationShipMap.get('DIA_'+orderItem.Id));
              orderItem.ftr_MR_Premier__c=(String)mrAttrToUpdate.get(ATTR_PREMIER_ID);
              orderItem.ftr_MR_NSG_TYPE__c=(String)mrAttrToUpdate.get(ATTR_NSG_TYPE);
        }
         
        if (prodrelationShipMap.containsKey(orderItem.Id)) {
            //Update Order Item fields      
            System.debug('ftr_OrderEnrichmentService prodrelationShipMap.containsKey -> '+ prodrelationShipMap.get(orderItem.Id));
            System.debug('ftr_OrderEnrichmentService SNEToUpdateMap -> '+ JSON.serialize(SNEToUpdateMap));

           Map<String,Object>  attrVals=(Map<String,Object> )SNEToUpdateMap.get(prodrelationShipMap.get(orderItem.Id));
            Map<String,Object>  attrValsIP=(Map<String,Object> )SNEToUpdateMap.get('IP_'+orderItem.Id);
            Map<String,Object>  attrValsMR=(Map<String,Object> )SNEToUpdateMap.get('MR_'+orderItem.Id);            
            Map<String,Object>  attrValsSIP=(Map<String,Object> )SNEToUpdateMap.get('SIP_'+orderItem.vlocity_cmt__ServiceAccountId__c); 
  	    Map<String,Object>  attrValsMSS=(Map<String,Object> )SNEToUpdateMap.get('MSS_'+orderItem.Id);
            Map<String,Object>  attrValsMSA=(Map<String,Object> )SNEToUpdateMap.get('MSA_'+orderItem.Id);
            Map<String,Object>  attrValsCELL=(Map<String,Object> )SNEToUpdateMap.get('CELL_'+orderItem.Id);
            Map<String,Object>  attrValsIND=(Map<String,Object> )SNEToUpdateMap.get('IND_'+orderItem.Id);
            Map<String,Object>  attrValsOUT=(Map<String,Object> )SNEToUpdateMap.get('OUT_'+orderItem.Id);      
            System.debug('ftr_OrderEnrichmentService UPDATE ORDER ITEM SIP -> '+  JSON.serialize(attrValsSIP));

            if (attrValsIP!=null && !attrValsIP.isEmpty()){

            if (attrValsIP.containsKey('IP_SNE_Code_MRC')){ orderItem.IP_SNE_Code_MRC__c=(String)attrValsIP.get('IP_SNE_Code_MRC');
            }
            if(attrValsIP.containsKey('IP_SNE_Code_OTC')){ orderItem.IP_SNE_Code_OTC__c=(String)attrValsIP.get('IP_SNE_Code_OTC');
            }
            if(attrValsIP.containsKey('IP_SNE_Code_TERM')){ orderItem.IP_SNE_Code_TERM__c=(String)attrValsIP.get('IP_SNE_Code_TERM');
            }
            if(attrValsIP.containsKey('IP_OneTimeTotal')){  orderItem.IP_OneTimeTotal__c=(Decimal)attrValsIP.get('IP_OneTimeTotal');
            }
            if(attrValsIP.containsKey('IP_RecurringCharge')){ orderItem.IP_RecurringCharge__c=(Decimal)attrValsIP.get('IP_RecurringCharge');
            }
            if(attrValsIP.containsKey('IP_Quantity')){ orderItem.IP_Quantity__c=(Decimal)attrValsIP.get('IP_Quantity');
            }          
        }
        if (attrValsMR!=null && !attrValsMR.isEmpty()){
            orderItem.MR_RecurringCharge__c= (attrValsMR.containsKey('MR_RecurringCharge')) ? (Decimal)attrValsMR.get('MR_RecurringCharge') : null;
            orderItem.MR_SNE_Code_MRC__c= (attrValsMR.containsKey('MR_SNE_Code_MRC')) ? (String)attrValsMR.get('MR_SNE_Code_MRC') : null;
            orderItem.MR_Quantity__c= (attrValsMR.containsKey('MR_Quantity')) ? (Decimal)attrValsMR.get('MR_Quantity') : null;
            //if(attrValsMR.containsKey('MR_RecurringCharge')){
            //    orderItem.MR_RecurringCharge__c=(Decimal)attrValsMR.get('MR_RecurringCharge');
            //}
            //if(attrValsMR.containsKey('MR_SNE_Code_MRC')){
            //    orderItem.MR_SNE_Code_MRC__c=(String)attrValsMR.get('MR_SNE_Code_MRC');
            //}
            //if(attrValsMR.containsKey('MR_Quantity')){
           //     orderItem.MR_Quantity__c=(Decimal)attrValsMR.get('MR_Quantity');
           // }
           
        }
      if (attrValsMSS!=null&&!attrValsMSS.isEmpty()){
            if(attrValsMSS.containsKey('MSS_RecurringCharge')){
                orderItem.MSS_RecurringCharge__c=(Decimal)attrValsMSS.get('MSS_RecurringCharge');
            }
            if(attrValsMSS.containsKey('MSS_SNE_Code_MRC')){
                orderItem.MSS_SNE_Code_MRC__c=(String)attrValsMSS.get('MSS_SNE_Code_MRC');
            }
            if(attrValsMSS.containsKey('MSS_Quantity')){
                orderItem.MSS_Quantity__c=(Decimal)attrValsMSS.get('MSS_Quantity');
            }
            if(attrValsMSS.containsKey('MSS_SNE_Code_TERM')){
                orderItem.MSS_SNE_Code_TERM__c=(String)attrValsMSS.get('MSS_SNE_Code_TERM');
            }
        }
        if (attrValsMSA!=null&&!attrValsMSA.isEmpty()){
            if(attrValsMSA.containsKey('MSA_RecurringCharge')){
                orderItem.MSA_RecurringCharge__c=(Decimal)attrValsMSA.get('MSA_RecurringCharge');
            }
            if(attrValsMSA.containsKey('MSA_SNE_Code_MRC')){
                orderItem.MSA_SNE_Code_MRC__c=(String)attrValsMSA.get('MSA_SNE_Code_MRC');
            }
            if(attrValsMSA.containsKey('MSA_Quantity')){
                orderItem.MSA_Quantity__c=(Decimal)attrValsMSA.get('MSA_Quantity');
            }
            if(attrValsMSA.containsKey('MSA_SNE_Code_TERM')){
                orderItem.MSA_SNE_Code_TERM__c=(String)attrValsMSA.get('MSA_SNE_Code_TERM');
            }
        }
 if (attrValsCELL!=null&&!attrValsCELL.isEmpty()){
            if(attrValsCELL.containsKey('CELL_RecurringCharge')){
                orderItem.CELL_RecurringCharge__c=(Decimal)attrValsCELL.get('CELL_RecurringCharge');
            }
            if(attrValsCELL.containsKey('CELL_SNE_Code_MRC')){
                orderItem.CELL_SNE_Code_MRC__c=(String)attrValsCELL.get('CELL_SNE_Code_MRC');
            }
            if(attrValsCELL.containsKey('CELL_Quantity')){
                orderItem.CELL_Quantity__c=(Decimal)attrValsCELL.get('CELL_Quantity');
            }
            if(attrValsCELL.containsKey('CELL_SNE_Code_TERM')){
                orderItem.CELL_SNE_Code_TERM__c=(String)attrValsCELL.get('CELL_SNE_Code_TERM');
            }
        }
        if (attrValsIND!=null&&!attrValsIND.isEmpty()){
            if(attrValsIND.containsKey('IND_RecurringCharge')){
                orderItem.IND_RecurringCharge__c=(Decimal)attrValsIND.get('IND_RecurringCharge');
            }
            if(attrValsIND.containsKey('IND_SNE_Code_MRC')){
                orderItem.IND_SNE_Code_MRC__c=(String)attrValsIND.get('IND_SNE_Code_MRC');
            }
            if(attrValsIND.containsKey('IND_Quantity')){
                orderItem.IND_Quantity__c=(Decimal)attrValsIND.get('IND_Quantity');
            }
            if(attrValsIND.containsKey('IND_SNE_Code_TERM')){
                orderItem.IND_SNE_Code_TERM__c=(String)attrValsIND.get('IND_SNE_Code_TERM');
            }
        }
      if (attrValsOUT!=null&&!attrValsOUT.isEmpty()){
            if(attrValsOUT.containsKey('OUT_RecurringCharge')){
                orderItem.OUT_RecurringCharge__c=(Decimal)attrValsOUT.get('OUT_RecurringCharge');
            }
            if(attrValsOUT.containsKey('OUT_SNE_Code_MRC')){
                orderItem.OUT_SNE_Code_MRC__c=(String)attrValsOUT.get('OUT_SNE_Code_MRC');
            }
            if(attrValsOUT.containsKey('OUT_Quantity')){
                orderItem.OUT_Quantity__c=(Decimal)attrValsOUT.get('OUT_Quantity');
            }
            if(attrValsOUT.containsKey('OUT_SNE_Code_TERM')){
                orderItem.OUT_SNE_Code_TERM__c=(String)attrValsOUT.get('OUT_SNE_Code_TERM');
            }
        }
        if (attrVals!=null && !attrVals.isEmpty()){
            orderItem.EVPL_SNE_Code_MRC__c= (attrVals.containsKey('EVPL_SNE_Code_MRC')) ? (String)attrVals.get('EVPL_SNE_Code_MRC') : null;
           	orderItem.EVPL_SNE_Code_OTC__c=(attrVals.containsKey('EVPL_SNE_Code_OTC')) ? (String)attrVals.get('EVPL_SNE_Code_OTC') : null; 
            orderItem.EVPL_SNE_Code_TERM__c=(attrVals.containsKey('EVPL_SNE_Code_TERM')) ? (String)attrVals.get('EVPL_SNE_Code_TERM') : null;
            orderItem.EVPL_OneTimeTotal__c=(attrVals.containsKey('EVPL_OneTimeTotal')) ? (Decimal)attrVals.get('EVPL_OneTimeTotal') : null;
            orderItem.EVPL_RecurringCharge__c=(attrVals.containsKey('EVPL_RecurringCharge')) ? (Decimal)attrVals.get('EVPL_RecurringCharge') : null;
            orderItem.EVPL_Quantity__c= (attrVals.containsKey('EVPL_Quantity')) ? (Decimal)attrVals.get('EVPL_Quantity') : null;
            orderItem.HostToEVPL__c= (attrVals.containsKey('HostToEVPL')) ? (String)attrVals.get('HostToEVPL') : null;
            //if(attrVals.containsKey('EVPL_SNE_Code_MRC')){
            //    orderItem.EVPL_SNE_Code_MRC__c=(String)attrVals.get('EVPL_SNE_Code_MRC');
            // }
            //if(attrVals.containsKey('EVPL_SNE_Code_OTC')){
            //    orderItem.EVPL_SNE_Code_OTC__c=(String)attrVals.get('EVPL_SNE_Code_OTC');
            //}
            //if(attrVals.containsKey('EVPL_SNE_Code_TERM')){
            //    orderItem.EVPL_SNE_Code_TERM__c=(String)attrVals.get('EVPL_SNE_Code_TERM');
            //}
            //if(attrVals.containsKey('EVPL_OneTimeTotal')){
            //    orderItem.EVPL_OneTimeTotal__c=(Decimal)attrVals.get('EVPL_OneTimeTotal');
            //}
            //if(attrVals.containsKey('EVPL_RecurringCharge')){
            //    orderItem.EVPL_RecurringCharge__c=(Decimal)attrVals.get('EVPL_RecurringCharge');
            //}
           //if(attrVals.containsKey('EVPL_Quantity')){
           //     orderItem.EVPL_Quantity__c=(Decimal)attrVals.get('EVPL_Quantity');
           // }
           // if(attrVals.containsKey('HostToEVPL')){
           //     orderItem.HostToEVPL__c=(String)attrVals.get('HostToEVPL');
           // }
        }
//SIP DPI Related code 

        if (attrValsSIP!=null && !attrValsSIP.isEmpty()){
            if(attrValsSIP.containsKey('SIP_Code_DID')){ orderItem.SIP_Code_DID__c=(String)attrValsSIP.get('SIP_Code_DID');
            }
            if(attrValsSIP.containsKey('DPI_SIP_Code_LBOTA')){ orderItem.SIP_Code_LDBOT__c=(String)attrValsSIP.get('DPI_SIP_Code_LBOTA');
            }
            if(attrValsSIP.containsKey('DPI_SIP_Code_ITW')){ orderItem.SIP_Code_ITW__c=(String)attrValsSIP.get('DPI_SIP_Code_ITW');
            }
            if(attrValsSIP.containsKey('DPI_SIP_Code_TFAB')){ orderItem.SIP_Code_TFAB__c=(String)attrValsSIP.get('DPI_SIP_Code_TFAB');
            }
            if(attrValsSIP.containsKey('DIP_SIP_Code_LBOT')){ orderItem.SIP_Code_LDBT__c=(String)attrValsSIP.get('DIP_SIP_Code_LBOT');
            }
            if(attrValsSIP.containsKey('DPI_SIP_Code_TFN')){ orderItem.SIP_Code_TFN__c=(String)attrValsSIP.get('DPI_SIP_Code_TFN');
            }
            if(attrValsSIP.containsKey('DIP_SIP_Code_SIPT')){ orderItem.SIP_Code_SIPT__c=(String)attrValsSIP.get('DIP_SIP_Code_SIPT');
            }
            if(attrValsSIP.containsKey('SIP_Code_INSK')){ orderItem.SIP_Code_INSK__c=(String)attrValsSIP.get('SIP_Code_INSK');
            }
            if(attrValsSIP.containsKey('SIP_INSK_OneTimeCharge')){ orderItem.SIP_INSK_OneTimeCh__c=(Decimal)attrValsSIP.get('SIP_INSK_OneTimeCharge');
            }
            if(attrValsSIP.containsKey('SIP_Code_MR')){ orderItem.SIP_Code_MR__c=(String)attrValsSIP.get('SIP_Code_MR');
            }
            if(attrValsSIP.containsKey('SIP_Code_MRINS')){ orderItem.SIP_Code_MRINS__c=(String)attrValsSIP.get('SIP_Code_MRINS');
            }
            if(attrValsSIP.containsKey('SIP_Code_NA')){ orderItem.SIP_Code_NA__c=(String)attrValsSIP.get('SIP_Code_NA');
            }
           if(attrValsSIP.containsKey('SIP_Code_RB')){  orderItem.SIP_Code_RB__c=(String)attrValsSIP.get('SIP_Code_RB');
            }
            if(attrValsSIP.containsKey('SIP_RM_OneTimeCharge')){ orderItem.SIP_RMB_OneTimeCharge__c=(Decimal)attrValsSIP.get('SIP_RM_OneTimeCharge');
            }
            if(attrValsSIP.containsKey('SIP_MR_RecurringCharge')){ orderItem.SIP_MR_RecurringCharge__c=(Decimal)attrValsSIP.get('SIP_MR_RecurringCharge');
            }
            if(attrValsSIP.containsKey('SIP_MRINS_OneTimeCharge')){  orderItem.SIP_MRINS_OneTimeCharge__c=(Decimal)attrValsSIP.get('SIP_MRINS_OneTimeCharge');
            }
           if(attrValsSIP.containsKey('SIP_NA_RecurringCharge')){ orderItem.SIP_NA_RecurringCharge__c=(Decimal)attrValsSIP.get('SIP_NA_RecurringCharge');
            }
            if(attrValsSIP.containsKey('SIP_CODE_NA_TERM')){ orderItem.SIP_CODE_NA_TERM__c=(String)attrValsSIP.get('SIP_CODE_NA_TERM');
            }
        }
        
            //orderItem.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttributes(orderItem.vlocity_cmt__JSONAttribute__c, '{}', SNEToUpdateMap.get(prodrelationShipMap.get(orderItem.Id)));            
        }   
     }
     System.debug('ftr_OrderEnrichmentService ITEMS TO UPDATE-->'+ItemToUpdateList);

     Update ItemToUpdateList;
     resultMap.put('isSuccess', true);
        } catch (Exception ex) { ftr_Logger.write(ex); resultMap.put('isSuccess', false); resultMap.put('errorMessage', ex.getMessage());
        } finally {
            ftr_Logger.writeInfo('Exit ftr_OrderEnrichmentService.'+UPDATE_SNE_ATTRIBUTES_METHOD_NAME);            
        }
         return  resultMap;       
    }
    
    public String ringCentralProductCount(Id OrderId){
        
      if(OrderId !=null){
            Integer addOne = 0;
            List<OrderItem> orderItemList = [Select Id,vlocity_cmt__Product2Id__r.Name from OrderItem where Order_Product_Subtype__c  = 'RingCentral' AND SNE_Code_MRC__c !='VP911' AND OrderId=:OrderId];
            if(!orderItemList.isEmpty()){
                for(OrderItem orderItemToll: orderItemList){
                    
                    if(orderItemToll.vlocity_cmt__Product2Id__r.Name == 'Toll Free Number'){
                        addOne = 1;
                    }
                }
                if(orderItemList.size() > 9){
                   
                    Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Network_COE_Non_Complex'];
                     
                    Task dpiCommercialTask = new Task();
                    
                    dpiCommercialTask.Description = 'Order Products are more than 9, please create the Order manually in DPI System';
                    dpiCommercialTask.Subject = 'DPI RC Fallout Task';
                    dpiCommercialTask.OwnerId = myQueue.Id;
                    dpiCommercialTask.WhatId = OrderId;
                    insert dpiCommercialTask;
                     
                }
            }
            return String.valueOf(orderItemList.size() + addOne);
        }
        return '0';
    }
   
}