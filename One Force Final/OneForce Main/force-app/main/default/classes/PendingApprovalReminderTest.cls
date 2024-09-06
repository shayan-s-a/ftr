@isTest
public class PendingApprovalReminderTest {
    @isTest
    public Static void test1() {
        Account ac = new Account();
        ac.Name = 'Head Office';
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office Account').getRecordTypeId();
        insert ac;

        Account ac2 = new Account();
        ac2.Name = 'Divisional Office';
        ac2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Divisional Office Account').getRecordTypeId();
        ac2.ParentId = ac.Id;
        insert ac2;

        Contact con = new Contact();
        con.LastName = 'Test Divisional Head';
        con.Personal_Email__c = 'test@gmail.com';
        con.Email = 'test@gmail.com';
        con.AccountId = ac2.Id;
        insert con;

        ac2.Divisional_Head__c = con.Id;
        update ac2;

        Contact con1 = new Contact();
        con1.LastName = 'Test Nespon Manager';
        con1.Personal_Email__c = 'test1@gmail.com';
        con1.Email = 'test1@gmail.com';
        con1.AccountId = ac2.Id;
        insert con1;

        Contact con2 = new Contact();
        con2.LastName = 'Test Employee';
        con2.Personal_Email__c = 'test2@gmail.com';
        con2.Email = 'test2@gmail.com';
        con2.AccountId = ac2.Id;
        con2.Nespon_Manager__c = con1.Id;
        insert con2;

        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        proj.Account__c = ac2.Id;
        proj.Active__c = true;
        proj.Description__c = 'Some Description';
        insert proj;

        Project_Participants__c pp = new Project_Participants__c();
        pp.Project__c = proj.Id;
        pp.Contact__c = con2.Id;
        pp.Type_of_participation__c = 'Billable';
        pp.Role__c = 'Developer';
        pp.Active__c = true;
        insert pp;

        Timesheet__c t = new Timesheet__c();
        t.Status__c = 'Submitted and Pending for Approval';
        t.Contact__c = con2.Id;
        t.Project__c = proj.Id;
        t.Project_Participants__c = pp.Id;
        t.Day__c = Date.today();
        t.Hours__c = 9;
        t.Pay_Code__c = 'Corporate Time';
        insert t;

        Email_Reminder_Settings__c emailSettings = Email_Reminder_Settings__c.getOrgDefaults();
        emailSettings.Friday_Date__c = Date.today();
        emailSettings.Manager_Reminder_Sent__c = false;
        emailSettings.Divisional_Head_Reminder_Sent__c = false;
        emailSettings.HR_Practitioner_Reminder_Sent__c = false;
        upsert emailSettings;

        SchedulableContext sc = null;
        PendingApprovalReminderSchedule s = new PendingApprovalReminderSchedule();
        s.execute(sc);

        emailSettings.Manager_Reminder_Sent__c = true;
        upsert emailSettings;

        PendingApprovalReminderBatch b = new PendingApprovalReminderBatch(); 
        Database.executeBatch(b);

        emailSettings.Divisional_Head_Reminder_Sent__c = true;
        upsert emailSettings;

        PendingApprovalReminderBatch b2 = new PendingApprovalReminderBatch(); 
        Database.executeBatch(b2);

        emailSettings.HR_Practitioner_Reminder_Sent__c = true;
        upsert emailSettings;

        PendingApprovalReminderBatch b3 = new PendingApprovalReminderBatch(); 
        Database.executeBatch(b3);
    }    
}