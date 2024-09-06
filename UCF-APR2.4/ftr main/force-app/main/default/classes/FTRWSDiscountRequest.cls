public class FTRWSDiscountRequest {
    
    public @AuraEnabled SterlingQuoteItem__c quoteItem{get;set;}
    public @AuraEnabled String recurringType{get;set;}
    public @AuraEnabled String discountType{get;set;} 
    public @AuraEnabled Decimal discountVal{get;set;}
    public @AuraEnabled String mrcDiscountNotes{get;set;}
    public @AuraEnabled String nrcDiscountNotes{get;set;}
    
}