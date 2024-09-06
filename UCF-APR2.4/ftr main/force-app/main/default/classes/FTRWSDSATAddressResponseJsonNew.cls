/**
* @description Json for Wholesale related functionalities
* @version           : 2.0
*/  

public class FTRWSDSATAddressResponseJsonNew {
    
    public class QualifiedAddress { 
		public String Address;
		public String City;
		public String State;
		public String ZipCode;
		public Double Latitude;
		public Double Longitude;
	}

	public Integer AQRecordId;
	public String CPQId;
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
	public String PERRouter;
	public String FutureHBEWcSpeed;
	public String PlannedHBETimeframe;
	public String PricingTier;
	public String FiberCiacEstimate;
	public String FiberCiacTier;
	public String CopperCiacEstimate;
	public String CopperCiacTier;
	public String LinkStatus;
	public Integer LengthFeet;
	public Integer FiberCost;
	public Integer EquipmentCost;
	public Integer TotalCost;
	public String FiberTier;
	public String CopperTier;
	public QualifiedAddress QualifiedAddress;
	public List<String> EReachProviders;
	public HBEDetails HBEDetails;
    public BSADetails BSADetails;
	public String FiberQualification;
	public String CopperQualification;
    public class HBEDetails {
        public String HBEMaxSpeed;
        public String HBEMaxQoS;
        public List<String> Products;
    } 
	public class BSADetails {
        public Integer BSAHttpStatusCode;
		public Integer Id;
		public Integer PlanId;
		public String Address;
		public String SiteName;
		public String SiteType;
		public String SiteId;
		public String WirecenterClliCode;
		public Double SiteLatitude;
		public Double SiteLongitude;
		public String ProductType;
		public String AbuYear;
		public String AbuApprovedWirecenter;
		public String ProductWirecenterServable;
		public String InputFileMtso;
		public Integer NewFiberBuriedFt;
		public Integer NewFiberExistingConduitFt;
		public Integer NewFiberAerialFt;
		public Integer NewFiberOverlashAerialFt;
		public Integer NewFiberNewConduitFt;
		public Integer NewFiberRowToBuildingFt;
		public Integer NewFiberObstacleFt;
		public Integer NewFiberPlowingFt;
		public Integer NewFiberEstimatedFt;
		public Integer FiberCostNewFiberOverlashAerial;
		public Integer FiberCostNewFiberRowToBuilding;
		public Decimal PctExistingFiberOverbuilt;
		public Integer FiberCostNewFiberNewConduit;
		public Integer FiberCostNewFiberObstacle;
		public Integer FiberCostNewFiberEstimated;
		public Integer FiberCostNewFiberAerial;
		public Integer FiberCostNewFiberBuried;
		public Integer ExistingFiberOverbuiltFt;
		public Integer FiberCostNewFiberPlowing;
		public Integer FiberCostNewFiberExistingConduit;
		public Integer SpliceCount;
		public Integer SplicingCost;
		public Integer TotalExistingFiberPathFt;
		public Integer TotalFiberCost;
		public Double AvgFiberCostPerFoot;
		public Integer CoToSiteFt;
		public Integer MaxFiberDistanceFt;
		public Integer TotalNewFiberFt;
		public String WithinMaxDistanceDark;
		public Integer BbCostGt10gb;
		public Integer BbCostLtEt1gb;
		public Integer BbCostGt1gbLtEt10gb;
		public Integer TrCostLtEt1gb;
		public Integer TrCostGt1gbLtEt10gb;
		public Integer TrCostGt10gb;
		public String Servable;
		public String FailureCode;
		public String ReviewReason;
		public String ReviewStatus;
		public String RouteNotes;
        public Decimal GuardrailCost;
	}

}