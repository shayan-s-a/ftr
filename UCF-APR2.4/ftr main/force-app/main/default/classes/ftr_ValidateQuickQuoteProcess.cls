global class ftr_ValidateQuickQuoteProcess implements vlocity_cmt.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        if (methodName == 'validQuickQuote') {
            String oppId = (String)inputMap.get('OpportunityId');
            if (oppId != null) {
                outputMap.put('result', validQuickQuote(oppId));
            }
        }

        return false;
    }

    global static Map<String, Object> validQuickQuote(String oppId) {
        Map<String, Object> out = new Map<String, Object>();

        out.put('notPDFCreate', false);
        out.put('notSynced', false);
        out.put('invalidQuote', false);
        out.put('invalidQuoteLineItem', false);

        // Valid the opportunity was Synced
        Opportunity Opportunity = [SELECT Id, Amount FROM Opportunity WHERE Id = :oppId WITH SECURITY_ENFORCED];
        if (Opportunity.Amount == 0 || Opportunity.Amount == null) {
            out.put('notSynced', true);
            // return out;
        }

        // Valid Opportunity have the quick quote pdf generated.
        List<ContentDocumentLink> cContentDoc = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :oppId WITH SECURITY_ENFORCED];
        if (cContentDoc.isEmpty()) {
            out.put('notPDFCreate', true);
            // return out;
        }

        // Valid at least one Quote not have quote lines.
        List<Quote> Quotes = [SELECT Id FROM Quote WHERE OpportunityId = :oppId WITH SECURITY_ENFORCED];
        if (Quotes.isEmpty()) {
            out.put('invalidQuote', true);
            // return out;
        }
        List<QuoteLineItem> qLines = [SELECT Id, QuoteId FROM QuoteLineItem WHERE QuoteId IN :Quotes WITH SECURITY_ENFORCED];
        if (qLines.isEmpty()) {
            out.put('invalidQuoteLineItem', true);
            // return out;
        } else {
            Map<Id, Integer> cantQLi = new Map<Id, Integer>();
            for (Quote q : Quotes) {
                cantQLi.put(q.Id, 0);
                for (QuoteLineItem qli : qLines) {
                    cantQLi.put(q.Id, cantQLi.get(q.Id) + 1);
                }
            }
            for (String line : cantQLi.keySet()) {
                if (cantQLi.get(line) == 0) {
                    out.put('invalidQuoteLineItem', true);
                    // return out;
                }
            }
        }
        return out;
    }
}