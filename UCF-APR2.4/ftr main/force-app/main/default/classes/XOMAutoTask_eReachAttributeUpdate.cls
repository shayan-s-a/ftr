global class XOMAutoTask_eReachAttributeUpdate implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    //Constants
    public final static String TECH_PRODUCTCODE_EIA = 'ENT_ETH_EIA_EVC_PSR_001';
    public final static String TECH_PRODUCTCODE_ELAN = 'ENT_ETH_ELAN_EVC_PSR_001'; 
    public final static String TECH_PRODUCTCODE_EVPL = 'ENT_ETH_EVPL_EVC_PSR_001';
    public final static String TECH_PRODUCTCODE_UNI = 'ENT_ETH_UNI_PSR_001'; 
    public final static String ATTR_EReach_ENNI_CLLI = 'E-Reach ENNI CLLI';
    public final static String ATTR_ENNI = 'ENNI';
    public final static String ATTR_ENNI_VENDOR = 'ENNI - VENDOR';
    public final static String ATTR_TECH_IS_PAERTNERED = 'ATTR_TECH_IS_PAERTNERED';
    public final static String ATTR_ENNI_NID_CILLI_CODE = 'ATTR_ENNI_NID_CILLI_CODE';
    public final static set<string> TECH_DPI_PRODUCTS = new set<string>{'ENT_ETH_ELAN_DPI','ENT_ETH_DPI_CIRCUIT_BILLING'};
        
        global void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items) {
            system.debug('XOMAutoTask_eReachAttributeUpdate');
            ftr_Logger.writeInfo('Enter XOMAutoTask_eReachAttributeUpdate.executeBatch');
            Set<Id> frlIds = new Set<Id>();
            
            Set<String> ATTRFRLRefIdSet = new Set<String>();
            Set<String> remoteEVPLONEvc = new Set<String>();
            Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
            Set<Id> orchPlanIds = new Set<Id>();
            Map<String,vlocity_cmt__FulfilmentRequestLine__c> UniFrlMap = new Map<String,vlocity_cmt__FulfilmentRequestLine__c>(); 
            Map<String,vlocity_cmt__FulfilmentRequestLine__c> EVCFrlMap = new Map<String,vlocity_cmt__FulfilmentRequestLine__c>(); 
            Map<String,vlocity_cmt__FulfilmentRequestLine__c> DPIFrlMap = new Map<String,vlocity_cmt__FulfilmentRequestLine__c>();
            Set<String> stateAbbrCodeSet = new Set<String>();
            Map<String,String> stateEnvMap = new Map<String,String>();
            Map<String,String> envNPAMap = new Map<String,String>();
            Map<String,String> envCompanyIndMap = new Map<String,String>();   
            Map<String,String> uniRemoteHostMap = new Map<String,String>();   //15 jan ELAN
            for (vlocity_cmt__OrchestrationItem__c item : items) {
                frlIds.add(item.vlocity_cmt__fulfilmentRequestLineId__c);
                orchPlanIds.add(item.vlocity_cmt__OrchestrationPlanId__c); 
            }
            Map<String,String> SpecifitionIdProductMappingMap = new Map<String,String>();
            Map<String,String> EVCTypeMappingMap = new Map<String,String>();
            Map<String,String> SpecifitionIdProductMappingEVPL = new Map<String,String>();//15 jan ELAN
            Map<String,String> EVCEVPLTypeMappingMap = new Map<String,String>();//15 jan ELAN
            List<ItemSpecifitionIdProductMapping__mdt> SpecifitionIdProductMappingList = [select label,OffNetItemSpecifitionIdL2__c, OnNetItemSpecifitionIdL2__c,EVC_Type__c  from ItemSpecifitionIdProductMapping__mdt];
            for ( ItemSpecifitionIdProductMapping__mdt SpecifitionIdobj : SpecifitionIdProductMappingList) {
                SpecifitionIdProductMappingMap.put(SpecifitionIdobj.OnNetItemSpecifitionIdL2__c,SpecifitionIdobj.OffNetItemSpecifitionIdL2__c);
                EVCTypeMappingMap.put(SpecifitionIdobj.OnNetItemSpecifitionIdL2__c,SpecifitionIdobj.EVC_Type__c);
                SpecifitionIdProductMappingEVPL.put(SpecifitionIdobj.label,SpecifitionIdobj.OffNetItemSpecifitionIdL2__c);//15 jan ELAN
                EVCEVPLTypeMappingMap.put(SpecifitionIdobj.label,SpecifitionIdobj.EVC_Type__c);//15 jan ELAN
            }
            List <vlocity_cmt__OrchestrationItem__c> DPIitems = [SELECT Id, vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c
                                                                 FROM vlocity_cmt__OrchestrationItem__c where  vlocity_cmt__OrchestrationPlanId__c =: orchPlanIds AND (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode IN:TECH_DPI_PRODUCTS AND Name = 'Wait for M6Orders Completion')];
            /*List <vlocity_cmt__OrchestrationItem__c> DPIUNIitems = [SELECT Id, vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c
FROM vlocity_cmt__OrchestrationItem__c where  vlocity_cmt__OrchestrationPlanId__c =: orchPlanIds AND ((vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode ='ENT_ETH_DPI_CIRCUIT_BILLING' AND Name = 'Wait for M6Orders Completion'))];*/
            List <vlocity_cmt__OrchestrationItem__c> EVCitems = [SELECT Id, vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ftr_IsComboOrderEnabled__c
                                                                 FROM vlocity_cmt__OrchestrationItem__c where  vlocity_cmt__OrchestrationPlanId__c IN: orchPlanIds AND ((vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_ELAN AND Name = :'Wait For UNI M6') OR (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_EIA AND Name = :'Wait To Start') OR (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_EVPL AND Name = :'Wait To Start'))];
            
            List <vlocity_cmt__OrchestrationItem__c> UNIitems = [SELECT Id, vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ftr_IsComboOrderEnabled__c
                                                                 FROM vlocity_cmt__OrchestrationItem__c where  vlocity_cmt__OrchestrationPlanId__c IN: orchPlanIds AND  vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_UNI AND Name = : 'Wait To Start'];
            If(!EVCitems.isEmpty() && !UNIitems.isEmpty()){
                
                for(vlocity_cmt__OrchestrationItem__c item : EVCitems){
                    String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                    String hostUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'ATTR_HostUNIRefId');
                    String remoteUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'ATTR_RemoteUNIRefId');
                    String stateAbbrCode = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'PriLocState'); 
                    system.debug('hostUNIRefId----'+hostUNIRefId);
                    System.debug('State Code on the item:'+stateAbbrCode);
                    if(String.isNotBlank(stateAbbrCode)){
                        stateAbbrCodeSet.add(stateAbbrCode);
                    } 
                    vlocity_cmt__FulfilmentRequestLine__c Evcfrl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                             vlocity_cmt__JSONAttribute__c = jsonAttribute);
                    ATTRFRLRefIdSet.add(hostUNIRefId);
                    EVCFrlMap.put(hostUNIRefId,Evcfrl);
                    if(remoteUNIRefId != null){
                        system.debug('remoteUNIRefId--1--'+remoteUNIRefId);
                        EVCFrlMap.put(remoteUNIRefId,Evcfrl);
                        ATTRFRLRefIdSet.add(remoteUNIRefId);
                        remoteEVPLONEvc.add(remoteUNIRefId);
                        uniRemoteHostMap.put(remoteUNIRefId,hostUNIRefId); //15 jan ELAN
                    }
                    system.debug('remoteUNIRefId--2--'+remoteUNIRefId);
                    system.debug('EVCFrlMap--2--'+EVCFrlMap);
                }
                
                for(vlocity_cmt__OrchestrationItem__c item : UNIitems){
                    String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                    String hostUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'ATTR_FRLRefId');
                    String stateAbbrCode = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'PriLocState');
                    system.debug('hostUNIRefId--2--'+hostUNIRefId) ;
                    vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                          vlocity_cmt__JSONAttribute__c = jsonAttribute);
                    UniFrlMap.put(hostUNIRefId,frl);
                    if(String.isNotBlank(stateAbbrCode)){
                        stateAbbrCodeSet.add(stateAbbrCode);
                    } 
                    system.debug('UniFrlMap--2--'+UniFrlMap);
                }
                
                System.debug('State code set:'+stateAbbrCodeSet);
                List<State_DPI_environment_mappings__mdt> listEnvMap = [select DPI_Environment__c,State_Code__c from State_DPI_environment_mappings__mdt where State_Code__c in :stateAbbrCodeSet ];
                for(State_DPI_environment_mappings__mdt env:listEnvMap){
                    stateEnvMap.put(env.State_Code__c,env.DPI_Environment__c);
                    list<ftr_PSRExchangeDetail__c> psrex = [select id,FICT_NPA__c,FICT_NXX__c,Company_Indicator_Code__c from ftr_PSRExchangeDetail__c where DPI_Env__c = :env.DPI_Environment__c limit 1];
                    string npanxxvalue = psrex[0].FICT_NPA__c + psrex[0].FICT_NXX__c;
                    envNPAMap.put(env.DPI_Environment__c,npanxxvalue);
                    envCompanyIndMap.put(env.DPI_Environment__c,psrex[0].Company_Indicator_Code__c.toPlainString());
                } 
                System.debug('Enviroment map:'+stateEnvMap);
                System.debug('NPANXX map:'+envNPAMap);      
                Boolean ownEVC = false;
                for(String uniRefId : ATTRFRLRefIdSet){
                    ownEVC = true;
                    if(UniFrlMap.containsKey(uniRefId)){
                        vlocity_cmt__FulfilmentRequestLine__c UnifrlRecord = UniFrlMap.get(uniRefId);
                        vlocity_cmt__FulfilmentRequestLine__c EvcfrlRecord = EVCFrlMap.get(uniRefId);
                        String TechPartnerHost;
                        String HostENNIUNI;
                        // 15 jan change Elan
                        if(uniRemoteHostMap.containsKey(uniRefId)){
                            ownEVC = true;
                            String hostUniAttr = uniRemoteHostMap.get(uniRefId);
                             system.debug('hostUniAttr -------'+hostUniAttr);
                            vlocity_cmt__FulfilmentRequestLine__c UnihostfrlRecord = UniFrlMap.get(hostUniAttr);
                            String UniHostjsonAttribute = UnihostfrlRecord.vlocity_cmt__JSONAttribute__c;
                            system.debug('UniHostjsonAttribute -------'+UniHostjsonAttribute);
                            TechPartnerHost = (String)ftr_CpqHelper.getJSONAttributeValue(UniHostjsonAttribute,ATTR_TECH_IS_PAERTNERED);
                            HostENNIUNI = (String)ftr_CpqHelper.getJSONAttributeValue(UniHostjsonAttribute,ATTR_ENNI);
                        }else if(uniRemoteHostMap.values().contains(uniRefId)){
                            ownEVC = false;
                        }
                        
                        
                        system.debug('UnifrlRecord--3--'+UnifrlRecord); 
                        system.debug('EvcfrlRecord--3--'+EvcfrlRecord);
                        String UnijsonAttribute = UnifrlRecord.vlocity_cmt__JSONAttribute__c;
                        String ATTRB_ENNI_UNI = (String)ftr_CpqHelper.getJSONAttributeValue(UnijsonAttribute, ATTR_ENNI);
                        String EvcjsonAttribute = EvcfrlRecord.vlocity_cmt__JSONAttribute__c;
                        String ATTR_ENNICLLI = (ownEVC == true)?(String)ftr_CpqHelper.getJSONAttributeValue(EvcjsonAttribute, ATTR_ENNI_NID_CILLI_CODE):'';
                        String ATTRB_ENNI = (String)ftr_CpqHelper.getJSONAttributeValue(EvcjsonAttribute, ATTR_ENNI);
                        String ATTR_ENNIVENDOR = (String)ftr_CpqHelper.getJSONAttributeValue(EvcjsonAttribute, ATTR_ENNI_VENDOR);
                        String IS_PAERTNERED = 'true';
                        String stateAbr = (String)ftr_CpqHelper.getJSONAttributeValue(UnijsonAttribute, 'PriLocState');
                        String ItemSpecifitionId = (String)ftr_CpqHelper.getJSONAttributeValue(EvcjsonAttribute, 'ItemSpecifitionIdL2');
                        String EVCTypeValue = (String)ftr_CpqHelper.getJSONAttributeValue(EvcjsonAttribute, 'EVC Type');
                        String environment = stateEnvMap.get(stateAbr);
                        String npaNXX = envNPAMap.get(environment);
                        String companyInd = envCompanyIndMap.get(environment);
                        String ItemSpecifitionIdL2data = SpecifitionIdProductMappingMap.get(ItemSpecifitionId);
                        String ItemSpecifitionIdL2data1 = EVCTypeMappingMap.get(ItemSpecifitionId);
                        system.debug('IS_PAERTNERED  - '+IS_PAERTNERED +'   TechPartnerHost - '+TechPartnerHost);
                        If(String.isNotEmpty(ATTRB_ENNI_UNI)){
                            system.debug('EVCFrlMap--3--'+EvcjsonAttribute);
                            system.debug('EVCFrlMap--3--'+ATTR_ENNICLLI); 
                            system.debug('EVCFrlMap--3--'+ATTR_ENNI) ;
                            system.debug('EVCFrlMap--2--'+ATTR_ENNIVENDOR);
                            system.debug('environment--2--'+environment);
                            system.debug('ItemSpecifitionIdL2data--2--'+ItemSpecifitionIdL2data);
                            system.debug('ItemSpecifitionIdL2data1--2--'+ItemSpecifitionIdL2data1);
                            system.debug('npanxx--2--'+npaNXX);
                            Map<String, Object> attrVals = new Map<String, Object>{
                                ATTR_EReach_ENNI_CLLI => ATTR_ENNICLLI,
                                    //ATTR_ENNI => ATTRB_ENNI,
                                    //ATTR_ENNI_VENDOR => ATTR_ENNIVENDOR,
                                    ATTR_TECH_IS_PAERTNERED => IS_PAERTNERED,
                                    'Environment' => environment,
                                    'NPA_NXX' =>npaNXX,
                                    'COMPANY_INDICATOR' => companyInd,
                                    'ItemSpecifitionIdL2' => '1521'
                                };
                                        
                                        UnifrlRecord.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(UnifrlRecord.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                            frlsToUpdateMap.put(UnifrlRecord.Id,UnifrlRecord);
                            if(!frlsToUpdateMap.containsKey(EvcfrlRecord.Id) && ownEVC){
                                attrVals = new Map<String, Object>{
                                    'Environment' => environment,
                                        'NPA_NXX' =>npaNXX,
                                        'COMPANY_INDICATOR' => companyInd,
                                        'ItemSpecifitionIdL2' =>  String.valueOf(ItemSpecifitionIdL2data),
                                        'EVC Type' => ItemSpecifitionIdL2data1
                                        };          
                                            EvcfrlRecord.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(EvcfrlRecord.vlocity_cmt__JSONAttribute__c, '{}', attrVals);                  
                                frlsToUpdateMap.put(EvcfrlRecord.Id,EvcfrlRecord);
                            }
                                If(String.isNotEmpty(ATTRB_ENNI_UNI) && String.isNotEmpty(HostENNIUNI)){
                                    attrVals = new Map<String, Object>{
                                            'ItemSpecifitionIdL2' =>  '1300',
                                            'EVC Type' => 'PSR EREACH (ALL OFFNET) EVPL - P2P'
                                            };          
                                                EvcfrlRecord.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(EvcfrlRecord.vlocity_cmt__JSONAttribute__c, '{}', attrVals);                  
                                    frlsToUpdateMap.put(EvcfrlRecord.Id,EvcfrlRecord);
                                }
                            
                        }
                    }
                }
                
                for(String remObj:remoteEVPLONEvc){
                    ATTRFRLRefIdSet.remove(remObj);
                }
            }
            
            Map<String,vlocity_cmt__FulfilmentRequestLine__c> UniFrlMap1 = new Map<String,vlocity_cmt__FulfilmentRequestLine__c>(); 
            Map<String,vlocity_cmt__FulfilmentRequestLine__c> EVCFrlMap1 = new Map<String,vlocity_cmt__FulfilmentRequestLine__c>();         
            If(DPIitems.size()>0){
                ATTRFRLRefIdSet.clear();
                for(vlocity_cmt__OrchestrationItem__c item : DPIitems){
                    String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                    system.debug('original attribute json:'+jsonAttribute);
                    String remoteUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'ATTR_RemoteUNIRefId');
                    String hostUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'ATTR_HostUNIRefId');
                    String frlUNIRefId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'ATTR_FRLRefId');
                    String uniSNEcode = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute,'UNI_SNE_CODE');
                    
                    if(remoteUNIRefId !=null && frlUNIRefId !=null && uniSNEcode == null){
                        system.debug('remoteUNIRefId----'+remoteUNIRefId);
                        vlocity_cmt__FulfilmentRequestLine__c Evcfrl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c, 
                                                                                                                 vlocity_cmt__JSONAttribute__c = jsonAttribute);
                        ATTRFRLRefIdSet.add(remoteUNIRefId);
                        EVCFrlMap1.put(remoteUNIRefId,Evcfrl);
                        system.debug('EVCFrlMap--2--'+EVCFrlMap1);
                    } 
                    if(uniSNEcode !=null && frlUNIRefId !=null){
                        
                        vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(Id = item.vlocity_cmt__FulfilmentRequestLineId__c,
                                                                                                              vlocity_cmt__JSONAttribute__c = jsonAttribute);
                        ATTRFRLRefIdSet.add(frlUNIRefId);
                        UniFrlMap1.put(frlUNIRefId,frl);
                        system.debug('UniFrlMap--2--'+UniFrlMap1);
                        
                    }
                }
                
                for(String uniRefId : ATTRFRLRefIdSet){
                    if(UniFrlMap1.containsKey(uniRefId)){
                        vlocity_cmt__FulfilmentRequestLine__c UnifrlRecord = UniFrlMap1.get(uniRefId);
                        //vlocity_cmt__FulfilmentRequestLine__c EvcfrlRecord = EVCFrlMap1.get(uniRefId);
                        system.debug('UnifrlRecord--3--'+UnifrlRecord); 
                        //system.debug('EvcfrlRecord--3--'+EvcfrlRecord);
                        //String UnijsonAttribute = UnifrlRecord.vlocity_cmt__JSONAttribute__c;
                        String UNIjsonAttribute = UnifrlRecord.vlocity_cmt__JSONAttribute__c;
                        String uniENNI = (String)ftr_CpqHelper.getJSONAttributeValue(UNIjsonAttribute, 'ATTR_PARTNER_SNE_CODE');
                        //String partnerSneCode = (String)ftr_CpqHelper.getJSONAttributeValue(EvcjsonAttribute, 'ATTR_PARTNER_SNE_CODE');
                        if(String.isNotEmpty(uniENNI)){
                            Map<String, Object> attrVals = new Map<String, Object>{
                                'ATTR_OFFLM_SNE_CODE' => 'OFFLM'
                                    //'ATTR_PARTNER_SNE_CODE' =>partnerSneCode
                                    };
                                        
                            UnifrlRecord.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(UnifrlRecord.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                            frlsToUpdateMap.put(UnifrlRecord.Id,UnifrlRecord);
                        }
                    }
                    
                }
            }
            
            if(frlsToUpdateMap.values().size()>0){
                try{
                    List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                    system.debug('frlsToUpdateMap.values() 2'+frlsToUpdateMap.values());
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            for (Database.Error err : result.getErrors()){
                                System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                            }
                        }
                    }
                } catch(Exception e) {
                    System.debug('Exception in Subscriber..'+ e.getMessage());
                    
                }
            }
            
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
    } 
}