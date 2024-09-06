trigger FTRWSAddressTrigger on FTRWSAddress__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> addressIds = new Set<Id>();
        for (FTRWSAddress__c objAddress : Trigger.New) {
            if (Trigger.oldMap.get(objAddress.Id).Address_Lost_checkbox__c != objAddress.Address_Lost_checkbox__c) {
                addressIds.add(objAddress.Id);
            }
        }
        List<SterlingQuoteItem__c> quoteItemList = [SELECT Id, OpportunityId__c FROM SterlingQuoteItem__c WHERE ST_AddressID__c IN: addressIds];
        system.debug('quoteItemList ==> ' + quoteItemList);
        SterlingQuoteItemUtility.updateTotalCIACCharge(quoteItemList);
    }
}