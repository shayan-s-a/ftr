@isTest
public class FTRESBEventRequestTest {

    @isTest
    static void myUnitTest() {
        
        String str = '{"Header": {"name": "OrderComplete","domain": "Quote","subType": "Order","source": "DPI","priority": "1","expiration": "24","id": "4184060273","correlationId": "F9C82001-966D-1A81-909D-0004AC1EA1AD","timestamp": "2022-05-09T12:37:23-05:00","property": ""},"Data": [{"applicationName": "EOC","identification": [{"key": "omOrderId","value": "1000306600"}]}]}';
   		FTRESBEventRequest esbEventReq = (FTRESBEventRequest) JSON.deserialize(str, FTRESBEventRequest.class);
        system.debug(esbEventReq.header);
        system.debug(esbEventReq);
        
    	esbEventReq.header.getName();
        esbEventReq.header.getDomain();
        esbEventReq.header.getSubType();
        esbEventReq.header.getSource();
        esbEventReq.header.getPriority();
        esbEventReq.header.getExpiration();
        esbEventReq.header.getId();
        
        
        esbEventReq.header.getCorrelationId();
        esbEventReq.header.getTimestamp();
        esbEventReq.header.getProperty();
     }
}