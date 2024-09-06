public class FTRWSDSATAddressResponseJson {
    public Integer AQRecordId;
	public Integer CPQId;
	public String OpportunityId;
	public String BusinessName;
	public Integer Id;
	public Integer VFORecordId;
	public Integer M6OrderNumber;
	public String CreatedBy;
	public String CreatorEmail;
	public Integer CreatedById;
	public String Opened;
	public Boolean InFootprint;
	public String Market;
	public String Level;
	public List<String> Products;
	public String WireCenterCLLI;
	public String SiteName;
	public String WireCenterQoS;
	public String WireCenterSpeed;
	public Boolean LitBuilding;
	public String FiberDistance;
	public String CopperDistance;
	public String FiberTier;
	public String CopperTier;
	public QualifiedAddress QualifiedAddress;
	public List<String> EReachProviders;
	public String FiberQualification;
	public String CopperQualification;

	public class QualifiedAddress {
		public String Address;
		public String City;
		public String State;
		public String ZipCode;
		public Double Latitude;
		public Double Longitude;
	}
    
      // Changes for BSA - Start
    public String LinkStatus;
    public String LengthFeet;
    public Double FiberCost; 
    public Double EquipmentCost;
    public Double TotalCost;
    // Changes for BSA - End GIT Test
    
	/*public static fromJSON parse(String json){
		return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
	}*/

}