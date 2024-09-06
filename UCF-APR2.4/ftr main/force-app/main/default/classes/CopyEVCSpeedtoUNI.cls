global with sharing  class CopyEVCSpeedtoUNI implements vlocity_cmt.VlocityOpenInterface  {
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        Boolean result =true;
        try {
            if(methodName == 'CopyEVCSpeedtoUNITrans'){
                CopyEVCSpeedtoUNITrans(inputMap,outputMap,options);
                
            }else if(methodName=='FetchUNI'){
                FetchUNI(inputMap,outputMap,options);
            }else if(methodName=='GetAttributesForReviewRemote'){
                GetAttributesForReviewRemote(inputMap,outputMap,options);
            }
        }
        catch (Exception ex) {
            ftr_Logger.writeInfo('CopyEVCSpeedtoUNI.Exception==>'+ex.getMessage());
            ftr_Logger.write(ex);
        } finally {
            ftr_Logger.writeInfo('Exit CopyEVCSpeedtoUNI.' + methodName);
        }
        
        
        return result; 
    }
  
  public  Map<String, Object> CopyEVCSpeedtoUNITrans(Map<String,Object> inputmap,Map<String,Object> outputMap, Map<String,Object> options) {
        
        List<String> ProdCodeList = new List<String>{
            ftr_CpqService.ProductCode_EIA,
            ftr_CpqService.ProductCode_MDIA,
            ftr_CpqService.ProductCode_EVPL,
            ftr_CpqService.ProductCode_EVPL_EVC,
            ftr_CpqService.ProductCode_ELAN,            
            ftr_CpqService.ProductCode_SDWAN,
            ftr_CpqService.ProductCode_SIP_NETWORK_ACCESS
        };
        
        Integer EVCSpeedMbps;
        Integer dupUNISpeed = 12345678;
        String EVCSerAccId;
        String UNIProdCode = 'ENT_ETH_UNI_0001';


        List<Object> accLocationUpdated = new List<Object>();
        List<Object> evcList = new List<Object>();
        List<Object> evcList2 = new List<Object>();
        List<Object> uniList = new List<Object>();

        List<String> serAccIdAll = new List<String>();
        List<String> serAccIdDup = new List<String>();
        Set<String> uniqueSerAccSet = new Set<String>();

        //System.debug('Input map to CopyEVCSpeedtoUNI'+inputmap);

        //Storing the AccessLocation List 
        List<Object> accessLocationList = (List<Object>) inputmap.get('AccessLocation');
        
        //Separating into three lists OLIs eligible as EVC,all OLI except UNI(IP,etc) and UNIs 
        for(Object accLocObj:accessLocationList){

            Map<String, Object> accessLocation = (Map<String, Object>) accLocObj;

            if(ProdCodeList.contains((String)accessLocation.get('ProductCode'))){
                evcList.add(accessLocation);
                serAccIdAll.add((String)accessLocation.get('ServiceAccountId'));
            }else if(accessLocation.get('ProductCode')==UNIProdCode){
                uniList.add(accessLocation);
            }
            if(accessLocation.get('ProductCode')!=UNIProdCode){
                evcList2.add(accessLocation);
            }
        }
        //System.debug('EVC List\n'+JSON.serializePretty(evcList));
        //System.debug('UNI List\n'+JSON.serializePretty(uniList));
        
        for (String str : serAccIdAll) {
            if (!uniqueSerAccSet.add(str)) {
                // If the string is not added to the set, it means it's a duplicate
                serAccIdDup.add(str);
            }
        }
        System.debug('serAccIdAll'+serAccIdAll);
        System.debug('uniqueSerAccSet'+ uniqueSerAccSet);
        System.debug('serAccIdDup'+ serAccIdDup);
        



        try {
            System.debug('#$# Entered try block CopyEVCSpeedtoUNITrans ---');
            // for(Object evcOLI:evcList){
            //     Map<String,Object> evcMap=(Map<String,Object>)evcOLI;
            //     EVCSpeedMbps=Integer.valueOf((Decimal)evcMap.get('SpeedinMbps'));
            //     EVCSerAccId=(String)evcMap.get('ServiceAccountId');
            //     Boolean duplicateUNI = serAccIdDup.contains(EVCSerAccId) ? true : false;
                
            //     for(Object uniOLI:uniList){
            //         Map<String, Object> uniMap = (Map<String, Object>) uniOLI;
            //         String UNISerAccId=(String)uniMap.get('ServiceAccountId');
            //         Integer UNISpeedMbps=Integer.valueOf((Decimal)uniMap.get('SpeedinMbps'));
            //         if(UNISerAccId==EVCSerAccId){
            //             UNISpeedMbps=EVCSpeedMbps;
            //             Integer uniSpeed = duplicateUNI? dupUNISpeed:UNISpeedMbps;
            //             uniMap.put('SpeedinMbps',uniSpeed);
            //             //uniMap.put('SpeedinMbps',UNISpeedMbps);
            //             accLocationUpdated.add(uniMap);
            //             //break;
            //         }                
            //     }                
                                               
            // }                      
            
            for(Object uniOLI:uniList){
                Map<String, Object> uniMap = (Map<String, Object>) uniOLI;
                String UNISerAccId=(String)uniMap.get('ServiceAccountId');
                Integer UNISpeedMbps=Integer.valueOf((Decimal)uniMap.get('SpeedinMbps'));

                for(Object evcOLI:evcList){
                    Map<String,Object> evcMap=(Map<String,Object>)evcOLI;
                    EVCSpeedMbps=Integer.valueOf((Decimal)evcMap.get('SpeedinMbps'));
                    EVCSerAccId=(String)evcMap.get('ServiceAccountId');
                    Boolean duplicateUNI = serAccIdDup.contains(EVCSerAccId) ? true : false;
                    if(UNISerAccId==EVCSerAccId){
                        UNISpeedMbps=EVCSpeedMbps;
                        Integer uniSpeed = duplicateUNI? dupUNISpeed:UNISpeedMbps;
                        uniMap.put('SpeedinMbps',uniSpeed);
                        //uniMap.put('SpeedinMbps',UNISpeedMbps);
                        accLocationUpdated.add(uniMap);
                        break;    
                    }
                                 
                }                    
            }
            accLocationUpdated.addAll(evcList2);
            System.debug('#$# Exit try block CopyEVCSpeedtoUNITrans');
        } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        
                  
        
    outputMap.put('AccessLocation',accLocationUpdated);
    //System.debug('CopyEVCSpeedtoUNITrns\n'+JSON.serializePretty(outputMap));
    return outputMap;
    }

    public Map<String,Object> FetchUNI(Map<String,Object> inputmap,Map<String,Object> outputMap, Map<String,Object> options){
        System.debug('#$# Options map FetchUNI -'+options);
        String DRName = (String)options.get('Dataraptor');
        System.debug('#$# Input map FetchUNI-'+inputmap);
        Map<String, Object> myTransformData = new Map<String, Object>{'OrderId'=>(String)inputmap.get('OrderId')};
        //Map<String, Object> myTransformData = (Map<String,Object>)inputmap;  
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(myTransformData, DRName);
        Map<String, Object> resultMap = result.convertToMap();
        Map<String, Object> errors = (Map<String, Object>)resultMap.get('errors');
        System.debug('Error in DR '+DRName+'-'+errors);
        List<Map<String, Object>> myTransformResult = (List<Map<String, Object>>)result.toJsonList();
        //System.debug('#$# output from FetchUNI DR - '+resultMap);
        
        if(Test.isRunningTest()){
            String testData = (String)inputmap.get('StaticResourceName'); //for purpose of testclass             
            Map<String,Object> data = new Map<String,Object>();            
            data= (Map<String, Object>) JSON.deserializeUntyped(testData);             
            myTransformResult.add(data);
        }
        
        

        Map<String,Object> myTransformResultMap =new Map<String,Object>();
        for (Map<String, Object> toMap : myTransformResult) {
            myTransformResultMap.putAll(toMap);
        }

        outputMap=CopyEVCSpeedtoUNITrans(myTransformResultMap,outputMap,options);
        //System.debug('#$# Output from FetchUNI\n'+JSON.serializePretty(outputMap));
        return outputMap;
    }

    public Map<String,Object> GetAttributesForReviewRemote(Map<String,Object> inputmap,Map<String,Object> outputMap, Map<String,Object> options){
        try{
            String OrderId = (String)inputmap.get('ContextId');
            String DRName = (String)options.get('Dataraptor');
            Map<String, Object> ipMap= new Map<String, Object>{'OrderId'=>OrderId};
            Map<String, Object> optMap= new Map<String, Object>{'Dataraptor'=>DRName};
            Map<String, Object> opMap= new Map<String, Object>();
            
            if(Test.isRunningTest()){
                ipMap.put('StaticResourceName',(String)inputmap.get('StaticResourceName'));
            }


            Map<String, Object> outputMapModified= new Map<String, Object>();
            outputMapModified=FetchUNI(ipMap, opMap, optMap);
            outputMap.put('Products', outputMapModified);        
                                               
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());  
        }
        
        //System.debug('OutputMap for GetAttributeFor'+JSON.serializePretty(outputMap));

        return outputMap;
    }	
}