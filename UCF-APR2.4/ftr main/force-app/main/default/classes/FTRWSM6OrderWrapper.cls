public class FTRWSM6OrderWrapper {
    
    public class Order {
        public String OpportunityNumber;
        public String ACNA;
        public String CCNA;
        public String PNUM;
        public String ProjectId;
        public String DSATID;
        public String VTA;
        public String UNIBDW;
        public String EVCBDW;
        public String CNO;
        public String QoS;
        public String OrderStage;
        public String Expedite;
        public String MaxServiceFrameSize;
        public String BDTRequired;
        public String BDTNumber;
        public String type_of_sr;
        public String ACTIVITY_IND;
        public String ServiceOrderNo;
        public DateTime FOCDate;
        public String PON;
        public String Version;
        public String RPON;
        public String ASRRemarks;
        public DateTime RequestedDueDate;
        public DateTime ScheduledDueDate;
        public String ControlKeyNo;
        public String UNISpecCode;
        public String EVCSpecCode;
        public String SEI;
        public String EVCI;
        public String InitiatiorName;
        public String InitiatiorNumber;
        public String InitiatiorEmail;
        public String CircuitQuantity;
        public String CircuitId;
        public String circuits; //SDDD-2041        
        public String UNINC;
        public String UNINCI;
        public String UNISECNCI;
        public String EVCNC;
        public String EVCNCI;
        public String MUX;
        public String CFA;
        public String CCEA;
        public String SUPPLEMENTTYPE;
        public String PRILOC_EndUserName;
        public String PRILOC_EndUserAddress;
        public String PRILOC_ACTL_NNI_CLLI;
        public String PRILOC_LCON;
        public String PRILOC_LCON_TN;
        public String PRILOC_LCON_Email;
        public String SECLOC_EndUserName;
        public String SECLOC_EndUserAddress;
        public String SECLOC_ACTL_NNI_CLLI;
        public String SECLOC_LCON;
        public String SECLOC_LCON_TN;
        public String SECLOC_LCON_Email;
        
        //Code changes for OAM-1369 PRILOC address did not populate in SF
        public String PRILOC_STREET_NUMBER;
        public String PRILOC_STREET_NAME;
        public String PRILOC_CITY;
        public String PRILOC_STATE;
        public String PRILOC_ZIP;
        public String SECLOC_STREET_NUMBER;
        public String SECLOC_STREET_NAME;
        public String SECLOC_CITY;
        public String SECLOC_STATE;
        public String SECLOC_ZIP;
    }
    
    public Order order;
    
}