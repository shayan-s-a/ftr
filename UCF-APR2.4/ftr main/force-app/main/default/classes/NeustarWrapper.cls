public class NeustarWrapper{
    
   
	//public cls_TNResponse_type_info[] TNResponse_type_info;
	public cls_TNResponse[] TNResponse;
	//public cls_field_order_type_info[] field_order_type_info;
	//public cls_apex_schema_type_info[] apex_schema_type_info;
	
	public class cls_TNResponse {
		public cls_Routing Routing;
		//public cls_PortingHistory PortingHistory;
		public cls_Ownership Ownership;
		public cls_IpFields IpFields;
		public cls_Geography Geography;
		public cls_CodeBlockInfo CodeBlockInfo;
		public cls_AdditionalFields AdditionalFields;
	}
	
	public class cls_Routing {
		public String WsmscDpcSsn;	//
		public String Lrn;	//5702650088
		public String LidbDpcSsn;	//238013000-000
		public String IsvmDpcSsn;	//235235001-000
		public String CnamDpcSsn;	//238013000-000
		public String ClassDpcSsn;	//235235001-000
	}
	
	public class cls_Ownership {
		public String SvType;	//Wireline
		public String Status;	//Ported - Intra
		public String PhoneNumber;	//5702474247
		public String NpacSpid;	//0161
		public String NanpaOcn;	//0161
		public String LastAltSpid;	//
		public String Company;	//FrontierPA_CTCO:0161 - NSR/1
		public String AltSpid;	//
	}
	
	class cls_IpFields {
		public String VoiceUri;	//
		public String SmsUri;	//
		public String MmsUri;	//
	}
	
	public class cls_Geography {
		public String State;	//Pennsylvania
		public String Region;	//Mid-Atlantic
		public String RateCenter;	//ROME
		public String Longitude;	//-76.44
		public String Latitude;	//41.78
		public String Lata;	//232 - NORTHEAST - PA
	}
	
	public class cls_CodeBlockInfo {
		public String PasBlockOwnerStatus;	//Assigned
		public String PasBlockOwnerOcnName;	//CORE COMMUNICATIONS, INC. - PA
		public String PasBlockOwnerOcn;	//3806
		public String PasBlockOwnerEffectiveDate;	//03/27/2019 12:00 AM, EDT
		public String NpacCodeOwnerSpidName;	//FrontierPA_CTCO:0161 - NSR/1
		public String NpacCodeOwnerSpid;	//0161
		public String NanpaCodeOwnerOcnName;	//COMMONWEALTH TELEPHONE COMPANY LLC
		public String NanpaCodeOwnerOcn;	//0161
		public String IlecRbocOcnName;	//LERG/DIR Listing Required
		public String IlecRbocOcn;	//LERG/DIR Listing Required
	}
	
	class cls_AdditionalFields {
		public String EndUserLocationType;	//
		public String EndUserLocation;	//
		public String BillingId;	//
	}
	
	public static NeustarWrapper parse(String json){
		return (NeustarWrapper) System.JSON.deserialize(json, NeustarWrapper.class);
	}	
}