global class ServiceOrder_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.stateful{
    
    DateTime dtm;
    List<RecordType> lstRt;
    Id rtId ;
    String ronFor;
    
  global ServiceOrder_Batch(String ronFor){
        this.ronFor = ronFor;
          dtm = System.now().addDays(1);
          lstRt = [select id from RecordType where DeveloperName = 'M6_Service_Order'];
          rtId = lstRt[0].Id;
    }

   global Database.QueryLocator start(Database.BatchableContext BC){
       system.debug('isScheduled :: '+System.isScheduled());
       if(ronFor == 'All'){
           if(lstRt!=null && lstRt.size() > 0){
                return Database.getQueryLocator('select id,name from Service_Order__c where recordtypeid=:rtId');
           }else
               return Database.getQueryLocator('select id,name from Service_Order__c where createdDate=:dtm');
       }
       //String recId = 'a196w00000000tWAAQ';
       //Is_Created_By_Velocity__c = true
       //return Database.getQueryLocator('select id,name from Service_Order__c where Id IN:lstServiceOrderIds');
       return Database.getQueryLocator('select id,name from Service_Order__c where Is_Created_By_Velocity__c = true');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Service_Order__c> lstSO = (List<Service_Order__c>) scope;
        ServiceOrderCtrl.syncServiceOrders(lstSO);
   }

   global void finish(Database.BatchableContext BC){
       
   }
}