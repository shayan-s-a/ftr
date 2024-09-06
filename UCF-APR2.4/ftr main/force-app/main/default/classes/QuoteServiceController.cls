/*********************************************************************************************************************
*@Name        : QuoteServiceController
*@Author      : Dileep Chinthala <dileep.chinthala@ftr.com>
*@Description : This controller class is called from in CreateQuickQuote_Controller class to generate QuickQuote.pdf with all quotes 
				under an opportunity
* UPDATES
* Version 		Date       		Developer  				Description
*------------------------------------------------------------------------------------------------------------------
*1.0    		11/25/2021     Dileep Chinthala      Initial Creation                                                      

**********************************************************************************************************************/
public class QuoteServiceController {
    
    public class QuoteWrapper {
        public Decimal totalQQValue{get; set;}
        public Decimal totalOnetimeCharge {get; set;}
        public Decimal totalMonthlyCharge {get; set;} 
        public List<QuoteLineItemWrapper> lineItemsList {get; set;}
        public QuoteWrapper(){
            lineItemsList = new List<QuoteLineItemWrapper>();
        }
    }
    public class QuoteLineItemWrapper {
        public String name { get; set; }
        public Integer quantity { get; set; }
        public String serviceAddress { get; set; }
        public Integer termLength { get; set; }
        public Decimal adjustedNRC { get; set; }
        public Decimal renewalMRR { get; set; }
        public Decimal netNewMRR { get; set; }
        public Decimal cpenrc { get; set; }
        public Decimal nrc { get; set; }
        public Decimal sumRenewNetNewMRR { get; set; }
        public String quoteRecordType { get; set; }
        
        public QuoteLineItemWrapper(QuoteLineItem oli) {
            Quantity = (Integer) oli.Quantity;
            Name = String.isBlank(oli.Speed__c) ? oli.Product2.Name : oli.Product2.Name + ' ' + oli.Speed__c;
            ServiceAddress = oli.vlocity_cmt__ServiceAccountId__r.Name;
            TermLength = (Integer) oli.Term_Months__c;
		if(oli.vlocity_cmt__OneTimeCharge__c==null)
        {
            		this.AdjustedNRC = 0;

        }else{
            		this.AdjustedNRC = oli.vlocity_cmt__OneTimeCharge__c;

        }            NetNewMRR = oli.ftr_NetNewRecurringCharge__c == null ? 0.00 : oli.ftr_NetNewRecurringCharge__c;//oli.CPQ_NetNewMRR__c;
            RenewalMRR = 0;//oli.Renewal_MRR__c;
            NRC = oli.vlocity_cmt__OneTimeCharge__c == null ? 0.00 : oli.vlocity_cmt__OneTimeCharge__c;
            CPENRC = oli.ftr_NRC_Discounted__c == null ? 0.00 : oli.ftr_NRC_Discounted__c;//oli.CPE_NRC_Price__c;
            quoteRecordType = 'Vlocity';
            sumRenewNetNewMRR = NetNewMRR + RenewalMRR;
            // if(oli.ftr_isApplyDiscount__c && oli.Product2.ProductCode  == 'ENT_ETH_EIA_0002' ){
            if(oli.ftr_isApplyDiscount__c ){
                sumRenewNetNewMRR = oli.ftr_DiscountPrice__c == null ? 0.00 : oli.ftr_DiscountPrice__c;
                if(oli.ftr_isApplyDiscount__c && oli.Product2.ProductCode  == 'ENT_ETH_EIA_0002' ){
                    Name = String.isBlank(oli.Speed__c) ? 'DIA Bundle' : 'DIA Bundle ' + oli.Speed__c;
                }
            }
        }
    }
    
    
    public QuoteServiceController() {
    }
    
    public static Map<Id, Quote> getAllQuoteIdsFromOpportunity(Id oppId) {
        return new Map<Id, Quote>([SELECT Id FROM Quote WHERE OpportunityId = :oppId]);
    }
    
     public static Map<Id, Quote> getSyncedQuoteIdFromOpportunity(Id oppId) {
        return new Map<Id, Quote>([SELECT Id,IsSyncing__c FROM Quote WHERE OpportunityId = :oppId AND IsSyncing__c = true]);
    }
    
    
    public static Decimal getTotalQuickQuoteValue(List<QuoteLineItemWrapper> oppProducts) {
        Decimal res = 0;
        for (QuoteLineItemWrapper op : oppProducts) {
            res += (op.RenewalMRR + op.NetNewMRR + op.NRC + op.CPENRC);
        }
        return res;
    }
    
    public static Decimal getOneTimeTotalQuickQuoteValue(List<QuoteLineItemWrapper> oppProducts) {
        Decimal res = 0;
        for (QuoteLineItemWrapper op : oppProducts) {
            res += (op.AdjustedNRC + op.CPENRC );
        }
        return res;
    }
    
    public static Decimal getMonthlyTotalQuickQuoteValue(List<QuoteLineItemWrapper> oppProducts) {
        Decimal res = 0;
        for (QuoteLineItemWrapper op : oppProducts) {
            res += op.sumRenewNetNewMRR;
        }
        return res;
    }
    
    public static List<QuoteWrapper> getAllQuoteProducts(Id oppId, Set<Id> quoteIds) {
        Map<String,QuoteWrapper> quoteSummaryMap = new Map<String,QuoteWrapper>();
        System.debug('$$$quoteIDs='+quoteIds);
        
        List<QuoteLineItem> quoteLineItemsList = new List<QuoteLineItem>(
            [
                SELECT
                Id,
                Quantity,
                Term_Months__c,
                Speed__c,
                vlocity_cmt__OneTimeCharge__c,
                Product2.Name,
                vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__ServiceAccountId__r.Name,
                quote.opportunity.recordtype.name,
                ftr_isApplyDiscount__c, 
                Product2.ProductCode, 
                ftr_DiscountPrice__c,
                ftr_NetNewRecurringCharge__c,
                ftr_NRC_Discounted__c,
                QuoteId
                FROM QuoteLineItem
                WHERE QuoteId IN :quoteIds
                ORDER BY Product2.Name ASC,vlocity_cmt__ServiceAccountId__r.Name DESC, Speed_Mbps__c DESC, Term__c DESC, vlocity_cmt__RecurringCharge__c DESC, vlocity_cmt__LineNumber__c DESC
            ]
        );
        for (QuoteLineItem oli : quoteLineItemsList) {
            QuoteWrapper wrapObj = new QuoteWrapper();
            if(quoteSummaryMap.containsKey(oli.QuoteId)){
                wrapObj = quoteSummaryMap.get(oli.QuoteId);
            }
            wrapObj.lineItemsList.add(new QuoteLineItemWrapper(oli));
            quoteSummaryMap.put(oli.QuoteId, wrapObj);
        }
        
        return quoteSummaryMap.values();
    }
}