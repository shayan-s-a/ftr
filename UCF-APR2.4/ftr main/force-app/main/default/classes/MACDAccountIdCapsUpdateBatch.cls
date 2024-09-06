//Version #3
global class MACDAccountIdCapsUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID,account_id_caps__c from Account where recordtype.developername = \'Master\' and account_id_caps__c = null';
        return Database.getQueryLocator(query);

    }
    global void execute(Database.BatchableContext bc, List<Account> acctList){
        for(Account acct: acctList){
            String temp = acct.Id;
            acct.Account_Id_Caps__c = temp.toUppercase();           
        }
        if (acctList !=null && acctList.size() > 0){
            try{
                Database.update(acctList, true);
            }catch(Exception e){
                System.debug(e);
            }
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    

}
// *
