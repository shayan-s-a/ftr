public class ServiceOrderResponse{
    public cls_next next;
    public cls_items[] items;
    public class cls_next {
        //public String $ref;	//http://mssftr06.corp.pvt:8080/ords/ossdev/get_m6_order_info/get_salesforce_details/document_number/2689724?page=1
    }
    public class cls_items {
        public Integer document_number;	//3369095
		public String pon_or_order_number;	//NCM10017553P2N
		public String order_status;	//Tasks Generated
		public String order_leg;	//2
		public Integer item_spec_id;	//1101
		public String priloc_address;	//2301 REGIONAL WATER LN  Bldg HSPS TAMPA FL 33618
		public String secloc_address;	//7909 WOODLAND CENTER BLVD   TAMPA FL 33062
		public String order_stage;	//Stage 5 - Physical / Virtual Turn up
		public String dd_task_date;	//2020-03-14T04:45:00Z
		public String last_cust_note;	//CUST Spoke to Keith Rollins who has said that he is in contact with the customer and trying to get more information as Harris might be working on another design to help the customer and the hot cut may not be needed but he should let me know soon
		public String provisioning_plan_name;	//PSR RETAIL EVC ADD/CHG
    }
    public ServiceOrderResponse parse(String json){
        return (ServiceOrderResponse) System.JSON.deserialize(json, ServiceOrderResponse.class);
    }
}