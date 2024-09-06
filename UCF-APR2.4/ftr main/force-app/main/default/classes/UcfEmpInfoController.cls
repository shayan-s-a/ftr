public class UcfEmpInfoController {

        @AuraEnabled(cacheable=true)
public static List<order> ordetQuoteCounts(String orderId) {
    List<order> lstOrderCountValues = [SELECT 
                                        Id,
                                        quote.RCDeviceCount__c, 
                                        quote.RCLicenseCount__c 
                                        from 
                                        order
                                            where 
                                            id=:orderId];
    return lstOrderCountValues;
}



/*
    @AuraEnabled(cacheable=true)
public static List<String> getMDNOptions(String orderId) {
    List<String> mdnValues = new List<String>();
    for (ftr_DID_Location_Details__c detail : [
        SELECT MDN__c,UCFLocationMainPhoneNumber__c FROM ftr_DID_Location_Details__c WHERE OrderId__c = :orderId
    ]) {
        mdnValues.add(detail.UCFLocationMainPhoneNumber__c);
    }
    return mdnValues;
} */


    @AuraEnabled
public static List<String> getMDNOptions(String orderId) {
    List<String> mdnValues = new List<String>();
    for (Service_Location__c detail : [
        select id, Main_Phone_Number__c from Service_Location__c  WHERE Order__c = :orderId
    ]) {
        mdnValues.add(detail.Main_Phone_Number__c);
    }
    return mdnValues;
} 



@AuraEnabled(cacheable=true)
public static List<OrderItem> getOrderItemsBySubType(String orderId) {
return [
    SELECT Id, Product2.Name, Order_Product_Subtype__c, Product2.vlocity_cmt__SubType__c
    FROM OrderItem
    WHERE OrderId = :orderId
    AND Product2.vlocity_cmt__SubType__c IN ('Collaboration', 'Webinar', 'Call Recording')
];
}

@AuraEnabled
public static Boolean hasCallRecording(String orderId) {
    List<OrderItem> orderItems = [
        SELECT Id, Product2.Name, Order_Product_Subtype__c, Product2.vlocity_cmt__SubType__c
        FROM OrderItem
        WHERE OrderId = :orderId
        AND Product2.vlocity_cmt__SubType__c = 'Call Recording'
    ];
    return !orderItems.isEmpty();
}


    @AuraEnabled(cacheable=true)
public static Map<String, List<String>> getProductPicklistsBySubtype(String orderId) {
    Map<String, Object> result = new Map<String, Object>();
    Map<String, List<String>> productPicklists = new Map<String, List<String>>();
    Map<String, Integer> subtypeCounts = new Map<String, Integer>();
    // Initialize the picklist maps for the subtypes
    System.debug('empInfo ' + orderId);
    productPicklists.put('Collaboration', new List<String>());
    productPicklists.put('Webinar', new List<String>());
    productPicklists.put('Call Recording', new List<String>());
    
    
    // Query for OrderItems and related Products based on the Order Id
    List<OrderItem> orderItems = [SELECT Id, Product2.Name, Order_Product_Subtype__c ,product2.vlocity_cmt__SubType__c
                                    FROM OrderItem
                                    WHERE OrderId = :orderId
                                    AND  product2.vlocity_cmt__SubType__c  IN ('Collaboration', 'Webinar','Call Recording')];
                                    System.debug('orderItems '+ orderItems);
                                    //AND Order_Product_Subtype__c  IN ('Collaboration', 'Webinar')];
    // Loop through and categorize by Subtype
    for (OrderItem item : orderItems) {
        String subtype = item.product2.vlocity_cmt__SubType__c;
            if (subtype == 'Collaboration' || subtype == 'Webinar' || subtype =='Call Recording') {
        //if (subtype == 'Collaboration' || subtype == 'Webinar') {
            productPicklists.get(subtype).add(item.Product2.Name);
        }
    }
    return productPicklists;
}
    

@AuraEnabled(cacheable=true)
public static List<OrderItem> getLisenceAccessoriesPL(String orderId) {
Map<String, OrderItem> uniqueItems = new Map<String, OrderItem>();
for (OrderItem item : [
    SELECT Id, Product2.Name, Order_Product_Subtype__c, Product_Type__c
    FROM OrderItem 
    WHERE  OrderId = :orderId AND Product_Type__c IN ('Accessories', 'License')
]) {
    String key = item.Product_Type__c + '-' + item.Product2.Name;
    if (!uniqueItems.containsKey(key)) {
        uniqueItems.put(key, item);
    }
}
return uniqueItems.values();
}

@AuraEnabled(cacheable=true)
public static List<OrderItem> getDeviceTypes(String orderId) {
Map<String, OrderItem> uniqueItemsMap = new Map<String, OrderItem>();
for (OrderItem item : [
    SELECT Id, Product2.Name, Product2.vlocity_cmt__SpecificationSubType__c
    FROM OrderItem
    WHERE OrderId = :orderId AND Product2Id IN (SELECT Id FROM Product2 WHERE vlocity_cmt__SpecificationSubType__c IN ('Conference Models', 'poly phones', 'yealink phones','ATA'))
]) {
    uniqueItemsMap.put(item.Product2.Name, item);
}
return uniqueItemsMap.values();
}



    @AuraEnabled(cacheable=true)
public static Map<String, Object> getProductPicklistsAndCountsBySubtype(String orderId) {
    Map<String, Object> result = new Map<String, Object>();
    Map<String, Set<String>> productNames = new Map<String, Set<String>>();
    Map<String, Integer> subtypeCounts = new Map<String, Integer>();

    // Initialize for distinct product names and counts for the subtypes
    productNames.put('Webinar', new Set<String>());
    productNames.put('Collaboration', new Set<String>());
        productNames.put('Call Recording', new Set<String>());
    
    subtypeCounts.put('Webinar', 0);
    subtypeCounts.put('Collaboration', 0);
        subtypeCounts.put('Collaboration', 0);

    // Query for OrderItems and related Products based on the Order Id
    List<OrderItem> orderItems =  [SELECT Id, Product2.Name, Order_Product_Subtype__c ,product2.vlocity_cmt__SubType__c
                                    FROM OrderItem
                                    WHERE OrderId = :orderId
                                    AND  product2.vlocity_cmt__SubType__c  IN ('Collaboration', 'Webinar','Call Recording')];
    // Loop through OrderItems to populate names and counts
    for (OrderItem item : orderItems) {
        String subtype = item.product2.vlocity_cmt__SubType__c;
        if (subtype == 'Webinar' || subtype == 'Collaboration' ||subtype == 'Call Recording' ) {
            // Add to set for distinct names
            productNames.get(subtype).add(item.Product2.Name);
            // Increment the count for the subtype
            Integer currentCount = subtypeCounts.get(subtype);
            subtypeCounts.put(subtype, currentCount + 1);
        }
    }

    // Convert sets to lists for the picklists
    Map<String, List<String>> productPicklists = new Map<String, List<String>>();
    for (String subtype : productNames.keySet()) {
        productPicklists.put(subtype, new List<String>(productNames.get(subtype)));
    }

    // Add the picklists and counts to the result map
    result.put('picklists', productPicklists);
    result.put('counts', subtypeCounts);
    
    return result;
}

    @AuraEnabled
public static List<ftr_DID_Number_Details__c> getEmployeInformationDataForPM(String recordId) {
    List<ftr_DID_Number_Details__c> DIDNumberDetail = [SELECT Id,DIDNumber__c,
    Ucf_Extension__c,Ucf_Department__c,Ucf_Email__c,Ucf_License_Type__c,
    Ucf_Dial_Plan_Information__c,Ucf_Collaboration__c,
    Ucf_Webinar__c,Ucf_Call_Recording__c,Ucf_Audio_Mining__c,Ucf_User_Name__c,Ucf_User_Admin__c,
    Ucf_Screen_Recording__c,Ucf_Storage__c,Ucf_Customize_Extension__c,Ucf_Extension_Lenght__c,  
    Ucf_Device_Type__c,Ucf_Device_Accessories__c,Ucf_MAC_Address__c,EAS_Pin__c,
    DIDLocationDetailsId__r.OrderId__r.quote.RCLicenseCount__c,  
        Ucf_Company_Name__c,Ucf_Address_Number__c,Ucf_Street_Name__c,	Ucf_City__c,	
        Ucf_State__c,	Ucf_Zip_Code__c,Ucf_Identifying_Location__c 
        FROM ftr_DID_Number_Details__c 
        WHERE (Ucf_Number_Use__c='DID' 
        OR Ucf_Number_Use__c='Vacant/Spare' 
        OR Ucf_Number_Use__c='Contact Center as a Service' 
        OR Ucf_Number_Use__c='Toll Free' 
        OR Ucf_Number_Use__c='Not Porting')
        AND DIDLocationDetailsId__r.OrderId__c  =: recordId
        ];
    return DIDNumberDetail;
}


@AuraEnabled(cacheable=true)
public static Map<String, Integer> getQuantitiesForProductType(String orderId, String productType) {
    return buildQuantityMap([SELECT Quantity, Product2.Name FROM OrderItem WHERE OrderId = :orderId AND Product_Type__c = :productType]);
}

@AuraEnabled(cacheable=true)
public static Map<String, Integer> getQuantitiesForVlocitySubType(String orderId, String vlocitySubType) {
    return buildQuantityMap([SELECT Quantity, Product2.Name FROM OrderItem WHERE OrderId = :orderId 
    AND Product2.vlocity_cmt__SubType__c = :vlocitySubType ]);
}
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getQuantitiesForCallRecordingType(String orderId, String productName) {
        return buildQuantityMap([SELECT Quantity, Product2.Name FROM OrderItem WHERE OrderId = :orderId AND Product2.Name = :productName ]);
    } 
    //audio mining and screen recording start

        @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getQuantitiesForAudioMining(String orderId) {
    Set<String> audioMiningSet = new Set<String>();
            List<UCF_PM_Enrichment_Product__mdt> enrichmentProducts = [SELECT Product_Name__c, Type__c FROM UCF_PM_Enrichment_Product__mdt];
            for (UCF_PM_Enrichment_Product__mdt product : enrichmentProducts) {
         if (product.Type__c == 'Audio Mining') {
            audioMiningSet.add(product.Product_Name__c);
        } 
    }


        return buildQuantityMap([SELECT Quantity, Product2.Name FROM OrderItem WHERE OrderId = :orderId and Product2.Name IN: audioMiningSet]);
    } 

        @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getQuantitiesForScreenRecodring(String orderId) {
    Set<String> screenRecordingSet = new Set<String>();
            List<UCF_PM_Enrichment_Product__mdt> enrichmentProducts = [SELECT Product_Name__c, Type__c FROM UCF_PM_Enrichment_Product__mdt];
            for (UCF_PM_Enrichment_Product__mdt product : enrichmentProducts) {
        if (product.Type__c == 'Screen Record') {
            screenRecordingSet.add(product.Product_Name__c);
        }
    }
        return buildQuantityMap([SELECT Quantity, Product2.Name FROM OrderItem WHERE OrderId = :orderId and Product2.Name IN: screenRecordingSet]);
    } 
//audio mining and screen recording end
    
        /* 
@AuraEnabled(cacheable=true)
    public static Map<String, Object> getQuantitiesForCallRecordingType(String orderId, String productName) {
List<OrderItem> orderItems = [SELECT Quantity, Product2.Name FROM OrderItem WHERE OrderId = :orderId AND Product2.Name = :productName];

Map<String, Object> result = new Map<String, Object>();
// Assuming that there will be only one such product per order
if (!orderItems.isEmpty()) {
    OrderItem item = orderItems[0];
    result.put('productName', 'Yes'); // Replacing product name with "Yes"
    result.put('Quantity', item.Quantity);
} 

return result;
}

*/


@AuraEnabled(cacheable=true)
public static Map<String, Integer> getQuantitiesForSpecificationSubType(String orderId) {
    List<String> subTypes = new List<String>{'Conference Models', 'poly phones', 'yealink phones', 'ATA'};
    return buildQuantityMap([SELECT Quantity, Product2.Name FROM OrderItem WHERE OrderId = :orderId AND Product2Id IN (SELECT Id FROM Product2 WHERE vlocity_cmt__SpecificationSubType__c IN :subTypes)]);
}
private static Map<String, Integer> buildQuantityMap(List<OrderItem> orderItems) {
Map<String, Integer> resultMap = new Map<String, Integer>();
for (OrderItem item : orderItems) {
    String productName = item.Product2.Name;
    Integer quantityToAdd = (item.Quantity != null) ? item.Quantity.intValue() : 0;

    if (resultMap.containsKey(productName)) {
        // If the product already exists in the map, add the quantities together
        resultMap.put(productName, resultMap.get(productName) + quantityToAdd);
    } else {
        // If the product does not exist in the map, add it with its quantity
        resultMap.put(productName, quantityToAdd);
    }
}
return resultMap;
}

/*
private static Map<String, Integer> buildQuantityMap(List<OrderItem> orderItems) {
    Map<String, Integer> resultMap = new Map<String, Integer>();
    for (OrderItem item : orderItems) {
        String productName = item.Product2.Name;
        Integer quantity = (item.Quantity != null) ? item.Quantity.intValue() : 0;
        resultMap.put(productName, quantity);
    }
    return resultMap;
}
*/
    private static List<ProductQuantity> getAggregateResults(String soqlQuery) {
    List<ProductQuantity> productQuantities = new List<ProductQuantity>();
    List<AggregateResult> results = Database.query(soqlQuery);

    for (AggregateResult ar : results) {
        String prodName = (String)ar.get('prodName');
        Integer total = (Integer)ar.get('total');
        productQuantities.add(new ProductQuantity(prodName, total));
    }
        system.debug('test 0001 productQuantities ' + productQuantities);
    return productQuantities;
}

// Utility method to safely convert AggregateResult to Integer
private static Integer safeIntegerValue(Object value) {
    if (value != null) {
        Decimal d = (Decimal)value;
        return d.intValue();
    }
    return 0;
}
/*

@AuraEnabled
public static String getAggregateCounts(String orderId) {
    // Initialize sums to 0
    Integer deviceTypeSum = 0;
    Integer accessoriesSum = 0;
    Integer licenseSum = 0;
    Integer webinarSum = 0;
    Integer collaborationSum = 0;
    Integer callRecordingSum = 0;

    // Device Type Sum
    AggregateResult deviceTypeResult = [
        SELECT SUM(Quantity) total
        FROM OrderItem
        WHERE OrderId = :orderId AND Product2Id IN 
        (SELECT Id FROM Product2 WHERE vlocity_cmt__SpecificationSubType__c IN ('Conference Models', 'poly phones', 'yealink phones', 'ATA'))
    ];
    deviceTypeSum = safeIntegerValue(deviceTypeResult.get('total'));

    // Accessories Sum
    AggregateResult accessoriesResult = [
        SELECT SUM(Quantity) total
        FROM OrderItem
        WHERE OrderId = :orderId AND Product_Type__c = 'Accessories'
    ];
    accessoriesSum = safeIntegerValue(accessoriesResult.get('total'));

    // License Sum
    AggregateResult licenseResult = [
        SELECT SUM(Quantity) total
        FROM OrderItem
        WHERE OrderId = :orderId AND Product_Type__c = 'License'
    ];
    licenseSum = safeIntegerValue(licenseResult.get('total'));

    // Webinar Sum
    AggregateResult webinarResult = [
        SELECT SUM(Quantity) total
        FROM OrderItem
        WHERE OrderId = :orderId AND Product2.vlocity_cmt__SubType__c = 'Webinar'
    ];
    webinarSum = safeIntegerValue(webinarResult.get('total'));

    // Collaboration Sum
    AggregateResult collaborationResult = [
        SELECT SUM(Quantity) total
        FROM OrderItem
        WHERE OrderId = :orderId AND Product2.vlocity_cmt__SubType__c = 'Collaboration'
    ];
    collaborationSum = safeIntegerValue(collaborationResult.get('total'));

    // Call Recording Sum
    AggregateResult callRecordingResult = [
        SELECT SUM(Quantity) total
        FROM OrderItem
        WHERE OrderId = :orderId AND Product2.vlocity_cmt__SubType__c = 'Call Recording'
    ];
    callRecordingSum = safeIntegerValue(callRecordingResult.get('total'));

    // Serialize the sums to JSON
    OrderItemSums sums = new OrderItemSums(deviceTypeSum, accessoriesSum, licenseSum, webinarSum, collaborationSum, callRecordingSum);
    return JSON.serialize(sums);
}
*/

// Utility method to safely convert AggregateResult to Integer
    /*
private static Integer safeIntegerValue(Object value) {
    if (value != null) {
        Decimal d = (Decimal)value;
        return d.intValue();
    }
    return 0;
} */

// AuraEnabled method to get product types
@AuraEnabled(cacheable=true)
public static ProductTypeWrapper getProductTypes(String orderId) {
    // Query Custom Metadata
    system.debug('eee orderId: '+orderId);
    List<UCF_PM_Enrichment_Product__mdt> enrichmentProducts = [SELECT Product_Name__c, Type__c FROM UCF_PM_Enrichment_Product__mdt];

    // Create Sets for Each Type
    Set<String> storageSet = new Set<String>();
    Set<String> audioMiningSet = new Set<String>();
    Set<String> screenRecordingSet = new Set<String>();

    // Populate Sets
    for (UCF_PM_Enrichment_Product__mdt product : enrichmentProducts) {
        if (product.Type__c == 'Storage') {
            storageSet.add(product.Product_Name__c);
        } else if (product.Type__c == 'Audio Mining') {
            audioMiningSet.add(product.Product_Name__c);
        } else if (product.Type__c == 'Screen Record') {
            screenRecordingSet.add(product.Product_Name__c);
        }
    }
system.debug('eee storageSet '+ storageSet);
system.debug('eee audioMiningSet '+ audioMiningSet);
system.debug('eee screenRecordingSet '+ screenRecordingSet);
    // Instantiate Wrapper
    ProductTypeWrapper wrapper = new ProductTypeWrapper();
    boolean ucfStorageOneYearAdded = false;
        // Query OrderItem and Populate Wrapper
        for (OrderItem item : [SELECT Id, Product2Id, Product2.Name FROM OrderItem WHERE OrderId = :orderId]) {
            // String productName = item.Product2.Name.replaceAll('\\s+', ' ').trim(); // Removing extra spaces
            String productName = item.Product2.Name; // Removing extra spaces
            System.debug('eee Product name from query ' + productName);
        if (storageSet.contains(productName)) {
            wrapper.storage.add(productName);
        } 
        if (audioMiningSet.contains(productName)) {
            wrapper.audioMining.add(productName);
        }
            if (screenRecordingSet.contains(productName)) {
            wrapper.screenRecording.add(productName);
        }
          // Check for "ucf storage 1 year" and add if not already included
    if (!ucfStorageOneYearAdded && productName.equals('UCF Storage 1  Year') && !storageSet.contains(productName)) {
        wrapper.storage.add(productName);
        ucfStorageOneYearAdded = true; // Update flag to indicate it's been added
    }
    }
   // storageSet.add("UCF Storage 1  Year");
system.debug('eee wrapper '+ wrapper);

    return wrapper;
}

// Class to hold the sums
public class OrderItemSums {
    public Integer deviceTypeSum;
    public Integer accessoriesSum;
    public Integer licenseSum;
    public Integer webinarSum;
    public Integer collaborationSum;
    public Integer callRecordingSum;

    public OrderItemSums(Integer deviceTypeSum, Integer accessoriesSum, Integer licenseSum, Integer webinarSum, Integer collaborationSum, Integer callRecordingSum) {
        this.deviceTypeSum = deviceTypeSum;
        this.accessoriesSum = accessoriesSum;
        this.licenseSum = licenseSum;
        this.webinarSum = webinarSum;
        this.collaborationSum = collaborationSum;
        this.callRecordingSum = callRecordingSum;
    }
}


// Inner class to structure the product data
public class ProductTypeWrapper {
    @AuraEnabled public List<String> storage;
    @AuraEnabled public List<String> audioMining;
    @AuraEnabled public List<String> screenRecording;

    public ProductTypeWrapper() {
        storage = new List<String>();
        audioMining = new List<String>();
        screenRecording = new List<String>();
    }
}

    public class ProductQuantity {
    @AuraEnabled public String productName;
    @AuraEnabled public Integer quantity;

    public ProductQuantity(String productName, Integer quantity) {
        this.productName = productName;
        this.quantity = quantity;
    }
}








}