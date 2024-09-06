public class FTRWSCVDRatesRequest {
    
    public FTRWSCVDRatesRequest() {
    }
    
    //public @AuraEnabled ID quoteLineId{get;set;}
    public @AuraEnabled ID addressId{get;set;}
    public @AuraEnabled String pNUM{get;set;} 
    
    public @AuraEnabled String locTier{get;set;} 
    public @AuraEnabled String region{get;set;}
    public @AuraEnabled String spec{get;set;}

    public @AuraEnabled String los{get;set;}
    public @AuraEnabled String vta{get;set;} 
    
    public @AuraEnabled String product{get;set;} 
    public @AuraEnabled String serviceTierPort{get;set;}
    public @AuraEnabled String circuitType{get;set;}
    
    public @AuraEnabled String usocTier{get;set;}
    public @AuraEnabled String usocType{get;set;} 
    public @AuraEnabled String uniSpeed{get;set;} 
    public @AuraEnabled String evcSpeed{get;set;}
    public @AuraEnabled String nrcUsoc{get;set;}

    public @AuraEnabled String mrcUsoc{get;set;}
    public @AuraEnabled String cntrlKey{get;set;} 
    
   
    public @AuraEnabled String address{get;set;}
    public @AuraEnabled String city{get;set;} 
    public @AuraEnabled String stateCd{get;set;} 
    public @AuraEnabled String swc{get;set;}

}