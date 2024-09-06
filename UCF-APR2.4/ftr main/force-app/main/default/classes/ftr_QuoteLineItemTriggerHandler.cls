/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-28-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 3.0   07-28-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class ftr_QuoteLineItemTriggerHandler extends ftr_TriggerHandler {

    public static Boolean isFirstBeforeUpdate = true;
    public static Boolean isFirstBeforeInsert = true;
    public static List<String>prodCodes = new List<String>{'ENT_ETH_EIA_0002','ENT_ETH_EIA_003','ENT_ETH_EVPL_0002','ENT_ETH_EVPL_0010','ENT_ETH_ELAN_0001'};

    public override void beforeInsert() {
        ftr_Logger.writeInfo('ftr_QuoteLineItemTriggerHandler.beforeInsert');
        System.debug('Trigger.new: '+ JSON.serialize(Trigger.new));
        ftr_QuoteService quoteSvs = new ftr_QuoteService();
        QuoteLineItem[] qLIs = new List<QuoteLineItem>();
        for (QuoteLineItem qLI : (List<QuoteLineItem>)Trigger.new) { // UCF Products have seperate Terms... exclude from this logic
            if (qLI.vlocity_cmt__JSONAttribute__c != null) {
                // The QLI is added by vlocity CPQ API
                qLIs.add(qLI);
            }
        }
        if (qLIs.size() > 0) {
            Quote parentQuote = [SELECT Id, Service_Term__c FROM Quote WHERE Id=:qLIs[0].QuoteId];
            quoteSvs.setTermForQLIs(parentQuote.Service_Term__c, qLIs);
            quoteSvs.populateTypeSubTypeAndFamily(qLIs); // Updated 9/23, Fausto Moussou @Nespon
            									         // This method populates the Type, Sub Type and Product Family values in the Quote Line Item. Re-using the 
            									         // existing filter to only affect Vlocity products
            quoteSvs.populateFieldToEvaluateLimitedExtensionOnInsert(qLIs);// Updated 10/11, Fausto Moussou @Nespon
            									                           // This method populates the RCLimitedExtensionCheck__c field to check for Limited Extension 
            									                           // device counts
        }

        // check messages
        if (ftr_CpqCartCtx.peekMessage('setChildServiceAccountField') != null) {
            Map<String, Object> message = ftr_CpqCartCtx.getMessage('setChildServiceAccountField');
            quoteSvs.setChildFieldOrAttributeFromParent(message, (List<QuoteLineItem>) Trigger.new, null);
        }
        if (ftr_CpqCartCtx.peekMessage('setChildTermField') != null) {
            Map<String, Object> message = ftr_CpqCartCtx.getMessage('setChildTermField');
            quoteSvs.setChildFieldOrAttributeFromParent(message, (List<QuoteLineItem>) Trigger.new, null);
        }
        if (ftr_CpqCartCtx.peekMessage('setChildTermAttribute') != null) {	
            Map<String, Object> message = ftr_CpqCartCtx.getMessage('setChildTermAttribute');	
            quoteSvs.setChildFieldOrAttributeFromParent(message, (List<QuoteLineItem>) Trigger.new, null);	
        }
        if (ftr_CpqCartCtx.peekMessage('setXLIAttributes') != null) {
            Map<String, Object> message = ftr_CpqCartCtx.getMessage('setXLIAttributes');
            quoteSvs.setXLIAttributes(message, (List<QuoteLineItem>) Trigger.new);
        }
        if (ftr_CpqCartCtx.peekMessage('prepareDSATAttrSync') != null) {
            Map<String, Object> cpqMessage = ftr_CpqCartCtx.getMessage('prepareDSATAttrSync');
            QuoteLineItem newQLI = (QuoteLineItem)Trigger.new[0];
            quoteSvs.syncDSATAttributes(newQLI.Id, newQLI);
        }
        if (isFirstBeforeInsert) {
            isFirstBeforeInsert = false;
            QuoteLineItemService.updateDsatStandardInterval(Trigger.New);
        }

    }

    public override void afterInsert() {
        ftr_Logger.writeInfo('ftr_QuoteLineItemTriggerHandler.afterInsert');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        
        if ((Boolean)Trigger.new[0].get('IsSyncing__c')) {
            QuoteSyncService.addInsertedQLIsForSync(Trigger.new);
            QuoteSyncService.sync(false);
        }
    }

    public override void beforeUpdate() {
        ftr_Logger.writeInfo('ftr_QuoteLineItemTriggerHandler.beforeUpdate');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);

        if ((Boolean)Trigger.new[0].get('ftr_isApplyDiscount__c') && (Trigger.new[0].get('Quantity') != Trigger.old[0].get('Quantity'))) {
            Trigger.new[0].addError('This item is part of a Bundle. You cannot change the Quantity.');
        }

        System.debug('Enter into ftr_QuoteLineItemTriggerHandler.beforeUpdate ' +  ftr_CpqAppHandlerHookImpl.debugLimits());

        ftr_CpqService service = new ftr_CpqService();
        ftr_QuoteService quoteSvs = new ftr_QuoteService();
        
        // Process prepareDSATAttrSync message published by ftr_CpqService.putCartsItems.PreInvoke method
        if (ftr_CpqCartCtx.peekMessage('prepareDSATAttrSync') != null) {
            Map<String, Object> cpqMessage = ftr_CpqCartCtx.getMessage('prepareDSATAttrSync');
            Id itemId = (Id)cpqMessage.get('itemId');

            if (Trigger.newMap.keySet().contains(itemId)) {
                QuoteLineItem newQLI = (QuoteLineItem)Trigger.newMap.get(itemId);
                quoteSvs.syncDSATAttributes(itemId, newQLI);
            }
        }

        ///check for partnered QLI speed updated
        QuoteLineItem currQli = (QuoteLineItem)Trigger.new[0];
        QuoteLineItem prevQli = (QuoteLineItem)Trigger.old[0];
        QuotelineItem currentQli = [Select Id,vlocity_cmt__Product2Id__r.ProductCode from QuotelineItem where Id=:Trigger.new[0].Id];
        if(currentQli != null && prodCodes.contains(currentQli.vlocity_cmt__Product2Id__r.ProductCode)){
                        Map<String,Object>oldQliattributevalues = ftr_CpqHelper.getJSONAttributeValues(prevQli.vlocity_cmt__JSONAttribute__c);
            Map<String,Object>newQliattributevalues = ftr_CpqHelper.getJSONAttributeValues(currQli.vlocity_cmt__JSONAttribute__c);
            Boolean partQnew = (boolean)newQliattributevalues.get('ATTR_ELIGBL_PARTNRD') !=null?(boolean)newQliattributevalues.get('ATTR_ELIGBL_PARTNRD'):false;
            system.debug('partQnew-->'+partQnew);
            String partQnewval = (String)newQliattributevalues.get('ATTR_PARTNER');
            Boolean partQold = (boolean)oldQliattributevalues.get('ATTR_ELIGBL_PARTNRD') !=null?(boolean)oldQliattributevalues.get('ATTR_ELIGBL_PARTNRD'):false;
            system.debug('partQold-->'+partQold);
            if(partQnew){
                    ftr_CpqCartCtx.addMessage('updatePartnerTier', new Map<String, Object> {
                        'cpqMethod' => 'putCartsItems.PreInvoke',
                        'quoteId' => currQli.QuoteId,
                        'itemId' => currQli.Id
                    });
            }
            if (currQli.vlocity_cmt__JSONAttribute__c != prevQli.vlocity_cmt__JSONAttribute__c) {
                String oldSpeed = (String)oldQliattributevalues.get(ftr_CpqService.AttribCode_SPEED);
                String newSpeed = (String)newQliattributevalues.get(ftr_CpqService.AttribCode_SPEED);
                String strVendorName;
                //Boolean partQ = partQnew;
                //System.debug('RN:::'+partQ);
                if(oldSpeed != newSpeed && partQnew){
                    ftr_CpqCartCtx.addMessage('updatepartnerNames', new Map<String, Object> {
                        'cpqMethod' => 'putCartsItems.PreInvoke',
                        'quoteId' => currQli.QuoteId,
                        'itemId' => currQli.Id
                    });
                }
                if(partQnew != partQold && !string.isBlank(newSpeed)){
                    if(partQnew){
                        quoteSvs.updatepartnerNames(newSpeed, currQli, false,true);
                    }else{
                        quoteSvs.updatepartnerNames(newSpeed, currQli, false,false);
                    }
                }
                if(partQnewval != null){
                    quoteSvs.updatePartnerTier(partQnewval, currQli, false,true);
                }
            }
        }
       


        // Process prepareSpeedRollup message published by ftr_CpqService.putCartsItems.PreInvoke method
        if (ftr_CpqCartCtx.peekMessage('prepareSpeedRollup') != null) {
            Map<String, Object> cpqMessage = ftr_CpqCartCtx.getMessage('prepareSpeedRollup');

            Id itemId = (Id)cpqMessage.get('itemId');

            if (Trigger.newMap.keySet().contains(itemId)) {
                QuoteLineItem oldQLI = (QuoteLineItem)Trigger.oldMap.get(itemId);
                QuoteLineItem newQLI = (QuoteLineItem)Trigger.newMap.get(itemId);
                Id parentItemId = (Id)cpqMessage.get('parentItemId');
                Id parentServiceAccountId = (Id)cpqMessage.get('parentServiceAccountId');
                Id quoteId = (Id)cpqMessage.get('quoteId'); 
                String productCode = (String)cpqMessage.get('itemProductCode');
                Map<String, List<Id>> rollupIdsMap = quoteSvs.getSpeedRollupQLIsOnQLIBeforeUpdate(oldQLI, newQLI, parentItemId, parentServiceAccountId, productCode);
                List<Id> evplIds = rollupIdsMap.get('EvplIds');
                //List<Id> accessIds = rollupIdsMap.get('AccessIds');
    
                if (evplIds.size() > 0 || Test.isRunningTest()) {
                    // Publish CPQ message for executing speed rollup for EVPLs
                    ftr_CpqCartCtx.addMessage('calculateEvplSpeedRollup', new Map<String, Object> {
                        'cpqMethod' => 'putCartsItems.PreInvoke',
                        'quoteId' => quoteId,
                        'itemIds' => evplIds
                    });
                }
                /*if (accessIds.size() > 0 || Test.isRunningTest()) {
                    // Publish CPQ message for executing speed rollup for Network Accesses
                    ftr_CpqCartCtx.addMessage('calculateAccessSpeedRollup', new Map<String, Object> {
                        'cpqMethod' => 'putCartsItems.PreInvoke',
                        'quoteId' => quoteId,
                        'itemIds' => accessIds
                    });
                }*/
            }
        }
        QuoteLineItemService.UpdateQuote((List<QuoteLineItem>) Trigger.new);

        System.debug('Exit into ftr_QuoteLineItemTriggerHandler.beforeUpdate ' +  ftr_CpqAppHandlerHookImpl.debugLimits());
        if (isFirstBeforeUpdate) {
            isFirstBeforeUpdate = false;
            QuoteLineItemService.updateDsatStandardInterval(Trigger.New);
        }

        // effective quantity needs to be set as the quantity because the bundle is not truley a bundle.. DID Number Included
        for (QuoteLineItem qLI : (List<QuoteLineItem>) Trigger.new) {
            if (qLI.Product_Family__c == 'SIP') {
                qLI.vlocity_cmt__EffectiveQuantity__c = qLI.Quantity;
            }
        }
    }

    public override void afterUpdate() {
        ftr_Logger.writeInfo('ftr_QuoteLineItemTriggerHandler.afterUpdate');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);

        if ((Boolean)Trigger.new[0].get('IsSyncing__c')) {
            QuoteLineItem[] syncQLIs = new List<QuoteLineItem>();
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                QuoteLineItem oldQLI = (QuoteLineItem)Trigger.old[i];
                QuoteLineItem newQLI = (QuoteLineItem)Trigger.new[i];
                if (QuoteSyncService.checkQLIForSync(oldQLI, newQLI)) {
                    syncQLIs.add(newQLI);
                }
            }
            if (syncQLIs.size() > 0) {
                QuoteSyncService.addUpdatedQLIsForSync(syncQLIs);
            }
            QuoteSyncService.sync(false);
        }
        ftr_QuoteService quoteSvs = new ftr_QuoteService();
        QuoteLineItem currQli = (QuoteLineItem)Trigger.new[0];
        QuoteLineItem prevQli = (QuoteLineItem)Trigger.old[0];
        if(currQli.vlocity_cmt__ServiceAccountId__c != prevQli.vlocity_cmt__ServiceAccountId__c ){
        list<quotelineitem> qlilist = [select id,vlocity_cmt__JSONAttribute__c,product2.ProductCode, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.Fiber_Tier__c from quotelineitem where quoteid = :(Id) currQli.get('quoteid')];
        quoteSvs.updateJurisdiction(currQli, qlilist);
        }
    }

    public override void beforeDelete() {
        if ((Boolean)Trigger.old[0].get('ftr_isApplyDiscount__c')) {
            Trigger.old[0].addError('This item is part of a bundled promotion and cannot be deleted.');
        }
        if ((Boolean)Trigger.old[0].get('IsSyncing__c')) {
            QuoteSyncService.addDeletedQLIsForSync(Trigger.old);
        }
        QuoteSyncService.sync(false);
    }

    public override void afterDelete() {
        ftr_Logger.writeInfo('ftr_QuoteLineItemTriggerHandler.afterDelete');
        ftr_Logger.writeVar('Trigger.old', Trigger.old);
        ftr_QuoteService quoteSvs = new ftr_QuoteService();        
        QuoteLineItem[] qLIs = new List<QuoteLineItem>();
        for (QuoteLineItem qLI : (List<QuoteLineItem>)Trigger.old) { // Checking for Vlocity Products
            if (qLI.vlocity_cmt__JSONAttribute__c != null) {
                // The QLI is added by vlocity CPQ API
                qLIs.add(qLI);
            }
        }
        if (qLIs.size() > 0) {
            quoteSvs.populateFieldToEvaluateLimitedExtensionOnDelete(qLIs);// Updated 10/11, Fausto Moussou @Nespon
            									                           // This method populates the RCLimitedExtensionCheck__c field to check for Limited Extension 
            									                           // device counts
        }
        // QuoteSyncService.sync(false);
    }

}