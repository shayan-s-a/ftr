@isTest
public class EmailNotificationReminderTest {
   @isTest static void testBatchClass() { 

    	// Create test data

       Contact testContact = new Contact(
           FirstName = 'John ',
           LastName = 'Doe ',
           personal_email__c = 'john.doe@example.com'
       );
  
       insert testContact;
       
       Test.startTest();
           EmailNotificationReminder notification = new EmailNotificationReminder();
           Database.executeBatch(notification);
       Test.stopTest();
   }
        
}