@isTest
public class TestDataFactoryKL {
    public static Contact con_NesponManager = new Contact();
    public static Contact con_ProjectManager = new Contact();
    public static List<TimeSheet__c> tsLst = new List<TimeSheet__c>();  // Timesheets List 
    public static User adminUser = new User();
    public static User updateAdminRole(){
        UserRole userrole = [Select Id, DeveloperName From UserRole Where Name = 'Admin' Limit 1];
        adminUser = [Select Id,Name, UserRoleId From User Where Id = :UserInfo.getUserId() Limit 1];
        adminUser.UserRoleId = userRole.Id;
        System.debug(adminUser);
        update adminUser;
        return adminUser;
    }
    
    public static Account createAccount(String Accname,String rt) {
		//Record type required 
        Account acc = new Account();
        acc.Name= Accname;
        acc.RecordTypeId= rt;
		if(acc<> null) {
			insert acc;
		}
       
		return acc;
	}	
	public static Contact createContact(String Accname, String rt,String LName, String FName ) {
		Account acc = createAccount(Accname,rt);
        System.debug('next');
		return createContact(acc.id,LName,FName);
	}
	
	public static Contact createContact(Id accountId,String LName, String FName) {
		
        con_NesponManager.accountId = accountId;
        con_NesponManager.LastName=LName+'Manager';
        con_NesponManager.FirstName=FName+'Manager';
        con_NesponManager.Personal_Email__c='asir.amin@nespon.com';
        con_NesponManager.Email='asir.amin@nespon.com';
		if(con_NesponManager<>null) {
			insert con_NesponManager;
		}
        
        Contact con = new Contact();
        con.accountId = accountId;
        con.LastName=LName;
        con.FirstName=FName;
        con.Personal_Email__c='asir.amin@nespon.com';
        con.Email='asir.amin@nespon.com';
        con.Nespon_Manager__c=con_NesponManager.id;
        
		if(con<>null) {
			insert con;
            System.debug(con);
		}
        Contact con_Employee2 = new Contact();
        con_Employee2.accountId = accountId;
        con_Employee2.LastName=LName+'Emp2';
        con_Employee2.FirstName=FName+'Emp2';
        con_Employee2.Nespon_Manager__c=con.id;
       
        con_ProjectManager=con_Employee2;
		if(con_Employee2 <>null) {
			insert con_Employee2;
		}
        System.debug('Conatct done ');
		return con;
	}
     public static User createCommnuityUser(String AccName,String rt,String firstName,String lastName,String Username,String UFname,String ULname ) {
        	Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
			Contact con =createContact(AccName,rt,firstName,lastName) ;
       		user usr = New User();
            usr.UserName =Username;
            usr.FirstName =UFname;
            usr.LastName =ULname;
            usr.Alias = 'test';
            usr.email = 'HRISTest_Employee@test.com';
            usr.CommunityNickName = 'HRISTest_Employee';
            usr.ProfileID = p.id;
            usr.TimeZoneSidKey = 'America/Los_Angeles';
            usr.LocaleSidKey = 'en_US';
            usr.EmailEncodingKey = 'UTF-8';
            usr.LanguageLocaleKey = 'en_US';
            usr.ContactID = con.Id;
         	//usr.IsPortalEnabled = true;
         	//usr.PortalRole = '00E8I000000F6tb';
            if(usr<>null) {
                insert usr;
			}
			 System.debug('Comm done ');
        	return usr;
	}
    
    public static User createCommnuityUser_Asir(Contact con, String Username,String UFname,String ULname ) {
        	Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
       		user usr = New User();
            usr.UserName =Username;
            usr.FirstName =UFname;
            usr.LastName =ULname;
            usr.Alias = 'test';
            usr.email = 'HRISTest_Employee@test.com';
            usr.CommunityNickName = 'HRISTest_Employee';
            usr.ProfileID = p.id;
            usr.TimeZoneSidKey = 'America/Los_Angeles';
            usr.LocaleSidKey = 'en_US';
            usr.EmailEncodingKey = 'UTF-8';
            usr.LanguageLocaleKey = 'en_US';
            usr.ContactID = con.Id;
            if(usr<>null) {
                System.runAs (adminUser) {
					insert usr;
                }
			}
			 System.debug('Comm done ');
        	return usr;
	}
    
    public static Project__c createProject(String accountId,String ProjectName ,String Dsc,Id PM){
        Project__c proj = new Project__c();
        proj.Name=ProjectName;
        proj.Description__c=Dsc;
        proj.Account__c =accountId;
        proj.Contact__c=con_NesponManager.Id;
        if(proj<>null) {
			insert proj;
            System.debug(proj);
		}
		
		return proj;
	}
    public static  Project_Participants__c createProjPart(String ProjectId,Boolean  Active, String Typepart, String Role,String  Con){
        Project_Participants__c ProjPart =new Project_Participants__c();
        ProjPart.Project__c =ProjectId;
        ProjPart.Active__c=Active;
        ProjPart.Type_of_participation__c=Typepart;
        ProjPart.Role__c=Role;
        ProjPart.Contact__c=Con;
         if(ProjPart<>null) {
			insert ProjPart;
            System.debug(ProjPart);
		}
		
		
        return ProjPart;
    }
	public static List<TimeSheet__c> createTimeSheet(Id AccId,Id conId,String ProjectName,String Dsc,String PCode,String status,String ProjectManger) {
        Project__c proj =createProject(AccId,ProjectName, Dsc,con_NesponManager.Id);
    	Project_Participants__c projPart =createProjPart(proj.Id,True,'Billable','BA',conId);
        
        TimeSheet__c Ts= New  TimeSheet__c();
        Ts.Project__c = proj.Id;
    
        Ts.Hours__c=4;
        //Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today());
        System.debug('Status>>>>>>>>>>>>>>>>>>>>>>'+status);
        //Ts.Status__c='';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        Ts= New  TimeSheet__c();
        //Approval Timesheet
        Ts.Project__c = proj.Id;
    
        Ts.Hours__c=4;
        Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today());
        Ts.Status__c='Submitted and Pending for Approval';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        Ts= New  TimeSheet__c();
        //Approval Timesheet
        Ts.Project__c = proj.Id;
    
        Ts.Hours__c=4;
        Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today());
        Ts.Status__c='Submitted and Pending for Approval';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        Ts= New  TimeSheet__c();
        //Approval Timesheet
        Ts.Project__c = proj.Id;
        Ts.Hours__c=4;
        Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today().addDays(-1));
        Ts.Status__c='Submitted and Pending for Approval';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        Ts= New  TimeSheet__c();
        //Approval Timesheet
        Ts.Project__c = proj.Id;
        Ts.Hours__c=4;
        Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today().addDays(-2));
        Ts.Status__c='Submitted and Pending for Approval';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        Ts= New  TimeSheet__c();
        //Approval Timesheet
        Ts.Project__c = proj.Id;
    
        Ts.Hours__c=4;
        Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today());
        System.debug('Status>>>>>>>>>>>>>>>>>>>>>>'+status);
        Ts.Status__c='Approved';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        Ts= New  TimeSheet__c();
        //Request to Edit
        Ts.Project__c = proj.Id;
    
        Ts.Hours__c=4;
        Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today());
        System.debug('Status>>>>>>>>>>>>>>>>>>>>>>'+status);
        Ts.Status__c='Request to Edit';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        Ts= New  TimeSheet__c();
        //Request to Edit
        Ts.Project__c = proj.Id;
    
        Ts.Hours__c=4;
        Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today());
        System.debug('Status>>>>>>>>>>>>>>>>>>>>>>'+status);
        Ts.Status__c='Request to Edit';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        Ts= New  TimeSheet__c();
        //Request to Edit
        Ts.Project__c = proj.Id;
    
        Ts.Hours__c=4;
        Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today().addDays(-1));
        System.debug('Status>>>>>>>>>>>>>>>>>>>>>>'+status);
        Ts.Status__c='Request to Edit';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        Ts= New  TimeSheet__c();
        //Request to Edit
        Ts.Project__c = proj.Id;
    
        Ts.Hours__c=4;
        Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today().addDays(-2));
        System.debug('Status>>>>>>>>>>>>>>>>>>>>>>'+status);
        Ts.Status__c='Request to Edit';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        Ts= New  TimeSheet__c();
        //Rejected
        Ts.Project__c = proj.Id;
    
        Ts.Hours__c=4;
        //Ts.Pay_Code__c=PCode;
    	Ts.Day__c=  date.valueOf(Date.today());
        System.debug('Status>>>>>>>>>>>>>>>>>>>>>>'+status);
        Ts.Status__c='Rejected';
    	Ts.Contact__c=conId;
        Ts.Project_Participants__c= projPart.id;
        tsLst.add(Ts);
        
        
 		if(tsLst.size() > 0) {
			insert tsLst;
            System.debug(tsLst);
            System.debug('timesheet done ');
		}
    	
        
		return tsLst;
    }
    // using previous Time sheet List 
    public static List<TimesheetController.TimesheetWrapper> CreateTimesheetWrapper(){
       	List<TimesheetController.TimesheetWrapper>  timeSheetsListToSave = new List<TimesheetController.TimesheetWrapper>();
    	for(TimeSheet__c singleTimesheet : tsLst) {
                   TimesheetController.TimesheetWrapper ts = new TimesheetController.TimesheetWrapper();
                   
            		ts.contactId = singleTimesheet.Contact__c ;
                    ts.project = singleTimesheet.project__c;
                    ts.hours = singleTimesheet.Hours__c;
                    ts.dayDate = singleTimesheet.Day__c;
                   // ts.Status__c = '';
                    if(singleTimesheet.id != null) {
                        ts.Id = singleTimesheet.id;
                    }
                    ts.payCode = singleTimesheet.Pay_Code__c;
                    ts.projectParticipantId =tsLst[0].Project_Participants__c;
                    //
                    // Ts.Project__c = proj.Id;
            
            
            timeSheetsListToSave.add(ts);
                }
        return timeSheetsListToSave;
    }
    
    
}