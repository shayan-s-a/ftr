public class FetchDataMLHG {
    
    /**
* @description Method to load data for MLHG Setup
* @param recordId the order record Id
* @return InitResponse
*/
    @AuraEnabled
    public static InitResponse ftrDIDNumberDetailsMLHG(String recordId) {
        InitResponse ir = new InitResponse();
        ir.ftrDIDNumberDetailList = [SELECT Id, DIDLocationDetailsId__r.OrderId__c,DIDLocationDetailsId__c,DIDNumber__c, EAS_Pin__c, Ucf_Extension__c, Ucf_Extension_Lenght__c, Ucf_Customize_Extension__c, 
                                     Ring_Pattern__c, Ucf_User_Name__c, Schedule__c,Schedule__r.UCF_Name__c, Member__c, MLHG_Name__c 
                                     FROM ftr_DID_Number_Details__c 
                                     WHERE Ucf_Number_Use__c='Multi-Line Hunting Group'
                                     AND DIDLocationDetailsId__r.OrderId__c  =: recordId ORDER BY Ucf_User_Name__c ASC];
        ir.availableDIDNumberList = [SELECT Id, DIDNumber__c, Ucf_Extension__c, Ucf_User_Name__c,EAS_Pin__c,DIDLocationDetailsId__r.OrderId__c  
                                     FROM ftr_DID_Number_Details__c 
                                     WHERE Ucf_Number_Use__c ='DID' 
                                     AND DIDLocationDetailsId__r.OrderId__c  =: recordId];
        System.debug('ir: '+ir);
        return ir;
    }
    

    @AuraEnabled
    public static list<MLHG_Member__c> ftrSelectedMembers(String recordId) {
        List<MLHG_Member__c> ftrMembersDetails = new List<MLHG_Member__c>();
        ftrMembersDetails = [SELECT Id, Name, DID_Number_Details__c,DID_Number_Details__r.Name,Parent_DID_Number_Detail__r.MLHG_Name__c
        FROM MLHG_Member__c WHERE  DID_Number_Details__r.DIDLocationDetailsId__r.OrderId__c =:recordId];
        System.debug('ftrMembersDetails: '+ftrMembersDetails);
        return ftrMembersDetails;
    }
    @AuraEnabled(cacheable=true)
    public static List<Time_Period__c> downloadCustomtimeperiodMLHG(String OrderId) {
        return [SELECT Id, Name, Day__c, MenuName__c, MondayStart__c, MondayStop__c, Schedule__r.UCF_Name__c, Start__c, Stop__c, Menu__c, Overflow_Timer__c, Overflow_Destination__c,TuesdayStart__c, TuesdayStop__c, WednesdayStart__c, WednesdayStop__c, ThursdayStart__c, ThursdayStop__c, FridayStart__c, FridayStop__c, SaturdayStart__c, SaturdayStop__c, SundayStart__c, SundayStop__c
        FROM Time_Period__c where Schedule__r.UCF_Order__c =: OrderId
                AND Schedule__r.RecordType.DeveloperName =: 'Multi_Line_Hunting_Groups'
               ];
    }
    /**
* @description Wrapper class to hold response to display
*/
    public Class InitResponse{
        @AuraEnabled public list<ftr_DID_Number_Details__c> ftrDIDNumberDetailList;
        @AuraEnabled public list<ftr_DID_Number_Details__c> availableDIDNumberList;
    }
    
    /**
* @description Method to perform 3 operations
* Operation 1: Make updates(Member Count) send from LWC on the DID Number Detail record
* Operation 2: Insert new members if any
* Operation 3: Delete records of MLHG Member if any member is removed
* @param didRecordToUpdate
* @param gmRecordsList
*/
    @AuraEnabled
    public static void updateRecords(ftr_DID_Number_Details__c didRecordToUpdate, List<MLHG_Member__c> gmRecordsList, Boolean ishandle) {
        
        system.debug('gmRecordsList: '+gmRecordsList);
        system.debug('didRecordToUpdate: '+didRecordToUpdate);
        try {
            ftr_DID_Number_Details__c fdnd = [SELECT Id, Ring_Pattern__c
                                              FROM ftr_DID_Number_Details__c
                                              WHERE Id =: didRecordToUpdate.Id];
            if(fdnd.Ring_Pattern__c == 'Ring One at a Time' && gmRecordsList.size() > 32){
                throw new AuraHandledException('You cannot select more than 32 users');
            }
            
            // Operation 1
            update didRecordToUpdate;

            if(ishandle == true){
            //Operation 2
            List<MLHG_Member__c> newMlhgMembersToInsert = new List<MLHG_Member__c>();
            Set<String> existingMembersSet = new Set<String>();
            Set<String> membersInGmRecordsSet = new Set<String>();
            Set<String> removedMembersSet = new Set<String>();
            List<MLHG_Member__c> mlghMemberRecordsToDeleteList = new List<MLHG_Member__c>();
            
            // Operation 2
            // fetch all exisitng MLHG members of the DID Number Detail being edited 
            for (MLHG_Member__c existingRec : [SELECT Id, DID_Number_Details__c, Name 
                                               FROM MLHG_Member__c 
                                               WHERE Parent_DID_Number_Detail__c =: didRecordToUpdate.Id]) {
                                                   existingMembersSet.add(existingRec.DID_Number_Details__c);
                                               }
            
            // clean duplicates to avoid inserting same member multiple times

            
            for (MLHG_Member__c rmRec : gmRecordsList) {
                membersInGmRecordsSet.add(rmRec.DID_Number_Details__c); // maintaining for Operation 3
                if (!existingMembersSet.contains(rmRec.DID_Number_Details__c)) {
                    newMlhgMembersToInsert.add(rmRec);
                }
            }
            
            System.debug('newMlhgMembersToInsert size : '+ newMlhgMembersToInsert.size());
            // Insert records if no duplicates were found
            if( newMlhgMembersToInsert.size() > 0 && newMlhgMembersToInsert != null ){
                System.debug('newMlhgMembersToInsert inside insert');
                insert newMlhgMembersToInsert;
                } 

            System.debug('existingMembersSet size : '+ existingMembersSet.size());
    
            //Operation 3
            for (String member : existingMembersSet) {
                if (!membersInGmRecordsSet.contains(member)) {
                    removedMembersSet.add(member);
                }
            }

            System.debug('removedMembersSet size : '+ removedMembersSet.size());

            // fetch all exisitng group members record required to delete
            for (MLHG_Member__c rec : [SELECT Id FROM MLHG_Member__c 
                                       WHERE DID_Number_Details__c IN: removedMembersSet 
                                       AND Parent_DID_Number_Detail__c =: didRecordToUpdate.Id]) {
                                           mlghMemberRecordsToDeleteList.add(rec);
                                       }
            System.debug('mlghMemberRecordsToDeleteList size : '+ mlghMemberRecordsToDeleteList.size());
            // delete records
            if(mlghMemberRecordsToDeleteList.size() > 0 && mlghMemberRecordsToDeleteList != null) delete mlghMemberRecordsToDeleteList;
                                    }
            
        } catch (Exception e) {
            throw new AuraHandledException('Transaction Failed. Error: '+e.getMessage());
        }
        
    }
    
    /**
* @description Method to get MLHG Member records
* @param recordId the DID Number Detail record Id
* @return List<Group_Member__c>
*/
    @AuraEnabled
    public static List<MLHG_Member__c> GetDidNumbers(String didNumberId) {
        return [SELECT Id, DID_Number_Details__c, Name 
                FROM MLHG_Member__c 
                WHERE Parent_DID_Number_Detail__c =: didNumberId];
    }
    
    @AuraEnabled
    public static Boolean validateRingOneAtaTime(String didNumberId) {
        ftr_DID_Number_Details__c fdnd = [SELECT Id, Ring_Pattern__c
                                          FROM ftr_DID_Number_Details__c
                                          WHERE Id =: didNumberId];
        return fdnd.Ring_Pattern__c == 'Ring One at a Time' ? true : false;
     }
     @AuraEnabled
    public static List<Holiday__c> getHolidaysBySchedule(string scheduleId) {
        return [
            SELECT Id, Schedule__c, Date__c, Name
            FROM Holiday__c
            WHERE Schedule__c = :scheduleId
             ORDER BY Sort_Order__c ASC
        ];
    }
    @AuraEnabled
    public static List<Holiday__c> downloadHolidaysBySchedule(string OrderId ) {
        
        Map<ID, Schedule__c> mapSchedules = new Map<ID, Schedule__c>([SELECT Id,Name FROM Schedule__c 
                                                                      WHERE 
                                                                      RecordType.DeveloperName =: 'Multi_Line_Hunting_Groups' and  
                                                                      UCF_Order__c =: OrderId ]);
        System.Debug('mapSchedules =' +  mapSchedules);
        if(mapSchedules != null || !mapSchedules.isEmpty())
        {
            List<Holiday__c> lstHolidays = [SELECT  Id, OwnerId, IsDeleted, Name,ConnectionReceivedId, ConnectionSentId, Date__c, Schedule__c,
                                            Ucf_Menu__c, Sort_Order__c, Schedule__r.UCF_Name__c 
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

      @AuraEnabled
    public static void updateHolidays(List<Holiday__c> holidays) {
        try {
            System.debug('Holdaus: '+ holidays);
            // Assuming updatedSchedule has an ID, this will update the record
            update holidays;
        } catch (Exception e) {
           System.debug('holidays '+ e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<Holiday__c> addHoliDays(List<Holiday__c> holidays) {
        try {
             system.debug('holi');
              system.debug('holi List '+ holidays);
            insert holidays;
            return holidays; // Return the inserted records with their new IDs
        } catch (Exception e) {
            // Error handling
            system.debug('holi e.getMessage()' + e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Schedule__c> ScheduleforMLHGSetUp(String orderId,String RecordTypeId) {
        List<Schedule__c> Schedule = [SELECT 
                                      Id,
                                      Name,
                                      Overflow_Timer_24_7__c,
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
                                      Ucf_Name__c,
                                      Monday__c,
                                      Tuesday__c,
                                      Wednesday__c,
                                      Thursday__c, 
                                      Friday__c, 
                                      Saturday__c,
                                      Sunday__c,
                                      RecordType.Name
                                      FROM Schedule__c where UCF_Order__c = :orderId AND RecordType.Name =: 'Multi-Line Hunting Groups'];
        System.debug(Schedule);
        return Schedule;
    }
    
    @AuraEnabled
    public static List<Schedule__c> queryschedules(String orderId) {
        List<Schedule__c> schedule = [SELECT Id, UCF_Name__c,Name,X247_checkbox__c,
                                      Overflow_Timer_24_7__c,
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
                                      Saturday__c,
                                      Sunday__c,
                                      RecordType.Name
                                      FROM Schedule__c where UCF_Order__c = :orderId AND RecordType.Name =: 'Multi-Line Hunting Groups'];
        return schedule;
    }
    
    @AuraEnabled
    public static List<Time_Period__c> saveTimePeriodRecords(List<Time_Period__c> timePeriodList) {
        try {
            // Perform a DML operation to insert the new records
            system.debug('MLHG '+ timePeriodList);
            insert timePeriodList;
            return timePeriodList; // Return the inserted records with their new IDs
        } catch (Exception e) {
            // Error handling
            system.debug('MLHG ex '+ e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Schedule__c updateSchedule(Schedule__c updatedSchedule) {
        try {
            System.debug('MLHG: '+ updatedSchedule);
            // Assuming updatedSchedule has an ID, this will update the record
            update updatedSchedule;
            return updatedSchedule;
        } catch (Exception e) {
            // Error handling
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String updateSchdule(Decimal overflowT24, 
                                       String overflowD24, 
                                       String holidayName, 
                                       Date holidayDate,
                                       Decimal overflowTOpen, 
                                       String overflowDOpen,
                                       String schId
                                      ) {
                                          System.debug('0001 : here');
                                          System.debug('0001 : ' );
                                          try {
                                              // Perform updates on the records
                                              
                                              Schedule__c sch = new Schedule__c();
                                              sch.ID = schId;
                                              if(overflowT24 != null )
                                              {
                                                  sch.Overflow_Timer_24_7__c =  overflowT24;
                                              }
                                              if(overflowT24 != null)
                                              {
                                                  sch.Overflow_Destination_24_7__c = overflowD24;
                                              }
                                              if(overflowTOpen != null)
                                              {
                                                  sch.Overflow_Timer_Closed__c    = overflowTOpen;
                                              }
                                              if(overflowDOpen != null )
                                              {
                                                  sch.Overflow_Destination_Closed__c = overflowDOpen;
                                              }
                                              if(holidayName != null && holidayName != '')
                                              {
                                                  sch.Holiday__c = holidayName;
                                                  
                                              }
                                              
                                              update sch;
                                              
                                              return 'Records updated successfully.';
                                          } catch (Exception e) {
                                              return 'Error updating records: ' + e.getMessage();
                                          }
                                      }
}