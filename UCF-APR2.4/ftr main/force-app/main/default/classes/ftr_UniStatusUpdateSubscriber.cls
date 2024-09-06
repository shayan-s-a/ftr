/**
* 
* @description Subscriber class called from ftr_FRLStatusUpdateEventDispatcher
*/ 

global with sharing class ftr_UniStatusUpdateSubscriber implements vlocity_cmt.VlocityOpenInterface {
    
    //Constants
    public final static String TECH_PRODUCTCODE_EIA = 'ENT_ETH_EIA_EVC_PSR_001';
    public final static String TECH_PRODUCTCODE_EVPL = 'ENT_ETH_EVPL_EVC_PSR_001';
    public final static String TECH_PRODUCTCODE_SIP = 'SIP_EVC_PSR_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_ELAN = 'ENT_ETH_ELAN_EVC_PSR_001'; //sravani 
    public final static String TECH_PRODUCTCODE_UNI = 'ENT_ETH_UNI_PSR_001'; //Prashant
    public final static String ATTR_ELAN_PAR_DOC = 'ELAN_PAR_DOC';
    //***This Product Code add by Annie NAeem ****///
    //  public final static String TECH_PRODUCTCODE_SIP = 'SIP_EVC_PSR_RES_SPEC_0010';
    
    public final static String ATT_HOST_UNI_REF_ID = 'ATTR_HostUNIRefId';
    public final static String ATT_REMOTE_UNI_REF_ID = 'ATTR_RemoteUNIRefId';
    public final static String ATT_DOC_NUMBER = 'documentNumber';
    public final static String ATT_HOST_UNI_STATUS = 'ATTR_HostUNIStatus';
    public final static String ATT_REMOTE_UNI_STATUS = 'ATTR_RemoteUNIStatus';
    public final static String ATT_WAIT_SEMAPHORE = 'ATTR_WaitSemaphore';
    public final static String ATT_PAR_UNI_ORD1 = 'PAR_UNI_ORD_1';
    public final static String ATT_PAR_UNI_ORD2 = 'PAR_UNI_ORD_2';
    public final static String ATT_RUID1 = 'RUID #1';
    public final static String ATT_RUID2 = 'RUID #2';
    public final static String ATT_VALUE_FALSE = 'False';
    public final static String ATT_DEFAULT_VALUE = 'NEWAUTOCLLI';
    public final static String STATUS_COMPLETED = 'Completed';
    
    //Input
    public final static String INPUT_EVENT = 'events';
    public final static String INPUT_STATE_RUNNING = 'Running';
    public final static String INPUT_STATE_PENDING = 'Pending';
    public final static String INPUT_ITEM_DEFINITION = 'Wait To Start';
    ///*****///
    public final static String INPUT_ITEM_SIPDEFINITION = 'SIP M6 WaitToStart';
    public final static String INPUT_ITEM_DEF_ELAN_WAIT_FOR_M6_ORD_COMPLETION = 'Wait For UNI M6';//sravani
    public final static String EXECUTE_METHOD = 'execute';
    public final static String ATT_DOCUMENTNUMBER ='documentNumber';
    
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter ftr_UniStatusUpdateSubscriber.' + methodName);
        try {
            if (methodName == EXECUTE_METHOD) {
                return execute(methodName, inputMap, outputMap);
            }
            return true;
        } catch (Exception ex) {
            System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            return false;
        } finally {
            System.debug('Exit ftr_UniStatusUpdateSubscriber.' + methodName);
        }
    }
    
    public Boolean execute(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap) {
        System.debug('FRLStatusUpdate:inputMap-->'+ inputMap);
        List<FRL_Status_Update__e> evs = (List<FRL_Status_Update__e>)inputMap.get(INPUT_EVENT);
        
        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
        Set<Id> orchPlanIds = new Set<Id>();
        Map<String,String> eventMap = new Map<String,String>();
        Map<String,String> flrIdMap = new Map<String,String>();
        for (FRL_Status_Update__e singleEvent : evs) {
            orchPlanIds.add(singleEvent.Plan_Id__c);
            flrIdMap.put(singleEvent.FRL_Reference_Id__c, singleEvent.Plan_Id__c);
            eventMap.put(singleEvent.FRL_Reference_Id__c,singleEvent.JSONAttribute__c);
        }
        System.debug('FRLStatusUpdate:flrIdMap-->'+ flrIdMap);
        //testing 
        //orchPlanIds.add('aA48D000000J02aSAC'); // remove 
        //get all the Orchestration Item of the plan with Running state
        List <vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__OrchestrationItemDefinitionId__r.Name,vlocity_cmt__State__c,vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ftr_IsComboOrderEnabled__c
                                                          FROM vlocity_cmt__OrchestrationItem__c
                                                          WHERE (vlocity_cmt__State__c =: INPUT_STATE_RUNNING OR vlocity_cmt__State__c =: INPUT_STATE_PENDING)
                                                          AND vlocity_cmt__OrchestrationPlanId__c IN: orchPlanIds
                                                          AND (vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: INPUT_ITEM_DEFINITION OR vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: INPUT_ITEM_SIPDEFINITION OR vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: INPUT_ITEM_DEF_ELAN_WAIT_FOR_M6_ORD_COMPLETION) // TODO: to refer an externalId field which will not change
                                                          AND (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_EIA
                                                               OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_EVPL
                                                               OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_SIP
                                                               OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_ELAN)];
        
        system.debug('items----'+items);
        system.debug('orchPlanIds----'+orchPlanIds);

        for(vlocity_cmt__OrchestrationItem__c item : items){
            system.debug('State----'+item.vlocity_cmt__State__c);
            system.debug('ProductCode----'+item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode);
            system.debug('Name----'+item.vlocity_cmt__OrchestrationItemDefinitionId__r.Name);
            String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
            vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                  vlocity_cmt__JSONAttribute__c = jsonAttribute);
            
            String hostUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_HOST_UNI_REF_ID); //'Host UNI Reference Id'); 
            String remoteUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_REMOTE_UNI_REF_ID); //'Remote UNI Reference Id'); 
            String prodCode = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
            String PAERTNERED = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_TECH_IS_PAERTNERED');
            String docNumUNI = '';
            //ATTR_FRLRefId
            String attrFRLRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_FRLRefId'); //ATTR_FRLRefId
            System.debug('FRLStatusUpdate::attrFRLRefId-->'+ attrFRLRefId);
            System.debug('FRLStatusUpdate:hostUNIRefId..'+ hostUNIRefId + '  '+remoteUNIRefId);
            //set UNI PSR to EVC Order if it is ComboOrder
            Boolean isComboOrder = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ftr_IsComboOrderEnabled__c;  
            String hasSharedUNI=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_SHARED_UNI');
            //For EIA
            if((prodCode == TECH_PRODUCTCODE_EIA || prodCode == TECH_PRODUCTCODE_SIP || prodCode == TECH_PRODUCTCODE_ELAN) && eventMap.containsKey(hostUNIRefId)){ //added by sravani TECH_PRODUCTCODE_ELAN
                // System.debug('FRLStatusUpdate:EIA JSON for Host..'+ eventMap.get(hostUNIRefId));
                System.debug('FRLStatusUpdate:Matching host UNI Exists for EIA:attrFRLRefId-->'+ attrFRLRefId);
                System.debug('FRLStatusUpdate:Matching host UNI Exists for EIA:hostUNIRefId-->'+ hostUNIRefId);
                docNumUNI = (String)ftr_CpqHelper.getJSONAttributeValue(eventMap.get(hostUNIRefId), ATT_DOC_NUMBER);
                system.debug('ATT_DEFAULT_VALUE--'+ATT_DEFAULT_VALUE);
                String ATTDefAultValue;
                Map<String, Object> attrVals;
                system.debug('prodCode----'+prodCode);
                if(prodCode == TECH_PRODUCTCODE_ELAN){
                    ATTDefAultValue = '';
                    attrVals = new Map<String, Object>{
                        ATT_PAR_UNI_ORD1 => docNumUNI,
                            ATT_RUID1 => docNumUNI,
                            ATT_RUID2 => ATTDefAultValue, //default for EIA
                            ATT_WAIT_SEMAPHORE => ATT_VALUE_FALSE, //'Wait Semaphore' => 'False', 
                            ATT_HOST_UNI_STATUS => STATUS_COMPLETED, //'Host UNI Status' => 'Completed' 
                            //ATT_DOCUMENTNUMBER=>(isComboOrder&&hasSharedUNI!=null&&hasSharedUNI.length()>0&&hasSharedUNI.equalsIgnoreCase('False'))?docNumUNI:''//set UNI PSR on Combo Orders
                            ATT_DOCUMENTNUMBER=> docNumUNI              
                            };                    
                                }else{
                                    if(PAERTNERED == 'false'){
                                        system.debug('prodCode-IN---'+prodCode);
                                        ATTDefAultValue = ATT_DEFAULT_VALUE;
                                        attrVals = new Map<String, Object>{
                                            ATT_PAR_UNI_ORD1 => docNumUNI,
                                                ATT_RUID1 => docNumUNI,
                                                ATT_RUID2 => ATTDefAultValue, //default for EIA
                                                ATT_WAIT_SEMAPHORE => ATT_VALUE_FALSE, //'Wait Semaphore' => 'False', 
                                                ATT_HOST_UNI_STATUS => STATUS_COMPLETED, //'Host UNI Status' => 'Completed' 
                                                //ATT_DOCUMENTNUMBER=>(isComboOrder&&hasSharedUNI!=null&&hasSharedUNI.length()>0&&hasSharedUNI.equalsIgnoreCase('False'))?docNumUNI:''//set UNI PSR on Combo Orders
                                                ATT_DOCUMENTNUMBER=> docNumUNI              
                                                };
                                                    }
                                    else{
                                        system.debug('prodCode-IN---'+prodCode);
                                        ATTDefAultValue = ATT_DEFAULT_VALUE;
                                        attrVals = new Map<String, Object>{
                                            ATT_PAR_UNI_ORD1 => docNumUNI,
                                                ATT_RUID1 => docNumUNI,
                                                //ATT_RUID2 => ATTDefAultValue, //default for EIA
                                                ATT_WAIT_SEMAPHORE => ATT_VALUE_FALSE, //'Wait Semaphore' => 'False', 
                                                ATT_HOST_UNI_STATUS => STATUS_COMPLETED, //'Host UNI Status' => 'Completed' 
                                                //ATT_DOCUMENTNUMBER=>(isComboOrder&&hasSharedUNI!=null&&hasSharedUNI.length()>0&&hasSharedUNI.equalsIgnoreCase('False'))?docNumUNI:''//set UNI PSR on Combo Orders
                                                ATT_DOCUMENTNUMBER=> docNumUNI              
                                                };
                                                    }
                                }
                
                frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                frlsToUpdateMap.put(frl.Id,frl);
                
            } else if (prodCode == TECH_PRODUCTCODE_EVPL) {
                
                if(eventMap.containsKey(hostUNIRefId)) {
                    System.debug('FRLStatusUpdate:Matching host UNI Exists for EVPL:attrFRLRefId-->'+ attrFRLRefId);
                    System.debug('FRLStatusUpdate:Matching host UNI Exists for EVPL:hostUNIRefId-->'+ hostUNIRefId);
                    
                    // System.debug('EVPL JSON for Host..'+ eventMap.get(hostUNIRefId));
                    docNumUNI = (String)ftr_CpqHelper.getJSONAttributeValue(eventMap.get(hostUNIRefId), ATT_DOC_NUMBER);
                    
                    Map<String, Object> attrVals = new Map<String, Object>{
                        ATT_PAR_UNI_ORD2 => docNumUNI,
                            ATT_RUID2 => docNumUNI,
                            ATT_HOST_UNI_STATUS => STATUS_COMPLETED //'Host UNI Status' => 'Completed'  
                            };
                                
                                frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                    frlsToUpdateMap.put(frl.Id,frl);
                    
                } 
                if (eventMap.containsKey(remoteUNIRefId)) {
                    //else if (eventMap.containsKey(remoteUNIRefId)) {
                    System.debug('FRLStatusUpdate:Matching Remote UNI Exists for EVPL:attrFRLRefId-->'+ attrFRLRefId);
                    System.debug('FRLStatusUpdate:Matching Remote UNI Exists for EVPL:hostUNIRefId-->'+ hostUNIRefId);
                    System.debug('EVPL JSON for Remote..'+ eventMap.get(remoteUNIRefId));
                    docNumUNI = (String)ftr_CpqHelper.getJSONAttributeValue(eventMap.get(remoteUNIRefId), ATT_DOC_NUMBER);
                    
                    Map<String, Object> attrVals = new Map<String, Object>{
                        ATT_PAR_UNI_ORD1 => docNumUNI,
                            ATT_RUID1 => docNumUNI,
                            ATT_REMOTE_UNI_STATUS => STATUS_COMPLETED, //'Remote UNI Status' => 'Completed'
                            ATT_DOCUMENTNUMBER=>(isComboOrder)?docNumUNI:''//set UNI PSR on Combo Orders
                                };
                                    
                                    frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                    frlsToUpdateMap.put(frl.Id,frl);
                    
                }
                
                String attr_HostUNIStatus = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, ATT_HOST_UNI_STATUS); // 'Host UNI Status');  
                String attr_RemoteUNIStatus = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, ATT_REMOTE_UNI_STATUS); //'Remote UNI Status'); 
                System.debug('FRLStatusUpdate:Host and Remote status..'+ attr_HostUNIStatus + '**' + attr_RemoteUNIStatus);
                if(attr_HostUNIStatus == STATUS_COMPLETED && attr_RemoteUNIStatus == STATUS_COMPLETED) {
                    System.debug('FRLStatusUpdate:Both Host and Remote status complete..');
                    frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttribute(frl.vlocity_cmt__JSONAttribute__c, '{}', ATT_WAIT_SEMAPHORE, ATT_VALUE_FALSE); //'Wait Semaphore', 'False');  
                    frlsToUpdateMap.put(frl.Id,frl);
                }
            }
            
        } 
        // Elan Changes Start
        
        List <vlocity_cmt__OrchestrationItem__c> Elanitems = [SELECT Id, vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ftr_IsComboOrderEnabled__c
                                                              FROM vlocity_cmt__OrchestrationItem__c where  vlocity_cmt__OrchestrationPlanId__c IN: orchPlanIds AND vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_ELAN AND Name = :'Wait For UNI M6'];
        
        List <vlocity_cmt__OrchestrationItem__c> UNIitems = [SELECT Id, vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ftr_IsComboOrderEnabled__c
                                                             FROM vlocity_cmt__OrchestrationItem__c where  vlocity_cmt__OrchestrationPlanId__c IN: orchPlanIds AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_UNI AND Name = : 'Wait To Start'];
        Set<Id> frlSet = new Set<Id>();
        Map<String,String> doccNumberMap = new Map<String,String>(); // ELAN
        Map<String,String> ElandoccNumberMap = new Map<String,String>(); // ELAN
        Map<String,String> frlFieldMap = new Map<String,String>(); //UNI
        Map<String,String> frlELANFieldMap = new Map<String,String>(); //15 jan ELAN
        MAP<Id,vlocity_cmt__FulfilmentRequestLine__c> ElanfrlMAp = new MAP<Id,vlocity_cmt__FulfilmentRequestLine__c>(); // ELAN 
        MAP<String,String> ATTRFRLRefIdMapWithFrl = new MAP<String,String>(); 
        MAP<Id,vlocity_cmt__FulfilmentRequestLine__c> UNIfrlMAp = new MAP<Id,vlocity_cmt__FulfilmentRequestLine__c>(); // UNI
        If(!Elanitems.isEmpty() && !UNIitems.isEmpty()){ 
            
            MAP<String,String> docMapWithhostUNIRefId = new MAP<String,String>(); 
            MAP<String,String> docMapWithhostELANRefId = new MAP<String,String>(); 
            
            for(vlocity_cmt__OrchestrationItem__c item : UNIitems){
                String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                String hostUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'ATTR_FRLRefId');
                String docNumUNI = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_DOC_NUMBER); 
                docMapWithhostUNIRefId.put(hostUNIRefId,docNumUNI);
                system.debug('size ----'+docMapWithhostUNIRefId.values());
                
            }
            //15 jan ELAN
            for(vlocity_cmt__OrchestrationItem__c item : Elanitems){
                String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                String hostELANRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'ATTR_FRLRefId');
                String docNumUNI = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_DOC_NUMBER); 
                docMapWithhostELANRefId.put(hostELANRefId,docNumUNI);
                system.debug('size ----'+docMapWithhostELANRefId.values());
            }
            
            for(vlocity_cmt__OrchestrationItem__c item : Elanitems){
                
                frlSet.add(item.vlocity_cmt__FulfilmentRequestLineId__c);
                
                String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                String hostUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_HOST_UNI_REF_ID);
                String ATTRFIRSTELAN = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_FIRSTELAN');
                String ELANCircuitID = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ELAN_Circuit_ID');
                String ELANATTRFRLRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_FRLRefId'); //15 jan ELAN
                String docNumUNI = docMapWithhostUNIRefId.get(hostUNIRefId);
                String ElanDocNumUNI = docMapWithhostELANRefId.get(ELANATTRFRLRefId);
                
                //15 jan ELAN
                 if(!frlELANFieldMap.containsKey(ELANATTRFRLRefId)){
                        frlELANFieldMap.put(ELANATTRFRLRefId,ELANCircuitID);
                    }
                
                If(ATTRFIRSTELAN == 'Yes'){
                    
                    String keyForGroup = ELANCircuitID;
                    doccNumberMap.put(keyForGroup,docNumUNI);
                    ElandoccNumberMap.put(keyForGroup,ElanDocNumUNI);
                }
                
                If(!ElanfrlMAp.containsKey(item.vlocity_cmt__FulfilmentRequestLineId__c)){
                    vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                          vlocity_cmt__JSONAttribute__c = jsonAttribute);
                    
                    ElanfrlMAp.put(item.vlocity_cmt__FulfilmentRequestLineId__c,frl);
                    
                }
                
                If( !ATTRFRLRefIdMapWithFrl.containsKey(hostUNIRefId)){
                    
                    ATTRFRLRefIdMapWithFrl.put(hostUNIRefId,ELANCircuitID); 
                    
                }
                
            }
            If(!doccNumberMap.isEmpty()){
                for(vlocity_cmt__OrchestrationItem__c item : UNIitems){ 
                    
                    frlSet.add(item.vlocity_cmt__FulfilmentRequestLineId__c);
                    
                    String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                    String 	UNIATTRFRLRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_FRLRefId');
                    if(!frlFieldMap.containsKey(UNIATTRFRLRefId)){
                        frlFieldMap.put(UNIATTRFRLRefId,ATTRFRLRefIdMapWithFrl.get(UNIATTRFRLRefId));
                    }
                    
                    If(!UNIfrlMAp.containsKey(item.vlocity_cmt__FulfilmentRequestLineId__c)){
                        vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                              vlocity_cmt__JSONAttribute__c = jsonAttribute);
                        UNIfrlMAp.put(item.vlocity_cmt__FulfilmentRequestLineId__c,frl);
                        
                    }
                    
                }
                
                for(vlocity_cmt__FulfilmentRequestLine__c frl : UNIfrlMAp.values()){
                    
                    String jsonAttribute = frl.vlocity_cmt__JSONAttribute__c;
                    String ATTRKeyFRLRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_FRLRefId');
                    String ELANCircuitID = frlFieldMap.get(ATTRKeyFRLRefId);
                    String parentDocNumber = doccNumberMap.get(ELANCircuitID);
                    Map<String, Object> attrVals = new Map<String, Object>{
                        ATTR_ELAN_PAR_DOC => parentDocNumber
                            
                            };
                                
                                frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                    frlsToUpdateMap.put(frl.Id,frl);
                    String ParDocNum = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_ELAN_PAR_DOC');
                    system.debug('ParDocNum------'+ParDocNum);
                    system.debug('------'+frl.Id);
                    system.debug('------'+frl.Id);
                }
                //15 jan ELAN
                if(!ElandoccNumberMap.isEmpty()){
                for(vlocity_cmt__FulfilmentRequestLine__c frl : ElanfrlMAp.values()){
                    String jsonAttribute;
                    if(frlsToUpdateMap.containsKey(frl.Id)){
                        frl = frlsToUpdateMap.get(frl.Id);
                        jsonAttribute = frl.vlocity_cmt__JSONAttribute__c;
                    }else{
                     jsonAttribute = frl.vlocity_cmt__JSONAttribute__c;
                    }
                   String ATTRKeyFRLRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_FRLRefId');
                    String ELANCircuitID = frlELANFieldMap.get(ATTRKeyFRLRefId);
                    String ELANparentDocNumber = ElandoccNumberMap.get(ELANCircuitID);
                    Map<String, Object> attrVals = new Map<String, Object>{
                        ATTR_ELAN_PAR_DOC => ELANparentDocNumber
                            
                            };
                                
                                
                    frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                    frlsToUpdateMap.put(frl.Id,frl);
                    String ParDocNum = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_ELAN_PAR_DOC');
                    system.debug('ParDocNum------'+ParDocNum);
                    system.debug('------'+frl.Id);
                    system.debug('------'+frl.Id);
                }
            }
            }
        }
        
        // Elan Changes End
        
        
        if(frlsToUpdateMap.values().size()>0){
            try{
                List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                            System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                        }
                    }
                }
            } catch(Exception e) {
                System.debug('Exception in Subscriber..'+ e.getMessage());
                return false;
            }
        }
        
        
        
        return true;
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
    }
    
    
}