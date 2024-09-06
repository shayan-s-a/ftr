@IsTest
public with sharing class Test_Fixture_Factory {
    public static Opportunity createTestOpportunity() {
        Opportunity opp = new Opportunity(Name = 'Test 1', StageName = 'Investigating', CloseDate = Date.today(), Pricebook2Id = Test.getStandardPricebookId());
        insert opp;
        return opp;
    }
    
    public static SterlingQuote__c createTestQuote(Id oppId, String discountType, String overallStatus) {
        return createTestQuote(oppId, discountType, overallStatus, true);
    }

    public static SterlingQuote__c createTestQuote(Id oppId, String discountType, String overallStatus, Boolean createOpportunityLineItems) {
        RecordType type = [SELECT Id FROM RecordType WHERE Name = 'SFA' AND SobjectType = 'SterlingQuote__c' LIMIT 1];
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        SterlingQuote__c quote = new SterlingQuote__c(Name = 'Test Quote 1', 
                                                        RecordType = type, 
                                                        OpportunityId__c = oppId, 
                                                        IsSyncing__c = true);
        insert quote;
        
        List<SterlingQuoteItem__c> items = createTestQuoteItems(quote.Id, discountType, overallStatus);
        Id pb = Test.getStandardPricebookId();
        for (SterlingQuoteItem__c item : items) {
            Product2 p = createTestProduct('test product', 'test product', '%999%');
            PricebookEntry pe = createPricebookEntry(pb, p.id, 10.50);
            if (createOpportunityLineItems) {
                OpportunityLineItem oli = createTestOpportunityLineItem(oppId, p, pb);
                item.OpportunityLineItemId__c = oli.Id;
            }
        }
        insert items;
        return quote;
    }

    public static List<SterlingQuoteItem__c> createTestQuoteItems(Id quoteId, String discountType, String overallStatus) {
        return new List<SterlingQuoteItem__c> {
            new SterlingQuoteItem__c (SterlingQuote__c = quoteId, DiscountType__c = '', Name = 'Test1', Quantity__c = 1, Category__c = 'Services',TermLength__c=1,NetNewMRR__c = 10,renewal_mrr_original__c=10,AdjustedNRC__c=10,CPE_NRC_Price__c=10),
            new SterlingQuoteItem__c (SterlingQuote__c = quoteId, DiscountType__c = discountType, OverallStatus__c = overallStatus, Name = 'Test2', Quantity__c = 1,TermLength__c=1, Category__c = 'Installation',NetNewMRR__c = 10,renewal_mrr_original__c=10,AdjustedNRC__c=10,CPE_NRC_Price__c=10),
            new SterlingQuoteItem__c (SterlingQuote__c = quoteId, DiscountType__c = '', Name = 'Test2', Quantity__c = 1, Category__c = 'Hardware/Matls',TermLength__c=1,NetNewMRR__c = 10,renewal_mrr_original__c=10,AdjustedNRC__c=10,CPE_NRC_Price__c=10),
            new SterlingQuoteItem__c (SterlingQuote__c = quoteId, DiscountType__c = '', Name = 'Test4', Quantity__c = 1, Category__c = 'Phone Power',TermLength__c=1,NetNewMRR__c = 10,renewal_mrr_original__c=10,AdjustedNRC__c=10,CPE_NRC_Price__c=10),
            new SterlingQuoteItem__c (SterlingQuote__c = quoteId, DiscountType__c = '', Name = 'Test5', Quantity__c = 1, Category__c = 'Write-In Parts',TermLength__c=1,NetNewMRR__c = 10,renewal_mrr_original__c=10,AdjustedNRC__c=10,CPE_NRC_Price__c=10)
        };
    }
    
    public static Product2 createTestProduct(String name, string description, string productCode) {
        Product2 p = new Product2();
        p.Name = name;
        p.Description = description;
        p.ProductCode = productCode;
        insert p;
        return p;
    }
    
    public static PricebookEntry createPricebookEntry(Id pricebookId, Id productId, Decimal price) {
		PricebookEntry pe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productId, UnitPrice = price, IsActive = true);
        insert pe;
        return pe;
    }
    
    public static OpportunityLineItem createTestOpportunityLineItem(Id opportunityId, Product2 product, Id pricebookId) {
        Product2 p = createTestProduct ('Test Product', 'Test Description', '%999%');

        PricebookEntry pe = createPricebookEntry(pricebookId, p.iD, 10000);
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.CPE_Gross_Margin__c = 0;
        oli.CPE_NRC_Price__c = 5.00;
        oli.NRC_Price__c = 12;
        oli.Product2 = p;
        oli.Service_Address__c = 'test';
        oli.Quantity = 1;
        oli.OpportunityId = opportunityId;
        oli.TotalPrice = 18.00;
        oli.PricebookEntryId = pe.Id;
        insert oli;
        return oli;
    }
}