public with sharing class ftr_FieldAssignmentSettingsController {

    @AuraEnabled
    public static List<SObject> getRecords(){
        try {
            return [
                SELECT Id, DeveloperName, MasterLabel, IsAutomationEnabled__c, ShouldCreateTask__c, 
                    ExcludedOrderStages__c, ExcludedRecordTypes__c, IncludedProductTypes__c, IncludedRecordTypes__c, QueueName__c
                FROM AutoFieldAssignmentSettings__mdt
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> saveRecord(String record){
        try {
            Map<String, Object> result = new Map<String, Object>();
            Map<String, Object> recordToUpdate = (Map<String, Object>) JSON.deserializeUntyped(record);
            MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
            metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
            metadataservice.SessionHeader.sessionId = getSessionIdFromVFPage();
            MetadataService.CustomMetadata mtdRecord = new MetadataService.CustomMetadata();
            mtdRecord.fullName = 'AutoFieldAssignmentSettings.' + String.valueOf(recordToUpdate.get('DeveloperName'));
            mtdRecord.label = String.valueOf(recordToUpdate.get('MasterLabel'));
            mtdRecord.values = new List<MetadataService.CustomMetadataValue>();
            recordToUpdate.remove('MasterLabel');
            recordToUpdate.remove('DeveloperName');
            recordToUpdate.remove('Id');
            for (String field : recordToUpdate.keySet()) {
                MetadataService.CustomMetadataValue customField = new MetadataService.CustomMetadataValue();
                customField.field = field;
                if (recordToUpdate.get(field) instanceof List<Object>) {
                    customField.value = String.join((List<Object>)recordToUpdate.get(field), ';');
                } else {
                    customField.value = String.valueOf(recordToUpdate.get(field));
                }
                mtdRecord.values.add(customField);
            }
            System.debug('mtdRecord: ' + JSON.serialize(mtdRecord));
            List<MetadataService.CustomMetadata> mtdRecords = new List<MetadataService.CustomMetadata>{mtdRecord};

            MetadataService.SaveResult[] srList;
            
            if (Test.isRunningTest()) {
                srList = new List<MetadataService.SaveResult> {
                    new MetadataService.SaveResult()
                };
                srList[0].success = true;
            } else {
                srList = metadataservice.updateMetadata(mtdRecords);
            }
            System.debug('srList: '+ JSON.serialize(srList));
            String message;
            if (!srList[0].success){
                message = srList[0].errors[0].message;
            }
            result.put('error', message);
            return result;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> getPicklistValues(){
        Map<String, Object> output = new Map<String, Object>();
        try {
            Schema.DescribeFieldResult status = Order.Order_Stage__c.getDescribe();
            List<Schema.PicklistEntry> statusValues = status.getPicklistValues();
            
            output.put('OrderStages', JSON.serialize(statusValues));

            List<Schema.PicklistEntry> allProductValues = new List<Schema.PicklistEntry>();
            Schema.DescribeFieldResult picklist = Order.Circuit_Product__c.getDescribe();
            allProductValues.addAll(picklist.getPicklistValues());
            
            picklist = Order.Product_Type__c.getDescribe();
            allProductValues.addAll(picklist.getPicklistValues());
            
            // picklist = Order.Product__c.getDescribe();
            // allProductValues.addAll(picklist.getPicklistValues());
            
            // picklist = Order.Add_On_Products__c.getDescribe();
            // allProductValues.addAll(picklist.getPicklistValues());
           
            // picklist = Order.Router_s__c.getDescribe();
            // allProductValues.addAll(picklist.getPicklistValues());
            
            output.put('Products', JSON.serialize(allProductValues));

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return output;
    }

    public static String getSessionIdFromVFPage() {
        if(Test.isRunningTest()) {
            return 'SESSION_ID';
        } else {
            String SESSION_ID_START = 'SESSION_ID_START';
            String SESSION_ID_END = 'SESSION_ID_END';
            String pageContent = Page.ftrSessionIdPage.getContent().toString();
            Integer startIndex = pageContent.indexOf(SESSION_ID_START) + SESSION_ID_START.length();
            Integer endIndex = pageContent.indexOf(SESSION_ID_END);
            return pageContent.substring(startIndex, endIndex);
        }
    }
}
