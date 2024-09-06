trigger PricingFormulaMatrixTrigger on Pricing_Formula_Matrix__c (before insert, before update) {
    Map<String, SObjectField> fMap = Pricing_Formula_Definition__c.SObjectType.getDescribe().fields.getMap();
    for (Pricing_Formula_Matrix__c pf : Trigger.new) {
        SObjectField f = fMap.get(pf.Formula_Name__c);
        if (f == null) {
            pf.addError('Invalid value for the Formula Name field.');
        } else {
            pf.Formula_Label__c = f.getDescribe().getLabel();
        }
    }
}