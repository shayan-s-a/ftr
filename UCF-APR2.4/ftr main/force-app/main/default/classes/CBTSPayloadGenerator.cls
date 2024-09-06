global without sharing class CBTSPayloadGenerator implements vlocity_cmt.VlocityOpenInterface2 {
    global Object invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        try {
            system.debug('Enter CBTSPayloadGenerator.' + methodName);
            if (methodName == 'generatePayload') {
                generatePayload(input, output, options);
            }
            system.debug('Exit CBTSPayloadGenerator.' + methodName);
            return true;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex);
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw ex;
        }
    }
    
    public void generatePayload(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        Map<String, Object> data = (Map<String, Object>) input.get('data');
        Map<String, Object> sfOrder = (Map<String, Object>) data.get('SFOrder');
        List<Map<String, Object>> locationContacts = (List<Map<String, Object>>) sfOrder.get('LocationContact');
        Map<String, Map<String, Object>> saIdToContactDetails = new Map<String, Map<String, Object>>();
        for (Map<String, Object> locationContact : locationContacts) {
            saIdToContactDetails.put((String)locationContact.get('SAId'), locationContact);
        }
        String productPhysicalMedium;
        Map<String, Object> sfOrderDetails = (Map<String, Object>) sfOrder.get('SFOrderDetails');
        Map<String, Object> orderLineItems = (Map<String, Object>) sfOrderDetails.get('OrderLineItems');
        List<Map<String, Object>> orderItems = (List<Map<String, Object>>) orderLineItems.get('OrderItem');       
        for (Map<String, Object> orderItem : orderItems) {
            String productName= (String)((Map<String, Object>)orderItem.get('product')).get('productName');
            String saId = (String) orderItem.get('SAId');            
            if (saIdToContactDetails.containsKey(saId)) {
                Map<String, Object> contactDetails = saIdToContactDetails.get(saId);        
                orderItem.put('LocationContactTN', contactDetails.get('LocationContactTN'));
                orderItem.put('LocationContactEmail', contactDetails.get('LocationContactEmail'));
                orderItem.put('LocationContactName', contactDetails.get('LocationContactName'));
            }
            //assign the physical medium 
             if(productName.equals('User to Network Interface (UNI) Port')){
                productPhysicalMedium= (String)((Map<String, Object>)orderitem.get('product')).get('productPhysicalMedium');                  
             }   
            orderItem.remove('SAId');             
        }
        //Added Physical Medium Node to MNS product
        for(Integer i = 0; i < orderItems.size(); i++){
            Map<string, Object> orderitemNew =  orderItems[i];
            String productName= (String)((Map<String, Object>)orderitemNew.get('product')).get('productName');            
            if('User to Network Interface (UNI) Port'.equals(productName)){
                orderItems.remove(i);
                system.debug('orderItems@#@'+orderItems);
                --i;
            }
            if(productName.equals('MNS - Managed Dedicated Internet')){
               Map<String, Object> productMap=(Map<String, Object>)  orderItems[i].get('product');
               productMap.put('productPhysicalMedium', productPhysicalMedium);
            }        
        }
        sfOrder.remove('LocationContact');
        output.put('payload', data);
    }
}