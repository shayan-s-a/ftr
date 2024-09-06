@isTest
public class TimesheetControllerTest2KL {
@isTest
    static void Test_Method (){
        

        //For Account Object
        String AccName ='HRIS Test Company';
        String rt= '0128I000000G1VPQA0'; // Divisional Record Type
            
         //For Contact Object    
        String firstName = 'HRIS First';
        String lastName = 'HRIS Last';
        
        //  For CommnuityUser (user Object)
        String uname ='HRISTest_Employee@test.com';
        String UFName ='Test-First';
        String ULName ='Test-Last';
		// For Project
		String ProjectName= 'Test Project';   
        String Dsc='Test Data for Project';
        //TimeSheet 
        String PCode='Corporate Time';
        String status='Submitted and Pending for Approval';
        Map <String,String> rec  =new Map<String,String>();
        User adminUser = TestDataFactoryKL.updateAdminRole();
        Contact con = new Contact();
        User usr = new User();
        System.runAs(adminUser){
         	con =TestDataFactoryKL.createContact(AccName,rt,firstName,lastName);   
        }
        System.runAs(adminUser){
         	usr =TestDataFactoryKL.createCommnuityUser_Asir(con,Uname,UFname,ULname);
        }
        System.debug('User contact Id  done: '+usr.ContactId);
        List<Contact> Test_Acc= [Select Id,AccountId,Nespon_Manager__c from Contact where Id=: usr.ContactId Limit 1];
        System.debug('User Account Id  done: '+Test_Acc[0].AccountId);
        System.runAs(adminUser){
            TimeSheet__c TSObj =TestDataFactoryKL.createTimeSheet(Test_Acc[0].AccountId,usr.ContactId,ProjectName,Dsc,PCode,status,'PM');
            
          
            //getUserDetails(String userId)
         
            
            rec=TimesheetController.getUserDetails(usr.id);
            
            List<TimesheetController.TimesheetWrapper> lstTS= new List<TimesheetController.TimesheetWrapper>();
            List<TimesheetController.TimesheetWrapper> lstTSApproval= new List<TimesheetController.TimesheetWrapper>();
            List<TimesheetController.TimesheetWrapper> lstTSView= new List<TimesheetController.TimesheetWrapper>();
            Date Dtfrom = date.valueOf( rec.get('dateFrom'));
            Date DtTo = date.valueOf(rec.get('dateTo'));
            Date TodayDate = Date.today();
            
            // Time option 'Current Pay Period'
            lstTS= TimesheetController.getTimesheetByDate(usr.ContactId, Dtfrom, DtTo, 'Current Pay Period') ;
            lstTS= TimesheetController.getTimesheetByDate(usr.ContactId, null, null, 'Next Pay Period') ;
          //  lstTS= TimesheetController.getTimesheetByDate( string saveRecords(List<TimesheetWrapper> timesheetsToSave, String conId), null, null, 'Previous Pay Period') ;
            System.debug('@@usr.Contact.Nespon_Manager__c: '+Test_Acc[0].Nespon_Manager__c);
            lstTSApproval= TimesheetController.getTimesheetForApproval(Test_Acc[0].Nespon_Manager__c , Dtfrom, DtTo);
            lstTSApproval= TimesheetController.getTimesheetsUpdateRequests(Test_Acc[0].Nespon_Manager__c);
            Map<String,String> mMap = TimesheetController.getUserProjectsParticipantsMap(usr.ContactId);
            
            // 2nd Phase
            lstTSView=TimesheetController.getTimesheetToView(Test_Acc[0].Nespon_Manager__c , Dtfrom, DtTo);
            List<TimesheetController.TimesheetWrapper> timesheetsToSave= TestDataFactoryKL.CreateTimesheetWrapper();
            String ss =TimesheetController.saveRecords(timesheetsToSave,usr.ContactId);
            ss =TimesheetController.submitRecords(timesheetsToSave,usr.ContactId);
         	ss= TimesheetController.recallRecords(timesheetsToSave,usr.ContactId ,'Reason', Dtfrom,DtTo,  'Current Pay Period'); 
            // Check error     
           	ss= TimesheetController.approveTimesheets(timesheetsToSave, Test_Acc[0].Nespon_Manager__c ) ;
            ss =TimesheetController.rejectTimesheets(timesheetsToSave ,'Reason', Test_Acc[0].Nespon_Manager__c);
            ss =TimesheetController.unlockTimesheets(timesheetsToSave , Test_Acc[0].Nespon_Manager__c);
          // Check error
          // ss =TimesheetController.unlockTimesheets(timesheetsToSave,String.valueOf(Test_Acc[0].Nespon_Manager__c));
            // For Phase II Asir Class Methods
            // 
            List<TimesheetControllerAS.TimesheetWrapper> timesheetsToSave1= new List<TimesheetControllerAS.TimesheetWrapper>();
            rec= TimesheetControllerAS.getUserDetailsByContactId(usr.ContactId);
            timesheetsToSave1=TimesheetControllerAS.getTimesheetByDateByEmployee(usr.ContactId,  Dtfrom,DtTo,'Current Pay Period');
            timesheetsToSave1=TimesheetControllerAS.getTimesheetByDateByEmployee(usr.ContactId,  Dtfrom,DtTo,'Next Pay Period');
            timesheetsToSave1=TimesheetControllerAS.getTimesheetByDateByEmployee(usr.ContactId,  Dtfrom,DtTo,'Previous Pay Period');
            
            timesheetsToSave1=TimesheetControllerAS.getTimesheetByDateByEmployee(usr.ContactId,  null,null,'Previous Pay Period');
            
			timesheetsToSave1=TimesheetControllerAS.getTimesheetByDate(usr.ContactId,  Dtfrom,DtTo,'Current Pay Period');
			timesheetsToSave1=TimesheetControllerAS.getTimesheetByDate(usr.ContactId,  Dtfrom,DtTo,'Next Pay Period');
            timesheetsToSave1=TimesheetControllerAS.getTimesheetByDate(usr.ContactId,  Dtfrom,DtTo,'Previous Pay Period');
			timesheetsToSave1=TimesheetControllerAS.getTimesheetByDate(usr.ContactId,  null,null,'Current Pay Period');
           
            
            
            
            
            
           
        }
    
       
         
    }
    
}