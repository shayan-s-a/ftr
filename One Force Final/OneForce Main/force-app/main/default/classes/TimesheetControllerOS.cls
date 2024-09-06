public class TimesheetControllerOS {
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getUserDetails(String userId) {
        Map<String,String> userDetails = new Map<String,String>();
        try {
            System.debug(':::: userId: ' + userId);
            List<User> users = [SELECT Id, ContactId FROM User
                                WHERE Id =: userId];
            if(!users.isEmpty()) {
                System.debug(':::: user: ' + users[0]); 

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
                                        WHERE Id =: users[0].ContactId];
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
                                                            AND Status__c = 'Submitted'];

                    System.debug(':::: timesheetForApprRej: ' + timesheetForApprRej.size());
                    userDetails.put('employeeTimesheetsFound', !timesheetForApprRej.isEmpty() ? 'true' : 'false');

                    // * Check if the current user is Manager in any of the Projects
                    List<Project__c> projectManager = [SELECT Id FROM Project__c
                                                    WHERE Contact__c =: con.Id];
                                                    
                    System.debug(':::: projectManager: ' + projectManager);
                    userDetails.put('isLineManager', !projectManager.isEmpty() ? 'true' : 'false');

                    List<TimeSheet__c> timesheetRequests = [SELECT Id FROM TimeSheet__c
                                                            WHERE Status__c = 'Recall'
                                                            AND Contact__r.Nespon_Manager__c =: con.Id];
                    if(!timesheetRequests.isEmpty()) {
                        userDetails.put('requestFound', 'true');
                    }
                }
            }
            return userDetails;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public Static List<TimesheetWrapper> getTimesheetByDate(String conId, Date dateFromParam, Date dateToParam, String timeOption) {
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
            List<TimeSheet__c> timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                                Project__r.Name,
                                                Hours__c, Overtime__c, Pay_Code__c, Final_Hours__c,
                                                Status__c, Contact__r.Name,
                                                Contact__r.Account.Name,
                                                Type_of_participation__c,
                                                Project_Participants__c,
                                                Project_Participants__r.Role__c
                                                FROM TimeSheet__c
                                                WHERE Contact__c =: conId
                                                AND Day__c >=: finalDateFrom
                                                AND Day__c <=: finalDateTo];

            List<ComboboxValues> userProjects = getUserProjects(conId);
            List<ComboboxValues> payCodes = getPayCodeValues();

            System.debug(':::: userProjects: ' + userProjects);

            Map<Date,List<TimesheetWrapper>> day_timsheets_map = new Map<Date,List<TimesheetWrapper>>();
            if(!timesheetList.isEmpty()) {
                for(TimeSheet__c t: timesheetList) {
                    if(day_timsheets_map.get(t.Day__c) == null || day_timsheets_map.get(t.Day__c).isEmpty()) {
                        TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false);
                        day_timsheets_map.put(t.Day__c, new List<TimesheetWrapper>{ singleTimesheetByDay });
                    }
                    else {
                        List<TimesheetWrapper> finalTimesheetByDay = day_timsheets_map.get(t.Day__c);
                        TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false);
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
                            weekSum += t.hours;
                            totalCount++;
                            totalHours += t.hours;
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
                        finalResponse.addAll(day_timsheets_map.get(finalDateFrom + i));
                        weekSum += day_timsheets_map.get(finalDateFrom + i)[0].hours;
                        
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
                    emptyTimesheetRow.inEditMode = false;
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
            return finalResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

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
                                                Project_Participants__r.Role__c
                                                FROM TimeSheet__c
                                                WHERE Contact__r.Nespon_Manager__c =: conId
                                                AND Status__c = 'Submitted'
                                                AND Day__c >=: dateFrom
                                                AND Day__c <=: dateTo];
            System.debug(':::: timesheetList.size: ' + timesheetList.size());
            if(!timesheetList.isEmpty()) {
                List<ComboboxValues> userProjects = getUserProjects(conId);
                List<ComboboxValues> payCodes = getPayCodeValues();

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
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false);
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, new List<TimesheetWrapper>{ singleTimesheetByDay });
                        }
                        else {
                            List<TimesheetWrapper> finalTimesheetByDay = dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name);
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false);
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
                                                Project_Participants__r.Role__c
                                                FROM TimeSheet__c
                                                WHERE Project__r.Contact__c =: conId // Line Manager
                                                AND Day__c >=: dateFrom
                                                AND Day__c <=: dateTo];
            System.debug(':::: getTimesheetToView => timesheetList.size: ' + timesheetList.size());
            if(!timesheetList.isEmpty()) {
                List<ComboboxValues> userProjects = getUserProjects(conId);
                List<ComboboxValues> payCodes = getPayCodeValues();

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
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false);
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, new List<TimesheetWrapper>{ singleTimesheetByDay });
                        }
                        else {
                            List<TimesheetWrapper> finalTimesheetByDay = dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name);
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false);
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
                                                Project_Participants__r.Role__c
                                                FROM TimeSheet__c
                                                WHERE  Status__c = 'Recall'
                                                AND Contact__r.Nespon_Manager__c =: conId
                                                // AND Day__c >=: dateFrom
                                                // AND Day__c <=: dateTo
                                                ORDER BY Contact__r.Name ASC];
                                                //ORDER BY Day__c ASC];
            System.debug(':::: getTimesheetsUpdateRequests => getTimesheetsUpdateRequests.size: ' + timesheetList.size());
            if(!timesheetList.isEmpty()) {
                List<ComboboxValues> userProjects = getUserProjects(conId);
                List<ComboboxValues> payCodes = getPayCodeValues();

                System.debug(':::: userProjects: ' + userProjects);

                Map<String,List<TimesheetWrapper>> dayUser_timsheets_map = new Map<String,List<TimesheetWrapper>>();
                
                if(!timesheetList.isEmpty()) {
                    for(TimeSheet__c t: timesheetList) {
                        if(dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name) == null || dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name).isEmpty()) {
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, false, false);
                            dayUser_timsheets_map.put(t.Day__c + t.Contact__r.Name, new List<TimesheetWrapper>{ singleTimesheetByDay });
                        }
                        else {
                            List<TimesheetWrapper> finalTimesheetByDay = dayUser_timsheets_map.get(t.Day__c + t.Contact__r.Name);
                            TimesheetWrapper singleTimesheetByDay = fillSingleTimesheet(t, userProjects, payCodes, true, false);
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
    

    public Static List<ComboboxValues> getUserProjects(String conId) {
        try {
            List<ComboboxValues> finalResponse = new List<ComboboxValues>();
            List<Project_Participants__c> projectParticipants = [SELECT Project__c, Project__r.Name 
                                                                FROM Project_Participants__c
                                                                WHERE Contact__c =: conId];
            System.debug(':::: projectParticipants: ' + projectParticipants);
            if(!projectParticipants.isEmpty()) {
                Map<String,String> uniqueProjects = new Map<String,String>();
                for(Project_Participants__c pp : projectParticipants) {
                    uniqueProjects.put(pp.Project__c, pp.Project__r.Name);
                    System.debug(':::: pp.Project__c: ' + pp.Project__c);
                    System.debug(':::: pp.Project__r.Name: ' + pp.Project__r.Name);
                }

                for(String projId : uniqueProjects.keySet()) {
                    ComboboxValues res = new ComboboxValues();
                    res.label = uniqueProjects.get(projId);
                    res.value = projId;
                    finalResponse.add(res);
                }
            }
            return finalResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

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

    public Static List<ComboboxValues> getPayCodeValues() {
        List<ComboboxValues> payCodes = new List<ComboboxValues>();
        Schema.DescribeFieldResult fieldResult = TimeSheet__c.Pay_Code__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            ComboboxValues combobox = new ComboboxValues();
            combobox.label = pickListVal.getLabel();
            combobox.value = pickListVal.getValue();
            payCodes.add(combobox);
		}
        return payCodes;
    }

    public Static TimesheetWrapper fillSingleTimesheet(TimeSheet__c timesheet, List<ComboboxValues> projects, List<ComboboxValues> payCodes, Boolean sameDay, Boolean viewOnly) {
        TimesheetWrapper singleTimesheet = new TimesheetWrapper();
        singleTimesheet.id = timesheet.Id;
        if(timesheet.Status__c == null || timesheet.Status__c == '') {
            if(!viewOnly) {
                singleTimesheet.isEditable = true;
            }
            singleTimesheet.timsheetSaved = true;
        }
        else if(timesheet.Status__c == 'Submitted') {
            singleTimesheet.submitted = true;
        }
        else if(timesheet.Status__c == 'Approved') {
            singleTimesheet.approved = true;
        }
        else if(timesheet.Status__c == 'Recall') {
            singleTimesheet.recall = true;
        }
        else if(timesheet.Status__c == 'Rejected') {
            if(!viewOnly) {
                singleTimesheet.isEditable = true;
            }
            singleTimesheet.rejected = true;
        }
        singleTimesheet.dayName = getDayName(timesheet.Day__c);
        singleTimesheet.dayDate = timesheet.Day__c;
        singleTimesheet.hours = timesheet.Hours__c;
        singleTimesheet.totalHours = timesheet.Hours__c; // ! Might need to Change Later
        singleTimesheet.project = timesheet.Project__c;
        singleTimesheet.projectName = timesheet.Project__r?.Name;
        singleTimesheet.projects = projects;
        singleTimesheet.payCode = timesheet.Pay_Code__c;
        singleTimesheet.payCodes = payCodes;
        singleTimesheet.inEditMode = false;
        if(sameDay) {
            singleTimesheet.combineRow = true;
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

    public Static String getDayName(Date dateValue) {
        Datetime dt = (DateTime) dateValue + 1; 
        String dayOfWeek = dt.format('EEEE');
        return dayOfWeek;
    }

    public Static String getMonthName(Date dateValue) {
        Datetime dt = (DateTime) dateValue; 
        String monthName = dt.format('MMMM');
        return monthName;
    }

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
                    ts.Hours__c = singleTimesheet.hours;
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
                    singleTimesheet.Status__c = 'Submitted';
                    timesheetsToSubmit.add(singleTimesheet);
                }
                update timesheetsToSubmit;

                // * SEND EMAIL + COMMUNITY NOTIFICATION
                List<Contact> contacts = [SELECT Nespon_Manager__c FROM Contact 
                                        WHERE Id =: conId LIMIT 1];

                CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                        FROM CustomNotificationType 
                                                        WHERE DeveloperName = 'TimeCardNotification'];
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Timesheet is waiting for Approval.');
                notification.setBody(timesheets[0].userName + ' has submitted timesheet for approval.');
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
                message.subject = 'Timesheet is waiting for Approval.';
                message.plainTextBody = timesheets[0].userName + ' has submitted timesheet for approval.';
                
                List<User> user = [SELECT Id, Email FROM User WHERE ContactId =: contacts[0].Nespon_Manager__c];
                if(!user.isEmpty()) {
                    System.debug(':::: user: ' + user[0]);
                    System.debug(':::: user[0]?.Email: ' + user[0]?.Email);
                    notification.send(new Set<String>{user[0]?.Id});
                    message.toAddresses = new String[] { user[0]?.Email };
                    System.debug(':::: message: ' + message);
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
                    if(user[0]?.Email != null) {
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

    @AuraEnabled
    public Static string recallRecords(List<TimesheetWrapper> timesheets, String conId, String reason, DateTime datef, String payPeriod ) {
        try {
            if(timesheets != null && !timesheets.isEmpty()) {
                System.debug(':::: recallRecords => timesheets:.size: ' + timesheets.size());
                List<Timesheet__c> timesheetsToSubmit = new List<Timesheet__c>();
                for(TimesheetWrapper t : timesheets) {
                    TimeSheet__c singleTimesheet = new TimeSheet__c();
                    singleTimesheet.Id = t.Id;
                    singleTimesheet.Status__c = 'Recall';
                    timesheetsToSubmit.add(singleTimesheet);
                }
                update timesheetsToSubmit;

                // save record reason
                Request_History__c newReqHistory = new Request_History__c();
                newReqHistory.Reason__c = reason;
                newReqHistory.Pay_Period__c= payPeriod;
                newReqHistory.Contact__c= conId;
                newReqHistory.Date_Time__c= datef;
                newReqHistory.Status__c='Requested to Unlock';
                insert newReqHistory;

                // * SEND EMAIL + COMMUNITY NOTIFICATION
                List<Contact> contacts = [SELECT Nespon_Manager__c FROM Contact 
                                        WHERE Id =: conId LIMIT 1];

                CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                        FROM CustomNotificationType 
                                                        WHERE DeveloperName = 'TimeCardNotification'];
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Request to Update Timesheet.');
                notification.setBody(timesheets[0].userName + ' is requesting to update timesheet.');
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
                message.subject = 'Request to Update Timesheet.';
                message.plainTextBody = timesheets[0].userName + ' is requesting to update timesheet.';
                
                List<User> user = [SELECT Id, Email FROM User WHERE ContactId =: contacts[0].Nespon_Manager__c];
                if(!user.isEmpty()) {
                    notification.send(new Set<String>{user[0]?.Id});
                    message.toAddresses = new String[] { user[0].Email };
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
                    if(user[0].Email != null) {
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

    @AuraEnabled
    public Static string approveTimesheets(List<TimesheetWrapper> timesheets, String managerId) {
        try {
            System.debug(':::: approveTimesheets => timesheets.size: ' + timesheets.size());
            if(!timesheets.isEmpty()) {
                List<TimeSheet__c> timeSheetListToApprove = new List<TimeSheet__c>();
                
                Map<String,List<TimesheetWrapper>> uniquename_timesheets_map = new Map<String,List<TimesheetWrapper>>();
                
                Set<Id> conIds = new Set<Id>();
                Map<String,Date> conId_payperiod_map = new Map<String,Date>();

                for(TimesheetWrapper singleTimesheet : timesheets) {
                    TimeSheet__c t = new TimeSheet__c();
                    t.Id = singleTimesheet.id;
                    t.Status__c = 'Approved';
                    t.Approved_By__c = managerId;
                    timeSheetListToApprove.add(t);
                    
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

                if(!timeSheetListToApprove.isEmpty()) {
                    update timeSheetListToApprove;

                    List<EmpProjectTotalHr__c> empTotalHrList = [SELECT Id, Name, Contact__c, Project_Participants__c,
                                                                Pay_Code__c, Month__c, Year__c, Timecard_Hours__c
                                                                FROM EmpProjectTotalHr__c
                                                                WHERE Contact__c IN: conIds];

                    // FOR SENDING NOTIFICATION TO EMPLOYEES
                    CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                        FROM CustomNotificationType 
                                                        WHERE DeveloperName = 'TimeCardNotification'];
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle('Timesheet Approved.');
                    notification.setBody('Your Timesheet has been approved.');
                    notification.setNotificationTypeId(notificationType.Id);
                    Map<String, Object> communityPageRef = new Map<String, Object>{
                        'type' => 'comm__namedPage',
                        'attributes' => new Map<String, Object>{
                            'pageName' => 'home'
                        }
                    };
                    notification.setTargetPageRef(JSON.serialize(communityPageRef));

                    Map<Id,User> usersMap = new Map<Id,User>([SELECT Id, Contact.Email, Contact.Personal_Email__c FROM User WHERE ContactId IN: conIds]);
                    List<Contact> conList = [SELECT Personal_Email__c, Name FROM Contact WHERE Id IN: conIds];
                    
                    Set<String> idStrs = (Set<String>)JSON.deserialize(JSON.serialize(usersMap.keySet()), Set<String>.class);
                    notification.send(idStrs);

                    String managerName = [SELECT Name FROM Contact WHERE Id =: managerId LIMIT 1]?.Name;
                    // * SEND SEPARATE EMAIL TO USERS
                    List<Messaging.SingleEmailMessage> allMessages = new List<Messaging.SingleEmailMessage>();
                    for(Contact c : conList) {

                        if(conId_payperiod_map.get(c.Id) != null) {
                            Date weekStartDate = conId_payperiod_map.get(c.Id).toStartofWeek();
                            Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
                            Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
                            Date dateTo = dateFrom.addDays(13);
    
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            message.optOutPolicy = 'FILTER';
                            message.subject = 'Timesheet Approved.';
                            message.plainTextBody = 'The timesheet for the pay period "' + String.valueOf(dateFrom).subStringBefore('00:') + ' - ' + String.valueOf(dateTo).subStringBefore('00:') + '" has been approved by "'+managerName+'" at "'+Datetime.now()+'"';
                            System.debug(':::: conList[0].Personal_Email__c: ' + c.Personal_Email__c);
                            
                            message.toAddresses = new String[] { c.Personal_Email__c };
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
                    return 'OK';
                }
            }
            return 'NOT OK';
        } catch(Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public Static string rejectTimesheets(List<TimesheetWrapper> timesheets) {
        try {
            System.debug(':::: rejectTimesheets => timesheets.size: ' + timesheets.size());
            if(!timesheets.isEmpty()) {
                List<TimeSheet__c> timeSheetListToReject = new List<TimeSheet__c>();
                
                Map<String,List<TimesheetWrapper>> uniquename_timesheets_map = new Map<String,List<TimesheetWrapper>>();
                
                Set<Id> conIds = new Set<Id>();

                for(TimesheetWrapper singleTimesheet : timesheets) {
                    TimeSheet__c t = new TimeSheet__c();
                    t.Id = singleTimesheet.id;
                    t.Status__c = 'Rejected';
                    timeSheetListToReject.add(t);

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
                if(!timeSheetListToReject.isEmpty()) {
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

    @AuraEnabled
    public Static string approveTimesheetUpdateRequests(List<TimesheetWrapper> timesheets) {
        try {
            System.debug(':::: approveTimesheetUpdateRequests => approveTimesheetUpdateRequests.size: ' + timesheets.size());
            if(!timesheets.isEmpty()) {
                List<TimeSheet__c> timeSheetListToApprove = new List<TimeSheet__c>();
                for(TimesheetWrapper singleTimesheet : timesheets) {
                    TimeSheet__c t = new TimeSheet__c();
                    t.Id = singleTimesheet.id;
                    t.Status__c = '';
                    timeSheetListToApprove.add(t);
                }
                if(!timeSheetListToApprove.isEmpty()) {
                    update timeSheetListToApprove;
                    System.debug(':::: approveTimesheetUpdateRequests => OK');
                    return 'OK';
                }
            }
            return 'NOT OK';
        } catch(Exception ex) {
            System.debug(':::: Exception: ' + ex.getMessage() + ' On Line: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }


    public class ComboboxValues {
        @AuraEnabled 
        public String label {get; set;}
        @AuraEnabled 
        public String value {get; set;}
    }

    public class TimesheetWrapper {
        @AuraEnabled 
        public String userName {get; set;}
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
        public String overTime {get; set;}
        @AuraEnabled
        public Decimal totalHours {get; set;}
        @AuraEnabled
        public Boolean combineRow {get; set;} // This will be used when we have multiple TimeSheet for Same Day
        
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
        
    }
}