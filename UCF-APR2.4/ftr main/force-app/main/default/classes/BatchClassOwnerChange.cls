global class BatchClassOwnerChange implements Database.Batchable<SObject>, Database.Stateful {
    
    private Id accOwnerId;
    private Id parentId;
    
    global BatchClassOwnerChange(Id accId, Id ownerId){
        this.parentId = accId;
        this.accOwnerId = ownerId;
        System.debug('parentId:  ' + parentId);
        System.debug('OwnerId:  ' + accOwnerId);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String parentAcc = '%' + parentId + '%';
        String query = 'SELECT Id,OwnerId FROM Account WHERE Parentid = :parentId OR Parent.Parentid = :parentId OR Parent.Parent.Parentid = :parentId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bC, List<Account> scope) {       
        
        List<Account> updList = new List<Account>();
        for (Account acc : scope){	
            if (acc.OwnerId != accOwnerId){
                acc.OwnerId = accOwnerId;
                updList.add(acc);
            }
        }
        update updList;
    }

    global void finish(Database.BatchableContext bC) {
        
        System.debug(LoggingLevel.Info,'finish ');
        
    }    
}