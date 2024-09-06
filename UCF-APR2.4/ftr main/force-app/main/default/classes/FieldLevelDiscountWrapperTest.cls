@isTest
public with sharing class FieldLevelDiscountWrapperTest {
    public FieldLevelDiscountWrapperTest() {

    }

    @isTest
    public static void main(){

        List<ftr_FieldLevelDiscounting__mdt> fldRecords = [SELECT Id, Priority__c, ProductCode__c, FiberTier__c, Speed__c, Type__c, Discount_Max__c, Discount_Min__c, Term__c, Approval_Needed__c 
                                                    , Pricing_Group__c FROM ftr_FieldLevelDiscounting__mdt order by Priority__c desc LIMIT 2];
        List<FieldLevelDiscountWrapper> comparedRecords = new List<FieldLevelDiscountWrapper>();
        for (ftr_FieldLevelDiscounting__mdt fld:fldRecords){
            FieldLevelDiscountWrapper fldwrapper = new FieldLevelDiscountWrapper(fld);
            comparedRecords.add(fldwrapper);
        }
        comparedRecords.sort();
    } 
}
