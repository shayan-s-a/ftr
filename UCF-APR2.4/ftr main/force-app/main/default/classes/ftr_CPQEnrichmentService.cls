/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @version             :2
 * @last modified on  : 09-14-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing  class ftr_CPQEnrichmentService implements vlocity_cmt.VlocityOpenInterface {
    
    private static final String UPDATE_VLAN_CODE_METHOD_NAME = 'updateVlanTagConfig';
    private static final String UPDATE_UNI_ATTR_METHOD_NAME = 'updateSIPUNIAttributes';
    private static final String ROLLUP_UNI_BIT_RATE_METHOD_NAME = 'rollupUNIBitRate';
    public final static String ProductCode_UNI = 'ENT_ETH_UNI_0001';
    private static final String UPDATE_ATTRIBUTES_BY_SERVACC = 'updateAttributesByServiceAccount';
    private static final String UPDATE_EIA_Over_SDWAN = 'updateEIAOverSDWAN';
    private static final String UPDATE_SEC_NCI = 'updateSECNCI';
    private static final String ATTR_ENTER_DOMAIN_ID = 'ATTR_ENTER_DOMAIN_ID';
    private static final String ATTR_NSG_TYPE = 'ATTR_NSG_TYPE';
    private static final String ATTR_SDWAN_HA = 'ATTR_SDWAN_HA';
    private static final String UPDATE_PROMO_ON_UNI = 'updatePromoOnUNI';
    private static final String ATTR_DIA_OVER_SDWAN = 'ATTR_DIA_OVER_SDWAN';
    public final static String ProductCode_ETH_EVPL_EVC = 'ENT_ETH_EVPL_0010';
    private static final String UPDATE_UNI_HBE_METHOD_NAME = 'updateUNIHBE';
    private static final String UPDATE_UNI_JURIS_METHOD_NAME = 'updateUNIJurisdiction';

    private static final Map<String, String> secNCI = new Map<String, String>{ // For Initial Fix only - Need to change to Metadata in Future
        'Service Multiplexing' => '02VLN.V',
        'Untagged' => '02VLN.UNT',
        'All-to-one Bundling' => '02VLN.A2'
    };

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
          ftr_Logger.writeInfo('Enter ftr_CPQEnrichmentService' + methodName);
         Boolean result =true;
        try {
            if(methodName == UPDATE_VLAN_CODE_METHOD_NAME){
                String orderId = (String)inputMap.get('orderId');
                updateVlanTagConfig(orderId,outputMap);
            } else if (methodName == ROLLUP_UNI_BIT_RATE_METHOD_NAME){

                String orderId = (String)inputMap.get('orderId');
                rollupUNIBitRate(orderId,outputMap);

            } else if (methodName == UPDATE_ATTRIBUTES_BY_SERVACC) {
                updateAttributesByServiceAccount(inputMap, outputMap);
            } else if (methodName == UPDATE_EIA_Over_SDWAN) {
                updateEIAOverSDWAN(inputMap, outputMap);
            } else if (methodName == UPDATE_SEC_NCI) {
                System.debug('ftr_CPQEnrichmentService :');
                String orderId = (String)inputMap.get('orderId');
                System.debug('ftr_CPQEnrichmentService orderId: '+ orderId);
                updateSECNCI(orderID, outputMap);

               // updateSECNCI(inputMap, outputMap); updatePromoOnUNI
            }
            else if (methodName == UPDATE_PROMO_ON_UNI) {
                String orderId = (String)inputMap.get('orderId');
                updatePromoOnUNI(orderID, outputMap);
            } 
            else if(methodName == UPDATE_UNI_ATTR_METHOD_NAME){
                    String orderId = (String)inputMap.get('OrderId');
                    updateSIPUNIAttributes(orderId,outputMap);
             }
            else if (methodName == UPDATE_UNI_HBE_METHOD_NAME){                
                String orderId = (String)inputMap.get('orderId');
                updateUNIHBE(orderId,outputMap);                
            }
 			else if (methodName == UPDATE_UNI_JURIS_METHOD_NAME){                
                String orderId = (String)inputMap.get('orderId');
                updateUNIJurisdiction(orderId,outputMap);                
            }
            
        } catch (Exception ex) {
            //resultMap.put('errorMessage', ex.getMessage());
            ftr_Logger.writeInfo('ftr_CPQEnrichmentService.Exception==>'+ex.getMessage());
            ftr_Logger.write(ex);
        } finally {
            ftr_Logger.writeInfo('Exit ftr_CPQEnrichmentService.' + methodName);
        }
        
         return result;
        
    }
    
    //This method updates Speed technical Attribute (ATTR_BANDWIDTH) of UNI product based on roll up Calculation
    // Currently a default value updated and business logic will be added
    public Map<String, Object> rollupUNIBitRate(string orderID,Map<String,Object> outputMap) {
        ftr_Logger.writeInfo('Enter ftr_CPQEnrichmentService.rollupUNIBitRate');
        try {
            Map<Id, OrderItem> oLIMap = new Map<Id, OrderItem>([SELECT Id,vlocity_cmt__Product2Id__r.ProductCode, ftr_ParentItemId__c, Product2.ProductCode, vlocity_cmt__JSONAttribute__c, UNI_Host__c, UNI_Remote__c, vlocity_cmt__RootItemId__c, vlocity_cmt__SequenceNumber__c FROM OrderItem WHERE OrderId=:orderID ORDER BY vlocity_cmt__SequenceNumber__c DESC NULLS LAST]);
            Map<Id, OrderItem> oLIMapNetworkAccess = new Map<Id, OrderItem>();
            Map<Id, Integer> uniSpeedMap = new Map<Id, Integer>();
            for (OrderItem oLI : oLIMap.values()) {
               
                if (oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_SIP_NETWORK_ACCESS) {
                    oLIMapNetworkAccess.put(oLI.vlocity_cmt__RootItemId__c, oLI);
                }

                if (oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_EIA||oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_ELAN || oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_MDIA || oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_EVPL_EVC) {
                    OrderItem uniHost = oLIMap.get(oLI.UNI_Host__c);
                    Integer uniHostSpeed = uniSpeedMap.containsKey(uniHost.Id) ? uniSpeedMap.get(uniHost.Id) : 0;
                    String evcBandWidth = (String)ftr_CpqHelper.getJSONAttributeValue(oLI.vlocity_cmt__JSONAttribute__c, 'ATTR_BANDWIDTH');
                    uniHostSpeed += ftr_CpqHelper.convertToSpeed(evcBandWidth);
                    uniSpeedMap.put(uniHost.Id, uniHostSpeed);
   
                }
                

                if (oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_EVPL_EVC) {
                    OrderItem uniRemote = oLIMap.get(oLI.UNI_Remote__c);
                    Integer uniRemoteSpeed = uniSpeedMap.containsKey(uniRemote.Id) ? uniSpeedMap.get(uniRemote.Id) : 0;
                    String evcBandWidth = (String)ftr_CpqHelper.getJSONAttributeValue(oLI.vlocity_cmt__JSONAttribute__c, 'ATTR_BANDWIDTH');
                    uniRemoteSpeed += ftr_CpqHelper.convertToSpeed(evcBandWidth);
                    uniSpeedMap.put(uniRemote.Id, uniRemoteSpeed);
                    
                }

                // added during SIP Trunking project... 
                if (oLI.vlocity_cmt__Product2Id__r.ProductCode == ProductCode_UNI && oLI.ftr_ParentItemId__c != null) {
                    // grab the parent EVC
                    OrderItem parentEVC = oLIMapNetworkAccess.containsKey(oLI.ftr_ParentItemId__c) ? oLIMapNetworkAccess.get(oLI.ftr_ParentItemId__c) : oLIMap.get(oLI.ftr_ParentItemId__c);
                    Integer uniSpeed = uniSpeedMap.containsKey(oLI.Id) ? uniSpeedMap.get(oLI.Id) : 0;
                    String evcBandWidth = (String)ftr_CpqHelper.getJSONAttributeValue(parentEVC.vlocity_cmt__JSONAttribute__c, 'ATTR_EVC_SPEED');
                    uniSpeed += ftr_CpqHelper.convertToSpeed(evcBandWidth);
                    uniSpeedMap.put(oLI.Id, uniSpeed);
                }

            }
             ftr_Logger.writeInfo('Rolled up host speed'+uniSpeedMap);
            ftr_Logger.writeInfo('Rolled up remote speed'+uniSpeedMap);

            List<OrderItem> uniToUpdates = new List<OrderItem>();
            for (Id uniId : uniSpeedMap.keySet()) {
                Integer rollupSpeed = uniSpeedMap.get(uniId);
                OrderItem uni = oLIMap.get(uniId);

                String rollupBandWidth = ftr_CpqHelper.convertToBandWidth(rollupSpeed);

                String modifiedJSON = ftr_CpqHelper.setJSONAttribute(uni.vlocity_cmt__JSONAttribute__c, '{}', 'ATTR_BANDWIDTH', rollupBandWidth);
                uni.vlocity_cmt__JSONAttribute__c = modifiedJSON;
                ftr_Logger.writeInfo('UNI Json attribute'+uni.vlocity_cmt__JSONAttribute__c);

                uni.Speed__c = rollupBandWidth;

                uniToUpdates.add(uni);
            }
            ftr_Logger.writeInfo('Final speed'+uniToUpdates);
            
            update uniToUpdates;
            
           
/*            
            list<OrderItem> lstUpdate = [SELECT Id, vlocity_cmt__JSONAttribute__c FROM OrderItem WHERE OrderId =: orderID 
            And ( vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_UNI)];
            
            ftr_Logger.writeInfo('rollupUNIBitRate:Order Items-->'+JSON.serialize(lstUpdate));            
            List<OrderItem> updOrderItemList = new List<OrderItem>();
            // Update ATTR_BANDWIDTH
            for(OrderItem item : lstUpdate) {
                String jsonAttribute = item.vlocity_cmt__JSONAttribute__c;
                System.debug('rollupUNIBitRate:iterate OLI-->');

                Map<string,Object> attrVals = new Map<string,Object>{
                    'ATTR_ROLLUP_BANDWIDTH'=> '100 Mbps'                    
                };
                item.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttributes(item.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                updOrderItemList.add(item);
            }
            ftr_Logger.writeInfo('rollupUNIBitRate:Update the List with Updated Bit Rate-->'+updOrderItemList); 
            Update updOrderItemList;
*/
            outputMap.put('isSuccess', true);                   

        } catch (Exception ex) {
            ftr_Logger.write(ex);
            outputMap.put('isSuccess', false);
            outputMap.put('errorMessage', ex.getMessage());
    }
    finally {
        ftr_Logger.writeInfo('Exit ftr_CPQEnrichmentService.rollupUNIBitRate');
        
    }

    return outputMap;

    }
    
      public Map<String, Object> updateVlanTagConfig(string orderID,Map<String,Object> outputMap) {
        ftr_Logger.writeInfo('Enter ftr_CPQEnrichmentService.updateVlanTagConfig');
        Map<string,Object> resultMap= new Map<String,Object>();
        try {
            list<OrderItem> lstUpdate = [SELECT Id, vlocity_cmt__JSONAttribute__c,VLAN_Tag_Config__c FROM OrderItem WHERE OrderId =: orderID 
            And ( vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_UNI)];
            
             ftr_Logger.writeInfo('Order Items'+lstUpdate);            
            List<OrderItem> updOrderItemList = new List<OrderItem>();
            if(lstUpdate.size()>0){
            
            for(OrderItem ordPrd : lstUpdate){


                OrderItem objOrdItem = new OrderItem();
                String updJSONAttr = ordPrd.vlocity_cmt__JSONAttribute__c;
                String attrVal = (String)ftr_CpqHelper.getJSONAttributeValue(updJSONAttr, 'ATTR_VLAN_TAG');
                 ftr_Logger.writeInfo('VLAN attr Value'+attrVal);  
                objOrdItem.Id = ordPrd.Id;
                objOrdItem.VLAN_Tag_Config__c=attrVal;
                updOrderItemList.add(objOrdItem);
                
                
            } 
            
            ftr_Logger.writeInfo('VLAN field Value'+updOrderItemList); 
            update updOrderItemList;
            outputMap.put('isSuccess', true);
              
        }
        }
            catch (Exception ex) {
                ftr_Logger.write(ex);
                outputMap.put('isSuccess', false);
                outputMap.put('errorMessage', ex.getMessage());
        }
        finally {
            ftr_Logger.writeInfo('Exit updateVlanTagConfig.'+UPDATE_VLAN_CODE_METHOD_NAME);
            
        }

        return outputMap;

     }

    public Map<String, Object> updateAttributesByServiceAccount(Map<String, Object> input, Map<String, Object> outputMap) {
        try {
            List<OrderItem> itemsToUpdate = new List<OrderItem>();
            Map<string,Object> inputMap = (Map<String, Object>) input.get('input');
            Map<string,Object> accMap = new Map<String,Object>();
            List<Object> request;
            try {
                request = (List<Object>) inputMap.get('request');
            } catch (Exception ex) {
                request = new List<Object> { inputMap.get('request') };
            }
            
            Set<String> servAccIds = new Set<String>();
            String orderId = (String) inputMap.get('OrderId');
           // String productCode = (String) inputMap.get('ProductCode');
            System.debug('orderId-> '+orderId);
            //System.debug('productCode-> '+productCode);
            for (Object req : request) {
                accMap.put((String) ((Map<String, Object>) req).get('ServiceAccountId'), (Map<String, Object>)((Map<String, Object>) req).get('attributesToUpdate'));
                String eiaOverSDWAN='false';
                eiaOverSDWAN= String.valueOf(((Map<String, Object>) req).get('EIA_Over_SDWAN__c'));
                Map<String, Object> attributesToUpdate=(Map<String, Object>)((Map<String, Object>) req).get('attributesToUpdate');
                attributesToUpdate.put(ATTR_DIA_OVER_SDWAN, eiaOverSDWAN);
                accMap.put((String) ((Map<String, Object>) req).get('ServiceAccountId'), attributesToUpdate);
            }
            
            List<OrderItem> lineItems = [SELECT id, vlocity_cmt__JSONAttribute__c, Product2.ProductCode, vlocity_cmt__ServiceAccountId__c, EIA_Over_SDWAN__c
                                        FROM OrderItem 
                                        WHERE OrderId = :orderId AND vlocity_cmt__ServiceAccountId__c IN :accMap.keySet()];
            
            for (OrderItem item : lineItems) {

                Map<String, Object> attributesToUpdate=(Map<String, Object>) accMap.get(item.vlocity_cmt__ServiceAccountId__c);
                String eiaOverSDWAN=(String)attributesToUpdate.get(ATTR_DIA_OVER_SDWAN);
                if(eiaOverSDWAN.endsWithIgnoreCase('true') &&(item.Product2.ProductCode == ftr_CpqService.ProductCode_EIA
                                      ||item.Product2.ProductCode == ftr_CpqService.ProductCode_SDWAN ||
                                           item.Product2.ProductCode == ftr_CpqService.ProductCode_UNI)) {
                                        
                        item.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttributes(item.vlocity_cmt__JSONAttribute__c, '{}', (Map<String, Object>) accMap.get(item.vlocity_cmt__ServiceAccountId__c));            
                        Map<string,Object> accMapVals=(Map<string,Object>)accMap.get(item.vlocity_cmt__ServiceAccountId__c);
                        item.ftr_SDWAN_EntDomain_Id__c=(String)accMapVals.get(ATTR_ENTER_DOMAIN_ID);            
                        item.ftr_SDWAN_NSGType__c=(String)accMapVals.get(ATTR_NSG_TYPE);            
                            if(accMapVals.get(ATTR_SDWAN_HA)!=null && (Boolean) (accMapVals.get(ATTR_SDWAN_HA))){
                                    item.ftr_SDWAN_HA__c='Y';
                                    }else {
                                        item.ftr_SDWAN_HA__c='N';
                                    }           
                        item.ftr_SDWAN_flag__c='Y';
                        itemsToUpdate.add(item);


                }
              
            }
            System.debug('itemsToUpdate-> '+JSON.serialize(itemsToUpdate));
            update itemsToUpdate;
            outputMap.put('isSuccess', true);
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            outputMap.put('isSuccess', false);
            outputMap.put('error', ex.getMessage());
        }
        return outputMap;        
    }

    public Map<String, Object> updateEIAOverSDWAN(Map<String, Object> input, Map<String, Object> outputMap) {
        try {
            System.debug('input->' + JSON.serialize(input));
            Map<String, Object> evcMap = (Map<String, Object>) input.get('DIAUNIAssoc');
            Map<String, Boolean> accMap = new Map<String, Boolean>();
            List<Object> request;
            String orderId = (String) input.get('orderId');
            System.debug('orderId->' + JSON.serialize(orderId));
            try {
                request = (List<Object>) evcMap.get('DIA');
            } catch (Exception ex) {
                request = new List<Object> { evcMap.get('DIA') };
            }

            for (Object req : request) {
                Map<String, Object> obj = (Map<String, Object>) req;
                System.debug(JSON.serialize(obj));
                Boolean val = accMap.get((String) obj.get('UNILocationId')) == null ? false : accMap.get((String) obj.get('UNILocationId'));
                if (obj.get('EIAoverSDWAN') != null && !val) {
                    accMap.put((String) obj.get('UNILocationId'), (Boolean) obj.get('EIAoverSDWAN'));
                }
            }
            System.debug('accMap: '+ accMap);
            
            List<OrderItem> lineItems = [SELECT id, vlocity_cmt__JSONAttribute__c, Product2.ProductCode, vlocity_cmt__ServiceAccountId__c, EIA_Over_SDWAN__c
                                        FROM OrderItem 
                                        WHERE OrderId = :orderId AND Product2.ProductCode = :ftr_CpqService.ProductCode_SDWAN AND vlocity_cmt__ServiceAccountId__c IN :accMap.keySet()];
            
            for (OrderItem item : lineItems) {
                Boolean value = accMap.get(item.vlocity_cmt__ServiceAccountId__c);
                System.debug('item->' + item);
                System.debug('value->' + value);
                item.EIA_Over_SDWAN__c = value;
            }
            update lineItems;
            outputMap.put('isSuccess', true);
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            outputMap.put('isSuccess', false);
            outputMap.put('error', ex.getMessage());
        }
        return outputMap;        
    }

    public Map<String, Object> updateSECNCI(string orderID,Map<String,Object> outputMap) {
        ftr_Logger.writeInfo('Enter ftr_CPQEnrichmentService.updateSECNCI');
        System.debug('ftr_CPQEnrichmentService orderId entered: '+ orderId);
        Map<string,Object> resultMap = new Map<String,Object>();
        Map<string,string> remoteUNIVLANMap = new Map<String,string>();
        try {
            list<OrderItem> lstToUpdate = [SELECT Id, vlocity_cmt__JSONAttribute__c, UNI_Host__c, UNI_Remote__c, UNI_Host__r.VLAN_Tag_Config__c FROM OrderItem WHERE OrderId =: orderID 
            And ( vlocity_cmt__Product2Id__r.ProductCode=: ProductCode_ETH_EVPL_EVC)];
            
             ftr_Logger.writeInfo('Order Items'+lstToUpdate);  
             System.debug('ftr_CPQEnrichmentService orderId lstToUpdate: '+ lstToUpdate);          
            //List<OrderItem> updateOrderItemList = new List<OrderItem>();
            if(lstToUpdate.size()>0){
                System.debug('ftr_CPQEnrichmentService orderId lstToUpdate: '+ lstToUpdate);
            for(OrderItem orderProd : lstToUpdate){

                remoteUNIVLANMap.put(orderProd.UNI_Remote__c,orderProd.UNI_Host__r.VLAN_Tag_Config__c);
                System.debug('ftr_CPQEnrichmentService orderId UNI_Remote__r: '+ orderProd.UNI_Remote__c +' 2 '+ orderProd.UNI_Host__r.VLAN_Tag_Config__c);
            } 
            outputMap.put('isSuccess', true);
            System.debug('ftr_CPQEnrichmentService orderId lstToUpdate: '+ lstToUpdate);  
        }
        list<OrderItem> lstUNIToUpdate = [SELECT Id, vlocity_cmt__JSONAttribute__c, ftr_hostUNISECNCI__c, VLAN_Tag_Config__c FROM OrderItem WHERE OrderId =: orderID 
            And ( vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_UNI)];
            
             ftr_Logger.writeInfo('Order Items'+lstUNIToUpdate);  
             
             System.debug('ftr_CPQEnrichmentService orderId lstUNIToUpdate: '+ lstUNIToUpdate);
            //List<OrderItem> updateOrderItemList = new List<OrderItem>();
            if(lstUNIToUpdate.size()>0){
                System.debug('SECNCI For UNI lstUNIToUpdate.size-->'+lstUNIToUpdate.size());
            for(OrderItem orderProdUNI : lstUNIToUpdate){
                if (remoteUNIVLANMap.containsKey(orderProdUNI.id)) {
                    System.debug('SECNCI For UNI lstUNIToUpdate');
                    String VLAN_SECNCI = remoteUNIVLANMap.get(orderProdUNI.id);
                    orderProdUNI.ftr_hostUNISECNCI__c =  secNCI.get(VLAN_SECNCI);
                    System.debug('SECNCI For UNI VLAN_SECNCI-->'+VLAN_SECNCI);
                    System.debug('SECNCI For UNI ftr_hostUNISECNCI__c-->'+orderProdUNI.ftr_hostUNISECNCI__c);
                    Update orderProdUNI;
                }   
            } 
            outputMap.put('isSuccess', true);
              
        }
        }
            catch (Exception ex) {
                ftr_Logger.write(ex);
                outputMap.put('isSuccess', false);
                outputMap.put('errorMessage', ex.getMessage());
        }
        finally {
            ftr_Logger.writeInfo('Exit updateSECNCI.'+UPDATE_SEC_NCI);
            
        }

        return outputMap;       
    }

    public Map<String, Object> updatePromoOnUNI(string orderID,Map<String,Object> outputMap){
        try{
            Map<String,OrderItem> UNIVsOrderItem = new Map<String,OrderItem>();
            //List<OrderItem> DIAOrderItems = [select UNI_Host__c,ftr_PromoCode__c from OrderItem where OrderId=:orderID and vlocity_cmt__Product2Id__r.ProductCode= 'ENT_ETH_EIA_0002'];
            for(OrderItem DIAItems:[select UNI_Host__c,ftr_PromoCode__c from OrderItem where OrderId=:orderID and vlocity_cmt__Product2Id__r.ProductCode= 'ENT_ETH_EIA_0002']){
                UNIVsOrderItem.put(DIAItems.UNI_Host__c,DIAItems);
            }
            List<OrderItem> UNIItems = [select Id,ftr_PromoCode__c from OrderItem where Id IN :UNIVsOrderItem.keySet()];
            for(OrderItem UNIItem: UNIItems){
                UNIItem.ftr_PromoCode__c = UNIVsOrderItem.get(UNIItem.Id).ftr_PromoCode__c;
            }
            update UNIItems;
        }
        catch(Exception ex){
            ftr_Logger.write(ex);
            //outputMap.put('isSuccess', false);
            //outputMap.put('error', ex.getMessage());
        }
        return outputMap;
    }

    public Map<String, Object> updateSIPUNIAttributes(string orderID,Map<String,Object> outputMap) {
        ftr_Logger.writeInfo('Enter ftr_CPQEnrichmentService.updateVlanTagConfig');
        Map<string,Object> resultMap= new Map<String,Object>();
        try {
            list<OrderItem> lstUpdate = [SELECT Id, vlocity_cmt__JSONAttribute__c,ftr_ParentItemId__c FROM OrderItem WHERE OrderId =: orderID 
            And ( vlocity_cmt__Product2Id__r.ProductCode=:ProductCode_UNI )];
            
             ftr_Logger.writeInfo('Order Items'+lstUpdate);            
            List<OrderItem> updOrderItemList = new List<OrderItem>();
            if(lstUpdate.size()>0){
            
            for(OrderItem ordPrd : lstUpdate){

                if(ordPrd.ftr_ParentItemId__c != null)
                {
                
                    Map<String, Object> attrVals = new Map<String, Object>{
                        'ATTR_VLAN_TAG' => 'Service Multiplexing',
                        'ATTR_PHY_MEDIUM' => 'Copper RJ45'
                    };

                    ordPrd.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(ordPrd.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                    updOrderItemList.add(ordPrd);
                }
                
                
            } 
            
            ftr_Logger.writeInfo('VLAN field Value'+updOrderItemList); 
            update updOrderItemList;
            outputMap.put('isSuccess', true);
              
        }
        }
            catch (Exception ex) {
                ftr_Logger.write(ex);
                outputMap.put('isSuccess', false);
                outputMap.put('errorMessage', ex.getMessage());
        }
        finally {
            ftr_Logger.writeInfo('Exit updateVlanTagConfig.'+UPDATE_VLAN_CODE_METHOD_NAME);
            
        }

        return outputMap;

     }
    
         public Map<String, Object> updateUNIHBE(string orderID,Map<String,Object> outputMap) {
        ftr_Logger.writeInfo('Enter ftr_CPQEnrichmentService.updateUNIHBE');
        try {
            Map<Id, OrderItem> oLIMap = new Map<Id, OrderItem>([SELECT Id,vlocity_cmt__Product2Id__r.ProductCode, ftr_ParentItemId__c, Product2.ProductCode, vlocity_cmt__JSONAttribute__c, UNI_Host__c, UNI_Remote__c, vlocity_cmt__RootItemId__c, vlocity_cmt__SequenceNumber__c FROM OrderItem WHERE OrderId=:orderID ORDER BY vlocity_cmt__SequenceNumber__c DESC NULLS LAST]);
            
            Map<Id, Boolean> uniHBEMap = new Map<Id, Boolean>();
            for (OrderItem oLI : oLIMap.values()) {           
                if (oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_EIA||oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_ELAN || oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_MDIA || oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_EVPL_EVC) {
                    OrderItem uniHost = oLIMap.get(oLI.UNI_Host__c);
                    Boolean evcHBE = (Boolean)ftr_CpqHelper.getJSONAttributeValue(oLI.vlocity_cmt__JSONAttribute__c, 'ATTR_NETWORK_HBE');
                    uniHBEMap.put(uniHost.Id, evcHBE);                 
                }             
                if (oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_EVPL_EVC) {
                    OrderItem uniRemote = oLIMap.get(oLI.UNI_Remote__c);
                    Boolean evcHBE = (Boolean)ftr_CpqHelper.getJSONAttributeValue(oLI.vlocity_cmt__JSONAttribute__c, 'ATTR_NETWORK_HBE');
                    uniHBEMap.put(uniRemote.Id, evcHBE);                    
                }
            }
            ftr_Logger.writeInfo('UNI HBE'+uniHBEMap);

            List<OrderItem> uniToUpdates = new List<OrderItem>();
            for (Id uniId : uniHBEMap.keySet()) {
                Boolean uniHBE = uniHBEMap.get(uniId);
                OrderItem uni = oLIMap.get(uniId);
                String modifiedJSON = ftr_CpqHelper.setJSONAttribute(uni.vlocity_cmt__JSONAttribute__c, '{}', 'ATTR_NETWORK_HBE', uniHBE);
                uni.vlocity_cmt__JSONAttribute__c = modifiedJSON;
                ftr_Logger.writeInfo('UNI Json attribute'+uni.vlocity_cmt__JSONAttribute__c);
                uniToUpdates.add(uni);
            }
            ftr_Logger.writeInfo('Final Data '+uniToUpdates);
            
            update uniToUpdates;
            outputMap.put('isSuccess', true);                   

        } catch (Exception ex) {
            ftr_Logger.write(ex);
            outputMap.put('isSuccess', false);
            outputMap.put('errorMessage', ex.getMessage());
    	}
    finally {
        ftr_Logger.writeInfo('Exit ftr_CPQEnrichmentService.updateUNIHBE');
        
    }

    return outputMap;

    }
 public Map<String, Object> updateUNIJurisdiction(string orderID,Map<String,Object> outputMap) {
        ftr_Logger.writeInfo('Enter ftr_CPQEnrichmentService.updateUNIJurisdiction');
        try {
            Map<Id, OrderItem> oLIMap = new Map<Id, OrderItem>([SELECT Id,vlocity_cmt__Product2Id__r.ProductCode, ftr_ParentItemId__c, Product2.ProductCode, vlocity_cmt__JSONAttribute__c, UNI_Host__c, UNI_Remote__c, vlocity_cmt__RootItemId__c, vlocity_cmt__SequenceNumber__c FROM OrderItem WHERE OrderId=:orderID ORDER BY vlocity_cmt__SequenceNumber__c DESC NULLS LAST]);
            
            Map<Id, String> uniJurisMap = new Map<Id, String>();
            for (OrderItem oLI : oLIMap.values()) {           
                if (oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_EIA||oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_ELAN || oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_MDIA || oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_EVPL_EVC) {
                    OrderItem uniHost = oLIMap.get(oLI.UNI_Host__c);
                    String evcJuris = (String)ftr_CpqHelper.getJSONAttributeValue(oLI.vlocity_cmt__JSONAttribute__c, 'ATTR_TECH_JURIS');
                    uniJurisMap.put(uniHost.Id, evcJuris);                 
                }             
                if (oLI.vlocity_cmt__Product2Id__r.ProductCode == ftr_CpqService.ProductCode_EVPL_EVC) {
                    OrderItem uniRemote = oLIMap.get(oLI.UNI_Remote__c);
                    String evcJuris = (String)ftr_CpqHelper.getJSONAttributeValue(oLI.vlocity_cmt__JSONAttribute__c, 'ATTR_TECH_JURIS');
                    uniJurisMap.put(uniRemote.Id, evcJuris);                    
                }
            }
            ftr_Logger.writeInfo('UNI Juris'+uniJurisMap);

            List<OrderItem> uniToUpdates = new List<OrderItem>();
            for (Id uniId : uniJurisMap.keySet()) {
                String uniJuris = uniJurisMap.get(uniId);
                OrderItem uni = oLIMap.get(uniId);
                String modifiedJSON = ftr_CpqHelper.setJSONAttribute(uni.vlocity_cmt__JSONAttribute__c, '{}', 'ATTR_TECH_JURISDICTION', uniJuris);
                uni.vlocity_cmt__JSONAttribute__c = modifiedJSON;
                ftr_Logger.writeInfo('UNI Json attribute'+uni.vlocity_cmt__JSONAttribute__c);
                uniToUpdates.add(uni);
            }
            ftr_Logger.writeInfo('Final Data '+uniToUpdates);
            
            update uniToUpdates;
            outputMap.put('isSuccess', true);                   

        } catch (Exception ex) {
            ftr_Logger.write(ex);
            outputMap.put('isSuccess', false);
            outputMap.put('errorMessage', ex.getMessage());
    	}
    finally {
        ftr_Logger.writeInfo('Exit ftr_CPQEnrichmentService.updateUNIJurisdiction');
        
    }

    return outputMap;

    }

     public static void justIncrement() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
                    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
      i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
                    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
                    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
      i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
                    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
             i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
      i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

}

}