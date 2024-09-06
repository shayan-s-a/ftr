/**
 * @description Service class to handle the Quote to Opportunity Sync
 *              Always one way sync from Quote to Opportunity
 * @version 1
 */
public with sharing class QuoteSyncService {
    public static final String DelayByVlocityCpqApi = 'DelayByVlocityCpqApi';
    private static Boolean delaySyncPrcess = false;
    private static String delaySyncReason;

    private static Quote quoteForSync;
    private static Quote quoteForUnsync;

    private static Map<Id, QuoteLineItem> updatedQLIsForSync = new Map<Id, QuoteLineItem>();
    private static Map<Id, QuoteLineItem> insertedQLIsForSync = new Map<Id, QuoteLineItem>();
    private static Map<Id, QuoteLineItem> deletedQLIsForSync = new Map<Id, QuoteLineItem>();

    private static vlocity_cmt__CustomFieldMap__c[] quoteSyncFieldMaps;
    static {
        quoteSyncFieldMaps = new List<vlocity_cmt__CustomFieldMap__c>();
        for (vlocity_cmt__CustomFieldMap__c fMap : vlocity_cmt__CustomFieldMap__c.getAll().values()) {
            if (fMap.vlocity_cmt__SourceSObjectType__c == 'QuoteLineItem' && fMap.vlocity_cmt__DestinationSObjectType__c == 'OpportunityLineItem') {
                quoteSyncFieldMaps.add(fMap);
            }
        }
    }


    public static void DelaySyncProcess(String reason) {
        QuoteSyncService.delaySyncPrcess = true;
        QuoteSyncService.delaySyncReason = reason;
    }

    public static void addInsertedQLIsForSync(QuoteLineItem[] syncQLIs) {
        insertedQLIsForSync.putAll(new Map<Id, QuoteLineItem>(syncQLIs));
    }

    public static void addUpdatedQLIsForSync(QuoteLineItem[] syncQLIs) {
        updatedQLIsForSync.putAll(new Map<Id, QuoteLineItem>(syncQLIs));
    }

    public static void addDeletedQLIsForSync(QuoteLineItem[] syncQLIs) {
        deletedQLIsForSync.putAll(new Map<Id, QuoteLineItem>(syncQLIs));
    }

    /**
     * 
     */
    private static OpportunityLineItem syncQuoteLineItemToOLI(QuoteLineItem quoteLineItem, OpportunityLineItem oppLineItem) {
        try {
            String termStr = (String)ftr_CpqHelper.getJSONAttributeValue(quoteLineItem.vlocity_cmt__JSONAttribute__c, 'ATTR_CONTRACT_TERM');
            if (termStr != null) oppLineItem.Term_Months__c = Integer.valueOf(termStr.substringBefore(' '));
        } catch (Exception ex) {
            System.debug('No term for QLI ' + quoteLineItem.Id);
        }
        
		for (vlocity_cmt__CustomFieldMap__c fieldmap : quoteSyncFieldMaps) {
            if (oppLineItem.Id != null && fieldmap.vlocity_cmt__DestinationFieldName__c == 'PricebookEntryId') {
                // For update, skip the listed fields because they are not editable
                continue;
            }
			if (quoteLineItem.get(fieldmap.vlocity_cmt__SourceFieldName__c) != null && quoteLineItem.get(fieldmap.vlocity_cmt__SourceFieldName__c) != '') {
				oppLineItem.put(fieldMap.vlocity_cmt__DestinationFieldName__c, quoteLineItem.get(fieldmap.vlocity_cmt__SourceFieldName__c));
			} else if (fieldmap.vlocity_cmt__DestinationFieldName__c == 'UnitPrice') {
				// this is added to ensure required field is filled.
				oppLineItem.put(fieldMap.vlocity_cmt__DestinationFieldName__c, 0.00);
			}
           
        }
        return oppLineItem;
    }


    /**
     * @description check if the update QLI need to be synced based on the Field Mapping
     */
    public static Boolean checkQLIForSync(QuoteLineItem beforeQLI, QuoteLineItem afterQLI) {
        system.debug('afterupdatecheckQLIForSync');
        for (vlocity_cmt__CustomFieldMap__c fMap : quoteSyncFieldMaps) {
            String fName = fMap.vlocity_cmt__SourceFieldName__c;
            if (beforeQLI.get(fName) != afterQLI.get(fName)) {
                return true;
            }
        }
        return false;
    }
    /**
     * 
     */
    public static Set<Id> getQuoteLineItemIdsByQuote(Id quoteId) {
        Map<Id, QuoteLineItem> qlis = new Map<Id, QuoteLineItem>([SELECT id FROM QuoteLineItem WHERE QuoteId = :quoteId]);
        return qlis.keySet();
    }
   
    /**
     * @description if forceSync is true, it will ignore the delaySyncProcess flag and always sync 
     */
    public static Map<String, Object> Sync(Boolean forceSync) {
        Map<String, Object> result = new Map<String, Object> {
            'error' => 'OK',
            'message' => ''
        };

        if (delaySyncPrcess && !forceSync) {
            // Sync is delayed
            result.put('message', 'Sync is delayed because of ' + delaySyncReason);
        } else if (updatedQLIsForSync.size() == 0 && insertedQLIsForSync.size() == 0 && deletedQLIsForSync.size() == 0) {
            result.put('message', 'No changes need to be synced.');
        } else {
            System.debug('Perf - QuoteSyncSerivce.Sync Start - ' + ftr_CpqAppHandlerHookImpl.debugLimits());
            // System.debug('updatedQLIsForSync: ' + JSON.serialize(updatedQLIsForSync.keySet()));
            // System.debug('insertedQLIsForSync: ' + JSON.serialize(insertedQLIsForSync.keySet()));
            // System.debug('deletedQLIsForSync: ' + JSON.serialize(deletedQLIsForSync.keySet()));


            Set<Id> qLIIds = new Set<Id>();
            qLIIds.addAll(updatedQLIsForSync.keySet());
            qLIIds.addAll(deletedQLIsForSync.keySet());
            

            OpportunityLineItem[] oLIsToInsert = new List<OpportunityLineItem>();
            
            for (QuoteLineItem qLI : insertedQLIsForSync.values()) {
                system.debug('insertedQLIsForSyncvishal'+insertedQLIsForSync.values());
                OpportunityLineItem oLI = new OpportunityLineItem(OpportunityId = qLI.OpportunityId__c, Quantity = 1, UnitPrice = 0.00);
                syncQuoteLineItemToOLI(qLI, oLI);
                oLIsToInsert.add(oLI);
            }
             Savepoint sp = Database.setSavepoint();

            try{
                  if (oLIsToInsert.size() > 0) insert oLIsToInsert; 

            }
            catch (Exception ex) {
                ftr_Logger.write(ex);
                result.put('message', ex.getMessage());
                Database.rollback(sp);
            }
            
            OpportunityLineItem[] oLIsToUpdate = new List<OpportunityLineItem>();
            OpportunityLineItem[] oLIsToDelete = new List<OpportunityLineItem>();
            for (OpportunityLineItem oLI : [SELECT Id, QuoteLineItem__c FROM OpportunityLineItem WHERE QuoteLineItem__c IN :qLIIds]) {
                QuoteLineItem updatedQLI = updatedQLIsForSync.get(oLI.QuoteLineItem__c);
                if (updatedQLI != null) {
                    syncQuoteLineItemToOLI(updatedQLI, oLI);
                    oLIsToUpdate.add(oLI);
                } else {
                    oLIsToDelete.add(oLI);
                } 
            } 

         /*   for (QuoteLineItem qLI : insertedQLIsForSync.values()) {
                system.debug('insertedQLIsForSyncvishal'+insertedQLIsForSync.values());
                OpportunityLineItem oLI = new OpportunityLineItem(OpportunityId = qLI.OpportunityId__c, Quantity = 1, UnitPrice = 0.00);
                syncQuoteLineItemToOLI(qLI, oLI);
                oLIsToInsert.add(oLI);
            }*/

            try {
                if (oLIsToUpdate.size() > 0) update oLIsToUpdate;
                if (oLIsToDelete.size() > 0) delete oLIsToDelete;

                oLIsToUpdate.clear();
                oLIsToDelete.clear();
                oLIsToInsert.clear();
            } 
            catch (Exception ex) {
                ftr_Logger.write(ex);
                result.put('message', ex.getMessage());
                Database.rollback(sp);
            }
            System.debug('Perf - QuoteSyncSerivce.Sync Finish - ' + ftr_CpqAppHandlerHookImpl.debugLimits());
        }

        System.debug('Perf - QuoteSyncSerivce.sync: ' + JSON.serialize(result));
        return result;
    }

    
    /**
     * @description Sync for a new Quote
     */
    public static Map<String, Object> Sync(Quote quoteToSync) {
        Map<String, Object> result = new Map<String, Object> {
            'error' => 'OK',
            'message' => ''
        };

        Quote quoteToUnsync;
        OpportunityLineItem[] oLIsToDelete = new List<OpportunityLineItem>();

        Quote[] currentSyncedQuotes = [SELECT Id, OpportunityId, IsSyncing__c FROM Quote WHERE IsSyncing__c=True AND OpportunityId=:quoteToSync.OpportunityId];
        if (currentSyncedQuotes.size() > 0) {
            quoteToUnsync = currentSyncedQuotes[0];
        }

        if (quoteToUnsync != null && quoteToSync.Id == quoteToUnsync.Id) {
            // Do nothing
            result.put('message', 'The selected quote is in syncing already.');
        } else {
            
            if (quoteToUnsync != null) {
                Set<Id> qLIIds = getQuoteLineItemIdsByQuote(quoteToUnsync.Id);
                oLIsToDelete = [SELECT Id FROM OpportunityLineItem WHERE QuoteLineItem__c IN :qLIIds];
            }
            
            Set<String> qLIFNames = new Set<String> { 'vlocity_cmt__JSONAttribute__c'.toLowerCase(), 'OpportunityId__c'.toLowerCase() };
            for (vlocity_cmt__CustomFieldMap__c fMap : quoteSyncFieldMaps) {
                qLIFNames.add(fMap.vlocity_cmt__SourceFieldName__c.toLowerCase());
            }

            Id quoteToSyncId = quoteToSync.Id;
            String query = 'SELECT ' + String.join(new List<String>(qLIFNames), ',') + ' FROM QuoteLineItem WHERE QuoteId=:quoteToSyncId';
            QuoteLineItem[] qLIs = Database.query(query);

            OpportunityLineItem[] oLIsToInsert = new List<OpportunityLineItem>();
            for (QuoteLineItem qLI : qLIs) {
                OpportunityLineItem oLI = new OpportunityLineItem(OpportunityId = quoteToSync.OpportunityId, Quantity = 1, UnitPrice = 0.00);
                syncQuoteLineItemToOLI(qLI, oLI);
                oLIsToInsert.add(oLI);
            }

            Quote[] quotesToUpdate = new List<Quote> { new Quote(
                    Id = quoteToSync.Id,
                    IsSyncing__c = true
                )
            };
            if (quoteToUnsync != null) {
                quotesToUpdate.add(new Quote(
                    Id = quoteToUnsync.Id,
                    IsSyncing__c = false
                ));
            }

            Savepoint sp = Database.setSavepoint();
            try {
                update quotesToUpdate;
                if (oLIsToDelete.size() > 0) delete oLIsToDelete;
                if (oLIsToInsert.size() > 0) insert oLIsToInsert; 
            } catch (Exception ex) {
                ftr_Logger.write(ex);
                result.put('message', ex.getMessage());
                result.put('error', 'ERR');
                Database.rollback(sp);
            }
            
        }

        System.debug('QuoteSyncSerivce.Sync Result: ' + JSON.serialize(result));
        return result;
    }

 
    /**
     * 
     */
    public static Map<String, Object> Unsync(Quote quoteToUnsync) {
        Map<String, Object> result = new Map<String, Object> {
            'error' => 'OK',
            'message' => ''
        };
        
        Set<Id> qLIIds = getQuoteLineItemIdsByQuote(quoteToUnsync.Id);
        OpportunityLineItem[] oLIsToDelete = [SELECT Id FROM OpportunityLineItem WHERE QuoteLineItem__c IN :qLIIds];
        quoteToUnsync.IsSyncing__c = false;

        Savepoint sp = Database.setSavepoint();
        try {
            update quoteToUnsync;
            if (oLIsToDelete.size() > 0) delete oLIsToDelete;
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            result.put('message', ex.getMessage());
            Database.rollback(sp);
        }
        return result;
    }
}