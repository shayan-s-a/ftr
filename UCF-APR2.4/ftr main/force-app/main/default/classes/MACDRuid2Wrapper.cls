public class MACDRuid2Wrapper {

	public class RelatedCircuits {
		public String relationship;
		public Integer circuitDesignId;
		public String circuitStatus;
		public String circuitName;
	}

	public class CustomAttributes {
		public String label;
		public String value;
		public String unitOfMeasure ;
	}

	public CircuitDetails circuitDetails;
	public String resourceLink;

	public class ExtendedCircuitProperties {
		public String label;
		public String value;
	}

	public class Locations {
		public Integer locationId;
		public String locationUse;
		public String locationType;
		public String clii;
		public String locationName;
		public String addressLine1;
		public String addressLine2;
		public String city;
		public String state;
		public String zipCode;
		public String localContact;
		public String contactTelNum;
	}

	public class CircuitDetails {
		public Integer circuitDesignId;
		public String circuitStatus;
		public String serviceItemStatus;
		public String exchangeCarrierCircuitName;
		public String accessCustomerCircuitName;
		public String circuitType;
		public String exchangeCarrierCircuitType;
		public String rateCode;
		public String circuitLayoutRecordNotes;
		public String jurisdictionCode;
		public String customerCircuitDescription;
		public String lineCoding;
		public String framing;
		public Boolean isFramingAnsi;
		public String networkChannelCode;
		public String networkChannelInterfaceCode;
		public String secondaryNciCode;
		public String lecBillingPhoneNumber;
		public String groupBillingPhoneNumber;
		public String associatedBillingPhoneNumber;
		public Integer openOrderCount;
		public Boolean isOfficialCircuitUseOnly;
		public Boolean isOfficialCompanyUseOnly;
		public String ownerCode;
		public Boolean isChannelized;
		public Boolean isProtectedCircuit;
		public String networkSystemConnectionType;
		public String bandwidthOrTdm;
		public Integer originLocationId;
		public String originLocationClli;
		public String originLocationName;
		public String originLocationType;
		public Integer terminatingLocationId;
		public String terminatingLocationCode;
		public String terminatingLocationName;
		public String terminatingLocationType;
		public String serviceTypeCategory;
		public String serviceTypeCode;
		public String serviceTypeShortDescription;
		public String serviceTypeLongDescription ;
		public String circuitLengthInMiles;
		public Boolean isSettled;
		public String lastModifiedByDate;
		public Boolean isDiversitySet;
		public List<Locations> locations;
		public List<CustomAttributes> customAttributes;
		public List<RelatedCircuits> relatedCircuits;
		public List<ExtendedCircuitProperties> extendedCircuitProperties;
	}

	
	public static MACDRuid2Wrapper parse(String json) {
		return (MACDRuid2Wrapper) System.JSON.deserialize(json, MACDRuid2Wrapper.class);
	}
}