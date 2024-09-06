@RestResource(urlMapping='/M6OrderStatusUpdateService/*')

global with sharing class ftr_PSROrderStatusProcessor {
    @HttpPost
    global static void UpdateOrder() {

        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        System.debug('M6OrderStatusEvent:body ---->'+body);
        String requestString = body.toString();
        System.debug('M6OrderStatusEvent:requestString -->'+requestString);
        //List<PSROrderUpdate__e> statusUpdateEventList = new List<PSROrderUpdate__e>();
        Map<String, String> values = (Map<String, String>)
        JSON.deserialize(requestString, Map<String, String>.class);
       
        System.debug('mapvalues--'+values);

        Map<String, Object> psrOrderEventMap = new Map<String, Object>{
            'PSROrderId__c' => Integer.ValueOf(values.get('PSROrderId__c')),
            'CircuitId__c'=> values.get('CircuitId__c'),
            'PSROrderStatus__c'=> values.get('PSROrderStatus__c'),
            'DueDate__c'=>values.get('DueDate__c'),
            'PurchaseOrderNumber__c'=>values.get('PurchaseOrderNumber__c'),
            'Stub_Response__c'=>values.get('Stub_Response__c')
        };
        String psrOrderEventMapStr = JSON.serialize(psrOrderEventMap);
        System.debug('M6OrderStatusEvent:PSROrderEventMapStr-->'+psrOrderEventMapStr);
        ftr_M6OrderStatusUpdateSubscriber.processBCNComplete(psrOrderEventMapStr);



               /* PSROrderUpdate__e event = new PSROrderUpdate__e();
                event.ApplicationId__c = values.get('ApplicationId__c');
                event.EmployeeId__c = values.get('EmployeeId__c'); 
                event.UserId__c = values.get('UserId__c');
                event.OrderType__c = values.get('OrderType__c');
                event.OrderDescription__c = values.get('OrderDescription__c');
                event.PSROrderId__c = Integer.ValueOf(values.get('PSROrderId__c'));
                event.PSROrderStatus__c = values.get('PSROrderStatus__c');
                event.CircuitId__c = values.get('CircuitId__c');
                event.DueDate__c =  date.ValueOf(values.get('DueDate__c'));
                event.PurchaseOrderNumber__c = values.get('PurchaseOrderNumber__c');
                statusUpdateEventList.add(event);

                System.debug('eventlist--'+statusUpdateEventList);
   List<Database.SaveResult> results = EventBus.publish(statusUpdateEventList);

        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event..'+ sr.getId());
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }*/
errors err = new errors();
err.statusCode ='VOM-200';
err.Message = 'M6 Order Events Processed Successfully';

response res = new response();
res.id = values.get('PSROrderId__c');
res.success = true;
res.errors = new List<errors>{err};


String serializedjson = JSON.serialize(res);
RestContext.response.addHeader('Content-Type', 'application/json');
RestContext.response.responseBody = Blob.valueOf(serializedjson);
System.debug('responsejson-'+serializedjson);

    try {
        Service_Order__c servOrder = [SELECT Order__r.OrderNumber, Order__c FROM Service_Order__c WHERE Name = :res.id LIMIT 1];
        Map<String, Object> logOutput = new Map<String, Object>();
        Map<String, Object> logInput = new Map<String, Object> {
            'request' => values,
            'response' => res,
            'interface' => 'M6OrderStatusUpdateService',
            'system' => 'M6',
            'status' => 'Success',
            'convertToXML' => false,
            'documentNumber' => res.id,
            'orderNumber' => servOrder.Order__r.OrderNumber,
            'relatedTo' => servOrder.Order__c
        };  
        APILogger log = new APILogger();
        log.createEntry(logInput, logOutput);
    } catch (Exception e) {
        System.debug('Unable to create log');
    }

    }
public class response {
    public String id;
    public Boolean success;
    public List<errors> errors;

}
public class errors{
    public String statusCode;
    public String  Message;
}
}