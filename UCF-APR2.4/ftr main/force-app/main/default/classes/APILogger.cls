global without sharing class APILogger implements vlocity_cmt.VlocityOpenInterface {

    global APILogger() {

    }

    global Boolean invokeMethod (String methodName,
                                 Map<String, Object> input,
                                 Map<String, Object> output,
                                 Map<String, Object> options) {
        try {
            System.debug('Enter APILogger.' + methodName + ' Limits: ' + ftr_CpqAppHandlerHookImpl.debugLimits());
            if (methodName == 'createEntry') {
                createEntry(input, output); 
            } 
            return true;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            output.put('Error', ex.getMessage());
            output.put('error', ex.getMessage());
            return false;
        } finally {
            System.debug('Exit APILogger.' + methodName + ' Limits: ' + ftr_CpqAppHandlerHookImpl.debugLimits());
        }
    }

    public void createEntry(Map<String, Object> input, Map<String, Object> output) {
        try {
            Object req = input.get('request');
            Object resp = input.get('response');
            input.remove('request');
            input.remove('response');
            APILogger__e log = new APILogger__e(
                Request__c = JSON.serialize(req),
                Response__c = JSON.serialize(resp),
                Payload__c = JSON.serialize(input)
            );
            Database.SaveResult sr = EventBus.publish(log);
            if (sr.isSuccess()) {
                System.debug('APILogger event published.');
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error publishing APILogger event: ' +
                            err.getStatusCode() +
                            ' - ' +
                            err.getMessage());
                }
            }
        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            output.put('Error', ex.getMessage());
            output.put('error', ex.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    global static Map<String, Object> getLogs(String systemName, String interfaceName, String startDate, String endDate, String filterNumber, String status){
        API_Log__c[] logs;
        Map<String, object> output = new Map<String, Object>();
        Date start = Date.valueOf(startDate);
        Date endD = Date.valueOf(endDate);
        String query = 'SELECT Name, Request__c, Response__c, RelatedTo__c, OrchestrationItemId__c, OrderNumber__c, ConvertToXML__c, Interface__c, CreatedDate, Status__c, DocumentNumber__c, System__c, ErrorMessage__c, ErrorCode__c FROM API_Log__c WHERE System__c <> NULL ';
        try {
            if (systemName != 'All') {
                query += ' AND  System__c =: systemName ';
            }
            if (interfaceName != 'All') {
                query += ' AND  Interface__c =: interfaceName ';
            }
            if (filterNumber != 'All') {
                query += ' AND (DocumentNumber__c = :filterNumber OR OrderNumber__c =: filterNumber) ';
            }
            if (status != 'All') {
                query += ' AND Status__c = :status ';
            }
            query += ' AND CreatedDate > :start AND CreatedDate < :endD ORDER BY CreatedDate DESC LIMIT 10000';
            logs = (API_Log__c[]) Database.query(query);
        } catch (Exception e) {
            output.put('error', e.getMessage());
        }
        output.put('logs', logs);
        output.put('startDate', start);
        output.put('endDate', endD);
        output.put('systemName', systemName);
        output.put('interfaceName', interfaceName);
        return output;
    }

    @AuraEnabled
    public static Map<String, Object> getPicklistValues(){
        Map<String, Object> output = new Map<String, Object>();
        try {
            Schema.DescribeFieldResult status = API_Log__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> statusValues = status.getPicklistValues();
            
            output.put('Status__c', JSON.serialize(statusValues));

            Schema.DescribeFieldResult systemDesc = API_Log__c.System__c.getDescribe();
            List<Schema.PicklistEntry> systemValues = systemDesc.getPicklistValues();
            
            output.put('System__c', JSON.serialize(systemValues));

            Schema.DescribeFieldResult interfaceDesc = API_Log__c.Interface__c.getDescribe();
            List<Schema.PicklistEntry> interfaceValues = interfaceDesc.getPicklistValues();

            output.put('Interface__c', JSON.serialize(interfaceValues));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return output;
    }
}