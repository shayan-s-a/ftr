public class FTRWSAdjustmentController {
    
    
    @AuraEnabled
    public static Boolean removeDiscount(String jsonString) {
        Boolean discRemoved = false;
        
        FTRWSDiscountRequest ftrwsDiscountObj = (FTRWSDiscountRequest)JSON.deserialize(jsonString, FTRWSDiscountRequest.class);
        String recurringType = ftrwsDiscountObj.recurringType;
        SterlingQuoteItem__c quoteItem = ftrwsDiscountObj.quoteItem;
        String discountType = ftrwsDiscountObj.discountType;
        Decimal discountVal = ftrwsDiscountObj.discountVal;
        String notes = '';
        
        System.debug('discountVal:' + discountVal);
        if(recurringType.containsIgnoreCase('MRC')) {
            quoteItem.AdjustedMRC__c = quoteItem.StandardMRC__c;
            quoteItem.MRC_Discount_Type__c = '';
            quoteItem.Adjusted_MRC_Notes__c = 'Deleted discount';
            quoteItem.MRC_Discount_Applied_By__c = null;
            quoteItem.NetNewMRR__c = quoteItem.AdjustedMRC__c;
        } else {
            quoteItem.AdjustedNRC__c = quoteItem.StandardNRC__c;
            quoteItem.Adjusted_NRC_Notes__c = 'Deleted discount';
            quoteItem.NRC_Discount_Type__c = '';
            quoteItem.NRC_Discount_Applied_By__c = null;
        }
        
        //quoteItem.Discount_Applied_By__c = null;//UserInfo.getUserId();
        quoteItem.OverallStatus__c = 'Draft';
        
        SterlingQuote__c quote = [select Id from SterlingQuote__c where Id=: quoteItem.SterlingQuote__c];
        quote.Status__c = 'Draft';
        update quoteItem;
        update quote;
        
        return discRemoved;
    }
    
    //recurringdiscType starts with mrc or nrc
    //discountType can be Percentage, Amount, Override
    @AuraEnabled
    public static Boolean applyDiscount(String jsonString) {
        Boolean discApplied = false;
        System.debug('Apply discount request: ' + jsonString);
        FTRWSDiscountRequest ftrwsDiscountObj = (FTRWSDiscountRequest)JSON.deserialize(jsonString, FTRWSDiscountRequest.class);
        String recurringType = ftrwsDiscountObj.recurringType;
        SterlingQuoteItem__c quoteItem = ftrwsDiscountObj.quoteItem;
        String discountType = ftrwsDiscountObj.discountType;
        Decimal discountVal = ftrwsDiscountObj.discountVal;
        String mrcDiscNotes = ftrwsDiscountObj.mrcDiscountNotes;
        String nrcDiscNotes = ftrwsDiscountObj.nrcDiscountNotes;
        System.debug('discountVal:' + discountVal);
        if(discountVal == 0.0 || discountVal == 0) {
            System.debug('No discount applied, as discount Value is ' + discountVal);
            return discApplied;
        }
        if(recurringType.containsIgnoreCase('MRC')) {
            mrcDiscNotes = ftrwsDiscountObj.mrcDiscountNotes;
            discApplied = applyMRCDiscount(quoteItem, discountType, discountVal, mrcDiscNotes); 
        } else {
            nrcDiscNotes = ftrwsDiscountObj.nrcDiscountNotes;
            discApplied = applyNRCDiscount(quoteItem, discountType, discountVal, nrcDiscNotes);    
        }
        return discApplied;
    }
    
    private static Boolean applyMRCDiscount(SterlingQuoteItem__c quoteItem, String discountType, Decimal discountVal, String newNotes) {
        Boolean discApplied = false;
        Decimal mrc = quoteItem.StandardMRC__c;
        if(String.isNotBlank(discountType)) {
            String discType = discountType.toUpperCase();
            if(discType == 'AMOUNT') {//amount
                quoteItem.AdjustedMRC__c = mrc + discountVal;
                discApplied = true;
            } else if(discType == 'OVERRIDE') {//override
                quoteItem.AdjustedMRC__c = discountVal;
                discApplied = true;
            } else if(discType == 'PERCENTAGE') {//percentage
                quoteItem.AdjustedMRC__c = mrc + (mrc * (discountVal/100)) ;
                discApplied = true;
            }
            
            if(discApplied) {
                System.debug('quoteItem.StandardMRC__c: ' + quoteItem.StandardMRC__c);
                System.debug('quoteItem.AdjustedMRC__c: ' + quoteItem.AdjustedMRC__c);
                quoteItem.NetNewMRR__c = quoteItem.AdjustedMRC__c; //check with Hemantha later
                quoteItem.UpdatedMRC__c = quoteItem.AdjustedMRC__c;//Added by Vara
                String existingNotes = quoteItem.Adjusted_MRC_Notes__c;
                if(String.isBlank(existingNotes)) {
                    if(String.isNotBlank(newNotes)) {
                        quoteItem.Adjusted_MRC_Notes__c = newNotes;    
                    }
                    
                } else {
                    if(String.isNotBlank(newNotes)) {
                        quoteItem.Adjusted_MRC_Notes__c = existingNotes + ' ' + newNotes;        
                    }
                }
                quoteItem.OverallStatus__c = 'Pending';
                quoteItem.MRC_Discount_Applied_By__c = UserInfo.getUserId();
                SterlingQuote__c quote = [select Id from SterlingQuote__c where Id=: quoteItem.SterlingQuote__c];
                quote.Status__c = 'Needs Review';
                
                if(String.isNotBlank(quoteItem.Products__r.Family)) {
                    if(quoteItem.Products__r.Family.contains('FOTS')) {
                        quote.FOTS__c = true;
                    }
                }
                update quoteItem;
                update quote;
            }
        }
        
        return discApplied;
    }
    
    //TODO: need to rework this based on the applyMRC logic
    private static Boolean applyNRCDiscount(SterlingQuoteItem__c quoteItem, String discountType, Decimal discountVal, String newNotes) {
        Boolean discApplied = false;
        Decimal nrc = quoteItem.StandardNRC__c;
        if(String.isNotBlank(discountType)) {
            String discType = discountType.toUpperCase();
            if(discType == 'AMOUNT') {//amount
                quoteItem.AdjustedNRC__c = nrc + discountVal;
                discApplied = true;
            } else if(discType == 'OVERRIDE') {//override
                quoteItem.AdjustedNRC__c = discountVal;
                discApplied = true;
            } else if(discType == 'PERCENTAGE') {//percentage
                quoteItem.AdjustedNRC__c = nrc + (nrc * (discountVal/100)) ;
                discApplied = true;
            }
        }
        
        if(discApplied) {
            System.debug('quoteItem.StandardNRC__c: ' + quoteItem.StandardNRC__c);
            System.debug('quoteItem.AdjustedNRC__c: ' + quoteItem.AdjustedNRC__c);
            //quoteItem. = quoteItem.AdjustedMRC__c; //check with Hemantha later
            String existingNotes = quoteItem.Adjusted_NRC_Notes__c;
            if(String.isBlank(existingNotes)) {
                if(String.isNotBlank(newNotes)) {
                    quoteItem.Adjusted_NRC_Notes__c = newNotes;    
                }
                
            } else {
                if(String.isNotBlank(newNotes)) {
                    quoteItem.Adjusted_NRC_Notes__c = existingNotes + ' ' + newNotes;        
                }
            }
            quoteItem.OverallStatus__c = 'Pending';
            quoteItem.UpdatedNRC__c=quoteItem.AdjustedNRC__c;//Added by Vara
            quoteItem.NRC_Discount_Applied_By__c = UserInfo.getUserId();
            SterlingQuote__c quote = [select Id from SterlingQuote__c where Id=: quoteItem.SterlingQuote__c];
            quote.Status__c = 'Needs Review';
            
                if(String.isNotBlank(quoteItem.Products__r.Family)) {
                    if(quoteItem.Products__r.Family.contains('FOTS')) {
                        quote.FOTS__c = true;
                    }
                }
            
            update quoteItem;
            update quote;
        }
        return discApplied;
    }
    
    @AuraEnabled
    public static FTRWSDiscountResponse getQuoteLineItemDiscountInfo(String jsonString) {
        System.debug('Apply discount request: ' + jsonString);
        FTRWSDiscountRequest discObj = (FTRWSDiscountRequest)JSON.deserialize(jsonString, FTRWSDiscountRequest.class);
        if(discObj != null) {
            String recurrType = discObj.recurringType;
            if(String.isNotBlank(recurrType)) {
                if('MRC'.equalsIgnoreCase(recurrType)) {
                    FTRWSDiscountResponse mrcDiscResp =  getMRCDiscountInfo(discObj);
                    return mrcDiscResp;
                } else {
                    FTRWSDiscountResponse nrcDiscResp = getNRCDiscountInfo(discObj);
                    return nrcDiscResp;
                }
            }
        }
        
        return null;        
    } 
    
    private static FTRWSDiscountResponse getMRCDiscountInfo(FTRWSDiscountRequest ftrwsDiscountObj) {
        FTRWSDiscountResponse response = new FTRWSDiscountResponse();
        SterlingQuoteItem__c quoteItem  = [Select Id,Primary_Competitor__c,Primary_Competitor_Amount__c,Competitors_in_area__c, Adjusted_MRC_Notes__c, AdjustedMRC__c, MRC_Discount_Applied_By__c, StandardMRC__c, Display_MRC__c from SterlingQuoteItem__c where Id=: ftrwsDiscountObj.quoteItem.Id];
        // Added by Vara from here
        Decimal PrimaryCompetitorAmount = quoteItem.Primary_Competitor_Amount__c;
        response.PrimaryCompetitor = quoteItem.Primary_Competitor__c;
        response.PrimaryCompetitorArea = quoteItem.Competitors_in_area__c;
        response.PrimaryCompetitorAmt = PrimaryCompetitorAmount;
        // Added by Vara upto Here
        Decimal actualMRC = quoteItem.StandardMRC__c;
        response.actualAmt = actualMRC;
        response.displayAmt = quoteItem.Display_MRC__c;
        Decimal adjustedMRC =  quoteItem.AdjustedMRC__c;
        response.adjustedAmt = adjustedMRC;
        response.notes = quoteItem.Adjusted_MRC_Notes__c;
        
        if(String.isNotBlank(quoteItem.MRC_Discount_Applied_By__c)) {
            User user = [Select Id, FirstName, LastName from User where Id=:quoteItem.MRC_Discount_Applied_By__c];
            response.discAppliedBy = user.FirstName +' ' + user.LastName;
        }
        response.recurringType = 'MRC';
        response.discAmt = adjustedMRC - actualMRC; 
        if(response.discAmt != 0.0) {
            response.isDiscounted = true;
        } 
        return response;        
    }
    
    private static FTRWSDiscountResponse getNRCDiscountInfo(FTRWSDiscountRequest ftrwsDiscountObj) {
        FTRWSDiscountResponse response = new FTRWSDiscountResponse();
        
        SterlingQuoteItem__c quoteItem  = [Select Id,Primary_Competitor__c,Primary_Competitor_Amount__c,Competitors_in_area__c, Adjusted_NRC_Notes__c, AdjustedNRC__c, NRC_Discount_Applied_By__c, StandardNRC__c, Display_NRC__c from SterlingQuoteItem__c where Id=: ftrwsDiscountObj.quoteItem.Id];
        // Added by Vara from here
        Decimal PrimaryCompetitorAmount = quoteItem.Primary_Competitor_Amount__c;
        response.PrimaryCompetitor = quoteItem.Primary_Competitor__c;
        response.PrimaryCompetitorArea = quoteItem.Competitors_in_area__c;
        response.PrimaryCompetitorAmt = PrimaryCompetitorAmount;
        // Added by Vara upto Here        
        Decimal actualNRC = quoteItem.StandardNRC__c;
        response.actualAmt = actualNRC;
        response.displayAmt = quoteItem.Display_NRC__c;
        Decimal adjustedNRC =  quoteItem.AdjustedNRC__c;
        response.adjustedAmt = adjustedNRC;
        response.notes = quoteItem.Adjusted_NRC_Notes__c;
        
        if(String.isNotBlank(quoteItem.NRC_Discount_Applied_By__c)) {
            User user = [Select Id, FirstName, LastName from User where Id=:quoteItem.NRC_Discount_Applied_By__c];
            response.discAppliedBy = user.FirstName +' ' + user.LastName;
        }

        response.recurringType = 'NRC';
        response.discAmt = adjustedNRC - actualNRC;
        if(response.discAmt != 0.0) {
            response.isDiscounted = true;
        }         
        return response;         
    }
/*        

*/    
    
   
}