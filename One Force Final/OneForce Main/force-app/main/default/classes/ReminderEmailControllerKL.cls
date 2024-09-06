public with sharing class ReminderEmailControllerKL {
    public ReminderEmailControllerKL() {

    }
    public static void  sendReminderEmail() {

        // For TimeSheet period 
        Date weekStartDate = Date.today().toStartofWeek();
        Date initialWeekStartDate = getDayName(weekStartDate).toLowerCase() == 'sunday' ? weekStartDate : weekStartDate - 1;
        Date dateFrom = initialWeekStartDate.addDays(-7); // NEW WORK SAME AS ADP
        Date dateTo = dateFrom.addDays(13);
        List<TimesheetWrapper> finalResponse = new List<TimesheetWrapper>();

        /*List<TimeSheet__c> timesheetList = [SELECT Id, Name, Day__c, Contact__c, Project__c,
                                            Project__r.Name,
                                            Hours__c, Overtime__c, Pay_Code__c, Final_Hours__c,
                                            Status__c, Contact__r.Name,
                                            Contact__r.Account.Name,
                                            Type_of_participation__c,
                                            Project_Participants__c,
                                            Project_Participants__r.Role__c
                                            FROM TimeSheet__c
                                            WHERE 
                                            //Contact__r.Nespon_Manager__c =: conId
                                            //AND
                                             Status__c = 'Submitted'
                                            AND Day__c >=: dateFrom
                                            AND Day__c <=: dateTo];*/
        List<TimeSheet__c> timesheetList = [SELECT Id, Name, Day__c, Contact__c    ,
                                            Status__c, Contact__r.Name                                          
                                            FROM TimeSheet__c
                                            WHERE 
                                            //Contact__r.Nespon_Manager__c =: conId
                                            //AND
                                             Status__c = 'Submitted'
                                            AND Day__c >=: dateFrom
                                            AND Day__c <=: dateTo]; 
        System.debug('dateFrom:::'+dateFrom+ ':::dateTo:::'+dateTo);                                  
        System.debug( ':::: timesheetList.size: ' + timesheetList.size());

    }
//******************************** */

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
       // @AuraEnabled
      //  public String payCode {get; set;}
       // @AuraEnabled 
       // public List<ComboboxValues> payCodes {get; set;}
      //  @AuraEnabled
       // public String project {get; set;}
        @AuraEnabled
        public String projectName {get; set;}
      //  @AuraEnabled 
      //  public List<ComboboxValues> projects {get; set;}
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

    public Static String getDayName(Date dateValue) {
        Datetime dt = (DateTime) dateValue + 1; 
        String dayOfWeek = dt.format('EEEE');
        return dayOfWeek;
    }
   

}