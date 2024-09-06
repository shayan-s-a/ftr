// This Batch will run every Friday to send email reminders to Manager/DivisonalHead/HR Practitioner
public class PendingApprovalReminderBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Contact__r.Account.Divisional_Head__r.Personal_Email__c, Contact__r.Nespon_Manager__r.Personal_Email__c FROM Timesheet__c WHERE Status__c = \'Submitted and Pending for Approval\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<TimeSheet__c> scope) {
        try {    
            System.debug(':::: scope: ' + scope.size());
            Date today = Date.today();
            Date firstDay = Date.today().addDays(-5);
            Date lastDay = today.addDays(1);
            List<Messaging.SingleEmailMessage> managerEmailsToSend = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> divisinalHeadEmailsToSend = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> HrEmailsToSend = new List<Messaging.SingleEmailMessage>();
            
            List<HR_Practitioner__mdt> hrPractitioners = [SELECT DeveloperName, Position_Id__c, Email__c FROM HR_Practitioner__mdt];
            Id orgWideId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1]?.Id;
            Set<String> managerEmails = new Set<String>();
            Set<String> divisonalHeadEmails = new Set<String>();
            Set<String> hrPractitionerEmails = new Set<String>();

            for(TimeSheet__c t: scope) {
                managerEmails.add(t.Contact__r.Nespon_Manager__r.Personal_Email__c);
                divisonalHeadEmails.add(t.Contact__r.Account.Divisional_Head__r.Personal_Email__c);
            }

            // For Manager Email
            for(String email : managerEmails) {
                managerEmailsToSend.add(fillEmail('Timesheet Pending For Approval Reminder (Manager)','The timesheets for the pay period "' + firstDay + ' - ' + lastDay + '" are awaiting approval. Click here to approve the timesheets.',email,orgWideId));
            }

            // For Divisional Head
            for(String email : divisonalHeadEmails) {
                divisinalHeadEmailsToSend.add(fillEmail('Timesheet Pending For Approval Reminder (Divisional Head)','The timesheets for the pay period "' + firstDay + ' - ' + lastDay + '" are awaiting approval. Click here to approve the timesheets.',email,orgWideId));
            }
            
            // For HR Practitioner
            for(HR_Practitioner__mdt hr : hrPractitioners) {
                hrPractitionerEmails.add(hr.Email__c);
                HrEmailsToSend.add(fillEmail('Timesheet Pending For Approval Reminder (HR Practitioner)','The timesheets for the pay period "' + firstDay + ' - ' + lastDay + '" are awaiting approval. Click here to approve the timesheets.',hr.Email__c,orgWideId));
            }

            
            Datetime now = Datetime.now();
            Time currentTime = Datetime.now().time();
            Email_Reminder_Settings__c emailSettings = Email_Reminder_Settings__c.getOrgDefaults();

            System.debug(':::: emailSettings?.Friday_Date__c: ' + emailSettings?.Friday_Date__c);
            System.debug(':::: today: ' + today);

            if(emailSettings?.Friday_Date__c == today) {
                if(!emailSettings?.Manager_Reminder_Sent__c) {
                    System.debug(':::: currentTime.hour(): ' + currentTime.hour());
                    if(currentTime.hour() >= emailSettings.Manager_Reminder_Hour__c && currentTime.hour() <= emailSettings.Manager_Reminder_Hour__c + 1) {
                        if(!managerEmailsToSend.isEmpty()) {
                            if(!Test.isRunningTest()) Messaging.SendEmailResult[] results = Messaging.sendEmail(managerEmailsToSend);
                        }
                        emailSettings.Manager_Reminder_Sent__c = true;
                        upsert emailSettings;
                    }
                } else if(!emailSettings?.Divisional_Head_Reminder_Sent__c) {
                    if(currentTime.hour() >= emailSettings.Divisional_Head_Reminder_Hour__c && currentTime.hour() <= emailSettings.Divisional_Head_Reminder_Hour__c + 1) {
                        if(!divisinalHeadEmailsToSend.isEmpty()) {
                            if(!Test.isRunningTest()) Messaging.SendEmailResult[] results = Messaging.sendEmail(divisinalHeadEmailsToSend);
                        }
                        emailSettings.Divisional_Head_Reminder_Sent__c = true;
                        upsert emailSettings;
                    }
                } else if(!emailSettings?.HR_Practitioner_Reminder_Sent__c) {
                    if(currentTime.hour() >= emailSettings.HR_Reminder_Hour__c && currentTime.hour() <= emailSettings.HR_Reminder_Hour__c + 1) {
                        if(!HrEmailsToSend.isEmpty()) {
                            if(!Test.isRunningTest()) Messaging.SendEmailResult[] results = Messaging.sendEmail(HrEmailsToSend);
                        }
                        emailSettings.HR_Practitioner_Reminder_Sent__c = true;
                        upsert emailSettings;
                    }
                }
                // THIS WILL TELL US THAT ALL 3 EMAILS ARE SENT NOW WE SHOULD UPDATE ALL FIELDS
                else {
                    if(emailSettings.Manager_Reminder_Sent__c == true
                    && emailSettings.Divisional_Head_Reminder_Sent__c == true
                    && emailSettings.HR_Practitioner_Reminder_Sent__c == true) {
                        System.debug(':::: FINAL ON FRIDAY:');
                        emailSettings.Friday_Date__c = today.addDays(7);
                        emailSettings.Manager_Reminder_Sent__c = false;
                        emailSettings.Divisional_Head_Reminder_Sent__c = false;
                        emailSettings.HR_Practitioner_Reminder_Sent__c = false;
                        upsert emailSettings;
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
        }

    }

    public void finish(Database.BatchableContext BC) {
    }

    public Messaging.SingleEmailMessage fillEmail(String subject, String body, String email, String orgWideId) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.optOutPolicy = 'FILTER';
        message.subject = subject;
        message.plainTextBody = body;
        message.toAddresses = new String[] { email };
        message.setOrgWideEmailAddressId(orgWideId);
        return message;
    }
}