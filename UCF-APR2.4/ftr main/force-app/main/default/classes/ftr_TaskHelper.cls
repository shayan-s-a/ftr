public without sharing class ftr_TaskHelper {
    
    @AuraEnabled(cacheable=true)
    public static List<DataTableWrapper> getMDUQueueTasksForOpp(){
        List<DataTableWrapper> response = new List<DataTableWrapper>();
        List<Task> lstTasks = new List<Task>();
        try {
            List<Group> lstMDUTeamQueue = [SELECT Id 
                                       FROM Group 
                                       WHERE Type = 'Queue' 
                                       AND DeveloperNAME = 'MDU_Contract_Team_Queue'
                                       LIMIT 1];
            if(lstMDUTeamQueue.size() > 0){
                lstTasks = [SELECT Id, Subject, What.Name, Status, CreatedDate, Owner.Name
                            FROM Task
                            WHERE OwnerId =: lstMDUTeamQueue[0].Id
                            AND (Status = 'Open' OR Status = 'Not Started')
                            AND What.Type = 'Opportunity'
                            Order By CreatedDate Desc];

                for(Task tsk : lstTasks){
                    DataTableWrapper obj = new DataTableWrapper();
                    obj.tskId = tsk.Id;
                    obj.subject = tsk.Subject;
                    obj.nameUrl = '/' + tsk.Id;
                    obj.oppName = tsk.What.Name;
                    obj.status = tsk.Status;
                    obj.createdDate = tsk.CreatedDate;
                    obj.ownerName = tsk.Owner.Name;
                    response.add(obj);
                }
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return response;
    }

    public class DataTableWrapper {
        @AuraEnabled
        public Id tskId {get;set;}
        @AuraEnabled
        public String subject {get;set;}
        @AuraEnabled
        public String nameUrl {get;set;}
        @AuraEnabled
        public String oppName {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public Datetime createdDate {get;set;}
        @AuraEnabled
        public String ownerName {get;set;}
    }
}