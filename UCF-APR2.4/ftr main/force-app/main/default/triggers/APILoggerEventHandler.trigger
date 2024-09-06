trigger APILoggerEventHandler on APILogger__e (after insert) {

    List<API_Log__c> logs = new List<API_Log__c>();

    for (APILogger__e event : Trigger.new) {
        Map<String, String> input = (Map<String, String>) JSON.deserialize(event.Payload__c, Map<String, String>.class);
        logs.add(
            new API_Log__c(
                Request__c = event.Request__c,
                Response__c = event.Response__c,
                Interface__c = input.get('interface'),
                System__c = input.get('system'),
                Status__c = input.get('status') != null && (input.get('status')).toUpperCase() == 'SUCCESS' ? 'Success' : 'Error',
                ConvertToXML__c = Boolean.valueOf(input.get('convertToXML')),
                OrchestrationItemId__c = input.get('orchestrationItemId'),
                DocumentNumber__c = input.get('documentNumber'),
                ErrorMessage__c = input.get('errorMessage'),
                ErrorCode__c = input.get('errorCode'),
                RelatedTo__c = input.get('relatedTo'),
                OrderNumber__c = input.get('orderNumber')
            )
        );
    }
    List<Database.SaveResult> srList = Database.insert(logs);
    for (Database.SaveResult sr : srList) {
        if (sr.isSuccess()) {
            System.debug('API Log created.');
        } else {
            for (Database.Error err : sr.getErrors()) {
                System.debug('Error in creating API Log: ' +
                        err.getStatusCode() +
                        ' - ' +
                        err.getMessage());
            }
        }
    }
}