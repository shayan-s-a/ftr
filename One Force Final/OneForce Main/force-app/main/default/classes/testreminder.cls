public class testreminder {

    public static void test1(){
        DateTime currentDateTime = DateTime.now();
        Date todaysDate = currentDateTime.date();
        Date fourDayBefore = todaysDate.addDays(-4);
        
        List<Contact> contacts =[select id, Name,personal_email__c, (select id, Approval_Date__c,Status__c, Day__c from TimeSheets__r where Day__c >= :fourDayBefore and Day__c<= :todaysDate) from Contact where id='0038I00000MLwMyQAL'];
        system.debug('timesheetcount '+contacts[0].TimeSheets__r.size());
        system.debug('timesheetcount '+contacts[0].TimeSheets__r);
        Integer count = contacts[0].TimeSheets__r.size();

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
            sendReminder(fourDayBefore,todaysDate,newList);
        }
    }
    
    public static string sendReminder(Date fourDayBefore, Date todaysDate, List<Contact> contacts){
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE DeveloperName = 'TimeCardNotification'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Request to Fill Timesheet.');
        notification.setBody('Reminder: '+String.valueOf(fourDayBefore)+' - '+String.valueOf(todaysDate)+' Timesheet is due for submission ');
        notification.setNotificationTypeId(notificationType.Id);
        Map<String, Object> communityPageRef = new Map<String, Object>{
            'type' => 'comm__namedPage',
                'attributes' => new Map<String, Object>{
                    'pageName' => 'home'
                        }
        };
        notification.setTargetPageRef(JSON.serialize(communityPageRef));
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.optOutPolicy = 'FILTER';
        message.subject = 'Request to Fill Timesheet.';
        message.plainTextBody = 'Reminder: The timesheet for the pay period '+String.valueOf(fourDayBefore)+' - '+String.valueOf(todaysDate)+' is due for submission.';
        List<OrgWideEmailAddress> orgWideId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        
        List<User> user = [SELECT Id, Email FROM User WHERE ContactId IN : contacts];
        if(!user.isEmpty()) {
            notification.send(new Set<String>{user[0]?.Id});
            message.toAddresses = new String[] { contacts[0].Personal_Email__c };
            message.setOrgWideEmailAddressId(orgWideId[0].id);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
                if(contacts[0].Personal_Email__c != null) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                }
            return 'OK';
        }
        return 'Not Ok';
    }
}