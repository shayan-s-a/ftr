trigger ValidateShippingInformation on ShippingInformation__c (before insert) {
    // Collect the Order IDs from the records being inserted
    Set<Id> orderIds = new Set<Id>();
    for (ShippingInformation__c info : Trigger.new) {
        orderIds.add(info.Order__c);
    }

    // Query for existing ShippingInformation__c records with the same Order IDs and Shipping Addresses
    Map<String, Id> existingAddressMap = new Map<String, Id>();
    for (ShippingInformation__c existingInfo : [
        SELECT Id, Order__c, Shipping_Address__c
        FROM ShippingInformation__c
        WHERE Order__c IN :orderIds
    ]) {
        String addressKey = existingInfo.Order__c + '-' + existingInfo.Shipping_Address__c;
        existingAddressMap.put(addressKey, existingInfo.Id);
    }

    // Check for duplicates and add errors
    for (ShippingInformation__c newInfo : Trigger.new) {
        String addressKey = newInfo.Order__c + '-' + newInfo.Shipping_Address__c;
        if (existingAddressMap.containsKey(addressKey)) {
            newInfo.addError('Error: Selected location already exists for the current Order.');
        }
    }
}