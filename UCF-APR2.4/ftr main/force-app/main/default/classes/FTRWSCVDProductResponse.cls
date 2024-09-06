public class FTRWSCVDProductResponse {
    
    //public @AuraEnabled FTRWSCVDAddress Address {get;set;}
    //public @AuraEnabled List<FTRWSCVDProduct> cvdProducts {get;set;} 
    
    public @AuraEnabled List<WSCatalogItems> items {get;set;}
    public @AuraEnabled String cvdLookupUsed {get;set;}
    public @AuraEnabled String cvdPriceTier {get;set;}
    
    public @AuraEnabled FTRWSCVDError error;
    public FTRWSCVDProductResponse() {
        this.error = new FTRWSCVDError();
    }
    

}