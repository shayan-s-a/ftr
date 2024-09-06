// Created By : Kauser laiq
@isTest

public class TimesheetControllerTestKL {
	@isTest()
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
            List<TimeSheet__c> TSObjLst =TestDataFactoryKL.createTimeSheet(Test_Acc[0].AccountId,usr.ContactId,ProjectName,Dsc,PCode,status,'PM');
            	
            Map <String,String> rec  =new Map<String,String>();
            //getUserDetails(String userId)
        
           // String strImg=TimesheetController.getImageUrl(String.valueof(usr.id));
            
            rec=TimesheetController.getUserDetails(usr.id);
            System.debug('UserDetails ::: '+usr.id);
             System.debug('UserDetails ::: '+usr.ContactId);
          
          //  rec= TimesheetController.getDivisonalOffices(usr.id, true, false, false) ;
         //   rec= TimesheetController.getDivisonalOffices(usr.id, true, true, false) ;
          //    rec= TimesheetController.getDivisonalOffices(usr.id, true, false, true) ;
         
            List<TimesheetController.TimesheetWrapper> lstTS= new List<TimesheetController.TimesheetWrapper>();
            List<TimesheetController.TimesheetWrapper> lstTSApproval= new List<TimesheetController.TimesheetWrapper>();
            List<TimesheetController.TimesheetWrapper> lstTSView= new List<TimesheetController.TimesheetWrapper>();
            Date Dtfrom = date.valueOf( rec.get('dateFrom'));
            Date DtTo = date.valueOf(rec.get('dateTo'));
            Date TodayDate = Date.today();
            String strConId=String.valueOf(usr.ContactId);	
           
        	 lstTS= TimesheetController.getTimesheetByDateByEmployee(strConId,Dtfrom, DtTo, 'Current Pay Period' , 'viewonly');
             lstTS= TimesheetController.getTimesheetByDateByEmployee(strConId,Dtfrom, DtTo, 'Next Pay Period' , 'notviewonly');
             lstTS= TimesheetController.getTimesheetByDateByEmployee(strConId,Dtfrom, DtTo,'Previous Pay Period' , 'notviewonly');

            
            
            
             // Time option 'Current Pay Period'
              System.debug('UserDetail111 ::: '+usr.ContactId);
            lstTS= TimesheetController.getTimesheetByDate(usr.ContactId, Dtfrom, DtTo, 'Next Pay Period') ;
              System.debug('UserDetails222 ::: '+usr.ContactId);
            lstTS= TimesheetController.getTimesheetByDate(usr.ContactId, Dtfrom, DtTo, 'Previous Pay Period') ;
            lstTS= TimesheetController.getTimesheetByDate(usr.ContactId, Dtfrom, DtTo, 'Current Pay Period') ;
            
 			
            Map<String,String> LstmMapCon= TimesheetController.getUserDetailsByContactId(String.valueOf(usr.ContactId) );
          //  lstTS= TimesheetController.getTimesheetByDate( string saveRecords(List<TimesheetWrapper> timesheetsToSave, String conId), null, null, 'Previous Pay Period') ;
            System.debug('@@usr.Contact.Nespon_Manager__c: '+Test_Acc[0].Nespon_Manager__c);
            
            lstTSApproval= TimesheetController.getTimesheetForApproval(Test_Acc[0].Nespon_Manager__c , Dtfrom, DtTo);
            lstTSApproval= TimesheetController.getTimesheetForApprovalByEmployeeId(usr.ContactId , Dtfrom, DtTo);
            lstTSView=TimesheetController.getTimesheetToView(Test_Acc[0].Nespon_Manager__c , Dtfrom, DtTo);
            lstTSView=TimesheetController.getTimesheetToViewByEmployeeId(usr.ContactId, Test_Acc[0].Nespon_Manager__c , Dtfrom, DtTo);
            List<Map<String,String>> LstmMap= TimesheetController.getUserListToShowForView(Test_Acc[0].Nespon_Manager__c) ;
             System.debug('LstmMap::: Done');
            List<TimesheetController.TimesheetWrapper> timesheetsToSave= TimesheetController.getTimesheetsUpdateRequestsByEmployeeId(usr.ContactId, Dtfrom, DtTo);
            System.debug('getTimesheetsUpdateRequestsByEmployeeId::: Done');
         
            System.debug('usr.ContactId:::'+usr.ContactId);
            
            
             List<TimesheetController.ComboboxValues> LstComboProject = TimesheetController.getUserProjects(strConId);
            lstTSView= TimesheetController.getUpdateRequestEmployeeList(strConId, Dtfrom, DtTo, 'Current Pay Period');
            
            Map<String,String> mMap = TimesheetController.getUserProjectsParticipantsMap(usr.ContactId);
         //   String ss =TimesheetController.saveRecords(timesheetsToSave,usr.ContactId);
            System.debug('Save Records: '+timesheetsToSave);
          //  List<TimesheetController.TimesheetWrapper> listToSubmit = new List<TimesheetController.TimesheetWrapper>();
          //  List<TimesheetControLstller.TimesheetWrapper> timesheetsToSubmit= TestDataFactoryKL.CreateTimesheetWrapper();
          //  ss =TimesheetController.submitRecords(timesheetsToSubmit,usr.ContactId);
            //  ss= TimesheetController.recallRecords(timesheetsToSubmit,usr.ContactId ,'Reason', Dtfrom,DtTo,  'Current Pay Period'); 
            
            
         
            
           
        }
    
   
         
    }
    
}