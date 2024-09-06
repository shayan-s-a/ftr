public class FTRWSDiscountResponse {

    
    public @AuraEnabled Decimal actualAmt{get;set;}
    public @AuraEnabled String displayAmt{get;set;}
    public @AuraEnabled Decimal adjustedAmt{get;set;}
    public @AuraEnabled Decimal discAmt{get;set;} //difference b/w actualAmt and adjustedAmt
    public @AuraEnabled String recurringType{get;set;}
    public @AuraEnabled String notes{get;set;}
    public @AuraEnabled String discAppliedBy{get;set;}
    public @AuraEnabled Boolean isDiscounted{get;set;}
    public @AuraEnabled String PrimaryCompetitor{get;set;}
    public @AuraEnabled String PrimaryCompetitorArea{get;set;}
    public @AuraEnabled Decimal PrimaryCompetitorAmt{get;set;}

}