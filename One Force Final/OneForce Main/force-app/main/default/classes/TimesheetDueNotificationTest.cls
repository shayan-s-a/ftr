@isTest
public class TimesheetDueNotificationTest {
    @isTest static void testBatchClass() { 
        List<Contact> testContacts = new List<Contact>();
        List<TimeSheet__c> testTimeSheets = new List<TimeSheet__c>();
        List<User> users = new list<User>();
    	// Create test data
        for(integer i = 0; i< 2; i++){
            Contact testContact = new Contact(
            FirstName = 'John '+i,
            LastName = 'Doe '+i,
            personal_email__c = 'john.doe'+i+'@example.com'
        	);
            testContacts.add(testContact);
        }
        insert testContacts;
        DateTime currentDateTime = System.now();
        Date todaysDate = currentDateTime.date();  
        date jsonDate = Date.newInstance(2023, 05, 25);
        for (Integer i = 0; i < 5; i++) {
            if(i==0){
				TimeSheet__c testTimeSheet = new TimeSheet__c(
            	Contact__c = testContacts[0].Id,
            	Approval_Date__c = System.now(),
            	Status__c = 'Approved',
            	Day__c = todaysDate
        		);
				testTimeSheets.add(testTimeSheet);                
            }
            else{
                TimeSheet__c testTimeSheet = new TimeSheet__c(
            	Contact__c = testContacts[0].Id,
            	Approval_Date__c = System.now(),
            	Status__c = 'Approved',
            	Day__c = todaysDate.addDays(-i)
        		); 
                testTimeSheets.add(testTimeSheet);
            }
        }
        
        //testTimeSheets.add(testTimeSheet);
        insert testTimeSheets;
       

        
        Test.startTest();
            TimesheetDueNotification notification = new TimesheetDueNotification();
            Database.executeBatch(notification);
        Test.stopTest();
    
    }
}