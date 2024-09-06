public with sharing class EmailWithCheckboxController {
   //version1
 
 @AuraEnabled
 public static list < User > fetchUser() {
  List < User > returnConList = new List < User > ();
 
  List < User > lstCon = [SELECT id,Name, 
                          firstName, 
                          LastName, 
                          Email, 
                          Phone,
                          UserRole.Name 
                          From User WHERE Email != null 
                         AND (UserRole.Name='DealDeskApprover' ) AND IsActive=true];
  // play for loop on lstCon and add each contact to returnConList List.
    for (User c: lstCon) {
       returnConList.add(c);
    }
 // return the List of contacts
      return returnConList;
 }
 
 
  @AuraEnabled
  public static integer sendemail(List<string> ids,String RecId1){
      List<Task> tskList = new List<Task>();
      System.debug('Inside sendEmail Dunction Ids :'+ids);
      System.debug('Inside sendEmail Dunction RecId1 :'+RecId1);
      if(ids.size()>0)
      {          
          System.debug('Sending Mails');
      SterlingQuote__c QuoteRecord = [select Id,Name,OpportunityId__r.Name from SterlingQuote__c where Id=: RecId1 limit 1];
      String Subj = 'A New Deal Desk Request on'+QuoteRecord.Name+' From Opportunity '+QuoteRecord.OpportunityId__r.Name+' Created.';
      List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
      for(User cc : [select id,name,Email from User where ID IN : ids]){
        // Step 1: Create a new Email
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    // Step 2: Set list of people who should get the email
       List<String> sendTo = new List<String>();
       sendTo.add(cc.Email);
       // sendTo.add('varasree67@gmail.com');   
       mail.setToAddresses(sendTo);
       
    
    // Step 3: Set who the email is sent from
       mail.setReplyTo('noreply@gmail.com'); // change it with your mail address.
       mail.setSenderDisplayName('salesforce test User'); 
    
    // Step 4. Set email contents - you can use variables!
      mail.setSubject('New Deal Desk Request is Raised');
      mail.setHtmlBody('Dear '+ cc.name + ' <br/><br/>New Deal Desk Request is Raised<br/><br/> Thanks <br/>');
    
    // Step 5. Add your email to the master list
      mails.add(mail);  
				     Task tsk = new Task();
					 tsk.Subject = Subj;
					 tsk.Status = 'Open';
					 tsk.Priority = 'Normal';
					 tsk.WhatId = RecId1;
					 tsk.OwnerId = cc.Id;
					 tskList.add(tsk);          
      }
     
    // Step 6: Send all emails in the master list
     Messaging.sendEmail(mails);
      insert tskList;  
          return 1;
      }
      else
      {
          System.debug('Mails Not Sending');
          return 0;
      }
   }   
    
    @future
    public static void CallMethod()
    {
        
    }    
    
}