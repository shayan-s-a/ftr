/**
* @description webservice callout to ServiceItemRequest L2 interface
* @version :1
*/  
global with sharing class ftr_PSROrderCompletionUpdateSubscriber implements vlocity_cmt.VlocityOpenInterface {
    public final static String TECH_PRODUCTCODE_EIA = 'ENT_ETH_EIA_EVC_PSR_001';
    public final static String TECH_PRODUCTCODE_UNI = 'ENT_ETH_UNI_PSR_001';
    public final static String TECH_PRODUCTCODE_EVPL_EVC = 'ENT_ETH_EVPL_EVC_PSR_001';
    public final static String TECH_PRODUCTCODE_DPI = 'ENT_ETH_DPI_CIRCUIT_BILLING';
	public final static String TECH_PRODUCTCODE_DPI_ELAN = 'ENT_ETH_ELAN_DPI';
    public final static String TECH_PRODUCTCODE_ELAN = 'ENT_ETH_ELAN_EVC_PSR_001'; 
    //SIP Trunking thecnical products
    public final static String TECH_PRODUCTCODE_SIP_UNI = 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_SIP_EVC = 'SIP_EVC_PSR_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_DPI_SIP_UNI = 'DPI_CIRCUIT_BILLING_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_DPI_SIP_TRUNKING = 'SIP_TRUNKING_DPI_BILLING_RES_SPEC_0010';
    public final static String TECH_PRODUCTCODE_DPI_MDN_RFS = 'DID_DPI_MDN_RFS_0010';


    public final static String ATT_Corelation_Id = 'CorrelationId';
    public final static String TECH_M6_IsOrderCompleted = 'ATTR_M6_IsOrderCompleted';
    public final static String INPUT_EVENT = 'events';
    public final static String INPUT_STATE_COMP = 'Completed';
    public final static String INPUT_STATE_RUNNING = 'Running';
    public final static String INPUT_STATE_PENDING = 'Pending';
    public final static String INPUT_ITEM_WAIT_BCN_COMPLETE = 'Wait for BCN Complete';
    public final static String INPUT_ITEM_WAIT_SIP_BCN_COMPLETE = 'SIP Wait for BCN Complete';
    public final static String INPUT_ITEM_WAIT_SIP_BCN_READY = 'SIP Wait for BCN Ready';
    public final static String ATTR_GRP_ORD_TRANSACTION_COUNT = 'GroupOrderTransactionCount';
    //public final static String INPUT_ITEM_DEFINITION_DPI = 'Wait for M6Orders Completion';
    public final static String INPUT_ITEM_DEF_WAIT_FOR_M6_ORD_COMPLETION = 'Wait for M6Orders Completion';
    public final static String INPUT_ITEM_DEF_SIP_WAIT_FOR_M6_ORD_COMPLETION = 'SIP Wait for M6Orders Completion';

    public final static String ATTR_IsSubmitOrderToDPI = 'ATTR_IsSubmitOrderToDPI';
    public final static String ATTR_IsBTNOrderComplete = 'ATTR_IsBTNOrderComplete';
    public final static String ATTR_WorkingTelephoneNumber = 'WorkingTelephoneNumber';
    public final static String ATTR_BillingTelephoneNumber = 'BillingTelephoneNumber';
    public final static String ATTR_Environment = 'Environment';

    public final static String ATTR_REF_ID = 'ATTR_FRLRefId';
    public final static String ATTR_WTN = 'WTN';

    public final static String EXECUTE_METHOD = 'execute';
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter ftr_PSROrderCompletionUpdateToDPISubscriber .' + methodName);
        try {
            if (methodName == EXECUTE_METHOD) {
                return execute(methodName, inputMap, outputMap);
            }
            return true;
        } catch (Exception ex) {
            System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            return false;
        } finally {
            System.debug('Exit ftr_PSROrderCompletionUpdateToDPISubscriber.' + methodName);
        }
    }
    public Boolean execute(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap) {
        List<PSR_OrderCompletion_Update__e> evs;
        Boolean setBTNOrder = false;
        if (inputMap.Containskey(INPUT_EVENT)) {
            evs = (List<PSR_OrderCompletion_Update__e>) inputMap.get(INPUT_EVENT);
        }

        Map<Id, vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id, vlocity_cmt__FulfilmentRequestLine__c>();
        Set<Id> orchPlanIds = new Set<Id>();
        //Map<String,String> eventMapcorrelation = new Map<String,String>();
        Map<String, String> orderCompletionEvent = new Map<String, String>();
        Map<String, String> commercialProductMap = new Map<String, String>();
        //Map<String,Integer> transactioncount = new Map<String,Integer>();
        Map<String, Integer> memberCntCorrelationIdMap = new Map<String, Integer>();
        for (PSR_OrderCompletion_Update__e singleEvent : evs) {
            orchPlanIds.add(singleEvent.Plan_Id__c);
            orderCompletionEvent.put(singleEvent.FRL_Reference_Id__c, singleEvent.JSONAttribute__c);
            System.debug('PSROrderCompletion:orderCompletionEvent-->' + orderCompletionEvent);
            //System.debug('PSROrderCompletion:eventMapcorrelation-->'+eventMapcorrelation);
        }
        List<vlocity_cmt__OrchestrationItem__c> items = [
            SELECT
                Id,
                vlocity_cmt__FulfilmentRequestLineId__c,
                vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c,
                vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,
                vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c,
                vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c,
                vlocity_cmt__OrchestrationPlanId__c
            FROM vlocity_cmt__OrchestrationItem__c
            WHERE
                vlocity_cmt__State__c = :INPUT_STATE_COMP
                AND vlocity_cmt__OrchestrationPlanId__c IN :orchPlanIds
                AND (vlocity_cmt__OrchestrationItemDefinitionId__r.Name = :INPUT_ITEM_WAIT_BCN_COMPLETE OR vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: INPUT_ITEM_WAIT_SIP_BCN_COMPLETE OR vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: INPUT_ITEM_WAIT_SIP_BCN_READY) // TODO: to refer an externalId field which will not change
                AND (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = :TECH_PRODUCTCODE_EIA
                OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = :TECH_PRODUCTCODE_UNI
                OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = :TECH_PRODUCTCODE_EVPL_EVC
                OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = :TECH_PRODUCTCODE_SIP_UNI
                OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = :TECH_PRODUCTCODE_SIP_EVC
				OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = :TECH_PRODUCTCODE_ELAN)
        ];

        //Take UNI as we need use commercialProductMap
        for (vlocity_cmt__OrchestrationItem__c item : items) {
            String jsonAttribute = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
            //System.debug('PSROrderCompletion:jsonattribute--'+jsonAttribute);
            Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);

            String correlationId=(String)myAttrVals.get(ATT_Corelation_Id);
            String attrFRLRefId=(String)myAttrVals.get(ATTR_REF_ID);
            String IsM6completed=(String)myAttrVals.get(TECH_M6_IsOrderCompleted);
            

            //String correlationId = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_Corelation_Id);
            String productCode = item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
            //String attrFRLRefId = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_REF_ID);
            commercialProductMap.put(attrFRLRefId, productCode);
            //Integer.valueof(ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_GRP_ORD_TRANSACTION_COUNT));
            //String IsM6completed = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, TECH_M6_IsOrderCompleted);
            System.debug('PSROrderCompletion:correlationId-->' + correlationId);
            System.debug('PSROrderCompletion:ProductCode--->' + item.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode);
            System.debug('PSROrderCompletion:ItemId--->' + item.Id);
            System.debug('PSROrderCompletion:IsM6completed--' + IsM6completed);
            if (IsM6completed == 'true') {
                if (memberCntCorrelationIdMap.containsKey(correlationId)) {
                    Integer memberCount = memberCntCorrelationIdMap.get(correlationId);
                    memberCount++;
                    memberCntCorrelationIdMap.put(correlationId, memberCount);
                } else {
                    memberCntCorrelationIdMap.put(correlationId, 1);
                }
            }
            System.debug('PSROrderCompletion:memberCntCorrelationIdMap--' + memberCntCorrelationIdMap);
            System.debug('PSROrderCompletion:MemberCount-->' + memberCntCorrelationIdMap.get(correlationId));
        }

        System.enqueueJob(new ConfirmPSROrderCompletion(memberCntCorrelationIdMap, commercialProductMap, orchPlanIds));
        return true;
    }

    public without sharing class ConfirmPSROrderCompletion implements Queueable {

        Map<String, Integer> memberCntCorrelationIdMap = new Map<String, Integer>();
        Map<String, String> commercialProductMap = new Map<String, String>();
        Set<Id> orchPlanIds = new Set<Id>();

        public ConfirmPSROrderCompletion(
            Map<String, Integer> memberCntCorrelationIdMap,
            Map<String, String> commercialProductMap,
            Set<Id> orchPlanIds
        ) {
            this.memberCntCorrelationIdMap = memberCntCorrelationIdMap;
            this.commercialProductMap = commercialProductMap;
            this.orchPlanIds = orchPlanIds;
        }

        public void execute(QueueableContext context) {
            String result;
            try {
                processPSROrderCompletion();
            } catch (Exception ex) {
            }
        }

        public void processPSROrderCompletion() {

            System.debug('INSIDE processPSROrderCompletion:: ');
            //if(memberOrdersProvisioningComplete == true){
            //setBTNOrder=true;
            Map<String, Object> orchPlanBTNMap = new Map<String, Object>();
            Map<String, Boolean> setBTNOrderCorrelationIdMap = new Map<String, Boolean>();
            Map<Id, vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id, vlocity_cmt__FulfilmentRequestLine__c>();
            List<vlocity_cmt__OrchestrationItem__c> DPIPlanitems = [
                SELECT
                    Id,
                    vlocity_cmt__FulfilmentRequestLineId__c,
                    vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c,
                    vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,
                    vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c,
                    vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c,
                    vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c
                FROM vlocity_cmt__OrchestrationItem__c
                WHERE
                    (vlocity_cmt__State__c = :INPUT_STATE_RUNNING
                    OR vlocity_cmt__State__c = :INPUT_STATE_PENDING)
                    AND vlocity_cmt__OrchestrationPlanId__c IN :orchPlanIds
                    AND (vlocity_cmt__OrchestrationItemDefinitionId__r.Name = :INPUT_ITEM_DEF_WAIT_FOR_M6_ORD_COMPLETION OR vlocity_cmt__OrchestrationItemDefinitionId__r.Name = :INPUT_ITEM_DEF_SIP_WAIT_FOR_M6_ORD_COMPLETION)// TODO: to refer an externalId field which will not change
                    AND (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = :TECH_PRODUCTCODE_DPI OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = :TECH_PRODUCTCODE_DPI_SIP_UNI OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = :TECH_PRODUCTCODE_DPI_SIP_TRUNKING OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = :TECH_PRODUCTCODE_DPI_MDN_RFS OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode =:TECH_PRODUCTCODE_DPI_ELAN)
            ];


            System.debug('processPSROrderCompletion -->' + JSON.serialize(DPIPlanitems));
            for (vlocity_cmt__OrchestrationItem__c DPIitem : DPIPlanitems) {
                String productCode = DPIitem.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode;
                String jsonAttribute = DPIitem.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
                Map<String, Object> myAttrValsDPI = ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);

                vlocity_cmt__FulfilmentRequestLine__c frl = new vlocity_cmt__FulfilmentRequestLine__c(
                    Id = DPIitem.vlocity_cmt__FulfilmentRequestLineId__c,
                    vlocity_cmt__JSONAttribute__c = jsonAttribute
                );

                String IsBTNOrderComplete = (String)myAttrValsDPI.get(ATTR_IsBTNOrderComplete) == null ? 'false' : (String)myAttrValsDPI.get(ATTR_IsBTNOrderComplete);
                String attrFRLRefId = (String)myAttrValsDPI.get(ATTR_REF_ID);
                
                String correlationId = (String)myAttrValsDPI.get(ATT_Corelation_Id);
                String workingTelephoneNumber = (String)myAttrValsDPI.get(ATTR_WorkingTelephoneNumber);
                String billingTelephoneNumber = (String)myAttrValsDPI.get(ATTR_BillingTelephoneNumber);
                String grpTransactionCount = (String)myAttrValsDPI.get(ATTR_GRP_ORD_TRANSACTION_COUNT);

               // String IsBTNOrderComplete = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_IsBTNOrderComplete);
                //String attrFRLRefId = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_REF_ID);
               // Integer grpTransactionCount = Integer.valueof(ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_GRP_ORD_TRANSACTION_COUNT));
                //String eventProductCode=eventMapcorrelation.get('productCode');

                //String correlationId = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATT_Corelation_Id);
                //String workingTelephoneNumber = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_WorkingTelephoneNumber);
                //String billingTelephoneNumber = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_BillingTelephoneNumber);
                System.debug('PSROrderCompletion:corelationid-->' + correlationId );
                System.debug('PSROrderCompletion:->IsBTNOrderComplete-->'+IsBTNOrderComplete);
                System.debug('PSROrderCompletion:attrFRLRefId-->' + attrFRLRefId );
                System.debug('PSROrderCompletion:-->workingTelephoneNumber-->'+workingTelephoneNumber);
                System.debug('PSROrderCompletion:billingTelephoneNumber-->' + billingTelephoneNumber );
                System.debug('PSROrderCompletion:-->grpTransactionCount-->'+grpTransactionCount);
                System.debug('PSROrderCompletion:-->commercialProductMap-->'+JSON.serialize(commercialProductMap));

                if (
                    (commercialProductMap.get(attrFRLRefId) == TECH_PRODUCTCODE_EIA ||
                    commercialProductMap.get(attrFRLRefId) == TECH_PRODUCTCODE_EVPL_EVC  ||
                    commercialProductMap.get(attrFRLRefId) == TECH_PRODUCTCODE_SIP_EVC   ||
                    commercialProductMap.get(attrFRLRefId) == TECH_PRODUCTCODE_SIP_UNI || commercialProductMap.get(attrFRLRefId) == TECH_PRODUCTCODE_ELAN) &&
                    memberCntCorrelationIdMap.containsKey(correlationId) &&
                    memberCntCorrelationIdMap.get(correlationId) == Integer.valueOf(grpTransactionCount)
                ) {
                    System.debug('PSROrderCompletion:Matching CorrelationId/GrpTransactionCount :attrFRLRefId-->' + attrFRLRefId);
                    System.debug('PSROrderCompletion:Before:IsBTNOrderComplete-->' + IsBTNOrderComplete);
                    System.debug('PSROrderCompletion:Before:IsBTNOrderComplete-->' + IsBTNOrderComplete);
                    if ((!IsBTNOrderComplete.equalsIgnoreCase('TRUE')) && !setBTNOrderCorrelationIdMap.containsKey(correlationId)) {
                        //SetBTN Order Exists
                        //            setBTNOrder=true;
                        //setBTNOrderCorrelationIdMap.put(correlationId, true);
                        String orchplanId = DPIitem.vlocity_cmt__OrchestrationPlanId__c;
                        //String OrderNumber = DPIitem.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__c;
                        //System.debug('PSROrderCompletion:Before:OrderNumber-->' + OrderNumber);
                        //String environment = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, ATTR_Environment);
                        String environment = (String)myAttrValsDPI.get(ATTR_Environment);
                        Map<String, Object> InputKeyVal = new Map<String, Object>();
                        Map<String, Object> attrVals = new Map<String, Object>();
                        Map<String, String> btnByEnvmtMap = new Map<String, String>();

                        if (ftr_OrderManagementHelper.validTelephoneNumber(billingTelephoneNumber)) {
                            System.debug('PSROrderCompletion:Set Existing BTN-->' + billingTelephoneNumber);

                            attrVals = new Map<String, Object>{
                                ATTR_IsSubmitOrderToDPI => 'true',
                                ATTR_IsBTNOrderComplete => 'True',
                                ATTR_BillingTelephoneNumber => billingTelephoneNumber
                            };
                            btnByEnvmtMap.put(environment, billingTelephoneNumber); //This is to set exsiting BTN for same Env if not selected
                        } else {
                            System.debug('PSROrderCompletion:Not an Existing BTN-->' + billingTelephoneNumber);
                            System.debug('PSROrderCompletion:Before:orchplanId-->' + orchplanId);
                            Map<String, Object> orchPlanByEnvmtMap = ftr_OrderManagementHelper.getBTNbyEnvironment(orchplanId);
                                       
                            //Map<String,Object> orchPlanByEnvmtMap=ftr_OrderManagementHelper.getBillingTNByEnvironment (OrderNumber);  
                            //add the existing btnByEnvmtMap
                            if (orchPlanBTNMap.containsKey(orchplanId)) {
                                Map<String, String> btnByEnvmtExistOrchMap = (Map<String, String>) orchPlanBTNMap.get(orchplanId);

                                for (String key : btnByEnvmtExistOrchMap.keySet()) {
                                    btnByEnvmtMap.put(key, btnByEnvmtExistOrchMap.get(key));
                                }
                                orchPlanBTNMap.put(orchplanId, btnByEnvmtMap);
                            }

                            Map<String, String> btnByEnvmtCurrentMap = new Map<String, String>();
                            btnByEnvmtCurrentMap = (Map<String, String>) orchPlanByEnvmtMap.get(environment); //FT: BTN/Flag
                            System.debug('PSROrderCompletion:!btnByEnvmtCurrentMap.isEmpty()-->' + btnByEnvmtCurrentMap);
                            if (
                                btnByEnvmtCurrentMap != null &&
                                !btnByEnvmtCurrentMap.isEmpty() &&
                                ftr_OrderManagementHelper.validString(btnByEnvmtCurrentMap.get('billingTelephoneNumber'))
                            ) {
                                btnByEnvmtMap.put(environment, btnByEnvmtCurrentMap.get('billingTelephoneNumber'));
                            }
                            if (ftr_OrderManagementHelper.validTelephoneNumber(btnByEnvmtMap.get(environment))) {
                                System.debug('PSROrderCompletion:getBTNbyEnvironment-->' + btnByEnvmtMap.get(environment));
                                if (
                                    btnByEnvmtCurrentMap != null &&
                                    !btnByEnvmtCurrentMap.isEmpty() &&
                                    ftr_OrderManagementHelper.validString(btnByEnvmtCurrentMap.get('isDPIOrderCreated')) &&
                                    btnByEnvmtCurrentMap.get('isDPIOrderCreated') == 'True'
                                ) {
                                    attrVals = new Map<String, Object>{
                                        ATTR_IsSubmitOrderToDPI => 'true',
                                        ATTR_IsBTNOrderComplete => 'True',
                                        ATTR_BillingTelephoneNumber => btnByEnvmtMap.get(environment)
                                    };
                                } else {
                                    //else isBTNOrderNotSet
                                    System.debug('ENTER SIP SECOND TIME:::');
                                    if(commercialProductMap.get(attrFRLRefId) == TECH_PRODUCTCODE_SIP_EVC   ||
                                    commercialProductMap.get(attrFRLRefId) == TECH_PRODUCTCODE_SIP_UNI){
                                        attrVals = new Map<String, Object>{
                                            ATTR_IsSubmitOrderToDPI => 'true',
                                            ATTR_IsBTNOrderComplete => 'True',
                                            ATTR_BillingTelephoneNumber => btnByEnvmtMap.get(environment)
                                        };
                                    } else {
                                        attrVals = new Map<String, Object>{
                                            ATTR_IsSubmitOrderToDPI => 'true',
                                            ATTR_BillingTelephoneNumber => btnByEnvmtMap.get(environment)
                                        };
                                    }
                                }
                            } else {
                                System.debug('ftr_OrderManagementHelper:set WTN as BTN-->' + btnByEnvmtMap.get(environment));
                                attrVals = new Map<String, Object>{
                                    ATTR_IsSubmitOrderToDPI => 'true',
                                    ATTR_IsBTNOrderComplete => 'True',
                                    ATTR_BillingTelephoneNumber => workingTelephoneNumber
                                };
                                btnByEnvmtMap.put(environment, workingTelephoneNumber);
                            }
                        }
                        orchPlanBTNMap.put(orchplanId, btnByEnvmtMap);
                        frl.vlocity_cmt__JSONAttribute__c = (String) ftr_CpqHelper.setJSONAttributes(
                            frl.vlocity_cmt__JSONAttribute__c,
                            '{}',
                            attrVals
                        );
                        frlsToUpdateMap.put(frl.Id, frl);
                        System.debug('PSROrderCompletion:frlsToUpdateMap Final--> ' + JSON.serialize(frlsToUpdateMap));
                    } else {
                        //
                        Map<String, Object> attrVals = new Map<String, Object>{ ATTR_IsSubmitOrderToDPI => 'true' };
                        frl.vlocity_cmt__JSONAttribute__c = (String) ftr_CpqHelper.setJSONAttributes(
                            frl.vlocity_cmt__JSONAttribute__c,
                            '{}',
                            attrVals
                        );
                        frlsToUpdateMap.put(frl.Id, frl);
                    }
                }
            }

            //  }
            if (frlsToUpdateMap.values().size() > 0) {
                try {
                    List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);

                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()) {
                            for (Database.Error err : result.getErrors()) {
                                System.debug('PSROrderCompletion:Error in Subscriber: ' + err.getStatusCode() + ' ' + err.getMessage());
                            }
                        } else {
                            System.debug('PSROrderCompletion Successfully published event-->' + result.getId());
                        }
                    }
                } catch (Exception e) {
                    System.debug('Exception in Subscriber..' + e.getMessage());
                }
            }
        }
    }
}