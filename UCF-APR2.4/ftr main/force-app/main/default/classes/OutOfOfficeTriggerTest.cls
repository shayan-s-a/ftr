@IsTest //(seeAllData=true)
public class OutOfOfficeTriggerTest {
       
    @isTest static void OutOfOfficetest2() {
        User u = new User(
            ProfileId = UserInfo.getProfileId(),
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            isActive=true
        );
        insert u;
        
        User u2 = new User(
            ProfileId = UserInfo.getProfileId(),
            LastName = 'last2',
            Email = 'puser2000@amamama.com',
            Username = 'puser0002@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST2',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            isActive=true
        );
        insert u2;
                        
        OutOfOffice ooo = new OutOfOffice(
            StartDate = Date.today(),
            EndDate = Date.today().addDays(1),
            Message='My message',
            IsEnabled = true,
            UserId = u.id //This should be a new user created in test class 
        );
        insert ooo;
        
        Datetime current =ooo.StartDate;                
        Date local = date.newinstance(current.year(), current.month(), current.day());
        
        WorkGroup__c workgrp = new WorkGroup__c();
        workgrp.Name ='Work Group1';
        workgrp.Field__c='Network Cost Management';
        insert workgrp;
        
        FieldAssignment__c fieldAssig = new FieldAssignment__c();
        fieldAssig.WorkGroupId__c = workgrp.id;
        fieldAssig.Backup_Assignment__c = u2.id;
        fieldAssig.Out_Of_Office_Start_Date__c = local;
        fieldAssig.UserId__c= ooo.UserId ;
        fieldAssig.OutOfOffice__c = ooo.IsEnabled;
        insert fieldAssig; 
                
        ooo.IsEnabled = false;
        update ooo;
        
        fieldAssig.OutOfOffice__c = ooo.IsEnabled;
        update fieldAssig;
        
        delete ooo;
    
    }
}