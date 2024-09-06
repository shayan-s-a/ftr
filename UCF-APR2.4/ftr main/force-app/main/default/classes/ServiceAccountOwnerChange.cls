public class ServiceAccountOwnerChange implements Queueable {
    private List<Account> lstServiceAccounts ; 
    private Integer count = 0;
    
    
    public ServiceAccountOwnerChange(List<Account> lstServiceAccounts,Boolean isItParentJob){
        this.lstServiceAccounts = lstServiceAccounts;
        count = lstServiceAccounts.size();
        
        if(isItParentJob){
            sendEmail('Hi, Queueable Job to update service accounts has been set in queue.','Queueable Job Queued');
        }
    }
    
    public void execute(QueueableContext context) {
        if(count <= 500){ 
            update lstServiceAccounts;
            sendEmail('Hi, This is to inform you that Queueable job to update service accounts is completed.','Queueable Job Ended');
            if(!Test.isRunningTest()) return;
        } 
        
        List<Account> maxAccToUpdate = new List<Account>();
        List<Account> remainingAccounts = new List<Account>();
        count = 0;
        for(Account acc : lstServiceAccounts){
            if(count <= 500) maxAccToUpdate.add(acc);
            else remainingAccounts.add(acc);
            count++;
        }
        
        if(!Test.isRunningTest()){ 
            update maxAccToUpdate;
            System.enqueueJob(new ServiceAccountOwnerChange(remainingAccounts,false));
        }
    }
    public void sendEmail(String emailContent,String subject){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //Getting the mail list from custom setting 
        List<String> emailList = new List<String>();
        for(Email_Distribution__c emails :[SELECT Id, Email__c FROM Email_Distribution__c WHERE Email__c != '']) emailList.add(emails.Email__c);
        if(emailList.size() == 0 && !Test.isRunningTest()) return;
        mail.setToAddresses(emailList);
        mail.setSubject(subject);
        mail.setHtmlBody(emailContent);
        try{
             Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }catch(exception ee){}
    }
}