/**
 * @description       : class is for updating service order stage in bulk number
 * @author            : Yasin Khan
 * @version           : 1 
**/

global with sharing class BatchServiceOrderStageUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    private String sOrderStageExcluded = 'Completed';
    private String orderStageExcluded = 'Complete';
    private String orderStageExcluded2 = 'Cancelled';
    private String orderStageExcluded3 = 'New';
    private Date todaysDate = Date.today();
    private Date exactDate = todaysDate.addDays(-365);
    private Id devRecordTypeId = Schema.SObjectType.Service_Order__c.getRecordTypeInfosByName().get('M6 Service Order').getRecordTypeId();
    boolean exceptionFlag = false;
    public Map<String, String> listOfSOUpdated = new Map<String, String>();
    public Map<String, String> listOfSONotUpdated = new Map<String, String>();
    public Map<String, String> listOfSOWithExceptions = new Map<String, String>();
    public Integer count = 0;
    Public String s = '';
    
    public BatchServiceOrderStageUpdate() {

    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        String query = 'SELECT Id, Name'
                        +' From Service_Order__c'
                        +' WHERE RecordTypeId = :devRecordTypeId and CreatedDate >= :exactDate AND'
                        +' (Service_Order_Stage__c != :sOrderStageExcluded AND Order__r.Order_Stage__c != :orderStageExcluded AND'
                        +' Order__r.Order_Stage__c != :orderStageExcluded2 AND Order__r.Order_Stage__c != :orderStageExcluded3)';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Service_Order__c> sOrderList){
        String currentItem = '';
        String currentItemId = '';
        if(sOrderList.size() > 0) {
            try{
                for(Service_Order__c item : sOrderList) {
                    currentItem = item.Name;
                    currentItemId = item.Id;
                    Service_Order__c serviceOrder = ServiceOrderStage_Ctrl.updateOrderStage(item.Id, item.Name, true);
                    if(serviceOrder != null) {
                        listOfSONotUpdated.put(item.Id, item.Name);
                    } else {
                        listOfSOUpdated.put(item.Id, item.Name);
                    }
                }
            }catch(Exception e) {
                count++;
                listOfSOWithExceptions.put(currentItemId, currentItem);
                s = currentItem+'!'+e.getMessage();
                exceptionFlag = true;
            }
        }
    }

    global void finish(Database.BatchableContext BC){

        if(listOfSOUpdated.size() > 0) {
            CSVCreationForM6SOrderStageUpdate.createCsv(listOfSOUpdated, 'Updated');
        }

        if(listOfSONotUpdated.size() > 0) {
            CSVCreationForM6SOrderStageUpdate.createCsv(listOfSONotUpdated, 'Not Updated');
        }

        if(listOfSOWithExceptions.size() > 0) {
            CSVCreationForM6SOrderStageUpdate.createCsv(listOfSOWithExceptions, 'With Exception');
        }

        if(exceptionFlag) {
            System.debug('Exception occured for : '+count);
        }
    }
}