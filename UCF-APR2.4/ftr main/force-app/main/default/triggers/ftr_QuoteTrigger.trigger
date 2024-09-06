/*
 * @description added by Vlocity Jan 23, 2020
 * POC only to demo how the Service Term to be propagated to downstream lines
 */
trigger ftr_QuoteTrigger on Quote (before insert, after insert, before update, after update,before delete) {
    new ftr_QuoteTriggerHandler().run();
    // System.debug('QuoteTrigger');
    // Quote[] pQuotes = new List<Quote>();
    // for (Quote newQ : Trigger.New) {
    //     Quote oldQ = Trigger.oldMap.get(newQ.Id);
    //     if (newQ.Contract_Term__c != oldQ.Contract_Term__c) {
    //         // Service Term updated, needs to propagate to lines
    //         pQuotes.add(newQ);
    //     }
    // }
    // if (pQuotes.size() > 0) {
    //     vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
    //     Map<Id, Quote> qMap = new Map<Id, Quote>(pQuotes);
    //     System.debug('Quote Ids: ' + qMap.keySet());
    //     List<QuoteLineItem> qLIs = [SELECT Id, QuoteId, vlocity_cmt__JSONAttribute__c, vlocity_cmt__Product2Id__r.vlocity_cmt__JSONAttribute__c FROM QuoteLineItem WHERE QuoteId=:qMap.keySet()];
    //     for (QuoteLineItem qLI : qLIs) {
    //         Quote pQuote = qMap.get(qLI.QuoteId);
    //         System.debug(pQuote.Contract_Term__c);

    //         Map<String, Object> input = new Map<String, Object> {
    //             'objectSO' => null,
    //             'runTimeAttributesJSON' => qLI.vlocity_cmt__JSONAttribute__c,
    //             'originalAttributesJSON' => qLI.vlocity_cmt__Product2Id__r.vlocity_cmt__JSONAttribute__c,
    //             'JSONAttributeActionRequestList' => new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> {
    //                 new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_CONTRACT_TERM', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, pQuote.Contract_Term__c)
    //             }
    //         };
    //         Map<String, Object> output = new Map<String, Object>();
    //         Map<String, Object> options = new Map<String, Object>();
    //         jsonSupport.invokeMethod('applyAttributeActions', input, output, options);
    //         // The code below is supposed to run once for POCD
    //         qLI.vlocity_cmt__JSONAttribute__c = (String)output.get('modifiedJSON');
    //     }
    //     // Only reprice the first quote for POC
    //     CustomCart.priceCart(pQuotes[0].Id);
        
    //     System.debug(qLIs.size());
    //     update qLIs;

    // }
}