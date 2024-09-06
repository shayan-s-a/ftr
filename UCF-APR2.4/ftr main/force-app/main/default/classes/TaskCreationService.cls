/**
 * @description Service class to handle task creation 
 */
public class TaskCreationService {

    private static TaskCreationConfig__mdt[] taskCreationConfigs;
    static {
        if (Test.isRunningTest()) {
            taskCreationConfigs = new List<TaskCreationConfig__mdt> { new TaskCreationConfig__mdt(System__c='M6', RecordTypeDeveloperName__c='SF_Team_Task', Priority__c='Normal', QueueDeveloperName__c='Customer_Network_Provisioning') };
        } else {
            taskCreationConfigs = [
                SELECT Priority__c, AssignToUser__c, Subject__c, QueueDeveloperName__c, System__c, RecordTypeDeveloperName__c, ErrorCode__c 
                FROM TaskCreationConfig__mdt
            ];
        }
    }

    /**
     * @description: creates tasks based on criteria defined in TaskCreationConfig__mdt
     */
    public static void createTasks(Map<Id, API_Log__c> apiLogMap) {
        List<Task> tasksToInsert = new List<Task>();
        
        Map<String, String> nameToIdMap = TaskCreationService.getAssignToValues();

        for (API_Log__c log : apiLogMap.values()) {
            TaskCreationConfig__mdt config = TaskCreationService.getConfig(log.System__c, log.ErrorCode__c);

            if (config == null) continue;
            
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(config.RecordTypeDeveloperName__c).getRecordTypeId();
            String assignToName = config.QueueDeveloperName__c != null ? config.QueueDeveloperName__c : config.AssignToUser__c;
            
            // if it wasnt successful, create a task
            if (log.Status__c.toUpperCase() != 'SUCCESS') {
                tasksToInsert.add(
                    new Task(
                        Description = 'Callout Exception: ' + log.System__c + ', ' + log.Interface__c + '\r\n\r\n Error Code: ' + log.ErrorCode__c + '\r\n\r\n Error Message: \r\n' + log.ErrorMessage__c,
                        Subject = config.Subject__c != null ? config.Subject__c : log.Status__c + ' from ' + log.System__c + ' ' + log.Interface__c,
                        Priority = config.Priority__c,
                        WhatId = log.RelatedTo__c,
                        RecordTypeId = recordTypeId,
                        IsReminderSet = true,
                        OwnerId = nameToIdMap.get(assignToName)
                    )
                );
            }

        }
        System.debug('tasksToInsert -> '+JSON.serialize(tasksToInsert));
        Database.SaveResult[] srList = Database.insert(tasksToInsert, false);

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted task. Task ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Task fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    /**
     * @description: returns the task creation metadata that the log should use
     */
    public static TaskCreationConfig__mdt getConfig(String systemName, String errorCode) {
        TaskCreationConfig__mdt config;
        for (TaskCreationConfig__mdt obj : TaskCreationService.taskCreationConfigs) {
            if (obj.System__c == systemName && obj.ErrorCode__c == errorCode) {
                config = obj;
            }
        }
        return config;
    }

    /**
     * @description: queries the user and queue Ids for assigning the Tasks
     */
    public static Map<String, String> getAssignToValues() {
        Set<String> queueDevNames = new Set<String>();
        Set<String> userNames = new Set<String>();
        Map<String, String> nameToIdMap = new Map<String, String>();
        
        // if queue is null, use user
        for (TaskCreationConfig__mdt obj : TaskCreationService.taskCreationConfigs) {
            if (obj.QueueDeveloperName__c != null)
                queueDevNames.add(obj.QueueDeveloperName__c);
            else
                userNames.add(obj.AssignToUser__c);
        }
        if (userNames != null) {
            for (User u : [SELECT Id, UserName FROM User WHERE UserName IN :userNames]) {
                nameToIdMap.put(u.UserName, u.Id);
            }
        }
        if (queueDevNames != null) {
            for (Group q : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :queueDevNames]) {
                nameToIdMap.put(q.DeveloperName, q.Id);
            }
        }
        return nameToIdMap;
    }

}