/**
* @description Service methods for Quote related functionalities
* @version           : 1
*/  

public class FTRWSDSATAddressResponse {
     
    public FTRWSDSATAddressResponse() {
 
    }
    
    public @AuraEnabled String businessName{get;set;}
    public @AuraEnabled String dsatId{get;set;}
    public @AuraEnabled String vfoRecordId{get;set;}
    public @AuraEnabled String m6OrderNumber{get;set;}
    public @AuraEnabled String createdBy{get;set;}
    public @AuraEnabled String creatorEmail{get;set;}
    public @AuraEnabled String createdById {get;set;} 
    
    public @AuraEnabled String opened{get;set;}
    public @AuraEnabled boolean inFootprint{get;set;}
    public @AuraEnabled String market{get;set;}
    public @AuraEnabled String level{get;set;}
    public @AuraEnabled String products{get;set;}
    public @AuraEnabled String wireCenterCLLI{get;set;}
    

    public @AuraEnabled String siteName{get;set;}
    public @AuraEnabled String wireCenterQoS{get;set;}
    public @AuraEnabled String wireCenterSpeed{get;set;}
    public @AuraEnabled boolean litBuilding{get;set;}
    public @AuraEnabled String fiberDistance{get;set;}

    public @AuraEnabled String copperDistance{get;set;}
    public @AuraEnabled String fiberTier{get;set;}
    public @AuraEnabled String copperTier{get;set;}
    public @AuraEnabled String Address{get;set;}
    public @AuraEnabled String City{get;set;}
    public @AuraEnabled String State{get;set;}
    public @AuraEnabled String ZipCode{get;set;}
    public @AuraEnabled String latitude{get;set;}
    public @AuraEnabled String longitude{get;set;}
    public @AuraEnabled String fiberQualification{get;set;}
    public @AuraEnabled String copperQualification{get;set;}
    public @AuraEnabled String HBE_Legacy{get;set;} 
    public @AuraEnabled String Nearby_HBE_SWC_CLLI{get;set;} 
    // change tst to hbe
    // Changes for BSA - Start
    public @AuraEnabled String LinkStatus{get;set;} 
    public @AuraEnabled String LengthFeet{get;set;} 
    public @AuraEnabled Double FiberCost{get;set;} 
    public @AuraEnabled Double EquipmentCost{get;set;} 
    public @AuraEnabled Double TotalCost{get;set;}
    public @AuraEnabled String FutureHBEWcSpeed{get;set;} 
    public @AuraEnabled String PlannedHBETimeframe{get;set;} 
    // Changes for BSA - End
    /* CML-1958 START*/
    public @AuraEnabled String WirecenterClliCode{get;set;} 
    public @AuraEnabled String PlanId{get;set;} 
    public @AuraEnabled String Servable{get;set;} 
    public @AuraEnabled String ReviewStatus{get;set;} 
    public @AuraEnabled String ReviewReason{get;set;} 
    public @AuraEnabled String RouteNotes{get;set;} 
    
    public @AuraEnabled Integer TotalNewFiberFt{get;set;} 
    public @AuraEnabled Integer CoToSiteFt{get;set;} 
    public @AuraEnabled Integer TotalFiberCost{get;set;} 
    public @AuraEnabled Integer SpliceCount{get;set;} 
    public @AuraEnabled Integer SplicingCost{get;set;} 
    public @AuraEnabled Integer BbCostLtEt1gb{get;set;} 
    public @AuraEnabled Integer BbCostGt1gbLtEt10gb{get;set;} 
    public @AuraEnabled Integer BbCostGt10gb{get;set;} 
    public @AuraEnabled Integer TrCostLtEt1gb{get;set;} 
    public @AuraEnabled Integer TrCostGt1gbLtEt10gb{get;set;} 
    public @AuraEnabled Integer TrCostGt10gb{get;set;} 
    public @AuraEnabled Integer BSAHttpStatusCode{get;set;}
    public @AuraEnabled Decimal GuardRailCost{get;set;} 
    public @AuraEnabled String HBEMaxSpeed{get;set;} 
    public @AuraEnabled String HBEMaxQoS{get;set;} 
    public @AuraEnabled List<String> HBEProducts{get;set;} 
     /* CML-1958 END*/
    
        
}