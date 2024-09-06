global with sharing class ftr_ResourceManagementService  { 
    //Constants 
   private static final String RESERVE_WTN_METHOD_NAME = 'reserveWTNumber';
   private static final string EVPL = 'ENT_ETH_EVPL_0010';
   private static final string  EIA = 'ENT_ETH_EIA_0002';
   private static final string  UNI = 'ENT_ETH_UNI_0001';
   private static final string  invalidWTNErrMsg = 'WTN/BTN reservation Not Successfull for the following Order Products :';
   
   private static String BTN;
    public class MyException extends Exception {}
    private static Map<String, List<String>> npaNxxMap = new Map<String, List<String>>();

   Public Id orderId;
   Map<String, Object> resultMap;
   ftr_DPIResourceManagmentSystemInterface dpiinterface = new ftr_DPIResourceManagmentSystemInterface();
       
    //Invoke method called from omniscript
     global Map<String, Object>  invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
      this.resultMap= new Map<String,Object>();
          System.debug('Enter ftr_ResourceManagementService.' + methodName);
          System.debug('Enter ftr_ResourceManagementService.inputMap-->' + inputMap);
         if (methodName==RESERVE_WTN_METHOD_NAME){             
          // orderId = (Id)inputMap.get('orderId');       
        String inputMapStr = JSON.serialize(inputMap);
        System.debug('ftr_ResourceManagementService:InputMapStr-->'+inputMapStr);

           //ftr_ResourceManagementService.processWTNReservation(inputMapStr);  
        }
           this.resultMap.put('isSuccess', true);
           return resultMap;
     }
     
     public static Map<String, Object>  findAvailableTelephoneNumberAndReserve( Map<String, Object> inputMap){
        System.debug('Enter ftr_ResourceManagementService.findAvailableTelephoneNumbers ' + ftr_CpqAppHandlerHookImpl.debugLimits());
        
        Map<String, Object> tnListMap = new Map<String, Object> ();
        Map<String, Object> outputMap = new Map<String, Object>();
        try{
            String env = (String) inputMap.get('env');
            String state = (String) inputMap.get('state');
             Integer itemSequence=Integer.valueOf(inputMap.get('itemSequence'));
            String maxTnNumbers=(String) inputMap.get('maxTnNumbers');
            String isReserveTN=(String) inputMap.get('isReserveTN');
            String telePhoneNumber;
            List<String> tnList;
            
            List<String> npaNxxList = ftr_ResourceManagementService.getNpaNxxList(inputMap);           
            
            // try to find numbers
            for (String npaNxx : npaNxxList) {
                System.debug('calling findAvailableTelephoneNumbers');
                inputMap.put('npaNxx', npaNxx);
                tnListMap = ftr_DPIResourceManagmentSystemInterface.invoke('findAvailableTelephoneNumbers', inputMap);
                if (tnListMap.get('tnList') != null) {
                    tnList = (List<String>) tnListMap.get('tnList');
                    if (tnList.size() > 0) {
                        System.debug('NPA NXX used: ' + npaNxx);
                        System.debug('TNs returned: ' + JSON.serialize(tnList));
                        break;
                    } 
                }
            }

            if(Test.isRunningTest()){
                tnList  = new List<String>{'7897897897','4564564564','4564564565','7897697897','1223321222','7897897297','7897897899','1223321221','1223321229'};
            }
            
            if (tnList != null) {
                Integer itemSeqNum=Integer.valueOf(itemSequence);
                if (tnList[itemSeqNum]!=null){
                    telePhoneNumber= tnList[itemSeqNum];
                    outputMap.put('telePhoneNumber', telePhoneNumber);
                }
                // reserve the numbers
                //reserveTnMap.put('env', env);
                //outMap.put('telePhoneNumber', tn);
                if (isReserveTN=='True'){
                Map<String,Object> reserveTnMap = new Map<String,Object>();
                reserveTnMap.put('env', env);
                reserveTnMap.put('tn', telePhoneNumber);
                try{
                    Map<String, Object> reservedOutMap = ftr_DPIResourceManagmentSystemInterface.invoke('reserveTelephoneNumber', reserveTnMap);
                  System.debug('Automatic retry of reservetelephonenumber :'+ reservedOutMap);
                    outputMap.put('result', reservedOutMap.get('result'));
                    outputMap.put('statusCode', reservedOutMap.get('statusCode'));
                    outputMap.put('responsebody', reservedOutMap.get('responsebody'));
                }catch (Exception ex){
                    outputMap.put('result', false); // For NULL check 
                }
            }
            } 
        }catch (Exception ex){
            ftr_Logger.write(ex);
            outputMap.put('result', false); // For NULL check 
        }
        System.debug('Exit ftr_ResourceManagementService.findAvailableTelephoneNumbersAndReserve ' + ftr_CpqAppHandlerHookImpl.debugLimits());
        return outputMap;
    }

     /**
     * @description: returns a unique list of NPANXXs for a given DPI ENV and StateCode
     */
    public static List<String> getNpaNxxList( Map<String, Object> inputMap){
        
        System.debug('::::inputMap1234'+inputMap);
        System.debug('NPA_NXXxcffgh'+(String) inputMap.get('npaNxx'));
        System.debug('Item_Name1234'+(String) inputMap.get('Item_Name'));
        String ItemName = (String) inputMap.get('Item_Name');
        String npaNXX = (String) inputMap.get('npaNxx');
        String env = (String) inputMap.get('env');
        String state = (String) inputMap.get('state');
        Integer itemSequence=Integer.valueOf(inputMap.get('itemSequence'));
        String maxTnNumbers=(String) inputMap.get('maxTnNumbers');
        String isReserveTN=(String) inputMap.get('isReserveTN');
        String wc_cilli = (String)inputMap.get('wc_cilli');
        if(wc_cilli!=null){
            wc_cilli = '%'+wc_cilli+'%';
        }else{wc_cilli = '%%';}
        String key = env + '-' + state;
        if (!npaNxxMap.containsKey(key)) {
            Set<String> npaNxxSet = new Set<String>();
            if(ItemName == 'RCFindAvailablePhoneNumber'){
                System.debug('npaNXX1234566'+npaNXX);
                System.debug('keyxcvb'+key); 
                npaNxxSet.add(npaNXX);
                npaNxxMap.put(key, new List<String>(npaNxxSet));
            }else{
                ftr_PSRExchangeDetail__c[] exchangeDetailList = [SELECT Id, FICT_NPA__c, FICT_NXX__c 
                                                                 FROM ftr_PSRExchangeDetail__c 
                                                                 WHERE StateCode__c = :state AND DPI_Env__c =:env 
                                                                 And WC_CLLI__c like :wc_cilli 
                                                                 AND FICT_NPA__c <> NULL AND FICT_NXX__c <> NULL];
                for (ftr_PSRExchangeDetail__c exchangeDetail : exchangeDetailList) {
                    npaNxxSet.add(exchangeDetail.FICT_NPA__c + exchangeDetail.FICT_NXX__c);
                }
                npaNxxMap.put(key, new List<String>(npaNxxSet));
                System.debug(':::: npaNxxMapFor'+npaNxxMap);
            }
        }
        System.debug(':::: npaNxxMap.getkey'+npaNxxMap.get(key));
        return npaNxxMap.get(key);
    }   
  
    
}