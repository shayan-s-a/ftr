global with sharing  class ELANConfigSERuleService implements vlocity_cmt.VlocityOpenInterface  { // NOPMD
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        Boolean result =true;
        try {
            if(methodName == 'ELANConfigSERules'){
                ELANConfigSERules(inputMap,outputMap,options);
                
            }            
        }
        catch (Exception ex) {
            //resultMap.put('errorMessage', ex.getMessage());
            ftr_Logger.writeInfo('ElanConfigService.Exception==>'+ex.getMessage());
            ftr_Logger.write(ex);
        } finally {
            ftr_Logger.writeInfo('Exit ElanConfigService.' + methodName);
        }
        
        
        return result; 
    }
    public  Map<String,Object> ELANConfigSERules(Map<String,Object> inputmap,Map<String,Object> outputMap, Map<String,Object> Options){
        Map<string,object> elanstep = (Map<string,object>)inputMap.get('ELANConfigurationStep');
        List<object> elanblock = (List<object>)elanstep.get('ELANProductsBlock');
        list<map<string, object>> updateelanlist = new list<map<string, object>>();
        List<Map<String, Object>> iteratedlist = new List<Map<String, Object>>();            
        Map<Integer, List<map<string,object>>> mapbynetwork = new Map<Integer, List<map<string, object>>>();
        Map<String, List<map<string,object>>> mapbyCircuitId = new Map<String, List<map<string, object>>>();
        //MethodScope variables declaration
        String ELANSERuleError='';
        String slaHub1Val = 'SLA HUB 1',slaHub2Val = 'SLA HUB 2',slaRemoteVal = 'SLA Remote';
        Map<String,String> ELANSERules = new Map<String,String>();

        for(Object obj : elanblock){
            Map<String, Object> resultMap = (Map<String, Object>)obj;
            iteratedlist.add(resultMap);
        }
        //system.debug('iteratedlist'+iteratedlist);
        
        for(map<string, object> elanmap : iteratedlist){
            Map<string,object> filteredmap = new map<string,object>();
            filteredmap = elanmap;
            Boolean existing = (Boolean)elanmap.get('ExistingCheckBox');
            if(!existing ){        
                 
                Integer network =(Integer)elanmap.get('ELANNetwork');
                system.debug('network'+network);
                if(!mapbynetwork.containsKey(network)){
                    mapbynetwork.put(network, new List<map<string,object>>());
                }
                
                mapbynetwork.get(network).add(filteredmap);
            }else{
                //CircuitIDText is saved as Integer network
                //System.debug('Entered 54 line');
                String network =(String)elanmap.get('CircuitIDText');
                system.debug('network'+network);
                if(!mapbyCircuitId.containsKey(network)){
                   mapbyCircuitId.put(network, new List<map<string,object>>());
                }
                
                mapbyCircuitId.get(network).add(filteredmap);         
                
            }
        }
        //System.debug('Line 65 mapbynetwork'+mapbynetwork);
        for(integer key :mapbynetwork.keyset() ){
            //Variable declarations
            List<String> allCOS = new List<String>();
            List<String> allNetworkType = new List<String>();
            List<String> allelanOEM = new List<String>();
            Integer SLAHUB1OEMId = 0,SLAHUB2OEMId = 0,SLARemoteOEMId = 0;
            String error = 'In Network No. '+key+' -';
            String errorTemp=error;
            System.debug('errorTemp'+errorTemp);
            List<Map<String, Object>> dataList = mapbynetwork.get(key);
            //System.debug('dataList'+dataList); 

            //ELANProductsBlock|n list enters
            for(Integer i = 0; i < dataList.size(); i++) {
                Map<String, Object> objmap = dataList[i];
                //System.debug('objmap'+objmap);
                map<string, object> obj = new map<string, object>();
                
                //Fetching required data                
                Boolean Existing = (Boolean)objmap.get('ExistingCheckBox');
                String elanCOS = (string)objmap.get('ClassOfService');
                String elanNetworkType =(string)objmap.get('ELANNetworkType');
                String elanOEM;/* = (String)objmap.get('OEM');*/
                String elanOEMIdHBE =(String)objmap.get('OEMIdHBE');
                String elanOEMIdLegacy =(String)objmap.get('OEMIdLegacy');
                //String elanOEMId = (String)objmap.get('OEMId');
                /*if(!elanOEMIdLegacy.equals('Legacy')){
                    elanOEM=elanOEMIdHBE;
                }
                else if(String.isNotBlank(elanOEMIdHBE) && String.isBlank(elanOEMIdLegacy)){
                    elanOEM=elanOEMIdHBE;
                }else if(String.isNotBlank(elanOEMIdLegacy) && String.isBlank(elanOEMIdHBE)){
                    elanOEM=elanOEMIdLegacy;
                }*/

                if(Existing==false || Existing==true ){
                    if(elanNetworkType=='HBE'){
                        if(elanOEMIdHBE!='Legacy'){
                            elanOEM=elanOEMIdHBE;
                            allelanOEM.add(elanOEM);  
                        }
                    }                     
                    allCOS.add(elanCOS);                
                    allNetworkType.add(elanNetworkType);
                    
                }    
            }
            Set<String> setOfallCOS = new Set<String>(allCOS);
            Set<String> setOfallNetworkType = new Set<String>(allNetworkType);
                for(String str:allelanOEM){
                    if(str!= null && str.equals(slaHub1Val)){
                        SLAHUB1OEMId++;
                    }else if(str!= null && str.equals(slaHub2Val)){
                        SLAHUB2OEMId++;
                    }else if(str!= null && str.equals(slaRemoteVal)){
                        SLARemoteOEMId++;
                    }
                }
            System.debug('COS Set ->'+setOfallCOS);
            System.debug('NetworkType Set ->'+setOfallNetworkType);
            System.debug('SLA HUB1 Count = '+SLAHUB1OEMId);
            System.debug('SLA HUB2 Count = '+SLAHUB2OEMId);
            System.debug('SLA Remote Count = '+SLARemoteOEMId);

                //Error validations starts
                if(allelanOEM.size()>0){
                    if(SLAHUB1OEMId==0 && SLAHUB2OEMId==0){
                        error+='You should have minimum one SLA HUB 1 and one SLA HUB 2 - OEM ID ';
                    }else if(SLAHUB1OEMId==0){
                        error+='You should have minimum one SLA HUB 1 OEM ID ';
                    }else if(SLAHUB1OEMId>1){
                        error+='You can\'t have more than one SLA HUB 1 OEM ID ';
                    }/*else if(SLAHUB2OEMId==0){
                        error+='You should have minimum one SLA HUB 2 OEM ID ';
                    }*/else if(SLAHUB2OEMId>1){
                        error+='You can\'t have more than one SLA HUB 2 OEM ID ';
                    } 
                }

                if(!error.equals(errorTemp)){
                    error+=' ; ';
                }        
        
                if (setOfallCOS.size()>1 && setOfallNetworkType.size()==1) {
                    error+='All COS should match within the network ';
                }else if (setOfallNetworkType.size()>1 && setOfallCOS.size()==1){
                    error+='All Network type should match within the network ';
                }else if(setOfallCOS.size() > 1 && setOfallNetworkType.size() > 1){
                    error+='All COS & Network type should match within the network ';
                }

                if(!error.equals(errorTemp)){
                    error+='<br>';
                    ELANSERuleError+=error;
                }
               
               
        }
        System.debug('Error Message -->'+ELANSERuleError);
        ELANSERules.put('ELANSERules',ELANSERuleError);
        outputMap.put('ELANConfigurationStep',ELANSERules);
        //System.debug(outputMap);
        return outputMap;  
    }  
}