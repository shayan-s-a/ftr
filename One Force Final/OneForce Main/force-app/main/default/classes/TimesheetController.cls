public class TimesheetController { 
    
    @AuraEnabled(cacheable=true)
    public static String getImageUrl(String conId)
    {
        List<User> url = [SELECT MediumPhotoUrl FROM User WHERE ContactId =: conId LIMIT 1];
        System.debug(url[0].MediumPhotoUrl);
        return url[0].MediumPhotoUrl;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> getUserDetails(String userId) {
        Map<String,String> userDetails = new Map<String,String>();
        try {
            System.debug(':::: userId: ' + userId);
            String finalContactId;
            if(userId.startsWith('003')) {
                finalContactId = userId;
            } else {
                
                finalContactId = [SELECT Id, ContactId FROM User
                                    WHERE Id =: userId]?.ContactId;
            }

            if(String.isNotBlank(finalContactId)) {
                System.debug(':::: user: ' + finalContactId);
 
                // Date weekStartDate = Date.today().toStartofWeek();
                
                // Date dateFrom = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
                // Date dateTo = dateFrom + 13;
                Date weekStartDate = Date.today().toStartofWeek();
            
                Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
                Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
                Date dateTo = dateFrom.addDays(13); // NEW WORK SAME AS ADP

                System.debug(':::: getUserDetails dateFrom: ' + dateFrom);
                System.debug('::::  getUserDetails dateTo: ' + dateTo);

                List<Contact> conList = [SELECT Id, Salutation, FirstName, LastName, Email, 
                                        PhotoUrl, AccountId, Account.Name, Account.Divisional_Head__c,
                                        Employee_ID__c, Personal_Email__c,
                                        Designation__c,
                                        Position_Id__c, ReportsTo.Name, Tax_ID_SSN__c, Functional_Area__r.Name,
                                        Job_Title_Description__c, Resources_Status__c, Hire_Date__c
                                        FROM Contact
                                        WHERE Id =: finalContactId];
                if(!conList.isEmpty()) {
                    Contact con = conList[0];
                    System.debug(':::: con: ' + con);
                    userDetails.put('Id', con.Id);
                    userDetails.put('Salutation', con.Salutation);
                    userDetails.put('FullName', con.LastName + ', ' + con.FirstName);
                    userDetails.put('NameInitials', con.LastName.substring(0,1) + con.FirstName.substring(0,1));
                    userDetails.put('FirstName', con.FirstName);
                    userDetails.put('LastName', con.LastName);
                    userDetails.put('ResourceStatus', con.Resources_Status__c);
                    userDetails.put('HireDate', String.valueOf(con.Hire_Date__c));
                    userDetails.put('Email', con.Email);
                    userDetails.put('PhotoUrl', con.PhotoUrl);
                    userDetails.put('AccountId', con.AccountId);
                    userDetails.put('Employee_ID__c', con.Employee_ID__c);
                    userDetails.put('Designation', con.Employee_Id__c + ' - ' + (con.Job_Title_Description__c != null ? con.Job_Title_Description__c : ''));
                    userDetails.put('dateFrom', String.valueOf(dateFrom));
                    userDetails.put('dateTo', String.valueOf(dateTo));
                    
                    userDetails.put('TaxId', con.Tax_ID_SSN__c);
                    userDetails.put('Role', '');
                    userDetails.put('RegionalOffice', '');
                    userDetails.put('DivisionalOffice', con.Account.Name);
                    userDetails.put('FunctionalArea', con.Functional_Area__r.Name);
                    userDetails.put('ReportsTo', con.ReportsTo.Name);
                    userDetails.put('PositionId', con.Position_Id__c);
                    userDetails.put('weekStartDate', String.valueOf(weekStartDate));
                    userDetails.put('weekEndDate', String.valueOf(weekStartDate.addDays(6)));
                    
                    // // * Check if the current user is Divisional Head of any Account
                    // List<Account> divisionalHeadAcc = [SELECT Id FROM Account
                    //                                     WHERE Divisional_Head__c =: con.Id];

                    userDetails.put('IsDivisionalHead', con.Account.Divisional_Head__c == con.Id ? 'true' : 'false');

                    // * Check if the current user is HR Practitioner or not
                    List<HR_Practitioner__mdt> hrPractitioners = [SELECT DeveloperName, Position_Id__c, Email__c FROM HR_Practitioner__mdt
                                                                WHERE Email__c =: con.Personal_Email__c];

                    userDetails.put('IsHRPractitioner', !hrPractitioners.isEmpty() ? 'true' : 'false');
                    // List<HR_Practitioner__mdt> hrPractitioners = [SELECT DeveloperName, Position_Id__c, Email__c FROM HR_Practitioner__mdt];
                    // userDetails.put('isHRPractitioner', 'false');
                    // for(HR_Practitioner__mdt m : hrPractitioners) {
                    //     if(m.Email__c == con.Personal_Email__c) {
                    //         userDetails.put('isHRPractitioner', 'true');                            
                    //     }
                    // }

                    // * Check if the current user is Manager of any Employee or not
                    List<Contact> conManager = [SELECT Id, Name FROM Contact
                                                WHERE Nespon_Manager__c =: con.Id];

                    System.debug(':::: conManager: ' + conManager);
                    userDetails.put('isNesponManager', !conManager.isEmpty() ? 'true' : 'false');

                    // * Check if any timesheet is waiting for approval
                    List<TimeSheet__c> timesheetForApprRej = [SELECT Id FROM TimeSheet__c
                                                            WHERE Contact__r.Nespon_Manager__c =: con.Id
                                                            AND Status__c = 'Submitted and Pending for Approval'];

                    System.debug(':::: timesheetForApprRej: ' + timesheetForApprRej.size());
                    userDetails.put('employeeTimesheetsFound', !timesheetForApprRej.isEmpty() ? 'true' : 'false');

                    // * Check if the current user is Manager in any of the Projects
                    List<Project__c> projectManager = [SELECT Id FROM Project__c
                                                    WHERE Contact__c =: con.Id];
                                                    
                    System.debug(':::: projectManager: ' + projectManager);
                    userDetails.put('isLineManager', !projectManager.isEmpty() ? 'true' : 'false');

                    List<TimeSheet__c> timesheetRequests = [SELECT Id FROM TimeSheet__c
                                                            WHERE Status__c = 'Request to Edit'
                                                            AND Contact__r.Nespon_Manager__c =: con.Id];
                    if(!timesheetRequests.isEmpty()) {
                        userDetails.put('requestFound', 'true');
                    }

                    
                }
            }
            return userDetails;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' On Line: ' + e.getLineNumber());
        }
    }

// new method add by Bilal
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getDivisonalOffices(String userId, Boolean isNesponManager, Boolean isDivisionalHead, Boolean isHRPractitioner) {
        try {
            Map<String,String> divisionalOfficeMap = new Map<String,String>();
            divisionalOfficeMap.put('','--None--');
            // Schema.DescribeSObjectResult objectDescribe = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
            // Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = objectDescribe.;

            // // Get the record types by their names
            // Schema.RecordTypeInfo headOfficeRecTypeInfo = recordTypeInfoMap.get('Head Office Account');
            String headOfficeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office Account').getRecordTypeId();
            String DivisionalOfficeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Divisional Office Account').getRecordTypeId();
            // Schema.RecordTypeInfo divOfficeRecTypeInfo = recordTypeInfoMap.get('Divisional Office Account');
            // List<String> divisionalOfficeIds = new List<String>();
            // divisionalOfficeIds.add(headOfficeRecTypeInfo.getRecordTypeId());
            // divisionalOfficeIds.add(divOfficeRecTypeInfo.getRecordTypeId());

            // for(Account rec : [SELECT ID, Name, RecordTypeId, RecordType.Name FROM Account WHERE RecordTypeId in :divisionalOfficeIds AND Divisonal_Head__c =: ]){
            List<User> loggedInUser = [SELECT ContactId, Contact.AccountId FROM User WHERE Id =: userId];
                Set<String> accIds = new Set<String>();
            if(isNesponManager) {
                List<Contact> conList = [SELECT Id, AccountId, Nespon_Manager__c FROM Contact
                                        WHERE Nespon_Manager__c =: loggedInUser[0].ContactId];
                for(Contact c: conList) {
                    accIds.add(c.AccountId);
                }

                List<Account> accList = [SELECT Name FROM Account 
                                        WHERE Id IN: accIds];
                for(Account rec : accList) {
                    divisionalOfficeMap.put(rec.Name,rec.Name);
                }
            }
            if(isDivisionalHead) {
                List<Account> accList = [SELECT Name FROM Account 
                                        WHERE Divisional_Head__c =: loggedInUser[0].ContactId];
                for(Account rec : accList) {
                    divisionalOfficeMap.put(rec.Name,rec.Name);
                }
            } 
            if(isHRPractitioner) {
                List<Account> accList = [SELECT Name FROM Account 
                                        WHERE RecordTypeId =: headOfficeRecTypeId OR RecordTypeId =: DivisionalOfficeRecTypeId];
                for(Account rec : accList) {
                    divisionalOfficeMap.put(rec.Name,rec.Name);
                }
            }

            return divisionalOfficeMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()  + e.getLineNumber());
        }
    }

 //Asir adding new method to find user by using contact Id (add by Bilal)
 @AuraEnabled(cacheable=true)
 public static Map<String,String> getUserDetailsByContactId(String conId) {
     Map<String,String> userDetails = new Map<String,String>();
     try {
         // Date weekStartDate = Date.today().toStartofWeek();
         
         // Date dateFrom = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
         // Date dateTo = dateFrom + 13;
         Date weekStartDate = Date.today().toStartofWeek();
     
         Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
         Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
         Date dateTo = dateFrom.addDays(13); // NEW WORK SAME AS ADP

         System.debug(':::: getUserDetails dateFrom: ' + dateFrom);
         System.debug('::::  getUserDetails dateTo: ' + dateTo);

         List<Contact> conList = [SELECT Id, Salutation, FirstName, LastName, Email, 
                                 PhotoUrl, AccountId, Account.Name, 
                                 Employee_ID__c, 
                                 Designation__c,
                                 Position_Id__c, ReportsTo.Name, Tax_ID_SSN__c, Functional_Area__r.Name,
                                 Job_Title_Description__c
                                 FROM Contact
                                 WHERE Id =: conId];
         if(!conList.isEmpty()) {
             Contact con = conList[0];
             System.debug(':::: con: ' + con);
             userDetails.put('Id', con.Id);
             userDetails.put('Salutation', con.Salutation);
             userDetails.put('FullName', con.LastName + ', ' + con.FirstName);
             userDetails.put('NameInitials', con.LastName.substring(0,1) + con.FirstName.substring(0,1));
             userDetails.put('FirstName', con.FirstName);
             userDetails.put('LastName', con.LastName);
             userDetails.put('Email', con.Email);
             userDetails.put('PhotoUrl', con.PhotoUrl);
             userDetails.put('AccountId', con.AccountId);
             userDetails.put('Employee_ID__c', con.Employee_ID__c);
             userDetails.put('Designation', con.Employee_Id__c + ' - ' + (con.Job_Title_Description__c != null ? con.Job_Title_Description__c : ''));
             userDetails.put('dateFrom', String.valueOf(dateFrom));
             userDetails.put('dateTo', String.valueOf(dateTo));
             
             userDetails.put('TaxId', con.Tax_ID_SSN__c);
             userDetails.put('Role', '');
             userDetails.put('RegionalOffice', '');
             userDetails.put('DivisionalOffice', con.Account.Name);
             userDetails.put('FunctionalArea', con.Functional_Area__r.Name);
             userDetails.put('ReportsTo', con.ReportsTo.Name);
             userDetails.put('PositionId', con.Position_Id__c);
             
             // * Check if the current user is Manager of any Employee or not
             List<Contact> conManager = [SELECT Id, Name FROM Contact
                                         WHERE Nespon_Manager__c =: con.Id];

             System.debug(':::: conManager: ' + conManager);
             userDetails.put('isNesponManager', !conManager.isEmpty() ? 'true' : 'false');

             // * Check if any timesheet is waiting for approval
             List<TimeSheet__c> timesheetForApprRej = [SELECT Id FROM TimeSheet__c
                                                     WHERE Contact__r.Nespon_Manager__c =: con.Id
                                                     AND Status__c = 'Submitted and Pending for Approval'];

             System.debug(':::: timesheetForApprRej: ' + timesheetForApprRej.size());
             userDetails.put('employeeTimesheetsFound', !timesheetForApprRej.isEmpty() ? 'true' : 'false');

             // * Check if the current user is Manager in any of the Projects
             List<Project__c> projectManager = [SELECT Id FROM Project__c
                                             WHERE Contact__c =: con.Id];
                                             
             System.debug(':::: projectManager: ' + projectManager);
             userDetails.put('isLineManager', !projectManager.isEmpty() ? 'true' : 'false');

             List<TimeSheet__c> timesheetRequests = [SELECT Id FROM TimeSheet__c
                                                     WHERE Status__c = 'Request to Edit'
                                                     AND Contact__r.Nespon_Manager__c =: con.Id];
             if(!timesheetRequests.isEmpty()) {
                 userDetails.put('requestFound', 'true');
             }
         }
         return userDetails;
     } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());
     }
 }

 //Asir adding new method for unlocking timesheet (add by Bilal)    
 @AuraEnabled(cacheable=true)
 public Static List<TimesheetWrapper> getTimesheetByDateByEmployee(String conId, Date dateFromParam, Date dateToParam, String timeOption , String status, String screen) {
     try {
         System.debug(':::: getTimesheetByDate conId: ' + conId);
         Date weekStartDate = Date.today().toStartofWeek();
         
         Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
         initialWeekStartDate = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
         Date initialWeekEndDate = initialWeekStartDate.addDays(13);
         Date finalDateFrom; 
         Date finalDateTo;


         if(dateFromParam != null) {
             finalDateFrom = dateFromParam;
         } else {
             finalDateFrom = initialWeekStartDate;
         }
         if(dateToParam != null) {
             finalDateTo = dateToParam;
         } else {
             finalDateTo = initialWeekEndDate;
         }
         
         if(timeOption == 'Current Pay Period') {
             finalDateFrom = initialWeekStartDate;
             finalDateTo = initialWeekEndDate;
         }
         else if(timeOption == 'Next Pay Period') {
             finalDateFrom = initialWeekStartDate.addDays(14);
             finalDateTo = finalDateFrom.addDays(13);
         }
         else if(timeOption == 'Previous Pay Period') {
             finalDateFrom = initialWeekStartDate.addDays(-14);
             finalDateTo = finalDateFrom.addDays(13);
         }

         System.debug(':::: dateFrom: ' + finalDateFrom);
         System.debug(':::: dateTo: ' + finalDateTo);

         List<TimesheetWrapper> finalResponse = new List<TimesheetWrapper>();
         List<TimeSheet__c> timesheetList = new List<TimeSheet__c>();
         if (status=='viewonly' || status=='Submitted and Pending for Approval' || status=='Request to Edit') {
            timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                             Project__r.Name,
                                             Hours__c, Overtime__c, Overtime_from__c, Overtime_to__c, Total_overtime__c, Type_of_hour__c, Description__c, Pay_Code__c, Final_Hours__c,
                                             Status__c, Contact__r.Name,
                                             Contact__r.Account.Name,
                                             Type_of_participation__c,
                                             Project_Participants__c,
                                             Project_Participants__r.Role__c,
                                             Reason_For_Rejection__c,

/////////////
                                            Rejected_By__c, Rejection_Date__c,
                                            Rejected_By__r.Position_Id__c,
                                            Rejected_By__r.FirstName, Rejected_By__r.LastName, 

/////////////
                                             Approved_By__c, Approval_Date__c,
                                            Approved_By__r.Position_Id__c,
                                            Approved_By__r.FirstName, Approved_By__r.LastName
                                             FROM TimeSheet__c
                                             WHERE Contact__c =: conId 
                                             AND Day__c >=: finalDateFrom
                                             AND Day__c <=: finalDateTo];
         }
         else{
            timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                Project__r.Name,
                                Hours__c, Overtime__c, Overtime_from__c, Overtime_to__c, Total_overtime__c, Type_of_hour__c, Description__c, Pay_Code__c, Final_Hours__c,
                                Status__c, Contact__r.Name,
                                Contact__r.Account.Name,
                                Type_of_participation__c,
                                Project_Participants__c,
                                Project_Participants__r.Role__c,
                                Reason_For_Rejection__c,

                               /////////////
                               Rejected_By__c, Rejection_Date__c,
                               Rejected_By__r.Position_Id__c,
                               Rejected_By__r.FirstName, Rejected_By__r.LastName, 
                               
                               /////////////


                                Approved_By__c, Approval_Date__c,
                            Approved_By__r.Position_Id__c,
                            Approved_By__r.FirstName, Approved_By__r.LastName
                                FROM TimeSheet__c
                                WHERE Contact__c =: conId AND Status__c = :status
                                AND Day__c >=: finalDateFrom
                                AND Day__c <=: finalDateTo];
         }
        //  else if (status=='Request to Edit') {
            // timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
            //                     Project__r.Name,
            //                     Hours__c, Overtime__c, Pay_Code__c, Final_Hours__c,
            //                     Status__c, Contact__r.Name,
            //                     Contact__r.Account.Name,
            //                     Type_of_participation__c,
            //                     Project_Participants__c,
            //                     Project_Participants__r.Role__c,
            //                     Reason_For_Rejection__c,
            //                     Approved_By__c, Approval_Date__c,
            //                 Approved_By__r.Position_Id__c,
            //                 Approved_By__r.FirstName, Approved_By__r.LastName
            //                     FROM TimeSheet__c
            //                     WHERE Contact__c =: conId AND Status__c = 'Request to Edit'
            //                     AND Day__c >=: finalDateFrom
            //                     AND Day__c <=: finalDateTo];
        //  }
        //  else if (status=='Submitted and Pending for Approval') {
        //     timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
        //                         Project__r.Name,
        //                         Hours__c, Overtime__c, Pay_Code__c, Final_Hours__c,
        //                         Status__c, Contact__r.Name,
        //                         Contact__r.Account.Name,
        //                         Type_of_participation__c,
        //                         Project_Participants__c,
        //                         Project_Participants__r.Role__c,
        //                         Reason_For_Rejection__c,
        //                         Approved_By__c, Approval_Date__c,
        //                     Approved_By__r.Position_Id__c,
        //                     Approved_By__r.FirstName, Approved_By__r.LastName
        //                         FROM TimeSheet__c
        //                         WHERE Contact__c =: conId AND Status__c = 'Submitted and Pending for Approval'
        //                         AND Day__c >=: finalDateFrom
        //                         AND Day__c <=: finalDateTo];
        //  }
         
         System.debug('@@getTimesheetByDateByEmployee: '+timesheetList);

         List<ComboboxValues> userProjects = getUserProjects(conId);
         //List<ComboboxValues> payCodes = getPayCodeValues();
         List<ComboboxValues> payCodes= new List<ComboboxValues>();

         System.debug(':::: userProjects: ' + userProjects);

         Map<Date,List<TimesheetWrapper>> day_timsheets_map = new Map<Date,List<TimesheetWrapper>>();
         if(!timesheetList.isEmpty()) {
             for(TimeSheet__c t: timesheetList) {
                 if(day_timsheets_map.get(t.Day__c) == null || day_timsheets_map.get(t.Day__c).isEmpty()) {
                     TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false, screen);
                     day_timsheets_map.put(t.Day__c, new List<TimesheetWrapper>{ singleTimesheetByDay });
                 }
                 else {
                     List<TimesheetWrapper> finalTimesheetByDay = day_timsheets_map.get(t.Day__c);
                     TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false, screen);
                     finalTimesheetByDay.add(singleTimesheetByDay);
                     day_timsheets_map.put(t.Day__c, finalTimesheetByDay);
                 }
             }
         }

         Integer daysBetween = finalDateFrom.daysBetween(finalDateTo) + 1;
         Decimal weekSum = 0;
         Integer weekNum = 1;
         for(Integer i = 0; i < daysBetween; i++) {

             if(day_timsheets_map.get(finalDateFrom + i) != null) {
                 // For Summary Row
                 if(day_timsheets_map.get(finalDateFrom + i).size() > 1) {
                     Decimal totalHours = 0;
                     Integer totalCount = 0;
                     for(TimesheetWrapper t : day_timsheets_map.get(finalDateFrom + i)) {
                        if (t.overTime){
                            weekSum += t.hours + t.totalOvertimeHours;
                            totalHours += t.hours + t.totalOvertimeHours;
                        }
                        else{
                            totalHours += t.hours;
                            weekSum += t.hours;
                        }
                         totalCount++;
                     }
                     // TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                     // newSummaryTimesheet.totalhoursInDay = totalHours;
                     // newSummaryTimesheet.showEachRowTotal = false;
                     // newSummaryTimesheet.totalRowsInDay = totalCount;
                     // newSummaryTimesheet.summaryRow = true;
                     // newSummaryTimesheet.dayName = getDayName(finalDateFrom + i);
                     // day_timsheets_map.get(finalDateFrom + i).add(newSummaryTimesheet);
                     
                     // * For Showing Sum of All Time Entries in a Day on Last Row
                     day_timsheets_map.get(finalDateFrom + i)[day_timsheets_map.get(finalDateFrom + i).size() - 1].totalHours = totalHours;
                     day_timsheets_map.get(finalDateFrom + i)[day_timsheets_map.get(finalDateFrom + i).size() - 1].showEachRowTotal = true;
                     finalResponse.addAll(day_timsheets_map.get(finalDateFrom + i));
                     
                     // * Add Weekly Sum Row
                     if(getDayName(finalDateFrom + i) == 'Saturday') {
                         TimesheetWrapper weekSumRow = new TimesheetWrapper();
                         weekSumRow.totalHours = weekSum;
                         weekSumRow.weeklySumRow = true;
                         weekSumRow.weekNumber = weekNum;
                         finalResponse.add(weekSumRow); 
                         weekSum = 0;
                         weekNum += 1;
                     }
                 }
                 else {
                     day_timsheets_map.get(finalDateFrom + i)[0].showEachRowTotal = true;  
                     if(day_timsheets_map.get(finalDateFrom + i)[0].overTime){
                        day_timsheets_map.get(finalDateFrom + i)[0].totalHours = day_timsheets_map.get(finalDateFrom + i)[0].hours + day_timsheets_map.get(finalDateFrom + i)[0].totalOvertimeHours;
                        weekSum += day_timsheets_map.get(finalDateFrom + i)[0].hours + day_timsheets_map.get(finalDateFrom + i)[0].totalOvertimeHours;
                    }
                    else{
                        // day_timsheets_map.put(finalDateFrom + i)[0].totalHours = day_timsheets_map.get(finalDateFrom + i)[0].hours;
                        weekSum += day_timsheets_map.get(finalDateFrom + i)[0].hours;    
                    } 
                     finalResponse.addAll(day_timsheets_map.get(finalDateFrom + i));
                    //  weekSum += day_timsheets_map.get(finalDateFrom + i)[0].hours;
                     
                     // * Add Weekly Sum Row
                     if(getDayName(finalDateFrom + i) == 'Saturday') {
                         TimesheetWrapper weekSumRow = new TimesheetWrapper();
                         weekSumRow.totalHours = weekSum;
                         weekSumRow.weeklySumRow = true;
                         weekSumRow.weekNumber = weekNum;
                         finalResponse.add(weekSumRow); 
                         weekSum = 0;
                         weekNum += 1;
                     }
                 }
             }
             else {
                 //Asir edit here to handle checkbox on timesheet row
                 Date dateToInsert = finalDateFrom + i;
                 TimesheetWrapper emptyTimesheetRow = new TimesheetWrapper();
                 emptyTimesheetRow.dayDate = finalDateFrom + i;
                 emptyTimesheetRow.dayName = getDayName(finalDateFrom + i);
                 emptyTimesheetRow.projects = userProjects;
                 emptyTimesheetRow.payCodes = payCodes;
                 emptyTimesheetRow.month =getMonthName(dateToInsert);
                 emptyTimesheetRow.year = dateToInsert.year();
                 emptyTimesheetRow.overTime = false;
                 emptyTimesheetRow.empty= true;
                 emptyTimesheetRow.inEditMode = false;
                 emptyTimesheetRow.emptyRowNumber = i;
                 emptyTimesheetRow.isEditable = true;
                 emptyTimesheetRow.disableCheckbox = true;
                 finalResponse.add(emptyTimesheetRow);

                 // * Add Weekly Sum Row
                 if(getDayName(finalDateFrom + i) == 'Saturday') {
                     TimesheetWrapper weekSumRow = new TimesheetWrapper();
                     weekSumRow.totalHours = weekSum;
                     weekSumRow.weeklySumRow = true;
                     weekSumRow.weekNumber = weekNum;
                     finalResponse.add(weekSumRow); 
                     weekSum = 0;
                     weekNum += 1;
                 }
             }

             // * If this is the Last Row and Last Day is Not Saturday
             if(i == (daysBetween - 1)) {
                 if(getDayName(finalDateFrom + i) != 'Saturday') {
                     TimesheetWrapper weekSumRow = new TimesheetWrapper();
                     weekSumRow.totalHours = weekSum;
                     weekSumRow.weeklySumRow = true;
                     weekSumRow.weekNumber = weekNum;
                     finalResponse.add(weekSumRow); 
                 }
             }
         }
         return finalResponse;
     } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());
     }
 }

//done 
    @AuraEnabled(cacheable=true)
    public Static List<TimesheetWrapper> getTimesheetByDate(String conId, Date dateFromParam, Date dateToParam, String timeOption) {
        try {
            System.debug(':::: getTimesheetByDate conId: ' + conId);
            Date weekStartDate = Date.today().toStartofWeek();
            ////////////////////////
            Integer daysDifference = dateFromParam.daysBetween( dateToParam );
            Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
            initialWeekStartDate = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
            Date initialWeekEndDate = initialWeekStartDate.addDays(13);
            Date finalDateFrom; 
            Date finalDateTo;


            if(dateFromParam != null) {
                finalDateFrom = dateFromParam;
            } else {
                finalDateFrom = initialWeekStartDate;
            }
            if(dateToParam != null) {
                finalDateTo = dateToParam;
            } else {
                finalDateTo = initialWeekEndDate;
            }
            
            if(timeOption == 'Current Pay Period') {
                finalDateFrom = initialWeekStartDate;
                finalDateTo = initialWeekEndDate;
            }
            else if(timeOption == 'Next Pay Period') {
                finalDateFrom = initialWeekStartDate.addDays(14);
                finalDateTo = finalDateFrom.addDays(13);
            }
            else if(timeOption == 'Previous Pay Period') {
                finalDateFrom = initialWeekStartDate.addDays(-14);
                finalDateTo = finalDateFrom.addDays(13);
            }

            System.debug(':::: dateFrom: ' + finalDateFrom);
            System.debug(':::: dateTo: ' + finalDateTo);

            List<TimesheetWrapper> finalResponse = new List<TimesheetWrapper>();
            ///////////////////////////////
            List<TimeSheet__c> timesheetList = new List<TimeSheet__c>();
            if(daysDifference <= 62){
                timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                                Project__r.Name,
                                                Hours__c, Overtime__c, Overtime_from__c, Overtime_to__c, Total_overtime__c, Pay_Code__c, Final_Hours__c,
                                                Status__c, Contact__r.Name, Type_of_hour__c, Description__c,
                                                Contact__r.Account.Name,
                                                Type_of_participation__c,
                                                Project_Participants__c,
                                                Project_Participants__r.Role__c,
                                                Reason_For_Rejection__c,
                                                /////////////
                                                Rejected_By__c, Rejection_Date__c,
                                                Rejected_By__r.Position_Id__c,
                                                Rejected_By__r.FirstName, Rejected_By__r.LastName, 
                                                
                                                /////////////



                                                Approved_By__c, Approval_Date__c,
                                                Approved_By__r.Position_Id__c,
                                                Approved_By__r.FirstName, Approved_By__r.LastName
                                                FROM TimeSheet__c
                                                WHERE Contact__c =: conId
                                                AND Day__c >=: finalDateFrom
                                                AND Day__c <=: finalDateTo];
            }

            List<ComboboxValues> userProjects = getUserProjects(conId);
            //List<ComboboxValues> payCodes = getPayCodeValues();
            List<ComboboxValues> payCodes= new List<ComboboxValues>();

            System.debug(':::: userProjects: ' + userProjects);

            Map<Date,List<TimesheetWrapper>> day_timsheets_map = new Map<Date,List<TimesheetWrapper>>();
            if(!timesheetList.isEmpty()) {
                for(TimeSheet__c t: timesheetList) {
                    if(day_timsheets_map.get(t.Day__c) == null || day_timsheets_map.get(t.Day__c).isEmpty()) {
                        TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false,'');
                        day_timsheets_map.put(t.Day__c, new List<TimesheetWrapper>{ singleTimesheetByDay });
                    }
                    else {
                        List<TimesheetWrapper> finalTimesheetByDay = day_timsheets_map.get(t.Day__c);
                        TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false,'');
                        finalTimesheetByDay.add(singleTimesheetByDay);
                        day_timsheets_map.put(t.Day__c, finalTimesheetByDay);
                    }
                }
            }

            Integer daysBetween = finalDateFrom.daysBetween(finalDateTo) + 1;
            Decimal weekSum = 0;
            Integer weekNum = 1;
            /////////////////////////////
            if (daysDifference <= 62){

                for(Integer i = 0; i < daysBetween; i++) {
    
                    if(day_timsheets_map.get(finalDateFrom + i) != null) {
                        // For Summary Row
                        if(day_timsheets_map.get(finalDateFrom + i).size() > 1) {
                            Decimal totalHours = 0;
                            Integer totalCount = 0;
                            for(TimesheetWrapper t : day_timsheets_map.get(finalDateFrom + i)) {
                                if (t.overTime){
                                    weekSum += t.hours + t.totalOvertimeHours;
                                    totalHours += t.hours + t.totalOvertimeHours;
                                }
                                else{
                                    totalHours += t.hours;
                                    weekSum += t.hours;
                                }
                                totalCount++;
                            }
                            // TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                            // newSummaryTimesheet.totalhoursInDay = totalHours;
                            // newSummaryTimesheet.showEachRowTotal = false;
                            // newSummaryTimesheet.totalRowsInDay = totalCount;
                            // newSummaryTimesheet.summaryRow = true;
                            // newSummaryTimesheet.dayName = getDayName(finalDateFrom + i);
                            // day_timsheets_map.get(finalDateFrom + i).add(newSummaryTimesheet);
                            
                            // * For Showing Sum of All Time Entries in a Day on Last Row
                            day_timsheets_map.get(finalDateFrom + i)[day_timsheets_map.get(finalDateFrom + i).size() - 1].totalHours = totalHours;
                            day_timsheets_map.get(finalDateFrom + i)[day_timsheets_map.get(finalDateFrom + i).size() - 1].showEachRowTotal = true;
                            finalResponse.addAll(day_timsheets_map.get(finalDateFrom + i));
                            
                            // * Add Weekly Sum Row
                            if(getDayName(finalDateFrom + i) == 'Saturday') {
                                TimesheetWrapper weekSumRow = new TimesheetWrapper();
                                weekSumRow.totalHours = weekSum;
                                weekSumRow.weeklySumRow = true;
                                weekSumRow.weekNumber = weekNum;
                                finalResponse.add(weekSumRow); 
                                weekSum = 0;
                                weekNum += 1;
                            }
                        }
                        else {
                            day_timsheets_map.get(finalDateFrom + i)[0].showEachRowTotal = true;
                            if(day_timsheets_map.get(finalDateFrom + i)[0].overTime){
                                day_timsheets_map.get(finalDateFrom + i)[0].totalHours = day_timsheets_map.get(finalDateFrom + i)[0].hours + day_timsheets_map.get(finalDateFrom + i)[0].totalOvertimeHours;
                                weekSum += day_timsheets_map.get(finalDateFrom + i)[0].hours + day_timsheets_map.get(finalDateFrom + i)[0].totalOvertimeHours;
                            }
                            else{
                                // day_timsheets_map.put(finalDateFrom + i)[0].totalHours = day_timsheets_map.get(finalDateFrom + i)[0].hours;
                                weekSum += day_timsheets_map.get(finalDateFrom + i)[0].hours;    
                            }
                            finalResponse.addAll(day_timsheets_map.get(finalDateFrom + i));
                            // weekSum += day_timsheets_map.get(finalDateFrom + i)[0].hours;
                            
                            // * Add Weekly Sum Row
                            if(getDayName(finalDateFrom + i) == 'Saturday') {
                                TimesheetWrapper weekSumRow = new TimesheetWrapper();
                                weekSumRow.totalHours = weekSum;
                                weekSumRow.weeklySumRow = true;
                                weekSumRow.weekNumber = weekNum;
                                finalResponse.add(weekSumRow); 
                                weekSum = 0;
                                weekNum += 1;
                            }
                        }
                    }
                    else {
                        TimesheetWrapper emptyTimesheetRow = new TimesheetWrapper();
                        emptyTimesheetRow.dayDate = finalDateFrom + i;
                        emptyTimesheetRow.dayName = getDayName(finalDateFrom + i);
                        emptyTimesheetRow.projects = userProjects;
                        emptyTimesheetRow.payCodes = payCodes;
                        emptyTimesheetRow.overTime = false;
                        emptyTimesheetRow.inEditMode = false;
                        emptyTimesheetRow.isEmptyRow = true;
                        emptyTimesheetRow.emptyRowNumber = i;
                        emptyTimesheetRow.isEditable = true;
                        finalResponse.add(emptyTimesheetRow);
    
                        // * Add Weekly Sum Row
                        if(getDayName(finalDateFrom + i) == 'Saturday') {
                            TimesheetWrapper weekSumRow = new TimesheetWrapper();
                            weekSumRow.totalHours = weekSum;
                            weekSumRow.weeklySumRow = true;
                            weekSumRow.weekNumber = weekNum;
                            finalResponse.add(weekSumRow); 
                            weekSum = 0;
                            weekNum += 1;
                        }
                    }
    
                    // * If this is the Last Row and Last Day is Not Saturday
                    if(i == (daysBetween - 1)) {
                        if(getDayName(finalDateFrom + i) != 'Saturday') {
                            TimesheetWrapper weekSumRow = new TimesheetWrapper();
                            weekSumRow.totalHours = weekSum;
                            weekSumRow.weeklySumRow = true;
                            weekSumRow.weekNumber = weekNum;
                            finalResponse.add(weekSumRow); 
                        }
                    }
                }
            }
            return finalResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

//done 
    @AuraEnabled(cacheable=true)
    public Static List<TimesheetWrapper> getTimesheetForApproval(String conId, Date dateFromParam, Date dateToParam) {
        try {
            System.debug(':::: getTimesheetForApproval conId: ' + conId);

            Date weekStartDate = Date.today().toStartofWeek();
            Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
            Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
            Date dateTo = dateFrom.addDays(13);

            if(dateFromParam != null) {
                dateFrom = dateFromParam;
            } 
            if(dateToParam != null) {
                dateTo = dateToParam;
            }

            System.debug(':::: dateFrom: ' + dateFrom);
            System.debug(':::: dateTo: ' + dateTo);

            List<TimesheetWrapper> finalResponse = new List<TimesheetWrapper>();
            List<TimeSheet__c> timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                                Project__r.Name,
                                                Hours__c, Overtime__c, Pay_Code__c, Final_Hours__c,
                                                Status__c, Contact__r.Name,
                                                Contact__r.Account.Name,
                                                Type_of_participation__c,
                                                Project_Participants__c,
                                                Project_Participants__r.Role__c,
                                                Reason_For_Rejection__c,

                                                /////////////
                                                Rejected_By__c, Rejection_Date__c,
                                                Rejected_By__r.Position_Id__c,
                                                Rejected_By__r.FirstName, Rejected_By__r.LastName, 
                                                
                                                /////////////
                                                






                                                Approved_By__c, Approval_Date__c,
                                                Approved_By__r.Position_Id__c,
                                                Approved_By__r.FirstName, Approved_By__r.LastName
                                                FROM TimeSheet__c
                                                WHERE Contact__r.Nespon_Manager__c =: conId
                                                AND Status__c = 'Submitted and Pending for Approval'
                                                AND Day__c >=: dateFrom
                                                AND Day__c <=: dateTo];
            System.debug(':::: timesheetList.size: ' + timesheetList.size());
            if(!timesheetList.isEmpty()) {
                List<ComboboxValues> userProjects = getUserProjects(conId);
                //List<ComboboxValues> payCodes = getPayCodeValues();
                List<ComboboxValues> payCodes= new List<ComboboxValues>();

                System.debug(':::: userProjects: ' + userProjects);

                // Map<Date,List<TimesheetWrapper>> day_timsheets_map = new Map<Date,List<TimesheetWrapper>>();
                Map<String,List<TimesheetWrapper>> dayUser_timsheets_map = new Map<String,List<TimesheetWrapper>>();
                if(!timesheetList.isEmpty()) {
                    for(TimeSheet__c t: timesheetList) {
                        // if(day_timsheets_map.get(t.Day__c) == null || day_timsheets_map.get(t.Day__c).isEmpty()) {
                        //     TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false);
                        //     day_timsheets_map.put(t.Day__c, new List<TimesheetWrapper>{ singleTimesheetByDay });
                        // }
                        // else {
                        //     List<TimesheetWrapper> finalTimesheetByDay = day_timsheets_map.get(t.Day__c);
                        //     TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false);
                        //     finalTimesheetByDay.add(singleTimesheetByDay);
                        //     day_timsheets_map.put(t.Day__c, finalTimesheetByDay);
                        // }
                        if(dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name) == null || dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name).isEmpty()) {
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false,'');
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, new List<TimesheetWrapper>{ singleTimesheetByDay });
                        }
                        else {
                            List<TimesheetWrapper> finalTimesheetByDay = dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name);
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false,'');
                            finalTimesheetByDay.add(singleTimesheetByDay);
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, finalTimesheetByDay);
                        }
                    }
                }

                for(String dayUser : dayUser_timsheets_map.keySet()) {
                    System.debug(':::: dayUser: ' + dayUser);
                    if(dayUser_timsheets_map.get(dayUser).size() > 1) {
                        Decimal totalHours = 0;
                        Integer totalCount = 0;
                        String userName = '';
                        Date timesheetDate;
                        for(TimesheetWrapper t : dayUser_timsheets_map.get(dayUser)) {
                            totalCount++;
                            totalHours += t.hours;
                            userName = t.userName;
                            timesheetDate = t.dayDate;
                        }
                        TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                        newSummaryTimesheet.totalhoursInDay = totalHours;
                        newSummaryTimesheet.showEachRowTotal = false;
                        newSummaryTimesheet.totalRowsInDay = totalCount;
                        newSummaryTimesheet.summaryRow = true;
                        newSummaryTimesheet.userName = userName;
                        newSummaryTimesheet.dayName = getDayName(timesheetDate);
                        // finalTimesheetByDay.add(newSummaryTimesheet);
                        dayUser_timsheets_map.get(dayUser).add(newSummaryTimesheet);
                        finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                    } else {
                        dayUser_timsheets_map.get(dayUser)[0].showEachRowTotal = true;   
                        finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                    }
                }

                // Integer daysBetween = dateFrom.daysBetween(dateTo) + 1;
                // Integer count = 0;
                // for(Integer i = 0; i < daysBetween; i++) {
                //     if(day_timsheets_map.get(dateFrom + count) != null) {
                //         // For Summary Row
                //         if(day_timsheets_map.get(dateFrom + count).size() > 1) {
                //             Decimal totalHours = 0;
                //             Integer totalCount = 0;
                //             for(TimesheetWrapper t : day_timsheets_map.get(dateFrom + count)) {
                //                 totalCount++;
                //                 totalHours += t.hours;
                //             }
                //             // List<TimesheetWrapper> finalTimesheetByDay = day_timsheets_map.get(dateFrom + count);
                //             TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                //             newSummaryTimesheet.totalhoursInDay = totalHours;
                //             newSummaryTimesheet.showEachRowTotal = false;
                //             newSummaryTimesheet.totalRowsInDay = totalCount;
                //             newSummaryTimesheet.summaryRow = true;
                //             newSummaryTimesheet.dayName = getDayName(dateFrom + count);
                //             // finalTimesheetByDay.add(newSummaryTimesheet);
                //             day_timsheets_map.get(dateFrom + count).add(newSummaryTimesheet);
                //             finalResponse.addAll(day_timsheets_map.get(dateFrom + count));
                //         }
                //         else {
                //             day_timsheets_map.get(dateFrom + count)[0].showEachRowTotal = true;   
                //             finalResponse.addAll(day_timsheets_map.get(dateFrom + count));
                //         }
                //     }
                //     count = count + 1;
                // }
            }
            return finalResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //done 
    @AuraEnabled(cacheable=true)
    public Static List<TimesheetWrapper> getTimesheetForApprovalByEmployeeId(String employeeId, Date dateFromParam, Date dateToParam) {
        try {
            System.debug(':::: getTimesheetForApprovalByEmployeeId employeeId: ' + employeeId);

            Date weekStartDate = Date.today().toStartofWeek();
            Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
            Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
            Date dateTo = dateFrom.addDays(13);

            if(dateFromParam != null) {
                dateFrom = dateFromParam;
            } 
            if(dateToParam != null) {
                dateTo = dateToParam;
            }

            System.debug(':::: dateFrom: ' + dateFrom);
            System.debug(':::: dateTo: ' + dateTo);

            List<TimesheetWrapper> finalResponse = new List<TimesheetWrapper>();
            List<TimeSheet__c> timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                                Project__r.Name,
                                                Hours__c, Overtime__c, Pay_Code__c, Final_Hours__c,
                                                Status__c, Contact__r.Name,
                                                Contact__r.Account.Name,
                                                Type_of_participation__c,
                                                Project_Participants__c,
                                                Project_Participants__r.Role__c,
                                                Reason_For_Rejection__c,

                                                /////////////
                                            Rejected_By__c, Rejection_Date__c,
                                            Rejected_By__r.Position_Id__c,
                                            Rejected_By__r.FirstName, Rejected_By__r.LastName, 

                                                /////////////
                                                Approved_By__c, Approval_Date__c,
                                                Approved_By__r.Position_Id__c,
                                                Approved_By__r.FirstName, Approved_By__r.LastName
                                                FROM TimeSheet__c
                                                WHERE Contact__c =: employeeId
                                                AND Status__c = 'Submitted and Pending for Approval'
                                                AND Day__c >=: dateFrom
                                                AND Day__c <=: dateTo];
            System.debug(':::: timesheetList.size: ' + timesheetList.size());
            System.debug(':::: timesheetList.size: ' + timesheetList);
            if(!timesheetList.isEmpty()) {
                List<ComboboxValues> userProjects = getUserProjects(employeeId);
                //List<ComboboxValues> payCodes = getPayCodeValues();
                List<ComboboxValues> payCodes= new List<ComboboxValues>();

                System.debug(':::: userProjects: ' + userProjects);

                // Map<Date,List<TimesheetWrapper>> day_timsheets_map = new Map<Date,List<TimesheetWrapper>>();
                Map<String,List<TimesheetWrapper>> dayUser_timsheets_map = new Map<String,List<TimesheetWrapper>>();
                if(!timesheetList.isEmpty()) {
                    for(TimeSheet__c t: timesheetList) {
                        if(dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name) == null || dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name).isEmpty()) {
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false,'');
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, new List<TimesheetWrapper>{ singleTimesheetByDay });
                        }
                        else {
                            List<TimesheetWrapper> finalTimesheetByDay = dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name);
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false,'');
                            finalTimesheetByDay.add(singleTimesheetByDay);
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, finalTimesheetByDay);
                        }
                    }
                }

                for(String dayUser : dayUser_timsheets_map.keySet()) {
                    System.debug(':::: dayUser: ' + dayUser);
                    if(dayUser_timsheets_map.get(dayUser).size() > 1) {
                        Decimal totalHours = 0;
                        Integer totalCount = 0;
                        String userName = '';
                        Date timesheetDate;
                        for(TimesheetWrapper t : dayUser_timsheets_map.get(dayUser)) {
                            totalCount++;
                            totalHours += t.hours;
                            userName = t.userName;
                            timesheetDate = t.dayDate;
                        }
                        TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                        newSummaryTimesheet.totalhoursInDay = totalHours;
                        newSummaryTimesheet.showEachRowTotal = false;
                        newSummaryTimesheet.totalRowsInDay = totalCount;
                        newSummaryTimesheet.summaryRow = true;
                        newSummaryTimesheet.userName = userName;
                        newSummaryTimesheet.dayName = getDayName(timesheetDate);
                        // finalTimesheetByDay.add(newSummaryTimesheet);
                        dayUser_timsheets_map.get(dayUser).add(newSummaryTimesheet);
                        finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                    } else {
                        dayUser_timsheets_map.get(dayUser)[0].showEachRowTotal = true;   
                        finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                    }
                }
            }
            return finalResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
//done
    @AuraEnabled(cacheable=true)
    public Static List<TimesheetWrapper> getTimesheetToView(String conId, Date dateFromParam, Date dateToParam) {
        System.debug(':::: getTimesheetToView conId: ' + conId);
        try {
            Date weekStartDate = Date.today().toStartofWeek();
            Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
            Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
            Date dateTo = dateFrom.addDays(13);

            if(dateFromParam != null) {
                dateFrom = dateFromParam;
            } 
            if(dateToParam != null) {
                dateTo = dateToParam;
            }

            System.debug(':::: dateFrom: ' + dateFrom);
            System.debug(':::: dateTo: ' + dateTo);

            List<TimesheetWrapper> finalResponse = new List<TimesheetWrapper>();
            List<TimeSheet__c> timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                                Project__r.Name,
                                                Hours__c, Overtime__c, Pay_Code__c, Final_Hours__c,
                                                Status__c, Contact__r.Name,
                                                Contact__r.Account.Name,
                                                Type_of_participation__c,
                                                Project_Participants__c,
                                                Project_Participants__r.Role__c,
                                                Reason_For_Rejection__c,

                                               /////////////
                                               Rejected_By__c, Rejection_Date__c,
                                               Rejected_By__r.Position_Id__c,
                                               Rejected_By__r.FirstName, Rejected_By__r.LastName, 
                                               
                                               /////////////



                                                Approved_By__c, Approval_Date__c,
                                                Approved_By__r.Position_Id__c,
                                                Approved_By__r.FirstName, Approved_By__r.LastName
                                                FROM TimeSheet__c
                                                WHERE Project__r.Contact__c =: conId // Line Manager
                                                AND Day__c >=: dateFrom
                                                AND Day__c <=: dateTo];
            System.debug(':::: getTimesheetToView => timesheetList.size: ' + timesheetList.size());
            if(!timesheetList.isEmpty()) {
                List<ComboboxValues> userProjects = getUserProjects(conId);
                //List<ComboboxValues> payCodes = getPayCodeValues();
                List<ComboboxValues> payCodes= new List<ComboboxValues>();

                System.debug(':::: userProjects: ' + userProjects);

                // Map<Date,List<TimesheetWrapper>> day_timsheets_map = new Map<Date,List<TimesheetWrapper>>();
                Map<String,List<TimesheetWrapper>> dayUser_timsheets_map = new Map<String,List<TimesheetWrapper>>();
                if(!timesheetList.isEmpty()) {
                    for(TimeSheet__c t: timesheetList) {
                        // if(day_timsheets_map.get(t.Day__c) == null || day_timsheets_map.get(t.Day__c).isEmpty()) {
                        //     TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, true);
                        //     day_timsheets_map.put(t.Day__c, new List<TimesheetWrapper>{ singleTimesheetByDay });
                        // }
                        // else {
                        //     List<TimesheetWrapper> finalTimesheetByDay = day_timsheets_map.get(t.Day__c);
                        //     TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, true);
                        //     finalTimesheetByDay.add(singleTimesheetByDay);
                        //     day_timsheets_map.put(t.Day__c, finalTimesheetByDay);
                        // }

                        if(dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name) == null || dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name).isEmpty()) {
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false,'');
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, new List<TimesheetWrapper>{ singleTimesheetByDay });
                        }
                        else {
                            List<TimesheetWrapper> finalTimesheetByDay = dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name);
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false,'');
                            finalTimesheetByDay.add(singleTimesheetByDay);
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, finalTimesheetByDay);
                        }
                    }
                }

                for(String dayUser : dayUser_timsheets_map.keySet()) {
                    System.debug(':::: dayUser: ' + dayUser);
                    if(dayUser_timsheets_map.get(dayUser).size() > 1) {
                        Decimal totalHours = 0;
                        Integer totalCount = 0;
                        String userName = '';
                        Date timesheetDate;
                        for(TimesheetWrapper t : dayUser_timsheets_map.get(dayUser)) {
                            totalCount++;
                            totalHours += t.hours;
                            userName = t.userName;
                            timesheetDate = t.dayDate;
                        }
                        TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                        newSummaryTimesheet.totalhoursInDay = totalHours;
                        newSummaryTimesheet.showEachRowTotal = false;
                        newSummaryTimesheet.totalRowsInDay = totalCount;
                        newSummaryTimesheet.summaryRow = true;
                        newSummaryTimesheet.userName = userName;
                        newSummaryTimesheet.dayName = getDayName(timesheetDate);
                        // finalTimesheetByDay.add(newSummaryTimesheet);
                        dayUser_timsheets_map.get(dayUser).add(newSummaryTimesheet);
                        finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                    } else {
                        dayUser_timsheets_map.get(dayUser)[0].showEachRowTotal = true;   
                        finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                    }
                }

                // Integer daysBetween = dateFrom.daysBetween(dateTo) + 1;
                // Integer count = 0;
                // for(Integer i = 0; i < daysBetween; i++) {
                //     if(day_timsheets_map.get(dateFrom + count) != null) {
                //         // For Summary Row
                //         if(day_timsheets_map.get(dateFrom + count).size() > 1) {
                //             Decimal totalHours = 0;
                //             Integer totalCount = 0;
                //             for(TimesheetWrapper t : day_timsheets_map.get(dateFrom + count)) {
                //                 totalCount++;
                //                 totalHours += t.hours;
                //             }
                //             // List<TimesheetWrapper> finalTimesheetByDay = day_timsheets_map.get(dateFrom + count);
                //             TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                //             newSummaryTimesheet.totalhoursInDay = totalHours;
                //             newSummaryTimesheet.showEachRowTotal = false;
                //             newSummaryTimesheet.totalRowsInDay = totalCount;
                //             newSummaryTimesheet.summaryRow = true;
                //             newSummaryTimesheet.dayName = getDayName(dateFrom + count);
                //             // finalTimesheetByDay.add(newSummaryTimesheet);
                //             day_timsheets_map.get(dateFrom + count).add(newSummaryTimesheet);
                //             finalResponse.addAll(day_timsheets_map.get(dateFrom + count));
                //         }
                //         else {
                //             day_timsheets_map.get(dateFrom + count)[0].showEachRowTotal = true;   
                //             finalResponse.addAll(day_timsheets_map.get(dateFrom + count));
                //         }
                //     }
                //     count = count + 1;
                // }
            }
            return finalResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


     //Asir adding new method to get employee list for unlocking timesheet
     @AuraEnabled(cacheable=true)
     public Static List<TimesheetWrapper> getUpdateRequestEmployeeList(String conId, Date dateFromParam, Date dateToParam, String timeOption) {
         try {
             System.debug(':::: getUpdateRequestEmployeeList START');
             Date weekStartDate = Date.today().toStartofWeek();
             
             Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
             initialWeekStartDate = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
             Date initialWeekEndDate = initialWeekStartDate.addDays(13);
             Date finalDateFrom; 
             Date finalDateTo;
 
 
             if(dateFromParam != null) {
                 finalDateFrom = dateFromParam;
             } else {
                 finalDateFrom = initialWeekStartDate;
             }
             if(dateToParam != null) {
                 finalDateTo = dateToParam;
             } else {
                 finalDateTo = initialWeekEndDate;
             }
             
             if(timeOption == 'Current Pay Period') {
                 finalDateFrom = initialWeekStartDate;
                 finalDateTo = initialWeekEndDate;
             }
             else if(timeOption == 'Next Pay Period') {
                 finalDateFrom = initialWeekStartDate.addDays(14);
                 finalDateTo = finalDateFrom.addDays(13);
             }
             else if(timeOption == 'Previous Pay Period') {
                 finalDateFrom = initialWeekStartDate.addDays(-14);
                 finalDateTo = finalDateFrom.addDays(13);
             }
 
             List<Contact> contactLst = [SELECT Id, Name FROM Contact 
                                         WHERE Nespon_Manager__c = :conId
                                         OR Account.Divisional_Head__c =: conId];
 
             // String query = 'SELECT Id, Name, Position_Id__c, Account.Name, Job_Title_Description__c FROM Contact';
             // if(!isHRPractitioner) {
             //     if(isNesponManager && isDivisionalHead) {
             //         query += ' WHERE Nespon_Manager__c = \'' + conId + '\' OR Account.Divisional_Head__c = \'' + conId + '\'';
             //     }
             //     else if(isNesponManager) {
             //         query += ' WHERE Nespon_Manager__c = \'' + conId + '\'';
             //     } else if(isDivisionalHead) {
             //         query += ' WHERE Account.Divisional_Head__c = \'' + conId + '\'';
             //     }
             // }
             // query += ' LIMIT 50000';
 
             // System.debug(':::: query: ' + query);
 
             // List<Contact> contactLst = Database.query(query);
             System.debug(':::: contactLst: '+contactLst);
             Set<String> contactIds = new Set<String>();
             for(Contact rec : contactLst) {
                 contactIds.add(rec.Id);
             }
             // List<Request_History__c> requestHistoryList = [SELECT Id, Status__c, Reason__c, Date_To__c, Date_Time__c, Contact__c, Contact__r.Name, Contact__r.Position_ID__c, Contact__r.Account.Name FROM Request_History__c WHERE Contact__c in :contactIds AND Status__c='Requested to Unlock'];
             List<Request_History__c> requestHistoryList = [SELECT Id, Status__c, Reason__c, 
                                                             Date_To__c, Date_Time__c, Contact__c, 
                                                             Contact__r.Name, Contact__r.Position_ID__c, 
                                                             Contact__r.Account.Name 
                                                             FROM Request_History__c 
                                                             WHERE Date_Time__c >= :finalDateFrom 
                                                             AND Date_To__c <= :finalDateTo 
                                                             AND Status__c = 'Requested to Unlock' 
                                                             AND Contact__c in :contactIds];
             System.debug('@@requestHistoryList: '+requestHistoryList);
             List<TimesheetWrapper> timesheetWrapperList = new List<TimesheetWrapper>();
             for(Request_History__c rec : requestHistoryList){
                 TimesheetWrapper wrapperObj = new TimesheetWrapper();
                 wrapperObj.id = rec.Id;
                 wrapperObj.reqEditReason = rec.Reason__c;
                 wrapperObj.contactId = rec.Contact__c;
                 wrapperObj.userName = rec.Contact__r.Name;
                 wrapperObj.reqPositionId = rec.Contact__r.Position_ID__c;
                 wrapperObj.divisionalOffice = rec.Contact__r.Account.Name;
                 wrapperObj.reqDateFrom = rec.Date_Time__c.date();
                 wrapperObj.reqDateTo = rec.Date_To__c.date();
                 timesheetWrapperList.add(wrapperObj);
             }
 
             return timesheetWrapperList;
             
         } catch (Exception e) {
             System.debug(':::: Exception: ' + e.getMessage() + ' On Line: ' + e.getLineNumber());
             throw new AuraHandledException(e.getMessage());
         }
     }
 
    //  @AuraEnabled(cacheable=true)
    //  public Static List<TimesheetWrapper> getUpdateRequestEmployeeListNew(String conId, Date dateFromParam, Date dateToParam, String timeOption, Boolean isNesponManager, Boolean isDivisionalHeadUnlock, Boolean isHRPractitionerUnlock) {
    //      try {
    //          System.debug(':::: getUpdateRequestEmployeeList START');
    //          Date weekStartDate = Date.today().toStartofWeek();
             
    //          Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
    //          initialWeekStartDate = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
    //          Date initialWeekEndDate = initialWeekStartDate.addDays(13);
    //          Date finalDateFrom; 
    //          Date finalDateTo;
 
 
    //          if(dateFromParam != null) {
    //              finalDateFrom = dateFromParam;
    //          } else {
    //              finalDateFrom = initialWeekStartDate;
    //          }
    //          if(dateToParam != null) {
    //              finalDateTo = dateToParam;
    //          } else {
    //              finalDateTo = initialWeekEndDate;
    //          }
             
    //          if(timeOption == 'Current Pay Period') {
    //              finalDateFrom = initialWeekStartDate;
    //              finalDateTo = initialWeekEndDate;
    //          }
    //          else if(timeOption == 'Next Pay Period') {
    //              finalDateFrom = initialWeekStartDate.addDays(14);
    //              finalDateTo = finalDateFrom.addDays(13);
    //          }
    //          else if(timeOption == 'Previous Pay Period') {
    //              finalDateFrom = initialWeekStartDate.addDays(-14);
    //              finalDateTo = finalDateFrom.addDays(13);
    //          }
 
    //          List<Contact> contactLst = [SELECT Id, Name FROM Contact 
    //                                      WHERE Nespon_Manager__c = :conId
    //                                      OR Account.Divisional_Head__c =: conId];
 
    //          String query = 'SELECT Id, Name, Position_Id__c, Account.Name, Job_Title_Description__c FROM Contact';
    //          if(!isHRPractitionerUnlock) {
    //              if(isNesponManager && isDivisionalHeadUnlock) {
    //                  query += ' WHERE Nespon_Manager__c = \'' + conId + '\' OR Account.Divisional_Head__c = \'' + conId + '\'';
    //              }
    //              else if(isNesponManager) {
    //                  query += ' WHERE Nespon_Manager__c = \'' + conId + '\'';
    //              } else if(isDivisionalHeadUnlock) {
    //                  query += ' WHERE Account.Divisional_Head__c = \'' + conId + '\'';
    //              }
    //          }
    //          query += ' LIMIT 50000';
 
    //          System.debug(':::: query: ' + query);
 
    //          List<Contact> contactLst = Database.query(query);
    //          System.debug(':::: contactLst: '+contactLst);
    //          Set<String> contactIds = new Set<String>();
    //          for(Contact rec : contactLst) {
    //              contactIds.add(rec.Id);
    //          }
    //          // List<Request_History__c> requestHistoryList = [SELECT Id, Status__c, Reason__c, Date_To__c, Date_Time__c, Contact__c, Contact__r.Name, Contact__r.Position_ID__c, Contact__r.Account.Name FROM Request_History__c WHERE Contact__c in :contactIds AND Status__c='Requested to Unlock'];
    //          List<Request_History__c> requestHistoryList = [SELECT Id, Status__c, Reason__c, 
    //                                                          Date_To__c, Date_Time__c, Contact__c, 
    //                                                          Contact__r.Name, Contact__r.Position_ID__c, 
    //                                                          Contact__r.Account.Name 
    //                                                          FROM Request_History__c 
    //                                                          WHERE Date_Time__c >= :finalDateFrom 
    //                                                          AND Date_To__c <= :finalDateTo 
    //                                                          AND Status__c = 'Requested to Unlock' 
    //                                                          AND Contact__c in :contactIds];
    //          System.debug('@@requestHistoryList: '+requestHistoryList);
    //          List<TimesheetWrapper> timesheetWrapperList = new List<TimesheetWrapper>();
    //          for(Request_History__c rec : requestHistoryList){
    //              TimesheetWrapper wrapperObj = new TimesheetWrapper();
    //              wrapperObj.id = rec.Id;
    //              wrapperObj.reqEditReason = rec.Reason__c;
    //              wrapperObj.contactId = rec.Contact__c;
    //              wrapperObj.userName = rec.Contact__r.Name;
    //              wrapperObj.reqPositionId = rec.Contact__r.Position_ID__c;
    //              wrapperObj.divisionalOffice = rec.Contact__r.Account.Name;
    //              wrapperObj.reqDateFrom = rec.Date_Time__c.date();
    //              wrapperObj.reqDateTo = rec.Date_To__c.date();
    //              timesheetWrapperList.add(wrapperObj);
    //          }
 
    //          return timesheetWrapperList;
             
    //      } catch (Exception e) {
    //          System.debug(':::: Exception: ' + e.getMessage() + ' On Line: ' + e.getLineNumber());
    //          throw new AuraHandledException(e.getMessage());
    //      }
    //  }
 
     @AuraEnabled(cacheable=true)
     public Static List<Map<String,String>> getUserListToShowForApproval(String conId, Boolean isNesponManager, Boolean isDivisionalHead, Boolean isHRPractitioner, Date dateFromParam, Date dateToParam) {
         System.debug(':::: isHRPractitioner: ' + isHRPractitioner);
         System.debug(':::: isNesponManager: ' + isNesponManager);
         System.debug(':::: isDivisionalHead: ' + isDivisionalHead);
         List<Map<String,String>> finalResponse = new List<Map<String,String>>();
         Date weekStartDate = Date.today().toStartofWeek();
         Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
         Date lastWeekStartDate = initialWeekStartDate.addDays(-7);
         Date lastWeekEndDate = lastWeekStartDate.addDays(6);
         String query = 'SELECT Id, Name, Position_Id__c, Account.Name, Job_Title_Description__c FROM Contact';
         if(!isHRPractitioner) {
             if(isNesponManager && isDivisionalHead) {
                 query += ' WHERE Nespon_Manager__c = \'' + conId + '\' OR Account.Divisional_Head__c = \'' + conId + '\'';
             }
             else if(isNesponManager) {
                 query += ' WHERE Nespon_Manager__c = \'' + conId + '\'';
             } else if(isDivisionalHead) {
                 query += ' WHERE Account.Divisional_Head__c = \'' + conId + '\'';
             }
         }
         query += ' LIMIT 50000';
 
         System.debug(':::: query: ' + query);
 
         List<Contact> conList = Database.query(query);
         Set<Id> conIds = new Set<Id>();
         for(Contact c : conList) {
             conIds.add(c.Id);
         }
         List<TimeSheet__c> timesheetList = [SELECT Id, Status__c, Contact__c 
                                             FROM TimeSheet__c WHERE Contact__c IN: conIds
                                             AND Day__c >=: dateFromParam
                                             AND Day__c <=: dateToParam
                                             ORDER BY Contact__c ASC 
                                             LIMIT 50000];
 
         Map<Id,List<Timesheet__c>> conId_timsheet_map = new Map<Id,List<Timesheet__c>>(); 
         Map<String,String> conId_Status_map = new Map<String,String>();
         for(Timesheet__c t : timesheetList) {
            Boolean checkStatusFlag = true;
             if(conId_Status_map.get(t.Contact__c) != null) {
                 if(conId_Status_map.get(t.Contact__c) != t.Status__c) {
                    if(t.Status__c == 'Submitted and Pending for Approval') {
                        conId_Status_map.put(t.Contact__c, 'Approval Pending');
                        checkStatusFlag = false;
                    }
                    else if (checkStatusFlag){
                        conId_Status_map.put(t.Contact__c, 'Unsubmitted'); 
                    }
                    // conId_Status_map.put(t.Contact__c, 'Multiple Statuses');
                 }
             } else {
                 if(t.Status__c == 'Submitted and Pending for Approval') {
                     conId_Status_map.put(t.Contact__c, 'Approval Pending');
                     checkStatusFlag = false;
                 }
                 else if (checkStatusFlag){
                     conId_Status_map.put(t.Contact__c, 'Unsubmitted');
                 }
             }
 
             if(conId_timsheet_map.get(t.Contact__c) == null) {
                 conId_timsheet_map.put(t.Contact__c, new List<TimeSheet__c> { t });
             } else {
                 List<TimeSheet__c> allTimesheets = conId_timsheet_map.get(t.Contact__c);
                 allTimesheets.add(t);
                 conId_timsheet_map.put(t.Contact__c, allTimesheets);
                 // if(conId_Status_map.get(t.Contact__c) == t.Status__c) {
                 //     conId_Status_map.put(t.Contact__c, t.Status__c);
                 // } else {
                 //     conId_Status_map.put(t.Contact__c, 'MULTIPLE STATUSES');
                 // }
             }
         }
 
         for(Contact c : conList) {
             Map<String,String> res = new Map<String,String>();
             res.put('Id',c.Id);
             res.put('userName', c.Name);
             res.put('reqPositionId', c.Position_Id__c);
             res.put('divisionalOffice', c.Account.Name);
             res.put('reqDateFrom', String.valueOf(dateFromParam));
             res.put('reqDateTo', String.valueOf(dateToParam));
             res.put('Designation', c.Job_Title_Description__c);
             res.put('approvalStatus', (conId_Status_map.get(c.Id) != null && conId_Status_map.get(c.Id) != '') ? conId_Status_map.get(c.Id) : 'Unsubmitted' );
             res.put('contactId', c.Id);
             
             finalResponse.add(res);
         }
 
         return finalResponse;
     }
 
     @AuraEnabled(cacheable=true)
     public Static List<TimesheetWrapper> getTimesheetsUpdateRequests(String conId) {
         System.debug(':::: getTimesheetsUpdateRequests conId: ' + conId);
         try {
             Date weekStartDate = Date.today().toStartofWeek();
             Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
             Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
             Date dateTo = dateFrom.addDays(13);
 
             // if(dateFromParam != null) {
             //     dateFrom = dateFromParam;
             // } 
             // if(dateToParam != null) {
             //     dateTo = dateToParam;
             // }
 
             System.debug(':::: dateFrom: ' + dateFrom);
             System.debug(':::: dateTo: ' + dateTo);
             
             List<TimesheetWrapper> finalResponse = new List<TimesheetWrapper>();
             List<TimeSheet__c> timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                                 Project__r.Name,
                                                 Hours__c, Overtime__c, Pay_Code__c, Final_Hours__c,
                                                 Status__c, Contact__r.Name,
                                                 Contact__r.Account.Name,
                                                 Type_of_participation__c,
                                                 Project_Participants__c,
                                                 Project_Participants__r.Role__c,
                                                 Reason_For_Rejection__c,


                                                /////////////
                                                Rejected_By__c, Rejection_Date__c,
                                                Rejected_By__r.Position_Id__c,
                                                Rejected_By__r.FirstName, Rejected_By__r.LastName, 
                                                
                                                /////////////


                                                 Approved_By__c, Approval_Date__c,
                                                Approved_By__r.Position_Id__c,
                                                Approved_By__r.FirstName, Approved_By__r.LastName
                                                 FROM TimeSheet__c
                                                 WHERE  Status__c = 'Request to Edit'
                                                 AND Contact__r.Nespon_Manager__c =: conId
                                                 // AND Day__c >=: dateFrom
                                                 // AND Day__c <=: dateTo
                                                 ORDER BY Contact__r.Name ASC];
                                                 //ORDER BY Day__c ASC];
             System.debug(':::: getTimesheetsUpdateRequests => getTimesheetsUpdateRequests.size: ' + timesheetList.size());
             if(!timesheetList.isEmpty()) {
                 List<ComboboxValues> userProjects = getUserProjects(conId);
                 //List<ComboboxValues> payCodes = getPayCodeValues();
                 List<ComboboxValues> payCodes= new List<ComboboxValues>();
 
                 System.debug(':::: userProjects: ' + userProjects);
 
                 Map<String,List<TimesheetWrapper>> dayUser_timsheets_map = new Map<String,List<TimesheetWrapper>>();
                 
                 if(!timesheetList.isEmpty()) {
                     for(TimeSheet__c t: timesheetList) {
                         if(dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name) == null || dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name).isEmpty()) {
                             TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false,'');
                             dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, new List<TimesheetWrapper>{ singleTimesheetByDay });
                         }
                         else {
                             List<TimesheetWrapper> finalTimesheetByDay = dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name);
                             TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false,'');
                             finalTimesheetByDay.add(singleTimesheetByDay);
                             dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, finalTimesheetByDay);
                         }
                     }
                 }
                 
                 for(String dayUser : dayUser_timsheets_map.keySet()) {
                     System.debug(':::: dayUser: ' + dayUser);
                     if(dayUser_timsheets_map.get(dayUser).size() > 1) {
                         Decimal totalHours = 0;
                         Integer totalCount = 0;
                         String userName = '';
                         Date timesheetDate;
                         for(TimesheetWrapper t : dayUser_timsheets_map.get(dayUser)) {
                             totalCount++;
                             totalHours += t.hours;
                             userName = t.userName;
                             timesheetDate = t.dayDate;
                         }
                         TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                         newSummaryTimesheet.totalhoursInDay = totalHours;
                         newSummaryTimesheet.showEachRowTotal = false;
                         newSummaryTimesheet.totalRowsInDay = totalCount;
                         newSummaryTimesheet.summaryRow = true;
                         newSummaryTimesheet.userName = userName;
                         newSummaryTimesheet.dayName = getDayName(timesheetDate);
                         // finalTimesheetByDay.add(newSummaryTimesheet);
                         dayUser_timsheets_map.get(dayUser).add(newSummaryTimesheet);
                         finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                     } else {
                         dayUser_timsheets_map.get(dayUser)[0].showEachRowTotal = true;   
                         finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                     }
                 }
 
                 // dateFrom = timesheetList[0].Day__c;
                 // dateTo = timesheetList[timesheetList.size() - 1].Day__c;
                 // Integer daysBetween = dateFrom.daysBetween(dateTo) + 1;
                 // Integer count = 0;
                 // for(Integer i = 0; i < daysBetween; i++) {
                 //     if(dayUser_timsheets_map.get(dateFrom + count) != null) {
                 //         // For Summary Row
                 //         if(day_timsheets_map.get(dateFrom + count).size() > 1) {
                 //             Decimal totalHours = 0;
                 //             Integer totalCount = 0;
                 //             String userName = '';
                 //             for(TimesheetWrapper t : day_timsheets_map.get(dateFrom + count)) {
                 //                 totalCount++;
                 //                 totalHours += t.hours;
                 //                 userName = t.userName;
                 //             }
                 //             // List<TimesheetWrapper> finalTimesheetByDay = day_timsheets_map.get(dateFrom + count);
                 //             TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                 //             newSummaryTimesheet.totalhoursInDay = totalHours;
                 //             newSummaryTimesheet.showEachRowTotal = false;
                 //             newSummaryTimesheet.totalRowsInDay = totalCount;
                 //             newSummaryTimesheet.summaryRow = true;
                 //             newSummaryTimesheet.userName = userName;
                 //             newSummaryTimesheet.dayName = getDayName(dateFrom + count);
                 //             // finalTimesheetByDay.add(newSummaryTimesheet);
                 //             day_timsheets_map.get(dateFrom + count).add(newSummaryTimesheet);
                 //             finalResponse.addAll(day_timsheets_map.get(dateFrom + count));
                 //         }
                 //         else {
                 //             day_timsheets_map.get(dateFrom + count)[0].showEachRowTotal = true;   
                 //             finalResponse.addAll(day_timsheets_map.get(dateFrom + count));
                 //         }
                 //     }
                 //     count = count + 1;
                 // }
                 // for(String userName : userName_timsheets_map.keySet()) {
                 //     if(userName_timsheets_map.get(userName).size() > 1) {
                 //         Decimal totalHours = 0;
                 //         Integer totalCount = 0;
                 //         Date timesheetDate;
                 //         for(TimesheetWrapper t: userName_timsheets_map.get(userName)) {
                 //             totalCount++;
                 //             totalHours += t.hours;
                 //         }
 
                 //         TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                 //         newSummaryTimesheet.totalhoursInDay = totalHours;
                 //         newSummaryTimesheet.showEachRowTotal = false;
                 //         newSummaryTimesheet.totalRowsInDay = totalCount;
                 //         newSummaryTimesheet.summaryRow = true;
                 //         newSummaryTimesheet.userName = userName;
                 //         newSummaryTimesheet.dayName = getDayName(dateFrom + count);
                 //     } else {
 
                 //     }
                 // }
             }
             return finalResponse;
         } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());
         }
     }
     @AuraEnabled

    public static string deleteRecords(List<String> deletedId)
    {
        if(!deletedId.isEmpty())
        {
            delete [SELECT Id FROM TimeSheet__c WHERE Id IN: deletedId];
            return 'OK';
        }
        return 'NOT OK';
    }
     
     @AuraEnabled(cacheable=true)
     public Static  List<ComboboxValues> getUserProjectByUserId(String userId) {
         String conId = [SELECT ContactId FROM User WHERE Id =: userId]?.ContactId;
         List<Project__c> projects = [SELECT Id, Name FROM Project__c WHERE Contact__c =: conId];
         List<ComboboxValues> finalResponse = new List<ComboboxValues>();
         for(Project__c p : projects) {
             ComboboxValues res = new ComboboxValues();
             res.label = p.Name;
             res.value = p.Name;
             finalResponse.add(res);
         }
         return finalResponse;
     }



    //done
    @AuraEnabled(cacheable=true)
    public Static List<TimesheetWrapper> getTimesheetToViewByEmployeeId(String employeeId, String conId, Date dateFromParam, Date dateToParam) {
        System.debug(':::: getTimesheetToView conId: ' + conId); // Manager Id
        try {
            List<TimesheetWrapper> finalResponse = new List<TimesheetWrapper>();
            if(String.isNotBlank(conId)) {
                Date weekStartDate = Date.today().toStartofWeek();
                Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
                Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
                Date dateTo = dateFrom.addDays(13);

                if(dateFromParam != null) {
                    dateFrom = dateFromParam;
                } 
                if(dateToParam != null) {
                    dateTo = dateToParam;
                }

                System.debug(':::: dateFrom: ' + dateFrom);
                System.debug(':::: dateTo: ' + dateTo);

                List<TimeSheet__c> timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                                    Project__r.Name,
                                                    Hours__c, Overtime__c, Pay_Code__c, Final_Hours__c,
                                                    Status__c, Contact__r.Name,
                                                    Contact__r.Account.Name,
                                                    Type_of_participation__c,
                                                    Project_Participants__c,
                                                    Project_Participants__r.Role__c,
                                                    Reason_For_Rejection__c,

                                                    /////////////
                                                    Rejected_By__c, Rejection_Date__c,
                                                    Rejected_By__r.Position_Id__c,
                                                    Rejected_By__r.FirstName, Rejected_By__r.LastName, 
                                                    
                                                    /////////////


                                                    Approved_By__c, Approval_Date__c,
                                                    Approved_By__r.Position_Id__c,
                                                    Approved_By__r.FirstName, Approved_By__r.LastName
                                                    FROM TimeSheet__c
                                                    WHERE Project_Participants__r.Contact__c =: employeeId
                                                    AND Project__r.Contact__c =: conId // Line Manager
                                                    AND Day__c >=: dateFrom
                                                    AND Day__c <=: dateTo];
                System.debug(':::: getTimesheetToView => timesheetList.size: ' + timesheetList.size());
                if(!timesheetList.isEmpty()) {
                    List<ComboboxValues> userProjects = getUserProjects(conId);
                    //List<ComboboxValues> payCodes = getPayCodeValues();
                    List<ComboboxValues> payCodes= new List<ComboboxValues>();

                    System.debug(':::: userProjects: ' + userProjects);

                    // Map<Date,List<TimesheetWrapper>> day_timsheets_map = new Map<Date,List<TimesheetWrapper>>();
                    Map<String,List<TimesheetWrapper>> dayUser_timsheets_map = new Map<String,List<TimesheetWrapper>>();
                    if(!timesheetList.isEmpty()) {
                        for(TimeSheet__c t: timesheetList) {

                            if(dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name) == null || dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name).isEmpty()) {
                                TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false,'');
                                dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, new List<TimesheetWrapper>{ singleTimesheetByDay });
                            }
                            else {
                                List<TimesheetWrapper> finalTimesheetByDay = dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name);
                                TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false,'');
                                finalTimesheetByDay.add(singleTimesheetByDay);
                                dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, finalTimesheetByDay);
                            }
                        }
                    }

                    for(String dayUser : dayUser_timsheets_map.keySet()) {
                        System.debug(':::: dayUser: ' + dayUser);
                        if(dayUser_timsheets_map.get(dayUser).size() > 1) {
                            Decimal totalHours = 0;
                            Integer totalCount = 0;
                            String userName = '';
                            Date timesheetDate;
                            for(TimesheetWrapper t : dayUser_timsheets_map.get(dayUser)) {
                                totalCount++;
                                totalHours += t.hours;
                                userName = t.userName;
                                timesheetDate = t.dayDate;
                            }
                            TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                            newSummaryTimesheet.totalhoursInDay = totalHours;
                            newSummaryTimesheet.showEachRowTotal = false;
                            newSummaryTimesheet.totalRowsInDay = totalCount;
                            newSummaryTimesheet.summaryRow = true;
                            newSummaryTimesheet.userName = userName;
                            newSummaryTimesheet.dayName = getDayName(timesheetDate);
                            // finalTimesheetByDay.add(newSummaryTimesheet);
                            dayUser_timsheets_map.get(dayUser).add(newSummaryTimesheet);
                            finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                        } else {
                            dayUser_timsheets_map.get(dayUser)[0].showEachRowTotal = true;   
                            finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                        }
                    }
                }
            }
            return finalResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
 //done
    @AuraEnabled(cacheable=true)
    public Static List<Map<String,String>> getUserListToShowForView(String conId) {
        
        List<Map<String,String>> finalResponse = new List<Map<String,String>>();
        Date weekStartDate = Date.today().toStartofWeek();
        Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
        Date lastWeekStartDate = initialWeekStartDate.addDays(-7);
        Date lastWeekEndDate = lastWeekStartDate.addDays(6);
        
        List<Project_Participants__c> participants = [SELECT Id, Project__r.Name, Contact__c, Contact__r.Name, Contact__r.Position_Id__c,
                                                    Contact__r.Account.Name, Contact__r.Job_Title_Description__c
                                                    FROM Project_Participants__c
                                                    WHERE Project__r.Contact__c =: conId
                                                    ORDER BY Project__r.Contact__c ASC];
        
        for(Project_Participants__c p : participants) {
            Map<String,String> res = new Map<String,String>();
            res.put('userName', p.Contact__r.Name);
            res.put('reqPositionId', p.Contact__r.Position_Id__c);
            res.put('divisionalOffice', p.Contact__r.Account.Name);
            //res.put('reqDateFrom', String.valueOf(lastWeekStartDate));
            //res.put('reqDateTo', String.valueOf(lastWeekEndDate));
            res.put('Designation', p.Contact__r.Job_Title_Description__c);
            //res.put('approvalStatus', (conId_Status_map.get(c.Id) != null && conId_Status_map.get(c.Id) != '') ? conId_Status_map.get(c.Id) : 'No Timesheet Found' );
            res.put('contactId', p.Contact__c);
            res.put('projectName', p.Project__r.Name);
            
            finalResponse.add(res);
        }

        // Set<Id> conIds = new Set<Id>();
        // for(Contact c : conList) {
        //     conIds.add(c.Id);
        // }
        // List<TimeSheet__c> timesheetList = [SELECT Id, Status__c, Contact__c 
        //                                     FROM TimeSheet__c WHERE Contact__c IN: conIds
        //                                     AND Day__c >=: lastWeekStartDate
        //                                     AND Day__c <=: lastWeekEndDate
        //                                     ORDER BY Contact__c ASC 
        //                                     LIMIT 50000];

        // Map<Id,List<Timesheet__c>> conId_timsheet_map = new Map<Id,List<Timesheet__c>>(); 
        // Map<String,String> conId_Status_map = new Map<String,String>();
        // for(Timesheet__c t : timesheetList) {
        //     if(conId_Status_map.get(t.Contact__c) != null) {
        //         if(conId_Status_map.get(t.Contact__c) != t.Status__c) {
        //             conId_Status_map.put(t.Contact__c, 'MULTIPLE STATUSES');
        //         }
        //     } else {
        //         if(t.Status__c == null || t.Status__c == '') {
        //             conId_Status_map.put(t.Contact__c, 'Unsubmitted');
        //         } else {
        //             conId_Status_map.put(t.Contact__c, t.Status__c);
        //         }
        //     }

        //     if(conId_timsheet_map.get(t.Contact__c) == null) {
        //         conId_timsheet_map.put(t.Contact__c, new List<TimeSheet__c> { t });
        //     } else {
        //         List<TimeSheet__c> allTimesheets = conId_timsheet_map.get(t.Contact__c);
        //         allTimesheets.add(t);
        //         conId_timsheet_map.put(t.Contact__c, allTimesheets);
        //         // if(conId_Status_map.get(t.Contact__c) == t.Status__c) {
        //         //     conId_Status_map.put(t.Contact__c, t.Status__c);
        //         // } else {
        //         //     conId_Status_map.put(t.Contact__c, 'MULTIPLE STATUSES');
        //         // }
        //     }
        // }

        // for(Contact c : conList) {
        //     Map<String,String> res = new Map<String,String>();
        //     res.put('userName', c.Name);
        //     res.put('reqPositionId', c.Position_Id__c);
        //     res.put('divisionalOffice', c.Account.Name);
        //     //res.put('reqDateFrom', String.valueOf(lastWeekStartDate));
        //     //res.put('reqDateTo', String.valueOf(lastWeekEndDate));
        //     res.put('Designation', c.Job_Title_Description__c);
        //     //res.put('approvalStatus', (conId_Status_map.get(c.Id) != null && conId_Status_map.get(c.Id) != '') ? conId_Status_map.get(c.Id) : 'No Timesheet Found' );
        //     res.put('contactId', c.Id);
            
        //     finalResponse.add(res);
        // }

        return finalResponse; 
    }
//done
    @AuraEnabled(cacheable=true)
    public Static List<TimesheetWrapper> getTimesheetsUpdateRequestsByEmployeeId(String conId, Date dateFromParam, Date dateToParam) {
        System.debug(':::: getTimesheetsUpdateRequestsByEmployeeId conId: ' + conId);
        try {
            Date weekStartDate = Date.today().toStartofWeek();
            Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
            Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
            Date dateTo = dateFrom.addDays(13);

            if(dateFromParam != null) {
                dateFrom = dateFromParam;
            } 
            if(dateToParam != null) {
                dateTo = dateToParam;
            }

            System.debug(':::: dateFrom: ' + dateFrom);
            System.debug(':::: dateTo: ' + dateTo);
            
            List<TimesheetWrapper> finalResponse = new List<TimesheetWrapper>();
            List<TimeSheet__c> timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                                Project__r.Name,
                                                Hours__c, Overtime__c, Pay_Code__c, Final_Hours__c,
                                                Status__c, Contact__r.Name,
                                                Contact__r.Account.Name,
                                                Type_of_participation__c,
                                                Project_Participants__c,
                                                Project_Participants__r.Role__c,
                                                Reason_For_Rejection__c,

                                                /////////////
                                                Rejected_By__c, Rejection_Date__c,
                                                Rejected_By__r.Position_Id__c,
                                                Rejected_By__r.FirstName, Rejected_By__r.LastName, 
                                                
                                                /////////////




                                                Approved_By__c, Approval_Date__c,
                                                Approved_By__r.Position_Id__c,
                                                Approved_By__r.FirstName, Approved_By__r.LastName
                                                FROM TimeSheet__c
                                                WHERE  Status__c = 'Request to Edit'
                                                // AND Contact__r.Nespon_Manager__c =: conId
                                                AND Contact__c =: conId
                                                AND Day__c >=: dateFrom
                                                AND Day__c <=: dateTo
                                                ORDER BY Contact__r.Name ASC];
                                                //ORDER BY Day__c ASC];
            System.debug(':::: getTimesheetsUpdateRequestsByEmployeeId => getTimesheetsUpdateRequestsByEmployeeId.size: ' + timesheetList.size());
            if(!timesheetList.isEmpty()) {
                List<ComboboxValues> userProjects = getUserProjects(conId);
                //List<ComboboxValues> payCodes = getPayCodeValues();
                List<ComboboxValues> payCodes= new List<ComboboxValues>();

                System.debug(':::: userProjects: ' + userProjects);

                Map<String,List<TimesheetWrapper>> dayUser_timsheets_map = new Map<String,List<TimesheetWrapper>>();
                
                if(!timesheetList.isEmpty()) {
                    for(TimeSheet__c t: timesheetList) {
                        if(dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name) == null || dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name).isEmpty()) {
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false,'');
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, new List<TimesheetWrapper>{ singleTimesheetByDay });
                        }
                        else {
                            List<TimesheetWrapper> finalTimesheetByDay = dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name);
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false,'');
                            finalTimesheetByDay.add(singleTimesheetByDay);
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, finalTimesheetByDay);
                        }
                    }
                }
                
                for(String dayUser : dayUser_timsheets_map.keySet()) {
                    System.debug(':::: dayUser: ' + dayUser);
                    if(dayUser_timsheets_map.get(dayUser).size() > 1) {
                        Decimal totalHours = 0;
                        Integer totalCount = 0;
                        String userName = '';
                        Date timesheetDate;
                        for(TimesheetWrapper t : dayUser_timsheets_map.get(dayUser)) {
                            totalCount++;
                            totalHours += t.hours;
                            userName = t.userName;
                            timesheetDate = t.dayDate;
                        }
                        TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                        newSummaryTimesheet.totalhoursInDay = totalHours;
                        newSummaryTimesheet.showEachRowTotal = false;
                        newSummaryTimesheet.totalRowsInDay = totalCount;
                        newSummaryTimesheet.summaryRow = true;
                        newSummaryTimesheet.userName = userName;
                        newSummaryTimesheet.dayName = getDayName(timesheetDate);
                        // finalTimesheetByDay.add(newSummaryTimesheet);
                        dayUser_timsheets_map.get(dayUser).add(newSummaryTimesheet);
                        finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                    } else {
                        dayUser_timsheets_map.get(dayUser)[0].showEachRowTotal = true;   
                        finalResponse.addAll(dayUser_timsheets_map.get(dayUser));
                    }
                }

                // dateFrom = timesheetList[0].Day__c;
                // dateTo = timesheetList[timesheetList.size() - 1].Day__c;
                // Integer daysBetween = dateFrom.daysBetween(dateTo) + 1;
                // Integer count = 0;
                // for(Integer i = 0; i < daysBetween; i++) {
                //     if(dayUser_timsheets_map.get(dateFrom + count) != null) {
                //         // For Summary Row
                //         if(day_timsheets_map.get(dateFrom + count).size() > 1) {
                //             Decimal totalHours = 0;
                //             Integer totalCount = 0;
                //             String userName = '';
                //             for(TimesheetWrapper t : day_timsheets_map.get(dateFrom + count)) {
                //                 totalCount++;
                //                 totalHours += t.hours;
                //                 userName = t.userName;
                //             }
                //             // List<TimesheetWrapper> finalTimesheetByDay = day_timsheets_map.get(dateFrom + count);
                //             TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                //             newSummaryTimesheet.totalhoursInDay = totalHours;
                //             newSummaryTimesheet.showEachRowTotal = false;
                //             newSummaryTimesheet.totalRowsInDay = totalCount;
                //             newSummaryTimesheet.summaryRow = true;
                //             newSummaryTimesheet.userName = userName;
                //             newSummaryTimesheet.dayName = getDayName(dateFrom + count);
                //             // finalTimesheetByDay.add(newSummaryTimesheet);
                //             day_timsheets_map.get(dateFrom + count).add(newSummaryTimesheet);
                //             finalResponse.addAll(day_timsheets_map.get(dateFrom + count));
                //         }
                //         else {
                //             day_timsheets_map.get(dateFrom + count)[0].showEachRowTotal = true;   
                //             finalResponse.addAll(day_timsheets_map.get(dateFrom + count));
                //         }
                //     }
                //     count = count + 1;
                // }
                // for(String userName : userName_timsheets_map.keySet()) {
                //     if(userName_timsheets_map.get(userName).size() > 1) {
                //         Decimal totalHours = 0;
                //         Integer totalCount = 0;
                //         Date timesheetDate;
                //         for(TimesheetWrapper t: userName_timsheets_map.get(userName)) {
                //             totalCount++;
                //             totalHours += t.hours;
                //         }

                //         TimesheetWrapper newSummaryTimesheet = new TimesheetWrapper();
                //         newSummaryTimesheet.totalhoursInDay = totalHours;
                //         newSummaryTimesheet.showEachRowTotal = false;
                //         newSummaryTimesheet.totalRowsInDay = totalCount;
                //         newSummaryTimesheet.summaryRow = true;
                //         newSummaryTimesheet.userName = userName;
                //         newSummaryTimesheet.dayName = getDayName(dateFrom + count);
                //     } else {

                //     }
                // }
            }
            return finalResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
//done
    public Static List<ComboboxValues> getUserProjects(String conId) {
        try {
            List<ComboboxValues> finalResponse = new List<ComboboxValues>();
            List<Project_Participants__c> projectParticipants = [SELECT Project__c, Project__r.Name,Pay_Code__c 
                                                                FROM Project_Participants__c 
                                                                WHERE Active__c =true and Assignment_up_to__c >= TODAY and Contact__c =: conId];
            System.debug(':::: projectParticipants: ' + projectParticipants);
            if(!projectParticipants.isEmpty()) {
                Map<String,Project_Participants__c> uniqueProjects = new Map<String,Project_Participants__c>();
                for(Project_Participants__c pp : projectParticipants) {
                    uniqueProjects.put(pp.Project__c, pp);
                    System.debug(':::: pp.Project__c: ' + pp.Project__c);
                    System.debug(':::: pp.Project__r.Name: ' + pp.Project__r.Name);
                }

                for(String projId : uniqueProjects.keySet()) {
                    ComboboxValues res = new ComboboxValues();
                    res.label = uniqueProjects.get(projId).Project__r.Name;
                    res.value = projId;
                    res.paycode = uniqueProjects.get(projId).Pay_Code__c;
                    finalResponse.add(res);
                }
            }
            return finalResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //done
    public Static Map<String,String> getUserProjectsParticipantsMap(String conId) {
        try {
            Map<String,String> projectId_projParticipantId_map = new Map<String,String>();

            List<Project_Participants__c> projectParticipants = [SELECT Id, Project__c
                                                                FROM Project_Participants__c
                                                                WHERE Contact__c =: conId];
            if(!projectParticipants.isEmpty()) {
                for(Project_Participants__c pp :projectParticipants) {
                    projectId_projParticipantId_map.put(pp.Project__c, pp.Id);
                }
            }
            return projectId_projParticipantId_map;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
//done
    // public Static List<ComboboxValues> getPayCodeValues() {
    //     List<ComboboxValues> payCodes = new List<ComboboxValues>();
    //     Schema.DescribeFieldResult fieldResult = TimeSheet__c.Pay_Code__c.getDescribe();
	// 	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	// 	for( Schema.PicklistEntry pickListVal : ple){
    //         ComboboxValues combobox = new ComboboxValues();
    //         combobox.label = pickListVal.getLabel();
    //         combobox.value = pickListVal.getValue();
    //         payCodes.add(combobox);
	// 	}
    //     return payCodes;
    // }

    @AuraEnabled
    public Static String removeOvertimeTimesheet(String timesheetId){
        try {
            TimeSheet__c timesheetRec = [SELECT Id, Type_of_hour__c, Overtime_from__c, Overtime_to__c, Description__c FROM TimeSheet__c WHERE Id = :timesheetId LIMIT 1];
            timesheetRec.Type_of_hour__c = '';
            timesheetRec.Overtime__c = false;
            timesheetRec.Overtime_from__c = null;
            timesheetRec.Overtime_to__c = null;
            timesheetRec.Description__c = '';
            System.debug('@@Timesheet info');
            System.debug(timesheetId);
            System.debug(timesheetRec);
            update timesheetRec;
            return 'OK';
        } catch (Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public Static String updateOvertimeTimesheet(String timesheetId, String typeOfOvertime, String overtimeStartTime, String overtimeEndTime, String overtimeDescription){
        try {
            List<String> otStartTimeLst = overtimeStartTime.split(':');
            Time otStartTime = Time.newInstance(Integer.valueOf(otStartTimeLst[0]), Integer.valueOf(otStartTimeLst[1]), Integer.valueOf(otStartTimeLst[2]), 0);
            List<String> otEndTimeLst = overtimeEndTime.split(':');
            Time otEndTime = Time.newInstance(Integer.valueOf(otEndTimeLst[0]), Integer.valueOf(otEndTimeLst[1]), Integer.valueOf(otEndTimeLst[2]), 0);
            TimeSheet__c timesheetRec = [SELECT Id, Type_of_hour__c, Overtime_from__c, Overtime_to__c, Description__c FROM TimeSheet__c WHERE Id = :timesheetId LIMIT 1];
            timesheetRec.Type_of_hour__c = typeOfOvertime;
            timesheetRec.Overtime__c = true;
            timesheetRec.Overtime_from__c = otStartTime;
            timesheetRec.Overtime_to__c = otEndTime;
            timesheetRec.Description__c = overtimeDescription;
            System.debug('@@Timesheet info');
            System.debug(timesheetId);
            System.debug(timesheetRec);
            update timesheetRec;
            return 'OK';
        } catch (Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

// working done
    public Static TimesheetWrapper fillSingleTimesheet(TimeSheet__c timesheet, List<ComboboxValues> projects, List<ComboboxValues> payCodes, Boolean sameDay, Boolean viewOnly, String screen) {
        TimesheetWrapper singleTimesheet = new TimesheetWrapper();
        singleTimesheet.id = timesheet.Id;
         //Asir edited here to handle checkbox in timesheet row
         singleTimesheet.disableCheckbox = false;
        if(timesheet.Status__c == null || timesheet.Status__c == '') {
            if(!viewOnly) {
                singleTimesheet.isEditable = true;
            }
            singleTimesheet.timsheetSaved = true;
        }
        else if(timesheet.Status__c == 'Submitted and Pending for Approval') {
            singleTimesheet.submitted = true;
            singleTimesheet.isEditable = false;
        }
        else if(timesheet.Status__c == 'Approved') {
            singleTimesheet.approved = true;
            System.debug(':::: timesheet.Approval_Date__c'+timesheet.Approval_Date__c);
            singleTimesheet.approvalMsg = timesheet.Approved_By__r.LastName + ', ' + timesheet.Approved_By__r.FirstName + ' ('+timesheet.Approved_By__r.Position_Id__c+') approved on ' + timesheet.Approval_Date__c.format() ;
        }
        else if(timesheet.Status__c == 'Request to Edit') {
            singleTimesheet.recall = true;
            singleTimesheet.isEditable = false;
        }
        else if(timesheet.Status__c == 'Rejected') {
            if(!viewOnly) {
                singleTimesheet.isEditable = true;
            }
            singleTimesheet.rejected = true;
            System.debug(':::: timesheet.Reason_For_Rejection__c: ' + timesheet.Reason_For_Rejection__c);
            singleTimesheet.rejectionReason = timesheet.Rejected_By__r.LastName + ', ' + timesheet.Rejected_By__r.FirstName + ' ('+timesheet.Rejected_By__r.Position_Id__c+') rejected on ' + timesheet.Rejection_Date__c.format('MM/dd/YYYY') +' at '+ timesheet.Rejection_Date__c.format('HH:mm a')  + '\n'+ 'Reason: '+ timesheet.Reason_For_Rejection__c;

        }

        singleTimesheet.dayName = getDayName(timesheet.Day__c);
        singleTimesheet.dayDate = timesheet.Day__c;
        singleTimesheet.hours = timesheet.Hours__c;
        singleTimesheet.totalHours = timesheet.Hours__c; // ! Might need to Change Later
        singleTimesheet.project = timesheet.Project__c;
        singleTimesheet.projectName = timesheet.Project__r?.Name;
        singleTimesheet.projects = projects;
        singleTimesheet.overTime = timesheet.Overtime__c;
        singleTimesheet.isEmptyRow = false;
        singleTimesheet.payCode = timesheet.Pay_Code__c;
        singleTimesheet.payCodes = payCodes;
        singleTimesheet.inEditMode = false;
        if(singleTimesheet.overTime){
            singleTimesheet.overtimeFrom = timesheet.Overtime_from__c;
            singleTimesheet.overtimeTo = timesheet.Overtime_to__c;
            singleTimesheet.overtimeType = timesheet.Type_of_hour__c;
            singleTimesheet.overtimeDescription = timesheet.Description__c;
            singleTimesheet.totalOvertimeHours = timesheet.Total_overtime__c;
        }
        if(sameDay) {
            singleTimesheet.combineRow = true;
        }
        if(screen=='approval' ) {
            if(timesheet.Status__c =='Submitted and Pending for Approval' || timesheet.Status__c =='Request to Edit'){
                singleTimesheet.disableCheckbox = false;
            }
            else{
                singleTimesheet.disableCheckbox = true;
            }
            singleTimesheet.isEditable = true;
            
        }
    
        if(screen=='unlock' && timesheet.Status__c !='Request to Edit' ){
            singleTimesheet.disableCheckbox = true;
            // singleTimesheet.isEditable = true;
        }

    
        singleTimesheet.userName = timesheet.Contact__r.Name;
        singleTimesheet.divisionalOffice = timesheet.Contact__r.Account.Name;
        singleTimesheet.projectParticipantRole = timesheet.Project_Participants__r.Role__c;

        // * For Employee Project Total Hour - Used In Approval
        singleTimesheet.contactId = timesheet.Contact__c;
        singleTimesheet.projectParticipantId = timesheet.Project_Participants__c;
        singleTimesheet.month = getMonthName(timesheet.Day__c);
        singleTimesheet.year = timesheet.Day__c.year();
        return singleTimesheet;
    }
//done
    public Static String getDayName(Date dateValue) {
        Datetime dt = (DateTime) dateValue + 1; 
        String dayOfWeek = dt.format('EEEE');
        return dayOfWeek;
    }
//done
    public Static String getMonthName(Date dateValue) {
        Datetime dt = (DateTime) dateValue; 
        String monthName = dt.format('MMMM');
        return monthName;
    }
//done
    @AuraEnabled
    public Static string saveRecords(List<TimesheetWrapper> timesheetsToSave, String conId) {
        try {
            if(!timesheetsToSave.isEmpty()) {
                Map<String,String> projectId_projParticipantId_map = getUserProjectsParticipantsMap(conId);

                List<TimeSheet__c> timeSheetListToSave = new List<TimeSheet__c>();
                for(TimesheetWrapper singleTimesheet : timesheetsToSave) {
                    System.debug(':::: singleTimesheet: ' + singleTimesheet);
                    System.debug(':::: singleTimesheet.: ' + singleTimesheet.dayDate);
                    TimeSheet__c ts = new TimeSheet__c();
                    ts.Contact__c = conId;
                    ts.Project__c = singleTimesheet.project;
                    if(singleTimesheet.hours != null){
                        ts.Hours__c = singleTimesheet.hours;
                    }
                    else{
                        ts.Hours__c = 0;
                    }
                    ts.Day__c = singleTimesheet.dayDate;
                   ts.Status__c = '';
                    
                    if(singleTimesheet.id != null) {
                        ts.Id = singleTimesheet.id;
                    }
                    ts.Pay_Code__c = singleTimesheet.payCode;
                    ts.Project_Participants__c = projectId_projParticipantId_map.get(singleTimesheet.project);
                    timeSheetListToSave.add(ts);
                }
                upsert timeSheetListToSave;
                System.debug(':::: UPSERTED');
                return 'OK';
            }
            return 'NOT OK';
        } catch (Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    //duplicated by shayan to implement overtime work
    @AuraEnabled
    public Static string saveRecords2(List<TimesheetWrapper> timesheetsToSave, String conId) {
        try {
            if(!timesheetsToSave.isEmpty()) {
                Map<String,String> projectId_projParticipantId_map = getUserProjectsParticipantsMap(conId);

                List<TimeSheet__c> timeSheetListToSave = new List<TimeSheet__c>();
                for(TimesheetWrapper singleTimesheet : timesheetsToSave) {
                    System.debug(':::: singleTimesheet: ' + singleTimesheet);
                    System.debug(':::: singleTimesheet.: ' + singleTimesheet.dayDate);
                    TimeSheet__c ts = new TimeSheet__c();
                    ts.Contact__c = conId;
                    ts.Project__c = singleTimesheet.project;
                    if(singleTimesheet.hours != null){
                        ts.Hours__c = singleTimesheet.hours;
                    }
                    else{
                        ts.Hours__c = 0;
                    }
                    if(singleTimesheet.overTime)
                    {
                        ts.Overtime__c = true;
                        ts.Overtime_from__c = singleTimesheet.overtimeFrom;
                        ts.Overtime_to__c = singleTimesheet.overtimeTo;
                        ts.Description__c = singleTimesheet.overtimeDescription;
                        ts.Type_of_hour__c = singleTimesheet.overtimeType;
                    }
                    ts.Day__c = singleTimesheet.dayDate;
                   ts.Status__c = '';
                    
                    if(singleTimesheet.id != null) {
                        ts.Id = singleTimesheet.id;
                    }
                    ts.Pay_Code__c = singleTimesheet.payCode;
                    ts.Project_Participants__c = projectId_projParticipantId_map.get(singleTimesheet.project);
                    timeSheetListToSave.add(ts);
                }
                upsert timeSheetListToSave;
                System.debug(':::: UPSERTED');
                return 'OK';
            }
            return 'NOT OK';
        } catch (Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }


    //duplicated by shayan to implement overtime
    @AuraEnabled
    public Static string saveRecordsFromManager2(List<TimesheetWrapper> timesheetsToSave, String conId) {
        try {
            if(!timesheetsToSave.isEmpty()) {
                Map<String,String> projectId_projParticipantId_map = getUserProjectsParticipantsMap(conId);

                List<TimeSheet__c> timeSheetListToSave = new List<TimeSheet__c>();
                for(TimesheetWrapper singleTimesheet : timesheetsToSave) {
                    TimeSheet__c ts = new TimeSheet__c();
                    ts.Contact__c = conId;
                    ts.Project__c = singleTimesheet.project;
                    if(singleTimesheet.hours != null){
                        ts.Hours__c = singleTimesheet.hours;
                    }
                    else{
                        ts.Hours__c = 0;
                    }

                    if(singleTimesheet.overTime)
                    {
                        ts.Overtime__c = true;
                        ts.Overtime_from__c = singleTimesheet.overtimeFrom;
                        ts.Overtime_to__c = singleTimesheet.overtimeTo;
                        ts.Description__c = singleTimesheet.overtimeDescription;
                        ts.Type_of_hour__c = singleTimesheet.overtimeType;
                    }
                    ts.Day__c = singleTimesheet.dayDate;
                   ts.Status__c = 'Submitted and Pending for Approval';
                    
                    if(singleTimesheet.id != null) {
                        ts.Id = singleTimesheet.id;
                    }
                    ts.Pay_Code__c = singleTimesheet.payCode;
                    ts.Project_Participants__c = projectId_projParticipantId_map.get(singleTimesheet.project);
                    timeSheetListToSave.add(ts);
                }
                upsert timeSheetListToSave;
                System.debug(':::: UPSERTED');
                return 'OK';
            }
            return 'NOT OK';
        } catch (Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    
    @AuraEnabled
    public Static string saveRecordsFromManager(List<TimesheetWrapper> timesheetsToSave, String conId) {
        try {
            if(!timesheetsToSave.isEmpty()) {
                Map<String,String> projectId_projParticipantId_map = getUserProjectsParticipantsMap(conId);

                List<TimeSheet__c> timeSheetListToSave = new List<TimeSheet__c>();
                for(TimesheetWrapper singleTimesheet : timesheetsToSave) {
                    TimeSheet__c ts = new TimeSheet__c();
                    ts.Contact__c = conId;
                    ts.Project__c = singleTimesheet.project;
                    if(singleTimesheet.hours != null){
                        ts.Hours__c = singleTimesheet.hours;
                    }
                    else{
                        ts.Hours__c = 0;
                    }
                    ts.Day__c = singleTimesheet.dayDate;
                   ts.Status__c = 'Submitted and Pending for Approval';
                    
                    if(singleTimesheet.id != null) {
                        ts.Id = singleTimesheet.id;
                    }
                    ts.Pay_Code__c = singleTimesheet.payCode;
                    ts.Project_Participants__c = projectId_projParticipantId_map.get(singleTimesheet.project);
                    timeSheetListToSave.add(ts);
                }
                upsert timeSheetListToSave;
                System.debug(':::: UPSERTED');
                return 'OK';
            }
            return 'NOT OK';
        } catch (Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    //done
    // public Static string submitRecords(Date dateFromParam, Date dateToParam, String conId) {
    @AuraEnabled
    public Static string submitRecords(List<TimesheetWrapper> timesheets, String conId) {
        try {
            if(timesheets != null && !timesheets.isEmpty()) {
                System.debug(':::: submitRecords => timesheets:.size: ' + timesheets.size());
                List<Timesheet__c> timesheetsToSubmit = new List<Timesheet__c>();
                for(TimesheetWrapper t : timesheets) {
                    TimeSheet__c singleTimesheet = new TimeSheet__c();
                    singleTimesheet.Id = t.Id;
                    singleTimesheet.Status__c = 'Submitted and Pending for Approval';
                    timesheetsToSubmit.add(singleTimesheet);
                }
                update timesheetsToSubmit;
                Date dateFrom= timesheets[0].dayDate;
                Date dateTo = timesheets[timesheets.size()-1].dayDate;
                

                // * SEND EMAIL + COMMUNITY NOTIFICATION
                List<Contact> contacts = [SELECT Nespon_Manager__c, Nespon_Manager__r.Personal_Email__c FROM Contact 
                                        WHERE Id =: conId LIMIT 1];

                CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                        FROM CustomNotificationType 
                                                        WHERE DeveloperName = 'TimeCardNotification'];
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Timesheet submitted.');
                notification.setBody(timesheets[0].userName + ' has submitted the timesheet for the pay period ' +dateFrom.format() + '-' + dateTo.format());
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
                message.subject = 'Timesheet is submitted for Approval.';
                message.plainTextBody = ' The timesheet for the pay period "' +dateFrom.format() + '-' + dateTo.format() +'" has been submitted by "'+ timesheets[0].userName + '" at "' + Datetime.now().format('HH:mm a') +'"';
                List<User> user = new List<User>();
                if (contacts[0].Nespon_Manager__c!=null) {
                    user = [SELECT Id, Email FROM User WHERE ContactId =: contacts[0].Nespon_Manager__c];
                }
           
                if(!user.isEmpty()) {
                    System.debug(':::: user: ' + user[0]);
                    notification.send(new Set<String>{user[0]?.Id});
                    message.toAddresses = new String[] { contacts[0]?.Nespon_Manager__r.Personal_Email__c };
                    System.debug(':::: message: ' + message);
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
                    if(contacts[0]?.Nespon_Manager__r.Personal_Email__c != null) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    }
                    return 'OK';
                }
                
                return 'OK';
            }
            return 'NOT OK';
        }
        catch(Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
//done
    @AuraEnabled
    public Static string recallRecords(List<TimesheetWrapper> timesheets, String conId ,String reason, DateTime dateF, DateTime dateT, Date dateFNew, Date dateTNew, String payPeriod) {
        try {
            if(timesheets != null && !timesheets.isEmpty()) {
                Map<String,Date> conId_payperiod_map = new Map<String,Date>();
                
                System.debug(':::: recallRecords => timesheets:.size: ' + timesheets.size());
                List<Timesheet__c> timesheetsToSubmit = new List<Timesheet__c>();
                List<Request_History__c> newReqList = new List<Request_History__c>();
                for(TimesheetWrapper t : timesheets) {
                    TimeSheet__c singleTimesheet = new TimeSheet__c();
                    singleTimesheet.Id = t.Id;
                    singleTimesheet.Status__c = 'Request to Edit';
                    timesheetsToSubmit.add(singleTimesheet);
                    
                    conId_payperiod_map.put(t.contactId, t.dayDate);

                    // save record reason
                    Request_History__c newReqHistory = new Request_History__c();
                    newReqHistory.Reason__c = reason;
                    newReqHistory.Pay_Period__c= payPeriod;
                    newReqHistory.Contact__c= conId;
                    newReqHistory.Date_Time__c= dateF;
                    newReqHistory.Date_To__c= dateT;
                    newReqHistory.Status__c = 'Requested to Unlock';
                    //Asir made changes here to adjust the date issue in request history object in sfdc
                    newReqHistory.Date_from_new__c= dateFNew;
                    newReqHistory.Date_to_new__c= dateTNew;
                    newReqList.add(newReqHistory);
                }
                update timesheetsToSubmit;
                
                insert newReqList;

                Date dateFrom= timesheets[0].dayDate;
                Date dateTo = timesheets[timesheets.size()-1].dayDate;
                
                // * SEND EMAIL + COMMUNITY NOTIFICATION
                List<Contact> contacts = [SELECT Nespon_Manager__c, Nespon_Manager__r.Personal_Email__c FROM Contact 
                                        WHERE Id =: conId LIMIT 1];

                CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                        FROM CustomNotificationType 
                                                        WHERE DeveloperName = 'TimeCardNotification'];
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Request to Unlock Timesheet.');
                notification.setBody(timesheets[0].userName + ' requested to unlock the timesheet for the pay period ' +dateFrom.format() + '-' + dateTo.format());
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
                message.subject = 'Request to Edit Timesheet.';
                //message.plainTextBody = timesheets[0].userName + ' is requesting to update timesheet for the pay period ' + String.valueOf(dateF) + ' - ' + String.valueOf(dateT);
                message.plainTextBody = timesheets[0].userName + 'has requested to unlock the timesheet for the pay period ' + dateF.format('MM/dd/YYYY') + ' - ' + dateT.format('MM/dd/YYYY')+ '" at "' + Datetime.now().format('HH:mm a') +'"';
                Id orgWideId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1]?.Id;

                List<User> user = [SELECT Id, Email FROM User WHERE ContactId =: contacts[0].Nespon_Manager__c];
                if(!user.isEmpty()) {
                    notification.send(new Set<String>{user[0]?.Id});
                    message.toAddresses = new String[] { contacts[0].Nespon_Manager__r.Personal_Email__c };
                    message.setOrgWideEmailAddressId(orgWideId);
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
                    if(contacts[0].Nespon_Manager__r.Personal_Email__c != null) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    }
                    return 'OK';
                }
            }
            return 'NOT OK';
        }
        catch(Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
//done


@AuraEnabled
public Static string approveTimesheets(List<TimesheetWrapper> timesheets, String managerId) {
    try {
        System.debug(':::: approveTimesheets => timesheets.size: ' + timesheets.size());
        if(!timesheets.isEmpty()) {
            List<TimeSheet__c> timeSheetListToSubmit = new List<TimeSheet__c>();
            List<TimesheetWrapper> timeSheetNewInsert = new List<TimesheetWrapper>();
            List<TimesheetWrapper> timesheetsUpdate = new List<TimesheetWrapper>();

            for (TimesheetWrapper singleTimesheet : timesheets){
                TimeSheet__c t = new TimeSheet__c();
                if (singleTimesheet.id == null){
                    Map<String,String> participantMap = getProjectIdByName(singleTimesheet.project, singleTimesheet.contactId);
                    t.Project_Participants__c= participantMap.get('participantId');
                    t.Role__c =  participantMap.get('role');
                    t.Day__c = singleTimesheet.dayDate;
                    t.Contact__c = singleTimesheet.contactId;
                    t.Approval_Date__c =datetime.now();
                    t.Status__c = 'Approved';  
                    t.Approved_By__c = managerId;
                    t.Pay_Code__c= singleTimesheet.payCode;
                    t.Project__c= singleTimesheet.project;
                    t.Hours__c= singleTimesheet.hours;
                    timeSheetListToSubmit.add(t);

                    singleTimesheet.projectParticipantId=participantMap.get('participantId');
                    timeSheetNewInsert.add(singleTimesheet);
                }
                else{
                    timesheetsUpdate.add(singleTimesheet);
                }
            }

            if(!timeSheetListToSubmit.isEmpty())
            {
                insert timeSheetListToSubmit;
                empTotalHrInsert(timeSheetNewInsert);
                if (timesheetsUpdate.isEmpty()) {
                    return 'OK';
                }
            }
            if (!timesheetsUpdate.isEmpty()) {
                List<TimeSheet__c> timeSheetListToApprove = new List<TimeSheet__c>();
                List<TimesheetWrapper> timeSheetListToApproveRecall = new List<TimesheetWrapper>();
                Map<String,List<TimesheetWrapper>> uniquename_timesheets_map = new Map<String,List<TimesheetWrapper>>();
                Set<Id> conIds = new Set<Id>();
                Set<Id> conIdsForRecall = new Set<Id>();
                Map<String,Date> conId_payperiod_map = new Map<String,Date>();
    
                for(TimesheetWrapper singleTimesheet : timesheetsUpdate) {
                    TimeSheet__c t = new TimeSheet__c();
                    t.Id = singleTimesheet.id;
                    t.Approval_Date__c =datetime.now();
                    t.Status__c = 'Approved';
                    t.Approved_By__c = managerId;
                    t.Pay_Code__c= singleTimesheet.payCode;
                    t.Project__c= singleTimesheet.project;
                    t.Hours__c= singleTimesheet.hours;

                    if (singleTimesheet.recall==true) {
                        timeSheetListToApproveRecall.add(singleTimesheet);
                        conIdsForRecall.add(singleTimesheet.contactId);
                        
                    }
    
                    timeSheetListToApprove.add(t);
                    
                    conId_payperiod_map.put(singleTimesheet.contactId, singleTimesheet.dayDate);
                    if (singleTimesheet.recall!=true) {
                        conIds.add(singleTimesheet.contactId);
                    }
                
                    String uniqueName = singleTimesheet.contactId + '-' + singleTimesheet.projectParticipantId + '-' + singleTimesheet.payCode + '-' + singleTimesheet.month + '-' + singleTimesheet.year;
                    if(uniquename_timesheets_map.get(uniqueName) == null || uniquename_timesheets_map.get(uniqueName).isEmpty()) {
                        uniquename_timesheets_map.put(uniqueName,new List<TimesheetWrapper>{ singleTimesheet });
                    } else {
                        List<TimesheetWrapper> finalTimesheetByUniqueName = uniquename_timesheets_map.get(uniqueName);
                        finalTimesheetByUniqueName.add(singleTimesheet);
                        uniquename_timesheets_map.put(uniqueName, finalTimesheetByUniqueName);
                    }
                }
    
                if(!timeSheetListToApprove.isEmpty()) {
                    update timeSheetListToApprove;
    
                    List<EmpProjectTotalHr__c> empTotalHrList = [SELECT Id, Name, Contact__c, Project_Participants__c,
                                                                Pay_Code__c, Month__c, Year__c, Timecard_Hours__c
                                                                FROM EmpProjectTotalHr__c
                                                                WHERE Contact__c IN: conIds];
                    
                    List<Contact> conList = [SELECT Personal_Email__c, Name FROM Contact WHERE Id IN: conIds];
    
                    // FOR SENDING NOTIFICATION TO EMPLOYEES
                    if(!conList.isEmpty() && conId_payperiod_map.get(conList[0].Id) != null) {
                        Date weekStartDateNotification = conId_payperiod_map.get(conList[0].Id).toStartofWeek();
                        Date initialWeekStartDateNotification = getDayName(weekStartDateNotification).toLowerCase() == 'sunday' ? weekStartDateNotification : WeekStartDateNotification - 1;
                        Date dateFromNotification = initialWeekStartDateNotification.addDays(-7); // NEW WORK SAME AS ADP
                        Date dateToNotification = dateFromNotification.addDays(13);
                    
                        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                            FROM CustomNotificationType 
                                                            WHERE DeveloperName = 'TimeCardNotification'];
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setTitle('Timesheet Approved.');
                        notification.setBody(dateFromNotification.format() + ' - ' + dateToNotification.format() + '" timesheet has been approved');
                        notification.setNotificationTypeId(notificationType.Id);
                        Map<String, Object> communityPageRef = new Map<String, Object>{
                            'type' => 'comm__namedPage',
                            'attributes' => new Map<String, Object>{
                                'pageName' => 'home'
                            }
                        };
                        notification.setTargetPageRef(JSON.serialize(communityPageRef));
    
                        Map<Id,User> usersMap = new Map<Id,User>([SELECT Id, Contact.Email, Contact.Personal_Email__c FROM User WHERE ContactId IN: conIds]);
                        
                        Set<String> idStrs = (Set<String>)JSON.deserialize(JSON.serialize(usersMap.keySet()), Set<String>.class);
                        notification.send(idStrs);
                    }
                    String managerName = [SELECT Name FROM Contact WHERE Id =: managerId LIMIT 1]?.Name;
                    Id orgWideId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1]?.Id;
                    // * SEND SEPARATE EMAIL TO USERS
                    List<Messaging.SingleEmailMessage> allMessages = new List<Messaging.SingleEmailMessage>();
                    if (!conList.isEmpty()) {
                        for(Contact c : conList) {
                            if(conId_payperiod_map.get(c.Id) != null) {
                                Date weekStartDate = conId_payperiod_map.get(c.Id).toStartofWeek();
                                Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
                                Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
                                Date dateTo = dateFrom.addDays(13);
        
                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                message.optOutPolicy = 'FILTER';
                                message.subject = 'Timesheet Approved.';
                                //message.plainTextBody = 'The timesheet for the pay period "' + String.valueOf(dateFrom).subStringBefore('00:') + ' - ' + String.valueOf(dateTo).subStringBefore('00:') + '" has been approved by "'+managerName+'" at "'+Datetime.now()+'"';
                                message.plainTextBody = 'The timesheet for the pay period "' + dateFrom.format() + ' - ' + dateto.format() + '" has been approved by "'+managerName+'" at "'+ Datetime.now().format('HH:mm a') +'"';
                                System.debug(':::: conList[0].Personal_Email__c: ' + c.Personal_Email__c);
                                
                                message.toAddresses = new String[] { c.Personal_Email__c };
                                message.setOrgWideEmailAddressId(orgWideId);
                                allMessages.add(message);
                            }
                        }
                    }
    
                    if(!allMessages.isEmpty()) {
                        
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(allMessages);
                        for(Messaging.SendEmailResult r : results) {
                            System.debug(':::: r.getErrors(): ' + r.getErrors());
                            System.debug(':::: isSuccess: ' + r.isSuccess());
                        }
                    }
    
                    List<EmpProjectTotalHr__c> empTotalHrListToUpsert = new List<EmpProjectTotalHr__c>();
                    
                    for(String uniqueName : uniquename_timesheets_map.keySet()) {
                        System.debug(':::: uniqueName: ' + uniqueName);
                        Boolean recordFound = false;
                        for(EmpProjectTotalHr__c emp : empTotalHrList) {
                            String existingUniqueName = emp.Contact__c + '-' + emp.Project_Participants__c + '-' + emp.Pay_Code__c + '-' + emp.Month__c + '-' + emp.Year__c;
                            System.debug(':::: existingUniqueName: ' + existingUniqueName);
                            if(uniqueName == existingUniqueName) {
                                Decimal totalHours = 0;
                                for(TimesheetWrapper t : uniquename_timesheets_map.get(uniqueName)) {
                                    totalHours += t.hours;
                                }
                                emp.Timecard_Hours__c = emp.Timecard_Hours__c + totalHours;
                                empTotalHrListToUpsert.add(emp);
                                recordFound = true;
                                System.debug(':::: RECORD FOUND => ');
                                System.debug(':::: RECORD FOUND => ' + uniqueName);
                                System.debug(':::: RECORD FOUND => ' + existingUniqueName);
                                break;
                            }
                        }
                        // * If recordNotFound then create 1 New Record with Sum of Hours
                        if(!recordFound) {
                            System.debug(':::: recordFound NOT');
                            System.debug(':::: recordFound NOT uniqueName: ' + uniqueName);
                            EmpProjectTotalHr__c newEmp = new EmpProjectTotalHr__c();
                            newEmp.Contact__c = uniquename_timesheets_map.get(uniqueName)[0].contactId;
                            newEmp.Project_Participants__c = uniquename_timesheets_map.get(uniqueName)[0].projectParticipantId;
                            newEmp.Pay_Code__c = uniquename_timesheets_map.get(uniqueName)[0].payCode;
                            newEmp.Month__c = uniquename_timesheets_map.get(uniqueName)[0].month;
                            newEmp.Year__c = uniquename_timesheets_map.get(uniqueName)[0].year;
                            Decimal totalHours = 0;
                            for(TimesheetWrapper t : uniquename_timesheets_map.get(uniqueName)) {
                                totalHours += t.hours;
                            }
                            newEmp.Timecard_Hours__c = totalHours;
                            empTotalHrListToUpsert.add(newEmp);
                        }
                    }
    
                    if(!empTotalHrListToUpsert.isEmpty()) {
                        System.debug(':::: empTotalHrListToUpsert: ' + empTotalHrListToUpsert.size());
                        upsert empTotalHrListToUpsert;
                    }
                    if (!timeSheetListToApproveRecall.isEmpty()) {
                        List<Request_History__c> requestHis =   [SELECT Id, Status__c, Date_Time__c, Date_To__c 
                                                                FROM Request_History__c
                                                                WHERE Contact__c IN: conIdsForRecall
                                                                AND Status__c = 'Requested to Unlock']; 
                                           
                        for(Request_History__c r : requestHis) {
                            for(TimesheetWrapper t: timeSheetListToApproveRecall) {
                                if(t.dayDate >= r.Date_Time__c && t.dayDate <= r.Date_To__c) {
                                    r.Status__c = 'Unlocked/Saved';
                                }
                            }
                        }
    
                        update requestHis;
                    }  
                    return 'OK';
                }
       
            }
        }
        return 'NOT OK';
    } catch(Exception ex) {
        System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
        throw new AuraHandledException(ex.getMessage());
    }

}
public static void empTotalHrInsert(List<TimesheetWrapper> timesheets){
    try{
        Map<String,List<TimesheetWrapper>> uniquename_timesheets_map = new Map<String,List<TimesheetWrapper>>();
        Set<Id> conIds = new Set<Id>();
        Map<String,Date> conId_payperiod_map = new Map<String,Date>();
        for(TimesheetWrapper singleTimesheet : timesheets) {
        conId_payperiod_map.put(singleTimesheet.contactId, singleTimesheet.dayDate);
        conIds.add(singleTimesheet.contactId);
        String uniqueName = singleTimesheet.contactId + '-' + singleTimesheet.projectParticipantId + '-' + singleTimesheet.payCode + '-' + singleTimesheet.month + '-' + singleTimesheet.year;
            if(uniquename_timesheets_map.get(uniqueName) == null || uniquename_timesheets_map.get(uniqueName).isEmpty()) {
                uniquename_timesheets_map.put(uniqueName,new List<TimesheetWrapper>{ singleTimesheet });
            } else {
                List<TimesheetWrapper> finalTimesheetByUniqueName = uniquename_timesheets_map.get(uniqueName);
                finalTimesheetByUniqueName.add(singleTimesheet);
                uniquename_timesheets_map.put(uniqueName, finalTimesheetByUniqueName);
            }
        }
        List<EmpProjectTotalHr__c> empTotalHrList = [SELECT Id, Name, Contact__c, Project_Participants__c,
                                                                Pay_Code__c, Month__c, Year__c, Timecard_Hours__c
                                                                FROM EmpProjectTotalHr__c
                                                                WHERE Contact__c IN: conIds];
        List<EmpProjectTotalHr__c> empTotalHrListToUpsert = new List<EmpProjectTotalHr__c>();
        for(String uniqueName : uniquename_timesheets_map.keySet()) {
            Boolean recordFound = false;
            for(EmpProjectTotalHr__c emp : empTotalHrList) {
                String existingUniqueName = emp.Contact__c + '-' + emp.Project_Participants__c + '-' + emp.Pay_Code__c + '-' + emp.Month__c + '-' + emp.Year__c;
                    if(uniqueName == existingUniqueName) {
                    Decimal totalHours = 0;
                    for(TimesheetWrapper t : uniquename_timesheets_map.get(uniqueName)) {
                        totalHours += t.hours;
                    }
                    emp.Timecard_Hours__c = emp.Timecard_Hours__c + totalHours;
                    empTotalHrListToUpsert.add(emp);
                    recordFound = true;
                    
                    break;
                }
            }
            // * If recordNotFound then create 1 New Record with Sum of Hours
            if(!recordFound) {
                EmpProjectTotalHr__c newEmp = new EmpProjectTotalHr__c();
                newEmp.Contact__c = uniquename_timesheets_map.get(uniqueName)[0].contactId;
                newEmp.Project_Participants__c = uniquename_timesheets_map.get(uniqueName)[0].projectParticipantId;
                newEmp.Pay_Code__c = uniquename_timesheets_map.get(uniqueName)[0].payCode;
                newEmp.Month__c = uniquename_timesheets_map.get(uniqueName)[0].month;
                newEmp.Year__c = uniquename_timesheets_map.get(uniqueName)[0].year;
                Decimal totalHours = 0;
                for(TimesheetWrapper t : uniquename_timesheets_map.get(uniqueName)) {
                    totalHours += t.hours;
                }
                newEmp.Timecard_Hours__c = totalHours;
                empTotalHrListToUpsert.add(newEmp);
            }
        }

        if(!empTotalHrListToUpsert.isEmpty()) {
            upsert empTotalHrListToUpsert;
        }
    }
    catch(Exception ex){
        System.debug('Error '+ex);
    }
 
}
public static Map<String, String> getProjectIdByName(String project, String conId){
    List<Project_Participants__c> projectList = [SELECT Id, Project__r.Name,Name,Role__c FROM Project_Participants__c WHERE Contact__c =:conId and Project__c =:project];
    system.debug('Ponka3::: '+ projectList);
    if (!projectList.isEmpty()) {
        Map<String, String> mapName = new Map<String, String>();
        mapName.put('participantId',projectList[0].id);
        mapName.put('role',projectList[0].Role__c);
        system.debug('Ponka2::: '+ mapName.put('role',projectList[0].Role__c));
        return mapName;
    }
    else{
        Map<String, String> mapName = new Map<String, String>();
        return  mapName;
    }
}
//done
    @AuraEnabled
    public Static string rejectTimesheets(List<TimesheetWrapper> timesheets ,string reason, String managerId) {
        try {
            System.debug(':::: rejectTimesheets => timesheets.size: ' + timesheets.size());
            if(!timesheets.isEmpty()) {
                List<TimeSheet__c> timeSheetListToReject = new List<TimeSheet__c>();
                
                Map<String,List<TimesheetWrapper>> uniquename_timesheets_map = new Map<String,List<TimesheetWrapper>>();
                
                Set<Id> conIds = new Set<Id>();
                Map<String,Date> conId_payperiod_map = new Map<String,Date>();
                for(TimesheetWrapper singleTimesheet : timesheets) {
                    TimeSheet__c t = new TimeSheet__c();
                    t.Id = singleTimesheet.id;
                    t.Status__c = 'Rejected';
                    t.Reason_for_Rejection__c = reason;
                    

//////////////////////////////
t.Rejection_Date__c =datetime.now();
//t.Status__c = 'Rejected';
t.Rejected_By__c = managerId;

timeSheetListToReject.add(t);

//////////////////////////////







                    conIds.add(singleTimesheet.contactId);
                    conId_payperiod_map.put(singleTimesheet.contactId, singleTimesheet.dayDate);

                    String uniqueName = singleTimesheet.contactId + '-' + singleTimesheet.projectParticipantId + '-' + singleTimesheet.payCode + '-' + singleTimesheet.month + '-' + singleTimesheet.year;
                    if(uniquename_timesheets_map.get(uniqueName) == null || uniquename_timesheets_map.get(uniqueName).isEmpty()) {
                        uniquename_timesheets_map.put(uniqueName,new List<TimesheetWrapper>{ singleTimesheet });
                    } else {
                        List<TimesheetWrapper> finalTimesheetByUniqueName = uniquename_timesheets_map.get(uniqueName);
                        finalTimesheetByUniqueName.add(singleTimesheet);
                        uniquename_timesheets_map.put(uniqueName, finalTimesheetByUniqueName);
                    }
                }
                List<Contact> conList = [SELECT Personal_Email__c FROM Contact WHERE Id IN: conIds];
                if(!timeSheetListToReject.isEmpty()) {

                  // rejection email and notification start
                  Date weekStartDateNotification = conId_payperiod_map.get(conList[0].Id).toStartofWeek();
                  Date initialWeekStartDateNotification = getDayName(weekStartDateNotification).toLowerCase() == 'sunday' ? weekStartDateNotification : WeekStartDateNotification - 1;
                  Date dateFromNotification = initialWeekStartDateNotification.addDays(-7); // NEW WORK SAME AS ADP
                  Date dateToNotification = dateFromNotification.addDays(13);

                  CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                            FROM CustomNotificationType 
                                                            WHERE DeveloperName = 'TimeCardNotification'];
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setTitle('Timesheet Rejected.');
                        notification.setBody(dateFromNotification.format() + ' - ' + dateToNotification.format() + '" timesheet has been rejected.');
                        notification.setNotificationTypeId(notificationType.Id);
                        Map<String, Object> communityPageRef = new Map<String, Object>{
                        'type' => 'comm__namedPage',
                        'attributes' => new Map<String, Object>{
                        'pageName' => 'home'
                        }
                };
                notification.setTargetPageRef(JSON.serialize(communityPageRef));
    
                Map<Id,User> usersMap = new Map<Id,User>([SELECT Id, Contact.Email, Contact.Personal_Email__c FROM User WHERE ContactId IN: conIds]);
              
    
                Set<String> idStrs = (Set<String>)JSON.deserialize(JSON.serialize(usersMap.keySet()), Set<String>.class);
                notification.send(idStrs);
    
                // * SEND SEPARATE EMAIL TO USERS
                String managerName = [SELECT Name FROM Contact WHERE Id =: managerId LIMIT 1]?.Name;
                Id orgWideId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1]?.Id;
                List<Messaging.SingleEmailMessage> allMessages = new List<Messaging.SingleEmailMessage>();
                    // for(User u : usersMap.values()) {
                for(Contact c : conList) {
                    if(conId_payperiod_map.get(c.Id) != null) {
                        Date weekStartDate = conId_payperiod_map.get(c.Id).toStartofWeek();
                        Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
                        Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
                        Date dateTo = dateFrom.addDays(13);

                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.optOutPolicy = 'FILTER';
                        message.subject = 'Timesheet Rejected.';
                        message.plainTextBody = 'The timesheet for the pay period "' + dateFrom.format() + ' - ' + dateTo.format() + '" has been rejected by "' + managerName + '" at "' + Datetime.now().format('HH:mm a') + '"';
                        System.debug(':::: conList[0].Personal_Email__c: ' + c.Personal_Email__c);
                        
                        message.toAddresses = new String[] { c.Personal_Email__c };
                        message.setOrgWideEmailAddressId(orgWideId);
                        allMessages.add(message);
                    }
                }
                    
                if(!allMessages.isEmpty()) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(allMessages);
                    for(Messaging.SendEmailResult r : results) {
                        System.debug(':::: r.getErrors(): ' + r.getErrors());
                        System.debug(':::: isSuccess: ' + r.isSuccess());
                    }
                }
    
    
    
                  // rejection email and notification end  
    

                    update timeSheetListToReject;
                    return 'OK';
                }
            }
            return 'NOT OK';
        } catch(Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
//done
    @AuraEnabled
    public Static string unlockTimesheets(List<TimesheetWrapper> timesheets, String managerId) {   //chanage userId to managerId
        try {
            System.debug(':::: unlockTimesheets => unlockTimesheets.size: ' + timesheets.size());
            System.debug('managerId:::: ' + managerId);
            if(!timesheets.isEmpty()) {
                List<TimeSheet__c> timeSheetListToApprove = new List<TimeSheet__c>();
                Set<String> conIds = new Set<String>();
                Map<String,Date> conId_payperiod_map = new Map<String,Date>();

                for(TimesheetWrapper singleTimesheet : timesheets) {
                    TimeSheet__c t = new TimeSheet__c();
                    t.Id = singleTimesheet.id;
                    t.Status__c = '';
                    timeSheetListToApprove.add(t);
                    conIds.add(singleTimesheet.contactId);
                    conId_payperiod_map.put(singleTimesheet.contactId, singleTimesheet.dayDate);
                }
                List<Contact> conList = [SELECT Personal_Email__c FROM Contact WHERE Id IN: conIds];
                if(!timeSheetListToApprove.isEmpty()) {

                    Date weekStartDateNotification = conId_payperiod_map.get(conList[0].Id).toStartofWeek();
                    Date initialWeekStartDateNotification = getDayName(weekStartDateNotification).toLowerCase() == 'sunday' ? weekStartDateNotification : WeekStartDateNotification - 1;
                    Date dateFromNotification = initialWeekStartDateNotification.addDays(-7); // NEW WORK SAME AS ADP
                    Date dateToNotification = dateFromNotification.addDays(13);

                    CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                    FROM CustomNotificationType 
                    WHERE DeveloperName = 'TimeCardNotification'];

                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle('Timesheet Unlock.');
                    notification.setBody( dateFromNotification.format() + ' - ' + dateToNotification.format() + '" Timesheet has been unlocked.');
                    notification.setNotificationTypeId(notificationType.Id);
                    Map<String, Object> communityPageRef = new Map<String, Object>{
                        'type' => 'comm__namedPage',
                        'attributes' => new Map<String, Object>{
                        'pageName' => 'home'
                        }
                    };

                    notification.setTargetPageRef(JSON.serialize(communityPageRef));
                    
                    Map<Id,User> usersMap = new Map<Id,User>([SELECT Id, Contact.Email, Contact.Personal_Email__c FROM User WHERE ContactId IN: conIds]);
                   
                    
                    Set<String> idStrs = (Set<String>)JSON.deserialize(JSON.serialize(usersMap.keySet()), Set<String>.class);
                    notification.send(idStrs);
             
                    // * SEND SEPARATE EMAIL TO USERS
                   String userName = [SELECT Name FROM Contact WHERE Id =: managerId LIMIT 1]?.Name;

                    // String managerName = [SELECT Name FROM Contact WHERE Id =: managerId LIMIT 1]?.Name;
                    List<Messaging.SingleEmailMessage> allMessages = new List<Messaging.SingleEmailMessage>();

                    Id orgWideId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1]?.Id;

                    for(Contact c : conList) {
                        if(conId_payperiod_map.get(c.Id) != null) {
                            Date weekStartDate = conId_payperiod_map.get(c.Id).toStartofWeek();
                            Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
                            Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
                            Date dateTo = dateFrom.addDays(13);

                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            message.optOutPolicy = 'FILTER';
                            message.subject = 'Timesheet Unlock.';
                            //message.plainTextBody = 'The timesheet for the requested pay period "' + String.valueOf(dateFrom).subStringBefore('00:') + ' - ' + String.valueOf(dateTo).subStringBefore('00:') + '" has been unlocked by "' + userName + '" at "' + Datetime.now() + '"';
                            message.plainTextBody = 'The timesheet for the requested pay period "' + dateFrom.format() + ' - ' + dateTo.format() + '" has been unlocked by "' + userName + '" at "' + Datetime.now().format('HH:mm a') + '"';
                            System.debug(':::: c.Personal_Email__c: ' + c.Personal_Email__c);
                            
                            message.toAddresses = new String[] { c.Personal_Email__c };
                            message.setOrgWideEmailAddressId(orgWideId);
                            allMessages.add(message);
                        }
                    }
               
               if(!allMessages.isEmpty()) {
               
               Messaging.SendEmailResult[] results = Messaging.sendEmail(allMessages);
               for(Messaging.SendEmailResult r : results) {
               System.debug(':::: r.getErrors(): ' + r.getErrors());
               System.debug(':::: isSuccess: ' + r.isSuccess());
               }
               }
             
             
             
             // unlock email and notification end
             



                    update timeSheetListToApprove;
                    System.debug(':::: conIds: ' + conIds);


                    List<Request_History__c> requestHis =   [SELECT Id, Status__c, Date_from_new__c, Date_to_new__c 
                                                            FROM Request_History__c
                                                            WHERE Contact__c IN: conIds
                                                            AND Status__c = 'Requested to Unlock'];
                    System.debug(':::: requestHis: ' + requestHis.size());
                    System.debug(':::: requestHis: ' + requestHis);
                    
                    for(Request_History__c r : requestHis) {
                        for(TimesheetWrapper t: timesheets) {
                            if(t.dayDate >= r.Date_from_new__c && t.dayDate <= r.Date_to_new__c) {
                                r.Status__c = 'Unlocked/Saved';
                            }
                        }
                    }

                    update requestHis;
                    System.debug(':::: unlockTimesheets => OK');

                    return 'OK';
                }
            }
            return 'NOT OK';
        } catch(Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public Static List<TimesheetWrapper> getUpdateRequestEmployeeListNewV2(String conId, Date dateFromParam, Date dateToParam, String timeOption, Boolean isNesponManager, Boolean isDivisionalHeadUnlock, Boolean isHRPractitionerUnlock) {
        try {
            System.debug(':::: getUpdateRequestEmployeeList START');
            Date weekStartDate = Date.today().toStartofWeek();
            
            Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
            initialWeekStartDate = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
            Date initialWeekEndDate = initialWeekStartDate.addDays(13);
            Date finalDateFrom; 
            Date finalDateTo;


            if(dateFromParam != null) {
                finalDateFrom = dateFromParam;
            } else {
                finalDateFrom = initialWeekStartDate;
            }
            if(dateToParam != null) {
                finalDateTo = dateToParam;
            } else {
                finalDateTo = initialWeekEndDate;
            }
            
            if(timeOption == 'Current Pay Period') {
                finalDateFrom = initialWeekStartDate;
                finalDateTo = initialWeekEndDate;
            }
            else if(timeOption == 'Next Pay Period') {
                finalDateFrom = initialWeekStartDate.addDays(14);
                finalDateTo = finalDateFrom.addDays(13);
            }
            else if(timeOption == 'Previous Pay Period') {
                finalDateFrom = initialWeekStartDate.addDays(-14);
                finalDateTo = finalDateFrom.addDays(13);
            }
            
            System.debug('finalDateFrom: '+finalDateFrom);
            System.debug('finalDateTo: '+finalDateTo);
            // List<Contact> contactLst = [SELECT Id, Name FROM Contact 
            //                             WHERE Nespon_Manager__c = :conId
            //                             OR Account.Divisional_Head__c =: conId];
            // return contactLst;

            String query = 'SELECT Id, Name, Position_Id__c, Account.Name, Job_Title_Description__c FROM Contact';
            if(!isHRPractitionerUnlock) {
                if(isNesponManager && isDivisionalHeadUnlock) {
                    query += ' WHERE Nespon_Manager__c = \'' + conId + '\' OR Account.Divisional_Head__c = \'' + conId + '\'';
                }
                else if(isNesponManager) {
                    query += ' WHERE Nespon_Manager__c = \'' + conId + '\'';
                } else if(isDivisionalHeadUnlock) {
                    query += ' WHERE Account.Divisional_Head__c = \'' + conId + '\'';
                }
            }
            query += ' LIMIT 50000';

            System.debug(':::: query: ' + query);

            List<Contact> contactLst = Database.query(query);
            System.debug(':::: contactLst: '+contactLst);
            Set<String> contactIds = new Set<String>();
            for(Contact rec : contactLst) {
                contactIds.add(rec.Id);
            }


            // :::::::::::::::::
            // List<Request_History__c> requestHistoryList = [SELECT Id, Status__c, Reason__c, Date_To__c, Date_Time__c, Contact__c, Contact__r.Name, Contact__r.Position_ID__c, Contact__r.Account.Name FROM Request_History__c WHERE Contact__c in :contactIds AND Status__c='Requested to Unlock'];
            
            
            List<Request_History__c> requestHistoryList = [SELECT Id, Status__c, Reason__c, 
                                                            Date_To__c, Date_Time__c, Date_from_new__c, Date_to_new__c, Contact__c, 
                                                            Contact__r.Name, Contact__r.Position_ID__c, 
                                                            Contact__r.Account.Name 
                                                            FROM Request_History__c 
                                                            WHERE 
                                                            Date_from_new__c >= :finalDateFrom 
                                                            AND Date_to_new__c <= :finalDateTo 
                                                            AND 
                                                            Status__c = 'Requested to Unlock' 
                                                            AND Contact__c in :contactIds];
            System.debug('@@requestHistoryList: '+requestHistoryList);
            List<TimesheetWrapper> timesheetWrapperList = new List<TimesheetWrapper>();
            for(Request_History__c rec : requestHistoryList){
                TimesheetWrapper wrapperObj = new TimesheetWrapper();
                wrapperObj.id = rec.Id;
                wrapperObj.reqEditReason = rec.Reason__c;
                wrapperObj.contactId = rec.Contact__c;
                wrapperObj.userName = rec.Contact__r.Name;
                wrapperObj.reqPositionId = rec.Contact__r.Position_ID__c;
                wrapperObj.divisionalOffice = rec.Contact__r.Account.Name;
                // wrapperObj.reqDateFrom = rec.Date_Time__c.date();
                // wrapperObj.reqDateTo = rec.Date_To__c.date();
                wrapperObj.reqDateFrom = rec.Date_from_new__c;
                wrapperObj.reqDateTo = rec.Date_to_new__c;
                timesheetWrapperList.add(wrapperObj);
            }

            return timesheetWrapperList;
            
        } catch (Exception e) {
            System.debug(':::: Exception: ' + e.getMessage() + ' On Line: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
//done
    public class ComboboxValues {
        @AuraEnabled 
        public String label {get; set;}
        @AuraEnabled 
        public String value {get; set;}
        @AuraEnabled 
        public String paycode {get; set;}
    }
//done
    public class TimesheetWrapper {
        @AuraEnabled 
        public String userName {get; set;}
        @AuraEnabled 
        public Decimal totalOvertimeHours {get; set;}
        @AuraEnabled 
        public Time overtimeFrom {get; set;}
        @AuraEnabled 
        public Boolean isEmptyRow {get; set;}
        @AuraEnabled 
        public Time overtimeTo {get; set;}
        @AuraEnabled 
        public String overtimeDescription {get; set;}
        @AuraEnabled 
        public String overtimeType {get; set;}
        @AuraEnabled 
        public Integer emptyRowNumber {get; set;}
        @AuraEnabled 
        public String id {get; set;}
        @AuraEnabled 
        public Boolean inEditMode {get; set;}
        @AuraEnabled 
        public Boolean isEditable {get; set;}
        @AuraEnabled 
        public Boolean timsheetSaved {get; set;}
        @AuraEnabled 
        public Boolean approved {get; set;}
        @AuraEnabled 
        public Boolean submitted {get; set;}
        @AuraEnabled 
        public Boolean empty {get; set;}
        @AuraEnabled 
        public Boolean recall {get; set;}
        @AuraEnabled 
        public Boolean rejected {get; set;}
        @AuraEnabled
        public String dayName {get; set;}
        @AuraEnabled
        public Date dayDate {get; set;}
        @AuraEnabled
        public String payCode {get; set;}
        @AuraEnabled 
        public List<ComboboxValues> payCodes {get; set;}
        @AuraEnabled
        public String project {get; set;}
        @AuraEnabled
        public String projectName {get; set;}
        @AuraEnabled 
        public List<ComboboxValues> projects {get; set;}
        @AuraEnabled
        public String rate {get; set;}
        @AuraEnabled
        public String projectParticipantRole {get; set;}
        @AuraEnabled
        public Decimal hours {get; set;}
        @AuraEnabled
        public String divisionalOffice {get; set;}
        @AuraEnabled
        public String regularHours {get; set;}
        @AuraEnabled
        public Boolean overTime {get; set;}
        @AuraEnabled
        public Decimal totalHours {get; set;}
        @AuraEnabled
        public Boolean combineRow {get; set;} // This will be used when we have multiple TimeSheet for Same Day
        @AuraEnabled
        public String reqEditReason {get; set;} // Asir added new property For getting request to edit reason
        @AuraEnabled
        public String reqPositionId {get; set;} // Asir added new property For getting position id of employee
        @AuraEnabled
        public Date reqDateFrom {get; set;} // Asir added new property For getting date from
        @AuraEnabled
        public Date reqDateTo {get; set;} // Asir added new property For getting date to
        @AuraEnabled
        public Boolean disableCheckbox {get; set;} // Asir added new property For handling the checkbox on timesheet row
        // FOR SUMMARY
        @AuraEnabled
        public Integer totalRowsInDay {get; set;}
        @AuraEnabled
        public Decimal totalhoursInDay {get; set;}
        @AuraEnabled
        public Boolean summaryRow {get; set;}
        @AuraEnabled
        public Boolean showEachRowTotal {get; set;}

        // * For Employee Project Total Hour - Used In Approval
        @AuraEnabled
        public String contactId {get; set;}
        @AuraEnabled
        public String projectParticipantId {get; set;}
        @AuraEnabled
        public String month {get; set;}
        @AuraEnabled
        public Integer year {get; set;}
        
        @AuraEnabled
        public Boolean weeklySumRow {get; set;}
        @AuraEnabled
        public Integer weekNumber {get; set;}

        @AuraEnabled
        public String rejectionReason {get; set;}
        @AuraEnabled
        public string approvalMsg {get; set;}
        
    }
 
}