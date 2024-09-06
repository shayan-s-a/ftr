public class QuickQuote_Controller {
    public List<Quote_Line_Item_Product_Wrapper> qqItems {get; set;}
    public Decimal totalQQValue{get; set;}
    public Decimal totalOnetimeCharge {get; set;}
    public Decimal totalMonthlyCharge {get; set;} 
    public String comments {get; set;}
    public Opportunity opp {get; set;}

    public QuickQuote_Controller() {
        System.debug('ApexPages.currentPage: ');
        Id oppId = ApexPages.currentPage().getParameters().get('oid');
        init(oppId);
    }
    
    public Void init(Id oppId) {
        if(oppId != null) {
            try {
                this.opp = getCurrentOpportunity(oppId);
                this.comments = ApexPages.currentPage().getParameters().get('c');
                Set<Id> quoteIds = SterlingQuoteUtility.getQuoteIdsFromOpportunity(oppId).keySet();
                this.qqItems = Quote_Line_Item_Product_Wrapper.getQuickQuoteWrappers(oppId, quoteIds);
                this.totalQQValue = Quote_Line_Item_Product_Wrapper.getTotalQuickQuoteValue(qqItems);
                this.totalOnetimeCharge = Quote_Line_Item_Product_Wrapper.getOneTimeTotalQuickQuoteValue(qqItems);
                this.totalMonthlyCharge = Quote_Line_Item_Product_Wrapper.getMonthlyTotalQuickQuoteValue(qqItems);
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
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
            FROM Opportunity 
            WHERE id = :oppId
            LIMIT 1];    
    }
}