public class QuoteEmail {
	public Id QuoteID {get;set;}
    public List<QuoteLineItem> getQuoteLineItems()
    {
        List<QuoteLineItem> QuoteLineItems = [SELECT Id, QuoteId, Quantity, vlocity_cmt__BaseRecurringCharge__c,ftr_MRC_Discounted__c, 
                                              		vlocity_cmt__RecurringCharge__c,vlocity_cmt__ServiceAccountId__c,
                                              		UnitPrice, Product2Id, vlocity_cmt__ServiceAccountId__r.Name, 
                                              		vlocity_cmt__Product2Id__r.Name, Speed__c,Term__c,
                                              		vlocity_cmt__ServiceAccountId__r.ShippingStreet,
                                                      vlocity_cmt__ServiceAccountId__r.ShippingCity,
                                                      vlocity_cmt__ServiceAccountId__r.ShippingState,
                                                      vlocity_cmt__ServiceAccountId__r.ShippingCountry,
                                                      vlocity_cmt__ServiceAccountId__r.ShippingPostalCode,
                                              		PricebookEntry.Product2.ProductCode, TotalPrice 
                 								FROM QuoteLineItem WHERE QuoteId =: QuoteID AND 
                                              		(ftr_MRC_Discounted__c > 0 OR ftr_NRC_Discounted__c > 0)
                                              ];
        // PricebookEntry.Product2.ProductCode IN ('ENT_ETH_EIA_0002')
        // BaseRecurringCharge__c > vlocity_cmt__RecurringCharge__c
        return QuoteLineItems;
    }
}