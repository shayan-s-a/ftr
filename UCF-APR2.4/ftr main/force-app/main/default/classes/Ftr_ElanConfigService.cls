global with sharing  class Ftr_ElanConfigService implements vlocity_cmt.VlocityOpenInterface  {
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        Boolean result =true;
        try {
            if(methodName == 'UpdateELANParentID'){
                UpdateELANParentID(inputMap,outputMap,options);
                
            }else if(methodName == 'Saveelandata'){
                Saveelandata(inputMap,outputMap,options);
                
            }else if(methodName == 'ELANConfigSERules'){
                //ELANConfigSERules(inputMap,outputMap,options);
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
    
    public Map<String, Object> UpdateELANParentID(Map<String,Object> inputmap,Map<String,Object> outputMap, Map<String,Object> Options) {
        Map<string,object> elanstep = (Map<string,object>)inputMap.get('ELANConfigurationStep');
        List<object> elanblock = (List<object>)elanstep.get('ELANProductsBlock');
        string UpdateELANPrefix = (string)Options.get('UpdateELANPrefix');
        string UpdateELANSCMD = (string)Options.get('UpdateELANSCMD');
        string UpdateELANSerial = (string)Options.get('UpdateELANSerial');
        string UpdateTelco = (string)Options.get('UpdateTelco');
        List<Map<String, Object>> iteratedlist = new List<Map<String, Object>>();
        for(Object obj : elanblock){
            Map<String, Object> resultMap = (Map<String, Object>)obj;
            iteratedlist.add(resultMap);
        }
        list<map<string,object>> updatedelanblock = new list<map<string,object>>();
        system.debug('elanblock'+elanblock);
        for(Map<String, Object> obj : iteratedlist){
            Boolean Existing = (Boolean)obj.get('ExistingCheckBox');
            string elanprefix = (string)obj.get('ELANPrefix');
            system.debug('test '+obj);
            if(Existing){
                obj.put('ELANPrefix',UpdateELANPrefix);
                obj.put('ELANSCMD',UpdateELANSCMD);
                obj.put('ELANSerial',UpdateELANSerial);
                obj.put('ELANTelco',UpdateTelco);                
            }
            updatedelanblock.add(obj);
        }
        elanstep.put('ELANProductsBlock',updatedelanblock);
        outputMap.put('ELANConfigurationStep',elanstep);
        return outputMap;
    }

    public Map<String,Object> Saveelandata(Map<String,Object> inputmap,Map<String,Object> outputMap, Map<String,Object> Options) {
        Map<string,object> elanstep = (Map<string,object>)inputMap.get('ELANConfigurationStep');
        List<object> elanblock = (List<object>)elanstep.get('ELANProductsBlock');
        list<map<string, object>> updateelanlist = new list<map<string, object>>();
        List<Map<String, Object>> iteratedlist = new List<Map<String, Object>>();            
        Map<Integer, List<map<string,object>>> mapbynetwork = new Map<Integer, List<map<string, object>>>();
        for(Object obj : elanblock){
            Map<String, Object> resultMap = (Map<String, Object>)obj;
            iteratedlist.add(resultMap);
        }
        system.debug('iteratedlist'+iteratedlist);
        
        for(map<string, object> elanmap : iteratedlist){
            System.debug('Enter first for loop---');
            map<string,object> filteredmap = new map<string,object>();
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
                System.debug('Enter first for loop else part---');
                map<string, object> obj = new map<string, object>();
                //string ELANId = (string)elanmap.get('ELANId');
                //string finalcircuitid = (string)elanmap.get('CircuitIDText');
				string ELANId = (string)elanmap.get('ELANId');
                string ELANPrefix = (string)elanmap.get('ELANPrefix');
                string ELANSCMD = (string)elanmap.get('ELANSCMD');
                string ELANSerial = (string)elanmap.get('ELANSerial');
                string ELANTelco = (string)elanmap.get('ELANTelco');
                string finalcircuitid = ELANPrefix +'/'+ELANSCMD+'/'+ELANSerial+'/'+ELANTelco;	
				
				String elanOEM;
                String elanNetworkType =(string)elanmap.get('ELANNetworkType');
                String elanOEMIdHBE =(String)elanmap.get('OEMIdHBE');
                String elanOEMIdLegacy =(String)elanmap.get('OEMIdLegacy');
                System.debug('Enter first for loop else part 102---');
                Boolean Hbeflag =(Boolean)elanmap.get('HbeEditable');
                Boolean HbeflagManuallyEdited =(Boolean)elanmap.get('HBEFlagManuallyEdited');
                //String elanOEMId = (String)objmap.get('OEMId');
                System.debug('Enter first for loop else part 106---');
                if(elanNetworkType=='HBE'){
                    if(elanOEMIdHBE!='Legacy'){
                        elanOEM=elanOEMIdHBE;
                          
                    }
                }else if(elanNetworkType=='Legacy'){
                    if(elanOEMIdLegacy=='Legacy'){
                        elanOEM=elanOEMIdLegacy;  
                    }
                }  
				
				System.debug('Line 115 -- Hbeflag '+Hbeflag+'HbeflagManuallyEdited '+HbeflagManuallyEdited+'OEMId '+elanOEM+
								'\nexisting '+existing+'finalcircuitid '+finalcircuitid+'ELANId '+ELANId);
                obj.put('Hbeflag',Hbeflag);
                obj.put('HbeflagManuallyEdited',HbeflagManuallyEdited);
                obj.put('OEMId',elanOEM);
                obj.put('existing',existing);
                obj.put('finalcircuitid',finalcircuitid);
                obj.put('ELANId',ELANId);                        
                updateelanlist.add(obj);
                system.debug('updateelanlist sent for DR for Exsisting ELANs\n'+updateelanlist);
                
            }
        }
        System.debug('mapbynetwork'+mapbynetwork);
        for(integer key :mapbynetwork.keyset() ){
            System.debug('Enter second for loop---'); 
            List<Map<String, Object>> dataList = mapbynetwork.get(key);
            for(Integer i = 0; i < dataList.size(); i++) {
                Map<String, Object> objmap = dataList[i];
                map<string, object> obj = new map<string, object>();
                 string ELANId = (string)objmap.get('ELANId');
                Integer network =(Integer)objmap.get('ELANNetwork');
                Boolean existing = (Boolean)objmap.get('ExistingCheckBox');
                //String OEMId = (String)objmap.get('OEM');
                String elanOEM;
                String elanNetworkType =(string)objmap.get('ELANNetworkType');
                String elanOEMIdHBE =(String)objmap.get('OEMIdHBE');
                String elanOEMIdLegacy =(String)objmap.get('OEMIdLegacy');
                Boolean Hbeflag =(Boolean)objmap.get('HbeEditable');
                Boolean HbeflagManuallyEdited =(Boolean)objmap.get('HBEFlagManuallyEdited');
                //String elanOEMId = (String)objmap.get('OEMId');
                if(elanNetworkType=='HBE'){
                    if(elanOEMIdHBE!='Legacy'){
                        elanOEM=elanOEMIdHBE;
                          
                    }
                }else if(elanNetworkType=='Legacy'){
                    if(elanOEMIdLegacy=='Legacy'){
                        elanOEM=elanOEMIdLegacy;  
                    }
                }               


                System.debug('Values going into updateelanlist ELANId '+ELANId+
                'network '+network+'existing '+existing+'OEMId '+elanOEM);
                
                obj.put('ELANId',ELANId);
                obj.put('network',network);
                obj.put('existing',existing);
                obj.put('Hbeflag',Hbeflag);
                obj.put('HbeflagManuallyEdited',HbeflagManuallyEdited);
                
                obj.put('OEMId',elanOEM);
                if(i==0){
                    obj.put('firstELAN', 'Yes');}
                else{
                    obj.put('firstELAN', 'No');
                }
                updateelanlist.add(obj);
                system.debug('updateelanlist sent for DR for New  ELANs\n'+updateelanlist);   
            }
        }
        inputmap.put('updatedelan',updateelanlist);
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(inputmap, 'SaveELANData');
		Map<String, Object> resultMap = result.convertToMap();
        Map<String, Object> errors = (Map<String, Object>)resultMap.get('errors');
		System.debug('@@errors'+errors);
		
        system.debug('olibynetwork'+result);
        outputMap.put('result',result);
        return outputmap;  
    }  
    
}