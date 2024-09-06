public class ServiceOrder_Queueable implements Queueable,Database.AllowsCallouts {

    List<Service_Order__c> serviceOrders;
    public ServiceOrder_Queueable(List<Service_Order__c> serviceOrders){
        this.serviceOrders = serviceOrders;
    }
    public void execute(QueueableContext context) {
        ServiceOrderCtrl.syncServiceOrders(serviceOrders);      
    }
   
}