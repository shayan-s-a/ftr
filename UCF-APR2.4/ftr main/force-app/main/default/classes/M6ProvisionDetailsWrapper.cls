public class M6ProvisionDetailsWrapper {

	public OrderDetails orderDetails;

	public class OrderDetails {
		public List<OrderCircuits> orderCircuits;
		public List<OrderContacts> orderContacts;
		public String orderNpaNxx;
		public String serviceRequestStatus;
		public String customerName;
		public String custAcctNbr;
		public String acna;
		public String ccna;
		public String supplementType;
		public String orderActivity;
		public String requestType;
		public String desiredDueDate;
		public String versionIdentification;
		public String projectIdentification;
		public String pon;
		public String orderNumber;
		public String typeOfSr;
		public Integer documentNumber;
	}

	public class Locations {
		public String contactTelNum;
		public String localContact;
		public String zip;
		public String state;
		public String city;
		public String addressLine2;
		public String addressLine1;
		public String locationName;
		public String clli;
		public String locationType;
		public String locationUse;
		public Integer locationId;
	}

	public class ElementConnections_Z {
		public String portSpeed;
		public String port;
		public String cardVendorPartNumber;
		public String cardVendorModelNumber;
		public String cardVendorName;
		public String shelfVendorPartNumber;
		public String shelfVendorModelNumber;
		public String shelfVendorName;
		public Integer shelfEquipmentId;
		public String connectionSpec;
		public String exchangeCarrierCircuitId;
		public Integer circuitDesignId;
	}

	public class CircuitDetails {
		public String svcTypeLongDesc;
		public String svcTypeShortDesc;
		public String serviceTypeCode;
		public String serviceTypeCategory;
		public String termLocNameType;
		public String termLocName;
		public String termLoc;
		public Integer termLocationId;
		public String origLocNameType;
		public String origLocName;
		public String origLocClli;
		public Integer origLocationId;
		public String nstBwTdmCd;
		public String nstConType;
		public String protectedCktInd;
		public String channelizedInd;
		public String ownedLeasedCd;
		public String officialCompanyInd;
		public String officialCircuitIndicator;
		public Integer numberOpenOrders;
		public String associatedBillingNumber;
		public String groupBillNumber;
		public String alltelBillingNumber;
		public String secnciCode;
		public String nciCode;
		public String ncCode;
		public String framingAnsiInd;
		public String framing;
		public String lineCoding;
		public String custCktDesc;
		public String jurisdictionCode;
		public String clrNotes;
		public String rateCode;
		public String eccktType;
		public String circuitType;
		public String accessCustomerCktRef;
		public String exchangeCarrierCircuitId;
		public String servItemStatus;
		public String circuitStatus;
		public Integer circuitDesignId;
	}

	public class ElementConnections {
		public String portSpeed;
		public String port;
		public String cardVendorPartNumber;
		public String cardVendorModelNumber;
		public String cardVendorName;
		public Integer cardEquipmentSpecId;
		public Integer cardEquipmentId;
		public String shelfVendorPartNumber;
		public String shelfVendorModelNumber;
		public String shelfVendorName;
		public Integer shelfEquipmentSpecId;
		public Integer shelfEquipmentId;
		public String connectionSpec;
		public String exchangeCarrierCircuitId;
		public Integer circuitDesignId;
	}

	public class RelatedCircuits {
		public String circuitName;
		public String circuitStatus;
		public Integer circuitDesignId;
		public String relationshipType;
	}

	public class CustomAttributes {
		public String caValueUom;
		public String caValue;
		public String caValueLabel;
	}

	public class OrderRuids {
		public Integer managedRouterIndicator;
		public String effectiveDate;
		public String ruidNciCode;
		public String ruidNcCode;
		public Integer ruidCircuitDesignId;
		public String ruidCircuitName;
		public String ruidNbr;
	}

	public class GlrElements {
	}

	public class GlrElements_Z {
		public List<ElementConnections> elementConnections;
		public String longitude;
		public String latitude;
		public String loopbackIp;
		public String macAddress;
		public String gatewayIp;
		public String mgmtAddress;
		public String exchangeSwc;
		public String clliName;
		public Integer locationId;
		public String elementClli;
		public String elementName;
		public Integer designId;
	}

	public class OrderCircuits {
		public List<RelatedCircuits> relatedCircuits;
		public List<GlrElements> glrElements;
		public List<CustomAttributes> customAttributes;
		public List<OrderRuids> orderRuids;
		public List<Locations> locations;
		public List<CircuitDetails> circuitDetails;
		public String circuitName;
		public Integer circuitDesignId;
		public String circuitActivity;
	}

	public class OrderContacts {
		public String contactEmail;
		public String contactNumber;
		public String contactName;
		public String contactType;
	}

	
	public static M6ProvisionDetailsWrapper parse(String json) {
		return (M6ProvisionDetailsWrapper) System.JSON.deserialize(json, M6ProvisionDetailsWrapper.class);
	}
}