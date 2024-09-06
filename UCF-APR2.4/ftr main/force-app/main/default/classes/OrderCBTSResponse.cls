public class OrderCBTSResponse {
    public class SFOrderFA {
        public String SFOrderNumber;
        public String OrderType;
        public String VendorId;
        public String VendorName;
        public SFOrderFADetails SFOrderFADetails;
    }
    
    public SFOrderFA SFOrderFA;
    
    public class SFOrderFADetails {
        public String FAStatusCode;
        public String FAStatus;
        public String FAStatusDate;
    }
}