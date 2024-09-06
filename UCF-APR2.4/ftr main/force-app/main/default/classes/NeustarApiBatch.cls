public class NeustarApiBatch implements Database.Batchable<sObject>,Database.stateful,Database.AllowsCallouts{
    
    public String callingLocation = '';
    public NeustarApiBatch(String callingLocation){
        this.callingLocation = callingLocation;
    }
    
    public static void removeJobNewUpdatedAccount(){
        try{
            List<CronTrigger> lstCronTrigger = [SELECT Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name = 'NeustarApiBatch Job:NewUpdatedAccount'];
            if(lstCronTrigger.size() > 0) system.abortJob(lstCronTrigger[0].Id);
        }catch(Exception ee){
            system.debug('error : '+ee.getMessage());
        }
    }
    public static void scheduleJobNewUpdatedAccount(){  
        try{
            String sch = '0 0 22 * * ? *';
            List<CronTrigger> lstCronTrigger = [SELECT Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name = 'NeustarApiBatch Job:NewUpdatedAccount'];
            if(lstCronTrigger.size() == 0 && !Test.isRunningTest()) String jobID = system.schedule('NeustarApiBatch Job:NewUpdatedAccount', sch, new NeustarApiSch('NewUpdatedAccount'));
        }catch(Exception ee){
            system.debug('error : '+ee.getMessage());
        }
    }
    
    public static void removeJobExistingND(){
        try{
            List<CronTrigger> lstCronTrigger = [SELECT Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name = 'NeustarApiBatch Job:ExistingND'];
            if(lstCronTrigger.size() > 0) system.abortJob(lstCronTrigger[0].Id);
        }catch(Exception ee){
            system.debug('error : '+ee.getMessage());
        }
    }
    public static void scheduleJobExistingND(){  
        try{
            String sch = '0 0 22 * * ? *';
            List<CronTrigger> lstCronTrigger = [SELECT Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name = 'NeustarApiBatch Job:ExistingND'];
            if(lstCronTrigger.size() == 0 && !Test.isRunningTest()) String jobID = system.schedule('NeustarApiBatch Job:ExistingND', sch, new NeustarApiSch('ExistingND'));
        }catch(Exception ee){
            system.debug('error : '+ee.getMessage());
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime dt = system.Now().addDays(-15);
        
        DateTime mileStoneDateForExistingND = Test.isRunningTest()?system.Now().addDays(1):system.Now().addDays(-910);
        String query = '';
        if(callingLocation.equalsIgnoreCase('ExistingND')){
            query = 'select id,TN__c from Neustar_Data__c where lastModifiedDate <: mileStoneDateForExistingND';
        }else if(callingLocation.equalsIgnoreCase('NewUpdatedAccount')){
        	query ='select id,Phone,RecordType.DeveloperName,ParentId from Account where Need_To_Sync_With_NeuStar__c = true AND lastModifiedDate >: dt';   
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        String recId = String.valueOf(scope[0].get('Id'));
        if(recId.startsWith('001')){
            List<Account> lstAcc = (List<Account>) scope;
            NeustarApiBatchHandler.updateAccountNeuStar(lstAcc);
        }else{
            List<Neustar_Data__c> lstND = (List<Neustar_Data__c>) scope;
            NeustarApiBatchHandler.updateOlderNeuStar(lstND);
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}