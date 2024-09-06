global class EmailNotificationReminder implements Database.Batchable<sObject>, Schedulable { 
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        // Construct your query to retrieve the records you want to process
        return Database.getQueryLocator([select Id, Name, Personal_Email__c from Contact]);
    }
    
    global void execute(Database.BatchableContext context, List<Contact> contacts) {  
         if(contacts.size()>0){
            sendReminderEmail(contacts);
        }
        
    }
    global void finish(Database.BatchableContext context) {
        // Perform any post-processing tasks
    }


	 global void execute(SchedulableContext sc){
        EmailNotificationReminder notification = new EmailNotificationReminder();
        Database.executeBatch(notification);
    }
    
    public static void sendReminderEmail(List<Contact> contacts){
        
         CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE DeveloperName = 'TimeCardNotification'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Timesheet Monthly Reminder.');
        notification.setBody('Reminder to submit the timesheet for the month end.');
        notification.setNotificationTypeId(notificationType.Id);
        Map<String, Object> communityPageRef = new Map<String, Object>{
            'type' => 'comm__namedPage',
                'attributes' => new Map<String, Object>{
                    'pageName' => 'home'
                        }
        };
        notification.setTargetPageRef(JSON.serialize(communityPageRef));
        
        List<Messaging.SingleEmailMessage> allMessages = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> orgWideId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        Set<String> userIdSet = new Set<String>();
                    for(Contact c : contacts) {
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            message.optOutPolicy = 'FILTER';
                            message.subject = 'Timesheet Monthly Reminder.';
                            message.plainTextBody = 'Hi Team, we are now approaching the end of the month. Please ensure your time is entered, along with the correct pay code, until the end of the month. Do not delay in getting this done. \n \n If you have any questions, please contact Farrah.Boban@Nespon.com.';
                            System.debug(':::: conList[0].Personal_Email__c: ' + c.Personal_Email__c);
                        	List<User> user = [SELECT Id, Email FROM User WHERE ContactId =: c.Id];
                        if(!user.isEmpty()){
                            userIdSet.add(user[0]?.Id);
                        }
                        if(c.Personal_Email__c!= null){
                            message.toAddresses = new String[] { c.Personal_Email__c };
                            message.setOrgWideEmailAddressId(orgWideId[0].id);
                            allMessages.add(message);
                        	}
                            
                        }
                    
                    if(!allMessages.isEmpty()) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(allMessages);
                        for(Messaging.SendEmailResult r : results) {
                            System.debug(':::: r.getErrors(): ' + r.getErrors());
                            System.debug(':::: isSuccess: ' + r.isSuccess());
                        }
                    }
        
        			 if(!userIdSet.isEmpty()){
            			notification.send(userIdSet);
        				}
                
        
     
    }
}