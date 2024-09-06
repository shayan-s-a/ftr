global without sharing class ftr_SIPOrderManagementHelper {
    public final static String STATUS_NOTSTARTED = 'Not Started';
    //Constants
    public final static String TECH_PRODUCTCODE_EIA = 'ENT_ETH_EIA_EVC_PSR_001';
    public final static String TECH_PRODUCTCODE_EVPL_EVC = 'ENT_ETH_EVPL_EVC_PSR_001';      
    public final static String TECH_PRODUCTCODE_UNI = 'ENT_ETH_UNI_PSR_001';
    public final static String TECH_PRODUCTCODE_DPI_CKT = 'ENT_ETH_DPI_CIRCUIT_BILLING'; 
    //SIP Trunking thecnical products
    public final static String TECH_PRODUCTCODE_SIP_UNI = 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_SIP_EVC = 'SIP_EVC_PSR_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_DPI_SIP_UNI = 'DPI_CIRCUIT_BILLING_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_DPI_SIP_TRUNKING = 'SIP_TRUNKING_DPI_BILLING_RES_SPEC_0010';
    
    public final static String ATTR_REF_ID = 'ATTR_FRLRefId'; 
    public final static String STATUS_COMPLETED = 'Completed';
    public static final String TASKNAME_RETRIEVECUSTOMERFACILITIES = 'SIPRetrieveCustomerFacilities';
    public static final String TASKNAME_FINDAVAILABLETELEPHONENUMBERS = 'SIPFindAvailableTelephoneNumbers';
    public static final String TASKNAME_RESERVETELEPHONENUMBER = 'SIPReserveTelephoneNumber'; 
    public final static String INPUT_ITEM_DEF_WAIT_FOR_M6_ORD_COMPLETION = 'Wait for M6Orders Completion';
    public final static String INPUT_ITEM_DEF_SIP_WAIT_FOR_M6_ORD_COMPLETION = 'SIP Wait for M6Orders Completion';
    
    // *Input
    public final static String INPUT_EVENT = 'events';
    public final static String INPUT_STATE = 'Running';
    public final static String INPUT_STATE_RUNNING = 'Running';
    public final static String INPUT_STATE_PENDING = 'Pending';
    public final static String INPUT_ITEM_DEFINITION_WT_TO_START = 'Wait To Start';
    public final static String INPUT_ITEM_DEFINITION_WT_FOR_M6ORD_COMP = 'Wait for M6Orders Completion';
    public final static String EXECUTE_METHOD = 'execute';
    public static String FulfilmentReqLineId;
    public final static String ATTR_IsBTNOrderComplete = 'ATTR_IsBTNOrderComplete';
    public final static String ATTR_WorkingTelephoneNumber = 'WorkingTelephoneNumber';
    public final static String ATTR_BillingTelephoneNumber = 'BillingTelephoneNumber';
    public final static String ATTR_Environment = 'Environment';
    public final static String ATTR_GroupMemberOrderId = 'GroupMemberOrderId';
    public final static String ATTR_LeadOrderId = 'LeadOrderId';
    
    /**
* This method returns the initial JSON payload from the given OrchestrationItem item
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  item Orchestration Item
* @return      initial payload 
*/
    public static Map<String, Object> getInputPayload(String url, String path, vlocity_cmt__OrchestrationItem__c item) {
        system.debug('getInputPayload:fulfilmentRequestLineId__c ---->'+item.vlocity_cmt__fulfilmentRequestLineId__c+' '+item);
        vlocity_cmt__FulfilmentRequestLine__c frl = [SELECT Id, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c,
                                                     vlocity_cmt__JSONAttribute__c, vlocity_cmt__Action__c, vlocity_cmt__LineNumber__c, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.Name,
                                                     vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber
                                                     FROM vlocity_cmt__FulfilmentRequestLine__c
                                                     WHERE Id=:item.vlocity_cmt__fulfilmentRequestLineId__c];
        
        Map<String, List<Object>> described_by = new Map<String, List<Object>>();
        Map<String, Object> payload = new Map<String, Object> {
            'order_id' => frl.vlocity_cmt__FulfilmentRequestID__r.Id,
                'salesforce_order_id'=>frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c,
                'salesforce_order_number'=>frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber,
                'account_id' => frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c,
                'order_items' => new List<Object> {
                    new Map<String, Object> {
                        'order_item_id' => frl.Id,
                            'action' => frl.vlocity_cmt__Action__c,
                            'line_number' => frl.vlocity_cmt__LineNumber__c,
                            'specified_by' => new Map<String, String> {
                                'specification_id' => frl.vlocity_cmt__Product2Id__c,
                                    'specification_name' => frl.vlocity_cmt__Product2Id__r.Name
                                    },
                                        'described_by' => described_by
                                        }
                }
        };
            
            String jsonAttribute = frl.vlocity_cmt__JSONAttribute__c;
        Map<String, Object> attrValMap = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
        System.debug('Attribute value map :'+ attrValMap);
        vlocity_cmt__Attribute__c[] myAttribs = [SELECT Id, vlocity_cmt__Code__c, vlocity_cmt__AttributeCategoryCode__c FROM vlocity_cmt__Attribute__c WHERE vlocity_cmt__Code__c=:attrValMap.keySet() 
                                                 ORDER BY vlocity_cmt__AttributeCategoryCode__c];
        
        
        Set<String> myCategoryCode = new Set<String>();
        List<Object> categoryAttribs;
        for (vlocity_cmt__Attribute__c attr : myAttribs) {
            
            if (!myCategoryCode.contains(attr.vlocity_cmt__AttributeCategoryCode__c)) {
                categoryAttribs = new List<Object>();
                described_by.put(attr.vlocity_cmt__AttributeCategoryCode__c, categoryAttribs);
            } else {
                categoryAttribs = (List<Object>)described_by.get(attr.vlocity_cmt__AttributeCategoryCode__c); 
            }
            myCategoryCode.add(attr.vlocity_cmt__AttributeCategoryCode__c);
            
            if(attrValMap.get(attr.vlocity_cmt__Code__c) != null){
                categoryAttribs.add(new Map<String, Object> {
                    'characteristic' => attr.vlocity_cmt__Code__c,
                        'value' => attrValMap.get(attr.vlocity_cmt__Code__c)
                        });
            }
            
        }
        System.debug('ftr_SIPOrderManagementHelper category attribute map: '+ categoryAttribs);
        return payload;
    }
    
    /**
* This method returns the JSON payload massaged by the RequestItem DataRaptor
* @param  input payload to be massaged
* @param  requestItemDRName Datarapotor name
* @return      payload massaged by RequestItem DR
*/
    /*public static Map<String, Object> executeRequestItemDR(Map<String, Object> input, String requestItemDRName) {

vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(input, requestItemDRName);
Map<String, Object> DRItemFinalRequest = (Map<String, Object>)result.toJSON();
return DRItemFinalRequest;
}
*/
    /**
* This method returns the JSON payload massaged by the Request DataRaptor
* @param  input payload to be massaged
* @param  requestDRName Datarapotor name
* @return      payload massaged by Request DR
*/
    public static Map<String, Object> executeRequestDR(Map<String, Object> input, String requestDRName) {
        
        System.debug('Inside execute dataraptor: '+ input + ', request dr name : '+ requestDRName);
        //requestDRName='a8b3C0000000FE6QAM';
        System.debug('BEFORE EXECUTION JSON RESQUEST: '+ JSON.serialize(input));
        
        System.debug('2 BEFORE EXECUTION JSON RESQUEST DR NAME: '+ JSON.serialize(input) +', request dr name : '+ requestDRName);
        
        System.debug('3 BEFORE EXECUTION JSON RESQUEST DR NAME: '+ JSON.serialize(input) +', request dr name : '+ requestDRName);
        
        
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(input, requestDRName);   
        
        System.debug('After execution: '+ result ); 
        
        Map<String, Object> DRFinalRequest = (Map<String,Object>)result.toJSON();
        System.debug('DRFinalRequest: '+ JSON.serialize(DRFinalRequest));
        return DRFinalRequest;
        
        
        //throw new ftr_M6SystemInterfaceException('Not implemented.');
    }
    
    /**
* This method returns the JSON payload massaged by the Response DataRaptor
* @param  ctx context data 
* @param  responseAttrsDR Datarapotor name
* @return      payload massaged by Response DR
*/
    /*public static Map<String, Object> executeResponseAttrsDR(Map<String, Object> ctx, String responseAttrsDR) {
System.debug('Response data raptor : '+ responseAttrsDR);
Map<String,Object> DRinput =new Map<String,Object>();
Map<String,Object> DRinputMap =new Map<String,Object>();

Map<String,Object> ctxOutput = (Map<String,Object>)ctx.get('output');


DRinputMap.put('Id',FulfilmentReqLineId);
DRinputMap.putAll(ctxOutput);
DRinput.put('output',DRinputMap);
vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(DRinput, responseAttrsDR);
Map<String, Object> resultMap = result.convertToMap();
return resultMap;
// throw new ftr_M6SystemInterfaceException('Not implemented.');
}
*/
    /**
* This method returns the JSON payload massaged by the ResponseItem DataRaptor
* @param  ctx context data 
* @param  responseItemDRName Datarapotor name
* @return      payload massaged by ResponseItem DR
*/
    /*public static Map<String, Object> executeResponseItemDR(Map<String, Object> ctx, String responseItemDRName) {

Map<String,Object> DRinput =new Map<String,Object>();
Map<String,Object> DRinputMap =new Map<String,Object>();

Map<String,Object> ctxOutput = (Map<String,Object>)ctx.get('output');


DRinputMap.put('Id',FulfilmentReqLineId);
DRinputMap.putAll(ctxOutput);
DRinput.put('output',DRinputMap);
vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(DRinput, responseItemDRName);
Map<String, Object> resultMap = result.convertToMap();
return resultMap;

//throw new ftr_M6SystemInterfaceException('Not implemented.');
}*/
    
    /**
* This method returns the JSON payload massaged by the ResponseItem DataRaptor
* @param  ctx context data 
* @param  responseDRName Datarapotor name
* @return      payload massaged by ResponseItem DR
*/
    public static Map<String, Object> executeResponseDR(Map<String, Object> ctx, String responseDRName, String fulfilmentid, String orderId) {
        system.debug('Inside ftr_SIPOrderManagementHelper responseDRName-->');    
        system.debug('responseDRName-->'+responseDRName + 'fulfilmentid : '+fulfilmentid);
        Map<String,Object> DRinputMap =new Map<String,Object>();
        Map<String, Object> resultMap =new Map<String,Object>();
        Map<String,Object> ctxOutput = (Map<String,Object>)ctx.get('output');
        system.debug('ctxOutput-->'+json.serialize(ctxOutput));
        DRinputMap.put('Id',fulfilmentid);
        DRinputMap.put('GroupMemberOrderId',ctxOutput.get('GroupMemberOrderId'));
        DRinputMap.put('LeadOrderId',ctxOutput.get('LeadOrderId'));
        DRinputMap.put('controlNumber',ctxOutput.get('controlNumber'));
        DRinputMap.put('cityabbreviation',ctxOutput.get('cityabbreviation'));
        DRinputMap.put('env',ctxOutput.get('env'));    
        system.debug('DRinputMap-->'+json.serialize(DRinputMap));  
        if(DRinputMap!=null){
            vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(DRinputMap, responseDRName);
            resultMap = result.convertToMap();
        }
        
        System.debug('ResultMap : '+resultMap );
        return resultMap;
        
    }
    public static Map<String, Object> executeResponseDR(vlocity_cmt__OrchestrationItem__c item,Map<String, Object> output){
        
        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
        vlocity_cmt__FulfilmentRequestLine__c frl = [SELECT Id, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c,
                                                     vlocity_cmt__JSONAttribute__c, vlocity_cmt__Action__c, vlocity_cmt__LineNumber__c, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.Name 
                                                     FROM vlocity_cmt__FulfilmentRequestLine__c
                                                     WHERE Id=:item.vlocity_cmt__fulfilmentRequestLineId__c];
        
        String sfOrderId=frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c;
        Map<String, Object> attrVals = new Map<String, Object>();  
        if (output.get('taskName')==TASKNAME_RETRIEVECUSTOMERFACILITIES){   
            attrVals = new Map<String, Object>{ 'ControlNumber'=> output.get('controlNumber'), 'cityAbbreviation'=> output.get('cityabbreviation'), 'Environment'=> output.get('env') };
                        }else if (output.get('taskName')==TASKNAME_FINDAVAILABLETELEPHONENUMBERS){   
                            attrVals = new Map<String, Object>{ 'WTN'=> output.get('telePhoneNumber') };
                                        }
        frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
        frlsToUpdateMap.put(frl.Id,frl);
        if(frlsToUpdateMap.values().size()>0){
            try{
                List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){ System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                        }
                    }else {
                        System.debug('M6OrderStatusUpdate Successfully published event-->'+ result.getId());
                    }
                }
            } catch(Exception e) { System.debug('Exception in Subscriber..'+ e.getMessage()); return output;
            }
        }
        
        return output;
        
    }
    public static Map<String, Object> executeReserveResponseDR(vlocity_cmt__OrchestrationItem__c item,Map<String, Object> output){
        System.debug('Inside executeReserveFirstAvailableResponseDR:'+ output);
        System.debug('Output for '+item + ': '+output.get('responsebody') +', FLRId: '+ item.vlocity_cmt__fulfilmentRequestLineId__c);
        String responseObj =  (String)output.get('responsebody');
        System.debug('reserveConfirmationId val:'+responseObj);
        String reserveConfirmationId;
        String telephoneNum;
        String dateReservedUntil;
        if(responseObj != null){
            reserveConfirmationId  = responseObj.substringBetween('"reserveConfirmationId" : "', '"');
            telephoneNum = responseObj.substringBetween('"telephoneNumber" : ', ' ,');
            dateReservedUntil = responseObj.substringBetween('"dateReservedUntil" : "', '"');
        }
        
        System.debug('reserveConfirmationId val:'+reserveConfirmationId);
        //System.debug('reserveConfirmationId in ordermanagementhelper: '+responseObj.get('reserveConfirmationId') + ': telephoneNumber : '+responseObj.get('telephoneNumber')+': dateReservedUntil :'+ responseObj.get('dateReservedUntil') +', FLRId: '+ item.vlocity_cmt__fulfilmentRequestLineId__c);
        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
        vlocity_cmt__FulfilmentRequestLine__c frl = [SELECT Id, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c,
                                                     vlocity_cmt__JSONAttribute__c, vlocity_cmt__Action__c, vlocity_cmt__LineNumber__c, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.Name 
                                                     FROM vlocity_cmt__FulfilmentRequestLine__c
                                                     WHERE Id=:item.vlocity_cmt__fulfilmentRequestLineId__c];
        
        String sfOrderId=frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c;
        Map<String, Object> attrVals = new Map<String, Object>();  
        
        /*    attrVals = new Map<String, Object>{
'ReserveConfirmationId'=> output.get('reserveConfirmationId'),
'WTN'=> output.get('telephoneNumber'),
'Environment'=> output.get('env'),
'DateReservedUntil'=> output.get('dateReservedUntil'),
'cityAbbreviation'=> output.get('cityabbreviation'),
'Environment'=> output.get('env')
};*/
        attrVals = new Map<String, Object>{
            'ATTR_RESERVE_CONF_ID'=> reserveConfirmationId,
                //'WTN'=> telephoneNum,
                
                'ATTR_RESERVED_UNTIL'=>dateReservedUntil
                
                
                };
                    System.debug ('Attribute values for reserving telephone number:'+ JSON.serialize(attrVals));
        frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
        frlsToUpdateMap.put(frl.Id,frl);
        System.debug ('frlsToUpdateMap:'+ frlsToUpdateMap);
        if(frlsToUpdateMap.values().size()>0){
            try{
                List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){ System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                        }
                    }else { System.debug('M6OrderStatusUpdate Successfully published event-->'+ result.getId());
                    }
                }
            } catch(Exception e) { System.debug('Exception in Subscriber..'+ e.getMessage()); return output;
            }
        }
        
        return output;
        
    }
    public static Map<String, Object>  getBillingTNByEnvironment (String orderNumber){
        
        Map<String,Object> orchPlanByEnvmtMap = new Map<String,Object>();
        
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName ='DPI_Service_Order'];
        
        List<Service_Order__c> serviceOrders =[SELECT Name,Billing_Number__c,DPI_Env__c from Service_Order__c
                                               Where  RecordTypeId =: rt.Id
                                               //DPI Service Order 
                                               and Order__c=:orderNumber];
        System.debug('ftr_SIPOrderManagementHelper:getBillingTNByEnvironment:orderNumber-->'+ orderNumber); 
        System.debug('ftr_SIPOrderManagementHelper:getBillingTNByEnvironment:RecordType-->'+ rt.Id); 
        
        for(Service_Order__c serviceOrder : serviceOrders){
            Map<String,String> btnByEnvmtMap = new Map<String,String>();
            
            
            String billingTelephoneNumber=serviceOrder.Billing_Number__c;
            String environment = serviceOrder.DPI_Env__c;
            String groupMemberOrderId=serviceOrder.Name;
            // String leadOrderId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_LeadOrderId);
            
            if (ftr_SIPOrderManagementHelper.validTelephoneNumber(billingTelephoneNumber)){
                if (orchPlanByEnvmtMap.containsKey(environment)) { btnByEnvmtMap=(Map<String,String>)orchPlanByEnvmtMap.get(environment);
                    System.debug('ftr_SIPOrderManagementHelper:getEnv-->'+ orchPlanByEnvmtMap.get(environment));
                } 
                
                
                System.debug('ftr_SIPOrderManagementHelper:btnByEnvmttMap:hasBTN-->'+ billingTelephoneNumber); 
                
                btnByEnvmtMap.put('billingTelephoneNumber', billingTelephoneNumber);
                
                
                
                if (ftr_SIPOrderManagementHelper.validString(groupMemberOrderId)){ System.debug('ftr_SIPOrderManagementHelper:btnByEnvmttMap:isDPIOrderCreated-->True');  btnByEnvmtMap.put('isDPIOrderCreated', 'True');
                }               
                orchPlanByEnvmtMap.put(environment, btnByEnvmtMap);
                
            }
            
        }
        System.DEBUG ('orchPlanByEnvmtMap-->'+orchPlanByEnvmtMap);
        return orchPlanByEnvmtMap;
        
    }
    
    public static Map<String, Object>  getBTNbyEnvironment (String orchPlanId) {
        
        System.debug('ftr_SIPOrderManagementHelper:btnByEnvmttMap:EntryTime-->'+ System.now()); 
        Map<String,Object> orchPlanByEnvmtMap = new Map<String,Object>();
        List<vlocity_cmt__OrchestrationItem__c> orchItems =[SELECT Id, vlocity_cmt__FulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c
                                                            FROM vlocity_cmt__OrchestrationItem__c
                                                            WHERE vlocity_cmt__OrchestrationPlanId__c =:orchPlanId
                                                            AND (vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: INPUT_ITEM_DEF_WAIT_FOR_M6_ORD_COMPLETION OR vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: INPUT_ITEM_DEF_SIP_WAIT_FOR_M6_ORD_COMPLETION )// TODO: to refer an externalId field which will not change
                                                            AND (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI_CKT OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI_SIP_UNI OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =: TECH_PRODUCTCODE_DPI_SIP_TRUNKING)];
        
        System.debug('Jyue-21: ' + orchItems.size() + ' : ' + Limits.getCpuTime());
        for(vlocity_cmt__OrchestrationItem__c item : orchItems){
            String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c; 
            Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
            
            String billingTelephoneNumber=(String)myAttrVals.get(ATTR_BillingTelephoneNumber);
            String environment = (String)myAttrVals.get(ATTR_Environment);
            String groupMemberOrderId=(String)myAttrVals.get(ATTR_GroupMemberOrderId);
            String leadOrderId = (String)myAttrVals.get(ATTR_LeadOrderId);
            
            //String billingTelephoneNumber=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_BillingTelephoneNumber);
            // String environment = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_Environment);
            // String groupMemberOrderId=(String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_GroupMemberOrderId);
            // String leadOrderId = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_LeadOrderId);
            Map<String,String> btnByEnvmtMap = new Map<String,String>();
            System.debug('Jyue-22: ' + Limits.getCpuTime());
            if (ftr_SIPOrderManagementHelper.validTelephoneNumber(billingTelephoneNumber)){
                if (orchPlanByEnvmtMap.containsKey(environment)) {                   
                    btnByEnvmtMap=(Map<String,String>)orchPlanByEnvmtMap.get(environment);
                } 
                System.debug('ftr_SIPOrderManagementHelper:btnByEnvmttMap:hasBTN-->'+ billingTelephoneNumber); 
                btnByEnvmtMap.put('billingTelephoneNumber', billingTelephoneNumber);
                if (ftr_SIPOrderManagementHelper.validString(groupMemberOrderId) &&ftr_SIPOrderManagementHelper.validString(leadOrderId)){
                        System.debug('ftr_SIPOrderManagementHelper:btnByEnvmttMap:isDPIOrderCreated-->True'); 
                        btnByEnvmtMap.put('isDPIOrderCreated', 'True');
                    }               
                orchPlanByEnvmtMap.put(environment, btnByEnvmtMap);
            }            
        }         
        System.debug('Jyue-23: ' + Limits.getCpuTime());
        System.debug('ftr_SIPOrderManagementHelper:btnByEnvmttMap-->'+ orchPlanByEnvmtMap);
        System.debug('ftr_SIPOrderManagementHelper:btnByEnvmttMap:ExitTime-->'+ System.now());  
        return orchPlanByEnvmtMap;
    } 
    
    
    public static Boolean validString(String inputVar){
        Boolean validString=false;
        if (String.isNotEmpty(inputVar)&& 
            String.isNotBlank(inputVar) && 
            !inputVar.containsIgnoreCase('null') && inputVar.length()!=0){
                validString=true;  
            }
        return validString;
    }
    
    
    public static Boolean validTelephoneNumber(String inputVar){
        System.debug('ftr_SIPOrderManagementHelper:validTelephoneNumber Start-->'+ inputVar); 
        Boolean validTelephoneNumber=false;
        if (ftr_SIPOrderManagementHelper.validString(inputVar)){
            String regx='^[0]*$';
            Pattern regexPattern = Pattern.compile(regx);
            Matcher regexMatcher = regexPattern.matcher(inputVar);
            System.debug('ftr_SIPOrderManagementHelper:validTelephoneNumber regex-->'+ inputVar); 
            if(regexMatcher.matches() == true ) {
                System.debug('ftr_SIPOrderManagementHelper:validTelephoneNumber regex matcher true-->'+ inputVar);
            }else {
                validTelephoneNumber=true;
                System.debug('ftr_SIPOrderManagementHelper:validTelephoneNumber Validnumber true-->'+ inputVar);
            }    
        }
        return validTelephoneNumber;
    }
    public static Boolean publishM6OrderUpdates(Map<String, Object> inputMap){
        System.debug('ftr_SIPOrderManagementHelper:publishM6OrderUpdates:inputMap-->'+ inputMap);  
        List<PSROrderUpdate__e> statusUpdateEventList = new List<PSROrderUpdate__e>();  
        String orderId=String.valueOf(inputMap.get('orderId'));
        String orchPlanId=String.valueOf(inputMap.get('orchPlanId'));
        Map<string,Object> assetRefCKTMap = (Map<string,Object>)inputMap.get('assetRefCKTMap');
        //Iterate and Create Events
        
        for(String key :assetRefCKTMap.keySet()){        
            Map<string,Object> assetRefCKTFLRMap=(Map<string,Object>)assetRefCKTMap.get(key);
            String assetRefCKTFLRMapStr=JSON.serialize(assetRefCKTFLRMap);
            PSROrderUpdate__e  event = new PSROrderUpdate__e (Plan_Id__c = orchPlanId, Order_Number__c =orderId, JSONInput__c=assetRefCKTFLRMapStr, FRL_Reference_Id__c=key);
            statusUpdateEventList.add(event);
        }
        
        System.debug('ftr_SIPOrderManagementHelper:publishM6OrderUpdates-->'+statusUpdateEventList);
        List<Database.SaveResult> results = EventBus.publish(statusUpdateEventList);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) { System.debug('ftr_SIPOrderManagementHelper:PSROrderUpdate__e  Successfully published event..'+ sr.getId());
            } else {
                for(Database.Error err : sr.getErrors()) { System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }     
        } 
        return true;
    }
    global static Boolean CreateTask( Map<String,Object> taskDetailsMap){
        
        try{
            String groupName;
            String AssignedOrderProvisioner;
            AssignedOrderProvisioner = [Select Order_Provisioner__c From Order Where Id =: (String) taskDetailsMap.get('WhatId')].Order_Provisioner__c;
            Group grp;
            if(taskDetailsMap.containsKey('InterfaceName')) {
                String interfaceName = (String) taskDetailsMap.get('InterfaceName');
                for(ftr_OrderMgmtFallout__mdt grpStg: [Select Group_Name__c, Interface_Name__c from ftr_OrderMgmtFallout__mdt where Interface_Name__c =: interfaceName]) {
                    groupName = grpStg.Group_Name__c;
                }
            }
            if (!ftr_SIPOrderManagementHelper.validString(groupName)){ groupName='Customer Network Provisioning'; }
            //if(groupName != '' && groupName != null){
            grp = [Select Id from Group where Type = 'Queue' AND Name = :groupName];
            //}
            
            
            Task tsk = new Task();
            tsk.Status = STATUS_NOTSTARTED;         //static Variable
            tsk.Subject = (String) taskDetailsMap.get('Subject'); //'DPI OM Billing Exception';
            tsk.Priority = (String) taskDetailsMap.get('Priority'); //'High'; 
            tsk.Description = (String) taskDetailsMap.get('Description'); //'Item is not contractable: CKT|Item is not contractable: EIA2Y'; 
            //tsk.OwnerId = grp.ID; //taskDetailsMap.get('Status')
            tsk.OwnerId = AssignedOrderProvisioner;
            tsk.WhatId = (String) taskDetailsMap.get('WhatId'); //taskDetailsMap.get('WhatId')  
            insert tsk;     
            return true;
        }
        
        catch(exception e){
            return false;
        }
        
        
        
    }
    // Added by Lakshmi
    /*    public static   List<Object> getCustomerOrderItemBySNE(Map<String,Object> inputs, Map<String,Object> output) {
system.debug('getCustomerOrderItemBySNE ----'+inputs);
List<Object> orderitems =  (  List<Object>)inputs.get('order_items');
Map<String,Object>  orderItemMap = new  Map<String,Object> (); 
Map<String,Object>  describedBy  = new Map<String,Object> ();
for (Object orderItem : orderitems) {
System.debug('orderItem*** : '+orderItem);
orderItemMap =  (  Map<String,Object> )orderItem;
inputs =  (  Map<String,Object> )orderItemMap.get('described_by');
System.debug('described by*** : '+inputs);
}
system.debug('getCustomerOrderItemBySNE ----'+inputs);
List<String> lstProds;
String SNE_Code_MRC,SNE_Code_OTC,SNE_Code_TERM,EVPL_SNE_Code_MRC, EVPL_SNE_Code_OTC, EVPL_SNE_Code_TERM, UNI_SNE_CODE,IP_SNE_Code_MRC,IP_SNE_Code_OTC, IP_Quantity,IP_SNE_Code_TERM = null;
String chargeType, quantity, circuit;
List<Object> finalList = new List<Object>();
for(Object attrsObj : inputs.values()) {
List<Object> attrs = (List<Object>)attrsObj;
for (Object attrObj : attrs) {
System.debug('attrObj: '+attrObj);
Map<String, Object> attr = (Map<String, Object>)attrObj;
String attrName = (String)attr.get('characteristic');
System.debug('Attribute Name: '+attrName);
Object attrVal = attr.get('value');
if(attrName.equals('SNE_Code_MRC')){
System.debug('Attribute value: '+attrVal);
if((object)attrVal==null || attrVal.equals('')){
SNE_Code_MRC = '';
}else{
SNE_Code_MRC = (String)attrVal;
}

}
if(attrName.equals('SNE_Code_OTC')){
SNE_Code_OTC =    (String)attrVal;
}
if(attrName.equals('SNE_Code_TERM')){
SNE_Code_TERM =    (String)attrVal;
}
if(attrName.equals('EVPL_SNE_Code_MRC')){
EVPL_SNE_Code_MRC = (String)attrVal;
}
if(attrName.equals('EVPL_SNE_Code_OTC')){
EVPL_SNE_Code_OTC = (String)attrVal;
}
if(attrName.equals('EVPL_SNE_Code_TERM')){
EVPL_SNE_Code_TERM = (String)attrVal;
}
if(attrName.equals('UNI_SNE_CODE')){
UNI_SNE_CODE = (String)attrVal;
}
if(attrName.equals('IP_SNE_Code_MRC')){
IP_SNE_Code_MRC = (String)attrVal;
}
if(attrName.equals('IP_SNE_Code_OTC')){
IP_SNE_Code_OTC = (String)attrVal;
}
if(attrName.equals('IP_SNE_Code_TERM')){
IP_SNE_Code_TERM = (String)attrVal;
System.debug('IP_SNE_Code_TERM: '+IP_SNE_Code_TERM);
}
if(attrName.equals('Quantity')){
quantity = (String)attrVal;
}
if(attrName.equals('CKT_SNE_CODE')){
circuit = (String)attrVal;
}    
if(attrName.equals('IP_Quantity')){
IP_Quantity = (String)attrVal;
}             
}
}
if(SNE_Code_MRC!=null){
chargeType = 'Permanent';
String direction = 'Forward'; 
String lineItemSeq = '1';
finalList.add(createCustOrderJson(SNE_Code_MRC, lineItemSeq, quantity, chargeType, direction));

}
if(SNE_Code_OTC!=null){
chargeType = 'Temporary';
String direction = 'Forward'; 
String lineItemSeq = '1';
finalList.add(createCustOrderJson(SNE_Code_OTC, lineItemSeq, quantity, chargeType, direction));
}
if(SNE_Code_TERM!=null){ 
chargeType = 'Permanent';
String direction = 'Forward'; 
String lineItemSeq = '1';
finalList.add(createCustOrderJson(SNE_Code_TERM, lineItemSeq, quantity, chargeType, direction));
}
if(IP_SNE_Code_OTC!=null){
chargeType = 'Temporary';
String direction = 'Forward'; 
String lineItemSeq = '1';
finalList.add(createCustOrderJson(IP_SNE_Code_OTC, lineItemSeq, quantity, chargeType, direction));

}
if(IP_SNE_Code_MRC!=null){
chargeType = 'Permanent';
String direction = 'Forward'; 
String lineItemSeq = '1';
finalList.add(createCustOrderJson(IP_SNE_Code_MRC, lineItemSeq, quantity, chargeType, direction));

}
if(EVPL_SNE_Code_MRC!=null){
chargeType = 'Permanent';
String direction = 'Forward'; 
String lineItemSeq = '1';
finalList.add(createCustOrderJson(EVPL_SNE_Code_MRC, lineItemSeq, quantity, chargeType, direction));

}
if(EVPL_SNE_Code_OTC!=null){
chargeType = 'Temporary';
String direction = 'Forward'; 
String lineItemSeq = '1';
finalList.add(createCustOrderJson(EVPL_SNE_Code_OTC, lineItemSeq, quantity, chargeType, direction));

}
if(EVPL_SNE_Code_TERM!=null){
chargeType = 'Permanent';
String direction = 'Forward'; 
String lineItemSeq = '1';
finalList.add(createCustOrderJson(EVPL_SNE_Code_TERM, lineItemSeq, quantity, chargeType, direction));

}
if(IP_SNE_Code_TERM!=null){
chargeType = 'Permanent';
String direction = 'Forward'; 
String lineItemSeq = '1';
finalList.add(createCustOrderJson(IP_SNE_Code_TERM, lineItemSeq, quantity, chargeType, direction));

}
if(UNI_SNE_CODE!=null){
chargeType = 'Permanent';
String direction = 'Forward'; 
String lineItemSeq = '1';
finalList.add(createCustOrderJson(UNI_SNE_CODE, lineItemSeq, quantity, chargeType, direction));
}
//   if(circuit!=null){
//     chargeType = 'Permanent';
//  String direction = 'Forward'; 
//  String lineItemSeq = '1';
//  finalList.add(createCustOrderJson(circuit, lineItemSeq, quantity, chargeType, direction));

//}

system.debug('finalList of customerorderitem---'+finalList);
//output.put('result', finalList);
return finalList;  
} 
private static Map<String,Object> createCustOrderJson(String snecode, String lineItemSeq, String quantity, String chargeType, String direction) {
Map<String, Object> mapItem = new Map<String, Object>();
Map<String, Object> mapProduct = new Map<String, Object>();
mapProduct.put('id',snecode);
System.debug('SNE Code :'+ ': '+snecode);
mapItem.put('action','Add');
mapProduct.put('lineItemSequenceNumber',lineItemSeq);
mapItem.put('quantity',quantity);
mapItem.put('processingDirection',direction);
mapItem.put('chargeType',chargeType);
if(mapProduct!=null){
mapItem.put('product',mapProduct);
}
System.debug('mapitem is :'+mapItem);
return mapItem;
}
public static   List<Object> getCommercialContractItemBySNE(Map<String,Object> inputs, Map<String,Object> output) {
system.debug('getCommercialOrderItemBySNE ----'+inputs);
List<Object> orderitems =  (  List<Object>)inputs.get('order_items');
Map<String,Object>  orderItemMap = new  Map<String,Object> (); 
Map<String,Object>  describedBy  = new Map<String,Object> ();
for (Object orderItem : orderitems) {
System.debug('orderItem*** : '+orderItem);
orderItemMap =  (  Map<String,Object> )orderItem;
inputs =  (  Map<String,Object> )orderItemMap.get('described_by');
System.debug('described by*** : '+inputs);
}
List<String> lstProds;
List<Object> finalList = new List<Object>();

String SNE_Code_OTC, SNE_Code_MRC, SNE_Code_TERM, EVPL_SNE_Code_MRC, EVPL_SNE_Code_OTC, EVPL_SNE_Code_TERM, UNI_SNE_CODE,IP_SNE_Code_MRC,IP_SNE_Code_OTC,IP_Quantity, IP_SNE_Code_TERM, IP_monthlyRecCharge, IP_oneTimeCharge;
String monthlyRecCharge, oneTimeCharge, quantity;
Integer commQuantity, commIPQuantity;
for(Object attrsObj : inputs.values()) {
List<Object> attrs = (List<Object>)attrsObj;
for (Object attrObj : attrs) {
System.debug('attrObj: '+attrObj);
Map<String, Object> attr = (Map<String, Object>)attrObj;
String attrName = (String)attr.get('characteristic');
System.debug('Attribute Name: '+attrName);
Object attrVal = attr.get('value');
if(attrName.equals('SNE_Code_MRC')){
System.debug('Attribute value: '+attrVal);
SNE_Code_MRC = (String)attrVal;
}
if(attrName.equals('SNE_Code_OTC')){
SNE_Code_OTC =    (String)attrVal;
}
if(attrName.equals('EVPL_SNE_Code_MRC')){
EVPL_SNE_Code_MRC = (String)attrVal;
}
if(attrName.equals('EVPL_SNE_Code_OTC')){
EVPL_SNE_Code_OTC = (String)attrVal;
}
if(attrName.equals('EVPL_SNE_Code_TERM')){
EVPL_SNE_Code_TERM = (String)attrVal;
}
if(attrName.equals('UNI_SNE_CODE')){
UNI_SNE_CODE = (String)attrVal;
}
if(attrName.equals('IP_SNE_Code_MRC')){
IP_SNE_Code_MRC = (String)attrVal;
}
if(attrName.equals('IP_SNE_Code_OTC')){
IP_SNE_Code_OTC = (String)attrVal;
}
if(attrName.equals('IP_SNE_Code_TERM')){
IP_SNE_Code_TERM = (String)attrVal;
System.debug('IP_SNE_Code_TERM: '+IP_SNE_Code_TERM);
}
if(attrName.equals('RecurringCharge')){
monthlyRecCharge = (String)attrVal;
}
if(attrName.equals('OneTimeTotal')){
oneTimeCharge = (String)attrVal;
}
if(attrName.equals('EVPL_RecurringCharge')){
monthlyRecCharge = (String)attrVal;
}
if(attrName.equals('EVPL_OneTimeTotal')){
oneTimeCharge = (String)attrVal;
}
if(attrName.equals('IP_RecurringCharge')){
IP_monthlyRecCharge = (String)attrVal;
}
if(attrName.equals('IP_OneTimeTotal')){
IP_oneTimeCharge = (String)attrVal;
} 
if(attrName.equals('Quantity')){
quantity = (String)attrVal;

commQuantity = Integer.valueOf(quantity);
}
if(attrName.equals('IP_Quantity')){
IP_Quantity = (String)attrVal;
commIPQuantity = Integer.valueOf(IP_Quantity);
} 
}
}
if(SNE_Code_MRC!=null){
finalList.add(createCommercialContractJson(SNE_Code_MRC, null, monthlyRecCharge, commQuantity));
}
if(SNE_Code_OTC!=null){
finalList.add(createCommercialContractJson(SNE_Code_OTC, oneTimeCharge, null, commQuantity));
}
if(SNE_Code_TERM!=null){
finalList.add(createCommercialContractJson(SNE_Code_TERM, null, null, commQuantity));
}
//    if(IP_SNE_Code_MRC!=null){
//    finalList.add(createCommercialContractJson(IP_SNE_Code_MRC,  null, IP_monthlyRecCharge, commIPQuantity));
//   }
//  if(IP_SNE_Code_OTC!=null){
//       finalList.add(createCommercialContractJson(IP_SNE_Code_OTC, IP_oneTimeCharge, null, commIPQuantity));
//  }
if(EVPL_SNE_Code_MRC!=null){
finalList.add(createCommercialContractJson(EVPL_SNE_Code_MRC, null, monthlyRecCharge, commQuantity));
}
if(EVPL_SNE_Code_OTC!=null){
finalList.add(createCommercialContractJson(EVPL_SNE_Code_OTC, oneTimeCharge, null, commQuantity));
}
if(EVPL_SNE_Code_TERM!=null){
finalList.add(createCommercialContractJson(EVPL_SNE_Code_TERM, null, null, commQuantity));
}
//  if(IP_SNE_Code_TERM!=null){
//      finalList.add(createCommercialContractJson(IP_SNE_Code_TERM,  null, null, commQuantity));
//  }


system.debug('finalList---'+finalList.size() + finalList);

//output.put('result', finalList);
return finalList;  
}
private static Map<String,Object> createCommercialContractJson(String snecode, String oneTimeCharge, String monthlyRecCharge, Integer commQuantity) {
Map<String, Object> mapItem = new Map<String, Object>();
Map<String, Object> mapMRCRate = new Map<String, Object>();
Map<String, Object> mapNRCRate = new Map<String, Object>();
String quantity  = String.ValueOf(commQuantity);
System.debug('SNE code inside createcomcontract :' +snecode);
mapItem.put('productId',snecode);
mapItem.put('quantity',quantity);
if(oneTimeCharge!=null){
mapNRCRate.put('amount',oneTimeCharge);
mapItem.put('nonRecurringChargeRate',mapNRCRate);
}
if(monthlyRecCharge!=null){
mapMRCRate.put('amount',monthlyRecCharge);
mapItem.put('monthlyRecurringChargeRate',mapMRCRate);
}
return mapItem;
} */
}