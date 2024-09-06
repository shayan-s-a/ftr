@RestResource(urlMapping='/DPIOrderStatusUpdateService/*')
global with sharing class ftr_BillingOrderStatusProcessor {
    @HttpPost
    global static void doPost() {
        
        RestRequest req = RestContext.request;
        String requestString = req.requestBody.toString();    
		System.debug('DPIOrderStatusUpdateService:requestBody from ESB-->'+requestString);
        ftr_DPIOrderStatusEvent obj;
        if(requestString != ''){
            obj = ftr_DPIOrderStatusEvent.parse(requestString);
        } 
        String correlationid = obj.clientTransactionId;
        String sfOrderNumber = correlationid.substringBefore('.');
        System.debug('DPIOrderStatusUpdateService:correlationid--->'+correlationid);
        ftr_BillingOrderStatusProcessor.processDPIOrderStatusEvent(requestString);
        errors err = new errors();
        err.statusCode ='VOM-200';
        err.Message = 'DPI Order Events Processed Successfully';
        
        response res = new response();
        res.id = correlationid;
        res.success = true;
        res.errors = new List<errors>{err};
            
        String serializedjson = JSON.serialize(res);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(serializedjson);
        System.debug('DPIOrderStatusUpdateService:responseJSON--->'+serializedjson);
        try {
            Map<String, Object> logOutput = new Map<String, Object>();
            Map<String, Object> logInput = new Map<String, Object> {
                'request' => JSON.deserializeUntyped(requestString),
                'response' => JSON.deserializeUntyped(serializedjson),
                'interface' => 'DPIOrderStatusUpdateService',
                'system' => 'DPI',
                'status' => 'Success',
                'convertToXML' => false,
                'orderNumber' => sfOrderNumber,
                'relatedTo' => [SELECT Id FROM Order WHERE OrderNumber = :sfOrderNumber LIMIT 1].Id
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
    @future
    public static void processDPIOrderStatusEvent(String requestString){
        
        ftr_DPIOrderStatusEvent obj;
        if(requestString != ''){
            obj = ftr_DPIOrderStatusEvent.parse(requestString);
        } 
        Map<String,Object> objectmap = new Map<String,Object>();
        objectmap.put('OrderNumber', obj.clientTransactionId.substringBefore('.'));
        
        for(ftr_DPIOrderStatusEvent.orders childorder : obj.orders){
            if(childorder.orderNumber != ''){
                objectmap.put(childorder.orderNumber,childorder);
            }
        }  
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_DPIStatusUpdateSubscriber stat = new ftr_DPIStatusUpdateSubscriber();
        Boolean result = stat.invokeMethod('execute', objectmap, outputMap, options);        
    }
    
}