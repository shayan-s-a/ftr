public without sharing class OrderUtility {
    /* SDDD-4527 created boolean variable for controlling recursion added by Swetha Chandu */
    public static Boolean isFirstTime = false;
    public static void reassignNetworkCOE(List<Order> newOrderList, Map<Id, Order> oldOrderList) {
        
        List<Order> ordersToReassign = new List<Order>();
        List<Id> orderAccountIdList = new List<Id>();
        List<Id> orderIdList = new List<Id>();
        
        //loop through all the incoming orders and store the ones relevant to this method
        for(Order newOrder : newOrderList) {
            Order oldOrder = (Order) oldOrderList.get(newOrder.Id);
            
            if(newOrder.Broadband_Queue_Assignment__c != null && ((oldOrder != null && oldOrder.Broadband_Queue_Assignment__c != newOrder.Broadband_Queue_Assignment__c) || oldOrder == null)) {
                ordersToReassign.add(newOrder);
                orderAccountIdList.add(newOrder.accountId);
                orderIdList.add(newOrder.Id);
            }
        }
        
        if(orderAccountIdList != null && orderAccountIdList.size() > 0) {
            
            Group networkCoeDevQueue = [SELECT id FROM Group WHERE developername = 'NetworkCOE_Dev' LIMIT 1];
            Id networkCoeDevQueueId = networkCoeDevQueue.Id;
            
            Group networkCoeAssignersQueue = [SELECT id FROM Group WHERE developername = 'Network_COE_Assigners' LIMIT 1];
            Id networkCoeAssignersQueueId = networkCoeAssignersQueue.Id;
            
            //Get all the territories for those accounts that haven't been flagged as deleted.
            List<ObjectTerritory2Association> accountTerritories = [SELECT id, IsDeleted, Territory2Id, objectId, territory2.POD_Assignment__c 
                                                                    FROM ObjectTerritory2Association 
                                                                    WHERE IsDeleted = false 
                                                                    AND objectid IN :orderAccountIdList];
            
            //Get the list of territory pod assignments as well as a mapping of the accountId to all the associated territories' pod assignments (to make comparisons easier later on)
            Map<Id, String> accountIdToPodAssignment = new Map<Id, String>();
            List<String> podAssignmentList = new List<String>();
            for(ObjectTerritory2Association accountTerritory : accountTerritories) {
                
                //Don't bother doing anything if the territory has no pod Assignment
                if(!String.isEmpty(accountTerritory.territory2.POD_Assignment__c)) {
                    podAssignmentList.add(accountTerritory.territory2.POD_Assignment__c);
                    accountIdToPodAssignment.put(accountTerritory.objectId, accountTerritory.territory2.POD_Assignment__c);
                }
            }//for(ObjectTerritory2Association accountTerritory : accountTerritories)
            
            //Get all the queues named after the associated pods
            List<Group> podQueues = [SELECT id, Type, Name 
                                     FROM Group 
                                     WHERE Type = 'Queue' 
                                     AND Name IN :podAssignmentList];
            
            Map<Id, Id> orderIdToPodQueueId = new Map<Id, Id>();
            
            //Loop through the relevant orders once more and map the order Id to the associated Pod Queue Id
            for(Order ord : ordersToReassign) {
                
                //Loop through the associated Queues
                for(Group podQueue : podQueues) {
                    if(podQueue.name == accountIdToPodAssignment.get(ord.accountId)) {
                        orderIdToPodQueueId.put(ord.Id, podQueue.Id);
                    }
                }
            }
            
            //Query for all the related approval processes.
            List<ProcessInstanceWorkItem> relevantWorkItems = [SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActorId, Id, ActorId
                                                               FROM ProcessInstanceWorkitem
                                                               WHERE ProcessInstance.TargetObjectId IN :orderIdList
                                                               AND ActorId = :networkCoeDevQueueId];
            
            List<ProcessInstanceWorkItem> workItemListToUpdate = new List<ProcessInstanceWorkItem>();
            
            //Loop through the relevant approval processes and reassign them to the appropriate Pod Queue
            for(ProcessInstanceWorkItem piwi : relevantWorkItems) {
                //If there is a territorially relevant pod queue to assign to this Approval Process then assign that.
                if(orderIdToPodQueueId.get(piwi.ProcessInstance.TargetObjectId) != null) {
                    piwi.ActorId = orderIdToPodQueueId.get(piwi.ProcessInstance.TargetObjectId);
                } else {
                    //Otherwise, assign it to the 'Network COE - Assigners' queue, a queue specifically created to be our queue of last resort.
                    piwi.ActorId = networkCoeAssignersQueueId;
                }
                
                workItemListToUpdate.add(piwi);
            }
            
            if(workItemListToUpdate != null && workItemListToUpdate.size() > 0) {
                update workItemListToUpdate;
            }
        }//end of if(orderAccountIdList != null && orderAccountIdList.size() > 0)
    }//end of reassignNetworkCOE(List<Order> newOrderList, Map<Id, Order> oldOrderList)
    
    public static void reassignCPECOE(List<Order> newOrderList, Map<Id, Order> oldOrderList) {
        
        List<Order> ordersToReassign = new List<Order>();
        List<Id> orderAccountIdList = new List<Id>();
        List<Id> orderIdList = new List<Id>();
        
        //loop through all the incoming orders and store the ones relevant to this method
        for(Order newOrder : newOrderList) {
            Order oldOrder = (Order) oldOrderList.get(newOrder.Id);
            
            if(newOrder.Broadband_Queue_Assignment__c != null && ((oldOrder != null && oldOrder.Broadband_Queue_Assignment__c != newOrder.Broadband_Queue_Assignment__c) || oldOrder == null)) {
                ordersToReassign.add(newOrder);
                orderAccountIdList.add(newOrder.accountId);
                orderIdList.add(newOrder.Id);
            }
        }
        
        Map<Id, String> accountIdToCPECOEQueueName = new Map<Id, String>();        
        
        if(orderAccountIdList != null && orderAccountIdList.size() > 0) {
            
            Group cpeCoeDevQueue = [SELECT id FROM Group WHERE developername = 'CPECOE_Dev'];
            Id cpeCoeDevQueueId = cpeCoeDevQueue.Id;
            
            //Get the Accounts' state information so we can use it to find the appropriate queues.
            List<Account> associatedAccounts = [SELECT id, name, ShippingStateCode FROM Account WHERE id IN :orderAccountIdList];
            
            String easternCOEGroupName = 'CPE COE - East';
            String centralCOEGroupName = 'CPE COE - Central';
            String westernCOEGroupName = 'CPE COE - West';
            
            
            List<String> coeGroupRegionNameList = new List<String>{easternCOEGroupName, centralCOEGroupName, westernCOEGroupName};
                
                for(Account acc : associatedAccounts) {
                    //The following is patterned after the formula in the formula field CPECOE_State_formula__c on the object Order_Team_Member__c.
                    
                    Set<String> easternStateCodes = new Set<String>{'AL', 'CT', 'FL', 'GA', 'MS', 'NC', 'NY', 'PA', 'SC', 'TN', 'WV'};
                        Set<String> centralStateCodes = new Set<String>{'IA', 'IL', 'IN', 'MI', 'MN', 'NE', 'OH', 'TX', 'WI'};
                            Set<String> westernStateCodes = new Set<String>{'AZ', 'CA', 'ID', 'MT', 'NM', 'NV', 'OR', 'UT', 'WA'};
                                
                                if(easternStateCodes.contains(acc.ShippingStateCode)) {
                                    accountIdToCPECOEQueueName.put(acc.id, easternCOEGroupName);
                                } 
                    else if(centralStateCodes.contains(acc.ShippingStateCode)) {
                        accountIdToCPECOEQueueName.put(acc.id, centralCOEGroupName);
                    } 
                    else if(westernStateCodes.contains(acc.ShippingStateCode)) {
                        accountIdToCPECOEQueueName.put(acc.id, westernCOEGroupName);
                    }
                }
            
            //Get all the queues named after the associated regions
            List<Group> regionQueues = [SELECT id, Type, Name 
                                        FROM Group 
                                        WHERE Type = 'Queue' 
                                        AND Name IN :coeGroupRegionNameList];
            //AND Name = :easternCOEGroupName OR Name = :centralCOEGroupName OR Name = :westernCOEGroupName];
            
            Map<Id, Id> orderIdToRegionQueueId = new Map<Id, Id>();
            
            //Loop through the relevant orders once more and map the order Id to the associated Pod Queue Id
            for(Order ord : ordersToReassign) {
                
                //Loop through the associated Queues
                for(Group regionQueue : regionQueues) {
                    if(regionQueue.name == accountIdToCPECOEQueueName.get(ord.accountId)) {
                        orderIdToRegionQueueId.put(ord.Id, regionQueue.Id);
                    }
                }
            }
            
            //Query for all the related approval processes.
            List<ProcessInstanceWorkItem> relevantWorkItems = [SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActorId, Id, ActorId
                                                               FROM ProcessInstanceWorkitem
                                                               WHERE ProcessInstance.TargetObjectId IN :orderIdList
                                                               AND ActorId = :cpeCoeDevQueueId];
            
            List<ProcessInstanceWorkItem> workItemListToUpdate = new List<ProcessInstanceWorkItem>();
            
            //Loop through the relevant approval processes and reassign them to the appropriate Region Queue
            for(ProcessInstanceWorkItem piwi : relevantWorkItems) {
                piwi.ActorId = orderIdToRegionQueueId.get(piwi.ProcessInstance.TargetObjectId);
                
                if(piwi.ActorId != null) {
                    workItemListToUpdate.add(piwi);
                }
            }
            
            if(workItemListToUpdate != null && workItemListToUpdate.size() > 0) {
                update workItemListToUpdate;
            }
        }//end of if(orderAccountIdList != null && orderAccountIdList.size() > 0)
    }//end of reassignCPECOE(List<Order> newOrderList, Map<Id, Order> oldOrderList)
    
    public static void reassignApprovalOwner(List<Order> newOrderList, Map<Id, Order> oldOrderList) {
        List<Id> orderIdList = new List<Id>();
        List<Id> oldAssigneeIds = new List<Id>();
        Map<Id, List<Id>> orderIdToOldAssigneeIds = new Map<Id, List<Id>>();
        Map<Id, Id> oldAssigneeIdToNewAssigneeId = new Map<Id, Id>();
        
        //loop through all the incoming orders and store the ones relevant to this method
        for(Order newOrder : newOrderList) {
            Order oldOrder = (Order) oldOrderList.get(newOrder.Id);
            Boolean relevantOrder = false;
            
            if(newOrder.CPE_DCS__c != null && newOrder.CPE_DCS__c != oldOrder.CPE_DCS__c && oldOrder.CPE_DCS__c != null) {
                relevantOrder = true;
                
                List<Id> tempAssigneeIds = new List<Id>();
                if(orderIdToOldAssigneeIds.get(newOrder.Id) != null) {
                    tempAssigneeIds = orderIdToOldAssigneeIds.get(newOrder.Id);
                }
                tempAssigneeIds.add(oldOrder.CPE_DCS__c);
                orderIdToOldAssigneeIds.put(newOrder.Id, tempAssigneeIds);
                
                oldAssigneeIds.add(oldOrder.CPE_DCS__c);
                oldAssigneeIdToNewAssigneeId.put(oldOrder.CPE_DCS__c, newOrder.CPE_DCS__c);
            }
            if(newOrder.Hot_Cut__c != null && newOrder.Hot_Cut__c != oldOrder.Hot_Cut__c && oldOrder.Hot_Cut__c != null) {
                relevantOrder = true;
                
                List<Id> tempAssigneeIds = new List<Id>();
                if(orderIdToOldAssigneeIds.get(newOrder.Id) != null) {
                    tempAssigneeIds = orderIdToOldAssigneeIds.get(newOrder.Id);
                }
                tempAssigneeIds.add(oldOrder.Hot_Cut__c);
                orderIdToOldAssigneeIds.put(newOrder.Id, tempAssigneeIds);
                
                oldAssigneeIds.add(oldOrder.Hot_Cut__c);
                oldAssigneeIdToNewAssigneeId.put(oldOrder.Hot_Cut__c, newOrder.Hot_Cut__c);
            }
            if(newOrder.VoIP_Translations__c != null && newOrder.VoIP_Translations__c != oldOrder.VoIP_Translations__c && oldOrder.VoIP_Translations__c != null) {
                relevantOrder = true;
                
                List<Id> tempAssigneeIds = new List<Id>();
                if(orderIdToOldAssigneeIds.get(newOrder.Id) != null) {
                    tempAssigneeIds = orderIdToOldAssigneeIds.get(newOrder.Id);
                }
                tempAssigneeIds.add(oldOrder.VoIP_Translations__c);
                orderIdToOldAssigneeIds.put(newOrder.Id, tempAssigneeIds);
                
                oldAssigneeIds.add(oldOrder.VoIP_Translations__c);
                oldAssigneeIdToNewAssigneeId.put(oldOrder.VoIP_Translations__c, newOrder.VoIP_Translations__c);
            }
            if(newOrder.CPE_COE__c != null && newOrder.CPE_COE__c != oldOrder.CPE_COE__c && oldOrder.CPE_COE__c != null) {
                relevantOrder = true;
                
                List<Id> tempAssigneeIds = new List<Id>();
                if(orderIdToOldAssigneeIds.get(newOrder.Id) != null) {
                    tempAssigneeIds = orderIdToOldAssigneeIds.get(newOrder.Id);
                }
                tempAssigneeIds.add(oldOrder.CPE_COE__c);
                orderIdToOldAssigneeIds.put(newOrder.Id, tempAssigneeIds);
                
                oldAssigneeIds.add(oldOrder.CPE_COE__c);
                oldAssigneeIdToNewAssigneeId.put(oldOrder.CPE_COE__c, newOrder.CPE_COE__c);
            }
            if(newOrder.Broadband_COE__c != null && newOrder.Broadband_COE__c != oldOrder.Broadband_COE__c && oldOrder.Broadband_COE__c != null) {
                relevantOrder = true;
                
                List<Id> tempAssigneeIds = new List<Id>();
                if(orderIdToOldAssigneeIds.get(newOrder.Id) != null) {
                    tempAssigneeIds = orderIdToOldAssigneeIds.get(newOrder.Id);
                }
                tempAssigneeIds.add(oldOrder.Broadband_COE__c);
                orderIdToOldAssigneeIds.put(newOrder.Id, tempAssigneeIds);
                
                oldAssigneeIds.add(oldOrder.Broadband_COE__c);
                oldAssigneeIdToNewAssigneeId.put(oldOrder.Broadband_COE__c, newOrder.Broadband_COE__c);
            }
            if(relevantOrder) {
                orderIdList.add(newOrder.Id);
            }        
        }//end of for(Order newOrder : newOrderList)
        
        if(orderIdList != null && orderIdList.size() > 0) {
            //Query for all the related approval processes.
            List<ProcessInstanceWorkItem> relevantWorkItems = [SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActorId, Id, ActorId
                                                               FROM ProcessInstanceWorkitem
                                                               WHERE ProcessInstance.TargetObjectId IN :orderIdList
                                                               AND ActorId IN :oldAssigneeIds
                                                               AND ProcessInstance.Status = 'Pending'];
            
            List<ProcessInstanceWorkItem> workItemListToUpdate = new List<ProcessInstanceWorkItem>();
            
            //Loop through the relevant approval processes and reassign them to the appropriate Region Queue
            for(ProcessInstanceWorkItem piwi : relevantWorkItems) {
                Id currentOrderId = piwi.ProcessInstance.TargetObjectId;
                
                for(Id oldAssigneeId : orderIdToOldAssigneeIds.get(currentOrderId)) {
                    if(piwi.ActorId == oldAssigneeId) {
                        piwi.ActorId = oldAssigneeIdToNewAssigneeId.get(oldAssigneeId);
                        
                        workItemListToUpdate.add(piwi);
                        break;
                    }
                }
            }
            
            if(workItemListToUpdate != null && workItemListToUpdate.size() > 0) {
                update workItemListToUpdate;
            }
        }//end of if(orderIdList != null && orderIdList.size() > 0)
    }//end of reassignApprovalOwner(List<Order> newOrderList, Map<Id, Order> oldOrderList)
    
    public static void assignBroadbandQueue(List<Order> orderList) {
        
        List<Order> ordersToUpdate = new List<Order>();
        List<Id> orderAccountIdList = new List<Id>();
        
        //loop through all the incoming orders and store the ones relevant to this method
        for(Order ord : orderList) {
            //Id newOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('New Order').getRecordTypeId();
            
            //If this is a Order has a product of 'Frontier AnyWare UCaaS + Broadband' and no Broadband Queue Assignment, then we want to flag this order as relevant.
            if((ord.Product__c == 'Frontier AnyWare UCaaS + Broadband' && ord.Broadband_Queue_Assignment__c == NULL) || Test.isRunningTest()) {
                ordersToUpdate.add(ord);
                orderAccountIdList.add(ord.accountId);
            }
        }
        
        if(orderAccountIdList != null && orderAccountIdList.size() > 0) {
            
            //Get all the territories for those accounts that haven't been flagged as deleted.
            List<ObjectTerritory2Association> accountTerritories = [SELECT id, IsDeleted, Territory2Id, objectId, territory2.POD_Assignment__c 
                                                                    FROM ObjectTerritory2Association 
                                                                    WHERE IsDeleted = false 
                                                                    AND objectid IN :orderAccountIdList];
            
            //Get the list of territory pod assignments as well as a mapping of the accountId to all the associated territories' pod assignments (to make comparisons easier later on)
            Map<Id, String> accountIdToPodAssignment = new Map<Id, String>();
            List<String> podAssignmentList = new List<String>();
            for(ObjectTerritory2Association accountTerritory : accountTerritories) {
                
                //Don't bother doing anything if the territory has no pod Assignment
                if(!String.isEmpty(accountTerritory.territory2.POD_Assignment__c)) {
                    podAssignmentList.add(accountTerritory.territory2.POD_Assignment__c);
                    accountIdToPodAssignment.put(accountTerritory.objectId, accountTerritory.territory2.POD_Assignment__c);
                }
            }//for(ObjectTerritory2Association accountTerritory : accountTerritories)
            
            //Get all the queues named after the associated pods
            List<Group> podQueues = [SELECT id, Type, Name 
                                     FROM Group 
                                     WHERE Type = 'Queue' 
                                     AND Name IN :podAssignmentList];
            
            //Loop through the relevant orders once more and assign the Queue Id to the Broadband_Queue_Assignment__c field
            for(Order ord : ordersToUpdate) {
                
                //Loop through the associated Queues
                for(Group podQueue : podQueues) {
                    if(podQueue.name == accountIdToPodAssignment.get(ord.accountId)) {
                        ord.Broadband_Queue_Assignment__c = podQueue.Id;
                    }
                }
            }
        }//end of if(orderAccountIdList != null && orderAccountIdList.size() > 0)
    }//end of assignBroadbandQueue(List<Order> orderList) 
    
    /* SDDD-4527 created this method to creating cases when Order Stage is Complete added by Mahesh G - Started */ 
    public static void CaseCreationforOrderCompleteStage(List<Order> newOrderList, Map<Id, Order> oldOrderMap){
        list<Case> CaseList = new list<Case>();
        if(isFirstTime != true){
            isFirstTime = true;
        list<GroupMember> queueList = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE Group.Name = :label.NCM_Queue];
        Set<Id> UserOrGroupId = new Set<Id>();
        Id recorTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(label.Case_RecordType).getRecordTypeId();
        for(GroupMember que : queueList){
            UserOrGroupId.add(que.UserOrGroupId);
        }
       
        List<Order> OrderList = [select id,Order_Stage__c,AccountId,OpportunityId,Service_Order__r.Billing_Number__c,EffectiveDate,NRC__c,MRC__c,OrderNumber,OwnerId,Associated_ECR__c,Type,Opportunity_Close_Date__c from Order where id IN :newOrderList];
        for(Order ordRecs : OrderList){
            system.debug('****Order_Stage__c  '+ordRecs.Order_Stage__c);
            system.debug('****oldOrderMap  '+oldOrderMap.get(ordRecs.Id).Order_Stage__c);
            system.debug('***UserOrGroupId***'+UserOrGroupId);
            system.debug('***ordRecs***'+ordRecs.OwnerId);
            if(ordRecs.Order_Stage__c == 'Complete' && ordRecs.Order_Stage__c !=oldOrderMap.get(ordRecs.Id).Order_Stage__c && UserOrGroupId.contains(ordRecs.OwnerId)){
                Case caseRecCreation = new Case();
                caseRecCreation.recordTypeId = recorTypeId;
                caseRecCreation.AccountId = ordRecs.AccountId;
                caseRecCreation.Opportunity__c = ordRecs.OpportunityId;
                caseRecCreation.BTN__c = ordRecs.Service_Order__r.Billing_Number__c;
                System.debug('@@@@@@Billing Number'+ordRecs.Service_Order__r.Billing_Number__c);
                caseRecCreation.Effective_Bill_Date__c = ordRecs.EffectiveDate;
                caseRecCreation.Orderz__c = ordRecs.Id;
                caseRecCreation.OrderManagement_NonRecurringCharges__c = ordRecs.NRC__c;
                caseRecCreation.OrderManagement_MonthlyRecurringCharges__c = ordRecs.MRC__c;
                caseRecCreation.Origin = 'Salesforce';
                caseRecCreation.Status = 'New';
                caseRecCreation.Subject = 'FBR ' + 'for ' + ordRecs.OrderNumber;
                caseRecCreation.OwnerId = ordRecs.OwnerId;
                caseRecCreation.ECR__c = ordRecs.Associated_ECR__c;
                //caseRecCreation.Order_Type__c = ordRecs.Type;
                //caseRecCreation.ClosedDate = ordRecs.Opportunity_Close_Date__c;
                CaseList.add(caseRecCreation);
                
            }
        }
            
        
        if(CaseList.size() > 0){
            insert CaseList;
            system.debug('@@@@CaseList' +CaseList);
        }
     }
    }
    /* SDDD-4527 created this method to creating cases when Order Stage is Complete added by Mahesh G - Ended */
    /* SDDD-4527 created this method to update service_order__c field in order object added by Swetha Chandu - Started */
    public static void ServiceorderupdateinOrder(List<Order> newOrderList){
        
        List<Order> ordersToUpdate = new List<Order>();
            for(Service_order__c srvorder : [Select id,Name,Billing_Number__c from Service_Order__c where Order__c = :newOrderList]){
          
            for(Order ordRecs : newOrderList){
                ordRecs.Service_Order__c = srvorder.id;
                ordersToUpdate.add(ordRecs);
            }
        }
    }
	/* SDDD-4527 created this method to update service_order__c field in order object added by Swetha Chandu - Ended */
        /*Fedral account story*/
    public static void checkBillingState(List<Order> newOrderList, Map<Id, Order> oldOrderList){
        List<Order> isBillingOrders = new List<Order>();
        String serviceAccount;
        for(Order newOrder : newOrderList) {
            Order oldOrder = (Order) oldOrderList.get(newOrder.Id);
            if(newOrder.Is_Billing__c==true && newOrder.Federal_Account__c==true &&  oldOrder != null && oldOrder.Is_Billing__c != newOrder.Is_Billing__c) {
                isBillingOrders.add(newOrder);
            }
        }
        List<vlocity_cmt__OrchestrationItem__c> items =[SELECT Id, Name, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__fulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c
                                                        FROM vlocity_cmt__OrchestrationItem__c 
                                                        where vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c IN :isBillingOrders and name='Wait to DPI Order Status Event' and vlocity_cmt__State__c='Running'];
        List<vlocity_cmt__OrchestrationItem__c> itemsToUpdate = new List<vlocity_cmt__OrchestrationItem__c>();
        for(vlocity_cmt__OrchestrationItem__c item: items){
            String jsonAttribute = item.vlocity_cmt__fulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c;
        	String IsBillingComplete = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, 'ATTR_IsBillingComplete');
            if(IsBillingComplete=='True'){
                item.vlocity_cmt__State__c ='Completed';
                itemsToUpdate.add(item);
            }
        	
        }
        if(itemsToUpdate.size()>0){
            update itemsToUpdate;
        }
        
    }
}