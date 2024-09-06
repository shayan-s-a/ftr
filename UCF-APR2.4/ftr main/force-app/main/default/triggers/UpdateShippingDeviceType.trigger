trigger UpdateShippingDeviceType on Shipping_Device__c (before insert) {
    // Collect the OrderProduct Ids associated with the Shipping Devices
    Set<Id> orderProductIds = new Set<Id>();
    
    for (Shipping_Device__c device : Trigger.new) {
        if (device.Order_Product__c != null) {
            orderProductIds.add(device.Order_Product__c);
        }
    }
    Map<Id, Id> mapOrderItemProduct2Id = new Map<Id, Id>();
    for(OrderItem orderItem: [SELECT id,orderid,vlocity_cmt__product2id__c FROM OrderItem WHERE Id = :orderProductIds]) {
        mapOrderItemProduct2Id.put(orderItem.vlocity_cmt__product2id__c, orderItem.Id);
    }
    
    Map<Id, String> mapOrderItemProductType = new Map<Id, String>();
    for(vlocity_cmt__CatalogProductRelationship__c catalogProduct : [SELECT Id,vlocity_cmt__product2id__c, vlocity_cmt__CatalogId__r.Name FROM vlocity_cmt__CatalogProductRelationship__c WHERE vlocity_cmt__Product2Id__c = :mapOrderItemProduct2Id.keySet()]) {
        mapOrderItemProductType.put(mapOrderItemProduct2Id.get(catalogProduct.vlocity_cmt__Product2Id__c), catalogProduct.vlocity_cmt__CatalogId__r.Name);   
    }

    for (Shipping_Device__c device : Trigger.new) {
        if (device.Order_Product__c != null && mapOrderItemProductType.containsKey(device.Order_Product__c)) {
            device.Device_Type__c = mapOrderItemProductType.get(device.Order_Product__c);
        }
    }
}