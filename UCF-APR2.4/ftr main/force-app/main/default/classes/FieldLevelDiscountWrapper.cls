public class FieldLevelDiscountWrapper implements Comparable {

    public ftr_FieldLevelDiscounting__mdt record;

    public FieldLevelDiscountWrapper(ftr_FieldLevelDiscounting__mdt record) {
        this.record = record;
    }

    public Integer compareTo(Object other) {

        // for descending order

        //return Integer.valueOf(record.Priority__c) - Integer.valueOf(((FieldLevelDiscountWrapper) other).record.Priority__c);
        return Integer.valueOf(((FieldLevelDiscountWrapper) other).record.Priority__c) - Integer.valueOf(record.Priority__c);

    }

}