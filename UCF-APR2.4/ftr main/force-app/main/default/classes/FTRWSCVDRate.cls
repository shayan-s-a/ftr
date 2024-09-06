//This class maps to the rate object returned in the CVD getRates rest service
public class FTRWSCVDRate {
    
    public FTRWSCVDRate() {
        
    }
    
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
    public @AuraEnabled String nrc{get;set;}

    public @AuraEnabled String mrcUsoc{get;set;}
    public @AuraEnabled String mrc{get;set;}
    
    public @AuraEnabled String airlineMileageUsoc{get;set;}
    public @AuraEnabled String airlineMileageRate{get;set;}
    public @AuraEnabled String fixedMileageUsoc{get;set;}
    public @AuraEnabled String fixedMileageRate{get;set;} 
    public @AuraEnabled String internetPortUsoc{get;set;}
    public @AuraEnabled String internetPortRate{get;set;}
    public @AuraEnabled String mileageThresholdUsoc{get;set;}
    public @AuraEnabled String mileageThresholdRate{get;set;}
        
    public @AuraEnabled String cntrlKey{get;set;} 
       
    public @AuraEnabled String address{get;set;}
    public @AuraEnabled String city{get;set;} 
    public @AuraEnabled String stateCd{get;set;} 
    public @AuraEnabled String zipCd{get;set;} 
    public @AuraEnabled String swc{get;set;}

}