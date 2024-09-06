@RestResource(urlMapping='/esbeventapi/*')
global with sharing class FTRESBEventApi {

    static RestRequest req;
    static RestResponse res;

    public FTRESBEventApi() {

    }

    
    @HttpPost
    global static void newEvent() {
        
        req = RestContext.request;
        res = RestContext.response;
        String dbResponse;

        FTRESBEventRequest esbEventReq = (FTRESBEventRequest) JSON.deserialize(req.requestBody.toString(), FTRESBEventRequest.class);
        EsbEvent__e event = new EsbEvent__e();
        event.name__c = esbEventReq.header.name;
        event.priority__c = esbEventReq.header.priority;
        event.data__c = JSON.serialize(esbEventReq.identities);
        event.correlationId__c = esbEventReq.header.correlationId;
        event.domain__c = esbEventReq.header.domain;
        event.expiration__c = esbEventReq.header.expiration;
        event.id__c = esbEventReq.header.id;
        event.property__c = esbEventReq.header.property;
        event.source__c =esbEventReq.header.source;
        event.subtype__c = esbEventReq.header.subType;
        event.timestamp__c = esbEventReq.header.timestamp;
        try{
           //insert event;
           //
           Database.SaveResult result = EventBus.publish(event);
            if (result.isSuccess()) {
        		System.debug('Successfully published event.' + result);
                dbResponse = 'success';
    		} else {
      		  for(Database.Error err : result.getErrors()) {
                 dbResponse = err.getMessage();        		    
    			}
            }
            API_Log__c apiLog = new API_Log__c(
                    Request__c = req.requestBody.toString(),
                    Response__c = JSON.serialize(dbResponse),
                    Interface__c = 'ESBEvent',
                    System__c = 'ESB',
                    Status__c = 'Success',
                    RelatedTo__c = '',
                    OrderNumber__c = '');
                    insert apiLog;
        }catch(Exception e){
            API_Log__c apiLog = new API_Log__c(Request__c = req.requestBody.toString(),Response__c = JSON.serialize(e.getMessage()),Interface__c = 'ESBEvent',System__c = 'ESB',Status__c = 'Error', RelatedTo__c = '', OrderNumber__c = '');
            insert apiLog;
        }
    }

}