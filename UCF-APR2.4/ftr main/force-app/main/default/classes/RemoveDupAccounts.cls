global class RemoveDupAccounts implements Database.Batchable<sObject>,Database.stateful, Schedulable {
    
    public static void scheduleJob(){  
        try{
            String sch = '0 0 18 * * ? *';
            List<CronTrigger> lstCronTrigger = [SELECT Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name = 'RemoveDupAccounts Job'];
            if(lstCronTrigger.size() > 0){
                system.abortJob(lstCronTrigger[0].Id);
            }
            String jobID = system.schedule('RemoveDupAccounts Job', sch, new RemoveDupAccounts());
        }catch(Exception ee){
            system.debug('error : '+ee.getMessage());
        }
    }
    global void execute(SchedulableContext SC) {
        database.executebatch(new RemoveDupAccounts(),1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer limitValue = String.isNotBlank(System.Label.Dup_Account_Batch_Limit)?Integer.valueOf(System.Label.Dup_Account_Batch_Limit):5000;
        DateTime dt = system.Now().addDays(-15);
        return database.getQueryLocator('select id,OwnerId,parent__c,Customer_Number__c from Account where parent__c=true and lastmodifiedDate >=: dt limit : limitValue');
    }
    global void execute(Database.BatchableContext bc, List<Sobject> records){
        // master Account
        Account acc = (Account) records[0];
        // all dup accounts
        List<Account> lstAcc = [select Id,name,recordType.name, Customer_Number__c from Account where Customer_Number__c =:acc.Customer_Number__c and ParentId !=: acc.id and id!=:acc.id];
        
        // map that will hold accounts to mark duplicate only. 
        Map<Id,Boolean> mapOfAccountsToDelete = new Map<Id,Boolean>();
        
        List<Contact> lstCon = [select id,AccountId from contact where AccountId IN:lstAcc ];
        for(Contact con : lstCon){
            if(!mapOfAccountsToDelete.containsKey(con.AccountId))
                mapOfAccountsToDelete.put(con.AccountId,false);                
        }
        List<Case> lstCase = [select id,AccountId from Case where AccountId IN:lstAcc AND Id NOT IN:mapOfAccountsToDelete.keyset()];
        for(Case cse : lstCase){
            if(!mapOfAccountsToDelete.containsKey(cse.AccountId))
                mapOfAccountsToDelete.put(cse.AccountId,false);                
        }
        
        List<Order> lstOrder = [select id,AccountId from Order where AccountId IN:lstAcc AND Id NOT IN:mapOfAccountsToDelete.keyset()];
        for(Order ord : lstOrder){
            if(!mapOfAccountsToDelete.containsKey(ord.AccountId))
                mapOfAccountsToDelete.put(ord.AccountId,false);                
        }
        
        List<Id> oppIdsForQuotes = new List<Id>();
        for(Quote qt : [select id,AccountId,OpportunityId from Quote where AccountId IN:lstAcc AND Id NOT IN:mapOfAccountsToDelete.keyset() ]){
            oppIdsForQuotes.add(qt.OpportunityId);
            
            if(!mapOfAccountsToDelete.containsKey(qt.AccountId))
                mapOfAccountsToDelete.put(qt.AccountId,false);
        } 
        
        List<Opportunity> lstOpp = [select id,AccountId from Opportunity where (AccountId IN:lstAcc AND Id NOT IN:mapOfAccountsToDelete.keyset()) OR Id IN : oppIdsForQuotes];
        for(Opportunity opp : lstOpp){
            if(!mapOfAccountsToDelete.containsKey(opp.AccountId))
                mapOfAccountsToDelete.put(opp.AccountId,false);
        }
        List<Contract> lstCont = [select id,AccountId from Contract where AccountId IN:lstAcc AND Id NOT IN:mapOfAccountsToDelete.keyset() ];
        for(Contract cont : lstCont){
            if(!mapOfAccountsToDelete.containsKey(cont.AccountId))
                mapOfAccountsToDelete.put(cont.AccountId,false);
        }
        List<Account> lstAccToDelete = new List<Account>();
        List<Account> lstAccToUpdate = new List<Account>();
        for(Account accR: lstAcc){
            if(mapOfAccountsToDelete.containskey(accR.Id)){
                accR.Duplicate_Account__c  = true;
                lstAccToUpdate.add(accR);
            }else lstAccToDelete.add(accR);
        }
        acc.parent__c = false;
        lstAccToUpdate.add(acc);
        
        if(lstAccToUpdate.size() > 10000 || (lstAccToUpdate.size() >= 1 && Test.isRunningTest())) System.enqueueJob(new UpdateDupAccounts(lstAccToUpdate,'update'));
        else update lstAccToUpdate;
        
        if(lstAccToDelete.size() > 10000 || (lstAccToDelete.size() >= 1 && Test.isRunningTest())) System.enqueueJob(new UpdateDupAccounts(lstAccToDelete,'delete'));
        else delete lstAccToDelete;
    }     
    global void finish(Database.BatchableContext bc){
        
    }    
}