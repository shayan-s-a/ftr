public class Opportunity_Line_Item_Utility {

    public static Map<Id, OpportunityLineItem> getOpportunityLineItemsMapFromOpportunity(String oppId) {
        return  new Map<Id, OpportunityLineItem>([SELECT Id, 
                            Renewal_MRR__c, 
                            UnitPrice, 
                            CPE_Gross_Margin__c, 
                            CPE_NRC_Price__c, 
                            NRC_Price__c, 
                            Product2.name, 
                            AdjustedMRC__c, 
                            QuoteId__c, 
                            Service_Address__c, 
                            ZAddress__c,
                            ftr_isApplyDiscount__c, 
                            Product2.ProductCode, 
                            ftr_DiscountPrice__c
                        FROM OpportunityLineItem 
                        WHERE Opportunityid = :oppId]);
    }
}