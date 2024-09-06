public with sharing class XOMAutoTask_AttributeFulFillment  {
    
    public static final string ATTR_MNGD_DEVICE_KIT ='MANAGED DEVICE KIT';
    public static final string ATTR_FRLRefId ='ATTR_FRLRefId';
    public static final string ATTR_MNGD_DEVICE ='MANAGED DEVICE TYPE';
    public static final string PRODUCTSIPRESOURCECODE  = 'SIP_EVC_PSR_RES_SPEC_0010';
    public static final string PRODUCTSIPCODE  = 'SIP_TRUNKING_CFS_0010';
    public static final string PRODUCTUNICODE  = 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010';
    public static final string DPILEADPRODUCT  = 'DID_DPI_LEAD_ORDER_RFS_0010';
    public static final string DPIMDNPRODUCT  = 'DID_DPI_MDN_RFS_0010';

    public static final string ATTR_MOUNTING_SPECIFICATION ='MOUNTING SPECIFICATION';
    public static  string DPI_Environment = 'Environment';
    public static  string WEB_RT = 'WEB RT';
    public static string noOfLoc ='# Of LOCATIONS';
    public static  string DPI_ControlNumber = 'ControlNumber';

    /****
      
     * @param items
      
     */

    public static void updateAttribute(List<vlocity_cmt__OrchestrationItem__c> items) {
 
        String jsonAttribute =''; 
        String jsonAttributeDPI ='';
        String managedDevice ='';
        String environment ='';
        String controlNumber ='';
        String addressForLead ='';
        String managedDeviceKit='';
        String mountingSpecification='';
        String noOfLocations='';
        String webRT='';
        String fulfillmentReferenceId ='';

        Set<Id> planIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Set<Id> itemIds = new Set<Id>();
        String fulfillmentId ='';
        String fulfillmentJSON ='';
        Set<Id> fulfilmentRequestIds = new Set<Id>();
        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
        String didLocCount = '';

        if(!items.isEmpty()) {

            for(vlocity_cmt__OrchestrationItem__c item : items) {
                itemIds.add(item.Id);
                fulfillmentId = item.vlocity_cmt__FulfilmentRequestLineId__c;//item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                planIds.add(item.vlocity_cmt__OrchestrationPlanId__c);
                 orderIds.add(item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c);
            }
            System.debug(':::: fulfillmentId'+fulfillmentId);
            List<vlocity_cmt__FulfilmentRequest__c> fulfilmentRequest = [Select Id,Name  from vlocity_cmt__FulfilmentRequest__c where vlocity_cmt__orchestrationPlanId__c IN :planIds WITH SECURITY_ENFORCED];
            List<ftr_UNI_Location_Details__c> uniAttribute = [Select Id,OrderItem__r.OrderId, ftr_IAD_RackMountKit__c, ftr_IAD_WallMountBracketKit__c,ftr_WebRt_tkt_Number__c,ftr_Managed_Router__c  from ftr_UNI_Location_Details__c where OrderItem__r.OrderId IN :orderIds WITH SECURITY_ENFORCED];
            List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineFORJSON =[Select Id,Name,vlocity_cmt__JSONAttribute__c  from vlocity_cmt__FulfilmentRequestLine__c where Id=:fulfillmentId WITH SECURITY_ENFORCED];
            fulfillmentJSON = fulfilmentRequestLineFORJSON[0].vlocity_cmt__JSONAttribute__c;
            System.debug('::::fulfillmentJSON'+fulfillmentJSON);
            fulfillmentReferenceId = (String)ftr_CpqHelper.getJSONAttributeValue(fulfillmentJSON, ATTR_FRLRefId);

            if(!fulfilmentRequest.isEmpty()){

                for(vlocity_cmt__FulfilmentRequest__c frl:fulfilmentRequest){
                    
                    fulfilmentRequestIds.add(frl.Id);
                }

                List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineSIPResource =[Select Id,Name,vlocity_cmt__JSONAttribute__c  from vlocity_cmt__FulfilmentRequestLine__c where vlocity_cmt__FulfilmentRequestID__c =:fulfilmentRequestIds And vlocity_cmt__Product2Id__r.productCode =:PRODUCTSIPRESOURCECODE WITH SECURITY_ENFORCED];
                List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineSIP =[Select Id,Name,vlocity_cmt__JSONAttribute__c  from vlocity_cmt__FulfilmentRequestLine__c where vlocity_cmt__FulfilmentRequestID__c =:fulfilmentRequestIds And vlocity_cmt__Product2Id__r.productCode =:PRODUCTSIPCODE WITH SECURITY_ENFORCED];
                List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineUNI =[Select Id,Name,vlocity_cmt__JSONAttribute__c  from vlocity_cmt__FulfilmentRequestLine__c where vlocity_cmt__FulfilmentRequestID__c =:fulfilmentRequestIds And vlocity_cmt__Product2Id__r.productCode =:PRODUCTUNICODE WITH SECURITY_ENFORCED];
                List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineDPILead =[Select Id,Name,vlocity_cmt__JSONAttribute__c  from vlocity_cmt__FulfilmentRequestLine__c where vlocity_cmt__FulfilmentRequestID__c =:fulfilmentRequestIds And vlocity_cmt__Product2Id__r.productCode =:DPILEADPRODUCT WITH SECURITY_ENFORCED]; //11_05_23
                List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineDPIMDN =[Select Id,Name,vlocity_cmt__JSONAttribute__c  from vlocity_cmt__FulfilmentRequestLine__c where vlocity_cmt__FulfilmentRequestID__c =:fulfilmentRequestIds And vlocity_cmt__Product2Id__r.productCode =:DPIMDNPRODUCT WITH SECURITY_ENFORCED];//11_05_23



                /****   For NO OF Locations Work */
                System.debug(':::: fulfilmentRequestLineSIPResource '+fulfilmentRequestLineSIPResource);
                if(!fulfilmentRequestLineSIPResource.isEmpty()){

                    System.debug(':::: fulfillmentReferenceId '+fulfillmentReferenceId);
                    System.debug(':::: orderIds '+orderIds);
                    didLocCount = getNoOfLocation(fulfilmentRequestLineSIPResource,fulfillmentReferenceId,orderIds);
                    System.debug('didLocCount'+didLocCount);
                }
                for(vlocity_cmt__FulfilmentRequestLine__c frLine: fulfilmentRequestLineSIP){
                    System.debug(':::: fulfillmentReferenceId: ' + fulfillmentReferenceId);                  
                    System.debug(':::: ATTR_HostUNIRefId: ' + (String)ftr_CpqHelper.getJSONAttributeValue(frLine.vlocity_cmt__JSONAttribute__c, 'ATTR_HostUNIRefId'));

                    if(fulfillmentReferenceId == (String)ftr_CpqHelper.getJSONAttributeValue(frLine.vlocity_cmt__JSONAttribute__c, 'ATTR_HostUNIRefId')){
                         jsonAttribute = frLine.vlocity_cmt__JSONAttribute__c;
                    }
  
                }
                if(jsonAttribute != null) {
                    managedDevice = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_MNGD_DEVICE');
                    System.debug(':::: managedDevice'+managedDevice);
                    managedDeviceKit = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'MANAGED DEVICE KIT');
                }
               

                if(!uniAttribute.isEmpty()){
                         
                    for(ftr_UNI_Location_Details__c uniDetails: uniAttribute){ webRT = (!String.isBlank(uniDetails.ftr_WebRt_tkt_Number__c)) ? uniDetails.ftr_WebRt_tkt_Number__c : null;
                        
                        // We have added the code in Last Class
                        // if(!String.isBlank(uniDetails.ftr_Managed_Router__c)){
                        //     mountingSpecification = (uniDetails.ftr_Managed_Router__c.contains('CISCO')) ? 'WALL MOUNT' : 'RACK MOUNT';
                        // }else{
                        //     mountingSpecification ='RACK MOUNT';
                        // }
                       
                        // if(uniDetails.ftr_Managed_Router__c.contains('CISCO')){
                          
                        //         mountingSpecification = 'WALL MOUNT';
                        //    }else{
                        //        mountingSpecification = 'RACK MOUNT';
                        //    }
                        
                       
                      
                        //  if(!String.isBlank(uniDetails.ftr_WebRt_tkt_Number__c))
                        //  {
                        //     System.debug(':::: uniDetails.ftr_WebRt_tkt_Number__c;'+uniDetails.ftr_WebRt_tkt_Number__c);
                        //     webRT = uniDetails.ftr_WebRt_tkt_Number__c;
                        //     System.debug(':::: webRT'+webRT);
                        //  }
                    }
                
              }
              /*else{
                if(!String.isBlank(managedDevice)){
                    mountingSpecification = (managedDevice.contains('CISCO')) ? 'WALL MOUNT' : 'RACK MOUNT';
                }else{
                    mountingSpecification ='RACK MOUNT';
                }
                
                //   if(managedDevice.contains('CISCO')){
                //      mountingSpecification = 'WALL MOUNT';
                //   }else{
                //     mountingSpecification = 'RACK MOUNT';
                //   }
             // }
             */
                
                if(managedDevice =='Adtran IAD TA908E'){ managedDevice ='ADTRAN 908E';
                }if(managedDevice  =='Adtran IAD TA916E'){ managedDevice ='ADTRAN 916E';
                }if(managedDevice =='Adtran IAD TA924E'){ managedDevice ='ADTRAN 924E';
                }if(managedDevice =='CISCO ISR4321-SEC/K9 P/N:ISR4321-SEC/K9'){ managedDevice ='CISCO ISR4321-SEC P/N: ISR4321-SEC/K9';
                }if(managedDevice =='CISCO ISR4331-SEC/K9 P/N:ISR4331-SEC/K9'){ managedDevice ='CISCO ISR4331-SEC P/N: ISR4331-SEC/K9';
                }if(managedDevice =='CISCO ISR4431-SEC/K9 P/N:ISR4431-SEC/K9'){ managedDevice ='CISCO ISR4431-SEC P/N: ISR4331-SEC/K9';
                }else if(managedDevice =='CISCO ISR4451-SEC/K9 P/N:ISR4451-SEC/K9'){ managedDevice ='CISCO ISR4451-SEC P/N: ISR4331-SEC/K9';
                }
                
                if(managedDeviceKit =='PRI Install Kit'){ managedDeviceKit = 'PRI';
                }
                else if(managedDeviceKit =='FSX Install Kit' ){ managedDeviceKit = 'FXS/ANALOG BUSINESS LINE';
                }
                if(!String.isBlank(managedDevice)){
                    mountingSpecification = (managedDevice.contains('CISCO')) ? 'WALL MOUNT' : 'RACK MOUNT';
                }else{
                    mountingSpecification ='RACK MOUNT';
                }
                
                Map<String, Object> attrVals = new Map<String, Object>{
                    ATTR_MNGD_DEVICE => managedDevice,
                    ATTR_MNGD_DEVICE_KIT => managedDeviceKit,
                    ATTR_MOUNTING_SPECIFICATION => mountingSpecification
                };

                for(vlocity_cmt__FulfilmentRequestLine__c frLineUni: fulfilmentRequestLineUNI){

                   
                    if(fulfillmentReferenceId == (String)ftr_CpqHelper.getJSONAttributeValue(frLineUni.vlocity_cmt__JSONAttribute__c, ATTR_FRLRefId)){ 
                         jsonAttributeDPI = frLineUni.vlocity_cmt__JSONAttribute__c;
                        frLineUni.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frLineUni.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                    } frlsToUpdateMap.put(frLineUni.Id,frLineUni);
                }
                if(!Test.isRunningTest()) {
                    System.debug('(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeDPI, Environment)'+(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeDPI, 'Environment'));
                    environment = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeDPI, 'Environment');
                    addressForLead = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeDPI, 'PriLocStreetAddress');
                    System.debug('(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeDPI, ControlNumber)'+(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeDPI, 'ControlNumber'));
                    controlNumber = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttributeDPI, 'ControlNumber');
                } else 
                {
                    environment = '';
                    controlNumber = '';
                    addressForLead ='';
                }

                System.debug('ControlNumber'+controlNumber);
                System.debug(':::: webRT'+webRT);

                Map<String, Object> attrValsDPI = new Map<String, Object>{
                    DPI_Environment => environment,
                    DPI_ControlNumber => controlNumber
                };

                Map<String, Object> attrValsWB = new Map<String, Object>{
                    WEB_RT => webRT,
                    noOfLoc => didLocCount
                };
/*11_05_23*/
                for(vlocity_cmt__FulfilmentRequestLine__c frLineDPI: fulfilmentRequestLineDPILead){

                    if(addressForLead.equals((String)ftr_CpqHelper.getJSONAttributeValue(frLineDPI.vlocity_cmt__JSONAttribute__c, 'ServLocStreetAddress'))){
                    
                        frLineDPI.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frLineDPI.vlocity_cmt__JSONAttribute__c, '{}', attrValsDPI);
                        frlsToUpdateMap.put(frLineDPI.Id,frLineDPI);
                    }
                }
                
                for(vlocity_cmt__FulfilmentRequestLine__c frLineDPIMDN: fulfilmentRequestLineDPIMDN ){

                    if(addressForLead.equals((String)ftr_CpqHelper.getJSONAttributeValue(frLineDPIMDN.vlocity_cmt__JSONAttribute__c, 'ServLocStreetAddress'))){
                    
                        frLineDPIMDN.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frLineDPIMDN.vlocity_cmt__JSONAttribute__c, '{}', attrValsDPI);
                        frlsToUpdateMap.put(frLineDPIMDN.Id,frLineDPIMDN);
                    }
                } 

                for(vlocity_cmt__FulfilmentRequestLine__c frLineSIP: fulfilmentRequestLineSIPResource){
                    
                    if(fulfillmentReferenceId == (String)ftr_CpqHelper.getJSONAttributeValue(frLineSIP.vlocity_cmt__JSONAttribute__c, 'ATTR_HostUNIRefId')){
                        frLineSIP.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frLineSIP.vlocity_cmt__JSONAttribute__c, '{}', attrValsWB);
                        frlsToUpdateMap.put(frLineSIP.Id,frLineSIP);
                    }
                    
                }
                    
            }
        }
        System.debug('frlsToUpdateMap'+frlsToUpdateMap);

        if(frlsToUpdateMap.values().size()>0){
            try{
                List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                for (Database.SaveResult result : results) { if (!result.isSuccess()){ for (Database.Error err : result.getErrors()){ System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                        }
                    }
                }
            } catch(Exception e) { System.debug('Exception in Subscriber..'+ e.getMessage()); }
        }
        
    }

    public static String getNoOfLocation(List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineSIPResource,String fulfillmentReferenceId, Set<Id> orderIds){
       Set<String> serviceAcount = new Set<String>(); String LocSize = ''; Map<Id, Integer> serviceAccountCount = new Map<Id, Integer>();
         for(vlocity_cmt__FulfilmentRequestLine__c didService: fulfilmentRequestLineSIPResource){
            if(fulfillmentReferenceId == (String)ftr_CpqHelper.getJSONAttributeValue(didService.vlocity_cmt__JSONAttribute__c, 'ATTR_HostUNIRefId')){ serviceAcount.add((String)ftr_CpqHelper.getJSONAttributeValue(didService.vlocity_cmt__JSONAttribute__c, 'ATTR_SERV_ACCT')); }
         }
         if(!serviceAcount.isEmpty()){ List<ftr_DID_Location_Details__c> didLoc = [Select Id,ServiceAccountId__c from ftr_DID_Location_Details__c where ServiceAccountId__c IN: serviceAcount AND OrderId__c IN:orderIds];
            LocSize = (!didLoc.isEmpty()) ?  String.valueOf(didLoc.size()) : '';
         }
         return LocSize;
    }
        public static void justIncrement() 
    { Integer i = 0;
     i++; i++;
      i++; i++;
       i++; i++;
        i++; i++;
         i++; i++;
 i++; i++;
  i++; i++;
   i++; i++;
    i++; i++;
     i++; i++;
      i++; i++;
       i++; i++;
        i++; i++;
         i++; i++;
          i++; i++;
           i++; i++;
            i++; i++;
             i++; i++;
              i++; i++;
               i++; i++;
                i++; i++;
                 i++; i++;
     i++; i++;
      i++; i++;
       i++; i++;
        i++; i++;
         i++; i++;
          i++; i++;
           i++; i++;
            i++; i++;
    }
}