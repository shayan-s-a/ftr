public with sharing class FTRWSDPIAddressResponse {
    public FTRWSDPIAddressResponse() {
    }
    public @AuraEnabled String status{get;set;}
    public @AuraEnabled String addressLine1{get;set;} //for display purpose
    
    public @AuraEnabled String streetNumber{get;set;} //for sending in the dpi request after updating any address fields
    public @AuraEnabled String streetName{get;set;}
    public @AuraEnabled String streetSuffix{get;set;}
    
    public @AuraEnabled String preDirectional{get;set;}
    
    public @AuraEnabled String unit{get;set;} //for display purpose
    public @AuraEnabled String secondaryDesignator{get;set;}
    public @AuraEnabled String secondaryNumber{get;set;}
    
    public @AuraEnabled String cityName{get;set;}
    public @AuraEnabled String state{get;set;}
    public @AuraEnabled String zipCode{get;set;}
    public @AuraEnabled String svcControlNo{get;set;}
    public @AuraEnabled String wirecenter{get;set;}
    public @AuraEnabled String clliCode {get;set;} 
    
    public @AuraEnabled boolean disableSave {get;set;} 
    public @AuraEnabled String latitude {get;set;} 
    public @AuraEnabled String longitude {get;set;} 
	public @AuraEnabled String environment {get;set;} 
}