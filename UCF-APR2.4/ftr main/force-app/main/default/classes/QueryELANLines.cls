global with sharing  class QueryELANLines implements vlocity_cmt.VlocityOpenInterface  {
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        Boolean result =true;
        try {
            if(methodName == 'QueryELANLines'){
                QueryELANLines(inputMap,outputMap,options);                
            }            
        }
        catch (Exception ex) {
            //resultMap.put('errorMessage', ex.getMessage());
            ftr_Logger.writeInfo('QueryELANLines.Exception==>'+ex.getMessage());
            ftr_Logger.write(ex);
        } finally {
            ftr_Logger.writeInfo('Exit QueryELANLines.' + methodName);
        }  return result; 
    }
    public Map<String, Object> QueryELANLines(Map<String,Object> inputmap,Map<String,Object> outputMap, Map<String,Object> Options) {
        
        String OrderId = (String)inputmap.get('ContextId');
        
        System.debug('The input map incoming'+inputmap);
        String DRName = 'QueryELANLines_V1';
        List<Map<String, Object>> iteratedlist = new List<Map<String, Object>>();
        list<map<string, object>> updateelanlist = new list<map<string, object>>();
        Set<Boolean> hbeflagSet = new Set<Boolean>();
        Boolean hasHbeELAN;
        Integer counter =1;
        String slahub1='SLA HUB 1',slahub2='SLA HUB 2',slaremote='SLA Remote',slaLegacy='Legacy';
        Boolean SEEnrichmentDone=false;

        Map<String, Object> myTransformData = new Map<String, Object>{'OrderId'=>OrderId};     
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(myTransformData, DRName);
        Map<String, Object> resultMap = result.convertToMap();
        Map<String, Object> errors = (Map<String, Object>)resultMap.get('errors');
        System.debug('Error in DR '+DRName+'-'+errors);
        List<Map<String, Object>> myTransformResult = (List<Map<String, Object>>)result.toJsonList();
        
        if(Test.isRunningTest()){
            //for purpose of testclass 
            String testData = (String)inputmap.get('StaticResourceName');                        
            Map<String,Object> data = new Map<String,Object>();
            data= (Map<String, Object>) JSON.deserializeUntyped(testData);                                  
            myTransformResult.add(data);
        }

        //Getting ELANProductsBlock from DR Output
        for(Map<String,Object> elanblockMap :myTransformResult){
            List<object> elanblock = (List<object>)elanblockMap.get('ELANProductsBlock');
            for(Object obj : elanblock){
                Map<String, Object> blockMap = (Map<String, Object>)obj;

                Boolean HBEId = (Boolean)blockMap.get('HBEId');
                String PremiseNetworkType = (String)blockMap.get('PremiseNetworkType');
                String OEMIdLegacy = (String)blockMap.get('OEMIdLegacy');
                String OEMIdHBE = (String)blockMap.get('OEMIdHBE');  

                hbeflagSet.add(HBEId);

                if((PremiseNetworkType=='Both'&&HBEId) || (PremiseNetworkType=='HBE'&&HBEId) || (PremiseNetworkType=='Both'&&!HBEId)){
                    blockMap.put('counter',counter);
                    System.debug('#$# Counter - '+counter); //Putting a counter for HBE eliglbe ELANs for OEM prepopulation purpose
                    counter=counter+1;
                }
                if(String.isNotBlank(OEMIdHBE) || String.isNotBlank(OEMIdLegacy)){
                    SEEnrichmentDone=true;
                    System.debug('#$# SEEnrichmentDone flag TRUED'); //Checking SE is done for 1st or 2nd time
                }
                iteratedlist.add(blockMap); //iteratedlist contains the list block on which loop should run on
                //System.debug('#$# Iterated List '+iteratedlist);
            }
        }  

        if(hbeflagSet.contains(true)){ //Cart has HBE ELANs
            hasHbeELAN=true;
        }else if(hbeflagSet.contains(false)){ 
            hasHbeELAN=false;
        }
        System.debug('#$# hasHbeELAN flag- '+hasHbeELAN);

        if(!SEEnrichmentDone){ //SE Enrichment is done for first time   

             for(Map<String,Object> elanmap :iteratedlist){
                Map<String,Object> elanmapUpdated =elanmap;
                Boolean HBEId = (Boolean)elanmap.get('HBEId');
                Boolean HBEManuallyUpdated = (Boolean)elanmap.get('HBEManuallyUpdated');
                String CircuitIDText = (String)elanmap.get('CircuitIDText');
                String Prepopulateforsplit = (String)elanmap.get('Prepopulateforsplit');
                Boolean ExistingCheckBox =(Boolean)elanmap.get('ExistingCheckBox');
                Boolean HbeEditable = (Boolean)elanmap.get('HbeEditable');
                String PremiseNetworkType = (String)elanmap.get('PremiseNetworkType');
                String OEMIdLegacy = (String)elanmap.get('OEMIdLegacy');
                String OEMIdHBE = (String)elanmap.get('OEMIdHBE');
                Integer counterNo=(Integer)elanmap.get('counter');

                if(hasHbeELAN){ //If the cart has HBE ELAN
                    if(PremiseNetworkType=='Both' ||PremiseNetworkType=='HBE'){
                        HbeEditable=true;
                        //HBEManuallyUpdated=true;
                            if(HBEId==true || HbeEditable==true){
                                if(counterNo==1){
                                    OEMIdHBE=slahub1;
                                }else if(counterNo==2){
                                    OEMIdHBE=slahub2;
                                }else if(counterNo>2){
                                    OEMIdHBE=slaremote;
                                }
                            }              
                       }else{ //Cart has ELAN and but this particular ELAN is pure Legacy so OEM - Legacy
                            OEMIdLegacy=slaLegacy;
                       }
                }else{ //If the all ELANs are pure legacy 
                    OEMIdLegacy=slaLegacy;
                }
                elanmapUpdated.put('OEMIdHBE', OEMIdHBE);
                elanmapUpdated.put('OEMIdLegacy', OEMIdLegacy);
                elanmapUpdated.put('HbeEditable', HbeEditable);
                elanmapUpdated.put('HbePrefilledByCond', HbeEditable);                
                updateelanlist.add(elanmapUpdated);
                System.debug('#$# OEMIdHBE - '+elanmapUpdated.get('OEMIdHBE')+'\nOEMIdLegacy - '+elanmapUpdated.get('OEMIdLegacy')+
                            '\ncounter - '+elanmap.get('counter')+'\nHbeEditable -'+elanmapUpdated.get('HbeEditable')+
                            'HbePrefilledByCond -'+elanmapUpdated.get('HbePrefilledByCond'));
            }

        }else{//SE Enrichment is done for second time
            for(Map<String,Object> elanmap :iteratedlist){
                Map<String,Object> elanmapUpdated =elanmap;
                String Prepopulateforsplit = (String)elanmap.get('Prepopulateforsplit');
                Boolean ExistingCheckBox =(Boolean)elanmap.get('ExistingCheckBox');
                Boolean HBEManuallyUpdated=(Boolean)elanmap.get('HBEManuallyUpdated');
                String PremiseNetworkType = (String)elanmap.get('PremiseNetworkType');
                String ELANSpeedText = (String)elanmap.get('ELANSpeedText');
                String ClassOfService = (String)elanmap.get('ClassOfService');                
                String ELANPrefix;
                String ELANSCMD;
                String ELANSerial;
                String ELANTelco;
                if(ExistingCheckBox){
                    List<String> str = Prepopulateforsplit.split('/',4);
                    ELANPrefix=str[0].trim();
                    ELANSCMD=str[1].trim();
                    ELANSerial=str[2].trim();
                    ELANTelco=str[3].trim();
                    System.debug('#$# Circuit id splited '+str);
                }
                if(!HBEManuallyUpdated){ //HBEManuallyUpdated is false i.e user didnt change prefilled values during 1st SE Enrichment
                    Boolean IsElanHbeBySpeedCos=IsElanHbeBySpeedCos(ELANSpeedText, ClassOfService, PremiseNetworkType);
                    if(IsElanHbeBySpeedCos){ //If ELAN is HBE by Speed and COS then the HbeEditable will be readonly
                        HBEManuallyUpdated=false;
                    }else{                   //If ELAN is not HBE by Speed and COS then the HbeEditable will be Editable
                        HBEManuallyUpdated=true;
                    }
                }
                elanmapUpdated.put('ELANPrefix', ELANPrefix);
                elanmapUpdated.put('ELANSCMD', ELANSCMD);
                elanmapUpdated.put('ELANSerial', ELANSerial);
                elanmapUpdated.put('ELANTelco', ELANTelco);
                elanmapUpdated.put('HBEManuallyUpdated', HBEManuallyUpdated);
                updateelanlist.add(elanmapUpdated);
                System.debug('#$# ELAN CircuitId'+ELANPrefix+'/'+ELANSCMD+'/'+ELANSerial+'/'+ELANTelco+'\nHBEManuallyUpdated boolean '+HBEManuallyUpdated);
                //System.debug('#$# updateelanlist for Secondtime SE'+updateelanlist);
            }  
        }
        outputMap.put('ELANProductsBlock',updateelanlist);
        System.debug('outputMap->'+outputMap);
        return outputmap;  
    }
    public static Boolean IsElanHbeBySpeedCos(String speed,String COS,String PremiseNetworkType){
        //validates if ELAN is HBE by Speed cos , called during 2nd SE enrichment
        Boolean ElanIsHbe=false;
        Integer speedInMbps;
        if(speed.contains('Mbps')){
            speedInMbps=Integer.valueOf(speed.substring(0, speed.length() - 4).trim());
        }else if(speed.contains('Gbps')){
            speedInMbps=1000*Integer.valueOf(speed.substring(0, speed.length() - 4).trim());
        }
        //System.debug('#$# Speed in MBPS - '+speedInMbps);

        if(PremiseNetworkType=='Both'){
            if(speedInMbps>=500){
                ElanIsHbe=true;
            }else if(COS != 'Silver'){
                ElanIsHbe=true;
            }
        }else if(PremiseNetworkType=='HBE'){
            ElanIsHbe=true;
        }else if(PremiseNetworkType=='Legacy'){
            ElanIsHbe=false;
        }
        System.debug('#$# The Premise '+PremiseNetworkType+'HBE by Speed is '+ElanIsHbe);
        return ElanIsHbe;
    }  
    
}