public class UpdatedMRRWrapper{
    public cls_updatedMRR[] updatedMRR;
    public class cls_updatedMRR {
        public String oliId;	//00k01000003tWPuAAM
        public String updatedMRRValue;	//0.00
        public String recurringCharge;
        public String recurringTotal;
        public String quantityValue;
    }
    public static UpdatedMRRWrapper parse(String json){
        return (UpdatedMRRWrapper) System.JSON.deserialize(json, UpdatedMRRWrapper.class);
    }
}