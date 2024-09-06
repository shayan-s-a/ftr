/*********************************************************************************************************************
*@Name        : CreateQuickQuote_Controller
*@Author      : Dileep Chinthala <dileep.chinthala@ftr.com>
*@Description : This controller class is used in CreateQuickQuote VF page to generate QuickQuote.pdf with all quotes 
				under an opportunity
* UPDATES
* Version 		Date       		Developer  				Description
*------------------------------------------------------------------------------------------------------------------
*1.0    		11/19/2021     Dileep Chinthala      Initial Creation                                                      

**********************************************************************************************************************/

public class CreateQuickQuote_Controller {
    //public List<Quote_Line_Item_Product_Wrapper> qqItems {get; set;}
    public List<QuoteServiceController.QuoteWrapper> quoteItems {get; set;}
    public Decimal totalQQValue{get; set;}
    public Decimal totalOnetimeCharge {get; set;}
    public Decimal totalMonthlyCharge {get; set;} 
    public String comments {get; set;}
    public Opportunity opp {get; set;} 
    public String allQuotes {get; set;} 
    
    public CreateQuickQuote_Controller() {
        System.debug('ApexPages.currentPage: ');
        Id oppId = ApexPages.currentPage().getParameters().get('oid');
        init(oppId);
    }
    
    public Void init(Id oppId) {
        if(oppId != null) {
            try {
                this.opp = getCurrentOpportunity(oppId);
                this.comments = ApexPages.currentPage().getParameters().get('c');
                this.allQuotes = ApexPages.currentPage().getParameters().get('allQuotes');
                quoteItems = new List<QuoteServiceController.QuoteWrapper> (); 
                if(this.allQuotes == 'TRUE') {
                Set<Id> quoteIds = QuoteServiceController.getAllQuoteIdsFromOpportunity(oppId).keySet();
                this.quoteItems = QuoteServiceController.getAllQuoteProducts(oppId, quoteIds);
                } else{
                    
                    Set<Id> quoteIds = QuoteServiceController.getSyncedQuoteIdFromOpportunity(oppId).keySet();
                	this.quoteItems = QuoteServiceController.getAllQuoteProducts(oppId, quoteIds);
                }
                for(QuoteServiceController.QuoteWrapper wrapObj:quoteItems){
                    wrapObj.totalQQValue = QuoteServiceController.getTotalQuickQuoteValue(wrapObj.lineItemsList);
                    wrapObj.totalOnetimeCharge = QuoteServiceController.getOneTimeTotalQuickQuoteValue(wrapObj.lineItemsList);
                    wrapObj.totalMonthlyCharge = QuoteServiceController.getMonthlyTotalQuickQuoteValue(wrapObj.lineItemsList);
                }
                
                
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
               AccountId,
               CreatedBy.Name, 
               CreatedBy.Email,
               CreatedBy.Phone
               FROM Opportunity 
               WHERE id = :oppId
               LIMIT 1];    
    }
}