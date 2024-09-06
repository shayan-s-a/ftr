global class TimesheetDueNotification implements Database.Batchable<sObject>,Schedulable {
    private static DateTime currentDateTime = DateTime.now();
    private static Date todaysDate = currentDateTime.date();
    private static Date fourDayBefore = todaysDate.addDays(-4);
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        // Construct your query to retrieve the records you want to process
        return Database.getQueryLocator([SELECT id, Name,personal_email__c, 
                                         (SELECT id, Approval_Date__c,Status__c, Day__c 
                                          FROM TimeSheets__r 
                                          WHERE Day__c >= :fourDayBefore and Day__c<= :todaysDate) 
                                         FROM Contact]);
    }
    
    global void execute(Database.BatchableContext context, List<Contact> contacts) {
 		List<Contact> newList= new List<Contact>();   
        Set<Date> uniqueValues = new Set<Date>();
        for(Contact con: contacts){
               if(con.TimeSheets__r.size()==0){
                   newList.add(con);
               }
                else{
                    for(TimeSheet__c sheet: con.TimeSheets__r){
                        uniqueValues.add(sheet.Day__c);
                    }
                    if(uniqueValues.size()<5){
                        newList.add(con);
                    }
                }
         }
        if(newList.size()>0){
            sendReminder(newList);
        }
    }
    
    global void finish(Database.BatchableContext context) {
        // Perform any post-processing tasks
    }
    
    global void execute(SchedulableContext sc){
        TimesheetDueNotification notification = new TimesheetDueNotification();
        Database.executeBatch(notification);
    }
    
    public static void sendReminder(List<Contact> contacts){
        DateTime fourDaysBefore = currentDateTime.addDays(-4);

        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE DeveloperName = 'TimeCardNotification'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Reminder for Due Timesheet');
        notification.setBody(''+fourDaysBefore.format('MM/dd/YYYY')+' - '+currentDateTime.format('MM/dd/YYYY')+' Timesheet is due for submission ');
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
        Boolean flag =false;
        Set<String> userIdSet = new Set<String>();
        for(Contact contact: contacts){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.optOutPolicy = 'FILTER';
        	message.subject = 'Reminder for Due Timesheet';
        	message.plainTextBody = 'The timesheet for the pay period '+fourDaysBefore.format('MM/dd/YYYY')+' - '+currentDateTime.format('MM/dd/YYYY')+' is due for submission.';
            List<User> user = [SELECT Id, Email FROM User WHERE ContactId =: contact.Id];
            if(!user.isEmpty()) {
            	userIdSet.add(user[0]?.Id);
                if(contact.Personal_Email__c!= null){
                    message.toAddresses = new String[] { contact.Personal_Email__c };
                    message.setOrgWideEmailAddressId(orgWideId[0].id);
                    allMessages.add(message);
                }
        	}
        }
        if(!allMessages.isEmpty()) {
             Messaging.SendEmailResult[] results = Messaging.sendEmail(allMessages);
        }
        if(!userIdSet.isEmpty()){
            notification.send(userIdSet);
        }
        
    }
}