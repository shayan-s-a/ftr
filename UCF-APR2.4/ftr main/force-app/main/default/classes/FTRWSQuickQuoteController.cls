public class FTRWSQuickQuoteController {
    
    
    public String rfqString { get; set; } //zAddress
    public List<FTRWSQuoteLineItemProdWrapper> qqItems {get; set;}
    public Decimal totalQQValue{get; set;}
    public Decimal totalOnetimeCharge {get; set;}
    public Decimal totalMonthlyCharge {get; set;} 
    public String comments {get; set;}
    public String quoteCreateDate {get; set;}
    public Opportunity opp {get; set;}
    public SterlingQuote__c quote {get; set;}
    public String ftrURL {get; set;}
    
    public FTRWSQuickQuoteController() {
        System.debug('ApexPages.currentPage: ');
        Id oppId = ApexPages.currentPage().getParameters().get('oid');
        init(oppId);
    }
    
    public Void init(Id oppId) {
        if(oppId != null) {
            try {
                this.opp = getCurrentOpportunity(oppId);
                this.quote = getSyncedQuote(oppId);
                this.comments = ApexPages.currentPage().getParameters().get('c');
                Set<Id> quoteIds = SterlingQuoteUtility.getQuoteIdsFromOpportunity(oppId).keySet();
                this.qqItems = FTRWSQuoteLineItemProdWrapper.getQuickQuoteWrappers(oppId, quoteIds);
                system.debug('QQ items for wholesale: ' + this.qqItems);
                this.rfqString = getRFQString(quote.Name);
                this.ftrURL = 'https://wholesale.frontier.com/';
                System.debug('My rfqString:' + this.rfqString);
                this.quoteCreateDate = FTRWSQuoteLineItemProdWrapper.getQuoteDate(quote.Id);
                System.debug('quote create Date:' + this.quoteCreateDate);
                this.totalQQValue = FTRWSQuoteLineItemProdWrapper.getTotalQuickQuoteValue(qqItems);
                this.totalOnetimeCharge = FTRWSQuoteLineItemProdWrapper.getOneTimeTotalQuickQuoteValue(qqItems);
                this.totalMonthlyCharge = FTRWSQuoteLineItemProdWrapper.getMonthlyTotalQuickQuoteValue(qqItems);
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
    }
    
    ///////////////////////////////////////
    //Fix for defect: EQU-39152. Display quote name instead of quote number in the RFQ field
    @TestVisible
    private static String getRFQString (String quoteName) {
        String quoteNameStr = 'Quote Name: ' + quoteName;
        return quoteNameStr;
    }
    
    @TestVisible
    private static Opportunity getCurrentOpportunity(Id oppId) {
        return[SELECT 
               Account.Name,
               Account.BillingStreet,
               Account.BillingCity,
               Account.BillingState,
               Account.BillingPostalCode,
               Account.BillingCountry,
               Account.Phone, 
               Account.SB_Email__c,
               AccountId
               //Owner.Name,
               //Owner.Phone,
               //Owner.Email
               FROM Opportunity 
               WHERE id = :oppId
               LIMIT 1];    
    }
    @TestVisible
    private static SterlingQuote__c getSyncedQuote(Id oppId) {
        SterlingQuote__c quote ; 
        try {
            quote = [SELECT 
                     Id,
                     CreatedDate,
                     Name,
                     WS_Quote_Number__c      
                     FROM SterlingQuote__c 
                     WHERE OpportunityId__c = :oppId
                     and IsSyncing__c = true   
                     LIMIT 1];
        } catch(Exception e) {
            System.debug('Error occured while getting synced quote in Quick quote controller: ' + e.getMessage());
        }
        
        return quote;    
    }
}