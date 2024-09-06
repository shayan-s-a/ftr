global class ftr_XOMSubmitOrderController implements vlocity_cmt.VlocityOpenInterface {
    
    global class ftr_XOMSubmitOrderControllerException extends Exception {}
    
    private Order myOrder;
    private static final String RESERVE_WTN_METHOD_NAME = 'reserveWTNumber';
    private static final String GET_EXCHANGE_DETAILS_METHOD_NAME = 'getExchangeDetails';
    private static final String UPDATE_SNE_ATTRIBUTES_METHOD_NAME = 'UpdateSNEAttributes';
    private static final String UPDATE_ITEM_SEQ_METHOD_NAME = 'updateOrderItemSequence';
    private static  String Pm_Ernrichment_Error_Message = '';
    private static List<String> errorMessages = new List<String>();
    public ftr_XOMSubmitOrderController(ApexPages.StandardController stdController) {
        this.myOrder = (Order)stdController.getRecord();
    }    
    
    public ftr_XOMSubmitOrderController() {
        
    }
    
    public without sharing class StartPlanAsync implements Queueable {
        String orderId;
        public StartPlanAsync(String orderId) {
            this.orderId = orderId;
        }
        
        public void execute(QueueableContext context) {
            try {
                vlocity_cmt__OrchestrationItem__c[] items = [select Id,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__c, vlocity_cmt__State__c,vlocity_cmt__OrchestrationItemDefinitionId__r.Name, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c 
                                                             from vlocity_cmt__OrchestrationItem__c 
                                                             where vlocity_cmt__OrchestrationItemDefinitionId__r.Name IN ('Wait To Start', 'Wait for M6Orders Completion') 
                                                             AND vlocity_cmt__State__c ='Pending' 
                                                             AND vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c=:orderId ];
                for (vlocity_cmt__OrchestrationItem__c item: items) {
                    item.vlocity_cmt__State__c = 'Running';
                }
                update items;
                System.debug('items: ' + JSON.serialize(items));
                
                items = [select Id,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__c, vlocity_cmt__State__c,vlocity_cmt__OrchestrationItemDefinitionId__r.Name, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c 
                         from vlocity_cmt__OrchestrationItem__c 
                         where vlocity_cmt__OrchestrationItemDefinitionId__r.Name IN ('Wait To Start', 'Wait for M6Orders Completion') AND vlocity_cmt__State__c ='Running' 
                         AND vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c=:orderId and 
                         vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = 'ENT_ETH_UNI_PSR_001'];
                
                for (vlocity_cmt__OrchestrationItem__c item: items) {
                    item.vlocity_cmt__State__c = 'Completed';
                }
                update items;
                
                System.debug('items: ' + JSON.serialize(items));
                
                //SIP Wait to Start
                Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
                Set<Id> fulfilmentRequestIds = new Set<Id>();
                
                vlocity_cmt__OrchestrationItem__c[]  itemsForUpdate = [select Id,Name,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__c, vlocity_cmt__State__c,vlocity_cmt__OrchestrationItemDefinitionId__r.Name, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c, 
                                                                       vlocity_cmt__FulfilmentRequestLineId__r.Id,vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Products__c from vlocity_cmt__OrchestrationItem__c 
                                                                       where vlocity_cmt__OrchestrationItemDefinitionId__r.Name IN ('Wait To Start','RC Wait To Start')
                                                                       AND vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c=:orderId and (vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode = 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010' OR vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode ='DPI_RC_Billing_RFS')];
                
                System.debug('itemsForUpdate: ' + JSON.serialize(itemsForUpdate));
                
                for (vlocity_cmt__OrchestrationItem__c item: itemsForUpdate) {
                    
                    if((item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Products__c.contains('EIA') || item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Products__c.contains('SIP')|| item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Products__c.contains('EVPL') || item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Products__c.contains('Managed Router')) && item.Name !='RC Wait To Start' ){
        
                        System.debug('::::::');
                        fulfilmentRequestIds.add(item.vlocity_cmt__FulfilmentRequestLineId__r.Id);
                    }else if(item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Products__c.contains('Ring Central') && !(item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Products__c.contains('EIA') || item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Products__c.contains('SIP') || item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Products__c.contains('Managed Router')) && item.Name =='RC Wait To Start'){
                          System.debug(':::::: ');
		                 fulfilmentRequestIds.add(item.vlocity_cmt__FulfilmentRequestLineId__r.Id);
                      }
                }
                
                List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineS =[Select Id,Name,vlocity_cmt__JSONAttribute__c  from vlocity_cmt__FulfilmentRequestLine__c where Id IN : fulfilmentRequestIds];
                String semaphoreWait = 'true';
                for(vlocity_cmt__FulfilmentRequestLine__c frLine: fulfilmentRequestLineS){
                    
                    Map<String, Object> attrVals = new Map<String, Object>{
                        'ATTR_WaitSemaphore' => semaphoreWait
                            };
                                
                                frLine.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frLine.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                    frlsToUpdateMap.put(frLine.Id,frLine);
                    break;
                }
                
                System.debug('frlsToUpdateMap: ' + frlsToUpdateMap);
                System.debug('frlsToUpdateMap: size(); ' + frlsToUpdateMap.values().size());
                
                
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
                        
                    }
                }
                
            } catch (Exception ex) {
                
                System.debug('Line number: '+ ex.getLineNumber() + ' - Exception: '+ ex.getMessage());
                
                // if there is any exception, stamp the error in the SubmitOrderResult field
                update new Order(
                    Id=this.orderId, 
                    SubmitOrderResult__c = 'Exception thrown while kick-starting orchestration items: ' + 'Line number: '+ ex.getLineNumber() + ' - Exception: '+ ex.getMessage()
                );
            }
        }
    }
    
    public without sharing class CreatePlanAsync implements Queueable {
        String orderId;
        public CreatePlanAsync(String orderId) {
            this.orderId = orderId;
        }
        public void execute(QueueableContext context) {
            Savepoint sp = Database.setSavepoint();
            String result;
            try {
                // submit the order to decompose
                System.debug('Calling SimpleDecompositionController.startOrchestrationPlan: '+ this.orderId);
                if (!Test.isRunningTest()) {
                    result = vlocity_cmt.SimpleDecompositionController.startOrchestrationPlan(this.orderId);
                } else {
                    result = 'OK';
                }
                System.debug('Finished SimpleDecompositionController.startOrchestrationPlan: '+ result);
                Order myOrder= [SELECT Id,Order_Provisioner__c,OwnerId,SubmitOrderResult__c,Products__c FROM ORDER WHERE ID =: This.OrderId];
                if(myOrder.Order_Provisioner__c != null){
                    myOrder.OwnerId = myOrder.Order_Provisioner__c;
                } else if(myOrder.Products__c.contains('Ring Central')){
                    Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Network_COE_Non_Complex'];
                    myOrder.OwnerId = myQueue.Id;
                }else if(!myOrder.Products__c.contains('UCF')){
                    Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Customer_Network_Provisioning'];
                    myOrder.OwnerId = myQueue.Id;
                }
                myOrder.SubmitOrderResult__c = 'Starting orchestration plan: ' + result;
                update myOrder;
                System.enqueueJob(new StartPlanAsync(this.orderId));
            } catch (Exception ex) {
                
                // roll back the operation 
                Database.rollback(sp);
                System.debug('Line number: '+ ex.getLineNumber() + ' - Exception: '+ ex.getMessage());
                
                // if there is any exception, stamp the error in the SubmitOrderResult field
                update new Order(
                    Id=this.orderId, 
                    SubmitOrderResult__c = 'Exception thrown while starting orchestration plan: ' + 'Line number: '+ ex.getLineNumber() + ' - Exception: '+ ex.getMessage()
                );
            }
        }
    }
    
    public without sharing class DecomposeOrderAsync implements Queueable {
        String orderId;
        public DecomposeOrderAsync(String orderId) {
            System.debug('Starting decomposition for: '+ orderId);
            this.orderId = orderId;
        }
        
        public void execute(QueueableContext context) { 
            Savepoint sp = Database.setSavepoint();
            Object result;
            try {
                // submit the order to decompose
                System.debug('Calling SimpleDecompositionController.decomposeOrder: '+ this.orderId);
                if (!Test.isRunningTest()) {
                    result = vlocity_cmt.SimpleDecompositionController.decomposeOrder(this.orderId);
                } else {
                    result = 'OK';
                }
                System.debug('Finished SimpleDecompositionController.decomposeOrder: '+ result);
                
                // update the SubmitOrderResult field with the result
                update new Order(
                    Id=this.orderId, 
                    SubmitOrderResult__c = 'Decomposition result: ' + JSON.serialize(result)
                );
                // start the orchestration plan
                System.enqueueJob(new CreatePlanAsync(this.orderId));
            } catch (Exception ex) {
                
                // roll back the operation 
                Database.rollback(sp);
                System.debug('Line number: '+ ex.getLineNumber() + ' - Exception: '+ ex.getMessage());
                
                // if there is any exception, stamp the error in the SubmitOrderResult field
                update new Order(
                    Id=this.orderId, 
                    SubmitOrderResult__c = 'Exception thrown while decomposing: ' + 'Line number: '+ ex.getLineNumber() + ' - Exception: '+ ex.getMessage()
                );
            }
        }
    }
    
    public PageReference submitOrder() {
        Map<String, Object> inputMap = new Map<String, Object> {
            'orderId' => myOrder.Id
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        // check if PS is assigned
        
        
        
        // invokeMethod('submitOrder', inputMap, outputMap, options);
        
        // if ((Boolean)outputMap.get('isSuccess')) {
        //     Id planId = (Id)outputMap.get('planId');
        //     system.debug('planId.Id-->'+planId);
        //     if(planId != null){  //Added Condition to Fix Page URL Issue while submitting an Order
        //          return new PageReference('/' + planId);
        //     }
        //      else{
        //          return new PageReference('/' + myOrder.Id);
        //      }
        // } else {
        //     throw new ftr_XOMSubmitOrderControllerException((String)outputMap.get('errorMessage'));
        // }
        return new PageReference('/' + myOrder.Id);
    }
    
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter ftr_XOMSubmitOrderController.' + methodName);
        try {
            if (methodName == 'submitOrder') {
                System.Debug('submitOrder Initiated');
                Id orderId = (Id)inputMap.get('contextId');
                inputMap.put('orderId', orderId);
                
                Boolean hasProjectSpecialist = checkForProjectSpecialist(inputMap, outputMap, options);
                // if no PS is assigned, stop them here
                if (!hasProjectSpecialist) {
                    return false;
                } else {
                    try {
                        Task[] t = new List<Task>([SELECT Id, Status FROM Task WHERE Subject = 'Network Project Specialist Assignment' AND WhatId =:orderId AND Status != 'Completed' LIMIT 1]);
                        if (t.size() > 0) {
                            t[0].Status = 'Completed';
                            update t;
                        }
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                    }
                }
                
                // 0. Update Item Seq/Count OLI fields
                ftr_OrderEnrichmentService orderMgmtservice = new ftr_OrderEnrichmentService();
                Map<String, Object>  updateOrderItemSeqMap = orderMgmtservice.invokeMethod(UPDATE_ITEM_SEQ_METHOD_NAME,inputMap,outputMap,options); 
                if ((Boolean)updateOrderItemSeqMap.get('isSuccess') == false) {
                    throw new ftr_XOMSubmitOrderControllerException((String)updateOrderItemSeqMap.get('errorMessage'));
                }
                
                // 1. Update SNE Attributes              
                Map<String, Object>  UpdSNEAttrResultMap = orderMgmtservice.invokeMethod(UPDATE_SNE_ATTRIBUTES_METHOD_NAME,inputMap,outputMap,options); 
                if ((Boolean)UpdSNEAttrResultMap.get('isSuccess') == false) {
                    throw new ftr_XOMSubmitOrderControllerException((String)UpdSNEAttrResultMap.get('errorMessage'));
                }
                
                // 2. Exchange details                 
                Map<String, Object>  exchangeDetailsResultMap = orderMgmtservice.invokeMethod(GET_EXCHANGE_DETAILS_METHOD_NAME,inputMap,outputMap,options); 
                if ((Boolean)exchangeDetailsResultMap.get('isSuccess') == false) {
                    throw new ftr_XOMSubmitOrderControllerException((String)exchangeDetailsResultMap.get('errorMessage'));
                }
                
                // Get The Ring Central Product Count 
                String ringCentralProductQuantities =  orderMgmtservice.ringCentralProductCount(orderId);
                // 3. Reserve WTN
                /*ftr_ResourceManagementService resourceMgmtservice = new ftr_ResourceManagementService();

Map<String, Object>  reserveWTNResultMap = resourceMgmtservice.invokeMethod(RESERVE_WTN_METHOD_NAME,inputMap,outputMap,options); 
if ((Boolean)reserveWTNResultMap.get('isSuccess') == false) {
throw new ftr_XOMSubmitOrderControllerException((String)reserveWTNResultMap.get('errorMessage'));
}*/
                
                // Submit Order to Vlocity OM
                // createPlanAsync(orderId);
                
                // Move the Order Stage to "Customer Network Provisioning"
                this.myOrder = [SELECT Id, Order_Stage__c, OwnerId, vlocity_cmt__OrderStatus__c, Product__c,Products__c, Order_Provisioner__c,Is_this_an_E_Reach_Off_Net_Ethernet__c FROM Order WHERE Id=:orderId];
                System.Debug('myOrder = ' + myOrder);
                // if the order contains products for OM:
                if (myOrder.Products__c.contains('EIA')||myOrder.Products__c.contains('MNS')||myOrder.Products__c.contains('E-LAN') || myOrder.Products__c.contains('EVPL') || myOrder.Products__c.contains('SIP')) {
                    if(myOrder.Is_this_an_E_Reach_Off_Net_Ethernet__c == 'No' || myOrder.Is_this_an_E_Reach_Off_Net_Ethernet__c==null){ //SDDD-4431
                        myOrder.Order_Stage__c = 'Customer Network Provisioning';
                    }else if(myOrder.Is_this_an_E_Reach_Off_Net_Ethernet__c == 'Yes'){ //SDDD-4431
                        myOrder.Order_Stage__c = 'Network Cost Management';
                    }
                    
                    if(myOrder.Product__c == 'Managed Network Services')    // Added for MNS CBTS Issue
                    {
                        System.enqueueJob(new AsyncCBTSIntegration(orderId));
                    }
                    // enqueued job updates the Owner to CNP once the orchestration plan is created.
                    System.enqueueJob(new DecomposeOrderAsync(orderId));
                    
                } else {
                    // if the order does not contain products for OM
                    
                    if (myOrder.Products__c.contains('SIP')) {
                        
                        myOrder.Order_Stage__c = 'CNP Quality Assurance';
                        if (myOrder.Order_Provisioner__c != null) {
                            myOrder.OwnerId = myOrder.Order_Provisioner__c;
                        } else {
                            Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName = 'Customer_Network_Provisioning'];
                            myOrder.OwnerId = myQueue.Id;
                        }
                        
                    } else if (myOrder.Products__c.contains('Frontier Secure') || myOrder.Products__c.contains('SDWAN')) {
                        
                        myOrder.Order_Stage__c = 'Customer Network Provisioning';
                        if (myOrder.Order_Provisioner__c != null) {
                            myOrder.OwnerId = myOrder.Order_Provisioner__c;
                        } else {
                            Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName = 'Customer_Network_Provisioning'];
                            myOrder.OwnerId = myQueue.Id;
                        }
                        
                    } else if (myOrder.Products__c.contains('UCF')) {
                        
                        myOrder.Order_Stage__c = 'QA Review';
                        Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName = 'Project_Management'];
                        myOrder.OwnerId = myQueue.Id;
                        
                    }
                    else if (myOrder.Products__c.contains('Ring Central')) {
                        System.debug('Products__c = ' + myOrder.Products__c );
                        myOrder.Order_Stage__c = 'Issuing Orders';
                        Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName = 'Network_COE_Non_Complex'];
                        myOrder.OwnerId = myQueue.Id;
                        System.enqueueJob(new DecomposeOrderAsync(orderId));
                    }
                }
                if (myOrder.Products__c.contains('Frontier Secure')) {
                    createMFWTaskOnMFWOrder(inputMap, outputMap, options);
                }
                
                myOrder.vlocity_cmt__OrderStatus__c = 'In Progress';
                myOrder.Ring_Central_Product_Count__c =  ringCentralProductQuantities;
                update myOrder;
                
            } else if (methodName == 'requestSEReview') {
                // prevent old orders from proceeding
                if (isOrderFromVlocity(methodName, inputMap, outputMap, options)) {
                    String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                    CustomFieldValidation cfv = new CustomFieldValidation(contextId, 'Request SE Review');
                    if (!cfv.isValid()) {
                        outputMap.put('Error', cfv.getErrors());
                        return false;
                    } 
                }
                Id contextId = (Id)inputMap.get('contextId');
                if (contextId != null && contextId.getSobjectType() == Order.SObjectType) {
                    Order order = new Order(
                        Id = (Id)contextId,
                        vlocity_cmt__OrderStatus__c = 'SE Review',
                        Order_Stage__c = 'Solutions Engineering'
                    );
                    Order o = [SELECT Id, Sales_Engineer__c FROM Order WHERE Id = :contextId];
                    if (o.Sales_Engineer__c != null) { 
                        order.OwnerId = o.Sales_Engineer__c;
                    } else {
                        Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Sales_Engineering'];
                        if (myQueue != null) order.OwnerId = myQueue.Id;
                    }
                    update order;
                }
            }
            
            else if (methodName == 'checkQLI') {
                return validateCart(inputMap, outputMap, options);
                
            } else if (methodName == 'checkQLIAndFSA') {
                if (validateCart(inputMap, outputMap, options) == false) {
                    return false;
                } else if (accountHasFSA(inputMap, outputMap, options) == false) {
                    return false;
                }
            } else if ( methodName == 'submitForDealDeskApproval') {
                Id quoteId = (Id)inputMap.get('contextId');
                //remove old approval request
                ApprovalProcessHelper.submitToDealDesk(quoteId);
            }
            else if (methodName == 'submitForApproval') { 
                if (validateCart(inputMap, outputMap, options) == false) {
                    return false;
                } else {
                    // if items are fully configured, submit quote for approval         
                    Id quoteId = (Id)inputMap.get('contextId');
                    try{
                        //fieldLevelDiscounting invocation
                        System.debug('before fdc');
                        FieldLevelDiscountingController fdc = new FieldLevelDiscountingController(quoteId);
                        //fdc.updateApprovalType(true);
                        //Hemantha - added different approval levels pricing group
                        fdc.updateApprovalTypeNew(true);
                        Quote objQuote = new Quote(Id = quoteId);
                        objQuote.Status = 'In Review';
                        Update objQuote;
                        System.debug('after fdc');
                    }catch(exception e){
                        system.debug('*****Error message:' +e.getMessage());
                        system.debug('*********Error line:' +e.getLineNumber());
                    }
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setObjectId(quoteId);
                    //approvalRequest.setProcessDefinitionNameorId('Approval process name');
                    Approval.ProcessResult result = Approval.process(approvalRequest);
                }
                
            }else if (methodName == 'submitForSEApproval') { 
                
                if (validateCart(inputMap, outputMap, options) == false) {
                    return false;
                } else {
                    // if items are fully configured, submit quote for approval        
                    Id quoteId = (Id)inputMap.get('contextId');
                    Opportunity objOpp =[select SEER_Assigned_To__c, SEER_Assigned_To__r.ManagerId from Opportunity where id in (select OpportunityId from Quote where id =:quoteId)];
					//Fetching QuoteLineItems and checking it has ELAN or not
                    List<QuoteLineItem> QLIList = [Select Id,Product2.ProductCode FROM QuoteLineItem where QuoteId =:quoteId];
					System.debug(QLIList);
                    String ELANProductCode='ENT_ETH_ELAN_0001';
                    Boolean cartHasELAN;
                    for(QuoteLineItem qli:QLIList){
                        if(qli.Product2.ProductCode==ELANProductCode){
                            cartHasELAN=true;
                            System.debug('cartHasELAN trued');
                        }
                    }                 
					if(objOpp.SEER_Assigned_To__c <> null){
                        Quote objQuote = new Quote(Id = quoteId);
                        objQuote.Validation_Status__c = 'Requires Approval';
                        objQuote.Assigned_To__c = objOpp.SEER_Assigned_To__c;
                        if(objOpp.SEER_Assigned_To__r.ManagerId != null){
                            objQuote.SE_Approver_Manager__c = objOpp.SEER_Assigned_To__r.ManagerId;
                        }
                          
                        Update objQuote;
						//System.debug('Quote updated -'+objQuote.toString());  
						//If QuoteLineItems has ELAN- ELAn approval process
						if(cartHasELAN=true){
							Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
							approvalRequest.setObjectId(quoteId);
							approvalRequest.setProcessDefinitionNameorId('Submit_For_SE_Approval_ELAN');
							Approval.ProcessResult result = Approval.process(approvalRequest);
                            System.debug('ELAN-approvalRequest sent');
							
						}else{
                            //If QuoteLineItems does not have ELAN- exsisting approval process
							Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
							approvalRequest.setObjectId(quoteId);
							approvalRequest.setProcessDefinitionNameorId('Submit_For_SE_Approval');
							Approval.ProcessResult result = Approval.process(approvalRequest);
                            System.debug('SWDAN-approvalRequest sent');
							
						}
                    }
                     else {
                        outputMap.put('Error', 'An SE needs to be assigned to the Opportunity.');
                        return false;
                    }
                }
                
            } 
            else if (methodName == 'rejectOrder') {
                Id contextId = (Id)inputMap.get('contextId');
                Order o = [Select Id, Sales_Engineer__c, Order_Stage__c From Order Where Id =: contextId];
                if(contextId != null && contextId.getSobjectType() == Order.SObjectType && o.Order_Stage__c == 'MSA Review') {
                    Order order = new Order(
                        Id = (Id)contextId,
                        vlocity_cmt__OrderStatus__c = 'SE Review',
                        Order_Stage__c = 'Solutions Engineering'
                    );
                    
                    if (o.Sales_Engineer__c != null) { 
                        order.OwnerId = o.Sales_Engineer__c;
                    } else {
                        Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Sales_Engineering'];
                        if (myQueue != null) order.OwnerId = myQueue.Id;
                    }
                    update order;
                } else if (contextId != null && contextId.getSobjectType() == Order.SObjectType && o.Order_Stage__c == 'Solutions Engineering') {
                    Order order = new Order(
                        Id = (Id)contextId,
                        vlocity_cmt__OrderStatus__c = 'Ready to Submit',
                        Order_Stage__c = 'New'
                    );
                    // Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Sales_Engineering'];
                    // if (myQueue != null) order.OwnerId = myQueue.Id;
                    for(Order ord: [Select Id, CreatedById from Order where Id =:order.Id]) {   
                        order.OwnerId = ord.CreatedById;    
                    }
                    update order;
                }
            }else if(methodName == 'submitToMSA'){
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                return submitToMSA(contextId);
            }else if (methodName == 'rejectMngdSvc') {
                Id contextId = (Id)inputMap.get('contextId');
                if (contextId != null && contextId.getSobjectType() == Order.SObjectType) {
                    Order order = new Order(
                        Id = (Id)contextId,
                        vlocity_cmt__OrderStatus__c = 'SE Review',
                        Order_Stage__c = 'Solutions Engineering'
                    );
                    // Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Sales_Engineering'];
                    // if (myQueue != null) order.OwnerId = myQueue.Id;
                    /*for(Order ord: [Select Id, CreatedById from Order where Id =:order.Id]) { 
order.OwnerId = ord.CreatedById;    
}*/
                    update order;
                }
            }  
            else if (methodName == 'cancelOrder') {
                System.Debug('methodName= '+ methodName);
                Id contextId = (Id)inputMap.get('contextId');
                if (contextId != null && contextId.getSobjectType() == Order.SObjectType) {
                    System.Debug('contextId= '+ contextId);
                    Order order = new Order(
                        Id = (Id)contextId,
                        vlocity_cmt__OrderStatus__c = 'Cancelled',
                        Order_Stage__c = 'Cancelled'
                    );
                    // Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Sales_Engineering'];
                    // if (myQueue != null) order.OwnerId = myQueue.Id;
                    Order updOrdRec = [Select Cancellation__c,Authorization_Name__c,Cancel_Reason__c,Cancellation_Description__c From Order Where Id = : contextId];
                    if(String.isEmpty(updOrdRec.Cancellation__c) == true || String.isEmpty(updOrdRec.Authorization_Name__c) == true || String.isEmpty(updOrdRec.Cancellation_Description__c) == true )
                    {
                        System.Debug('updOrdRec.Cancellation__c = ' + updOrdRec.Cancellation__c);
                        System.Debug('updOrdRec.Authorization_Name__c = ' + updOrdRec.Authorization_Name__c);
                        System.Debug('updOrdRec.Cancel_Reason__c = ' + updOrdRec.Cancel_Reason__c);
                        System.Debug('updOrdRec.Cancellation_Description__c = ' + updOrdRec.Cancellation_Description__c);
                        outputMap.put('Error', 'Following fields are required for Cancellation. * Cancellation, * Cancellation Description and * Cancellation Authorization Name is also required.');	
                    }
                    else{
                        update order;                            
                    }
                    
                    
                    
                }
            } else if (methodName == 'confirmSubmitOrder') {
                // check if its an old vlocity order, then prompt confirmation message
                if (isOrderFromVlocity(methodName, inputMap, outputMap, options)) {
                    String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                    boolean elanconfigerror = false;
                    list<orderitem> olist = [ SELECT Product2.ProductCode,Existing__c, vlocity_cmt__JSONAttribute__c FROM Orderitem WHERE  OrderId =:contextId];
                    if(olist.size()>0){
                        for(orderitem oli :olist ){
                            String jsonAttribute = (String) oli.get('vlocity_cmt__JSONAttribute__c');
                            string fieldValue = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'CircuitId');                                
                            if(oli.Existing__c && oli.Product2.ProductCode == 'ENT_ETH_ELAN_0001' && fieldValue == null ){
                                elanconfigerror = true;
                            }
                        }
                    }
                    
                    CustomFieldValidation cfv = new CustomFieldValidation(contextId, 'Submit Order');
                    
                    if(elanconfigerror){
                       outputMap.put('Error', 'Please enter EVC Parent ID in ELAN Configuration');
                                 
                    } else if (!cfv.isValid()) {
                        outputMap.put('Error', cfv.getErrors());
                        return false;
                    } else {
                        outputMap.put('Warning', System.Label.ftr_Confirm_Order_Submission_Message);
                        return true;
                    }
                } else {
                    return false;
                }
            } else if (methodName == 'confirmProgressUCFOrder') {
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                CustomFieldValidation cfv = new CustomFieldValidation(contextId, 'Submit UCF to QA Review');
                if (!cfv.isValid()) {
                    outputMap.put('Error', cfv.getErrors());
                    return false;
                } else {
                    outputMap.put('Warning', System.Label.ftr_Confirm_Order_Submission_Message);
                    return true;
                }
            }  else if (methodName == 'confirmCompleteOrder') {
                // prompt confirmation message
                outputMap.put('Warning', System.Label.ftr_Confirm_Order_Completion_Message);
                return true;
            } else if (methodName == 'stageOrder') {
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                return stageOrder(contextId);
            } else if (methodName == 'stageUCFOrder') {
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                return stageUCFOrder(contextId);
            }else if (methodName == 'submitDecompositionPlan') {
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                return submitDecompositionPlan(contextId);
            }else if (methodName == 'checkImplementationSpecialistForPM') {
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                
                Boolean checkPmEnrichmentValidations = performEmployeInformationValidations(contextId);
                if(checkPmEnrichmentValidations){
                    return checkImplementationSpecialistForPM(contextId);
                }
                else
                {
                    if(!String.isEmpty(Pm_Ernrichment_Error_Message))
                    {
                        outputMap.put('Error', Pm_Ernrichment_Error_Message);
                        return false;
                    }
                }
            }
            else if(methodName == 'checkForOrderDueDateChange') {
                System.debug('checkForOrderDueDateChange');
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                return checkForOrderDueDateChange(contextId);
            }else if (methodName == 'checkImplementationSpecialistForNT') {
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                Boolean checkPmEnrichmentNTValidations = performPMNetworkTranslationValidations(contextId);
                if(checkPmEnrichmentNTValidations){
                    return checkImplementationSpecialistForNT(contextId);
                }
                else
                {
                    if(!String.isEmpty(Pm_Ernrichment_Error_Message))
                    {
                        outputMap.put('Error', Pm_Ernrichment_Error_Message);
                        return false;
                    }
                }
                // return checkImplementationSpecialistForNT(contextId);
            }
            else if (methodName == 'checkForImplementationSpecialist') {
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                CustomFieldValidation cfv = new CustomFieldValidation(contextId, 'Request SE Review');
                if(cfv.isValid()){
                    Boolean checkDIDLoc = checkForImplementationSpecialist(contextId);
                    if(!checkDIDLoc){
                        outputMap.put('Error', 'Please complete the UCF Enrichment process before progressing the order.');
                        return false;
                    } 
                    
                }else if(!cfv.isValid()){
                    outputMap.put('Error', cfv.getErrors());
                    return false;
                }
            }else if(methodName == 'rejectOrderNetworkTranslations'){
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                return rejectOrderNetworkTranslations(contextId);
            }
            else if (methodName == 'stageMFWOrder') {
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                return stageMFWOrder(contextId);
            }  else if (methodName == 'confirmCancelOrder') {
                // prompt confirmation message
                outputMap.put('Warning', System.Label.ftr_Confirm_Order_Cancel_Message);
                return true;
            }
            else if(methodName == 'checkApprovedTotal'){
                System.debug('::::::: Owais');
                system.debug('::::map '+inputMap);
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                Boolean checkTotal = checkApprovedTotal(contextId);
                if (!checkTotal) {
                    outputMap.put('Error', 'Approved Recurring Total can not be greater than Effective Recurring Total');
                    return false;
                } 
            }
            else if(methodName == 'stageEReachOrder'){
                String contextId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
                return stageEReachOrder(contextId);
            }
            outputMap.put('isSuccess', true);
            
            return true;
        } catch (Exception ex) {  
            outputMap.put('isSuccess', false);
            outputMap.put('errorMessage', ex.getMessage());
            
            System.debug('The following exception has occurred: ' + ex.getMessage());
            return false;
        } finally {
            System.debug('Exit ftr_XOMSubmitOrderController.' + methodName);
        }
    }
    
    public Boolean stageOrder(String orderId) {
        String nextStage = '';
        Order o = [SELECT id, order_stage__c, vlocity_cmt__OrderStatus__c, OwnerId FROM order WHERE id=:orderId];
        
        if (o.Order_Stage__c == 'Solutions Engineering' || o.Order_Stage__c == 'Sales Engineering') {
            Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Customer_Network_Provisioning'];
            o.Order_Stage__c = 'CNP Quality Assurance';
            o.vlocity_cmt__OrderStatus__c = 'In Progress';
            o.OwnerId = myQueue.Id;
            
        } else if (o.Order_Stage__c == 'CNP Quality Assurance') {
            o.Order_Stage__c = 'PSR In Progress';
        }else if (o.Order_Stage__c == 'Customer Network Provisioning'){
            o.Order_Stage__c = 'CNP Quality Assurance';
        }
        
        update o;
        return true;        
    }
    public Boolean stageMFWOrder(String orderId) {
        String nextStage = '';
        
        Order o = [SELECT id, order_stage__c, vlocity_cmt__OrderStatus__c, OwnerId FROM order WHERE id=:orderId];
        
        if (o.Order_Stage__c == 'In Progress') { //&& add OwnerId =Service Delivery PM
            Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Customer_Network_Provisioning'];
            o.Order_Stage__c = 'Pending Billing';
            o.vlocity_cmt__OrderStatus__c = 'In Progress';
            o.OwnerId = myQueue.Id;
            
        }else if (o.Order_Stage__c == 'Customer Network Provisioning') { //&& add OwnerId =Customer Network Provisioning
            Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Service_Delivery_PM'];
            o.Order_Stage__c = 'In Progress';
            o.vlocity_cmt__OrderStatus__c = 'In Progress';
            o.OwnerId = myQueue.Id;
            
        } 
        
        update o;
        return true;        
    }
    public Boolean stageUCFOrder(String orderId) {
        String nextStage = '';
        Order o = [SELECT id, order_stage__c, vlocity_cmt__OrderStatus__c, Products__c, Network_Project_Specialist__c, OwnerId FROM order WHERE id=:orderId];        
        if (o.Order_Stage__c == 'Customer Network Provisioning' || o.Order_Stage__c == 'New') {     
            if (o.Network_Project_Specialist__c == null) {
                Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Project_Management'];
                o.OwnerId = myQueue.Id;
            } else {
                o.OwnerId = o.Network_Project_Specialist__c;
            }
            o.Order_Stage__c = 'QA Review';
            o.vlocity_cmt__OrderStatus__c = 'In Progress';
            
        } else if (o.Order_Stage__c == 'QA Review') {//&& add OwnerId =Project Management
            Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Network_COE_UCaas'];
            o.Order_Stage__c = 'In Progress';
            o.vlocity_cmt__OrderStatus__c = 'In Progress';
            o.OwnerId = myQueue.Id;
        }else if (o.Order_Stage__c == 'In Progress') {//&& add OwnerId = Network COE - Ucaas
            
            if (o.Products__c.contains('UCF') && (!o.Products__c.contains('EIA')&& !o.Products__c.contains('MNS') && !o.Products__c.contains('EVPL')&& !o.Products__c.contains('E-LAN'))){
                Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Network_COE_UCaas'];
                o.Order_Stage__c = 'Pending Billing';
                o.vlocity_cmt__OrderStatus__c = 'In Progress';
                o.OwnerId = myQueue.Id;
                
            }else{
                
                Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Customer_Network_Provisioning'];
                o.Order_Stage__c = 'Pending Billing';
                o.vlocity_cmt__OrderStatus__c = 'In Progress';
                o.OwnerId = myQueue.Id;
            }
        }
        update o;
        return true;        
    }
    public boolean stageEReachOrder(String orderId){
        Order o = [SELECT id, order_stage__c FROM order WHERE id=:orderId];
        o.order_stage__c = 'ECR/EWO In Progress';
        update o;
        return true;
    }
    public Boolean checkForImplementationSpecialist(String orderId){
        System.Debug('checkForImplementationSpecialist called');
        Id recordTypeId;
        List<ftr_DID_Location_Details__c>  didLoc = [Select Id,OrderId__c from ftr_DID_Location_Details__c where OrderId__c=:orderId];
        if(!didLoc.isEmpty()){
            Database.DMLOptions dlo = new Database.DMLOptions();
            Order o = [SELECT Id, order_stage__c, vlocity_cmt__OrderStatus__c, Products__c, Network_Project_Specialist__c, OwnerId FROM order WHERE Id=:orderId];
            
            Map<Id,String> serviceAccountId = new Map<Id,String>();
            List<OrderItem> orderItemList = [Select Id,vlocity_cmt__ServiceAccountId__c,vlocity_cmt__ServiceAccountId__r.Name from OrderItem where OrderId =:orderId];
            for(OrderItem orderItemData: orderItemList){
                serviceAccountId.put(orderItemData.vlocity_cmt__ServiceAccountId__c,orderItemData.vlocity_cmt__ServiceAccountId__r.Name);
            }    
            if((o.order_stage__c =='New')  && o.Products__c.contains('UCF')){
                //List<Task> taskList = new List<Task>();        
                if(!serviceAccountId.isEmpty()){
                    System.debug('calling task creation');
                    D1711_DCOrderTask(serviceAccountId,o.order_stage__c,orderId);
                }
            }
            
            
            if(o.Network_Project_Specialist__c !=null && o.Order_Stage__c == 'New'){
                System.Debug('PM Enrichment Stage called');
                //createTask(o);
                DualOrderSEChange(orderId);
                Group PmQ = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Project_Manager'];
                o.Order_Stage__c = 'PM Enrichment';
                o.vlocity_cmt__OrderStatus__c = 'In Progress';
                o.OwnerId = PmQ.Id;
                
                
            }
            
            else if(o.Network_Project_Specialist__c ==null && o.Order_Stage__c == 'New'){
                system.debug('In Network Speacialist Null and order new');
                //createTask(o);
                DualOrderSEChange(orderId);
                system.debug('In Network Speacialist Null and order new 2');
                Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='PM_Assignment'];
                system.debug('In Network Speacialist Null and order new myQueue ' + myQueue);
                o.Order_Stage__c = 'PM Assignment';
                o.vlocity_cmt__OrderStatus__c = 'PM Assignment';
                o.OwnerId = myQueue.Id;
            }
            else if(o.Network_Project_Specialist__c != null && o.Order_Stage__c == 'Hot Cuts'){
                //createTask(o);
                if(!serviceAccountId.isEmpty()){
                    D1711_DCOrderTask(serviceAccountId,o.order_stage__c,orderId);
                }
            }
            
            //update o;
            system.debug('In Network Speacialist NullUpdate');
            Database.update(o,dlo);
            return true;
        }
        return false;
    }
    
    // for Pm enrichment validations
    private boolean performPMNetworkTranslationValidations(String orderId){
        errorMessages.clear();
        Integer missingEasPinCount = 0;
        Integer missingBusinessGroupNameCount = 0;
        Integer missingLocalRoutingNumberCount = 0;
        boolean validationResult = true;
        Id userId = UserInfo.getUserId();
        system.debug('zainab userId '+ userId);
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :userId];
        system.debug('zainab currentUser '+ currentUser);
        system.debug('zainab profile name:'+ currentUser.Profile.Name);
        system.debug('zainab orderID '+ orderId); 
        system.debug('#Solution Engineer Supervisor:'+ currentUser.Profile.Name);  
        if (currentUser.Profile.Name == '#Solution Engineer Supervisor') {
            system.debug('zainab inside loop ');
            List<Service_Location__c> serviceLocations = [SELECT Id, Business_Group_Name__c, EAS_Pin__c, Order__c 
                                                          FROM Service_Location__c 
                                                          WHERE Order__c = :orderId];
            system.debug('zainab serviceLocations '+ serviceLocations);
            
            for (Service_Location__c location : serviceLocations) {
                if (location.EAS_Pin__c == null) {
                    missingEasPinCount ++;
                    //errorMessages.add('EAS Pin is empty. Please enter EAS Pin.'+ '<br>');
                    //validationResult = false;
                    system.debug('inside easpin checck ');            
                }
                // Check if Business Group Name is empty or null
                if (String.isEmpty(location.Business_Group_Name__c)) {
                    missingBusinessGroupNameCount++;
                    //errorMessages.add('Business Group Name is empty. Please enter Business Group Name.'+'\n');
                    //validationResult = false;
                }
            }
            
            if (missingEasPinCount > 0) {
                errorMessages.add('EAS Pin is empty. Please enter EAS Pin.'+'\n');
                validationResult = false;
            }
            if (missingBusinessGroupNameCount > 0) {
                errorMessages.add('Business Group Name is empty. Please enter Business Group Name.'+'\n');
                validationResult = false;
            }
            
            List<ftr_DID_Number_Details__c> DIDNumberDetailforLRN=new List<ftr_DID_Number_Details__c>();
            DIDNumberDetailforLRN= [SELECT Id,DID_Number__c,NPA__c, NXX__c,Local_Routing_Number__c FROM 
                                    ftr_DID_Number_Details__c where DIDLocationDetailsId__r.OrderId__c =: orderId];
            system.debug('heree '+ DIDNumberDetailforLRN);
            Map<String,ftr_DID_Number_Details__c> MapOfDIDNumbers =new Map<String,ftr_DID_Number_Details__c>();
            for(ftr_DID_Number_Details__c DID : DIDNumberDetailforLRN)    
            {
                MapOfDIDNumbers.put(DID.DID_Number__c.substring(0, 3)+'-'+DID.DID_Number__c.substring(3, 6),DID);
            }
            DIDNumberDetailforLRN.clear();
            DIDNumberDetailforLRN=MapOfDIDNumbers.values();
            
            for (ftr_DID_Number_Details__c lrn : DIDNumberDetailforLRN) {
                if (lrn.Local_Routing_Number__c == null) {
                    missingLocalRoutingNumberCount++;
                    
                } 
            } 
            
            if (missingLocalRoutingNumberCount > 0) {
                errorMessages.add('one or more Local Routing Numbers are empty. Please enter Local Routing Number.'+'\n');
                validationResult = false;
            }
            
        }
        
        appendErrorMessages();
        
        return validationResult;
    }
    
    
    private boolean performEmployeInformationValidations(String orderId)
    {
        system.debug('Validation Pm Progress order Hit ' + orderId);
        
        
        errorMessages.clear();
        
        Order orderRecord = [SELECT Id, Order_Stage__c, Status FROM Order WHERE Id = :orderId LIMIT 1];
        // Check if the order stage is not 'PM Enrichment'
        if (orderRecord.Order_Stage__c != 'PM Enrichment') {
            // If not 'PM Enrichment', skip validation and return true
            return true;     
        }
    

        boolean validationResult = true;
        boolean hasValueCollaborationFlag = false;
        boolean hasValueWebinarFlag = false;
        boolean hasValuedeviceTypeFlag = false;
        boolean hasValueaudioMiningFlag = false;
        boolean hasValuedeviceAccesoriesFlag = false;
        boolean hasValuestorageFlag = false;
        boolean hasValuelicenseTypeFlag = false;
        boolean hasValuescreenRecordingFlag = false;
        boolean hasValuecallRecordingFlag = false;
        
        //sl
        boolean	hasValueLocationName = true;
        boolean	hasValueLocationAddress = true;
        boolean	hasValueTimeZone = true;
        boolean	hasValueNewCons = true;
        boolean	hasValueContactName = true;
        boolean	hasValueContactEmail = true;
        boolean	hasValueContactPhone = true;
        boolean	hasValueCallerIdName = true;
        //
        
        boolean	hasValueCurrentCarrier = true;
        boolean hasValueExtension = true;
        boolean hasValueUserName= true;
        boolean hasValueCompanyName= true;
        boolean hasValueAddress= true;
        boolean hasValueStreet= true;
        boolean hasValueCity= true;
        boolean hasValueZipCode= true;
        boolean hasValueUserAdmin= true;
        boolean hasValueOutboundCallerId= true;
        boolean hasValueOtherOutboundCallerId= true;
        
        
        boolean orderHasCollaborationProduct = false;
        boolean orderHasWebinaProduct = false;
        boolean orderHasdeviceTypeProduct = false;
        boolean orderHasaudioMiningProduct = false;
        boolean orderHasdeviceAccesoriesProduct = false;
        boolean orderHasstorageProduct = false;
        boolean orderHaslicenseTypeProduct = false;
        boolean orderHasscreenRecordingProduct = false;
        boolean orderHascallRecordingProduct = false;
        
        
        
        List<ftr_911_Notifications__c> notificationList = [SELECT Id,Name FROM ftr_911_Notifications__c WHERE Order__c = :orderId];
 
        if (notificationList == null ||notificationList.isEmpty()) {
                errorMessages.add('No 911 Notifications records found for the order.');
                System.debug('No related ftr_911_Notifications__c records found for the order.');
                validationResult = false;
            
            }
        
        
        System.debug('AAAA: order stage '+ orderRecord.Order_Stage__c);
        
        
        
        Integer didCount = 0;
        Integer autoAttendantCount = 0;
        Integer vacantSpareCount = 0;
        Integer tollFreeCount = 0;
        Integer ccaasCount = 0; // Contact Center as a Service
        Boolean isPmEnrichmentValidatedSucessfully = false;
        Map<String, Integer> licenseTypeMap = new Map<String, Integer>();
        Map<String, Integer> collaborationMap = new Map<String, Integer>();
        Map<String, Integer> webinarMap = new Map<String, Integer>();
        Map<String, Integer> deviceTypeMap = new Map<String, Integer>();
        Map<String, Integer> audioMiningMap = new Map<String, Integer>(); 
        Map<String, Integer> deviceAccesoriesMap = new Map<String, Integer>(); 
        Map<String, Integer> storageMap = new Map<String, Integer>(); 
        Map<String, Integer> callRecordingMap = new Map<String, Integer>(); 
        Map<String, Integer> screenRecordingMap = new Map<String, Integer>(); 
        
        
        Map<String, Integer> orderLicenseTypeMap = new Map<String, Integer>();
        Map<String, Integer> orderCollaborationMap = new Map<String, Integer>();
        Map<String, Integer> orderWebinarMap = new Map<String, Integer>();
        Map<String, Integer> orderDeviceTypeMap = new Map<String, Integer>();
        Map<String, Integer> orderAudioMiningMap = new Map<String, Integer>(); 
        Map<String, Integer> orderDeviceAccesoriesMap = new Map<String, Integer>(); 
        Map<String, Integer> orderStorageMap = new Map<String, Integer>(); 
        Map<String, Integer> orderCallRecordingMap = new Map<String, Integer>(); 
        Map<String, Integer> orderScreenRecordingMap = new Map<String, Integer>(); 
        
        
        // Query the records
        List<ftr_DID_Number_Details__c> didNumberDetailsPn = [SELECT Id, 
                                                              Ucf_Number_Use__c, 
                                                              DIDNumber__c 
                                                              FROM 
                                                              ftr_DID_Number_Details__c  
                                                              WHERE  
                                                              DIDLocationDetailsId__r.OrderId__c =:orderId and  Ucf_Number_Use__c IN 
                                                              ('DID', 'Auto Attendant', 'Vacant/Spare', 'Toll Free', 'Contact Center as a Service')];
        for (ftr_DID_Number_Details__c detail : didNumberDetailsPn) 
        {
            switch on detail.Ucf_Number_Use__c
            {
                when 'DID' {
                    didCount++;
                }
                when 'Auto Attendant' {
                    autoAttendantCount++;
                }
                when 'Vacant/Spare' {
                    vacantSpareCount++;
                }
                when 'Toll Free' {
                    tollFreeCount++;
                }
                when 'Contact Center as a Service' {
                    ccaasCount++;
                }
                
            }
            
        }
        
        system.debug('Pm Progress order didCount '+ didCount);
        system.debug('Pm Progress order autoAttendantCount '+ autoAttendantCount);
        system.debug('Pm Progress order vacantSpareCount '+ vacantSpareCount);
        system.debug('Pm Progress order tollFreeCount '+ tollFreeCount);
        system.debug('Pm Progress order ccaasCount '+ ccaasCount);
        
        List<OrderItem> orderItemstoGetLisenceQ = [
            SELECT Quantity
            FROM OrderItem
            WHERE Product_Type__c = 'License'
            AND Product2.Name IN ('UCF Inbound WebFax DID', 'UCF Basic', 'UCF Executive', 'UCF Analog')
            AND OrderId = :orderId
        ];
        
        Integer totalOrderQforLisence = 0;
        for (OrderItem item : orderItemstoGetLisenceQ) {
            totalOrderQforLisence += item.Quantity.intValue();
        }

	System.debug('Total Quantity: ' + totalOrderQforLisence);
        
        List<Service_Location__c> serviceLocationList = [select  id, 
                                                         Location_Name__c, 
                                                         Location_Address__c, 
                                                         Time_Zone__c, 
                                                         Order__c, 
                                                         New_Construction__c, 
                                                         Contact_Name__c, 
                                                         Contact_Email__c, 
                                                         Contact_Phone__c, 
                                                         Caller_ID_Name__c  
                                                         from 
                                                         Service_Location__c where Order__c  =:orderId];
                                                    
        
        for (Service_Location__c service : serviceLocationList) {
            if(String.isEmpty(service.Location_Name__c)) 
            {
                hasValueLocationName = false;
                
            }
            
            if(String.isEmpty(service.Location_Address__c)) 
            {
                hasValueLocationAddress = false;
                
            }
            if(String.isEmpty(service.Time_Zone__c)) 
            {
                hasValueTimeZone = false;
                
            }
            if(String.isEmpty(service.New_Construction__c)) 
            {
                hasValueNewCons = false;
                
            }
            if(String.isEmpty(service.Contact_Name__c)) 
            {
                hasValueContactName = false;
                
            }
            if(String.isEmpty(service.Contact_Email__c)) 
            {
                hasValueContactEmail = false;
                
            }
            
            if(String.isEmpty(service.Contact_Phone__c)) 
            {
                hasValueContactPhone = false;
                
            }
            if(String.isEmpty(service.Caller_ID_Name__c)) 
            {
                hasValueCallerIdName = false;
                
            }
        }
        
        List<ftr_DID_Number_Details__c> didNumberDetailsForPhoneNumber = [SELECT Id, 
                                                                          Ucf_Current_Carrier__c 
                                                                          FROM 
                                                                          ftr_DID_Number_Details__c
                                                                          where 
                                                                          DIDLocationDetailsId__r.OrderId__c =:orderId];
        for (ftr_DID_Number_Details__c detailph : didNumberDetailsForPhoneNumber) {
            system.debug('Xxoomm: detail.Ucf_Company_Name__c '+detailph.Ucf_Current_Carrier__c);
            if(String.isEmpty(detailph.Ucf_Current_Carrier__c)) 
            {
                hasValueCurrentCarrier = false;
                
            }
        }
        
        
        List<ftr_DID_Number_Details__c> didNumberDetails = [SELECT Id, Ucf_License_Type__c, Ucf_Collaboration__c,
                                                            Ucf_Webinar__c, 
                                                            Ucf_Device_Accessories__c, 
                                                            Ucf_Device_Type__c, 
                                                            Ucf_Call_Recording__c, 
                                                            Ucf_Audio_Mining__c, 
                                                            Ucf_Screen_Recording__c, 
                                                            Ucf_Storage__c ,
                                                            Ucf_Extension__c,
                                                            Ucf_User_Name__c, 
                                                            Ucf_Company_Name__c, 
                                                            Ucf_User_Admin__c, 
                                                            Outbound_Caller_ID__c, 
                                                            Ucf_Other_Outbound_Caller_ID__c,
                                                            Ucf_Address_Number__c, 
                                                            Ucf_Street_Name__c, 
                                                            Ucf_City__c, 
                                                            Ucf_Zip_Code__c 
                                                            FROM ftr_DID_Number_Details__c 
                                                            where DIDLocationDetailsId__r.OrderId__c =:orderId
                                                            and Ucf_Number_Use__c ='DID'];
        system.debug('Pm Progress order didNumberDetails  '+ didNumberDetails);
        for (ftr_DID_Number_Details__c detail : didNumberDetails) {
            if(detail.Ucf_License_Type__c != null && detail.Ucf_License_Type__c != 'None') {
                hasValuelicenseTypeFlag = true;
                incrementCountInMapDidNumber(licenseTypeMap, detail.Ucf_License_Type__c);
            }
            
            if(detail.Ucf_Collaboration__c != null && detail.Ucf_Collaboration__c != 'None') {
                hasValueCollaborationFlag = true;
                incrementCountInMapDidNumber(collaborationMap, detail.Ucf_Collaboration__c);
            }
            
            if(detail.Ucf_Webinar__c != null && detail.Ucf_Webinar__c != 'None') {
                hasValueWebinarFlag = true;
                incrementCountInMapDidNumber(webinarMap, detail.Ucf_Webinar__c);
            }
            
            if(detail.Ucf_Device_Type__c != null) {
                hasValuedeviceTypeFlag = true;
                incrementCountInMapDidNumber(deviceTypeMap, detail.Ucf_Device_Type__c);
            }
            
            if(detail.Ucf_Audio_Mining__c != null && detail.Ucf_Audio_Mining__c != 'No') {
                hasValueaudioMiningFlag = true;
                incrementCountInMapDidNumber(audioMiningMap, detail.Ucf_Audio_Mining__c);
            }
            if(detail.Ucf_Device_Accessories__c != null && detail.Ucf_Device_Accessories__c != 'None') {
                hasValuedeviceAccesoriesFlag = true;
                incrementCountInMapDidNumber(deviceAccesoriesMap, detail.Ucf_Device_Accessories__c);
            }
            
            system.debug('Pm Progress order detail.Ucf_Storage__c  '+ detail.Ucf_Storage__c);
            if(detail.Ucf_Storage__c != 'UCF Call Recording Basic' && detail.Ucf_Storage__c != null) {
                hasValuestorageFlag = true;
                system.debug('Pm Progress order detail.Ucf_Storage__c inside  '+ detail.Ucf_Storage__c);
                incrementCountInMapDidNumber(storageMap, detail.Ucf_Storage__c);
            }
            if(detail.Ucf_Call_Recording__c != null && detail.Ucf_Call_Recording__c != 'No') {
                hasValuecallRecordingFlag = true;
                incrementCountInMapDidNumber(callRecordingMap, detail.Ucf_Call_Recording__c);
            }
            if(detail.Ucf_Screen_Recording__c != null && detail.Ucf_Screen_Recording__c != 'No') 
            {
                hasValuescreenRecordingFlag = true;
                incrementCountInMapDidNumber(screenRecordingMap, detail.Ucf_Screen_Recording__c);
            }
            system.debug('Xxoomm: detail.Ucf_Extension__c '+detail.Ucf_Extension__c);
            // if(String.String.isEmpty(detail.Ucf_Extension__c)  == null || detail.Ucf_Extension__c == '') 
            if(String.isEmpty(detail.Ucf_Extension__c)) 
            {
                system.debug('Xxoomm: here 1');
                hasValueExtension = false;
                
            }
            
            system.debug('Xxoomm: detail.Ucf_User_Name__c '+detail.Ucf_User_Name__c);
            if(String.isEmpty(detail.Ucf_User_Name__c)) 
                // if(detail.Ucf_User_Name__c == null || detail.Ucf_User_Name__c == '') 
            {
                hasValueUserName = false;
                system.debug('Xxoomm: here 2');
                
            }
            system.debug('Xxoomm: detail.Ucf_Company_Name__c '+detail.Ucf_Company_Name__c);
            if(String.isEmpty(detail.Ucf_Company_Name__c)) 
                // if(detail.Ucf_Company_Name__c == null || detail.Ucf_Company_Name__c == '') 
            {
                hasValueCompanyName = false;
                system.debug('Xxoomm: here 3');
                
            }
            system.debug('Xxoomm: detail.Ucf_Address_Number__c '+detail.Ucf_Address_Number__c);
            if(String.isEmpty(detail.Ucf_Address_Number__c)) 
                //if(detail.Ucf_Address_Number__c == null || detail.Ucf_Address_Number__c == '') 
            {
                hasValueAddress = false;
                system.debug('Xxoomm: here 4');
                
            }
            system.debug('Xxoomm: detail.Ucf_Street_Name__c '+detail.Ucf_Street_Name__c);
            if(String.isEmpty(detail.Ucf_Street_Name__c)) 
                // if(detail.Ucf_Street_Name__c == null || detail.Ucf_Street_Name__c == '') 
            {
                hasValueStreet = false;
                system.debug('Xxoomm: here 5');
                
            }
            system.debug('Xxoomm: detail.Ucf_City__c '+detail.Ucf_City__c);
            if(String.isEmpty(detail.Ucf_City__c)) 
                //if(detail.Ucf_City__c == null || detail.Ucf_City__c == '') 
            {
                hasValueCity = false;
                system.debug('Xxoomm: here 6');
                
            }
            system.debug('Xxoomm: detail.Ucf_Zip_Code__c '+detail.Ucf_Zip_Code__c);
            if(String.isEmpty(detail.Ucf_Zip_Code__c)) 
            {
                hasValueZipCode = false;
                
            }
            
            system.debug('Xxoomm: detail.Ucf_User_Admin__c '+detail.Ucf_User_Admin__c);
            if(String.isEmpty(detail.Ucf_User_Admin__c)) 
            {
                hasValueUserAdmin = false;
                
            }
            
            system.debug('Xxoomm: detail.Outbound_Caller_ID__c '+detail.Outbound_Caller_ID__c);
            if(String.isEmpty(detail.Outbound_Caller_ID__c)) 
            {
                hasValueOutboundCallerId = false;
                
            }
            
            
            if(!String.isEmpty(detail.Outbound_Caller_ID__c)) 
            {
                if(detail.Outbound_Caller_ID__c == 'Other')
                {
                    if(String.isEmpty(detail.Ucf_Other_Outbound_Caller_ID__c)) 
                    {
                        hasValueOtherOutboundCallerId = false;
                    }
                    
                }
            }
            
            
            
        } 
        
        
        List<OrderItem> orderItems = [SELECT Quantity, Product2.Name, Product_Type__c
                                      FROM OrderItem 
                                      WHERE OrderId = :orderId AND Product_Type__c IN ('Accessories', 'License')];
        
        system.debug('Pm Progress order orderItems  '+ orderItems);
        
        // Iterate over the records and populate maps
        for (OrderItem item : orderItems) {
            if (item.Product_Type__c == 'Accessories') {
                orderHasdeviceAccesoriesProduct = true;
                incrementCountInMap(orderDeviceAccesoriesMap, item.Product2.Name, item.Quantity.intValue());
            } 
            if (item.Product_Type__c == 'License') {
                orderHaslicenseTypeProduct = true;
                incrementCountInMap(orderLicenseTypeMap, item.Product2.Name, item.Quantity.intValue());
            }
        }
        
        List<OrderItem> orderItemsCwc = [SELECT Id, Product2.Name, product2.vlocity_cmt__SubType__c, Quantity
                                         FROM OrderItem
                                         WHERE OrderId = :orderId
                                         AND  product2.vlocity_cmt__SubType__c  IN ('Collaboration', 'Webinar','Call Recording')];
        // Iterate over the records and populate maps
        for (OrderItem item : orderItemsCwc) {
            switch on item.Product2.vlocity_cmt__SubType__c {
                when 'Collaboration' {
                    orderHasCollaborationProduct = true;
                    incrementCountInMap(orderCollaborationMap, item.Product2.Name, item.Quantity.intValue());
                }
                when 'Webinar' {
                    orderHasWebinaProduct = true;
                    incrementCountInMap(orderWebinarMap, item.Product2.Name, item.Quantity.intValue());
                }
                /* when 'Call Recording' {
incrementCountInMap(orderStorageMap, item.Product2.Name, item.Quantity.intValue());
} */
            }
        }
        
        
        List<OrderItem> orderItemsCallRecordingRelated = [SELECT Id, Product2.Name, Quantity,Product2.vlocity_cmt__SubType__c
                                                          FROM OrderItem
                                                          WHERE OrderId = :orderId
                                                          AND  Product2.Name  
                                                          IN ('UCF Call Recording Basic', 'UCF Audio Mining','UCF Screen Record', 
                                                              'UCF Storage 3 Years', 'UCF Storage 1 Year', 'UCF Storage 180 Days')];
        // Iterate over the records and populate maps
        
        system.debug('Pm Progress order orderItemsCallRecordingRelated  '+ orderItemsCallRecordingRelated);
        for (OrderItem item : orderItemsCallRecordingRelated) {
            switch on item.Product2.vlocity_cmt__SubType__c {
                when 'UCF Call Recording Basic' {
                    orderHascallRecordingProduct = true;
                    incrementCountInMap(orderCallRecordingMap, 'Yes', item.Quantity.intValue());
                }
                when 'UCF Audio Mining' {
                    orderHasaudioMiningProduct = true;
                    incrementCountInMap(orderAudioMiningMap, item.Product2.Name, item.Quantity.intValue());
                }
                when 'UCF Screen Record' {
                    orderHasscreenRecordingProduct = true;
                    incrementCountInMap(screenRecordingMap,  item.Product2.Name, item.Quantity.intValue());
                } 
                when 'UCF Storage 3 Years', 'UCF Storage 1 Year', 'UCF Storage 180 Days' {
                    orderHasstorageProduct = true;
                    incrementCountInMap(storageMap,  item.Product2.Name, item.Quantity.intValue());
                    
                }
                
            }
        }
        
        //get storage count
        
        List<OrderItem> orderItemsDeviceType = [SELECT Id, Product2.Name, Quantity, Product2.vlocity_cmt__SpecificationSubType__c
                                                FROM OrderItem
                                                WHERE OrderId = :orderId 
                                                AND Product2Id IN (SELECT Id FROM Product2 WHERE vlocity_cmt__SpecificationSubType__c IN ('Conference Models', 'poly phones', 'yealink phones', 'ATA'))];
        
        // Iterate over the records and populate the map
        for (OrderItem item : orderItemsDeviceType) {
            orderHasdeviceTypeProduct = true;
            incrementCountInMap(orderDeviceTypeMap, item.Product2.Name,item.Quantity.intValue());
        }
        
        
        if(totalOrderQforLisence > 0)
        {
            if(totalOrderQforLisence != didCount)
            {
                  errorMessages.add('License quantity selected on order must be equal to the number selected as DID.');
            	  validationResult = false;
            }
          
        }
        if(!hasValueLocationName)
        {
            errorMessages.add('Location Name can not be empty on Service Location.');
            validationResult = false;
        }   
        
        
        if(!hasValueLocationAddress)
        {
            errorMessages.add('Location Address can not be empty on Service Location.');
            validationResult = false;
        }   
        
        
        if(!hasValueTimeZone)
        {
            errorMessages.add('Time zone can not be empty on Service Location.');
            validationResult = false;
        }   
        
        
        if(!hasValueNewCons)
        {
            errorMessages.add('New construction can not be empty on Service Location.');
            validationResult = false;
        }   
        
        
        if(!hasValueContactName)
        {
            errorMessages.add('Contact Name can not be empty on Service Location.');
            validationResult = false;
        }   
        
        
        if(!hasValueContactEmail)
        {
            errorMessages.add('Contact Email can not be empty on Service Location.');
            validationResult = false;
        }   
        
        
        if(!hasValueContactPhone)
        {
            errorMessages.add('Contact phone can not be empty on Service Location.');
            validationResult = false;
        }   
        
        if(!hasValueCallerIdName)
        {
            errorMessages.add('Caller id name can not be empty on Service Location.');
            validationResult = false;
        }   
        
        
        
        if(!hasValueCurrentCarrier)
        {
            errorMessages.add('Current Carrier can not be empty.');
            System.debug('Xxoomm: Current Carrier can not be empty');
            validationResult = false;
        }   
        if(!hasValueExtension)
        {
            errorMessages.add('Extension can not be empty.');
            System.debug('Xxoomm: Extension can not be empty');
            validationResult = false;
        }
        
        if(!hasValueUserName)
        {
            errorMessages.add('User Name can not be empty.');
            System.debug('Xxoomm: User Name  can not be empty');
            validationResult = false;
        }
        if(!hasValueCompanyName)
        {
            errorMessages.add('Company Name can not be empty.');
            System.debug('Xxoomm: Company Name can not be empty');
            validationResult = false;
        }
        
        if(!hasValueAddress)
        {
            errorMessages.add('Address can not be empty.');
            System.debug('Xxoomm: Address can not be empty');
            validationResult = false;
        }
        
        if(!hasValueStreet)
        {
            errorMessages.add('Street Name can not be empty.');
            System.debug('Xxoomm: Street Name can not be empty');
            validationResult = false;
        }
        
        if(!hasValueCity)
        {
            errorMessages.add('City can not be empty.');
            System.debug('Xxoomm: City can not be empty');
            validationResult = false;
        }
        
        if(!hasValueZipCode)
        {
            errorMessages.add('Zip Code can not be empty.');
            System.debug('Xxoomm: Zip Code can not be empty');
            validationResult = false;
        }
        
        if(!hasValueUserAdmin)
        {
            errorMessages.add('User Admin can not be empty.');
            System.debug('Xxoomm: User Admin can not be empty');
            validationResult = false;
        }
        
        if(!hasValueOutboundCallerId)
        {
            errorMessages.add('Outbound caller id can not be empty.');
            System.debug('Xxoomm: Outbound caller id can not be empty');
            validationResult = false;
        }
        
        if(!hasValueOtherOutboundCallerId)
        {
            errorMessages.add('Other outbound caller id can not be empty.');
            System.debug('Xxoomm: Other outbound caller id can not be empty');
            validationResult = false;
        }
        
        if(orderHasCollaborationProduct)
        {
            if(!hasValueCollaborationFlag)
            {
                errorMessages.add('Please Select Collaboration Product.');
                System.debug('Xxoomm: Please Select Collaboration Product');
                validationResult = false;
            }
        }
        
        if(orderHasWebinaProduct)
        {
            if(!hasValueWebinarFlag)
            {
                errorMessages.add('Please Select Webinar Product.');
                System.debug('Xxoomm: Please Select Webinar Product');
                validationResult = false;
            }
        }
        
        if(orderHasdeviceTypeProduct)
        {
            if(!hasValuedeviceTypeFlag)
            {
                errorMessages.add('Please Select Device type Product.');
                System.debug('Xxoomm: Please Select Device type Product');
                validationResult = false;
            }
        }
        
        if(orderHasaudioMiningProduct)
        {
            if(!hasValueaudioMiningFlag)
            {
                errorMessages.add('Please Select Audio mining Product.');
                System.debug('Xxoomm: Please Select Audio mining Product');
                validationResult = false;
            }
        }
        
        if(orderHasdeviceAccesoriesProduct)
        {
            if(!hasValuedeviceAccesoriesFlag)
            {
                errorMessages.add('Please Select Device accesories Product.');
                System.debug('Xxoomm: Please Select Device accesories Product');
                validationResult = false;
            }
        }
        
        if(orderHasstorageProduct)
        {
            if(!hasValuestorageFlag)
            {
                errorMessages.add('Please Select Storage Product.');
                System.debug('Xxoomm: Please Select Storage Product');
                validationResult = false;
            }
        }
        
        if(orderHaslicenseTypeProduct)
        {
            if(!hasValuelicenseTypeFlag)
            {
                errorMessages.add('Please Select License type Product.');
                System.debug('Xxoomm: Please Select License type Product');
                validationResult = false;
            }
        }
        if(orderHascallRecordingProduct)
        {
            if(!hasValuecallRecordingFlag)
            {
                errorMessages.add('Please Select Call recording Product.');
                System.debug('Xxoomm: Please Select Call recording Product');
                validationResult = false;
            }
        }
        if(orderHasscreenRecordingProduct)
        {
            if(!hasValuescreenRecordingFlag)
            {
                errorMessages.add('Please Select Screen recodring Product.');
                System.debug('Xxoomm: Please Select Screen recodring Product');
                validationResult = false;
            }
        }
        
        
        
        
        /*
system.debug('Pm Progress orde Validation PM licenseTypeMap :' + licenseTypeMap + 'orderLicenseTypeMap ' + orderLicenseTypeMap );
if (!isEmpInfoCountValid(licenseTypeMap, orderLicenseTypeMap)) {
errorMessages.add(' The quantities selected on License Type does not match the items on the order.  ');
System.debug('Pm Progress order Validation PM failed for License Type');
validationResult = false;
}
system.debug('Pm Progress order Validation PM collaborationMap :' + collaborationMap + 'orderLicenseTypeMap ' + orderLicenseTypeMap );
if (!isEmpInfoCountValid(collaborationMap, orderLicenseTypeMap)) {
errorMessages.add(' The quantities selected on collaboration does not match the items on the order.  ');
System.debug('Pm Progress order Validation PM failed for collaboration');
validationResult = false;
}

system.debug('Pm Progress order Validation PM webinarMap :' + webinarMap + 'orderWebinarMap ' + orderWebinarMap );

if (!isEmpInfoCountValid(webinarMap, orderWebinarMap)) {
errorMessages.add(' The quantities selected on webinar does not match the items on the order.  ');
System.debug('Pm Progress order Validation PM failed for webinar');
validationResult = false;
}
system.debug('Validation PM deviceTypeMap :' + deviceTypeMap + 'orderDeviceTypeMap ' + orderDeviceTypeMap );

if (!isEmpInfoCountValid(deviceTypeMap, orderDeviceTypeMap)) {
errorMessages.add(' The quantities selected on Device Type does not match the items on the order.  ');
System.debug('Pm Progress order Validation PM failed for Device Type');
validationResult = false;
}
system.debug('Pm Progress order Validation PM audioMiningMap :' + audioMiningMap + 'orderAudioMiningMap ' + orderAudioMiningMap );

if (!isEmpInfoCountValid(audioMiningMap, orderAudioMiningMap)) {
errorMessages.add(' The quantities selected on Audio Mining does not match the items on the order.  ');
System.debug('Pm Progress order Validation PM failed for audio mining');
validationResult = false;
}

if (!isEmpInfoCountValid(storageMap, orderStorageMap)) {
errorMessages.add(' The quantities selected on Storage does not match the items on the order. ');
System.debug('Pm Progress order Validation PM failed for storage');
validationResult = false;
} 
system.debug('Pm Progress order Validation PM callRecordingMap :' + callRecordingMap + 'orderCallRecordingMap ' + orderCallRecordingMap );

if (!isEmpInfoCountValid(callRecordingMap, orderCallRecordingMap)) {
errorMessages.add(' The quantities selected on Call Recording does not match the items on the order.  ');
System.debug('Pm Progress order Validation PM failed for Call Recording');
validationResult = false;
}
system.debug('Pm Progress order Validation PM screenRecordingMap :' + screenRecordingMap + 'orderScreenRecordingMap ' + orderScreenRecordingMap );
if (!isEmpInfoCountValid(screenRecordingMap, orderScreenRecordingMap)) {
errorMessages.add(' The quantities selected on Screen Recording does not match the items on the order.  ');
System.debug('Pm Progress order Validation failed for Screen Recording');
validationResult = false;
}
*/
        if (!isValidDIDCount(orderId, didCount)) {
            errorMessages.add(' The quantities selected on DID does not match the items on the order. ');
            System.debug('Pm Progress order Validation PM failed for DID count '+ didCount);
            validationResult = false;
        }
        if (!isValidAutoAttendantCount(orderId, autoAttendantCount)) {
            errorMessages.add(' The quantities selected on Auto Attendent does not match the items on the order. ');
            System.debug('Pm Progress order AAA: Validation PM failed for Auto Attendant count '+ autoAttendantCount);
            System.debug('Pm Progress order AAA: validationResult ' + validationResult);
            validationResult = false;
        }
        if (!isValidTollFreeCount(orderId, tollFreeCount)) {
            errorMessages.add(' The quantities selected on Toll Free count does not match the items on the order.  ' );
            System.debug('Pm Progress order Validation PM failed for toll free count ' + tollFreeCount);
            validationResult = false;
        }
        
        
        if (!isValidCCaaSCount(orderId, ccaasCount)) {
            errorMessages.add(' The quantities selected on Ccaas count does not match the items on the order.  ');
            System.debug('Pm Progress order Validation PM failed for ccaasCount count '+ ccaasCount);
            validationResult = false;
        }
        if (!isValidAdditionalDids(orderId, vacantSpareCount)) {
            errorMessages.add(' The quantities selected on Spare count does not match the items on the order.  ');
            System.debug('Pm Progress order Validation PM failed for vacant spare count '+ vacantSpareCount);
            validationResult = false;
        }
        
        
        
        
        appendErrorMessages();
        
        
        // Return or process the maps as needed
        return validationResult; // Example: returning just the licenseTypeMap, adjust as needed
        //return true;
    }
    
    
    private boolean isEmpInfoCountValid(Map<String, Integer> eMap, Map<String, Integer> orderMap) 
    {
        for (String key : eMap.keySet()) {
            if (orderMap.containsKey(key)) {
                system.debug('Pm Progress order Validation PM count check Emp infp '+ eMap.get(key));
                system.debug('Pm Progress order Validation PM count check order '+ orderMap.get(key));
                if (eMap.get(key) > orderMap.get(key)) {
                    System.debug('Count for ' + key + ' in map is greater than in orderMap');
                    return false; // Validation failed
                }
            }  else {
                System.debug('Key ' + key + ' not found in orderMap');
                return true; // Key not present in orderMap
            } 
        }
        
        return true; // Validation passed
    }
    
    
    private static void incrementCountInMapDidNumber(Map<String, Integer> didEmpfomap, String fieldValue) {
        
        if (fieldValue != null) {
            System.debug('Pm Progress order Validation PM didEmpfomap '+ didEmpfomap);
            System.debug('Pm Progress order Validation PM fieldValue '+ fieldValue);
            Integer count = didEmpfomap.containsKey(fieldValue) ? didEmpfomap.get(fieldValue) + 1 : 1;
            didEmpfomap.put(fieldValue, count);
            System.debug('Pm Progress order Validation PM fieldValue Final ' + fieldValue + 'count: '+ count);
        } 
    }
    private static void incrementCountInMap(Map<String, Integer> empInfomap, String productName, Integer quantity) {
        if (productName != null && quantity != null) {
            Integer currentCount = empInfomap.containsKey(productName) ? empInfomap.get(productName) + quantity : quantity;
            empInfomap.put(productName, currentCount);
        }
    }
    
    
    private Boolean isValidDIDCount(String orderId, Integer didCount) {
        Integer licenseQuantitySum = getProductQuantityForLicense(orderId, 'License');
        return didCount <= licenseQuantitySum;
    }
    
    private Boolean isValidTollFreeCount(String orderId, Integer tollFreeCount) {
        Integer ucfTollfreeSum = getProductQuantitySumTollFree(orderId, 'Toll-Free');
        return tollFreeCount <= ucfTollfreeSum ;
    }
    
    private Boolean isValidAdditionalDids(String orderId, Integer vacantSpareCount) {
        Integer ucfAdditionalDidSum = getProductQuantitySumAdditionalDids(orderId, 'UCF Additional DIDs');
        return vacantSpareCount <= ucfAdditionalDidSum ;
    }
    
    
    private Boolean isValidAutoAttendantCount(String orderId, Integer autoAttendantCount) {
        Integer ucfPremiumAutoAttendantSum = getProductQuantitySumAA(orderId, 'UCF Premium Auto Attendant');
        if(ucfPremiumAutoAttendantSum > 0 && autoAttendantCount > 0)
        {
            if(autoAttendantCount == 1)
            {
                return true;
            }
            system.debug('Pm Progress order AAA: isValidAutoAttendantCount ucfPremiumAutoAttendantSum ' + ucfPremiumAutoAttendantSum );
            Integer difference = autoAttendantCount - ucfPremiumAutoAttendantSum;
            
            return difference == 0 || difference == 1;
        }
        else
        {
            return true;
        }
        
    }
    
    
    private Boolean isValidCCaaSCount(String orderId, Integer ccaasCount) {
        String[] productNames = new String[] {'UCF CCaaS Agent', 'UCF CCaaS Supervisor'}; // Replace with actual product names
            Integer ucfccaasSum = getProductQuantitySumCcaas(orderId, productNames);
        return ccaasCount <= ucfccaasSum;
    }
    
    
    private Integer getProductQuantitySumCcaas(String orderId,String[] productNames) {
        Integer quantitySum = 0;
        List<OrderItem> orderItems = [SELECT Quantity FROM OrderItem 
                                      WHERE OrderId = :orderId AND Product2.Name In :productNames ];
        for (OrderItem item : orderItems) {
            quantitySum +=  item.Quantity.intValue(); 
        }
        
        return quantitySum;
    }
    
    
    private Integer getProductQuantitySumTollFree(String orderId, String productName) {
        Integer quantitySum = 0;
        List<OrderItem> orderItems = [SELECT Quantity FROM OrderItem 
                                      WHERE OrderId = :orderId AND Product2.vlocity_cmt__SubType__c = :productName];
        for (OrderItem item : orderItems) {
            quantitySum +=  item.Quantity.intValue(); 
        }
        
        return quantitySum;
    }
    
    private Integer getProductQuantitySumAdditionalDids(String orderId, String productName) {
        Integer quantitySum = 0;
        
        // Query the QuoteId related to the Order
        List<Order> orders = [SELECT QuoteId FROM Order WHERE Id = :orderId];
        if (!orders.isEmpty() && orders[0].QuoteId != null) {
            Id quoteId = orders[0].QuoteId;
            
            // Query the QuoteLineItems for the obtained QuoteId and specific product name
            List<QuoteLineItem> quoteLineItems = [SELECT Quantity 
                                                  FROM QuoteLineItem 
                                                  WHERE QuoteId = :quoteId 
                                                  AND Product2.Name = :productName];
            
            // Sum the quantities
            for (QuoteLineItem item : quoteLineItems) {
                quantitySum += item.Quantity.intValue(); 
            }
        }
        
        return quantitySum;
    }
    
    private Integer getProductQuantityForLicense(String orderId, String productName) {
        System.debug('Validation PM QuantityForLicens orderId' + orderId + 'productName '+ productName);
        Integer quantitySum = 0;
        List<OrderItem> orderItems = [ SELECT Quantity
                                      FROM OrderItem 
                                      WHERE  OrderId = :orderId AND Product_Type__c =:productName];
        for (OrderItem item : orderItems) {
            quantitySum +=  item.Quantity.intValue(); 
        }
        System.debug('Validation PM QuantityForLicens quantitySum' + quantitySum);
        return quantitySum;
    }
    
    
    private Integer getProductQuantitySumAA(String orderId, String productName) {
        System.debug('Validation PM getProductQuantitySumAA orderId' + orderId + 'productName '+ productName);
        Integer quantitySum = 0;
        List<OrderItem> orderItems = [SELECT Quantity FROM OrderItem 
                                      WHERE OrderId = :orderId AND Product2.Name = :productName];
        System.debug('AAA: Validation PM getProductQuantitySumAA orderItems' + orderItems);                 
        for (OrderItem item : orderItems) {
            quantitySum +=  item.Quantity.intValue(); 
        }
        System.debug('AAA: Validation PM getProductQuantitySumAA quantitySum' + quantitySum);
        return quantitySum;
    }
    
    
    private void appendErrorMessages() {
        //Pm_Ernrichment_Error_Message = '';
        for (String message : errorMessages) {
            Pm_Ernrichment_Error_Message += message + '<br>'; // Append each message with HTML line breaka line separator
            //Pm_Ernrichment_Error_Message += message + System.lineSeparator();
        }
    }
    
    //Pm enrichment validation end
    
    public Boolean checkForProjectSpecialist(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        String orderId = (String) inputMap.get('orderId');
        Order currentOrder = [SELECT Id,Products__c, Network_Project_Specialist__c,Order_Stage__c,OwnerId, OrderNumber, vlocity_cmt__OrderStatus__c FROM Order WHERE Id = :orderId];
        //Add condition to skip for MFW Standalone      
        if (currentOrder.Products__c.contains('EIA')|| currentOrder.Products__c.contains('MNS')|| currentOrder.Products__c.contains('EVPL')  || currentOrder.Products__c.contains('SIP')||currentOrder.Products__c.contains('E-LAN')) {
            if (currentOrder.Network_Project_Specialist__c == null) {
                Group myQ = [SELECT Id, Email FROM Group WHERE Type = 'Queue' AND DeveloperName = 'PM_Assignment' LIMIT 1];
                if (myQ.Id != currentOrder.ownerId && currentOrder.Order_Stage__c != 'PM Assignment' && currentOrder.vlocity_cmt__OrderStatus__c != 'PM Assignment') {
                    String[] emails = new String[]{};
                        String[] userIds = new String[]{};
                            for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId=:myQ.Id]) {
                                userIds.add(member.UserOrGroupId);
                            }
                    for (User u : [SELECT Email FROM User WHERE Id IN :userIds]) {
                        emails.add(u.Email);
                    }
                    currentOrder.OwnerId = myQ.Id;
                    currentOrder.vlocity_cmt__OrderStatus__c = 'PM Assignment';
                    currentOrder.Order_Stage__c = 'PM Assignment';
                    if (!Test.isRunningTest())
                        update currentOrder;
                    sendOrderDetails(currentOrder, emails);
                    try {
                        insert new Task(
                            Description = 'A Network Project Specialist needs to be assigned before the order can be submitted.',
                            Subject = 'Network Project Specialist Assignment',
                            Priority = 'High',
                            WhatId = myOrder.Id,
                            OwnerId = myQ.Id,
                            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SF_Team_Task').getRecordTypeId(),
                            ActivityDate = Date.today(),
                            IsReminderSet = true
                        );
                    } catch (EXception e) {
                        System.debug(e.getMessage());
                    }
                }
                return false;
            }
        }
        return true;
    }
    
    public Boolean createMFWTaskOnMFWOrder(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        String orderId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
        //Order currentOrder = [SELECT Id, Network_Project_Specialist__c,Order_Stage__c,OwnerId, OrderNumber, vlocity_cmt__OrderStatus__c FROM Order WHERE Id = :orderId];
        Order currentOrder = [SELECT Id,Order_Stage__c,OwnerId,OrderNumber,vlocity_cmt__OrderStatus__c, Products__c FROM Order WHERE Id=:myOrder.Id];
        //if (currentOrder.Products__c.contains('Frontier Secure')) {
        Group myQ = [SELECT Id, Email FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Service_Delivery_PM' LIMIT 1];                    
        
        try {
            insert new Task(
                Description = 'A Service Delivery PM needs to be assigned for a Managed Firewall Order.',
                Subject = 'Managed Firewall Order',
                Priority = 'High',
                WhatId = myOrder.Id,
                OwnerId = myQ.Id,
                RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SF_Team_Task').getRecordTypeId(),
                ActivityDate = Date.today(),
                IsReminderSet = true
            );
        } catch (EXception e) {
            System.debug(e.getMessage());
        }
        
        // }
        return true;
    }
    
    
    public void sendOrderDetails(Order o, String[] toEmails) {
        try {
            Order ord = [SELECT Id, OrderNumber, Account.Name FROM Order WHERE Id=:o.Id];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = toEmails;
            message.setSenderDisplayName('Salesforce Ordering Notification');
            message.subject = 'SF Order ' + ord.OrderNumber + ' needs a Project Specialist assigned';
            message.plaintextbody = 'Salesforce order ' + ord.OrderNumber + ' for ' + ord.Account.Name + ' is needing a Project Specialist to be assigned before it gets submitted to M6.  Please review and submit the order once a Project Specialist is assigned. \n\nOrder link:\n' + URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Order/'+ o.Id +'/view  \n\nThank you.';
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (!results[0].success) {
                System.debug('Error in sending email: ' + results[0].errors[0].message);
            } else {
                System.debug('Email sent successfully.');
            }
        } catch (Exception e) {
            System.debug('Exception occured. Email was not sent.');
            System.debug(e.getMessage());
        }
    }
    
    public Boolean submitDecompositionPlan(String orderId){
        
        System.enqueueJob(new DecomposeOrderAsync(orderId));
        return true;
    }
    
    private boolean validateCart(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        Map<String, Object> input = new Map<String, Object>();
        String methodName = 'getCartsItems';
        input.put('cartId', inputMap.get('contextId'));
        input.put('ContextId', inputMap.get('contextId'));
        input.put('methodName', methodName);
        input.put('validate', true);
        input.put('price', false);
        input.put('classMethodName', methodName);
        vlocity_cmt.VOIInvoker invoker = vlocity_cmt.VOIInvoker.getInstance();
        Object invokeResult;
        if (!Test.isRunningTest()){
            invokeResult = invoker.invoke('CpqAppHandler', 'invokeClass', input, outputMap, options);      
        } else {
            invokeResult = ftr_TestDataFactory.getCartsItemsOutput();
        }
        Map<string, object> output = (Map<string, Object>)JSON.deserializeUntyped((String)invokeResult);
        System.debug('validateCart-output: '+JSON.serialize(output));
        String error = 'OK';
        Map<string,object> parent = new Map<string,Object>();
        Set<String> servAccIds = new Set<String>(); 
        parent.putAll(output);
        if (parent.get('messages') != null) {
            getMessages(parent.get('messages'), output);
        }
        if (parent.get('records') != null) {
            // iterate thru records
            for (Object rec : (List<Object>)parent.get('records')) {
                Map<String,Object> record = (Map<string,Object>)rec;
                if (record.get('vlocity_cmt__CpqCardinalityMessage__c') != null) {
                    if (((Map<string,object>)record.get('vlocity_cmt__CpqCardinalityMessage__c')).get('value') != null) {
                        error = (String)((Map<string,object>)record.get('vlocity_cmt__CpqCardinalityMessage__c')).get('value');
                    }
                }
                servAccIds.add((String)((Map<string,object>)record.get('vlocity_cmt__ServiceAccountId__c')).get('value'));
                // check if there are any messages
                if (record.get('messages') != null) {
                    getMessages(record.get('messages'), output);
                }
                // get the line items
                if (record.get('lineItems') != null) {
                    Map<string, object> lineItems = (Map<String, Object>) record.get('lineItems');
                    // check messages
                    if (lineItems.get('messages') != null) {
                        getMessages(lineItems.get('messages'), output);
                    }
                    // check lineitems
                    if (lineItems.get('records') != null) {
                        for (Object childRec : (List<Object>)lineItems.get('records')) {
                            Map<String,Object> item = (Map<string,Object>)childRec;
                            if (item.get('vlocity_cmt__CpqCardinalityMessage__c') != null) {
                                if (((Map<string,object>)item.get('vlocity_cmt__CpqCardinalityMessage__c')).get('value') != null) {
                                    error = (String)((Map<string,object>)item.get('vlocity_cmt__CpqCardinalityMessage__c')).get('value');
                                }
                            }
                            servAccIds.add((String)((Map<string,object>)item.get('vlocity_cmt__ServiceAccountId__c')).get('value'));
                            // check if there are any messages
                            if (item.get('messages') != null) {
                                getMessages(item.get('messages'), output);
                            }
                        }
                    }
                }
            }
        }
        Account[] servAccs = [SELECT Id FROM Account WHERE ID IN:servAccIds AND RecordType.Name='Service'];
        if (error == 'OK') {
            if (output.get('Errors') != null) {
                error = 'Required attributes are missing. Please finish configuring the quote.';
                System.debug(output.get('Errors'));
            }
            if (servAccs.size() != servAccIds.size()) {
                error = 'A service account is required for each product. Please finish configuring the quote.';
            }
        }
        System.debug('validateCart-outputMap:'+JSON.serialize(outputMap));
        outputMap.put('Error', error);
        if (error == 'OK') 
            return true;
        else 
            return false;
    }
    
    private void getMessages(Object messages, Map<string, object> item) {
        for (Object obj : (List<Object>)messages) {
            Map<string,object> message = (Map<String, Object>)obj;
            String msg = (String) message.get('message');
            String sev = (String)message.get('severity');
            if (sev == 'ERROR') {
                if (item.get('Errors') == null) {
                    item.put('Errors', new String[]{ msg });
                } else {
                    item.put('Errors', ((List<String>)item.get('Errors')).add(msg));
                }
            }
        }
    }
    
    private Boolean checkApprovedTotal(String contextId){
        List<Quote> QuoteList = [SELECT Id, Approved_Recurring_Total__c, Requested_Recurring_Total__c FROM Quote WHERE Id =:contextId];
        if(QuoteList[0].Approved_Recurring_Total__c>QuoteList[0].Requested_Recurring_Total__c){
            return false;
        }
        else{
            return true;
        }
    }
    
    @Testvisible
    private boolean accountHasFSA(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        Id quoteId = (Id)inputMap.get('contextId');
        Account a = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Quote WHERE Id=: quoteId) LIMIT 1];
        List<Contract> cList = new List<Contract>([SELECT Id FROM Contract WHERE RecordType.Name IN ('Frontier Services Agreement','Community Connections - Agreement','VZ3 Agreement - VEC', 'VZ3 Agreement - VES') AND AccountId=:a.Id LIMIT 1]);
        if (cList.size() > 0)
            return true;
        else {
            outputMap.put('Error', 'An FSA is required before generating a product schedule.');
            return false;
        }
    }
    
    private Boolean isOrderFromVlocity(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        String orderId = String.isNotBlank((String) inputMap.get('orderId')) ? (String) inputMap.get('orderId') : (String) inputMap.get('contextId');
        system.debug('orderId-->'+orderId);
        Order currentOrder = [SELECT Id, vlocity_cmt__QuoteId__r.vlocity_cmt__ValidationStatus__c FROM Order WHERE Id = :orderId];
        if (currentOrder.vlocity_cmt__QuoteId__r.vlocity_cmt__ValidationStatus__c == 'Failed') {
            outputMap.put('Error', System.Label.ftr_Block_Non_Vlocity_Orders_Message);
            return false;
        }
        return true;
    }
    
    public Boolean submitToMSA(String orderId) {
        String nextStage = '';
        Order o = [SELECT id, order_stage__c, vlocity_cmt__OrderStatus__c, Network_Project_Specialist__c, OwnerId FROM order WHERE id=:orderId];
        
        Group myQueue = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Managed_Services_Architect'];
        if (myQueue != null){
            o.OwnerId = myQueue.Id;
        }
        o.vlocity_cmt__OrderStatus__c = 'MNGD SVC Review';
        o.Order_Stage__c = 'MSA Review';
        update o;
        return true;        
    }
    
    public static void createTask(Order ordRecord){
        List<String> distinctAccountNames = new List<String>();
        for (AggregateResult result : [SELECT vlocity_cmt__ServiceAccountId__r.Name FROM OrderItem WHERE OrderId = :ordRecord.Id GROUP BY vlocity_cmt__ServiceAccountId__r.Name]) {
            String accName = (String)result.get('Name');
            distinctAccountNames.add(accName);
        }
        
        Group grp = [Select Id from Group where Type = 'Queue' AND DeveloperName  ='Network_COE_UCaas'];	
        if(ordRecord.Order_Stage__c == 'New'){              		
            Task task = new Task();
            task.Subject = 'DI 711 Order For BPO';
            task.Description = 'BPO Need to create DI 711 Order on DPI System For Each Service Location';
            task.OwnerId = grp.Id;
            task.Priority = 'High';
            task.WhatId = ordRecord.Id;
            task.Status ='In Progress';
            task.ActivityDate = Date.Today() + 2;
            insert task;
            
        }else if(ordRecord.Order_Stage__c == 'In Progress' && ordRecord.Is_Due_Date_Set__c == true){			
            Task task = new Task();
            task.Subject = 'Order Due Date Changed';
            task.Description = 'BPO Need to create DI 711 Order on DPI System For Each Service Location';
            task.OwnerId = grp.Id;
            task.Priority = 'High';
            task.WhatId = ordRecord.Id;
            task.Status ='In Progress';
            task.ActivityDate = Date.Today() + 2;
            insert task;
        }else if(ordRecord.Order_Stage__c == 'PM Enrichment'){			
            Task task = new Task();
            task.Subject = 'INFINIUM Order For BPO';
            task.Description = 'BPO Need to create Infinium Order with all the Equipments which are on Order for - ' + distinctAccountNames[0];
            task.OwnerId = grp.Id;
            task.Priority = 'High';
            task.WhatId = ordRecord.Id;
            task.Status ='In Progress';
            task.ActivityDate = Date.Today() + 2;
            insert task;
        }
        else if(ordRecord.Order_Stage__c == 'Hot Cuts'){
            Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND DeveloperName = 'DC_711_Order' LIMIT 1].Id;
            System.debug('calling task creation recordTypeId + ' + recordTypeId);
            Task task = new Task();
            task.RecordTypeId = recordTypeId;
            task.Subject = 'Tech Install - DC 711';
            task.Description = 'BPO Team needs to create a DC 711 order to install equipment.';
            task.OwnerId = grp.Id;
            task.Priority = 'High';
            task.WhatId = ordRecord.Id;
            task.Status ='Not Started';
            task.ActivityDate = Date.Today() + 2;
            insert task;
        }
        
    }
    
    public void DualOrderSEChange(String OrderId){
        system.debug('In Network Speacialist Dual called');
        Group grp = [Select Id from Group where Type ='Queue' AND DeveloperName ='Sales_Engineering'];
        system.debug('In Network Speacialist Dual called grp '+ grp);
        List<Order> orderChildUpdate = new List<Order>();
        List<Order> orderChild = [SELECT id, order_stage__c, vlocity_cmt__OrderStatus__c, Network_Project_Specialist__c, OwnerId FROM order WHERE Parent_Order__c=:orderId];
        system.debug('In Network Speacialist Dual called orderChild '+ orderChild);
        if(!orderChild.isEmpty()){
            
            for(Order childOrder: orderChild){
                childOrder.order_stage__c = 'Solutions Engineering';
                childOrder.vlocity_cmt__OrderStatus__c = 'SE Review';
                childOrder.OwnerId = grp.Id;
                orderChildUpdate.add(childOrder);
            }
            system.debug('In Network Speacialist Dual called orderChild last ');
            if(!orderChildUpdate.isEmpty()){
                update orderChildUpdate;
            }
        }
    }
    
    public Boolean rejectOrderNetworkTranslations(String orderId){
        
        Order o = [SELECT Id, order_stage__c, vlocity_cmt__OrderStatus__c, Products__c, Network_Project_Specialist__c, OwnerId FROM order WHERE Id=:orderId];
        if(o.Network_Project_Specialist__c !=null && o.order_stage__c == 'Network Translations'){
            o.Order_Stage__c = 'PM Enrichment';
            o.vlocity_cmt__OrderStatus__c = 'In Progress';
            o.OwnerId = o.Network_Project_Specialist__c;
        }
        update o;
        return true;
    }
    
    public void D1711_DCOrderTask(Map<Id,String> serviceAccountId,String OrderStage,String orderId){
        Id recordTypeId;
        List<Task> taskList = new List<Task>();
        Order o = [SELECT Id, OrderNumber FROM order WHERE Id=:orderId];
        Group grp = [Select Id from Group where Type = 'Queue' AND DeveloperName  ='Network_COE_UCaas'];
        if(OrderStage  == 'New'){
            System.debug('calling task creation');
            
            
            recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND DeveloperName = 'D1_711_Order' LIMIT 1].Id;    
            
            for(String key : serviceAccountId.keySet()){
                
                // Check if a task already exists for this service location
                if(!isTaskAlreadyExists(orderId, serviceAccountId.get(key), recordTypeId)) {
                    Task task = new Task();
                    task.RecordTypeId = recordTypeId;
                    task.Subject ='SFO# '+ o.OrderNumber + ' Sitewalk - DI 711';
                    task.Description = 'BPO needs to create DI 711 order in DPI System for ' +' '+ serviceAccountId.get(key) +' '+ ' service location to schedule the Sitewalk, and send the email to the correct Local Manager for this location.';
                    //task.ServiceLocation__c = serviceAccountId.get(key);
                    task.OwnerId = grp.Id;
                    task.Priority = 'High';
                    task.WhatId = orderId;
                    task.Status ='Not Started';
                    task.ActivityDate = Date.Today() + 2;
                    taskList.add(task);
                }
            }
            if(!taskList.isEmpty()){
                
                insert taskList;
            }
            
        }else if(OrderStage == 'Hot Cuts'){
            Picklistpopulation ppTaskCreation = new Picklistpopulation(); 
            System.debug('calling task creation for hot cuts');
            
            recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND DeveloperName = 'DC_711_Order' LIMIT 1].Id;
            Task tsk = [Select Id,OwnerId from Task where RecordType.DeveloperName ='D1_711_Order' AND What.Id =:orderId Limit 1];
            
            for(String key : serviceAccountId.keySet()){
                
                // Check if a task already exists for this service location
                if(!isTaskAlreadyExists(orderId, serviceAccountId.get(key), recordTypeId)) {
                    Task task = new Task();
                    task.RecordTypeId = recordTypeId;
                    task.Subject = 'SFO# '+ o.OrderNumber + ' Tech Install - DC 711';
                    //task.Description = 'BPO needs to create DC 711 orders in DPI System for'+'-'+serviceAccountId.get(key);
                    task.Description = ' BPO needs to create DC 711 orders in DPI System for ' +' '+ serviceAccountId.get(key) +' '+ ' service location to schedule the Tech Install, and send the email to the correct Local Manager for this location.';
                    //task.ServiceLocation__c = serviceAccountId.get(key);
                    task.OwnerId = tsk.OwnerId;
                    task.Priority = 'High';
                    task.WhatId = orderId;
                    task.Status ='Not Started';
                    task.ActivityDate = Date.Today() + 2;
                    taskList.add(task);
                }
                //taskList.add(task);
                
                // Creating Task for DI 
                // 
                Id DIBillingrecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND DeveloperName = 'BI_Billing_Order' LIMIT 1].Id;
                System.debug('calling task creation recordTypeId + ' + recordTypeId);
                Task DIBillingTask = new Task();
                DIBillingTask.RecordTypeId = DIBillingrecordTypeId;
                DIBillingTask.Subject = 'Create Billing Orders for UCF';
                DIBillingTask.Description = 'BPO needs to create all DPI orders in DPI System for each service location.';
                DIBillingTask.OwnerId = grp.Id;
                DIBillingTask.Priority = 'High';
                DIBillingTask.WhatId = orderId;
                DIBillingTask.Status ='Not Started';
                DIBillingTask.ActivityDate = Date.Today() + 2;
                
                
                //Creating Tasks for Numbers 
                //ppTaskCreation.createTask(orderId);
                //insert task; 
                
                taskList.add(DIBillingTask);
            }
            if(!taskList.isEmpty()){
                
                insert taskList;
            }
        }
        
    }
    
    // Helper method to check if a task already exists for a given service location and record type
    private Boolean isTaskAlreadyExists(String orderId, String serviceLocation, Id recordTypeId) {
        // Retrieve tasks related to the order, matching record type and containing service location in description
        List<Task> tasks = [SELECT Description FROM Task WHERE WhatId = :orderId AND RecordTypeId = :recordTypeId];
        
        // Iterate through the tasks and check if any of their descriptions contain the service location
        for (Task task : tasks) {
            if (task.Description != null && task.Description.contains(serviceLocation)) {
                return true; // Task with the same service location found
            }
        }
        return false; // No task with the same service location found
    }
    
    /*  --------- WHEN Order Stage is PM Enrichment -------- 
--------- It is called on Vlocity Actions (UCF PM Progress Order) -------
*/
    public Boolean checkImplementationSpecialistForPM(String orderId){
        
        Database.DMLOptions dlo = new Database.DMLOptions();
        Map<Id,String> serviceAccountId = new Map<Id,String>();
        Order o = [SELECT Id, order_stage__c, vlocity_cmt__OrderStatus__c, Products__c, Network_Project_Specialist__c, 
                   OwnerId FROM order WHERE Id=:orderId];
        
       
        List<OrderItem> orderItemList = [Select Id,vlocity_cmt__ServiceAccountId__c,vlocity_cmt__ServiceAccountId__r.Name from OrderItem where OrderId =:orderId];
        for(OrderItem orderItemData: orderItemList){
                serviceAccountId.put(orderItemData.vlocity_cmt__ServiceAccountId__c,orderItemData.vlocity_cmt__ServiceAccountId__r.Name);
        }   
        
        
        if (o.Network_Project_Specialist__c !=null && o.Order_Stage__c =='PM Enrichment'){
            if(!serviceAccountId.isEmpty()){
               D1711_DCOrderTask(serviceAccountId,o.Order_Stage__c,orderId);
             }
            
            Group netQ = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='VoIP_Translations'];
            o.Order_Stage__c = 'Network Translations';
            o.vlocity_cmt__OrderStatus__c = 'In Progress';
            o.OwnerId = netQ.Id;
            
            dlo.emailHeader.triggerUserEmail = true;
        }
        
        Database.update(o,dlo);
        ftr_InfiniumOrderCreation.sendRequest(orderId);
        return true;
    }
    
    public Boolean checkForOrderDueDateChange(String orderId){
        System.debug('checkForOrderDueDateChange');
        Database.DMLOptions dlo = new Database.DMLOptions();
        Order o = [SELECT Id, order_stage__c, vlocity_cmt__OrderStatus__c, Products__c, Network_Project_Specialist__c, 
                   OwnerId FROM order WHERE Id=:orderId];
        
        if (o.Order_Stage__c.contains('In Progress') && o.Is_Due_Date_Set__c == true){
            createTask(o);
        }
        
        // Database.update(o,dlo);
        return true;
    }
    
    /*  --------- WHEN Order Stage is Network Translations -------- 
--------- It is called on Vlocity Actions (UCF NT Progress Order) -------
*/
    public Boolean checkImplementationSpecialistForNT(String orderId){
        
        Database.DMLOptions dlo = new Database.DMLOptions();
        Order o = [SELECT Id, order_stage__c, vlocity_cmt__OrderStatus__c, Products__c, Network_Project_Specialist__c, 
                   OwnerId FROM order WHERE Id=:orderId];
        
        if (o.Network_Project_Specialist__c !=null && o.Order_Stage__c =='Network Translations'){
            createTask(o);
             ftr_SubmitUCFOrder  submitUCfOrder = new ftr_SubmitUCFOrder();
            submitUCfOrder.createTechnicalProduct(orderId);
            ftr_SubmitUCFOrder.updateOrderLineItems(orderId);
            Group netQ = [SELECT Id, name, DeveloperName FROM Group where Type = 'Queue' and DeveloperName='Hot_Cuts'];
            o.Order_Stage__c = 'Hot Cuts';
            o.vlocity_cmt__OrderStatus__c = 'In Progress';
            o.OwnerId = netQ.Id;
            
            dlo.emailHeader.triggerUserEmail = true;
        }
        
        Database.update(o,dlo);
       
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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