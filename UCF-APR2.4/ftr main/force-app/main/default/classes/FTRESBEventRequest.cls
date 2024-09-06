global with sharing class FTRESBEventRequest {

    public FTRESBEventRequest() {

    }

    public Header header;
    public Identities[] identities;
	public Messages[] messages;
	public ContextData[] contextData;
    
	public class Header {
		public String name;	//OrderComplete
		public String domain;	//Quote
		public String subType;	//Order
		public String source;	//DPI
		public String priority;	//1
		public String expiration;	//24
		public String id;	//4184060273
		public String correlationId;	//F9C82001-966D-1A81-909D-0004AC1EA1AD
		public String timestamp;	//2022-05-09T12:37:23-05:00
		public String property;	//
        
        public String getName(){
            return name;
        }
        
        public String getDomain(){
            return domain;
        }
        
        public String getSubType(){
            return subType;
        }
        
        public String getSource(){
            return source;
        }
        
        public String getPriority(){
            return priority;
        }
        
        public String getExpiration(){
            return expiration;
        }
        
        public String getId(){
            return id;
        }
        
        public String getCorrelationId(){
            return correlationId;
        }
        
        public String getTimestamp(){
            return timestamp;
        }
        
        public String getProperty(){
            return property;
        }
        
	}
	public class Identities {
		public String applicationName;	//EOC
		public Identification[] identification;
	}
	public class Identification {
		public String key;	//omOrderId
		public String value;	//1000306600
	}
	public class Messages {
		public String messageId;	//ES70001
		public String severity;	//INFO
		public String messageText;	//Order posted successfully
		public String recoveryText;	//
	}

    public class ContextData {
		public String datePosted;	//2022-04-14
		public String orderType;	//SS
		public String doubleSidedOrderAction;	//IN
	}

}