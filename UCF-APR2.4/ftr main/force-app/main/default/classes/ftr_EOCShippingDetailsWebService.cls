@RestResource(urlMapping='/EOCShippingDetails/*')
global with sharing class ftr_EOCShippingDetailsWebService {

     @HttpGet
    global static void getDPIOrder() {
        String orderNumber = RestContext.request.params.get('DPIOrderNumber');
        String envCode = RestContext.request.params.get('Envcode');
        Map<String, String> mapSneSku = new Map<String, String>();

        for (FTR_SNE_RC_ID__c sne_sku : [SELECT Id, Name, SKU_ID__c, SNE_ID__c FROM FTR_SNE_RC_ID__c]) {
            mapSneSku.put(sne_sku.SNE_ID__c, sne_sku.SKU_ID__c);
        }

        // Check if both parameters are provided and handle errors if not
        if (String.isBlank(orderNumber) || String.isBlank(envCode)) {
            RestResponse res = RestContext.response;
            res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf('Both DPIOrderNumber and Envcode parameters are required.');
            return;
        }

        List<Service_Order__c> serviceOrder = [SELECT Id, Name, Order__c FROM Service_Order__c WHERE Name = :orderNumber LIMIT 1];
        // Check if both parameters are provided and handle errors if not
        if (serviceOrder.size() > 0) {
            // Query ShippingInformation__c and related Shipping_Device__c records in a bulkified way
            List<ShippingInformation__c> shippingInfoList = [SELECT Id, Order__c, Street__c, City__c, State__c, Zip__c, Country__c,
                                                            (SELECT Id, Name, Type__c, Ship_Count__c, SNE__c FROM Shipping_Devices__r)
                                                            FROM ShippingInformation__c WHERE Order__c = :serviceOrder[0].Order__c];
            // Build the JSON response
            Map<String, Object> dpiOrder = new Map<String, Object>();
            Map<String, Object> shippingDetails = new Map<String, Object>();
            Map<String, Object> mapshippingItemDetails = new Map<String, Object>();

            shippingDetails.put('DPIOrderNumber', orderNumber);

            List<Object> shippingItemDetails = new List<Object>();
            for (ShippingInformation__c shippingInfo : shippingInfoList) {
                Map<String, Object> shippingItem = new Map<String, Object>();
                Map<String, Object> shippingAddress = new Map<String, Object>();
                shippingAddress.put('street', shippingInfo.Street__c);
                shippingAddress.put('city', shippingInfo.City__c);
                shippingAddress.put('state', shippingInfo.State__c);
                shippingAddress.put('country', shippingInfo.Country__c);
                shippingAddress.put('zip', shippingInfo.Zip__c);
                shippingItem.put('shippingAddress', shippingAddress);

                List<Object> devices = new List<Object>();
                for (Shipping_Device__c device : shippingInfo.Shipping_Devices__r) {
                    if(device.Ship_Count__c > 0) {
                        Map<String, Object> deviceInfo = new Map<String, Object>();
                        deviceInfo.put('quantity', String.valueOf(device.Ship_Count__c));
                        deviceInfo.put('skuId', String.valueOf(mapSneSku.get(device.SNE__c)));
                        devices.add(deviceInfo);
                    }
                }
                shippingItem.put('devices', devices);
                shippingItemDetails.add(shippingItem);
            }

            shippingDetails.put('shippingDetails', mapshippingItemDetails);
            mapshippingItemDetails.put('shippingItemDetails', shippingItemDetails);
            dpiOrder.put('DPIOrder' , shippingDetails);

            // Serialize the map to JSON and return the response
            String jsonResponse = JSON.serialize(dpiOrder);
            RestResponse res = RestContext.response;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(jsonResponse);
        } else {
            RestResponse res = RestContext.response;
            res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf('Order does not exist for DPIOrderNumber: ' + orderNumber);
            return;
        }
    }
}