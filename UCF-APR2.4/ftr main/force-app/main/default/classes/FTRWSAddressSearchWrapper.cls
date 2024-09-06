public class FTRWSAddressSearchWrapper {

	public class Addresses {
		public String addressKey{get;set;}
		public String parentKey;
		public Address address{get;set;}
        public String strAddress {
            get {
                ReadAddress objAddress = new ReadAddress(address.addressLine1, address.addressLine2, parsedAddress.city, 
                                                         parsedAddress.stateProvince, parsedAddress.zipCodeBase, samRecords[0].environment, samRecords[0].controlNumber);
                return JSON.serialize(objAddress);
            }
            set;
        }
        public String strAddressDisplay {
            get {
                List<String> stringList = new List<String>{address.addressLine1, address.addressLine2, parsedAddress.city, parsedAddress.stateProvince, parsedAddress.zipCodeBase};
                return String.join(stringList, ' ');
            }
            set;
        }
		public ParsedAddress parsedAddress;
		public List<SamRecords> samRecords;
		public Double latitude;
		public Double longitude;
		public Boolean isParent;
		public Boolean inFootprint;
	}
    
    public class ReadAddress {
		public String addressLine1{get;set;}
		public String addressLine2{get;set;} 
        public String city{get;set;}
		public String stateProvince{get;set;}
		public String zipCodeBase{get;set;}
        public String env{get;set;}
        public String controlNumber{get;set;}
        public ReadAddress(String addressLine1, String addressLine2, String city, String stateProvince, String zipCodeBase, String controlNumber, String env) {
            this.addressLine1 = addressLine1;
            this.addressLine2 = addressLine2;
            this.city = city;
            this.stateProvince = stateProvince;
            this.zipCodeBase = zipCodeBase;
            this.env = env;
            this.controlNumber = controlNumber;
        }
    }

	public List<Addresses> addresses{get;set;}
	public Integer totalCount;
	public List<Links> links;

	public class Address {
		public String addressLine1{get;set;}
		public String addressLine2{get;set;}
		public String city{get;set;}
		public String stateProvince{get;set;}
		public String zipCode{get;set;}
	}

	public class Links {
		public String href;
		public String rel;
		public String verb;
	}

	public class SamRecords {
		public String environment;
		public String controlNumber;
	}

	public class ParsedAddress {
		public String streetNumber;
		public String streetPreDirectional;
		public String streetName;
		public String streetSuffix;
		public String streetPostDirectional;
		public String unitType;
		public String unitNumber;
		public String city;
		public String stateProvince;
		public String zipCodeBase;
		public String zipCodePlus4;
	}
}