global with sharing class QuoteServiceTermUpdate{
    
    @InvocableMethod
    public static void UpdateServiceTerm(List<QuoteLineItem> lstQuoteLineItemId) {
        try{
            if(!lstQuoteLineItemId.isEmpty()){

                //UPDATE: Made it bulk safe in case the list contains more than one item, e.g. from a mass update
                Map<Id, List<QuoteLineItem>> quoteGroups = new Map<Id, List<QuoteLineItem>>();
                for(QuoteLineItem qli : lstQuoteLineItemId)
                {
                    if(quoteGroups.containsKey(qli.quoteId))
                    {
                        quoteGroups.get(qli.quoteId).add(qli);
                    }
                    else
                    {
                        quoteGroups.put(qli.quoteId, new List<QuoteLineItem> { qli });
                    }
                }
                List<Quote> quotesToUpdate = new List<Quote>();
                for(List<QuoteLineItem> lineItems : quoteGroups.values())
                {
                    String contextId = lineItems[0].Id;
                    String methodName = 'Quote_ServiceTerm'; // Calling Vlocity Integration Procedure
                    String dataJson = '{"QLIId":"'+contextId+'"}}';
                    Map<String,Object> input = (Map<String,Object>) JSON.deserializeUntyped(dataJSON);
                    Map<String,Object> output = new Map<String,Object>();
                    Map<String,Object> options = new Map<String,Object>();
                    vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
                    integProcServ.invokeMethod(methodName, input, output, options);
                    System.debug('Quote_ServiceTerm Response: ' + JSON.serialize(output));

                }
            }
        }
        catch(Exception e) {
            System.debug('Exception Msg: ' + e.getMessage());
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw e;
        }
    }

}