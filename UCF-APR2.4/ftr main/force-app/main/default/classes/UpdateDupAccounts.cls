public class UpdateDupAccounts implements Queueable {
    public List<Account> lstAcc;
    public String dmlOperation;
    public UpdateDupAccounts(List<Account> lstAcc,String dmlOperation){
        this.lstAcc = lstAcc;
        this.dmlOperation = dmlOperation;
    }
    public void execute(QueueableContext context) {
        List<Account> lstAccToUpdate = new List<Account>();
        Integer index = lstAcc.size() >= 10000 ? 9999 : lstAcc.size()-1;
        for(Integer i = index; i >= 0 ; i--){
            lstAccToUpdate.add(lstAcc[i]);
            lstAcc.remove(i);
        }
        if(lstAccToUpdate.size() > 0){
            if(dmlOperation == 'update')
            	update lstAccToUpdate;
            else if(dmlOperation == 'delete')
            	delete lstAccToUpdate;
        }
        if(lstAcc.size() > 0)
        	System.enqueueJob(new UpdateDupAccounts(lstAcc,dmlOperation));
    }
}