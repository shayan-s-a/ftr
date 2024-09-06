public class ftr_QuoteTriggerHandler extends ftr_TriggerHandler {
	public static Boolean isFirstBeforeUpdate = true;
	public override void beforeInsert() {
		ftr_Logger.writeInfo('ftr_QuoteTriggerHandler.beforeInsert');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        
        /* code below introduced for hybrid opportunity 2020-07-30 */
		// check if quote should auto-sync
		if (Trigger.new.size() == 1) {
            Quote qt = (Quote) Trigger.new[0];
			// added qt.ftr_QuoteCreationStatus__c == null for PartnerPortal QQ creation.  QQ has a status of In Progress, all other quotes have this as NULL
            if (String.isNotBlank(qt.OpportunityId) && qt.ftr_QuoteCreationStatus__c == null) { 
                List<Quote> syncedQuote = new List<Quote>([SELECT Id FROM Quote WHERE OpportunityId=:qt.OpportunityId AND IsSyncing__c = true]);
                if (syncedQuote.size() < 1) {
                    Trigger.new[0].put('IsSyncing__c', true);
                }
            }
		}
	}
	public override void afterInsert() {
		ftr_Logger.writeInfo('ftr_QuoteTriggerHandler.afterInsert');
		ftr_Logger.writeVar('Trigger.new', Trigger.new);
	}

	public override void beforeUpdate() {
		ftr_Logger.writeInfo('ftr_QuoteTriggerHandler.beforeUpdate');
		ftr_Logger.writeVar('Trigger.new', Trigger.new);
		
		if (isFirstBeforeUpdate) {
			isFirstBeforeUpdate = false;
			ftr_QuoteService service = new ftr_QuoteService();
			service.setProductsFieldOnQuote((Map<Id, Quote>) Trigger.newMap, false);
			service.setRSMApprover((Map<Id, Quote>) Trigger.newMap, false);
			service.countLocationsOnQuote((Map<Id, Quote>) Trigger.newMap, false);
			// check if its an EasyPass Quote
			Id easyPassRecType = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('EasyPass_Quote').getRecordTypeId();
			if ((String) Trigger.new[0].get('RecordTypeId') == easyPassRecType || (Boolean) Trigger.new[0].get('ftr_IsBundle__c')) {
				service.automateQuoteName((Quote) Trigger.new[0], false);
			}
		}
	}
	public override void afterUpdate() {
		ftr_Logger.writeInfo('ftr_QuoteTriggerHandler.afterUpdate');
		ftr_Logger.writeVar('Trigger.new', Trigger.new);

		// Sync Term from Quote to QLIs. The logic only works on updating a single quote. If Quotes are updated in batch, the logic is skipped
		if (Trigger.new.size() == 1) {
			Quote oldQuote = (Quote) Trigger.old[0];
			Quote newQuote = (Quote) Trigger.new[0];
			if (oldQuote.Service_Term__c != newQuote.Service_Term__c) {
				// The Term is changed, fire the logic to propagate the new term value to QLIs
				ftr_QuoteService quoteSvs = new ftr_QuoteService();
				quoteSvs.updateTermForAllQLIs(newQuote.Id, newQuote.Service_Term__c);
			}

		}
	}

	public override void beforeDelete() {
		ftr_Logger.writeInfo('ftr_QuoteTriggerHandler.beforeDelete');
		ftr_Logger.writeVar('Trigger.old', Trigger.old);

	}
}