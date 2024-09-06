public class FTRWSCVDAddress {
    
    public FTRWSCVDAddress() {
        
    }
    
    public @AuraEnabled String address{get;set;}
    public @AuraEnabled String city{get;set;} 
    public @AuraEnabled String stateCd{get;set;} 
    public @AuraEnabled String zipCd{get;set;} 
    public @AuraEnabled String swc{get;set;}
    public @AuraEnabled String UsocTier{get;set;}
    public @AuraEnabled String lookUpUsed{get;set;}
}