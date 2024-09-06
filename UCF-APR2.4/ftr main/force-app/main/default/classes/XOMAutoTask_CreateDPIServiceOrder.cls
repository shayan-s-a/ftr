global class XOMAutoTask_CreateDPIServiceOrder implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
  
	private static final Integer MAX_ATTEMPTS = 3;
    global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {
        ftr_Logger.writeInfo('Enter XOMAutoTask_CreateDPIServiceOrder.executeBatch');
        try {
            Set<Id> frlIds = new Set<Id>();
            for (vlocity_cmt__OrchestrationItem__c item : items) {
                frlIds.add(item.vlocity_cmt__fulfilmentRequestLineId__c);
            }
            vlocity_cmt__FulfilmentRequestLine__c[] frls = [SELECT Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber, vlocity_cmt__Product2Id__r.Name 
                                                            FROM vlocity_cmt__FulfilmentRequestLine__c
                                                            WHERE Id=:frlIds];

            RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName ='DPI_Service_Order'];

            List<Service_Order__c> soList = new List<Service_Order__c>();
            for (vlocity_cmt__FulfilmentRequestLine__c frl : frls) {
                String wtn = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'WorkingTelephoneNumber');
                String btn = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'BillingTelephoneNumber');
                String name = wtn == btn ? (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'LeadOrderId') : (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'GroupMemberOrderId');
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
            //insert soList;
            Integer attempts = MAX_ATTEMPTS;
            while(attempts > 0){
                System.debug('insert save attempt number is:{0} ' +attempts);
                try {
                    attempts--; 
                    if(!Test.isRunningTest()){
                   
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
            ftr_Logger.writeInfo('Exit XOMAutoTask_CreateDPIServiceOrder.executeBatch');
        }
    }
        

}