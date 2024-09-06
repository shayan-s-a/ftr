public class QuoteLinesController
{ 
    public String vquoteId {get; set;} 
  
    
    public List<QuoteLineItem> quotelines {
        get
      {
          return [select Id,
                    Floor_Price_One_Time__c,
                    Floor_Price_Recurring__c,
                    //Product2Id__r.name 
                    Product2.Name,
                  	vlocity_cmt__ServiceAccountId__r.Name,
                    vlocity_cmt__Recurringcharge__c,
                    vlocity_cmt__OnetimeCharge__c
                    from QuoteLineItem 
                    where quoteid= : vquoteId ];
           }
    }      
 
}