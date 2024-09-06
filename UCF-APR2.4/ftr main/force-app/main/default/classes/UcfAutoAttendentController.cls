public class UcfAutoAttendentController {

    @AuraEnabled(cacheable=true)
public static List<ftr_DID_Number_Details__c> ftrDIDNumberDetailsAutoAttendants() {
    System.debug('AA called');
    List<ftr_DID_Number_Details__c> DIDNumberDetail = [SELECT Id,DIDNumber__c,Ucf_Extension__c,EAS_Pin__c, 
    ucf_Auto_Attendent_Name__c, Ring_Pattern__c,Ucf_User_Name__c,Schedule__c,Member__c,MLHG_Name__c FROM ftr_DID_Number_Details__c WHERE Ucf_Number_Use__c='Multi-Line Hunting Group'];
    return DIDNumberDetail;
}

    @AuraEnabled
public static List<Time_Period__c> saveTimePeriods(List<Time_Period__c> timePeriods) {
    // Perform any required processing before saving
    // Always ensure that you handle exceptions and check for permissions as needed
    try {
        insert timePeriods;
    } catch (Exception e) {
        // Handle the exception appropriately
        throw new AuraHandledException('Error saving time periods: ' + e.getMessage());
    }
    return timePeriods;
}
    @AuraEnabled(cacheable=true)
public static List<Schedule__c> ScheduleforAutoAttendantsSetUp() {
    List<Schedule__c> Schedule = [SELECT Id,Name,UCF_Order__c,RecordType.Name FROM Schedule__c where RecordType.Name =: 'Auto Attendants'];
    System.debug(Schedule);
    return Schedule;
}
//Methods for AA Schedules
@AuraEnabled
public static List<Schedule__c> ScheduleforAutoAttendantsSchedules(String orderId) {
List<Schedule__c> schedule = [SELECT Id, UCF_Name__c,Name,X247_checkbox__c,
                                    Overflow_Destination_24_7__c,
                                    Overflow_Timer_Closed__c,
                                    Overflow_Destination_Closed__c,
                                    Overflow_Timer_Open__c,
                                    Overflow_Destination_Open__c,
                                    Monday_Start_Time__c,
                                    Monday_End_Time__c,
                                    Tuesday_Start_Time__c,
                                    Tuesday_End_Time__c,
                                    Wednesday_Start_Time__c,
                                    Wednesday_End_Time__c,
                                    Thursday_Start_Time__c,
                                    Thursday_End_Time__c,
                                    Friday_Start_Time__c,
                                    Friday_End_Time__c,
                                    Saturday_Start_Time__c,
                                    Saturday_End_Time__c,
                                    Sunday_Start_Time__c,
                                    Sunday_End_Time__c,
                                    Monday__c,
                                    Tuesday__c,
                                    Wednesday__c,
                                    Thursday__c, 
                                    Friday__c, 
                                    Ucf_Men_24_7__c,Ucf_Menu_Close__c,Ucf_Menu_Open__c,Menu_Holiday__c,
                                    Saturday__c, Sunday__c,RecordType.Name 
                                FROM Schedule__c where UCF_Order__c = :orderId AND RecordType.Name =: 'Auto Attendants'];
return schedule;
}
    @AuraEnabled
public static List<Menu_Line__c> getMenuLines(String menuId) {
    // Query to get existing Menu Lines
    return [SELECT id, Number__c, Options__c, Label__c, Destination_Info__c, Greeting__c, Sub_Menu__c
        FROM Menu_Line__c where Menu__c =: menuId ORDER BY  sort_order__c];
}

@AuraEnabled
public static List<Menu_Line__c> downloadMenuLines(String OrderId) {
    // Query to get existing Menu
      Map<ID, Menu__c> mapMenu = new Map<ID, Menu__c>([Select Id, OwnerId,Name, Greeting__c, Order__c From Menu__c Where Order__c =: OrderId]);
      if( mapMenu != null || !mapMenu.isEmpty())
      {
          List<Menu_Line__c> lstMenuLine = [Select Id, OwnerId, Name, Destination_Info__c, Greeting__c, Label__c, Menu__c, Number__c, Options__c, Sort_Order__c,
                                Sub_Menu__c,Menu__r.Name From Menu_Line__c Where Menu__c =: mapMenu.keyset()];
          
          return lstMenuLine;
      }
      
    else
    {
        return new List<Menu_Line__c>();
    }
}
 @AuraEnabled
    public static List<Holiday__c> downloadHolidaysByAASchedule(string OrderId ) {
        
        Map<ID, Schedule__c> mapSchedules = new Map<ID, Schedule__c>([SELECT Id,Name FROM Schedule__c WHERE RecordType.DeveloperName =: 'Auto_Attendants' and  UCF_Order__c =: OrderId ]);
        System.Debug('mapSchedules =' +  mapSchedules);
        if(mapSchedules != null || !mapSchedules.isEmpty())
        {
            List<Holiday__c> lstHolidays = [SELECT  Id, OwnerId, IsDeleted, Name,ConnectionReceivedId, ConnectionSentId, Date__c, Schedule__c,
                                            Ucf_Menu__c, Sort_Order__c,Schedule__r.UCF_Name__c 
                                            FROM Holiday__c
                                            WHERE Schedule__c =: mapSchedules.keyset() order by Schedule__r.UCF_Name__c asc];    
            System.Debug('lstHolidays =' +  lstHolidays);
            return lstHolidays;
        }
        else 
        {
            return new List<Holiday__c>();
        }
        
    }
//osama work downloadCustomtimeperiod
@AuraEnabled(cacheable=true)
public static List<Time_Period__c> downloadCustomtimeperiodAA(String OrderId) {
    return [SELECT Id, Name, Day__c, MenuName__c, MondayStart__c, MondayStop__c, Schedule__r.UCF_Name__c, Start__c, Stop__c, Menu__c, Overflow_Timer__c,Overflow_Destination__c, TuesdayStart__c, TuesdayStop__c, WednesdayStart__c, WednesdayStop__c, ThursdayStart__c, ThursdayStop__c, FridayStart__c, FridayStop__c, SaturdayStart__c, SaturdayStop__c, SundayStart__c, SundayStop__c
    FROM Time_Period__c where Schedule__r.UCF_Order__c =: OrderId AND Schedule__r.RecordType.DeveloperName =: 'Auto_Attendants'];
}

@AuraEnabled(cacheable=true)
public static List<Greetings__c> getGreetings(String OrderId) {
    return [SELECT Id,Order__c, Name,Message_Board__c FROM Greetings__c where Order__c=:OrderId];
}

    @AuraEnabled
public static String saveMenuLines(List<Menu_Line__c> menuLines) {

        try {
            System.debug('menu '+ menuLines);
        update menuLines;
        return 'Menu  Lines Updated Successfully';
    } catch (Exception e) {
        return 'Error Updating record: ' + e.getMessage();
    }
}

    @AuraEnabled
public static String updateAaSetupData(List<ftr_DID_Number_Details__c > aaSetupData) {

        try {
            System.debug('menu '+ aaSetupData);
        update aaSetupData;
        return 'AA Setup data Updated Successfully';

    } catch (Exception e) {
            System.debug('menu 2 '+ e.getMessage());
        return 'Error Updating record: ' + e.getMessage();
    }
}



@AuraEnabled
public static String updateMenuFields(String menuId, String greetingName, String menuName) {
try {
    // Query the menu record based on the provided ID
    List<Menu__c> lstMenu = [SELECT Id, Greeting__c, Name FROM Menu__c WHERE Id = :menuId];
    
    // Check if we have at least one record
    if (lstMenu != null && !lstMenu.isEmpty()) {
        // There should only be one record because menuId is unique
        Menu__c menuToUpdate = lstMenu.get(0);

        // Update the fields with the new values
        menuToUpdate.Greeting__c = greetingName;
        menuToUpdate.Name = menuName;

        // Update the record outside the loop
        update menuToUpdate;
    }

    return 'Menu Updated Successfully';
} catch (Exception e) {
    return 'Error Updating record: ' + e.getMessage();
}
}




@AuraEnabled
public static String insertSchedule(String scheduleName,String orderId, String RecordTypeId) {
    try {
        //System.debug('00001');
        Order orderContract=[SELECT Id, Name,Contract_Schedule__c FROM Order where Id = :orderId];
        
            system.debug('Recford type'+RecordTypeId);
        if(orderContract.Contract_Schedule__c!= Null){
            Schedule__c schedule = new Schedule__c();
        Schedule.UCF_Name__c = scheduleName;
        Schedule.UCF_Order__c = orderId;
        schedule.Schedule_Start_Date__c=Date.today();
        schedule.Contract__c=orderContract.Contract_Schedule__c;
        schedule.RecordTypeId = [select id from recordtype where DeveloperName=:RecordTypeId limit 1].id;
        insert schedule;
            string schId = schedule.id;
             if(schId != null && schId != '')
            {
                 List<Holiday__c> holidays = new List<Holiday__c>{
                new Holiday__c(Name='New Year\'s Eve', Schedule__c=schedule.Id, Sort_Order__c=1),
                new Holiday__c(Name='New Year\'s Day', Schedule__c=schedule.Id, Sort_Order__c=2),
                new Holiday__c(Name='Martin Luther King Jr Day', Schedule__c=schedule.Id, Sort_Order__c=3),
                new Holiday__c(Name='Memorial Day', Schedule__c=schedule.Id, Sort_Order__c=4),
                new Holiday__c(Name='Independence Day', Schedule__c=schedule.Id, Sort_Order__c=5),
                new Holiday__c(Name='Labor Day', Schedule__c=schedule.Id, Sort_Order__c=6),
                new Holiday__c(Name='Veterans Day', Schedule__c=schedule.Id, Sort_Order__c=7),
                new Holiday__c(Name='Thanksgiving Day', Schedule__c=schedule.Id, Sort_Order__c=8),
                new Holiday__c(Name='Christmas Eve', Schedule__c=schedule.Id, Sort_Order__c=9),
                new Holiday__c(Name='Christmas Day', Schedule__c=schedule.Id, Sort_Order__c=10)
            };
            insert holidays;
            }
        return 'Schedule Created Succesfully';
        }
        else{
            return 'Please Select Contract On Order';  
        }
    } catch (Exception e) {
        return 'Error creating Schedule: ' + e.getMessage();
    }
}
@AuraEnabled
public static String deleteSchedule(String scheduleId) {
    try {
        list<Holiday__c> delHolidayList = new list<Holiday__c>();
        delHolidayList = [select id from Holiday__c where Schedule__c =: scheduleId];
        if(delHolidayList != null && delHolidayList.size() > 0)
        {
            delete delHolidayList;
        }
        Schedule__c schedule=[SELECT Id, Name FROM Schedule__c where Id = :scheduleId];
        
        delete schedule;
        return 'Schedule deleted successfully';
    } catch (Exception e) {
        return 'Error deleting Schedule: ' + e.getMessage();
    }
}
//Methods for Greetings
@AuraEnabled(cacheable=true)
public static List<Greetings__c> greetingsforAutoAttendantsGreetings(String orderId) {
    List<Greetings__c> greetings = [SELECT Id,Name,Message_Board__c FROM Greetings__c where Order__c = :orderId ];
    return greetings;
}
@AuraEnabled
public static String insertGreeting(String greetingName,String orderId) {
    try {
            Greetings__c greeting = new Greetings__c();
            greeting.Name = greetingName;
            greeting.Order__c = orderId;
            insert greeting;
            return 'Greeting Created Succesfully';
    } catch (Exception e) {
        return 'Error creating Schedule: ' + e.getMessage();
    }
}
@AuraEnabled
public static String deleteGreeting(String greetingId) {
    try {
        //System.debug('00001');
        Greetings__c greeting=[SELECT Id, Name FROM Greetings__c where Id = :greetingId];
        
        delete greeting;
        return 'Greetings deleted successfully';
    } catch (Exception e) {
        return 'Error deleting Greetings: ' + e.getMessage();
    }
}
@AuraEnabled
public static Greetings__c greetingforEdit(String greetingId) {
    try{
        Greetings__c greetings = [SELECT Id,Name,Message_Board__c FROM Greetings__c where Id = :greetingId ];
        return greetings;
    }catch (QueryException e) {
        System.debug('Query Exception: ' + e.getMessage());
        throw new AuraHandledException('Error retrieving Greeting record: ' + e.getMessage());
    } catch (Exception e) {
        System.debug('Exception: ' + e.getMessage());
        throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
    }
    
}
@AuraEnabled()
public static string updateGreeting(Greetings__c greetingrec) {
    try {
        update greetingrec;
        return 'Greeting Updated Successfully';
    } catch (Exception e) {
        return 'Error Updating record: ' + e.getMessage();
    }
}

//Methods for Menus
@AuraEnabled
public static List<Menu__c> menusforAutoAttendants(String orderId) {
    system.debug('Menuss order id>> ' +orderId );
    List<Menu__c> menus = [SELECT Id,Name,Greeting__c FROM Menu__c where Order__c = :orderId ];
     system.debug('Menuss >> ' +menus );
    return menus;
}
@AuraEnabled
public static String insertMenus(String menuName, String orderId) {
try {
    // Insert Menu
    Menu__c menu = new Menu__c();
    menu.Name = menuName;
    menu.Order__c = orderId;
    insert menu;

    // Prepare to insert Menu Line Items
    List<Menu_Line__c> menuLines = new List<Menu_Line__c>();
    for (Integer i = 1; i <= 12; i++) {
        Menu_Line__c line = new Menu_Line__c();
        line.Menu__c = menu.Id; // Assuming a relationship field to Menu__c
        line.Sort_Order__c = i;
        // Assign Number__c and Options__c based on the loop index
        if (i <= 9) {
            line.Number__c = String.valueOf(i);
        } else if (i == 10) {
            line.Number__c = '0';
        } else if (i == 11) {
            line.Number__c = '*';
            line.Options__c = 'Replay Menu';
        } else if (i == 12) {
            line.Number__c = '#';
            line.Options__c = 'Previous Menu';
        }
        menuLines.add(line);
    }

    // Insert Menu Lines
    insert menuLines;

    return 'Menu and Menu Lines Created Successfully';
} catch (Exception e) {
    return 'Error creating Menu and Menu Lines: ' + e.getMessage();
}
}
@AuraEnabled
public static String deleteMenus(String menuId) {
    try {
        //System.debug('00001');
        Menu__c menu=[SELECT Id, Name FROM Menu__c where Id = :menuId];
        
        delete menu;
        return 'Menu deleted successfully';
    } catch (Exception e) {
        return 'Error deleting Menu: ' + e.getMessage();
    }
}

    @AuraEnabled
public static List<Time_Period__c> getTimePeriodData(string didId) {

    

        // Get the Schedule ID from the DID Number Details
List<ftr_DID_Number_Details__c> didNumberDetails = [SELECT Schedule__c FROM ftr_DID_Number_Details__c WHERE Id =: didId LIMIT 1];
String scheduleId = (didNumberDetails.isEmpty()) ? null : didNumberDetails[0].Schedule__c;
system.debug('AA Setup scheduleId: '+ scheduleId);
    List<Time_Period__c> timePeriodList = new List<Time_Period__c>();
if (String.isNotBlank(scheduleId)) {
    // Query Time Periods with the associated Menu
    timePeriodList = [
        SELECT Id, Name, Menu__c, Menu__r.Name, Menu__r.Greeting__c
        FROM Time_Period__c
        WHERE Schedule__c =: scheduleId
    ];
    

}
    return timePeriodList;
}


@AuraEnabled(cacheable=true)
public static List<TimePeriodWrapper> getTimePeriodData2(string didId) {
System.debug('Called getTimePeriodData with didId: ' + didId);
List<TimePeriodWrapper> wrappedTimePeriods = new List<TimePeriodWrapper>();


// Get the Schedule ID from the DID Number Details
List<ftr_DID_Number_Details__c> didNumberDetails = [SELECT Schedule__c FROM ftr_DID_Number_Details__c WHERE Id =: didId LIMIT 1];
String scheduleId = (didNumberDetails.isEmpty()) ? null : didNumberDetails[0].Schedule__c;
system.debug('AA Setup scheduleId: '+ scheduleId);

if (String.isNotBlank(scheduleId)) {
    // Query Time Periods with the associated Menu
    List<Time_Period__c> timePeriodList = [
        SELECT Id, Name, Menu__c, Menu__r.Name
        FROM Time_Period__c
        WHERE Schedule__c =: scheduleId
    ];
system.debug('AA Setup timePeriodList: '+ timePeriodList);
    system.debug('AA Setup timePeriodList size : '+ timePeriodList.size());
    // Collect Menu IDs
    Set<Id> menuIds = new Set<Id>();
    for (Time_Period__c tp : timePeriodList) {
        menuIds.add(tp.Menu__c);
    }
    
    system.debug('AA Setup menuIds: '+ timePeriodList);
    system.debug('AA Setup menuIds size : '+ menuIds.size());

    // Query Menu Lines with Greetings for all Menus
    Map<Id, String> menuIdToGreetingMap = new Map<Id, String>();
    for (Menu_Line__c ml : [SELECT Menu__c, Greeting__c FROM Menu_Line__c WHERE Menu__c IN :menuIds]) {
        menuIdToGreetingMap.put(ml.Menu__c, ml.Greeting__c);
    }
    
    system.debug('AA Setup menuIdToGreetingMap: '+ menuIdToGreetingMap);
    system.debug('AA Setup menuIdToGreetingMap size : '+ menuIdToGreetingMap.size());

    // Wrap the Time Periods with the Greetings
    for (Time_Period__c tp : timePeriodList) {
        String greeting = menuIdToGreetingMap.get(tp.Menu__r.Id);
        wrappedTimePeriods.add(new TimePeriodWrapper(tp.Id, tp.Name, tp.Menu__r.Name, greeting));
    }
    system.debug('AA Setup wrappedTimePeriods: '+ wrappedTimePeriods);
    system.debug('AA Setup wrappedTimePeriods size : '+ wrappedTimePeriods.size());
}

return wrappedTimePeriods;
}


//Methods for AA Setup
@AuraEnabled
public static List<ftr_DID_Number_Details__c> ftrDIDNumberDetailsAutoAttendantsSetup(string orderId) {
    try{
        System.debug('AA called');
    List<ftr_DID_Number_Details__c> DIDNumberDetail = [SELECT Id,DIDNumber__c,Ucf_Extension__c, 
        Ring_Pattern__c,Ucf_User_Name__c,EAS_Pin__c,Schedule__r.UCF_Name__c,
    Schedule__c,Member__c,MLHG_Name__c,Ucf_Customize_Extension__c,ucf_Auto_Attendent_Name__c,Ucf_Extension_Lenght__c
        FROM ftr_DID_Number_Details__c 
        WHERE Ucf_Number_Use__c='Auto Attendant'
        AND DIDLocationDetailsId__r.OrderId__c  =: orderId];
        return DIDNumberDetail;
    }
    catch(Exception ex){
        throw new AuraHandledException('Darn it! Something went wrong: '
        + ex.getMessage()+' Line number'+ex.getLineNumber());   
    }
}
@AuraEnabled(cacheable=true)
public static List<Schedule__c> ScheduleforAutoAttendantSetUp(string orderId) {
    List<Schedule__c> Schedule = [SELECT 
                                    Id,
                                    Name,
                                    Ucf_Name__c,
                                    Overflow_Timer_24_7__c,
                                    Overflow_Destination_24_7__c,
                                    Overflow_Timer_Closed__c,
                                    Overflow_Destination_Closed__c,
                                    Holiday__c, 
                                    Holiday_Date__c 
                                FROM Schedule__c where UCF_Order__c =: orderId AND RecordType.Name=:'Auto Attendants'];
    System.debug(Schedule);
    return Schedule;
}
    /*
    @AuraEnabled
    public static List<Time_Period__c> saveTimePeriodRecords(List<Time_Period__c> combinedTimePeriodsToSave ) {
    try {
        // Perform a DML operation to insert the new records
        System.debug('AA TP '+ combinedTimePeriodsToSave);
        
        insert combinedTimePeriodsToSave ;
        return combinedTimePeriodsToSave ; // Return the inserted records with their new IDs
    } catch (Exception e) {
        // Error handling
        System.debug('AA TP '+ e.getMessage());
        throw new AuraHandledException('Error: ' + e.getMessage());
    }
    }
 */
    @AuraEnabled
    public static List<Holiday__c> addHoliDays(List<Holiday__c> holidays) {
    try {
        // Perform a DML operation to insert the new records
        insert holidays;
        return holidays; // Return the inserted records with their new IDs
    } catch (Exception e) {
        // Error handling
        throw new AuraHandledException('Error: ' + e.getMessage());
    }
    }

    @AuraEnabled
public static List<Holiday__c> getHolidaysBySchedule(string scheduleId) {
    return [
        SELECT Id, Schedule__c, Date__c, Name
        FROM Holiday__c
        WHERE Schedule__c = :scheduleId
        AND Date__c != null
        ORDER BY Date__c
    ];
}


    @AuraEnabled
public static List<Holiday__c> getHolidaysByScheduleId(String scheduleId) {
    // Query to fetch holidays based on the provided schedule ID
    return [SELECT Id, Name, Date__c, Schedule__c FROM Holiday__c WHERE Schedule__c = :scheduleId and Date__c != null];
}

@AuraEnabled
public static Schedule__c updateSchedule(Schedule__c updatedSchedule, String menuOpen, String menuClosed, String menu247, String menuHoliday) {
    try {
        update updatedSchedule; // Update the schedule record

        Map<String, Id> menuNameToIdMap = new Map<String, Id>();
        // Query for menus
        for (Menu__c menu : [SELECT Id, Name FROM Menu__c WHERE Name IN :new List<String>{menuOpen, menuClosed, menu247, menuHoliday}]) {
            menuNameToIdMap.put(menu.Name, menu.Id);
        }

        // Fetch existing Time_Period__c records
        List<Time_Period__c> existingTimePeriods = [SELECT Id, Name FROM Time_Period__c WHERE Schedule__c = :updatedSchedule.Id AND Name IN ('Open', 'Closed', '24/7', 'Holiday')];
        Map<String, Time_Period__c> nameToTimePeriodMap = new Map<String, Time_Period__c>();
        for (Time_Period__c tp : existingTimePeriods) {
            nameToTimePeriodMap.put(tp.Name, tp);
        }

        // Upsert Time Periods
        upsertTimePeriods(menuNameToIdMap, nameToTimePeriodMap, updatedSchedule.Id, menuOpen, 'Open');
        upsertTimePeriods(menuNameToIdMap, nameToTimePeriodMap, updatedSchedule.Id, menuClosed, 'Closed');
        upsertTimePeriods(menuNameToIdMap, nameToTimePeriodMap, updatedSchedule.Id, menu247, '24/7');
        upsertTimePeriods(menuNameToIdMap, nameToTimePeriodMap, updatedSchedule.Id, menuHoliday, 'Holiday');

        return updatedSchedule;
    } catch (Exception e) {
        throw new AuraHandledException('Error: ' + e.getMessage());
    }
}

private static void upsertTimePeriods(Map<String, Id> menuNameToIdMap, Map<String, Time_Period__c> nameToTimePeriodMap, Id scheduleId, String menuName, String timePeriodName) {
    if (!String.isEmpty(menuName)) {
        Time_Period__c tp = nameToTimePeriodMap.get(timePeriodName) != null ? nameToTimePeriodMap.get(timePeriodName) : new Time_Period__c();
        tp.Name = timePeriodName;
        tp.Menu__c = menuNameToIdMap.get(menuName);
        tp.Schedule__c = scheduleId;
        upsert tp;
    }
}

public class TimePeriodWrapper {
public Id id;
public String name;
public String menuName;
public String greeting;

public TimePeriodWrapper(Id id, String name, String menuName, String greeting) {
    this.id = id;
    this.name = name;
    this.menuName = menuName;
    this.greeting = greeting;
}
}

@AuraEnabled
public static List<Time_Period__c> saveTimePeriodsNew(List<Time_Period__c> timePeriods) {
    // Perform any required processing before saving
    // Always ensure that you handle exceptions and check for permissions as needed
    try {
        System.debug('timePeriods '+ timePeriods);
        upsert timePeriods;
    } catch (Exception e) {
        // Handle the exception appropriately
        throw new AuraHandledException('Error saving time periods: ' + e.getMessage());
    }
    return timePeriods;
}


@AuraEnabled
public static List<Time_Period__c> getSavedTimePeriods(String scheduleId) {
    // Query to fetch saved schedules
    return  [select 
    Id,  Name, Day__c, MondayStart__c, 
    MondayStop__c, Schedule__c, Start__c, 
    Stop__c, Menu__c, Overflow_Destination__c,
        Overflow_Timer__c, TuesdayStart__c, TuesdayStop__c
        , WednesdayStart__c, WednesdayStop__c, ThursdayStart__c,
        ThursdayStop__c, FridayStart__c,  FridayStop__c,
        SaturdayStart__c, SaturdayStop__c,MenuName__c,
        SundayStart__c, SundayStop__c
        from Time_Period__c  where Schedule__c =:scheduleId and Name not in ('Open','Closed','24/7','Holiday')];
}   
    @AuraEnabled
public static void deleteHolidayById(Id holidayId) {
try {
    delete [SELECT Id FROM Holiday__c  WHERE Id = :holidayId];
} catch(Exception e) {
    // Handle exceptions
    throw new AuraHandledException('Error: ' + e.getMessage());
}
}

}