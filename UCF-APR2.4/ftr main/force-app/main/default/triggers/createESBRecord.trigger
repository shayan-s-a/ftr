trigger createESBRecord on EsbEvent__e (after insert) {
    public class Indentities {
        public String key;
        public String value;
    }
    
    public class Oli {
        String externalId;
        String requisitionNumber;
        String purchaseOrderNumber;
        String purchaseOrderLine;
    }
    
    public class Header {
        public String name;
        public String domain;
        public String subType;
        public String source;
        public String priority;
        public String expiration;
        public String id;
        public String correlationId;
        public String timestamp;
        public String property;
    }
    
    public class Data {
        public String applicationName;
        public String referenceId;
        public List<Indentities> identification;
    }
    
    String infiniumRecordTypeID = Schema.getGlobalDescribe().get('Service_Order__c').getDescribe().getRecordTypeInfosByName().get('Infinium REQ').getRecordTypeId();
    for (EsbEvent__e event : Trigger.new) {
        if(event.source__c == 'InfiniumApi' && event.subtype__c == 'Notification') {
            List<Data> dataList = (List<Data>) JSON.deserialize(event.data__c, List<Data>.class);
            System.debug(dataList);
            List<Infinium_Order_Event__c> infiniumOrder = new List<Infinium_Order_Event__c>();
            List<Service_Order__c> liServOrder = new List<Service_Order__c>();
            if (dataList != null && !dataList.isEmpty()) {
                Data data = dataList[0];
                System.debug(data);
                if (data.identification != null && !data.identification.isEmpty()) {
                    if(data.identification.size() > 0) {
                        String projectId = '';
                        String referenceId = '';
                        List<Map<String, String>> liOliItems = new List<Map<String, String>>();
                        for(Indentities oli : data.identification) {
                            if(oli.key == 'OLI') {
                                liOliItems = (List<Map<String, String>>) JSON.deserialize(oli.value, List<Map<String, String>>.class);
                            }
                            if(oli.key == 'projectId') {
                                projectId = oli.value;
                            }
                            if(oli.key == 'referenceId') {
                                referenceId = oli.value;
                            }
                            
                            System.debug(liOliItems);
                        }
                        System.debug(projectId);
                        System.debug(referenceId);
                        System.debug(liOliItems);
                        List<String> orderIdreferenceId = referenceId.split('-');
                        Order orderId = [SELECT Id, OrderNumber FROM Order WHERE OrderNumber = :String.valueOf(orderIdreferenceId[0]) LIMIT 1];
                        
                        List<String> combRequisitionNumber = new List<String>();
                        List<String> combPurchaseOrderNumber = new List<String>();
                        
                        for(Map<String, String> oliItem : liOliItems) {
                            Infinium_Order_Event__c newObj = new Infinium_Order_Event__c();
                            newObj.projectId__c = projectId;
                            newObj.externalId__c = oliItem.get('externalId');
                            newObj.purchaseOrderLine__c = oliItem.get('purchaseOrderLine');
                            newObj.purchaseOrderNumber__c = oliItem.get('purchaseOrderNumber');
                            newObj.referenceId__c = referenceId;
                            newObj.requisitionNumber__c = oliItem.get('requisitionNumber');
                            combRequisitionNumber.add(oliItem.get('requisitionNumber'));
                            combPurchaseOrderNumber.add(oliItem.get('purchaseOrderNumber'));
                            infiniumOrder.add(newObj);
                        }
                        
                        Service_Order__c servOrder = new Service_Order__c();
                        servOrder.Name = referenceId;
                        if(orderId != null) {
                            servOrder.Order__c = orderId.Id;
                        }
                        servOrder.Order_Number__c = String.valueOf(orderIdreferenceId[0]);
                        servOrder.Description__c = 'projectId: ' + projectId;
                        servOrder.RecordTypeId = infiniumRecordTypeID;
                        servOrder.Infinium_Requisition_No__c = String.join(combRequisitionNumber, ',');
                        servOrder.Purchase_Order_Number__c = String.join(combPurchaseOrderNumber, ',');
                        
                        liServOrder.add(servOrder);
                    }
                }
            }
            if(infiniumOrder.size() > 0) {
                insert infiniumOrder;
            }
            if(liServOrder.size() > 0) {
                insert liServOrder;
            }
        }
    }
}