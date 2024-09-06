/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 29-09-2023
 * @last modified by  : 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 2.0   29-09-2023   Initial Version
**/
trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, after insert,
after update) {
    
    
TriggerDispatcher.Run(new ftr_OLITriggerHandler());

  if (Trigger.isInsert) {
    if (Trigger.isAfter) {
      Set<Id> setOLIId = new Set<Id>();
      for (OpportunityLineItem oli : Trigger.new) {
        setOLIId.add(oli.Id);
      }

      aps_VlocityQuoteHandler.processAttr_After(setOLIId);
    }
  }

  if (Trigger.isUpdate) {
    if (Trigger.isBefore) {
      aps_VlocityQuoteHandler.processAttr_Before(Trigger.new);
    }
  }
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for (OpportunityLineItem oli : Trigger.new) {
            OpportunityLineItem oldOli = Trigger.isUpdate ? Trigger.oldMap.get(oli.Id) : new OpportunityLineItem();
            if (oli.QuoteLineItem__c != null && (oli.vlocity_cmt__JSONAttribute__c != null && oli.vlocity_cmt__JSONAttribute__c != oldOli.vlocity_cmt__JSONAttribute__c)) {
                String attrPartner = (String)ftr_CpqHelper.getJSONAttributeValue(oli.vlocity_cmt__JSONAttribute__c, 'ATTR_PARTNER');
                oli.Partnered__c = String.isNotBlank(attrPartner) ? 'Yes' : 'No';
            }
        }
    }
}