@isTest
private class ftr_ValidateQuickQuoteProcessTest {
    @isTest
    static void ftr_ValidateQuickQuoteProcessTest() {
        test.startTest();
        
        Map<String, String> inputMap = new Map<String, String>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        ftr_ValidateQuickQuoteProcess service = new ftr_ValidateQuickQuoteProcess();
        Boolean r = service.invokeMethod('validQuickQuote', inputMap, outputMap, options);
        System.assertEquals(false, r);

        List<Opportunity> opps = ftr_TestDataFactory.getOpportunities(1);
        insert opps;
        String oppId = '';
        for (Opportunity opp : opps) {
            oppId = opp.Id;
        }

        Map<String, Object> result = ftr_ValidateQuickQuoteProcess.validQuickQuote(oppId);
        for (String i : result.keySet()) {
            System.assertEquals(true, result.get(i));
        }

        List<QuoteLineItem> qli = ftr_TestDataFactory.getQLI(2, 1);
        insert qli;

        String qId;
        for (QuoteLineItem q : qli) {
            qId = q.QuoteId;
        }
        Quote quote = [SELECT Id, OpportunityId FROM Quote WHERE Id = :qId WITH SECURITY_ENFORCED LIMIT 1];
        oppId = quote.OpportunityId;

        result = ftr_ValidateQuickQuoteProcess.validQuickQuote(oppId);
        for (String i : result.keySet()) {
            if (i == 'invalidQuoteLineItem' || i == 'invalidQuote') {
                System.assertEquals(false, result.get(i));
            } else {
                System.assertEquals(true, result.get(i));
            }
        }

        test.stopTest();
    }
}