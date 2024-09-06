/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
**/
global class XOMAutoTask_SIPCreateDPIServiceOrder implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
  

    global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {
        ftr_Logger.writeInfo('Enter XOMAutoTask_SIPCreateDPIServiceOrder.executeBatch');
        try {
            Set<Id> frlIds = new Set<Id>();
            Set<Id> planIds = new Set<Id>();
            for (vlocity_cmt__OrchestrationItem__c item : items) {
                frlIds.add(item.vlocity_cmt__fulfilmentRequestLineId__c);
                planIds.add(item.vlocity_cmt__OrchestrationPlanId__c);
            }
            vlocity_cmt__FulfilmentRequestLine__c[] frls = [SELECT Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber, vlocity_cmt__Product2Id__r.Name 
                                                            FROM vlocity_cmt__FulfilmentRequestLine__c
                                                            WHERE Id=:frlIds];
            List<vlocity_cmt__OrchestrationItem__c> sipDpiCircuit = [Select Id,vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c  from vlocity_cmt__orchestrationItem__c where Name ='SIP Wait for M6Orders Completion' and vlocity_cmt__OrchestrationPlanId__c=:planIds and vlocity_cmt__State__c ='Running'];
            RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName ='DPI_Service_Order'];

             if(!sipDpiCircuit.isEmpty()){
                updateDPISIP(sipDpiCircuit);
             }
            if(Test.isRunningTest()){
                updateDPISIP(sipDpiCircuit);
            }
            List<Service_Order__c> soList = new List<Service_Order__c>();
            for (vlocity_cmt__FulfilmentRequestLine__c frl : frls) {
                String wtn = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'WorkingTelephoneNumber');
                String btn = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'BillingTelephoneNumber');
                String leadOId = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'LeadOrderId');
                String groupOId = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'GroupMemberOrderId');
                //String name = wtn == btn ? (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'LeadOrderId') : (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'GroupMemberOrderId');
                String name = leadOId == groupOId ? (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'LeadOrderId') : (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'GroupMemberOrderId');
                Service_Order__c so = new Service_Order__c(
                    Name = name,
                    Working_Number__c = wtn,
                    Order__c = frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.Id,
                    Order_Number__c = frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber,
                    Description__c = 'Auto generated "' + frl.vlocity_cmt__Product2Id__r.Name + '" by Vlocity OM',
                    RecordTypeId = rt.Id,
                    Billing_Number__c = btn,
                    DPI_Env__c = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'Environment'),
                    Schedule_Due_Date__c = Date.valueOf((String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'ATTR_DueDate'))
                );
                soList.add(so);
            }
            System.debug(JSON.serialize(soList));
            insert soList;
        } catch (Exception ex) { 
            ftr_Logger.write(ex);
            throw ex;
        } finally {
            ftr_Logger.writeInfo('Exit XOMAutoTask_SIPCreateDPIServiceOrder.executeBatch');
        }
    }
        
     private void updateDPISIP(List<vlocity_cmt__OrchestrationItem__c> sipDpiCircuit){

           Set<Id> frlIds = new Set<Id>();
           Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
           Map<String, Object> attrValsDPI = new Map<String, Object>{
            'Attr_WaitToStart' => 'True'
             
        };

            for(vlocity_cmt__OrchestrationItem__c dpiItem: sipDpiCircuit){
                frlIds.add(dpiItem.vlocity_cmt__fulfilmentRequestLineId__c);
            }

            vlocity_cmt__FulfilmentRequestLine__c[] frls = [SELECT Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber, vlocity_cmt__Product2Id__r.Name 
            FROM vlocity_cmt__FulfilmentRequestLine__c
            WHERE Id=:frlIds];

            for (vlocity_cmt__FulfilmentRequestLine__c frl : frls) {

                frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrValsDPI);
                frlsToUpdateMap.put(frl.Id,frl);
            }

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
}