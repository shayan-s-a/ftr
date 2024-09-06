public class FTRWSAddressResponse {

    public @AuraEnabled boolean dpiSuccess{get;set;}
    public @AuraEnabled boolean dsatSuccess{get;set;}
    public @AuraEnabled boolean multipleDPIResults{get;set;}
    public @AuraEnabled List<FTRWSDPIAddressResponse> dpiResponseList{get;set;}
    public @AuraEnabled FTRWSDSATAddressResponse dsatResponse{get;set;}
}