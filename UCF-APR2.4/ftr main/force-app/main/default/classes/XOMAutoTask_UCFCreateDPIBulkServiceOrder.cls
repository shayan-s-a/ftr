global class XOMAutoTask_UCFCreateDPIBulkServiceOrder implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {

     global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {
       
        try {
            Set<Id> frlIds = new Set<Id>();
            
            for (vlocity_cmt__OrchestrationItem__c item : items) {
                System.debug('::::::::: UteSADf'+item.vlocity_cmt__fulfilmentRequestLineId__c);
                frlIds.add(item.vlocity_cmt__fulfilmentRequestLineId__c);
            }
            List<vlocity_cmt__FulfilmentRequestLine__c> frls = [SELECT Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber, vlocity_cmt__Product2Id__r.Name
                                                                FROM vlocity_cmt__FulfilmentRequestLine__c
                                                                WHERE Id=:frlIds WITH SECURITY_ENFORCED];
            
            RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName ='DPI_Service_Order' WITH SECURITY_ENFORCED];
            
            List<Service_Order__c> soList = new List<Service_Order__c>();
            for (vlocity_cmt__FulfilmentRequestLine__c frl : frls) {
               
                String ItemId = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c,'ItemId');
                String correlationId = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c,'CorrelationId');
                String didNumbers = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c,'ATTR_DIDNumber');
                String name = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'LeadOrderId');
                String leadDIDNumber = correlationId.substringAfterLast('.');
                
                String[] values = didNumbers.split(',');
                List<String> filteredNumbers = new List<String>();
                for (String value : values) {
                    if (value != leadDIDNumber) {
                        filteredNumbers.add(value);
                    }
               }
               String filteredDidNumbers = String.join(filteredNumbers, ',');
                
                Service_Order__c so = new Service_Order__c(
                    Name = 'Bulk Order For: '+name,
                    Order__c = frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.Id,
                    Order_Number__c = frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber,
                    Description__c = 'Auto generated "' + frl.vlocity_cmt__Product2Id__r.Name + '" by Vlocity OM For '+filteredDidNumbers,
                    RecordTypeId = rt.Id,
                    DPI_Env__c = (String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'Environment'),
                    Schedule_Due_Date__c = Date.valueOf((String)ftr_CpqHelper.getJSONAttributeValue(frl.vlocity_cmt__JSONAttribute__c, 'ATTR_DueDate'))
                );
                soList.add(so);
            }
            if(!soList.isEmpty()){
            
               insert soList;
            }
            
        } catch (Exception ex) { 
            ftr_Logger.write(ex);
            throw ex;
        } finally {
            ftr_Logger.writeInfo('Exit XOMAutoTask_SIPCreateDPILeadServiceOrder.executeBatch');
        }
    }
}