global class TestApexKL implements Database.Batchable<sObject> {
    global String body='';
    global List<User> UserList = new List<User>();
   global Database.QueryLocator start(Database.BatchableContext BC) {
      			String query = 'SELECT Id, ContactId ,isportalenabled ,contact.lastname,email FROM User where isPortalEnabled = true and email='+'\'laiq.kauser@nespon.com\'';
       			system.debug('string ::::'+ query );
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<User> scope) {
     for(User a : scope)
     {
         UserList.add(a);
     }
        
     List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail1=new Messaging.SingleEmailMessage();  
         for(User a:UserList){
        String[] toadd=new String[]{a.Email};
        string b =  'hello' ; 
        body += b ;
        mail1.setToAddresses(toadd);
        mail1.setSubject('Test mail');
        mail1.setPlainTextBody('this is a test mail');
        mail1.setHtmlBody(body);
        lstEmail.add(mail1);
        System.debug(lstEmail.size());
    }
    System.debug(body);
       Messaging.SendEmail(lstEmail);
  
    }
    global void finish(Database.BatchableContext BC) {
    }


}