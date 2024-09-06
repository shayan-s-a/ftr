public class FTRWSCVDRatesResponse {
    
    public FTRWSCVDRatesResponse() {
        
    }
   
    
    public @AuraEnabled FTRWSCVDError error {get;set;}
    public @AuraEnabled List<FTRWSCVDRate> Rate {get;set;} 
    public @AuraEnabled FTRWSCVDAddress Address {get;set;}
    
    
}