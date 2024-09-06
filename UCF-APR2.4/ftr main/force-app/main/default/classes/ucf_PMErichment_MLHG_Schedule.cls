public with sharing class ucf_PMErichment_MLHG_Schedule {
        @AuraEnabled(cacheable=true)
        public static List<Schedule__c> queryschedules(String orderId) {
        List<Schedule__c> schedule = [SELECT Id, UCF_Name__c,Name FROM Schedule__c where UCF_Order__c = :orderId ];
        return schedule;
    }

@AuraEnabled
public static String insertHolidayName(String holidayName, String scheduleId) {
    try {
        // Get the last holiday based on sort order
        List<Holiday__c> lastHolidayList = [
            SELECT Sort_Order__c 
            FROM Holiday__c 
            WHERE Schedule__c = :scheduleId 
            ORDER BY Sort_Order__c DESC 
            LIMIT 1
        ];
        System.debug('Holiday lastHolidayList '+ lastHolidayList);

        Integer newSortOrder = 1; // Default sort order if no holidays exist yet
         System.debug('Holiday newSortOrder '+ newSortOrder);

        // If a holiday exists, increment the last sort order by 1
        if (!lastHolidayList.isEmpty()) {
             System.debug('Holiday newSortOrder1loop : '+ Integer.valueOf(lastHolidayList[0].Sort_Order__c) + 1);
            newSortOrder = Integer.valueOf(lastHolidayList[0].Sort_Order__c) + 1;
        }

        // Create a new holiday record
        Holiday__c newHoliday = new Holiday__c();
        newHoliday.Name = holidayName;
        newHoliday.Schedule__c = scheduleId;
        newHoliday.Sort_Order__c = newSortOrder;

        // Insert the new holiday
        insert newHoliday;

        return 'Holiday added succesfully';
    } catch (Exception e) {
        // Handle any exceptions
        return 'Error creating Holiday: ' + e.getMessage();
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
            schedule.RecordTypeId = [select id,Name from recordtype where Name=:RecordTypeId limit 1].id;
            insert schedule;
            string schId = schedule.id;

            if(schId != null && schId != '')
            {
                 List<Holiday__c> holidays = new List<Holiday__c>{
                new Holiday__c(Name='New Year\'s Eve', Schedule__c=schedule.Id, Sort_Order__c=1),
                new Holiday__c(Name='New Year\'s Day', Schedule__c=schedule.Id, Sort_Order__c=2),
                new Holiday__c(Name='Martin Luther King Jr Day', Schedule__c=schedule.Id, Sort_Order__c=3),
                new Holiday__c(Name='Memorial Day', Schedule__c=schedule.Id, Sort_Order__c=4),
                new Holiday__c(Name='Juneteenth Day', Schedule__c=schedule.Id, Sort_Order__c=5),
                new Holiday__c(Name='Independence Day', Schedule__c=schedule.Id, Sort_Order__c=6),
                new Holiday__c(Name='Labor Day', Schedule__c=schedule.Id, Sort_Order__c=7),
                new Holiday__c(Name='Veterans Day', Schedule__c=schedule.Id, Sort_Order__c=8),
                new Holiday__c(Name='Thanksgiving Day', Schedule__c=schedule.Id, Sort_Order__c=9),
                new Holiday__c(Name='Christmas Eve', Schedule__c=schedule.Id, Sort_Order__c=10),
                new Holiday__c(Name='Christmas Day', Schedule__c=schedule.Id, Sort_Order__c=11)
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
            //System.debug('00001');
            Schedule__c schedule=[SELECT Id, Name FROM Schedule__c where Id = :scheduleId];
            
            delete schedule;
            return 'Schedule deleted successfully';
        } catch (Exception e) {
            return 'Error deleting Schedule: ' + e.getMessage();
        }
    }
}