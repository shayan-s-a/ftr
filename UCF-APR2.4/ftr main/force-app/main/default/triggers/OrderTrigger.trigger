trigger OrderTrigger on Order(before insert,before update,before delete,after insert,after update,after delete,after undelete) {
        
    
    
    if(trigger.isBefore){
        
        if(trigger.isInsert){
            OrderUtility.assignBroadbandQueue(trigger.new);
            
        }else if(trigger.isUpdate){
            OrderUtility.assignBroadbandQueue(trigger.new);
            /* SDDD-4527 This method is used for update service_order__c field in order object added by Swetha Chandu */
            OrderUtility.ServiceorderupdateinOrder(Trigger.New);
            
            /* SDDD-4526 This method is used for calling NCM Order Assignment Automation process added by Anil A - Started */
            Order newOrder = (Order) Trigger.new[0];
            Order oldOrder = (Order) Trigger.old[0];
                        
            if( newOrder.Order_Stage__c != oldOrder.Order_Stage__c && newOrder.Order_Stage__c ==System.Label.Network_Cost_Management ){                    
                NCMAutomationOrderHandler.ownerAssignmentForNCM(newOrder,oldOrder);
            } 
            /* SDDD-4526 This method is used for calling NCM Order Assignment Automation process added by Anil A - Ended */
                       
            
        }else if(trigger.isDelete){
            
        }
        
    }else if(trigger.isAfter){
        
        if(trigger.isInsert){
            
        }else if(trigger.isUpdate){
            RetreievSupportTeamDetails.getEmails(trigger.new,trigger.oldMap);
            OrderUtility.reassignNetworkCOE(trigger.new, trigger.oldMap);
            OrderUtility.reassignCPECOE(trigger.new, trigger.oldMap);
            OrderUtility.reassignApprovalOwner(trigger.new, trigger.oldMap);
            /* SDDD-4527 This method is used for Creating cases when Order Stage is Complete added by Mahesh G */
            OrderUtility.CaseCreationforOrderCompleteStage(Trigger.New, Trigger.oldMap);
            PicklistPopulation.resetPlanOfLeadAfterMDN(Trigger.New, Trigger.oldMap);
            
        }else if(trigger.isDelete){
            
        }else if(trigger.isUndelete){
            
        }
        
    }
    if (Trigger.isAfter && (Trigger.isInsert) || (Trigger.isUpdate)) {
        Id newOrderRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('New_Order').getRecordTypeId();        
        Id upgOrderRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Upgrade_Order').getRecordTypeId();   
        for (Order objOrder : Trigger.New) {
			Order oldOrder = new Order(); 
            if (Trigger.isUpdate) {
                oldOrder = Trigger.oldMap.get(objOrder.Id);
            }
            if ((((objOrder.Order_Stage__c == 'CNP Quality Assurance' || objOrder.Order_Stage__c == 'Customer Network Provisioning' 
                 || objOrder.Order_Stage__c == 'Network Cost Management') && objOrder.RecordTypeId == newOrderRecTypeId) || 
                (objOrder.RecordTypeId == upgOrderRecTypeId))
                && oldOrder.Order_Stage__c != objOrder.Order_Stage__c && (objOrder.Implementor_PM__c != null || objOrder.Network_Project_Specialist__c != null)) {
                if (!SendOrderDetailsToCbtsUtility.CBTS_EXECUTED) {
                    SendOrderDetailsToCbtsUtility.postToCBTS(objOrder.Id);
                    SendOrderDetailsToCbtsUtility.CBTS_EXECUTED = true;
                }
            }
        }
    } 
}