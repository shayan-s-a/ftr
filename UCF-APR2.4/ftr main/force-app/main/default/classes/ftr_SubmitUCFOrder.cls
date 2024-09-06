public with sharing class ftr_SubmitUCFOrder {
    public void createTechnicalProduct(String orderId) {
        try {
            List<OrderItem> liOrderItems = [SELECT Id, Product_Name__c, Product2.Name, Product2.ProductCode, vlocity_cmt__ServiceAccountId__c FROM OrderItem WHERE OrderId = :orderId];
            
            Map<String, String> mapProductItemId = new Map<String, String>();
            Map<String, String> mapProductServAcc = new Map<String, String>();
            Map<String, String> mapID_DIDNumber = new Map<String, String>();
            
            for(OrderItem orderItem : liOrderItems) {
                mapProductItemId.put(orderItem.Product_Name__c, orderItem.Id);
                mapProductServAcc.put(orderItem.Product_Name__c, orderItem.vlocity_cmt__ServiceAccountId__c);
            }
            
            System.debug(mapProductItemId.keySet());
            
            List<ftr_DID_Location_Details__c> liLocationDetails = [SELECT Id, OrderId__c FROM ftr_DID_Location_Details__c WHERE OrderId__c = :orderId];
            
            List<ftr_DID_Number_Details__c> liNumbers = [SELECT Id, Ucf_Install_Type__c, Ucf_License_Type__c, Ucf_Device_Type__c, Ucf_Device_Accessories__c, DID_Number__c, DIDLocationDetailsId__c, Ucf_Number_Use__c, Ucf_Collaboration__c, Ucf_Webinar__c, Ucf_Audio_Mining__c, Ucf_Screen_Recording__c, Ucf_Storage__c, DIDLocationDetailsId__r.ServiceAccountId__r.Id FROM  ftr_DID_Number_Details__c WHERE MDN_Checkbox__c = false AND DIDLocationDetailsId__c IN :liLocationDetails];
            
            Map<String, List<ftr_DID_Number_Details__c>> mapNumberByType = new Map<String, List<ftr_DID_Number_Details__c>>();
            
            for(ftr_DID_Number_Details__c didNumber :liNumbers) {
                if(didNumber.Ucf_Number_Use__c != null && didNumber.Ucf_Number_Use__c != 'Toll Free' && didNumber.Ucf_Number_Use__c != 'Not Porting') {
                    if(mapNumberByType.containsKey(didNumber.Ucf_Number_Use__c)) {
                        List<ftr_DID_Number_Details__c> existingNumbers = mapNumberByType.get(didNumber.Ucf_Number_Use__c);
                        existingNumbers.add(didNumber);
                        mapNumberByType.put(didNumber.Ucf_Number_Use__c, existingNumbers);
                    } else {
                        List<ftr_DID_Number_Details__c> newNumbers = new List<ftr_DID_Number_Details__c>();
                        newNumbers.add(didNumber);
                        mapNumberByType.put(didNumber.Ucf_Number_Use__c, newNumbers);
                    }
                }
            }
            
            System.debug(mapNumberByType.keySet());
            
            List<ftr_DID_Number_Details__c> liNumberByPortInNewDid = new List<ftr_DID_Number_Details__c>();
            
            List<ftr_DID_Number_Details__c> liNumberAllOthers = new List<ftr_DID_Number_Details__c>();
            
            List<String> liNotUsableNo = new List<String>();
            liNotUsableNo.add('Toll Free');
            liNotUsableNo.add('Contact Center as a Service');
            liNotUsableNo.add('Not Porting');
            //liNotUsableNo.add('General Voice Mail');
            //liNotUsableNo.add('Multi-Line Hunt Group Pilot');
            
            List<String> usableNumberUse = new List<String>();
            for (List<ftr_DID_Number_Details__c> listValues : mapNumberByType.values()) {
                for (ftr_DID_Number_Details__c numberDetail : listValues) {
                    if(!liNotUsableNo.contains(numberDetail.Ucf_Number_Use__c)) {
                        /* if(numberDetail.Ucf_Number_Use__c != 'Toll Free' &&  numberDetail.Ucf_Number_Use__c != 'Contact Center as a Service' && numberDetail.Ucf_Number_Use__c != 'Not Porting') { */
                        if(numberDetail.Ucf_Install_Type__c == 'New DID Range' || numberDetail.Ucf_Install_Type__c == 'Port-In') {
                            liNumberByPortInNewDid.add(numberDetail);
                            mapID_DIDNumber.put(numberDetail.Id, numberDetail.Ucf_Install_Type__c);
                        } else {
                            liNumberAllOthers.add(numberDetail);  
                        }
                    }
                }
            }
            
            System.debug(liNumberByPortInNewDid);
            System.debug(liNumberAllOthers);
            
            // For PortIn New DiD numbers Only
            Map<String, List<ftr_DID_Number_Details__c>> segregatedRecords = new Map<String, List<ftr_DID_Number_Details__c>>();
            
            for (ftr_DID_Number_Details__c record : liNumberByPortInNewDid) {
                String key = (record.DIDLocationDetailsId__c != null ? record.DIDLocationDetailsId__c : '') +
                    (record.Ucf_Install_Type__c != null ? '_' + record.Ucf_Install_Type__c : '') +
                    (record.Ucf_Number_Use__c != null ? '_' + record.Ucf_Number_Use__c : '') +
                    (record.Ucf_License_Type__c != null ? '_' + record.Ucf_License_Type__c : '') +
                    (record.Ucf_Device_Type__c != null ? '_' + record.Ucf_Device_Type__c : '') +
                    (record.Ucf_Device_Accessories__c != null ? '_' + record.Ucf_Device_Accessories__c : '') +
                    (record.Ucf_Webinar__c != null ? '_' + record.Ucf_Webinar__c : '') +
                    (record.Ucf_Audio_Mining__c != null ? '_' + record.Ucf_Audio_Mining__c : '') +
                    (record.Ucf_Screen_Recording__c != null ? '_' + record.Ucf_Screen_Recording__c : '') +
                    (record.Ucf_Storage__c != null ? '_' + record.Ucf_Storage__c : '') +
                    (record.Ucf_Collaboration__c != null ? '_' + record.Ucf_Collaboration__c : '');
                
                System.debug(key);
                if (!segregatedRecords.containsKey(key)) {
                    if(key != null) {
                        segregatedRecords.put(key, new List<ftr_DID_Number_Details__c>());
                    }
                }
                segregatedRecords.get(key).add(record);
            }
            
            System.debug(segregatedRecords.keySet());
            
            Map<String, List<ftr_DID_Number_Details__c>> mapSegregatedList = new Map<String, List<ftr_DID_Number_Details__c>>();
            
            for (String key : segregatedRecords.keySet()) {
                List<ftr_DID_Number_Details__c> segregatedList = segregatedRecords.get(key);
                mapSegregatedList.put(key, segregatedList);
            }
            
            System.debug(mapSegregatedList.keySet());
            
            Map<String, List<ftr_DID_Number_Details__c>> segregatedOtherRecords = new Map<String, List<ftr_DID_Number_Details__c>>();
            
            for (ftr_DID_Number_Details__c record : liNumberAllOthers) {
                String key = /* (record.DIDLocationDetailsId__c != null ? record.DIDLocationDetailsId__c : '') +  */(record.Ucf_Number_Use__c != null ? record.Ucf_Number_Use__c : '') + (record.Ucf_Install_Type__c != null ? '_' + record.Ucf_Install_Type__c : '');
                
                if (!segregatedOtherRecords.containsKey(key)) {
                    segregatedOtherRecords.put(key, new List<ftr_DID_Number_Details__c>());
                }
                
                segregatedOtherRecords.get(key).add(record);
            }
            
            System.debug(segregatedOtherRecords.keySet());
            
            Map<String, List<ftr_DID_Number_Details__c>> mapOtherSegregatedList = new Map<String, List<ftr_DID_Number_Details__c>>();
            for (String key : segregatedOtherRecords.keySet()) {
                List<ftr_DID_Number_Details__c> segregatedList = segregatedOtherRecords.get(key);
                mapOtherSegregatedList.put(key, segregatedList);
            }
            
            System.debug(mapOtherSegregatedList.keySet());
            
            Product2 prod = [SELECT Id FROM Product2 WHERE ProductCode = 'UCF_DID_DPI_Services' LIMIT 1];
            PricebookEntry pricebookEntry = [SELECT Id,Product2Id,Pricebook2.Name FROM PricebookEntry WHERE Product2Id = :prod.Id];
            List<OrderItem> liOrderItemsInsert = new List<OrderItem>();
            List<Map<String, Object>> liItems = new List<Map<String, Object>>();
            
            List<Item> liItem = new List<Item>();
            
            for(List<ftr_DID_Number_Details__c> aggResult : mapSegregatedList.values()) {  
                Set<String> didNumberDetails = new Set<String>();
                Set<String> didOrderItems = new Set<String>();
                Map<String, Set<String>> mapKeyCount = new Map<String, Set<String>>();
                String servcAccId = '';
                for(ftr_DID_Number_Details__c numberDetail :aggResult) {
                    didNumberDetails.add(numberDetail.DID_Number__c);
                    servcAccId = numberDetail.DIDLocationDetailsId__r.ServiceAccountId__r.Id;
                    if(mapProductItemId.containsKey(numberDetail.Ucf_License_Type__c)){
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_License_Type__c)));
                    }
                    if(mapProductItemId.containsKey(numberDetail.Ucf_Device_Type__c)){
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_Device_Type__c)));
                    }
                    if(mapProductItemId.containsKey(numberDetail.Ucf_Device_Accessories__c)) {
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_Device_Accessories__c)));
                    }
                    // Ucf_Collaboration__c, Ucf_Webinar__c, Ucf_Audio_Mining__c, Ucf_Screen_Recording__c, Ucf_Storage__c
                    if(mapProductItemId.containsKey(numberDetail.Ucf_Collaboration__c)) {
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_Collaboration__c)));
                    }
                    if(mapProductItemId.containsKey(numberDetail.Ucf_Webinar__c)) {
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_Webinar__c)));
                    }
                    if(mapProductItemId.containsKey(numberDetail.Ucf_Audio_Mining__c)) {
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_Audio_Mining__c)));
                    }
                    if(mapProductItemId.containsKey(numberDetail.Ucf_Screen_Recording__c)) {
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_Screen_Recording__c)));
                    }
                    if(mapProductItemId.containsKey(numberDetail.Ucf_Storage__c)) {
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_Storage__c)));
                    }
                    
                }
                
                List<String> autoAttenNumberDetails = new List<String>(didNumberDetails);
                if(aggResult[0].Ucf_Number_Use__c == 'Auto Attendant') {
                    if(didNumberDetails.size() > 1) {
                        autoAttenNumberDetails.remove(0);
                    }
                }
                
                System.debug(didOrderItems);
                System.debug(didNumberDetails);
                
                String textIds = String.join(didOrderItems, ',');
                
                OrderItem techOrderItemBase = new OrderItem();
                techOrderItemBase.Quantity = 1;
                techOrderItemBase.UnitPrice = 0;
                techOrderItemBase.PricebookEntryId = pricebookEntry.Id;
                techOrderItemBase.OrderId = orderId;
                techOrderItemBase.vlocity_cmt__Product2Id__c = prod.Id;
                if(aggResult[0].Ucf_Number_Use__c == 'Auto Attendant') {
                    techOrderItemBase.UCF_DID_Numbers__c = String.join(autoAttenNumberDetails, ',');
                } else {
                    techOrderItemBase.UCF_DID_Numbers__c = String.join(didNumberDetails, ',');
                }
                techOrderItemBase.UCF_DID_Order_Items__c = textIds;
                techOrderItemBase.ftr_DIDLocationId__c = aggResult[0].DIDLocationDetailsId__c;
                techOrderItemBase.DID_Type__c = aggResult[0].Ucf_Number_Use__c + ':' + aggResult[0].Ucf_Install_Type__c;
                if(aggResult[0].Ucf_Number_Use__c == 'Auto Attendant') {
                    techOrderItemBase.DID_Numbers__c = Decimal.valueOf(autoAttenNumberDetails.size());
                } else {
                    techOrderItemBase.DID_Numbers__c = Decimal.valueOf(didNumberDetails.size());
                }
                
                techOrderItemBase.vlocity_cmt__ServiceAccountId__c = servcAccId;
                
                System.debug(techOrderItemBase);
                
                if(aggResult[0].Ucf_Number_Use__c == 'Auto Attendant') {
                    if(didNumberDetails.size() > 1) {
                        liOrderItemsInsert.add(techOrderItemBase);   
                    }
                } else {
                    liOrderItemsInsert.add(techOrderItemBase);   
                }
            }
            
            for(List<ftr_DID_Number_Details__c> aggResult : mapOtherSegregatedList.values()) {  
                Set<String> didNumberDetails = new Set<String>();
                Set<String> didOrderItems = new Set<String>();
                Set<String> orderServAcc = new Set<String>();
                
                String servcAccId = '';
                
                for(ftr_DID_Number_Details__c numberDetail :aggResult) {
                    servcAccId = numberDetail.DIDLocationDetailsId__r.ServiceAccountId__r.Id;
                    didNumberDetails.add(numberDetail.DID_Number__c);
                    if(mapProductItemId.containsKey(numberDetail.Ucf_License_Type__c)){
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_License_Type__c)));
                    }
                    if(mapProductItemId.containsKey(numberDetail.Ucf_Device_Type__c)){
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_Device_Type__c)));
                    }
                    if(mapProductItemId.containsKey(numberDetail.Ucf_Device_Accessories__c)) {
                        didOrderItems.add(String.valueOf(mapProductItemId.get(numberDetail.Ucf_Device_Accessories__c)));
                    }
                    
                    if(mapProductServAcc.containsKey(numberDetail.Ucf_License_Type__c)){
                        orderServAcc.add(String.valueOf(mapProductServAcc.get(numberDetail.Ucf_License_Type__c)));
                    }
                    if(mapProductServAcc.containsKey(numberDetail.Ucf_Device_Type__c)){
                        orderServAcc.add(String.valueOf(mapProductServAcc.get(numberDetail.Ucf_Device_Type__c)));
                    }
                    if(mapProductServAcc.containsKey(numberDetail.Ucf_Device_Accessories__c)) {
                        orderServAcc.add(String.valueOf(mapProductServAcc.get(numberDetail.Ucf_Device_Accessories__c)));
                    }
                    // Ucf_Collaboration__c, Ucf_Webinar__c, Ucf_Audio_Mining__c, Ucf_Screen_Recording__c, Ucf_Storage__c
                    if(mapProductServAcc.containsKey(numberDetail.Ucf_Collaboration__c)) {
                        orderServAcc.add(String.valueOf(mapProductServAcc.get(numberDetail.Ucf_Collaboration__c)));
                    }
                    if(mapProductServAcc.containsKey(numberDetail.Ucf_Webinar__c)) {
                        orderServAcc.add(String.valueOf(mapProductServAcc.get(numberDetail.Ucf_Webinar__c)));
                    }
                    if(mapProductServAcc.containsKey(numberDetail.Ucf_Audio_Mining__c)) {
                        orderServAcc.add(String.valueOf(mapProductServAcc.get(numberDetail.Ucf_Audio_Mining__c)));
                    }
                    if(mapProductServAcc.containsKey(numberDetail.Ucf_Screen_Recording__c)) {
                        orderServAcc.add(String.valueOf(mapProductServAcc.get(numberDetail.Ucf_Screen_Recording__c)));
                    }
                    if(mapProductServAcc.containsKey(numberDetail.Ucf_Storage__c)) {
                        orderServAcc.add(String.valueOf(mapProductServAcc.get(numberDetail.Ucf_Storage__c)));
                    }
                }
                
                System.debug(didOrderItems);
                System.debug(orderServAcc);
                System.debug(didNumberDetails);
                
                List<String> autoAttenNumberDetails = new List<String>(didNumberDetails);
                if(aggResult[0].Ucf_Number_Use__c == 'Auto Attendant') {
                    if(didNumberDetails.size() > 1) {
                        autoAttenNumberDetails.remove(0);
                    }
                }
                
                String textIds = String.join(didOrderItems, ',');
                
                OrderItem techOrderItemNon = new OrderItem();
                techOrderItemNon.Quantity = 1;
                techOrderItemNon.UnitPrice = 0;
                techOrderItemNon.PricebookEntryId = pricebookEntry.Id;
                techOrderItemNon.OrderId = orderId;
                techOrderItemNon.vlocity_cmt__Product2Id__c = prod.Id;
                if(aggResult[0].Ucf_Number_Use__c == 'Auto Attendant') {
                    techOrderItemNon.UCF_DID_Numbers__c = String.join(autoAttenNumberDetails, ',');
                } else {
                    techOrderItemNon.UCF_DID_Numbers__c = String.join(didNumberDetails, ',');
                }
                techOrderItemNon.UCF_DID_Order_Items__c = textIds;
                techOrderItemNon.ftr_DIDLocationId__c = aggResult[0].DIDLocationDetailsId__c;
                techOrderItemNon.DID_Type__c = aggResult[0].Ucf_Number_Use__c + ':' + aggResult[0].Ucf_Install_Type__c;
                if(aggResult[0].Ucf_Number_Use__c == 'Auto Attendant') {
                    techOrderItemNon.DID_Numbers__c = Decimal.valueOf(autoAttenNumberDetails.size());
                } else {
                    techOrderItemNon.DID_Numbers__c = Decimal.valueOf(didNumberDetails.size());
                }
                techOrderItemNon.vlocity_cmt__ServiceAccountId__c = servcAccId;
                
                System.debug(techOrderItemNon);
                if(aggResult[0].Ucf_Number_Use__c == 'Auto Attendant') {
                    if(didNumberDetails.size() > 1) {
                        //liOrderItemsInsert.add(techOrderItemNon);   
                    }
                } else {
                    //liOrderItemsInsert.add(techOrderItemNon);   
                }
            }
            
            System.debug(liOrderItemsInsert.size());
            
            if(liOrderItemsInsert.size() > 0) {
                insert liOrderItemsInsert;
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        
    }
    public static void updateOrderLineItems(String orderId) {
        // Fetch all order items related to the given order
        List<OrderItem> liOrderItems = [SELECT Id, Product_Name__c, vlocity_cmt__ServiceAccountId__c, UCF_DID_Order_Items__c, OrderId
                                        FROM OrderItem 
                                        WHERE OrderId = :orderId];
        
        List<ftr_DID_Number_Details__c> liNumbers = [SELECT Id, Name, Ucf_Device_Type__c, Ucf_Device_Accessories__c, Ucf_License_Type__c, Ucf_Collaboration__c, Ucf_Webinar__c, Ucf_Audio_Mining__c, Ucf_Screen_Recording__c, Ucf_Storage__c, DIDNumber__c,Ucf_Install_Type__c,Ucf_Number_Use__c,MDN_Checkbox__c,DIDLocationDetailsId__c,DIDLocationDetailsId__r.ServiceAccountId__c FROM ftr_DID_Number_Details__c WHERE DIDLocationDetailsId__r.OrderId__c  = :orderId AND MDN_Checkbox__c = true];
        
        Map<String, List<String>> SerIdNameMap = new Map<String, List<String>>();
        Map<String, String> SerIdDIDTypeNameMap = new Map<String, String>();
        Map<String, String> SerIdDIDNumber = new Map<String, String>();
        Map<String, String> SetDIDLocId = new Map<String, String>();
        Map<String, Set<String>> mapName = new Map<String, Set<String>>();
        
        
        for (ftr_DID_Number_Details__c numberDetail : liNumbers) {
            
            
            SerIdDIDTypeNameMap.put(numberDetail.DIDLocationDetailsId__r.ServiceAccountId__c, numberDetail.Ucf_Number_Use__c + ':' + numberDetail.Ucf_Install_Type__c);
            SerIdDIDNumber.put(numberDetail.DIDLocationDetailsId__r.ServiceAccountId__c,numberDetail.DIDNumber__c);
            List<String> names;
            If(numberDetail.Ucf_License_Type__c != null)
            {
                names = new List<String>{numberDetail.Ucf_License_Type__c, numberDetail.Ucf_Device_Type__c, numberDetail.Ucf_Device_Accessories__c, numberDetail.Ucf_Collaboration__c, numberDetail.Ucf_Webinar__c, numberDetail.Ucf_Audio_Mining__c, numberDetail.Ucf_Screen_Recording__c, numberDetail.Ucf_Storage__c};
                    SerIdNameMap.put(numberDetail.DIDLocationDetailsId__r.ServiceAccountId__c, names);
            }   
            
            SetDIDLocId.put(numberDetail.DIDLocationDetailsId__r.ServiceAccountId__c,numberDetail.DIDLocationDetailsId__c);
        }
        
        for (OrderItem oi : liOrderItems) {
            if (SerIdNameMap.containsKey(oi.vlocity_cmt__ServiceAccountId__c)) {
                List<String> ListOfDeviceInfo = SerIdNameMap.get(oi.vlocity_cmt__ServiceAccountId__c);
                for (String name : ListOfDeviceInfo) {
                    if (oi.Product_Name__c.equals(name)) {
                        if (!mapName.containsKey(oi.vlocity_cmt__ServiceAccountId__c)) {mapName.put(oi.vlocity_cmt__ServiceAccountId__c, new Set<String>());
                                                                                       }
                        mapName.get(oi.vlocity_cmt__ServiceAccountId__c).add(oi.Id);
                    }
                }
            }
        }
        
        // Convert Set to CSV
        Map<String, String> mapNameCSV = new Map<String, String>();
        for (String key : mapName.keySet()) {
            List<String> stringList = new List<String>(mapName.get(key));
            String csv = String.join(stringList, ',');
            mapNameCSV.put(key, csv);
        }
        
        List<OrderItem> ucfDC711OrderItems = [SELECT Id, UCF_DID_Order_Items__c, DID_Type__c,ftr_DIDLocationId__c, vlocity_cmt__ServiceAccountId__c, Product_Name__c FROM OrderItem WHERE Product_Name__c = 'UCF DC 711' AND OrderId =: orderId];
        
        for (OrderItem oi : ucfDC711OrderItems) {
            if (mapNameCSV.containsKey(oi.vlocity_cmt__ServiceAccountId__c)) {oi.UCF_DID_Order_Items__c = mapNameCSV.get(oi.vlocity_cmt__ServiceAccountId__c);}
            oi.DID_Type__c = SerIdDIDTypeNameMap.get(oi.vlocity_cmt__ServiceAccountId__c); oi.UCF_DID_Numbers__c =  SerIdDIDNumber.get(oi.vlocity_cmt__ServiceAccountId__c); oi.ftr_DIDLocationId__c = SetDIDLocId.get(oi.vlocity_cmt__ServiceAccountId__c);
        }
        
        
        if (!ucfDC711OrderItems.isEmpty()) {
            update ucfDC711OrderItems;
            System.debug('UCF DC 711 OrderItems updated successfully');
        } else {
            System.debug('No UCF DC 711 OrderItems to update');
        }
    }
    
    public class ItemWrapper {
        public List<Item> items;
        public Boolean price;
        public Boolean validate;
    }
    
    public class Item {
        public String ProductCode;
        public Map<String, String> attributesToUpdate;
        public Map<String, String> fieldsToUpdate;
        public String itemId;
    }
    
}