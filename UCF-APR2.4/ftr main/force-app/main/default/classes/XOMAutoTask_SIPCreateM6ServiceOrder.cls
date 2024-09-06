global class XOMAutoTask_SIPCreateM6ServiceOrder implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask  {
    
     private static final Integer MAX_ATTEMPTS = 3;
    global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {
         
        try {
            Set<Id> frlIds = new Set<Id>();
            for (vlocity_cmt__OrchestrationItem__c item : items) {
                frlIds.add(item.vlocity_cmt__fulfilmentRequestLineId__c);
            }
            List<vlocity_cmt__FulfilmentRequestLine__c> frls = [SELECT Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber, vlocity_cmt__Product2Id__r.Name 
                                                            FROM vlocity_cmt__FulfilmentRequestLine__c
                                                            WHERE Id=:frlIds WITH SECURITY_ENFORCED];

            RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName ='M6_Service_Order' WITH SECURITY_ENFORCED];

            // *Create Service Order
            List<Service_Order__c> soList = new List<Service_Order__c>();
            for (vlocity_cmt__FulfilmentRequestLine__c frl : frls) {
                Service_Order__c so = new Service_Order__c(
                    Name = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'documentNumber'),
                    Circuit_ID__c = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'documentNumber'),
                    Working_Number__c = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'WTN'),
                    Type__c = 'PSR',
                    Order__c = frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.Id,
                    Order_Number__c = frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber,
                    Description__c = 'Auto generated for "' + frl.vlocity_cmt__Product2Id__r.Name + '" by Vlocity OM',
                    RecordTypeId = rt.Id,
                    Schedule_Due_Date__c = Date.today()
                );
                
                soList.add(so);
            }
           // insert soList;
            Integer attempts = MAX_ATTEMPTS;
            while(attempts > 0){
                 
                try {
                    attempts--; 
                    if(!Test.isRunningTest() && Schema.sObjectType.Service_Order__c.isCreateable()){
                   
                         insert soList;
                    }
                     attempts = 0;
                } catch (System.DmlException dmlEx) {
                            if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) { 
                                attempts = 0;  // exit on any other exception
                        throw dmlEx;  // throw exception after MAX_ATTEMPTS
                    }
                       }
                      
            } 
            
        } catch (Exception ex) { 
            ftr_Logger.write(ex);

            throw ex;
        } finally {
            ftr_Logger.writeInfo('Exit XOMAutoTask_CreateM6ServiceOrder.executeBatch');
        }
    }


   

}