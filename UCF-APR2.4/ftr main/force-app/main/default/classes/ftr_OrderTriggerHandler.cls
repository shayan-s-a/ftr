public class ftr_OrderTriggerHandler extends ftr_TriggerHandler {

    public override void beforeInsert() {
        ftr_Logger.writeInfo('ftr_OrderTriggerHandler.beforeInsert');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        
    }
    public override void afterInsert() {
        ftr_Logger.writeInfo('ftr_OrderTriggerHandler.afterInsert');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
    }
    
    public override void beforeUpdate() {
        ftr_Logger.writeInfo('ftr_OrderTriggerHandler.beforeUpdate');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        
        Order newOrder = (Order) Trigger.new[0];
        Order oldOrder = (Order) Trigger.old[0];
        
        // only enter on stage change
        if (newOrder.Order_Stage__c != oldOrder.Order_Stage__c) {
            
            if (!FieldAssignmentService.hasProcessed) {
                FieldAssignmentService.hasProcessed = true;

                FieldAssignmentService service = new FieldAssignmentService(oldOrder, newOrder);

                if (oldOrder.Order_Stage__c != 'New') {

                    if(newOrder.Network_Project_Specialist__c != null){
                        FieldAssignmentService.sendOrderDetails(newOrder, oldOrder, newOrder.Network_Project_Specialist__c);
                    }
                    
                    if(newOrder.Implementor_PM__c != null){
                        FieldAssignmentService.sendOrderDetails(newOrder, oldOrder, newOrder.Implementor_PM__c);
                    }
                    
                }
            }
        }
    }
    public override void afterUpdate() {
        ftr_Logger.writeInfo('ftr_OrderTriggerHandler.afterUpdate');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        
    }
    
    public override void beforeDelete() {
        ftr_Logger.writeInfo('ftr_OrderTriggerHandler.beforeDelete');
        ftr_Logger.writeVar('Trigger.old', Trigger.old);
        
    }
    
}